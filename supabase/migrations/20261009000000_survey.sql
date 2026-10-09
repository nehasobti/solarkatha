-- SolarKatha Phase 5: roof survey (sites), roof layout image.

alter type public.photo_kind add value if not exists 'roof_layout';

create type public.roof_type as enum ('rcc', 'tin_sheet', 'other');
create type public.shading_level as enum ('none', 'low', 'medium', 'high');

create table public.sites (
  id uuid primary key,
  company_id uuid not null references public.companies (id),
  lead_id uuid not null references public.leads (id),
  roof_type public.roof_type,
  floors int check (floors is null or floors between 0 and 50),
  -- GeoJSON FeatureCollection of roof polygons ([lng, lat] order)
  roof_polygons jsonb,
  usable_area_sqm numeric check (usable_area_sqm is null or usable_area_sqm >= 0),
  orientation_deg int check (orientation_deg is null or orientation_deg between 0 and 359),
  tilt_deg int check (tilt_deg is null or tilt_deg between 0 and 90),
  shading_level public.shading_level not null default 'none',
  fitted_panel_count int check (fitted_panel_count is null or fitted_panel_count >= 0),
  fitted_kw numeric check (fitted_kw is null or fitted_kw >= 0),
  max_kw numeric check (max_kw is null or max_kw >= 0),
  -- lead_photos row (kind roof_layout) holding the layout image
  layout_photo_id uuid references public.lead_photos (id),
  notes text,
  surveyed_by uuid references public.profiles (id),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  deleted_at timestamptz
);

-- One current survey per lead.
create unique index sites_lead_uq on public.sites (lead_id) where deleted_at is null;

create trigger sites_set_updated_at before update on public.sites
  for each row execute function private.set_updated_at();

alter table public.sites enable row level security;
revoke all on public.sites from anon;

create policy sites_select on public.sites for select to authenticated
  using (exists (select 1 from public.leads l where l.id = lead_id
    and l.company_id = sites.company_id and private.can_access_lead(l.company_id, l.assigned_to)));
create policy sites_insert on public.sites for insert to authenticated
  with check (exists (select 1 from public.leads l where l.id = lead_id
    and l.company_id = sites.company_id and private.can_access_lead(l.company_id, l.assigned_to)));
create policy sites_update on public.sites for update to authenticated
  using (exists (select 1 from public.leads l where l.id = lead_id
    and private.can_access_lead(l.company_id, l.assigned_to)));

-- Panel fitting settings (seeded defaults; companies can override).
insert into public.app_config (company_id, key, value) values
  (null, 'panel_length_m', '2.278'),
  (null, 'panel_width_m', '1.134'),
  (null, 'panel_gap_m', '0.05'),
  (null, 'roof_setback_m', '0.6')
on conflict do nothing;

alter publication powersync add table public.sites;
do $$
begin
  if exists (select 1 from pg_roles where rolname = 'powersync_role') then
    grant select on public.sites to powersync_role;
  end if;
end $$;
