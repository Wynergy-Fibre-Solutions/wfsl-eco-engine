param(
  [Parameter(Mandatory = $false)]
  [string]$ProofDir = ".\proof",

  [Parameter(Mandatory = $false)]
  [switch]$RequireEvidence
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$root = Split-Path -Parent $MyInvocation.MyCommand.Path
. (Join-Path $root "lib\guard.ps1")
. (Join-Path $root "lib\authority.ps1")

function Get-Utf8NoBomBytes {
  param([Parameter(Mandatory = $true)][string]$Text)
  $utf8NoBom = New-Object System.Text.UTF8Encoding($false)
  return $utf8NoBom.GetBytes($Text)
}

function Get-Sha256HexFromText {
  param([Parameter(Mandatory = $true)][string]$Text)
  $bytes = Get-Utf8NoBomBytes -Text $Text
  return (Get-Sha256Hex -Bytes $bytes)
}

function Read-Trimmed {
  param([Parameter(Mandatory = $true)][string]$Path)
  if (-not (Test-Path $Path)) { throw "MISSING FILE: $Path" }
  return (Get-Content -Raw $Path).Trim()
}

function Pass([string]$Msg) { Write-Host ("PASS: " + $Msg) }
function Fail([string]$Msg) { throw ("FAIL: " + $Msg) }

$proofPath = Join-Path $root $ProofDir
if (-not (Test-Path $proofPath)) { Fail "Proof directory not found: $proofPath" }

$snapshotJsonPath = Join-Path $proofPath "snapshot.json"
$snapshotHashPath = Join-Path $proofPath "snapshot.sha256"
$policyHashPath   = Join-Path $proofPath "policy.sha256"

# 1) snapshot integrity
$snapshotRaw = Read-Trimmed -Path $snapshotJsonPath
Deny-IfPastedTranscript -RawText $snapshotRaw
$snapshotComputed = Get-Sha256HexFromText -Text $snapshotRaw

$snapshotExpected = Read-Trimmed -Path $snapshotHashPath
if ($snapshotComputed -ne $snapshotExpected) { Fail "snapshot.sha256 mismatch" }
Pass "snapshot integrity verified"

# 2) policy identity from proof
$policyExpected = Read-Trimmed -Path $policyHashPath
Pass "policy identity loaded from proof"

# 3) verify detached signature if present
$policyPath = Join-Path $root "policy.v2.json"
$sigPath = Join-Path $root "policy.v2.json.sig"
$pubPath = Join-Path $root "authority\public.authority.es256.json"

if (Test-Path $sigPath) {
  Verify-DetachedPolicySignature -PolicyPath $policyPath -SignaturePath $sigPath -PublicKeyPath $pubPath
  Pass "policy signature verified"
} else {
  Pass "policy signature not present (optional)"
}

# 4) evidence
$evidenceJsonPath = Join-Path $proofPath "evidence.v3.json"
$evidenceHashPath = Join-Path $proofPath "evidence.v3.sha256"

$evidencePresent = (Test-Path $evidenceJsonPath) -and (Test-Path $evidenceHashPath)
if ($RequireEvidence -and -not $evidencePresent) { Fail "evidence required but not present" }

if ($evidencePresent) {
  $evidenceRaw = Read-Trimmed -Path $evidenceJsonPath
  Deny-IfPastedTranscript -RawText $evidenceRaw

  try { $e = $evidenceRaw | ConvertFrom-Json -ErrorAction Stop } catch { Fail "evidence.v3.json is not valid JSON" }

  if ($e.schema -ne "wfsl.eco.evidence.v3") { Fail "unsupported evidence schema" }
  if ($e.evidenceVersion -ne "3.0.0") { Fail "unsupported evidenceVersion" }
  if ($e.engine.name -ne "wfsl-eco-engine") { Fail "unexpected engine.name" }
  if ($e.engine.behaviourLevel -ne "v3") { Fail "unexpected engine.behaviourLevel" }

  if ($e.inputs.snapshotSha256 -ne $snapshotExpected) { Fail "evidence does not bind to snapshot" }
  if ($e.inputs.policySha256 -ne $policyExpected) { Fail "evidence does not bind to policy identity" }

  $core = [ordered]@{
    schema = $e.schema
    evidenceVersion = $e.evidenceVersion
    engine = [ordered]@{
      name = $e.engine.name
      behaviourLevel = $e.engine.behaviourLevel
    }
    inputs = [ordered]@{
      snapshotSha256 = $e.inputs.snapshotSha256
      policySha256   = $e.inputs.policySha256
    }
  }

  $coreJson = $core | ConvertTo-Json -Depth 6 -Compress
  Deny-IfPastedTranscript -RawText $coreJson
  $coreHash = Get-Sha256HexFromText -Text $coreJson

  $hashFileExpected = Read-Trimmed -Path $evidenceHashPath
  if ($e.evidenceSha256 -ne $coreHash) { Fail "evidenceSha256 mismatch" }
  if ($hashFileExpected -ne $coreHash) { Fail "evidence.v3.sha256 mismatch" }

  Pass "evidence integrity verified"
} else {
  Pass "evidence not present (optional)"
}

Write-Host "OK: verification completed"
exit 0
