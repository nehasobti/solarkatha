-- One phone = one member. Registering moves the token to the signed-in
-- member (a shared phone that switches users stops getting the previous
-- member's notifications). RLS alone can't move another member's row.

create or replace function public.register_device_token(p_token text, p_platform text default 'android')
returns void
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_company uuid := private.current_company_id();
begin
  if auth.uid() is null or v_company is null or coalesce(p_token, '') = '' then
    raise exception 'not allowed' using errcode = '42501';
  end if;
  insert into public.device_tokens (token, profile_id, company_id, platform, updated_at)
  values (p_token, auth.uid(), v_company, p_platform, now())
  on conflict (token) do update
    set profile_id = excluded.profile_id, company_id = excluded.company_id,
        platform = excluded.platform, updated_at = now();
end;
$$;

create or replace function public.unregister_device_token(p_token text)
returns void
language sql
security definer
set search_path = ''
as $$
  delete from public.device_tokens where token = p_token and profile_id = auth.uid();
$$;

revoke all on function public.register_device_token(text, text) from public, anon;
revoke all on function public.unregister_device_token(text) from public, anon;
grant execute on function public.register_device_token(text, text) to authenticated;
grant execute on function public.unregister_device_token(text) to authenticated;
