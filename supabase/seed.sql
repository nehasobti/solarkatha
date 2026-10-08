-- Demo data for local development and the public demo.
-- Test phone numbers (OTP 123456) are configured in supabase/config.toml for
-- local use and in the Supabase dashboard (Auth > Providers > Phone) for hosted
-- projects. Logging in with one of these numbers claims the matching invite.

insert into public.companies (id, name, state_code, address, phone, brand_color)
values (
  '00000000-0000-4000-8000-000000000001',
  'Demo Solar Solutions',
  'UP',
  'Gomti Nagar, Lucknow, Uttar Pradesh 226010',
  '+91 99999 00001',
  '#E07B00'
)
on conflict (id) do nothing;

insert into public.team_invites (company_id, name, phone, email, role)
values
  ('00000000-0000-4000-8000-000000000001', 'Demo Owner', '919999900001', 'owner@demo.solarkatha.test', 'owner'),
  ('00000000-0000-4000-8000-000000000001', 'Ravi Kumar', '919999900002', null, 'sales'),
  ('00000000-0000-4000-8000-000000000001', 'Suresh Yadav', '919999900003', null, 'installer')
on conflict do nothing;
