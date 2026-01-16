param(
  [Parameter(Mandatory = $false)]
  [string]$OutDir = "C:\Users\Paul Wynn\eco-engine-v1\proof",

  [Parameter(Mandatory = $false)]
  [switch]$AllowRebootVariance,

  [Parameter(Mandatory = $false)]
  [switch]$EmitEvidence
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

. "$PSScriptRoot\lib\guard.ps1"
. "$PSScriptRoot\lib\evidence.ps1"
. "$PSScriptRoot\lib\authority.ps1"

Require-ExplicitInvocation -InvocationName $MyInvocation.InvocationName

# v2: policy binding (deny-by-default)
$policyPath = Join-Path $PSScriptRoot "policy.v2.json"
if (-not (Test-Path $policyPath)) {
  throw "POLICY DENY: policy.v2.json missing. Refusing to run."
}

# Authority connector (detached signature, if present)
$sigPath = Join-Path $PSScriptRoot "policy.v2.json.sig"
$pubPath = Join-Path $PSScriptRoot "authority\public.authority.es256.json"
if (Test-Path $sigPath) {
  Verify-DetachedPolicySignature -PolicyPath $policyPath -SignaturePath $sigPath -PublicKeyPath $pubPath
}

$policyRaw = Get-Content -Raw $policyPath
Deny-IfPastedTranscript -RawText $policyRaw

try {
  $policy = $policyRaw | ConvertFrom-Json -ErrorAction Stop
}
catch {
  throw "POLICY DENY: policy.v2.json is not valid JSON. Refusing to run."
}

if ($policy.schema -ne "wfsl.eco.policy.v2") {
  throw "POLICY DENY: Unsupported policy schema. Refusing to run."
}

if ($policy.denyByDefault -ne $true) {
  throw "POLICY DENY: denyByDefault must be true for v2. Refusing to run."
}

if (-not $policy.allowedActions.'snapshot.v1') {
  throw "POLICY DENY: Action snapshot.v1 is not permitted by policy. Refusing to run."
}

# Deterministic policy identity
$utf8NoBom = New-Object System.Text.UTF8Encoding($false)
$policyBytes = $utf8NoBom.GetBytes($policyRaw)
$policySha256 = Get-Sha256Hex -Bytes $policyBytes

# OutDir enforcement: must be within allowed roots
$outFull = [System.IO.Path]::GetFullPath($OutDir).TrimEnd('\')

$allowedRoots = @()
foreach ($r in $policy.outDirAllowedRoots) {
  if (-not $r) { continue }
  $allowedRoots += [System.IO.Path]::GetFullPath([string]$r).TrimEnd('\')
}

$allowed = $false
foreach ($root in $allowedRoots) {
  if ($outFull.StartsWith($root, [System.StringComparison]::OrdinalIgnoreCase)) {
    $allowed = $true
    break
  }
}

if (-not $allowed) {
  throw ("POLICY DENY: OutDir is not within allowed roots. OutDir=" + $outFull)
}

if (-not (Test-Path $OutDir)) { New-Item -ItemType Directory -Path $OutDir -Force | Out-Null }

# OS snapshot fields selected to minimise volatility.
$os = Get-CimInstance -ClassName Win32_OperatingSystem
$cs = Get-CimInstance -ClassName Win32_ComputerSystem

$snapshot = [ordered]@{
  version = "eco-engine-v2"
  schema  = "wfsl.eco.snapshot.v2"
  policy  = [ordered]@{
    path   = $policyPath
    sha256 = $policySha256
  }
  machine = [ordered]@{
    computerName = $env:COMPUTERNAME
    userName     = $env:USERNAME
    domain       = $env:USERDOMAIN
  }
  os = [ordered]@{
    caption        = $os.Caption
    version        = $os.Version
    buildNumber    = $os.BuildNumber
    osArchitecture = $os.OSArchitecture
    lastBootUpTime = ([DateTime]$os.LastBootUpTime).ToUniversalTime().ToString("o")
  }
  hardware = [ordered]@{
    manufacturer = $cs.Manufacturer
    model        = $cs.Model
    systemType   = $cs.SystemType
  }
}

$json = $snapshot | ConvertTo-Json -Depth 6 -Compress
Deny-IfPastedTranscript -RawText $json

$bytes = $utf8NoBom.GetBytes($json)
$sha256 = Get-Sha256Hex -Bytes $bytes

$proofJsonPath = Join-Path $OutDir "snapshot.json"
$proofHashPath = Join-Path $OutDir "snapshot.sha256"
$proofPolicyHashPath = Join-Path $OutDir "policy.sha256"

if (-not $AllowRebootVariance -and (Test-Path $proofHashPath) -and (Test-Path $proofJsonPath)) {
  $prevHash = (Get-Content -Raw $proofHashPath).Trim()
  if ($prevHash -ne $sha256) {
    throw "DETERMINISM FAIL: Snapshot hash changed. If you rebooted, rerun with -AllowRebootVariance. Previous=$prevHash Current=$sha256"
  }
}

Write-DeterministicFile -Path $proofJsonPath -ContentUtf8 $json
Write-DeterministicFile -Path $proofHashPath -ContentUtf8 ($sha256 + "`n")
Write-DeterministicFile -Path $proofPolicyHashPath -ContentUtf8 ($policySha256 + "`n")

# v3: optional evidence emission (deterministic)
if ($EmitEvidence) {
  Write-EvidenceV3 -OutDir $OutDir -SnapshotSha256 $sha256 -PolicySha256 $policySha256
}

# Human-safe output
Write-Host "Execution completed successfully."
Write-Host "Proof updated."
Write-Host "Policy enforced."
if (Test-Path $sigPath) { Write-Host "Policy signature verified." }
if ($EmitEvidence) { Write-Host "Evidence emitted." }
exit 0
