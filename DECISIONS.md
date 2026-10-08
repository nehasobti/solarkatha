# Decisions

Choices made where the spec was silent or unclear. Newest at the bottom of each phase.

## Phase 1 – Foundation

1. **Package versions.** Flutter 3.47.6 / Dart 3.13.5; flutter_riverpod 3.4, riverpod_annotation 4 / riverpod_generator 4, go_router 18, freezed 4, supabase_flutter 2.18.
2. **Extra packages.**
   - `shared_preferences`: keeps the language, high-contrast and large-text choices on the device, so they work before login. supabase_flutter already depends on it.
   - `flutter_web_plugins` (part of the Flutter SDK): gives path-based web URLs (`/t/<token>`, `/dashboard`) instead of `/#/…`.
3. **Fonts are bundled** (Noto Sans and Noto Sans Devanagari, Regular/Medium/Bold, OFL licence in `app/assets/fonts/OFL.txt`). Hindi then renders the same on cheap phones and on web, with no internet needed. Noto Sans is the primary font and Devanagari is the fallback.
4. **Supabase key name.** The app reads `SUPABASE_PUBLISHABLE_KEY`, because supabase_flutter 2.18 deprecates `anonKey` in favour of `publishableKey`. A legacy anon key also works in that field.
5. **How users join a company.** Owners invite team members by phone or email (`team_invites`). On first login the app calls `claim_invite()`, which creates the profile with the invited role. A login with no invite goes to an onboarding screen and creates a new company through `create_company()`, which makes that user the owner. So anyone can start a company; this fits a multi-tenant demo.
6. **Extra columns and tables.** The spec's table list didn't cover these:
   - `profiles.email`, used for owner email login.
   - `team_invites`, needed for the invite flow above.
   - `companies.created_at / updated_at / deleted_at`, the usual timestamps.
7. **RLS helpers live in a `private` schema** (`current_company_id()`, `current_app_role()`, `is_owner()`). That schema isn't exposed through the Data API. They are `security definer` so policies can read `profiles` without recursion.
8. **Role and active-flag changes** are enforced by a trigger (`profiles_guard`):
   - Only an owner can change another member's role or active flag.
   - Nobody can change their own role or active flag.
   - Nobody can move a profile to another company.
   Server code with no `auth.uid()` (service role, migrations) is not restricted.
9. **The `anon` role has no table privileges.** The public tracking page will read data through the `track` Edge Function (Phase 6).
10. **Placeholder SMS provider.** Local `config.toml` enables Twilio with placeholder values, because Supabase phone auth needs an SMS provider configured even when only test numbers are used. Test numbers `919999900001–3` use OTP `123456`. On a hosted project, set these test numbers in the dashboard. Real SMS is a later step.
11. **Navigation by role.** One responsive shell: a bottom bar on phones, a side rail at 900 px and wider. Each role gets its own destinations and landing page:
    - owner: `/dashboard`
    - sales: `/home`
    - installer: `/projects`
    Opening a route another role owns redirects to your own landing page. Owner-only sections (subsidy, team, products, config, branding) appear only on the wide layout and are placeholders until Phase 6.
12. **`features/home/`** was added for the sales rep home screen. It isn't in the spec's folder list.
13. **Large text** multiplies the system text scale by 1.25. **High contrast** forces a light theme with black-on-white surfaces and thicker outlines.
14. **Generated code is committed**: `*.g.dart`, `*.freezed.dart` and `lib/l10n/gen/`. A fresh clone then builds without code generation. CI regenerates these files and fails if they differ.
15. **Web on Vercel.** CI writes `build/web` into `.vercel/output/static` with an SPA rewrite in `app/vercel/config.json` (Build Output API v3), then runs `vercel deploy --prebuilt --prod`.
16. **Release signing.** Release APKs are signed with the keystore from `android/key.properties` when it exists (CI writes it from secrets). Otherwise they fall back to debug signing, so `flutter build apk --release` still works locally.
17. **Android application ID** is `in.solarkatha.app`, from `flutter create --org in.solarkatha`. Change it before publishing to the Play Store.
18. **Windows build setup.** The Flutter package cache is on E: (`PUB_CACHE=E:\flutter-pub-cache`), the same drive as the project. Kotlin's incremental compiler breaks when plugin sources and the build folder are on different drives.

## Phase 2 – Leads and offline sync

1. **PowerSync on web too.** The spec says the web app talks to Supabase directly. Using PowerSync on both Android and web means one repository and one set of screens instead of two data paths. The owner dashboard still works online; it just reads through the same local cache.
2. **Photos live in their own table, `lead_photos`,** instead of a `sites.photos` array. Rows can be added offline without merge conflicts on an array, and RLS and sync rules can filter photos per lead. The `sites` table comes with the survey (Phase 5).
3. **The photo upload queue is PowerSync's attachment queue** (`powersync_core/attachments`). Photos are saved on the device first, the metadata row syncs, and the file uploads with retry when online. Other devices download the files. Upstream marks this API experimental, so the `experimental_member_use` lint is silenced in `analysis_options.yaml`. On web, photo files are kept in memory, because the web app is used online.
4. **Image compression** uses `image_picker`'s built-in `maxWidth/maxHeight 1600` and `imageQuality 80`. That meets the spec without adding a separate compression package.
5. **Extra columns on `leads`:**
   - `created_by`
   - `next_follow_up_at`, which powers "Today's follow-ups"
   - `consent_at`, for DPDP consent (spec, Security section)
   - `created_at / updated_at / deleted_at`
