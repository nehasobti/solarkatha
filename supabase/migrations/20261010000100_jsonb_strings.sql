-- Rows written by the app before the upload fix stored JSON text as a jsonb
-- string ("[...]"). Turn those back into real JSON. Genuine string values
-- (e.g. WhatsApp templates in app_config) don't start with [ or { and stay.
do $$
declare
  t record;
begin
  for t in
    select * from (values
      ('subsidy_rules', 'slabs'), ('tariffs', 'slabs'),
      ('bills', 'units_monthly'), ('bills', 'ai_confidence'),
      ('proposals', 'loan'), ('proposals', 'est_generation'),
      ('proposals', 'compliance'), ('sites', 'roof_polygons'),
      ('app_config', 'value')
    ) as v(tbl, col)
  loop
    execute format(
      'update public.%I set %I = (%I #>> ''{}'')::jsonb
       where jsonb_typeof(%I) = ''string'' and left(%I #>> ''{}'', 1) in (''['', ''{'')',
      t.tbl, t.col, t.col, t.col, t.col);
  end loop;
end $$;
