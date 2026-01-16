param(
  [Parameter(Mandatory = $false)]
  [string]$PolicyPath = ".\policy.v2.json",

  [Parameter(Mandatory = $false)]
  [string]$PrivateKeyPath = ".\authority\private.authority.es256.json",

  [Parameter(Mandatory = $false)]
  [string]$OutSigPath = ".\policy.v2.json.sig"
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$root = Split-Path -Parent $MyInvocation.MyCommand.Path
$repo = Split-Path -Parent $root

$policyFull = Join-Path $repo $PolicyPath
$privFull   = Join-Path $repo $PrivateKeyPath
$outFull    = Join-Path $repo $OutSigPath

if (-not (Test-Path $policyFull)) { throw "SIGN: Policy missing: $policyFull" }
if (-not (Test-Path $privFull))   { throw "SIGN: Private key missing: $privFull" }

$policyRaw = Get-Content -Raw $policyFull
Deny-IfPastedTranscript -RawText $policyRaw

$privRaw = Get-Content -Raw $privFull
try { $k = $privRaw | ConvertFrom-Json -ErrorAction Stop } catch { throw "SIGN: Invalid private key JSON." }

if ($k.schema -ne "wfsl.authority.priv.v1") { throw "SIGN: Unsupported private key schema." }
if ($k.alg -ne "ES256") { throw "SIGN: Unsupported alg. Expected ES256." }

$x = [Convert]::FromBase64String([string]$k.x)
$y = [Convert]::FromBase64String([string]$k.y)
$d = [Convert]::FromBase64String([string]$k.d)

$params = New-Object System.Security.Cryptography.ECParameters
$params.Curve = [System.Security.Cryptography.ECCurve+NamedCurves]::nistP256
$params.Q = New-Object System.Security.Cryptography.ECPoint
$params.Q.X = $x
$params.Q.Y = $y
$params.D = $d

$ecdsa = [System.Security.Cryptography.ECDsa]::Create($params)

$utf8NoBom = New-Object System.Text.UTF8Encoding($false)
$data = $utf8NoBom.GetBytes($policyRaw)

$sig = $ecdsa.SignData($data, [System.Security.Cryptography.HashAlgorithmName]::SHA256)
$sigB64 = [Convert]::ToBase64String($sig)

[System.IO.File]::WriteAllText($outFull, $sigB64 + "`n", $utf8NoBom)

Write-Host "OK: policy signed"
Write-Host ("signature -> " + (Resolve-Path $outFull))
exit 0
