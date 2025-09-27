\
# scripts\connect.ps1
# Loads variables from .env and opens a sqlcmd session inside the container.

$envPath = Join-Path -Path (Get-Location) -ChildPath ".env"
if (!(Test-Path $envPath)) {
  Write-Error ".env file not found at $envPath"
  exit 1
}

Get-Content $envPath | ForEach-Object {
  if ($_ -match '^\s*#') { return }
  if ($_ -match '^\s*$') { return }
  $kv = $_ -split '=',2
  if ($kv.Count -eq 2) {
    $key = $kv[0].Trim()
    $val = $kv[1].Trim()
    [System.Environment]::SetEnvironmentVariable($key, $val)
  }
}

if (-not $env:SA_PASSWORD) {
  Write-Error "SA_PASSWORD not found in .env"
  exit 1
}

docker exec -it mssql_server /opt/mssql-tools/bin/sqlcmd -S localhost -U SA -P "$($env:SA_PASSWORD)"
