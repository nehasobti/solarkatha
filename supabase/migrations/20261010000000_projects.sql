-- SolarKatha Phase 6: projects, subsidy stages, installer access,
-- notifications, public tracking, per-product panel size.

-- ---------------------------------------------------------------------------
-- Types
-- ---------------------------------------------------------------------------

create type public.project_stage as enum (
  'portal_registration', 'discom_feasibility', 'vendor_selected', 'installation',
  'net_meter_applied', 'net_meter_installed', 'inspection',
  'commissioning_certificate', 'subsidy_claimed', 'subsidy_credited'
);
create type public.stage_status as enum ('pending', 'in_progress', 'done', 'blocked');

alter type public.photo_kind add value if not exists 'document';

-- ---------------------------------------------------------------------------
-- Tables
-- ---------------------------------------------------------------------------

create table public.projects (
  id uuid primary key default gen_random_uuid(),
  company_id uuid not null references public.companies (id),
  lead_id uuid not null references public.leads (id),
  proposal_id uuid not null unique references public.proposals (id),
  current_stage public.project_stage not null default 'portal_registration',
  system_kw numeric,
  net_price numeric,
  expected_subsidy numeric,
  signed_at timestamptz,
  net_meter_number text,
  commissioning_date date,
  subsidy_amount_received numeric check (subsidy_amount_received is null or subsidy_amount_received >= 0),
  subsidy_received_at timestamptz,
  completed_at timestamptz,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  deleted_at timestamptz
);
create index projects_company_idx on public.projects (company_id) where deleted_at is null;
create trigger projects_set_updated_at before update on public.projects
  for each row execute function private.set_updated_at();

create table public.project_stages (
  id uuid primary key default gen_random_uuid(),
  company_id uuid not null references public.companies (id),
  project_id uuid not null references public.projects (id),
  lead_id uuid not null references public.leads (id),
  stage public.project_stage not null,
  position int not null check (position between 1 and 10),
  status public.stage_status not null default 'pending',
  due_date date,
  started_at timestamptz,
  done_at timestamptz,
  done_by uuid references public.profiles (id),
  note text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (project_id, stage)
);
create index project_stages_project_idx on public.project_stages (project_id, position);
create trigger project_stages_set_updated_at before update on public.project_stages
  for each row execute function private.set_updated_at();

-- Installers assigned to a project (spec: projects.installer_ids). A row per
-- assignment so access rules and sync can filter on it.
create table public.project_assignees (
  id uuid primary key default gen_random_uuid(),
  company_id uuid not null references public.companies (id),
  project_id uuid not null references public.projects (id),
  lead_id uuid not null references public.leads (id),
  profile_id uuid not null references public.profiles (id),
  created_at timestamptz not null default now(),
  unique (project_id, profile_id)
);
create index project_assignees_profile_idx on public.project_assignees (profile_id);

-- In-app notifications for the team (push via FCM later).
create table public.notifications (
  id uuid primary key default gen_random_uuid(),
  company_id uuid not null references public.companies (id),
  profile_id uuid not null references public.profiles (id),
  kind text not null,
  entity text,
  entity_id uuid,
  data jsonb not null default '{}'::jsonb,
  read_at timestamptz,
  created_at timestamptz not null default now()
);
create index notifications_profile_idx on public.notifications (profile_id, created_at desc);

-- Documents per stage: lead photos linked to a stage.
alter table public.lead_photos add column if not exists project_stage_id uuid references public.project_stages (id);

-- Public tracking: revocable token, rate limiting.
alter table public.proposals add column if not exists share_revoked_at timestamptz;

create table public.track_hits (
  id bigint generated always as identity primary key,
  client_hash text not null,
  created_at timestamptz not null default now()
);
create index track_hits_client_idx on public.track_hits (client_hash, created_at);

