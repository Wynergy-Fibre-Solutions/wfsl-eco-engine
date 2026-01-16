Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$root = Split-Path -Parent $PSScriptRoot
$runner = Join-Path $root "run.ps1"
$proofDir = Join-Path $root "proof"
$policyPath = Join-Path $root "policy.v2.json"
$policyBackup = Join-Path $root "policy.v2.json.bak"

function Assert-Fails {
  param(
    [Parameter(Mandatory = $true)][string]$Name,
    [Parameter(Mandatory = $true)][scriptblock]$Action
  )

  try {
    & $Action
    throw "EXPECTED FAIL BUT SUCCEEDED: $Name"
  }
  catch {
    Write-Host "PASS (expected fail): $Name -> $($_.Exception.Message)"
  }
}

function Assert-Succeeds {
  param(
    [Parameter(Mandatory = $true)][string]$Name,
    [Parameter(Mandatory = $true)][scriptblock]$Action
  )

  try {
    & $Action
    Write-Host "PASS: $Name"
  }
  catch {
    throw "EXPECTED SUCCESS BUT FAILED: $Name -> $($_.Exception.Message)"
  }
}

function Assert-Exists {
  param(
    [Parameter(Mandatory = $true)][string]$Name,
    [Parameter(Mandatory = $true)][string]$Path
  )
  if (-not (Test-Path $Path)) {
    throw "EXPECTED FILE MISSING: $Name -> $Path"
  }
  Write-Host "PASS: $Name exists"
}

function Assert-NotExists {
  param(
    [Parameter(Mandatory = $true)][string]$Name,
    [Parameter(Mandatory = $true)][string]$Path
  )
  if (Test-Path $Path) {
    throw "EXPECTED FILE TO BE ABSENT: $Name -> $Path"
  }
  Write-Host "PASS: $Name absent"
}

# Clean proof
if (Test-Path $proofDir) { Remove-Item -Recurse -Force $proofDir }
New-Item -ItemType Directory -Path $proofDir -Force | Out-Null

$evidencePath = Join-Path $proofDir "evidence.v3.json"
$evidenceHashPath = Join-Path $proofDir "evidence.v3.sha256"

# 1) Normal run should succeed (no evidence)
Assert-Succeeds -Name "v2 normal run (policy-bound)" -Action { & $runner -OutDir $proofDir }
Assert-NotExists -Name "evidence (default off)" -Path $evidencePath
Assert-NotExists -Name "evidence hash (default off)" -Path $evidenceHashPath

# 2) Repeat run should succeed and remain deterministic (no evidence)
Assert-Succeeds -Name "v2 rerun deterministic" -Action { & $runner -OutDir $proofDir }
Assert-NotExists -Name "evidence still off" -Path $evidencePath

# 3) Evidence enabled run should succeed and emit files
Assert-Succeeds -Name "v3 evidence emission enabled" -Action { & $runner -OutDir $proofDir -EmitEvidence }
Assert-Exists -Name "evidence.v3.json" -Path $evidencePath
Assert-Exists -Name "evidence.v3.sha256" -Path $evidenceHashPath

# 4) Evidence enabled rerun should be deterministic (files still present)
Assert-Succeeds -Name "v3 evidence rerun deterministic" -Action { & $runner -OutDir $proofDir -EmitEvidence }
Assert-Exists -Name "evidence still present" -Path $evidencePath

# 5) Guard transcript marker denial
. (Join-Path $root "lib\guard.ps1")
Assert-Fails -Name "deny pasted transcript marker" -Action { Deny-IfPastedTranscript -RawText "PS C:\Users\Paul Wynn>" }

# 6) Policy missing should deny
if (Test-Path $policyBackup) { Remove-Item -Force $policyBackup }
Move-Item -Force $policyPath $policyBackup
Assert-Fails -Name "policy missing denies execution" -Action { & $runner -OutDir $proofDir }
Move-Item -Force $policyBackup $policyPath

# 7) OutDir outside allowed roots should deny
$badOut = Join-Path $env:TEMP "eco-engine-v1-bad-out"
Assert-Fails -Name "outdir outside allowed roots denies execution" -Action { & $runner -OutDir $badOut }

# 8) Determinism enforcement should fail if proof hash is modified
$hashPath = Join-Path $proofDir "snapshot.sha256"
$orig = (Get-Content -Raw $hashPath).Trim()
Set-Content -Path $hashPath -Value ("0000" + $orig.Substring(4)) -NoNewline

Assert-Fails -Name "determinism mismatch (tampered hash)" -Action { & $runner -OutDir $proofDir }

# Restore proof by rerunning with reboot variance allowed
Assert-Succeeds -Name "restore proof (allow variance)" -Action { & $runner -OutDir $proofDir -AllowRebootVariance }

Write-Host "OK: break suite completed"
