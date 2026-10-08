-- SolarKatha Phase 1: companies, profiles, team invites, activity log, RLS.
--
-- Tenant rule: every business row carries company_id and RLS limits users to
-- their own company. Helper functions live in the `private` schema, which is
-- not exposed through the Data API.

create schema if not exists private;
grant usage on schema private to authenticated;

-- ---------------------------------------------------------------------------
-- Types
-- ---------------------------------------------------------------------------

create type public.user_role as enum ('owner', 'sales', 'installer');
create type public.app_language as enum ('en', 'hi');

-- ---------------------------------------------------------------------------
-- Tables
-- ---------------------------------------------------------------------------

create table public.companies (
  id uuid primary key default gen_random_uuid(),
  name text not null check (char_length(btrim(name)) between 2 and 120),
  logo_url text,
  gstin text check (gstin is null or gstin ~ '^[0-9]{2}[A-Z0-9]{13}$'),
  address text,
  state_code text not null check (state_code ~ '^[A-Z]{2}$'),
  phone text,
  brand_color text check (brand_color is null or brand_color ~ '^#[0-9A-Fa-f]{6}$'),
  mnre_vendor_id text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  deleted_at timestamptz
);

create table public.profiles (
  id uuid primary key references auth.users (id) on delete cascade,
  company_id uuid not null references public.companies (id),
  name text not null default '',
  phone text,
  email text,
  role public.user_role not null,
  language public.app_language not null default 'en',
  active boolean not null default true,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  deleted_at timestamptz
);

create index profiles_company_id_idx on public.profiles (company_id);

-- An owner invites a team member by phone (digits incl. country code, e.g.
-- 919876543210) or email. The member's first login claims the invite.
create table public.team_invites (
  id uuid primary key default gen_random_uuid(),
  company_id uuid not null references public.companies (id),
  name text,
  phone text check (phone is null or phone ~ '^[0-9]{10,15}$'),
  email text check (email is null or email = lower(email)),
  role public.user_role not null,
  invited_by uuid references public.profiles (id),
  accepted_by uuid references public.profiles (id),
  accepted_at timestamptz,
  revoked_at timestamptz,
  created_at timestamptz not null default now(),
  check (phone is not null or email is not null)
);

create unique index team_invites_pending_phone_uq
  on public.team_invites (company_id, phone)
  where phone is not null and accepted_at is null and revoked_at is null;
create unique index team_invites_pending_email_uq
  on public.team_invites (company_id, email)
  where email is not null and accepted_at is null and revoked_at is null;

create table public.activity_log (
  id uuid primary key default gen_random_uuid(),
  company_id uuid not null references public.companies (id),
  actor_id uuid references public.profiles (id),
  entity text not null,
  entity_id uuid,
  action text not null,
  data jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now()
);

create index activity_log_company_created_idx
  on public.activity_log (company_id, created_at desc);

-- ---------------------------------------------------------------------------
-- Helper functions (private schema)
-- ---------------------------------------------------------------------------

create or replace function private.current_company_id()
returns uuid
language sql
stable
security definer
set search_path = ''
as $$
  select p.company_id
  from public.profiles p
  where p.id = (select auth.uid())
    and p.active
    and p.deleted_at is null
$$;

create or replace function private.current_app_role()
returns public.user_role
language sql
stable
security definer
set search_path = ''
as $$
  select p.role
  from public.profiles p
  where p.id = (select auth.uid())
    and p.active
    and p.deleted_at is null
$$;

create or replace function private.is_owner()
returns boolean
language sql
stable
security definer
set search_path = ''
as $$
  select coalesce(private.current_app_role() = 'owner', false)
$$;

revoke all on function private.current_company_id() from public;
revoke all on function private.current_app_role() from public;
revoke all on function private.is_owner() from public;
grant execute on function private.current_company_id() to authenticated;
grant execute on function private.current_app_role() to authenticated;
grant execute on function private.is_owner() to authenticated;

create or replace function private.set_updated_at()
returns trigger
language plpgsql
set search_path = ''
as $$
begin
  new.updated_at := now();
  return new;
end;
$$;

-- Members may edit their own name/language; only an owner may change another
-- member's role or active flag, and nobody may move a profile between
-- companies. Server-side code (no auth.uid()) is not restricted.
create or replace function private.profiles_guard()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
begin
  if (select auth.uid()) is null then
    return new;
  end if;

  if new.id <> old.id or new.company_id <> old.company_id then
    raise exception 'profile id and company cannot be changed'
      using errcode = '42501';
  end if;

  if new.role is distinct from old.role or new.active is distinct from old.active then
    if not private.is_owner() or new.id = (select auth.uid()) then
      raise exception 'only an owner can change another member''s role or status'
        using errcode = '42501';
    end if;
  end if;

  return new;
end;
$$;

create trigger companies_set_updated_at
  before update on public.companies
  for each row execute function private.set_updated_at();

create trigger profiles_set_updated_at
  before update on public.profiles
  for each row execute function private.set_updated_at();

create trigger profiles_guard
  before update on public.profiles
  for each row execute function private.profiles_guard();

-- ---------------------------------------------------------------------------
-- Row Level Security
-- ---------------------------------------------------------------------------

