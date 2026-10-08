-- SolarKatha Phase 2: leads, lead photos, photo storage, PowerSync publication.

create type public.lead_source as enum ('walk_in', 'referral', 'call', 'campaign');
create type public.lead_status as enum ('new', 'surveyed', 'proposal_sent', 'won', 'lost');
create type public.photo_kind as enum ('roof', 'meter', 'db_box', 'wiring_path', 'bill', 'other');

-- ---------------------------------------------------------------------------
-- Tables (ids are generated on the device so records can be created offline)
-- ---------------------------------------------------------------------------

create table public.leads (
  id uuid primary key,
  company_id uuid not null references public.companies (id),
  assigned_to uuid references public.profiles (id),
  created_by uuid references public.profiles (id),
  name text not null check (char_length(btrim(name)) between 1 and 120),
  phone text not null check (phone ~ '^\+?[0-9]{10,15}$'),
  alt_phone text check (alt_phone is null or alt_phone ~ '^\+?[0-9]{10,15}$'),
  address text,
  district text,
  state_code text check (state_code is null or state_code ~ '^[A-Z]{2}$'),
  pincode text check (pincode is null or pincode ~ '^[1-9][0-9]{5}$'),
  lat double precision check (lat is null or lat between -90 and 90),
  lng double precision check (lng is null or lng between -180 and 180),
  source public.lead_source not null default 'walk_in',
  status public.lead_status not null default 'new',
  lost_reason text,
  notes text,
  next_follow_up_at timestamptz,
  consent_at timestamptz,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  deleted_at timestamptz
);

create index leads_company_status_idx on public.leads (company_id, status) where deleted_at is null;
create index leads_assigned_idx on public.leads (assigned_to) where deleted_at is null;
create index leads_phone_idx on public.leads (company_id, phone);

-- Photo metadata. The file lives in Storage at
-- company/<company_id>/lead-photos/<id>.jpg and is uploaded by the app's
-- attachment queue, possibly long after this row syncs.
create table public.lead_photos (
  id uuid primary key,
  company_id uuid not null references public.companies (id),
  lead_id uuid not null references public.leads (id),
  kind public.photo_kind not null default 'other',
  created_by uuid references public.profiles (id),
  created_at timestamptz not null default now(),
  deleted_at timestamptz
);

create index lead_photos_lead_idx on public.lead_photos (lead_id);

create trigger leads_set_updated_at
  before update on public.leads
  for each row execute function private.set_updated_at();

-- ---------------------------------------------------------------------------
-- Visibility helper
-- ---------------------------------------------------------------------------

-- Owners see every lead in their company; sales reps only leads assigned to
-- them. Installers see leads through projects (Phase 6).
create or replace function private.can_access_lead(p_company_id uuid, p_assigned_to uuid)
returns boolean
language sql
stable
security definer
set search_path = ''
as $$
  select p_company_id = private.current_company_id()
     and (private.is_owner() or p_assigned_to = (select auth.uid()))
$$;

revoke all on function private.can_access_lead(uuid, uuid) from public;
grant execute on function private.can_access_lead(uuid, uuid) to authenticated;

-- ---------------------------------------------------------------------------
-- RLS
-- ---------------------------------------------------------------------------

alter table public.leads enable row level security;
alter table public.lead_photos enable row level security;
revoke all on public.leads, public.lead_photos from anon;

create policy leads_select on public.leads
  for select to authenticated
  using ((select private.can_access_lead(company_id, assigned_to)));

create policy leads_insert on public.leads
  for insert to authenticated
  with check (
    (select private.can_access_lead(company_id, assigned_to))
    and created_by = (select auth.uid())
  );

create policy leads_update on public.leads
  for update to authenticated
  using ((select private.can_access_lead(company_id, assigned_to)))
  with check ((select private.can_access_lead(company_id, assigned_to)));

-- No delete policy: leads are soft-deleted (deleted_at). Hard delete after
-- 30 days runs server-side (Phase 7).

create policy lead_photos_select on public.lead_photos
  for select to authenticated
  using (exists (
    select 1 from public.leads l
    where l.id = lead_id
      and l.company_id = lead_photos.company_id
      and private.can_access_lead(l.company_id, l.assigned_to)
  ));

create policy lead_photos_insert on public.lead_photos
  for insert to authenticated
  with check (
    created_by = (select auth.uid())
    and exists (
      select 1 from public.leads l
      where l.id = lead_id
        and l.company_id = lead_photos.company_id
        and private.can_access_lead(l.company_id, l.assigned_to)
        and l.consent_at is not null
    )
  );

create policy lead_photos_update on public.lead_photos
  for update to authenticated
  using (exists (
    select 1 from public.leads l
    where l.id = lead_id
      and private.can_access_lead(l.company_id, l.assigned_to)
  ));

-- ---------------------------------------------------------------------------
-- Audit: lead created, status changed, deleted
-- ---------------------------------------------------------------------------

create or replace function private.log_lead_change()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
begin
  if tg_op = 'INSERT' then
    insert into public.activity_log (company_id, actor_id, entity, entity_id, action, data)
    values (new.company_id, auth.uid(), 'lead', new.id, 'created',
            jsonb_build_object('status', new.status));
  elsif new.deleted_at is not null and old.deleted_at is null then
    insert into public.activity_log (company_id, actor_id, entity, entity_id, action)
    values (new.company_id, auth.uid(), 'lead', new.id, 'deleted');
  elsif new.status is distinct from old.status then
    insert into public.activity_log (company_id, actor_id, entity, entity_id, action, data)
    values (new.company_id, auth.uid(), 'lead', new.id, 'status_changed',
            jsonb_build_object('from', old.status, 'to', new.status, 'lost_reason', new.lost_reason));
  elsif new.assigned_to is distinct from old.assigned_to then
    insert into public.activity_log (company_id, actor_id, entity, entity_id, action, data)
    values (new.company_id, auth.uid(), 'lead', new.id, 'reassigned',
            jsonb_build_object('from', old.assigned_to, 'to', new.assigned_to));
  end if;
  return new;
end;
$$;

create trigger leads_audit
  after insert or update on public.leads
  for each row execute function private.log_lead_change();

-- ---------------------------------------------------------------------------
-- Storage: private bucket, paths company/<company_id>/...
-- ---------------------------------------------------------------------------

insert into storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
values ('site-photos', 'site-photos', false, 10485760, array['image/jpeg', 'image/png', 'image/webp'])
on conflict (id) do nothing;

create policy site_photos_select on storage.objects
  for select to authenticated
  using (
    bucket_id = 'site-photos'
    and (storage.foldername(name))[1] = 'company'
    and (storage.foldername(name))[2] = (select private.current_company_id())::text
  );

create policy site_photos_insert on storage.objects
  for insert to authenticated
  with check (
    bucket_id = 'site-photos'
    and (storage.foldername(name))[1] = 'company'
    and (storage.foldername(name))[2] = (select private.current_company_id())::text
  );

create policy site_photos_update on storage.objects
  for update to authenticated
  using (
    bucket_id = 'site-photos'
    and (storage.foldername(name))[1] = 'company'
    and (storage.foldername(name))[2] = (select private.current_company_id())::text
  );

-- ---------------------------------------------------------------------------
-- PowerSync logical replication
-- ---------------------------------------------------------------------------

do $$
begin
  if not exists (select 1 from pg_publication where pubname = 'powersync') then
    create publication powersync;
  end if;
end $$;

alter publication powersync add table
  public.companies, public.profiles, public.leads, public.lead_photos;