6. **Photos require consent.** A photo can only be added once the lead has `consent_at`, enforced both in the app and by RLS.
7. **Phone numbers** are stored as 10 digits without `+91`. Call and WhatsApp buttons add `91` themselves.
8. **Lead visibility.** Sales reps see and edit only leads assigned to them, and can only create leads assigned to themselves. Owners see every lead in the company and can reassign. Installers get leads through projects in Phase 6.
9. **Leads are soft-deleted** (`deleted_at`). Sync rules leave out deleted rows, so they disappear from every device. The hard delete after 30 days is Phase 7.
10. **Audit.** Lead create, status change, reassignment and delete are written to `activity_log` by a database trigger.
11. **"Not yet synced" marker.** It comes from PowerSync's local upload queue (`ps_crud`), so it is exact per record.
12. **Session works offline.** After the first sync, the signed-in user's profile and company are read from the device. The app opens with no signal; only the very first login needs the network.
13. **Signing out clears the device:** the local database and the photo files.
14. **Location capture** uses the `geolocator` package, which is listed in the spec's stack.
15. **Lead detail tabs.** Bill, Survey, Proposals and Project show "coming in a later update" until their phases.
16. **Survey code written early.** `features/survey/domain/roof_geometry.dart` (roof area and panel fitting) was written ahead of Phase 5. The `latlong2` package it uses stays for Phase 5.

## Phase 3 – Bill scan and sizing

1. **Renamed to SolarKatha.** The app name, Dart package (`solarkatha`), Android app ID (`in.solarkatha.app`) and web title all changed. Because the app ID changed, the new APK installs as a separate app on a phone; uninstall the old "SuryaPro" app.
2. **Config tables are multi-tenant.** `app_config`, `subsidy_rules`, `tariffs` and `loan_presets` have a nullable `company_id`. A NULL row is a platform default; a company's own row overrides it. Owners edit their company's rows (Phase 6 config screen). The app resolves which row applies (`SizingConfig.fromRows`).
3. **Seeded values (at build time; verify before real use):**
   - Central subsidy: ₹30,000 per kW for the first 2 kW, ₹18,000 for the 3rd kW, capped at ₹78,000.
   - UP state top-up: ₹15,000 per kW, capped at ₹30,000.
   - UP domestic tariff: approximate UPPCL LMV-1 slabs, ₹110 fixed charge.
   - Loan presets: SBI and Bank of Baroda Surya Ghar at 7% for 10 years; other bank 10.5% for 7 years.
   - Default price: ₹60,000 per kW.
   - Export rate: ₹2 per unit.
4. **Missing tariff fallback.** When a state has no tariff, savings use the bill's average rate (bill amount ÷ units), and the screen says so. With no tariff and no bill amount, savings are hidden rather than guessed.
5. **EMI default.** The loan defaults to the net price after subsidy, because under PM Surya Ghar the subsidy is credited against the loan. The rep can change the rate and tenure.
6. **Bill scan queue.** A scan is a local-only `action_queue` row. It runs once the phone is online *and* the bill photo has uploaded; the function reads the photo from Storage. Network and 5xx errors retry, up to 5 attempts. A 4xx error (limit reached, forbidden) fails immediately, and the rep can type the values in instead.
7. **The bill-scan function never saves anything.** It returns the extracted fields. The bill row is written only when the rep taps "Confirm bill". Fields the model marked medium or low confidence get an amber outline and a "Please check" hint.
8. **Bills reference the photo by id** (`bills.photo_id` → `lead_photos`) instead of `image_path`. The storage path is derived from it.
9. **Model choice.** The Gemini model defaults to `gemini-flash-latest` and can be changed with the `GEMINI_MODEL` secret without a redeploy. The prompt tells the model to return null rather than guess. The server validates the response, rejects out-of-range numbers, and normalises DISCOM names to short codes.
10. **Daily scan limit** is read from `app_config.bill_scan_daily_limit` (50 by default) and counted in the server-only `ai_usage` table, from midnight IST.
11. **Generation cache.** `generation-estimate` caches PVGIS results per 1 kW by location rounded to 0.05°, tilt and azimuth, in the server-only `generation_cache` table. The app also remembers the last result per location on the device, so sizing works offline. Without a location, or offline, it uses `default_yield_kwh_per_kw_day` × days in month.
12. **Duplicate consumer number.** If the bill's consumer number is already on another lead, the bill form warns: only one central subsidy per household. This is a warning, not a block; the full compliance checklist is Phase 4.
13. **Deno and the PowerSync role.** Deno was installed to `D:\tools\deno`, with `DENO_DIR` on D:. The migration grants `powersync_role` read access to the new tables.