alter table public.companies enable row level security;
alter table public.profiles enable row level security;
alter table public.team_invites enable row level security;
alter table public.activity_log enable row level security;

-- Anonymous visitors never read tables directly; the public tracking page
-- goes through an Edge Function.
revoke all on public.companies, public.profiles, public.team_invites, public.activity_log from anon;

-- companies
create policy companies_select_own on public.companies
  for select to authenticated
  using (id = (select private.current_company_id()));

create policy companies_update_owner on public.companies
  for update to authenticated
  using (id = (select private.current_company_id()) and (select private.is_owner()))
  with check (id = (select private.current_company_id()) and (select private.is_owner()));

-- profiles
create policy profiles_select_company on public.profiles
  for select to authenticated
  using (
    id = (select auth.uid())
    or company_id = (select private.current_company_id())
  );

create policy profiles_update_self_or_owner on public.profiles
  for update to authenticated
  using (
    id = (select auth.uid())
    or ((select private.is_owner()) and company_id = (select private.current_company_id()))
  )
  with check (
    id = (select auth.uid())
    or ((select private.is_owner()) and company_id = (select private.current_company_id()))
  );

-- team_invites: owners only
create policy team_invites_owner_all on public.team_invites
  for all to authenticated
  using ((select private.is_owner()) and company_id = (select private.current_company_id()))
  with check ((select private.is_owner()) and company_id = (select private.current_company_id()));

-- activity_log: owners read; any member writes their own entries
create policy activity_log_select_owner on public.activity_log
  for select to authenticated
  using ((select private.is_owner()) and company_id = (select private.current_company_id()));

create policy activity_log_insert_member on public.activity_log
  for insert to authenticated
  with check (
    company_id = (select private.current_company_id())
    and actor_id = (select auth.uid())
  );

-- ---------------------------------------------------------------------------
-- RPCs used by the app after login
-- ---------------------------------------------------------------------------

-- Claims a pending invite that matches the signed-in user's phone or email.
-- Returns the profile id, or null when there is no invite.
create or replace function public.claim_invite()
returns uuid
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_uid uuid := auth.uid();
  v_phone text;
  v_email text;
  v_invite public.team_invites%rowtype;
begin
  if v_uid is null then
    raise exception 'not authenticated' using errcode = '28000';
  end if;

  if exists (select 1 from public.profiles where id = v_uid) then
    return v_uid;
  end if;

  select nullif(regexp_replace(coalesce(u.phone, ''), '\D', '', 'g'), ''),
         nullif(lower(u.email), '')
    into v_phone, v_email
  from auth.users u
  where u.id = v_uid;

  select i.* into v_invite
  from public.team_invites i
  where i.accepted_at is null
    and i.revoked_at is null
    and ((v_phone is not null and i.phone = v_phone)
      or (v_email is not null and i.email = v_email))
  order by i.created_at
  limit 1
  for update;

  if not found then
    return null;
  end if;

  insert into public.profiles (id, company_id, name, phone, email, role)
  values (v_uid, v_invite.company_id, coalesce(v_invite.name, ''), v_phone, v_email, v_invite.role);

  update public.team_invites
  set accepted_at = now(), accepted_by = v_uid
  where id = v_invite.id;

  insert into public.activity_log (company_id, actor_id, entity, entity_id, action, data)
  values (v_invite.company_id, v_uid, 'profile', v_uid, 'invite_claimed',
          jsonb_build_object('role', v_invite.role));

  return v_uid;
end;
$$;

-- Creates a company with the signed-in user as its owner. Used when a new
-- installer business signs up and no invite exists for them.
create or replace function public.create_company(
  p_company_name text,
  p_state_code text,
  p_owner_name text,
  p_language public.app_language default 'en'
)
returns uuid
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_uid uuid := auth.uid();
  v_phone text;
  v_email text;
  v_company_id uuid;
begin
  if v_uid is null then
    raise exception 'not authenticated' using errcode = '28000';
  end if;

  if exists (select 1 from public.profiles where id = v_uid) then
    raise exception 'this account already belongs to a company' using errcode = 'P0001';
  end if;

  if char_length(btrim(coalesce(p_owner_name, ''))) < 2 then
    raise exception 'owner name is required' using errcode = '22023';
  end if;

  select nullif(regexp_replace(coalesce(u.phone, ''), '\D', '', 'g'), ''),
         nullif(lower(u.email), '')
    into v_phone, v_email
  from auth.users u
  where u.id = v_uid;

  insert into public.companies (name, state_code)
  values (btrim(p_company_name), upper(btrim(p_state_code)))
  returning id into v_company_id;

  insert into public.profiles (id, company_id, name, phone, email, role, language)
  values (v_uid, v_company_id, btrim(p_owner_name), v_phone, v_email, 'owner', p_language);

  insert into public.activity_log (company_id, actor_id, entity, entity_id, action)
  values (v_company_id, v_uid, 'company', v_company_id, 'created');

  return v_company_id;
end;
$$;

revoke all on function public.claim_invite() from public, anon;
revoke all on function public.create_company(text, text, text, public.app_language) from public, anon;
grant execute on function public.claim_invite() to authenticated;
grant execute on function public.create_company(text, text, text, public.app_language) to authenticated;
