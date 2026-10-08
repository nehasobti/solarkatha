-- SolarKatha Phase 4: products, proposals, payments, documents bucket.

create type public.product_type as enum ('panel', 'inverter', 'structure', 'other');
create type public.proposal_status as enum ('draft', 'sent', 'signed', 'expired');
create type public.payment_kind as enum ('advance', 'balance');
create type public.payment_status as enum ('created', 'paid', 'expired', 'cancelled');

-- ---------------------------------------------------------------------------
-- Products (company catalogue)
-- ---------------------------------------------------------------------------

create table public.products (
  id uuid primary key default gen_random_uuid(),
  company_id uuid not null references public.companies (id),
  type public.product_type not null,
  brand text not null check (char_length(btrim(brand)) between 1 and 80),
  model text not null check (char_length(btrim(model)) between 1 and 120),
  watt_peak numeric check (watt_peak is null or watt_peak > 0),
  is_dcr boolean not null default false,
  almm_listed boolean not null default false,
  -- inverters: on the scheme's approved list
  approved_list boolean not null default false,
  warranty_years int check (warranty_years is null or warranty_years between 0 and 40),
  unit_price numeric not null default 0 check (unit_price >= 0),
  active boolean not null default true,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  deleted_at timestamptz
);
create index products_company_idx on public.products (company_id, type) where deleted_at is null;
create trigger products_set_updated_at before update on public.products
  for each row execute function private.set_updated_at();

-- ---------------------------------------------------------------------------
-- Proposals (versioned per lead)
-- ---------------------------------------------------------------------------

create table public.proposals (
  id uuid primary key,
  company_id uuid not null references public.companies (id),
  lead_id uuid not null references public.leads (id),
  version int not null default 1 check (version > 0),
  language public.app_language not null default 'en',
  system_kw numeric not null check (system_kw > 0 and system_kw <= 100),
  panel_product_id uuid references public.products (id),
  panel_count int check (panel_count is null or panel_count > 0),
  inverter_product_id uuid references public.products (id),
  gross_price numeric not null check (gross_price >= 0),
  central_subsidy numeric not null default 0 check (central_subsidy >= 0),
  state_subsidy numeric not null default 0 check (state_subsidy >= 0),
  net_price numeric not null check (net_price >= 0),
  -- {"amount": .., "rate": .., "years": .., "emi": .., "bank": ".."}
  loan jsonb,
  -- {"monthly": [12 kWh], "annual": ..}
  est_generation jsonb,
  annual_savings numeric,
  payback_years numeric,
  lifetime_savings numeric,
  current_monthly_bill numeric,
  -- {"items": {"panels_dcr": true, ...}, "override_by": uuid|null}
  compliance jsonb,
  status public.proposal_status not null default 'draft',
  pdf_path text,
  pdf_generated_at timestamptz,
  -- Customer signature as a PNG data URL (small; syncs offline).
  signature_png text check (signature_png is null or char_length(signature_png) < 400000),
  signed_at timestamptz,
  sent_at timestamptz,
  share_token text unique,
  created_by uuid references public.profiles (id),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  deleted_at timestamptz
);
create index proposals_lead_idx on public.proposals (lead_id) where deleted_at is null;
create trigger proposals_set_updated_at before update on public.proposals
  for each row execute function private.set_updated_at();

-- Share token is generated on the server (32 random bytes, URL-safe).
create or replace function private.proposal_defaults()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
begin
  if new.share_token is null then
    new.share_token := translate(encode(extensions.gen_random_bytes(32), 'base64'), '+/=', '-_');
  end if;
  return new;
end;
$$;
create trigger proposals_defaults before insert on public.proposals
  for each row execute function private.proposal_defaults();

-- Audit: price changes, status changes (sent / signed).
create or replace function private.log_proposal_change()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
begin
  if tg_op = 'INSERT' then
    insert into public.activity_log (company_id, actor_id, entity, entity_id, action, data)
    values (new.company_id, auth.uid(), 'proposal', new.id, 'created',
            jsonb_build_object('version', new.version, 'net_price', new.net_price, 'system_kw', new.system_kw));
  else
    if new.net_price is distinct from old.net_price or new.gross_price is distinct from old.gross_price then
      insert into public.activity_log (company_id, actor_id, entity, entity_id, action, data)
      values (new.company_id, auth.uid(), 'proposal', new.id, 'price_changed',
              jsonb_build_object('from', old.net_price, 'to', new.net_price));
    end if;
    if new.status is distinct from old.status then
      insert into public.activity_log (company_id, actor_id, entity, entity_id, action, data)
      values (new.company_id, auth.uid(), 'proposal', new.id, 'status_changed',
              jsonb_build_object('from', old.status, 'to', new.status));
    end if;
  end if;
  return new;
end;
$$;
create trigger proposals_audit after insert or update on public.proposals
  for each row execute function private.log_proposal_change();

-- ---------------------------------------------------------------------------
-- Payments (Razorpay payment links). Written only by Edge Functions.
-- ---------------------------------------------------------------------------

create table public.payments (
  id uuid primary key default gen_random_uuid(),
  company_id uuid not null references public.companies (id),
  lead_id uuid not null references public.leads (id),
  proposal_id uuid not null references public.proposals (id),
  project_id uuid, -- set once projects exist (Phase 6)
  kind public.payment_kind not null default 'advance',
  amount numeric not null check (amount > 0),
  razorpay_link_id text unique,
  short_url text,
  status public.payment_status not null default 'created',
  paid_at timestamptz,
  razorpay_payment_id text,
  created_by uuid references public.profiles (id),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);
