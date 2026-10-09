-- Watt peak used for roof panel fitting when the catalogue has no panels yet.
insert into public.app_config (company_id, key, value)
values (null, 'default_panel_wp', '540')
on conflict do nothing;
