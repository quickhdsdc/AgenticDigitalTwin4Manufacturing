param([switch]$NoBrowser)
$ErrorActionPreference = 'Stop'
Set-Location -LiteralPath (Split-Path -Parent $PSScriptRoot)
if (-not (Get-Command docker -ErrorAction SilentlyContinue)) { throw 'Install and start Docker Desktop first.' }
docker info --format '{{.OSType}}' 2>$null | Out-Null
if ($LASTEXITCODE -ne 0) { throw 'Start Docker Desktop and wait for the Linux engine, then try again.' }
if ((docker info --format '{{.OSType}}') -ne 'linux') { throw 'Select Linux containers in Docker Desktop.' }
docker compose version --short | Out-Null
if ($LASTEXITCODE -ne 0) { throw 'Docker Compose is required.' }
if (-not (Test-Path -LiteralPath '.env')) { Copy-Item -LiteralPath '.env.example' -Destination '.env' }
foreach ($directory in @('projects', 'imports')) { New-Item -ItemType Directory -Force -Path $directory | Out-Null }
$release = Get-Content -LiteralPath 'release.json' -Raw | ConvertFrom-Json
if ([IO.Path]::GetFileName($release.archive) -ne $release.archive -or $release.archive_sha256 -notmatch '^[a-f0-9]{64}$') { throw 'Invalid release manifest.' }
try { $current = & docker image inspect $release.image --format '{{.Id}}' 2>$null } catch { $current = $null }
if (-not $current -or $current -ne $release.image_id) {
    if (-not (Test-Path -LiteralPath $release.archive)) { throw 'Extract the complete deployment ZIP from Releases. The image archive is missing.' }
    Write-Host 'Verifying the application image...'
    if ((Get-FileHash -LiteralPath $release.archive -Algorithm SHA256).Hash.ToLowerInvariant() -ne $release.archive_sha256) { throw 'Image checksum mismatch. Download a fresh release.' }
    docker image load --input $release.archive
    if ($LASTEXITCODE -ne 0) { throw 'Could not load the application image.' }
    if ((docker image inspect $release.image --format '{{.Id}}') -ne $release.image_id) { throw 'Loaded image does not match this release.' }
}
docker compose up -d --no-build --pull never --wait --wait-timeout 180
if ($LASTEXITCODE -ne 0) { throw 'Startup failed. Check Docker status and port availability.' }
$port = $env:REVIEW_HOST_PORT
if (-not $port) {
    $line = Get-Content -LiteralPath '.env' | Where-Object { $_ -match '^REVIEW_HOST_PORT=' } | Select-Object -First 1
    if ($line) { $port = ($line -split '=', 2)[1].Trim().Trim([char]39).Trim([char]34) }
}
if (-not $port) { $port = '8088' }
if ($port -notmatch '^[0-9]+$') { throw 'Invalid REVIEW_HOST_PORT.' }
$url = 'http://127.0.0.1:' + $port
Invoke-RestMethod -Uri ($url + '/api/health/ready') -TimeoutSec 15 | Out-Null
Write-Host ('Review Workbench ready: ' + $url)
if (-not $NoBrowser) { Start-Process $url -WindowStyle Hidden }
