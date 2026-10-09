# SolarKatha

**For Indian rooftop solar installers: scan the bill, size the system, work out the PM Surya Ghar subsidy and EMI, send a Hindi or English proposal on WhatsApp, and track every customer until the subsidy is credited.**

> Status: **Phase 6 of 7 built.** Done so far: login and roles in Hindi and English; leads with offline sync and photos; AI bill scan; sizing with subsidy, EMI and payback; proposals with PDF, WhatsApp, signature and UPI payment; roof survey on satellite imagery with automatic panel layout; projects with the 10 subsidy stages, a public customer tracking page, notifications, and the owner dashboard with team, config and branding. Web: https://solarkatha.vercel.app

## Repository layout

```
app/                 Flutter app (Android + web)
packages/solar_core/ pure Dart solar maths (sizing, subsidy, tariff, EMI, payback)
supabase/functions/  Edge Functions: bill-scan (Gemini), generation-estimate (PVGIS)
powersync/           sync streams (paste into the PowerSync dashboard)
pdf-service/         Vercel function: proposal HTML → PDF (Chromium, Noto fonts)
supabase/            migrations, RLS policies, seed, pgTAP tests, local config
.github/workflows/   ci.yml, deploy-web.yml, release-apk.yml
DECISIONS.md         choices made where the spec was open
```

Later phases add `packages/solar_core/`, `supabase/functions/`, `pdf-service/` and `powersync/`.

## Tech stack

Flutter (Material 3) · Riverpod 3 + riverpod_generator · go_router · freezed / json_serializable · Supabase (Postgres, Auth, Storage, Edge Functions) in Mumbai · PowerSync (Phase 2) · Gemini via an Edge Function (Phase 3) · Vercel · GitHub Actions.

## Local setup (Windows PowerShell)

Prerequisites: Flutter stable (3.47+) on `PATH`, Chrome, and for Android builds Android Studio with the Android SDK. For the local database you also need Docker Desktop and the Supabase CLI.

```powershell
cd app
flutter pub get
flutter gen-l10n
dart run build_runner build
```

### Option A – use a hosted Supabase project

1. Create a Supabase project in the **Mumbai (ap-south-1)** region.
2. Apply the schema and seed:

   ```powershell
   npx supabase login
   npx supabase link --project-ref YOUR-PROJECT-REF
   npx supabase db push --include-seed
   ```

   Or paste `supabase/migrations/*.sql`, then `supabase/seed.sql`, into the SQL editor.
3. In the dashboard, go to **Authentication > Sign In / Providers**:
   - Enable **Phone**. Pick any SMS provider; placeholder values are fine for test numbers. Add the test numbers `919999900001`, `919999900002` and `919999900003`, each with OTP `123456`.
   - Enable **Email OTP**. In **Email Templates > Magic Link**, include `{{ .Token }}` so owners receive a 6-digit code. See `supabase/templates/magic_link.html`.
4. Copy `app/env/dev.example.json` to `app/env/dev.json`, then fill in the project URL and the publishable key.

### Offline sync (PowerSync Cloud)

Without `POWERSYNC_URL` the app still works, but data stays on that one device. To sync:

1. Create a free instance at [powersync.com](https://www.powersync.com) in a region close to Mumbai.
2. **Connect the database:** use Supabase **Project Settings → Database → Connection string** (direct connection, port 5432). The `powersync` publication already exists; the migrations created it.
3. **Client auth:** enable **Use Supabase Auth**, and paste the JWT secret / JWKS URL from Supabase **Project Settings → API**.
4. **Sync rules:** paste `powersync/sync-rules.yaml` and deploy.
5. Copy the instance URL into `app/env/dev.json` as `POWERSYNC_URL`.

### Server functions (bill scan and generation estimate)

1. Get a Gemini API key at **aistudio.google.com → Get API key**.
2. In Supabase, go to **Edge Functions → Secrets → Add new secret**. Add `GEMINI_API_KEY` with that key. You can also add `GEMINI_MODEL` to choose a different model.
3. Deploy both functions:

   ```powershell
   npx supabase login
   npx supabase functions deploy bill-scan generation-estimate --project-ref ffygaowdbkunrkdxksig
   ```

### Option B – local Supabase (Docker)

```powershell
npx supabase start          # prints the local API URL and publishable key
npx supabase test db        # runs the RLS tests
```

Copy `app/env/local.example.json` to `app/env/local.json` and paste in the key.

### Run

```powershell
cd app
flutter run -d chrome --web-port 3000 --dart-define-from-file=env/dev.json
flutter run -d <android-device-id> --dart-define-from-file=env/dev.json
```

### Demo logins (seeded company "Demo Solar Solutions", Lucknow)

| Role | Mobile | OTP |
| --- | --- | --- |
| Owner | 99999 00001 | 123456 |
| Sales rep | 99999 00002 | 123456 |
| Installer | 99999 00003 | 123456 |

The first login with each number claims the matching team invite. Any other number goes to the "Set up your company" screen.

## Checks

```powershell
cd packages/solar_core; dart run coverage:test_with_coverage; cd ../..
cd supabase/functions; deno test tests/; cd ../..
cd app
dart format --set-exit-if-changed lib test
flutter analyze
flutter test
```

## Deployment

| Part | Where | How |
| --- | --- | --- |
| Database, auth | Supabase (Mumbai) | `npx supabase db push` |
| Web app | Vercel | `deploy-web.yml` on push to `main`: `flutter build web`, then `vercel deploy --prebuilt --prod` with an SPA rewrite |
| Android APK | GitHub Releases | `release-apk.yml` on a `v*` tag builds a signed APK |

GitHub secrets:

- **Web deploy:** `APP_ENV_JSON` (the contents of your `env/*.json`), `VERCEL_TOKEN`, `VERCEL_ORG_ID`, `VERCEL_PROJECT_ID`.
- **APK release:** `ANDROID_KEYSTORE_BASE64`, `ANDROID_KEYSTORE_PASSWORD`, `ANDROID_KEY_ALIAS`, `ANDROID_KEY_PASSWORD`.

To create the release keystore once:

```powershell
keytool -genkey -v -keystore solarkatha-release.jks -keyalg RSA -keysize 2048 -validity 10000 -alias solarkatha
[Convert]::ToBase64String([IO.File]::ReadAllBytes("solarkatha-release.jks")) | Set-Clipboard
```