create index payments_proposal_idx on public.payments (proposal_id);
create trigger payments_set_updated_at before update on public.payments
  for each row execute function private.set_updated_at();

-- ---------------------------------------------------------------------------
-- RLS
-- ---------------------------------------------------------------------------

alter table public.products enable row level security;
alter table public.proposals enable row level security;
alter table public.payments enable row level security;
revoke all on public.products, public.proposals, public.payments from anon;

create policy products_select on public.products for select to authenticated
  using (company_id = (select private.current_company_id()));
create policy products_owner_write on public.products for all to authenticated
  using (company_id = (select private.current_company_id()) and (select private.is_owner()))
  with check (company_id = (select private.current_company_id()) and (select private.is_owner()));

create policy proposals_select on public.proposals for select to authenticated
  using (exists (select 1 from public.leads l where l.id = lead_id
    and l.company_id = proposals.company_id and private.can_access_lead(l.company_id, l.assigned_to)));
create policy proposals_insert on public.proposals for insert to authenticated
  with check (created_by = (select auth.uid()) and exists (select 1 from public.leads l where l.id = lead_id
    and l.company_id = proposals.company_id and private.can_access_lead(l.company_id, l.assigned_to)));
create policy proposals_update on public.proposals for update to authenticated
  using (exists (select 1 from public.leads l where l.id = lead_id
    and private.can_access_lead(l.company_id, l.assigned_to)));

-- Payments: read only for the app; created/updated by functions (service role).
create policy payments_select on public.payments for select to authenticated
  using (exists (select 1 from public.leads l where l.id = lead_id
    and l.company_id = payments.company_id and private.can_access_lead(l.company_id, l.assigned_to)));
revoke insert, update, delete on public.payments from authenticated;

-- ---------------------------------------------------------------------------
-- Documents bucket (proposal PDFs). Private; signed URLs only.
-- ---------------------------------------------------------------------------

insert into storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
values ('documents', 'documents', false, 20971520, array['application/pdf', 'image/png', 'image/jpeg'])
on conflict (id) do nothing;

create policy documents_select on storage.objects for select to authenticated
  using (bucket_id = 'documents'
    and (storage.foldername(name))[1] = 'company'
    and (storage.foldername(name))[2] = (select private.current_company_id())::text);

-- ---------------------------------------------------------------------------
-- Config: advance %, WhatsApp templates (per language)
-- ---------------------------------------------------------------------------

insert into public.app_config (company_id, key, value) values
  (null, 'advance_pct', '20'),
  (null, 'proposal_valid_days', '15'),
  (null, 'wa_template_proposal_en',
   to_jsonb('Namaste {customer_name}, here is your solar proposal from {company_name}: {system_kw} system, you pay {net_price} after subsidy. Proposal PDF: {pdf_link}'::text)),
  (null, 'wa_template_proposal_hi',
   to_jsonb('नमस्ते {customer_name}, {company_name} की ओर से आपका सोलर प्रस्ताव: {system_kw} सिस्टम, सब्सिडी के बाद आपको {net_price} देने होंगे। प्रस्ताव PDF: {pdf_link}'::text)),
  (null, 'wa_template_payment_en',
   to_jsonb('Namaste {customer_name}, please pay the advance of {amount} for your solar system using this UPI link: {payment_link}'::text)),
  (null, 'wa_template_payment_hi',
   to_jsonb('नमस्ते {customer_name}, अपने सोलर सिस्टम का {amount} एडवांस इस UPI लिंक से भरें: {payment_link}'::text))
on conflict do nothing;

-- Demo catalogue for the demo company.
insert into public.products (company_id, type, brand, model, watt_peak, is_dcr, almm_listed, approved_list, warranty_years, unit_price)
select c.id, p.type::public.product_type, p.brand, p.model, p.wp, p.dcr, p.almm, p.appr, p.warranty, p.price
from public.companies c
cross join (values
  ('panel', 'Waaree', 'Bi-55-540 DCR Mono PERC', 540, true, true, false, 25, 16500),
  ('panel', 'Adani', 'Shine 545 Wp DCR', 545, true, true, false, 25, 16800),
  ('panel', 'Generic', '550 Wp Mono (non-DCR, imported cells)', 550, false, false, false, 12, 11000),
  ('inverter', 'Polycab', '3 kW On-grid PSIS-3K', null, false, false, true, 8, 28000),
  ('inverter', 'Growatt', 'MIN 3000TL-XE', null, false, false, true, 10, 30000),
  ('structure', 'Local', 'GI elevated structure (per kW)', null, false, false, false, 10, 6000)
) as p(type, brand, model, wp, dcr, almm, appr, warranty, price)
where c.id = '00000000-0000-4000-8000-000000000001'
  and not exists (select 1 from public.products x where x.company_id = c.id);

-- ---------------------------------------------------------------------------
-- PowerSync
-- ---------------------------------------------------------------------------

alter publication powersync add table public.products, public.proposals, public.payments;
do $$
begin
  if exists (select 1 from pg_roles where rolname = 'powersync_role') then
    grant select on public.products, public.proposals, public.payments to powersync_role;
  end if;
end $$;
