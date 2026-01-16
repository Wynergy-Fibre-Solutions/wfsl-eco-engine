# WFSL Verify (eco-engine-v1)
# Deterministic proof verification with strict input guards.
# No network access. No telemetry.

[CmdletBinding()]
param(
  [Parameter(Mandatory = $false)]
  [string]$ProofDir = ".\proof",

  [Parameter(Mandatory = $false)]
  [switch]$RequireEvidence
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

function Fail([string]$Message, [int]$Code = 1) {
  Write-Host "FAIL: $Message"
  exit $Code
}

function Pass([string]$Message) {
  Write-Host "PASS: $Message"
}

function Ok([string]$Message) {
  Write-Host "OK: $Message"
}

function Assert-NotEmptyPath([string]$PathValue, [string]$Name) {
  if ([string]::IsNullOrWhiteSpace($PathValue)) {
    Fail "$Name path is empty"
  }
}

function Assert-Exists([string]$PathValue, [string]$Name) {
  Assert-NotEmptyPath $PathValue $Name
  if (-not (Test-Path -LiteralPath $PathValue)) {
    Fail "$Name not found: $PathValue"
  }
}

function Read-FirstToken([string]$PathValue) {
  $raw = Get-Content -LiteralPath $PathValue -Raw
  if ([string]::IsNullOrWhiteSpace($raw)) { return "" }
  # normalise newlines and split on any whitespace
  $tok = ($raw -replace "`r`n", "`n").Split([char[]](" `t`n"), [System.StringSplitOptions]::RemoveEmptyEntries) | Select-Object -First 1
  if ($null -eq $tok) { return "" }
  return $tok.Trim().ToLowerInvariant()
}

function Get-Sha256Hex([string]$PathValue) {
  Assert-Exists $PathValue "file"
  (Get-FileHash -LiteralPath $PathValue -Algorithm SHA256).Hash.ToLowerInvariant()
}

function Verify-HashFile([string]$FilePath, [string]$HashPath, [string]$Label) {
  Assert-Exists $FilePath $Label
  Assert-Exists $HashPath "$Label sha file"

  $expected = Read-FirstToken $HashPath
  if ([string]::IsNullOrWhiteSpace($expected)) {
    Fail "$Label sha file is empty: $HashPath"
  }

  $actual = Get-Sha256Hex $FilePath
  if ($actual -ne $expected) {
    Fail "$Label sha mismatch. expected=$expected actual=$actual"
  }

  Pass "$Label integrity verified"
}

# --- Proof contract (fixed paths only) ---
Assert-NotEmptyPath $ProofDir "ProofDir"
$proofRoot = (Resolve-Path -LiteralPath $ProofDir).Path

$policyPath      = Join-Path $proofRoot "policy.v2.json"
$policyShaPath   = Join-Path $proofRoot "policy.sha256"

$evidencePath    = Join-Path $proofRoot "evidence.json"
$evidenceShaPath = Join-Path $proofRoot "evidence.sha256"
$evidenceSelfSha = Join-Path $proofRoot "evidence.self.sha256"

$snapshotPath    = Join-Path $proofRoot "snapshot.json"
$snapshotShaPath = Join-Path $proofRoot "snapshot.sha256"

# --- Snapshot ---
Verify-HashFile -FilePath $snapshotPath -HashPath $snapshotShaPath -Label "snapshot"

# --- Policy ---
Verify-HashFile -FilePath $policyPath -HashPath $policyShaPath -Label "policy"
Pass "policy identity loaded from proof"

# --- Evidence (optional but enforceable) ---
if ($RequireEvidence) {
  Assert-Exists $evidencePath "evidence"
  Assert-Exists $evidenceShaPath "evidence sha file"
  Assert-Exists $evidenceSelfSha "evidence self sha file"

  Verify-HashFile -FilePath $evidencePath -HashPath $evidenceShaPath -Label "evidence"

  # Evidence self-sha check: evidence.self.sha256 is SHA256 of evidence.sha256 content token (not the file bytes)
  $declared = Read-FirstToken $evidenceSelfSha
  if ([string]::IsNullOrWhiteSpace($declared)) {
    Fail "evidence self sha file is empty: $evidenceSelfSha"
  }

  $evidenceShaToken = Read-FirstToken $evidenceShaPath
  if ([string]::IsNullOrWhiteSpace($evidenceShaToken)) {
    Fail "evidence sha file is empty: $evidenceShaPath"
  }

  $bytes = [System.Text.Encoding]::UTF8.GetBytes($evidenceShaToken)
  $hashBytes = [System.Security.Cryptography.SHA256]::Create().ComputeHash($bytes)
  $computed = -join ($hashBytes | ForEach-Object { $_.ToString("x2") })

  if ($computed -ne $declared) {
    Fail "evidence self sha mismatch. expected=$declared actual=$computed"
  }

  Pass "evidence self sha verified"
  Pass "evidence integrity verified"
}

Ok "verification completed"
exit 0
