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

## Phase 4 – Proposals

1. **PDF rendering.** HTML template → headless Chromium (`puppeteer-core` + `@sparticuz/chromium`) on a Vercel function (`pdf-service/`, Mumbai region `bom1`). The Noto fonts are embedded as data URLs and the page blocks all network requests, so Hindi shapes correctly and nothing external loads. All text is HTML-escaped. Images must be PNG/JPEG data URLs and the brand colour must be `#rrggbb`.
2. **PDF service auth.** Requests are signed with HMAC-SHA256 over `"<timestamp>.<body>"` using `PDF_SERVICE_SECRET`. Requests older than 5 minutes are rejected (replay protection).
3. **PDFs are stored privately.** They go in a private `documents` bucket at `company/<id>/proposals/<proposal>/v<n>.pdf`. The WhatsApp link is a signed URL valid for 7 days, so the customer can open it from the chat.
4. **Signature stored inline.** The signature is a PNG data URL in `proposals.signature_png` (spec: `signature_path`). It's small, syncs offline with the row, and the PDF service embeds it directly.
5. **Payments link to proposals.** `payments` references `proposal_id` and `lead_id`; `project_id` is set once projects exist (Phase 6). Only Edge Functions write payments; the app reads them.
6. **Payment links.** These are standard Razorpay Payment Links (UPI, cards, netbanking). Razorpay doesn't support UPI-only links in test mode. The default advance is `app_config.advance_pct` (20%) of the net price, and the rep can change it. The amount can never exceed what is still due.
7. **Webhook.** It's deployed with `--no-verify-jwt` because Razorpay sends no Supabase token. The `X-Razorpay-Signature` HMAC is checked before anything changes. It's idempotent: a paid payment is never changed again.
8. **Compliance checklist** (`solar_core`):
   - Items: panels DCR, ALMM-listed, inverter on the approved list, own connection (rep ticks), consumer number entered, at least 4 site photos (bill photos don't count), roof type (rep ticks until the Phase 5 survey records it), and no duplicate consumer number.
   - It blocks PDF, WhatsApp, signature and payment until everything passes or an owner switches on the override. The override is stored with the owner's id.
9. **Panel count.** The panel count is rounded up and the proposal stores the *installed* kW (for example 6 × 540 Wp = 3.24 kW), so subsidy and price match what's actually fitted.
10. **Status flow.** Sharing marks the proposal `sent` and moves a new/surveyed lead to `proposal_sent`. Signing marks it `signed` and the lead `won`. Sent proposals are read-only; changes need a new version.
11. **WhatsApp templates.** The message templates are in `app_config` per language (`wa_template_proposal_en/hi`, `wa_template_payment_en/hi`), with `{customer_name}`-style placeholders.
12. **Demo catalogue.** It's seeded for the demo company: 2 DCR panels, 1 imported non-DCR panel, 2 inverters and a structure.
13. **Local npm cache.** `npm` installs use `npm_config_cache=D:\npm-cache`, so nothing lands on C:.

## Phase 5 – Roof survey

1. **Map imagery is Esri World Imagery through `flutter_map`, not Google Maps.** It needs no API key or billing account. Attribution is shown on the map. Esri's terms allow development and demo use; a commercial launch needs an ArcGIS account (or switch back to `google_maps_flutter`, which needs only the tile layer changed). Places autocomplete is not used: the map centres on the lead's saved GPS location, and the "My location" button works at the site.
2. **Drawing.** The rep taps the roof corners; undo and clear are available. Area uses a local metre projection (shoelace formula), accurate to centimetres on a rooftop.
3. **Panel auto-fit.** Panels are laid in a grid aligned to the roof's longest edge, keeping `roof_setback_m` (0.6 m) clear of every edge. Both portrait and landscape and several grid offsets are tried, and the best kept. Concave roofs are handled: no panel overlaps a cut-out.
4. **Panel-fitting settings are in `app_config`:** `panel_length_m`, `panel_width_m`, `panel_gap_m`, `roof_setback_m`, `default_panel_wp`. The watt peak comes from the first active DCR panel in the catalogue.
5. **Roof limit.** `sites.max_kw` is the smaller of the kW that physically fits and area ÷ `sqm_per_kw`.
   - **Sizing** pre-fills the roof area as `max_kw × sqm_per_kw`, so its recommendation is capped at the surveyed limit and says "Limited by roof area".
   - **Proposal builder** warns when the chosen size exceeds the roof.
6. **Roof layout image.** The map with the roof and panels is captured (RepaintBoundary → PNG). It's saved as a `lead_photos` row of kind `roof_layout` and uploaded by the same offline photo queue. The PDF function embeds it on the "Roof layout" page. Capture is skipped when no imagery is shown (tests).
7. **One survey per lead** (unique `sites.lead_id` among non-deleted rows). The polygon is stored as GeoJSON (`[lng, lat]`). Saving a survey moves a "new" lead to "surveyed".
8. **Roof type check.** The compliance "roof type recorded" check is now automatic: it passes when the survey has a roof type, instead of a manual tick.
9. **Site photos moved.** The photo checklist (roof, meter, DB box, wiring path) is now on the Survey tab, as the spec places it. Layout images don't count toward the 4-photo compliance rule.

## Phase 6 – Projects, tracking and owner dashboard

1. **A signed proposal starts the project automatically.** A database trigger (`proposals_signed_create_project`) creates the project and its 10 subsidy stages, sets due dates from `stage_sla_days` in `app_config`, marks the lead "won" and notifies the owners and the rep. It fires the same way whether the rep or the customer signs.
2. **Stage rules are in the database.**
   - Marking a stage done starts the next one and moves `projects.current_stage`.
   - Only an owner can reopen a done stage (`stage_guard`).
   - Every stage change and the subsidy-received amount go to `activity_log`.
3. **Installers** see only projects they're assigned to (`project_assignees`, one row per installer; the spec's `installer_ids` array). They get the lead, survey, photos and proposal of those projects (read-only, via RLS and their own sync stream), and can add stage documents. They don't get the lead page in the app.
4. **Stage documents** are `lead_photos` rows of kind `document` with `project_stage_id`. They use the same offline photo queue.
5. **WhatsApp stage updates** use the `wa_template_stage_en/hi` templates in `app_config`, in the proposal's language, with the tracking link. They're sent with one tap from a done stage (wa.me, like Phase 4).
6. **Customer tracking page** (`/t/<share_token>`, no login) is served by the public `track` Edge Function.
   - It returns only what the customer needs: first name, kW, price, subsidy, PDF link, stages and the pay link. No phone numbers or internal notes are returned.
   - Customers can sign there. Requests are rate-limited per IP hash (`track_rate_limit_per_minute`). Turning a link off sets `proposals.share_revoked_at`.
   - The page uses the company's brand colour and has its own Hindi/English switch.