-- Per-product panel size (survey fits panels with the chosen panel's size).
alter table public.products add column if not exists length_m numeric check (length_m is null or length_m between 0.5 and 4);
alter table public.products add column if not exists width_m numeric check (width_m is null or width_m between 0.3 and 2);
update public.products set length_m = 2.278, width_m = 1.134 where type = 'panel' and length_m is null and watt_peak between 500 and 560;

-- ---------------------------------------------------------------------------
-- Access
-- ---------------------------------------------------------------------------

create or replace function private.is_assigned_installer(p_lead_id uuid)
returns boolean
language sql
stable
security definer
set search_path = ''
as $$
  select exists (
    select 1 from public.project_assignees pa
    where pa.lead_id = p_lead_id
      and pa.profile_id = (select auth.uid())
      and pa.company_id = private.current_company_id()
  )
$$;
revoke all on function private.is_assigned_installer(uuid) from public;
grant execute on function private.is_assigned_installer(uuid) to authenticated;

/** Owner, the lead's sales rep, or an installer assigned to its project. */
create or replace function private.can_access_lead_id(p_lead_id uuid)
returns boolean
language sql
stable
security definer
set search_path = ''
as $$
  select exists (
    select 1 from public.leads l
    where l.id = p_lead_id
      and l.company_id = private.current_company_id()
      and (private.is_owner() or l.assigned_to = (select auth.uid()))
  ) or private.is_assigned_installer(p_lead_id)
$$;
revoke all on function private.can_access_lead_id(uuid) from public;
grant execute on function private.can_access_lead_id(uuid) to authenticated;

alter table public.projects enable row level security;
alter table public.project_stages enable row level security;
alter table public.project_assignees enable row level security;
alter table public.notifications enable row level security;
alter table public.track_hits enable row level security;
revoke all on public.projects, public.project_stages, public.project_assignees,
  public.notifications, public.track_hits from anon;
revoke all on public.track_hits from authenticated;

create policy projects_select on public.projects for select to authenticated
  using (company_id = (select private.current_company_id()) and private.can_access_lead_id(lead_id));
create policy projects_update on public.projects for update to authenticated
  using (company_id = (select private.current_company_id()) and private.can_access_lead_id(lead_id));

create policy stages_select on public.project_stages for select to authenticated
  using (company_id = (select private.current_company_id()) and private.can_access_lead_id(lead_id));
create policy stages_update on public.project_stages for update to authenticated
  using (company_id = (select private.current_company_id()) and private.can_access_lead_id(lead_id));

create policy assignees_select on public.project_assignees for select to authenticated
  using (company_id = (select private.current_company_id())
    and ((select private.is_owner()) or profile_id = (select auth.uid()) or private.can_access_lead_id(lead_id)));
create policy assignees_owner_write on public.project_assignees for all to authenticated
  using (company_id = (select private.current_company_id()) and (select private.is_owner()))
  with check (company_id = (select private.current_company_id()) and (select private.is_owner()));

create policy notifications_own on public.notifications for select to authenticated
  using (profile_id = (select auth.uid()));
create policy notifications_mark_read on public.notifications for update to authenticated
  using (profile_id = (select auth.uid()));

-- Installers: read the lead, survey, photos and proposals of their projects;
-- add stage documents.
create policy leads_select_installer on public.leads for select to authenticated
  using (private.is_assigned_installer(id));
create policy sites_select_installer on public.sites for select to authenticated
  using (private.is_assigned_installer(lead_id));
create policy lead_photos_select_installer on public.lead_photos for select to authenticated
  using (private.is_assigned_installer(lead_id));
create policy lead_photos_insert_installer on public.lead_photos for insert to authenticated
  with check (created_by = (select auth.uid()) and private.is_assigned_installer(lead_id));
create policy proposals_select_installer on public.proposals for select to authenticated
  using (private.is_assigned_installer(lead_id));

-- ---------------------------------------------------------------------------
-- Project creation when a proposal is signed (app or tracking page)
-- ---------------------------------------------------------------------------

create or replace function private.create_project_for_proposal(p_proposal_id uuid)
returns uuid
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_p public.proposals%rowtype;
  v_project_id uuid;
  v_sla jsonb;
  v_due date;
  v_stage public.project_stage;
  v_pos int := 0;
begin
  select * into v_p from public.proposals where id = p_proposal_id;
  if not found then return null; end if;
  select id into v_project_id from public.projects where proposal_id = p_proposal_id;
  if found then return v_project_id; end if;

  insert into public.projects (company_id, lead_id, proposal_id, system_kw, net_price,
    expected_subsidy, signed_at)
  values (v_p.company_id, v_p.lead_id, v_p.id, v_p.system_kw, v_p.net_price,
    v_p.central_subsidy + v_p.state_subsidy, coalesce(v_p.signed_at, now()))
  returning id into v_project_id;

  select value into v_sla from public.app_config
  where key = 'stage_sla_days' and (company_id = v_p.company_id or company_id is null)
  order by company_id nulls last limit 1;

  v_due := coalesce(v_p.signed_at, now())::date;
  foreach v_stage in array enum_range(null::public.project_stage) loop
    v_pos := v_pos + 1;
    v_due := v_due + coalesce((v_sla ->> v_stage::text)::int, 7);
    insert into public.project_stages (company_id, project_id, lead_id, stage, position,
      status, due_date, started_at)
    values (v_p.company_id, v_project_id, v_p.lead_id, v_stage, v_pos,
      case when v_pos = 1 then 'in_progress' else 'pending' end::public.stage_status,
      v_due, case when v_pos = 1 then now() end);
  end loop;

  update public.payments set project_id = v_project_id where proposal_id = p_proposal_id;
  update public.leads set status = 'won' where id = v_p.lead_id and status <> 'won';

  -- Tell the owners and the lead's rep.
  insert into public.notifications (company_id, profile_id, kind, entity, entity_id, data)
  select v_p.company_id, pr.id, 'project_created', 'project', v_project_id,
         jsonb_build_object('lead_id', v_p.lead_id, 'system_kw', v_p.system_kw)
  from public.profiles pr
  join public.leads l on l.id = v_p.lead_id
  where pr.company_id = v_p.company_id and pr.active
    and (pr.role = 'owner' or pr.id = l.assigned_to);

  return v_project_id;
end;
$$;

create or replace function private.on_proposal_signed()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
begin
  if new.status = 'signed' and (tg_op = 'INSERT' or old.status is distinct from 'signed') then
    perform private.create_project_for_proposal(new.id);
  end if;
  return new;
end;
$$;
create trigger proposals_signed_create_project after insert or update of status on public.proposals
  for each row execute function private.on_proposal_signed();

-- Existing signed proposals get their projects now.
select private.create_project_for_proposal(id) from public.proposals
where status = 'signed' and deleted_at is null
  and not exists (select 1 from public.projects pj where pj.proposal_id = proposals.id);

-- ---------------------------------------------------------------------------
-- Stage rules: status only moves forward unless an owner changes it;
-- marking done advances the project and notifies the team.
-- ---------------------------------------------------------------------------

create or replace function private.stage_guard()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
begin
  if (select auth.uid()) is null then return new; end if; -- server
  if old.status = 'done' and new.status <> 'done' and not private.is_owner() then
    raise exception 'only an owner can reopen a completed stage' using errcode = '42501';
  end if;
  if new.status = 'done' and old.status <> 'done' then
    new.done_at := coalesce(new.done_at, now());
    new.done_by := coalesce(new.done_by, (select auth.uid()));
  end if;
  return new;
end;
$$;
create trigger project_stages_guard before update on public.project_stages
  for each row execute function private.stage_guard();

create or replace function private.on_stage_done()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_next public.project_stages%rowtype;
begin
  if new.status = 'done' and old.status <> 'done' then
    select * into v_next from public.project_stages
    where project_id = new.project_id and position = new.position + 1;
    if found then
      update public.project_stages set status = 'in_progress', started_at = coalesce(started_at, now())
      where id = v_next.id and status = 'pending';
      update public.projects set current_stage = v_next.stage where id = new.project_id;
    else
      update public.projects set completed_at = now() where id = new.project_id;
    end if;

    insert into public.activity_log (company_id, actor_id, entity, entity_id, action, data)
    values (new.company_id, auth.uid(), 'project', new.project_id, 'stage_done',
            jsonb_build_object('stage', new.stage));

    insert into public.notifications (company_id, profile_id, kind, entity, entity_id, data)
    select new.company_id, pr.id, 'stage_done', 'project', new.project_id,
           jsonb_build_object('stage', new.stage, 'lead_id', new.lead_id)
    from public.profiles pr
    join public.leads l on l.id = new.lead_id
    where pr.company_id = new.company_id and pr.active
      and pr.id is distinct from auth.uid()
      and (pr.role = 'owner' or pr.id = l.assigned_to
           or exists (select 1 from public.project_assignees pa
                      where pa.project_id = new.project_id and pa.profile_id = pr.id));
  end if;
  return new;
end;
$$;
create trigger project_stages_done after update of status on public.project_stages
  for each row execute function private.on_stage_done();

-- Subsidy received: audit.
create or replace function private.log_project_change()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
begin
  if new.subsidy_amount_received is distinct from old.subsidy_amount_received then
    insert into public.activity_log (company_id, actor_id, entity, entity_id, action, data)
    values (new.company_id, auth.uid(), 'project', new.id, 'subsidy_received',
            jsonb_build_object('amount', new.subsidy_amount_received));
  end if;
  return new;
end;
$$;
create trigger projects_audit after update on public.projects
  for each row execute function private.log_project_change();

-- ---------------------------------------------------------------------------
-- Config
-- ---------------------------------------------------------------------------

insert into public.app_config (company_id, key, value) values
  (null, 'stage_sla_days', '{"portal_registration": 3, "discom_feasibility": 15, "vendor_selected": 3, "installation": 10, "net_meter_applied": 3, "net_meter_installed": 20, "inspection": 10, "commissioning_certificate": 5, "subsidy_claimed": 5, "subsidy_credited": 30}'),
  (null, 'public_web_url', to_jsonb('https://solarkatha.vercel.app'::text)),
  (null, 'track_rate_limit_per_minute', '30'),
  (null, 'wa_template_stage_en',
   to_jsonb('Namaste {customer_name}, an update on your {system_kw} solar project with {company_name}: "{stage}" is complete. Follow the progress here: {tracking_link}'::text)),
  (null, 'wa_template_stage_hi',
   to_jsonb('नमस्ते {customer_name}, {company_name} के साथ आपके {system_kw} सोलर प्रोजेक्ट की जानकारी: "{stage}" पूरा हो गया है। प्रगति यहाँ देखें: {tracking_link}'::text))
on conflict do nothing;

-- ---------------------------------------------------------------------------
-- PowerSync
-- ---------------------------------------------------------------------------

alter publication powersync add table public.projects, public.project_stages,
  public.project_assignees, public.notifications;
do $$
begin
  if exists (select 1 from pg_roles where rolname = 'powersync_role') then
    grant select on public.projects, public.project_stages, public.project_assignees,
      public.notifications to powersync_role;
  end if;
end $$;
