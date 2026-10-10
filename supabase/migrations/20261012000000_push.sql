-- SolarKatha: push notifications (FCM).
--
-- Each signed-in phone registers its FCM token in device_tokens. When a row
-- lands in notifications, a trigger calls the `push` Edge Function through
-- pg_net with a shared secret. The function URL and secret live in Vault
-- (push_function_url, push_hook_secret), so this file holds no secrets;
-- without them the trigger does nothing.

create extension if not exists pg_net;

create table public.device_tokens (
  token text primary key,
  profile_id uuid not null references public.profiles (id) on delete cascade,
  company_id uuid not null references public.companies (id),
  platform text not null default 'android',
  updated_at timestamptz not null default now()
);
create index device_tokens_profile_idx on public.device_tokens (profile_id);

alter table public.device_tokens enable row level security;
revoke all on public.device_tokens from anon;

-- A member manages only their own phone's token.
create policy device_tokens_own on public.device_tokens for all to authenticated
  using (profile_id = (select auth.uid()))
  with check (
    profile_id = (select auth.uid())
    and company_id = (select private.current_company_id())
  );

create or replace function private.send_push()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_url text;
  v_secret text;
begin
  select decrypted_secret into v_url from vault.decrypted_secrets where name = 'push_function_url';
  select decrypted_secret into v_secret from vault.decrypted_secrets where name = 'push_hook_secret';
  if v_url is null or v_secret is null then
    return new;
  end if;
  if not exists (select 1 from public.device_tokens where profile_id = new.profile_id) then
    return new;
  end if;
  perform net.http_post(
    url := v_url,
    body := jsonb_build_object('notification_id', new.id),
    headers := jsonb_build_object('Content-Type', 'application/json', 'x-push-secret', v_secret)
  );
  return new;
end;
$$;

create trigger notifications_send_push
  after insert on public.notifications
  for each row execute function private.send_push();
