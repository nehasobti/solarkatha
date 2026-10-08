# Pushes supabase/migrations and seed.sql to the hosted Supabase project.
# Prompts for the database password; it is never written to disk.
param(
  [string]$ProjectRef = 'ffygaowdbkunrkdxksig',
  [string]$PoolerHost = 'aws-0-ap-south-1.pooler.supabase.com'
)

$ErrorActionPreference = 'Stop'
Set-Location (Split-Path $PSScriptRoot -Parent)

$secure = Read-Host 'Supabase database password' -AsSecureString
$bstr = [Runtime.InteropServices.Marshal]::SecureStringToBSTR($secure)
try {
  $plain = [Runtime.InteropServices.Marshal]::PtrToStringBSTR($bstr)
} finally {
  [Runtime.InteropServices.Marshal]::ZeroFreeBSTR($bstr)
}
$encoded = [Uri]::EscapeDataString($plain)
$dbUrl = "postgresql://postgres.${ProjectRef}:${encoded}@${PoolerHost}:5432/postgres"

npx --yes supabase@latest db push --include-seed --db-url $dbUrl
if ($LASTEXITCODE -eq 0) {
  Write-Host "`nSchema and seed pushed." -ForegroundColor Green
} else {
  Write-Host "`nPush failed (exit $LASTEXITCODE)." -ForegroundColor Red
}
