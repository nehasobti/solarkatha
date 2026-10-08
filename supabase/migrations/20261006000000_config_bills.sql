-- SolarKatha Phase 3: config tables, bills, AI usage, generation cache.
--
-- Config rows with company_id NULL are platform defaults (seeded, read-only
-- to companies). A company may add its own rows; the app prefers the
-- company's row over the default for the same key / scope.

-- ---------------------------------------------------------------------------
-- Config tables
-- ---------------------------------------------------------------------------

create table public.app_config (
  id uuid primary key default gen_random_uuid(),
  company_id uuid references public.companies (id),
  key text not null,
  value jsonb not null,
  updated_at timestamptz not null default now()
);
create unique index app_config_key_uq
  on public.app_config (coalesce(company_id, '00000000-0000-0000-0000-000000000000'::uuid), key);

create table public.subsidy_rules (
  id uuid primary key default gen_random_uuid(),
  company_id uuid references public.companies (id),
  -- 'central' or a two-letter state code
  scope text not null check (scope = 'central' or scope ~ '^[A-Z]{2}$'),
  segment text not null default 'residential' check (segment in ('residential', 'group_housing')),
  -- [{"upto_kw": 2, "per_kw": 30000}, {"upto_kw": 3, "per_kw": 18000}]
  slabs jsonb not null,
  cap_amount numeric,
  valid_from date not null default current_date,
  valid_to date,
  source_note text,
  updated_at timestamptz not null default now()
);

create table public.tariffs (
  id uuid primary key default gen_random_uuid(),
  company_id uuid references public.companies (id),
  state_code text not null check (state_code ~ '^[A-Z]{2}$'),
  discom text, -- null = applies to every DISCOM in the state
  category text not null default 'domestic',
  -- [{"upto_units": 100, "rate": 5.5}, {"upto_units": null, "rate": 6.5}]
  slabs jsonb not null,
  fixed_charge numeric not null default 0,
  valid_from date not null default current_date,
  source_note text,
  updated_at timestamptz not null default now()
);

create table public.loan_presets (
  id uuid primary key default gen_random_uuid(),
  company_id uuid references public.companies (id),
  bank_name text not null,
  rate_pct numeric not null check (rate_pct >= 0 and rate_pct < 50),
  max_years int not null check (max_years between 1 and 30),
  notes text,
  sort int not null default 0,
  updated_at timestamptz not null default now()
);

-- ---------------------------------------------------------------------------
-- Bills
-- ---------------------------------------------------------------------------

create table public.bills (
  id uuid primary key,
  company_id uuid not null references public.companies (id),
  lead_id uuid not null references public.leads (id),
  photo_id uuid references public.lead_photos (id),
  discom text,
  consumer_number text,
  customer_name text,
  tariff_category text,
  sanctioned_load_kw numeric check (sanctioned_load_kw is null or sanctioned_load_kw >= 0),
  billing_period text,
  -- {"2026-08": 320, "2026-07": 290, ...}
  units_monthly jsonb,
  avg_monthly_units numeric check (avg_monthly_units is null or avg_monthly_units >= 0),
  bill_amount numeric check (bill_amount is null or bill_amount >= 0),
  -- {"discom": "high", "consumer_number": "low", ...}
  ai_confidence jsonb,
  source text not null default 'manual' check (source in ('manual', 'scan')),
  confirmed_by uuid references public.profiles (id),
  confirmed_at timestamptz,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  deleted_at timestamptz
);
create index bills_lead_idx on public.bills (lead_id) where deleted_at is null;
create index bills_consumer_idx on public.bills (company_id, consumer_number) where deleted_at is null;

create trigger bills_set_updated_at
  before update on public.bills
  for each row execute function private.set_updated_at();

-- ---------------------------------------------------------------------------
-- Server-only tables (no client access)
-- ---------------------------------------------------------------------------

create table public.ai_usage (
  id bigint generated always as identity primary key,
  company_id uuid not null references public.companies (id),
  actor_id uuid references public.profiles (id),
  kind text not null,
  ok boolean not null,
  created_at timestamptz not null default now()
);
create index ai_usage_company_day_idx on public.ai_usage (company_id, kind, created_at);

-- PVGIS results per 1 kW, keyed by location rounded to 0.05°, tilt and
-- azimuth.
create table public.generation_cache (
  lat_key numeric not null,
  lng_key numeric not null,
  tilt int not null,
  azimuth int not null,
  monthly_kwh_per_kw jsonb not null,
  source text not null default 'pvgis',
  created_at timestamptz not null default now(),
  primary key (lat_key, lng_key, tilt, azimuth)
);

-- ---------------------------------------------------------------------------
-- RLS
-- ---------------------------------------------------------------------------

