-- Public landing page: savings calculator defaults and a daily news feed.

-- The calculator reads the platform defaults (no company rows) without login.
grant select on public.app_config, public.subsidy_rules, public.tariffs, public.loan_presets to anon;

create policy app_config_public_defaults on public.app_config for select to anon
  using (company_id is null and key in (
    'sqm_per_kw', 'default_yield_kwh_per_kw_day', 'degradation_pct',
    'tariff_escalation_pct', 'export_rate_per_kwh', 'lifetime_years',
    'default_price_per_kw', 'shading_loss_pct', 'system_loss_pct'));
create policy subsidy_rules_public_defaults on public.subsidy_rules for select to anon
  using (company_id is null);
create policy tariffs_public_defaults on public.tariffs for select to anon
  using (company_id is null);
create policy loan_presets_public_defaults on public.loan_presets for select to anon
  using (company_id is null);

-- News headlines (title, source, link only), refreshed daily by `news-refresh`.
create table public.news_items (
  id bigint generated always as identity primary key,
  url text not null unique,
  title text not null,
  source text,
  lang text not null default 'en' check (lang in ('en', 'hi')),
  published_at timestamptz,
  fetched_at timestamptz not null default now()
);
create index news_items_lang_published_idx on public.news_items (lang, published_at desc);
alter table public.news_items enable row level security;
grant select on public.news_items to anon, authenticated;
create policy news_items_public_read on public.news_items for select to anon, authenticated
  using (true);

-- Daily refresh at 06:00 IST (00:30 UTC) through pg_net; URL and secret live
-- in Vault (news_refresh_url, cron_secret). Without them this does nothing.
create or replace function private.refresh_news()
returns void
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_url text;
  v_secret text;
begin
  select decrypted_secret into v_url from vault.decrypted_secrets where name = 'news_refresh_url';
  select decrypted_secret into v_secret from vault.decrypted_secrets where name = 'cron_secret';
  if v_url is null or v_secret is null then
    return;
  end if;
  perform net.http_post(
    url := v_url,
    body := '{}'::jsonb,
    headers := jsonb_build_object('Content-Type', 'application/json', 'x-cron-secret', v_secret),
    timeout_milliseconds := 30000
  );
end;
$$;
revoke all on function private.refresh_news() from public, anon, authenticated;

do $$
begin
  if exists (select 1 from cron.job where jobname = 'refresh-news') then
    perform cron.unschedule('refresh-news');
  end if;
  perform cron.schedule('refresh-news', '30 0 * * *', 'select private.refresh_news()');
end $$;
