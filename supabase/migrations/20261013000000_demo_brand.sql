-- Demo company uses the new brand orange.

create or replace function private.reset_demo()
returns void
language plpgsql
security definer
set search_path = ''
as $$
declare
  c constant uuid := '00000000-0000-4000-8000-000000000001';
  v_sales uuid;
  v_installer uuid;
  v_owner uuid;
  v_panel uuid;
  v_inverter uuid;
  per_kw constant numeric[] := array[156,152,173,165,157,126,97,104,117,151,151,154];
  l record;
  v_lead uuid;
  v_proposal uuid;
  v_project uuid;
  i int;
begin
  select id into v_owner from public.profiles where company_id = c and role = 'owner' order by created_at limit 1;
  select id into v_sales from public.profiles where company_id = c and role = 'sales' order by created_at limit 1;
  select id into v_installer from public.profiles where company_id = c and role = 'installer' order by created_at limit 1;

  delete from public.activity_log where company_id = c;
  delete from public.notifications where company_id = c;
  delete from public.payments where company_id = c;
  delete from public.project_assignees where company_id = c;
  update public.lead_photos set project_stage_id = null where company_id = c;
  delete from public.project_stages where company_id = c;
  delete from public.projects where company_id = c;
  delete from public.bills where company_id = c;
  delete from public.sites where company_id = c;
  delete from public.lead_photos where company_id = c;
  delete from public.proposals where company_id = c;
  delete from public.leads where company_id = c;
  delete from public.app_config where company_id = c;
  delete from public.loan_presets where company_id = c;
  delete from public.subsidy_rules where company_id = c;
  delete from public.tariffs where company_id = c;

  update public.companies
     set name = 'Demo Solar Solutions', state_code = 'UP',
         address = 'Gomti Nagar, Lucknow, Uttar Pradesh 226010',
         phone = '+91 99999 00001', brand_color = '#EA580C',
         gstin = null, mnre_vendor_id = null
   where id = c;
  update public.profiles set active = true where company_id = c;
  -- The demo sales rep works in Hindi, the others in English.
  update public.profiles set language = case when role = 'sales' then 'hi' else 'en' end::public.app_language
   where company_id = c;

  select id into v_panel from public.products
   where company_id = c and type = 'panel' and active and deleted_at is null
   order by is_dcr desc, almm_listed desc limit 1;
  select id into v_inverter from public.products
   where company_id = c and type = 'inverter' and active and deleted_at is null limit 1;

  for l in
    select * from (values
      -- name, phone, district, pincode, lat, lng, source, status, units, kw, days_ago, lang
      ('Ramesh Gupta',    '9876500011', 'Lucknow',   '226010', 26.8506, 80.9995, 'referral', 'won',           320, 3.0, 40, 'hi'),
      ('Sunita Verma',    '9876500012', 'Lucknow',   '226016', 26.8721, 81.0186, 'walk_in',  'won',           420, 4.0, 30, 'en'),
      ('Anil Srivastava', '9876500013', 'Lucknow',   '226024', 26.8930, 80.9462, 'campaign', 'proposal_sent', 260, 2.0, 12, 'hi'),
      ('Pooja Mishra',    '9876500014', 'Barabanki', '225001', 26.9258, 81.1834, 'call',     'proposal_sent', 350, 3.0,  9, 'en'),
      ('Mohd. Imran',     '9876500015', 'Lucknow',   '226003', 26.8601, 80.9145, 'referral', 'surveyed',      300, 3.0,  6, 'hi'),
      ('Kavita Singh',    '9876500016', 'Lucknow',   '226028', 26.8124, 80.9890, 'walk_in',  'new',           null, null, 2, 'hi'),
      ('Deepak Yadav',    '9876500017', 'Unnao',     '209801', 26.5393, 80.4878, 'call',     'new',           null, null, 1, 'en'),
      ('Rakesh Tiwari',   '9876500018', 'Lucknow',   '226012', 26.7780, 80.9346, 'campaign', 'lost',          180, 1.0, 20, 'en')
    ) as t(name, phone, district, pincode, lat, lng, source, status, units, kw, days_ago, lang)
  loop
    v_lead := gen_random_uuid();
    insert into public.leads (id, company_id, assigned_to, created_by, name, phone, address,
      district, state_code, pincode, lat, lng, source, status, lost_reason, consent_at,
      next_follow_up_at, created_at)
    values (v_lead, c, v_sales, coalesce(v_sales, v_owner), l.name, l.phone,
      l.district || ', Uttar Pradesh', l.district, 'UP', l.pincode, l.lat, l.lng,
      l.source::public.lead_source,
      -- won/proposal_sent are set by the proposal triggers below
      case when l.status in ('won', 'proposal_sent') then 'surveyed' else l.status end::public.lead_status,
      case when l.status = 'lost' then 'Chose a cheaper non-DCR quote' end,
      now() - make_interval(days => l.days_ago),
      case when l.status in ('new', 'surveyed', 'proposal_sent') then now() + make_interval(days => 1 + l.days_ago % 3) end,
      now() - make_interval(days => l.days_ago));

    if l.units is not null then
      insert into public.bills (id, company_id, lead_id, discom, consumer_number, customer_name,
        tariff_category, sanctioned_load_kw, billing_period, units_monthly, avg_monthly_units,
        bill_amount, source, confirmed_by, confirmed_at)
      values (gen_random_uuid(), c, v_lead, 'MVVNL', '4' || right(l.phone, 9), l.name, 'domestic',
        greatest(l.kw, 2), to_char(now() - interval '1 month', 'Mon YYYY'),
        to_jsonb(array[l.units, l.units, l.units]), l.units, round(l.units * 6.8 + 110),
        'manual', coalesce(v_sales, v_owner), now() - make_interval(days => l.days_ago));
    end if;

    if l.status in ('won', 'proposal_sent', 'lost') then
      v_proposal := gen_random_uuid();
      insert into public.proposals (id, company_id, lead_id, language, system_kw,
        panel_product_id, panel_count, inverter_product_id, gross_price, central_subsidy,
        state_subsidy, net_price, est_generation, annual_savings, payback_years,
        lifetime_savings, current_monthly_bill, status, sent_at, created_by, created_at)
      values (v_proposal, c, v_lead, l.lang::public.app_language, l.kw,
        v_panel, ceil(l.kw * 1000 / 540), v_inverter,
        l.kw * 60000,
        (least(l.kw, 2) * 30000 + greatest(least(l.kw, 3) - 2, 0) * 18000),
        least(l.kw * 15000, 30000),
        l.kw * 60000 - (least(l.kw, 2) * 30000 + greatest(least(l.kw, 3) - 2, 0) * 18000) - least(l.kw * 15000, 30000),
        jsonb_build_object(
          'monthly', (select jsonb_agg(round(m * l.kw)) from unnest(per_kw) m),
          'annual', round((select sum(m) from unnest(per_kw) m) * l.kw)),
        round(l.units * 12 * 6.8 * 0.9), 4.2, round(l.units * 12 * 6.8 * 0.9 * 25 * 1.3),
        round(l.units * 6.8 + 110),
        'sent'::public.proposal_status,
        now() - make_interval(days => greatest(l.days_ago - 2, 0)),
        coalesce(v_sales, v_owner), now() - make_interval(days => greatest(l.days_ago - 2, 0)));

      if l.status = 'won' then
        -- Signing creates the project, its stages and the notifications.
        update public.proposals
           set status = 'signed', signed_at = now() - make_interval(days => l.days_ago - 4)
         where id = v_proposal;
        select id into v_project from public.projects where proposal_id = v_proposal;

        insert into public.payments (company_id, lead_id, proposal_id, project_id, kind,
          amount, short_url, status, paid_at, created_by)
        values (c, v_lead, v_proposal, v_project, 'advance',
          round((l.kw * 60000 - (least(l.kw, 2) * 30000 + greatest(least(l.kw, 3) - 2, 0) * 18000) - least(l.kw * 15000, 30000)) * 0.2),
          null, 'paid', now() - make_interval(days => l.days_ago - 5), coalesce(v_sales, v_owner));

        if v_installer is not null then
          insert into public.project_assignees (company_id, project_id, lead_id, profile_id)
          values (c, v_project, v_lead, v_installer);
        end if;

        -- First project is further along than the second.
        for i in 1 .. case when l.name = 'Ramesh Gupta' then 5 else 2 end loop
          update public.project_stages
             set status = 'done', done_at = now() - make_interval(days => greatest(l.days_ago - 6 - i * 4, 0))
           where project_id = v_project and position = i;
        end loop;
      elsif l.status = 'proposal_sent' then
        update public.leads set status = 'proposal_sent' where id = v_lead;
      elsif l.status = 'lost' then
        update public.leads set status = 'lost' where id = v_lead;
      end if;
    end if;
  end loop;

end;
$$;

revoke all on function private.reset_demo() from public, anon, authenticated;

update public.companies set brand_color = '#EA580C'
 where id = '00000000-0000-4000-8000-000000000001';