7. **The web app is on Vercel** at `https://solarkatha.vercel.app`; `public_web_url` in `app_config` builds the tracking links. Change it there if a custom domain is added.
8. **Owner dashboard** figures are computed on the device from synced rows, so they work offline:
   - kW sold: projects
   - revenue: paid payments
   - subsidies pending: projects without a received amount
   - active projects, and projects by stage
   On phones, the owner sections (subsidy, team, products, config, branding) are reached from shortcuts on the dashboard.
9. **Team invites stay server-only** (not synced) and need a connection. Members are activated or deactivated by the owner. Per-rep numbers (leads, won, kW) come from synced data.
10. **Config editing** writes company override rows. Defaults stay untouched, and removing an override brings the default back. Subsidy rules and tariffs are edited as JSON slabs (same format as the seeds), validated as a list.
11. **jsonb upload fix.** JSON columns are kept as text in the local SQLite. The connector now sends them as JSON values, so Postgres stores real JSON instead of a quoted string. Migration `20261010000100` repaired older rows. This also fixes the generation chart and loan block in PDFs for proposals saved from the app.
12. **Panel size per product.** Panels have `length_m`/`width_m`. The survey uses the size of the chosen panel, falling back to the `app_config` default. For example, 710 W panels (≈ 2.38 × 1.30 m) fit correctly.
13. **CSV export** (leads, projects) is UTF-8 with BOM so Excel shows Hindi names, shared through the system share sheet or downloaded on web.
14. **Deferred:** FCM push (needs a Firebase project). In-app notifications (bell) cover the same events for now.
