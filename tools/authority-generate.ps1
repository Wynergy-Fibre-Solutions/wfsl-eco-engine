param(
  [Parameter(Mandatory = $false)]
  [string]$OutDir = ".\authority"
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$root = Split-Path -Parent $MyInvocation.MyCommand.Path
$repo = Split-Path -Parent $root

$target = Join-Path $repo $OutDir
if (-not (Test-Path $target)) { New-Item -ItemType Directory -Path $target -Force | Out-Null }

$privPath = Join-Path $target "private.authority.es256.json"
$pubPath  = Join-Path $target "public.authority.es256.json"

# Correct curve reference for PowerShell/.NET
$curve = [System.Security.Cryptography.ECCurve+NamedCurves]::nistP256
$ecdsa = [System.Security.Cryptography.ECDsa]::Create($curve)

$params = $ecdsa.ExportParameters($true)

$pub = [ordered]@{
  schema = "wfsl.authority.pub.v1"
  alg    = "ES256"
  x      = [Convert]::ToBase64String($params.Q.X)
  y      = [Convert]::ToBase64String($params.Q.Y)
}

$priv = [ordered]@{
  schema = "wfsl.authority.priv.v1"
  alg    = "ES256"
  x      = [Convert]::ToBase64String($params.Q.X)
  y      = [Convert]::ToBase64String($params.Q.Y)
  d      = [Convert]::ToBase64String($params.D)
}

$pubJson  = $pub  | ConvertTo-Json -Depth 6 -Compress
$privJson = $priv | ConvertTo-Json -Depth 6 -Compress

$utf8NoBom = New-Object System.Text.UTF8Encoding($false)
[System.IO.File]::WriteAllText($pubPath,  $pubJson + "`n",  $utf8NoBom)
[System.IO.File]::WriteAllText($privPath, $privJson + "`n", $utf8NoBom)

Write-Host "OK: authority keypair generated"
Write-Host ("public  -> " + (Resolve-Path $pubPath))
Write-Host ("private -> " + (Resolve-Path $privPath))
Write-Host "IMPORTANT: Do not commit the private key."
exit 0
