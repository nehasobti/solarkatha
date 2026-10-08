-- Run with: supabase test db
begin;
create extension if not exists pgtap with schema extensions;

select plan(10);

insert into auth.users (id, phone, aud, role) values
  ('a0000000-0000-4000-8000-000000000001', '919100000001', 'authenticated', 'authenticated'), -- owner A
  ('a0000000-0000-4000-8000-000000000002', '919100000002', 'authenticated', 'authenticated'), -- sales A1
  ('a0000000-0000-4000-8000-000000000003', '919100000003', 'authenticated', 'authenticated'), -- sales A2
  ('b0000000-0000-4000-8000-000000000001', '919100000011', 'authenticated', 'authenticated'); -- owner B

insert into public.companies (id, name, state_code) values
  ('a1000000-0000-4000-8000-000000000000', 'Company A', 'UP'),
  ('b1000000-0000-4000-8000-000000000000', 'Company B', 'RJ');

insert into public.profiles (id, company_id, name, role) values
  ('a0000000-0000-4000-8000-000000000001', 'a1000000-0000-4000-8000-000000000000', 'Owner A', 'owner'),
  ('a0000000-0000-4000-8000-000000000002', 'a1000000-0000-4000-8000-000000000000', 'Sales A1', 'sales'),
  ('a0000000-0000-4000-8000-000000000003', 'a1000000-0000-4000-8000-000000000000', 'Sales A2', 'sales'),
  ('b0000000-0000-4000-8000-000000000001', 'b1000000-0000-4000-8000-000000000000', 'Owner B', 'owner');

insert into public.leads (id, company_id, assigned_to, created_by, name, phone, consent_at) values
  ('c0000000-0000-4000-8000-000000000001', 'a1000000-0000-4000-8000-000000000000',
   'a0000000-0000-4000-8000-000000000002', 'a0000000-0000-4000-8000-000000000002', 'A1 lead', '9876543210', now()),
  ('c0000000-0000-4000-8000-000000000002', 'a1000000-0000-4000-8000-000000000000',
   'a0000000-0000-4000-8000-000000000003', 'a0000000-0000-4000-8000-000000000003', 'A2 lead', '9876543211', null);

set local role authenticated;

-- Sales A1
select set_config('request.jwt.claims', '{"sub":"a0000000-0000-4000-8000-000000000002","role":"authenticated"}', true);

select results_eq($$ select name from public.leads $$, $$ values ('A1 lead') $$,
  'sales rep sees only their own leads');

select throws_ok(
  $$ insert into public.leads (id, company_id, assigned_to, created_by, name, phone)
     values (gen_random_uuid(), 'a1000000-0000-4000-8000-000000000000',
             'a0000000-0000-4000-8000-000000000003', 'a0000000-0000-4000-8000-000000000002', 'x', '9876543212') $$,
  '42501', null, 'sales rep cannot create a lead for another rep');

select is_empty(
  $$ update public.leads set name = 'hacked' where id = 'c0000000-0000-4000-8000-000000000002' returning 1 $$,
  'sales rep cannot update another rep''s lead');

select lives_ok(
  $$ insert into public.lead_photos (id, company_id, lead_id, kind, created_by)
     values (gen_random_uuid(), 'a1000000-0000-4000-8000-000000000000',
             'c0000000-0000-4000-8000-000000000001', 'roof', 'a0000000-0000-4000-8000-000000000002') $$,
  'photo allowed on own lead with consent');

-- Sales A2: their lead has no consent yet
select set_config('request.jwt.claims', '{"sub":"a0000000-0000-4000-8000-000000000003","role":"authenticated"}', true);

select throws_ok(
  $$ insert into public.lead_photos (id, company_id, lead_id, kind, created_by)
     values (gen_random_uuid(), 'a1000000-0000-4000-8000-000000000000',
             'c0000000-0000-4000-8000-000000000002', 'roof', 'a0000000-0000-4000-8000-000000000003') $$,
  '42501', null, 'photo blocked until the customer consents');

select is_empty($$ select 1 from public.lead_photos $$,
  'sales rep cannot see photos of another rep''s lead');

-- Owner A
select set_config('request.jwt.claims', '{"sub":"a0000000-0000-4000-8000-000000000001","role":"authenticated"}', true);

select results_eq($$ select count(*)::int from public.leads $$, $$ values (2) $$,
  'owner sees every lead in the company');

select lives_ok(
  $$ update public.leads set assigned_to = 'a0000000-0000-4000-8000-000000000003'
     where id = 'c0000000-0000-4000-8000-000000000001' $$,
  'owner can reassign a lead');

-- Owner B
select set_config('request.jwt.claims', '{"sub":"b0000000-0000-4000-8000-000000000001","role":"authenticated"}', true);

select is_empty($$ select 1 from public.leads $$, 'other company sees no leads');
select is_empty($$ select 1 from public.lead_photos $$, 'other company sees no photos');

select * from finish();
rollback;