alter table public.app_config enable row level security;
alter table public.subsidy_rules enable row level security;
alter table public.tariffs enable row level security;
alter table public.loan_presets enable row level security;
alter table public.bills enable row level security;
alter table public.ai_usage enable row level security;
alter table public.generation_cache enable row level security;

revoke all on public.app_config, public.subsidy_rules, public.tariffs,
  public.loan_presets, public.bills, public.ai_usage, public.generation_cache from anon;
revoke all on public.ai_usage, public.generation_cache from authenticated;

-- Config: everyone signed in reads defaults and their company's rows;
-- owners manage their company's rows.
do $$
declare t text;
begin
  foreach t in array array['app_config', 'subsidy_rules', 'tariffs', 'loan_presets'] loop
    execute format($f$
      create policy %1$s_select on public.%1$s for select to authenticated
        using (company_id is null or company_id = (select private.current_company_id()));
      create policy %1$s_owner_write on public.%1$s for all to authenticated
        using (company_id = (select private.current_company_id()) and (select private.is_owner()))
        with check (company_id = (select private.current_company_id()) and (select private.is_owner()));
    $f$, t);
  end loop;
end $$;

-- Bills follow their lead's visibility; a bill needs the customer's consent.
create policy bills_select on public.bills
  for select to authenticated
  using (exists (
    select 1 from public.leads l
    where l.id = lead_id and l.company_id = bills.company_id
      and private.can_access_lead(l.company_id, l.assigned_to)
  ));

create policy bills_insert on public.bills
  for insert to authenticated
  with check (exists (
    select 1 from public.leads l
    where l.id = lead_id and l.company_id = bills.company_id
      and private.can_access_lead(l.company_id, l.assigned_to)
      and l.consent_at is not null
  ));

create policy bills_update on public.bills
  for update to authenticated
  using (exists (
    select 1 from public.leads l
    where l.id = lead_id and private.can_access_lead(l.company_id, l.assigned_to)
  ));

-- ---------------------------------------------------------------------------
-- PowerSync
-- ---------------------------------------------------------------------------

alter publication powersync add table
  public.app_config, public.subsidy_rules, public.tariffs, public.loan_presets, public.bills;

-- powersync_role (created in the dashboard SQL editor) reads every table.
do $$
begin
  if exists (select 1 from pg_roles where rolname = 'powersync_role') then
    grant select on public.app_config, public.subsidy_rules, public.tariffs,
      public.loan_presets, public.bills to powersync_role;
  end if;
end $$;

-- ---------------------------------------------------------------------------
-- Seed: platform defaults current at build time (owners can override).
-- ---------------------------------------------------------------------------

insert into public.app_config (company_id, key, value) values
  (null, 'sqm_per_kw', '10'),
  (null, 'default_yield_kwh_per_kw_day', '4.2'),
  (null, 'shading_loss_pct', '{"none": 0, "low": 3, "medium": 8, "high": 15}'),
  (null, 'degradation_pct', '0.5'),
  (null, 'tariff_escalation_pct', '3'),
  (null, 'export_rate_per_kwh', '2'),
  (null, 'lifetime_years', '25'),
  (null, 'default_price_per_kw', '60000'),
  (null, 'system_loss_pct', '14'),
  (null, 'bill_scan_daily_limit', '50');

insert into public.subsidy_rules (company_id, scope, segment, slabs, cap_amount, valid_from, source_note) values
  (null, 'central', 'residential',
   '[{"upto_kw": 2, "per_kw": 30000}, {"upto_kw": 3, "per_kw": 18000}]', 78000, '2024-02-13',
   'PM Surya Ghar: Muft Bijli Yojana CFA for residential rooftop solar'),
  (null, 'UP', 'residential',
   '[{"upto_kw": null, "per_kw": 15000}]', 30000, '2024-04-01',
   'Uttar Pradesh state top-up (example; verify current UPNEDA notification)');

insert into public.tariffs (company_id, state_code, discom, category, slabs, fixed_charge, source_note) values
  (null, 'UP', null, 'domestic',
   '[{"upto_units": 100, "rate": 5.5}, {"upto_units": 150, "rate": 5.5}, {"upto_units": 300, "rate": 6.0}, {"upto_units": null, "rate": 6.5}]',
   110, 'UPPCL LMV-1 urban metered, approximate; verify current tariff order');

insert into public.loan_presets (company_id, bank_name, rate_pct, max_years, notes, sort) values
  (null, 'SBI Surya Ghar (up to 3 kW)', 7.0, 10, 'Collateral-free rooftop solar loan; check current rate', 1),
  (null, 'Bank of Baroda Surya Ghar', 7.0, 10, 'Check current rate', 2),
  (null, 'Other bank / NBFC', 10.5, 7, 'Typical personal or green loan', 3);
