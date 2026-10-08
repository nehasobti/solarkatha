-- Run with: supabase test db
begin;
create extension if not exists pgtap with schema extensions;

select plan(18);

-- ---------------------------------------------------------------------------
-- Fixtures (as the postgres superuser, RLS bypassed)
-- ---------------------------------------------------------------------------

insert into auth.users (id, phone, email, aud, role)
values
  ('a0000000-0000-4000-8000-000000000001', '919000000001', null, 'authenticated', 'authenticated'), -- owner A
  ('a0000000-0000-4000-8000-000000000002', '919000000002', null, 'authenticated', 'authenticated'), -- sales A
  ('b0000000-0000-4000-8000-000000000001', '919000000011', null, 'authenticated', 'authenticated'), -- owner B
  ('c0000000-0000-4000-8000-000000000001', '919000000021', null, 'authenticated', 'authenticated'), -- invited, no profile
  ('d0000000-0000-4000-8000-000000000001', null, 'new@owner.test', 'authenticated', 'authenticated'); -- brand new owner

insert into public.companies (id, name, state_code)
values
  ('a1000000-0000-4000-8000-000000000000', 'Company A', 'UP'),
  ('b1000000-0000-4000-8000-000000000000', 'Company B', 'RJ');

insert into public.profiles (id, company_id, name, role)
values
  ('a0000000-0000-4000-8000-000000000001', 'a1000000-0000-4000-8000-000000000000', 'Owner A', 'owner'),
  ('a0000000-0000-4000-8000-000000000002', 'a1000000-0000-4000-8000-000000000000', 'Sales A', 'sales'),
  ('b0000000-0000-4000-8000-000000000001', 'b1000000-0000-4000-8000-000000000000', 'Owner B', 'owner');

insert into public.team_invites (company_id, name, phone, role)
values ('a1000000-0000-4000-8000-000000000000', 'Installer A', '919000000021', 'installer');

-- ---------------------------------------------------------------------------
-- Owner of company A
-- ---------------------------------------------------------------------------
set local role authenticated;
select set_config('request.jwt.claims', '{"sub":"a0000000-0000-4000-8000-000000000001","role":"authenticated"}', true);

select results_eq(
  $$ select name from public.companies $$,
  $$ values ('Company A') $$,
  'owner A sees only company A'
);

select results_eq(
  $$ select count(*)::int from public.profiles $$,
  $$ values (2) $$,
  'owner A sees only company A profiles'
);

select is_empty(
  $$ select 1 from public.profiles where company_id = 'b1000000-0000-4000-8000-000000000000' $$,
  'owner A cannot read company B profiles'
);

select is_empty(
  $$ update public.companies set name = 'Hacked' where id = 'b1000000-0000-4000-8000-000000000000' returning 1 $$,
  'owner A cannot update company B'
);

select lives_ok(
  $$ update public.profiles set role = 'installer' where id = 'a0000000-0000-4000-8000-000000000002' $$,
  'owner A can change a team member role'
);

select throws_ok(
  $$ update public.profiles set role = 'sales' where id = 'a0000000-0000-4000-8000-000000000001' $$,
  '42501',
  null,
  'owner cannot change their own role'
);

select results_eq(
  $$ select count(*)::int from public.team_invites $$,
  $$ values (1) $$,
  'owner A sees company A invites'
);

select throws_ok(
  $$ insert into public.team_invites (company_id, phone, role)
     values ('b1000000-0000-4000-8000-000000000000', '919000000099', 'sales') $$,
  '42501',
  null,
  'owner A cannot create invites for company B'
);

-- ---------------------------------------------------------------------------
-- Sales member of company A (role was changed to installer above; reset)
-- ---------------------------------------------------------------------------
reset role;
update public.profiles set role = 'sales' where id = 'a0000000-0000-4000-8000-000000000002';
set local role authenticated;
select set_config('request.jwt.claims', '{"sub":"a0000000-0000-4000-8000-000000000002","role":"authenticated"}', true);

select is_empty(
  $$ select 1 from public.team_invites $$,
  'sales cannot read invites'
);

select is_empty(
  $$ update public.companies set name = 'Renamed' returning 1 $$,
  'sales cannot update the company'
);

select lives_ok(
  $$ update public.profiles set language = 'hi' where id = 'a0000000-0000-4000-8000-000000000002' $$,
  'sales can change own language'
);

select throws_ok(
  $$ update public.profiles set role = 'owner' where id = 'a0000000-0000-4000-8000-000000000002' $$,
  '42501',
  null,
  'sales cannot promote themselves'
);

select is_empty(
  $$ select 1 from public.activity_log $$,
  'sales cannot read the activity log'
);

-- ---------------------------------------------------------------------------
-- Owner of company B
-- ---------------------------------------------------------------------------
select set_config('request.jwt.claims', '{"sub":"b0000000-0000-4000-8000-000000000001","role":"authenticated"}', true);

select results_eq(
  $$ select name from public.companies $$,
  $$ values ('Company B') $$,
  'owner B sees only company B'
);

-- ---------------------------------------------------------------------------
-- Invited user claims their invite
-- ---------------------------------------------------------------------------
select set_config('request.jwt.claims', '{"sub":"c0000000-0000-4000-8000-000000000001","role":"authenticated"}', true);

select is(
  public.claim_invite(),
  'c0000000-0000-4000-8000-000000000001'::uuid,
  'invited user claims invite'
);

select results_eq(
  $$ select role::text, company_id from public.profiles where id = 'c0000000-0000-4000-8000-000000000001' $$,
  $$ values ('installer', 'a1000000-0000-4000-8000-000000000000'::uuid) $$,
  'claimed profile has invite role and company'
);

-- ---------------------------------------------------------------------------
-- New user without invite creates a company
-- ---------------------------------------------------------------------------
select set_config('request.jwt.claims', '{"sub":"d0000000-0000-4000-8000-000000000001","role":"authenticated"}', true);

select is(public.claim_invite(), null::uuid, 'no invite returns null');

select isnt(
  public.create_company('New Solar Co', 'mh', 'New Owner', 'hi'),
  null::uuid,
  'new user can create a company'
);

select * from finish();
rollback;
