-- Public landing-page assistant: per-IP (hashed) and daily rate limiting.
create table public.assistant_hits (
  id bigint generated always as identity primary key,
  client_hash text not null,
  created_at timestamptz not null default now()
);
create index assistant_hits_client_idx on public.assistant_hits (client_hash, created_at);
create index assistant_hits_created_idx on public.assistant_hits (created_at);
alter table public.assistant_hits enable row level security;
revoke all on public.assistant_hits from anon, authenticated;

-- Keep a week of hits.
do $$
begin
  if exists (select 1 from cron.job where jobname = 'prune-assistant-hits') then
    perform cron.unschedule('prune-assistant-hits');
  end if;
  perform cron.schedule('prune-assistant-hits', '15 3 * * *',
    $q$delete from public.assistant_hits where created_at < now() - interval '7 days'$q$);
end $$;
