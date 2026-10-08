import 'package:powersync/powersync.dart';
import 'package:powersync_core/attachments/attachments.dart';

/// On-device SQLite schema, mirrored from Supabase by PowerSync.
/// Every table has an implicit text `id` column. Timestamps are ISO-8601
/// strings in UTC.
const leadsTable = 'leads';
const leadPhotosTable = 'lead_photos';
const billsTable = 'bills';
const actionQueueTable = 'action_queue';

final appSchema = Schema([
  const Table('companies', [
    Column.text('name'),
    Column.text('state_code'),
    Column.text('logo_url'),
    Column.text('gstin'),
    Column.text('address'),
    Column.text('phone'),
    Column.text('brand_color'),
    Column.text('mnre_vendor_id'),
  ]),
  const Table('profiles', [
    Column.text('company_id'),
    Column.text('name'),
    Column.text('phone'),
    Column.text('email'),
    Column.text('role'),
    Column.text('language'),
    Column.integer('active'),
  ]),
  const Table(
    leadsTable,
    [
      Column.text('company_id'),
      Column.text('assigned_to'),
      Column.text('created_by'),
      Column.text('name'),
      Column.text('phone'),
      Column.text('alt_phone'),
      Column.text('address'),
      Column.text('district'),
      Column.text('state_code'),
      Column.text('pincode'),
      Column.real('lat'),
      Column.real('lng'),
      Column.text('source'),
      Column.text('status'),
      Column.text('lost_reason'),
      Column.text('notes'),
      Column.text('next_follow_up_at'),
      Column.text('consent_at'),
      Column.text('created_at'),
      Column.text('updated_at'),
      Column.text('deleted_at'),
    ],
    indexes: [
      Index('assigned', [IndexedColumn('assigned_to')]),
      Index('status', [IndexedColumn('status')]),
    ],
  ),
  const Table(
    leadPhotosTable,
    [
      Column.text('company_id'),
      Column.text('lead_id'),
      Column.text('kind'),
      Column.text('created_by'),
      Column.text('created_at'),
      Column.text('deleted_at'),
    ],
    indexes: [
      Index('lead', [IndexedColumn('lead_id')]),
    ],
  ),
  const Table(
    billsTable,
    [
      Column.text('company_id'),
      Column.text('lead_id'),
      Column.text('photo_id'),
      Column.text('discom'),
      Column.text('consumer_number'),
      Column.text('customer_name'),
      Column.text('tariff_category'),
      Column.real('sanctioned_load_kw'),
      Column.text('billing_period'),
      Column.text('units_monthly'), // JSON object month -> units
      Column.real('avg_monthly_units'),
      Column.real('bill_amount'),
      Column.text('ai_confidence'), // JSON object field -> high/medium/low
      Column.text('source'),
      Column.text('confirmed_by'),
      Column.text('confirmed_at'),
      Column.text('created_at'),
      Column.text('updated_at'),
      Column.text('deleted_at'),
    ],
    indexes: [
      Index('lead', [IndexedColumn('lead_id')]),
      Index('consumer', [IndexedColumn('consumer_number')]),
    ],
  ),
  // Config tables (read-only on the device). company_id NULL = default.
  const Table('app_config', [
    Column.text('company_id'),
    Column.text('key'),
    Column.text('value'), // JSON
  ]),
  const Table('subsidy_rules', [
    Column.text('company_id'),
    Column.text('scope'),
    Column.text('segment'),
    Column.text('slabs'), // JSON
    Column.real('cap_amount'),
    Column.text('valid_from'),
    Column.text('valid_to'),
    Column.text('source_note'),
  ]),
  const Table('tariffs', [
    Column.text('company_id'),
    Column.text('state_code'),
    Column.text('discom'),
    Column.text('category'),
    Column.text('slabs'), // JSON
    Column.real('fixed_charge'),
    Column.text('valid_from'),
  ]),
  const Table('loan_presets', [
    Column.text('company_id'),
    Column.text('bank_name'),
    Column.real('rate_pct'),
    Column.integer('max_years'),
    Column.text('notes'),
    Column.integer('sort'),
  ]),
  // Local-only queue of server calls made while offline (bill scans).
  const Table.localOnly(actionQueueTable, [
    Column.text('kind'),
    Column.text('lead_id'),
    Column.text('photo_id'),
    Column.text('company_id'),
    Column.text('status'), // pending | done | failed
    Column.integer('attempts'),
    Column.text('last_error'),
    Column.text('result'), // JSON
    Column.text('created_at'),
    Column.text('updated_at'),
  ]),
  // Local-only upload/download queue for photo files.
  AttachmentsQueueTable(),
]);
