# WFSL Snapshot (eco-engine-v1)
# Deterministic snapshot emission into an existing proof directory.
# No network access. No telemetry.

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

function Write-Snapshot {
  [CmdletBinding()]
  param(
    [Parameter(Mandatory = $true)]
    [string]$ProofDir,

    [Parameter(Mandatory = $true)]
    [string]$PolicySha256,

    [Parameter(Mandatory = $true)]
    [string]$TimestampUtc,

    [Parameter(Mandatory = $false)]
    [string]$EngineName = "eco-engine-v1",

    [Parameter(Mandatory = $false)]
    [string]$EngineVersion = "1.0.0"
  )

  if ([string]::IsNullOrWhiteSpace($ProofDir)) {
    throw "Write-Snapshot: ProofDir is empty"
  }
  if (-not (Test-Path -LiteralPath $ProofDir)) {
    throw "Write-Snapshot: output directory not found: $ProofDir"
  }

  $policy = $PolicySha256.Trim().ToLowerInvariant()
  if ($policy -notmatch '^[0-9a-f]{64}$') {
    throw "Write-Snapshot: PolicySha256 must be 64 hex chars"
  }

  $ts = $TimestampUtc.Trim()
  if ([string]::IsNullOrWhiteSpace($ts)) {
    throw "Write-Snapshot: TimestampUtc is empty"
  }

  $outRoot = (Resolve-Path -LiteralPath $ProofDir).Path
  $snapshotPath = Join-Path $outRoot "snapshot.json"
  $snapshotShaPath = Join-Path $outRoot "snapshot.sha256"

  $snapshot = [ordered]@{
    engine = [ordered]@{
      name    = $EngineName
      version = $EngineVersion
    }
    timestamp_utc = $ts
    policy_sha256 = $policy
    proof = [ordered]@{
      schema = "wfsl-proof-v1"
    }
  }

  $json = ($snapshot | ConvertTo-Json -Depth 6)
  $json = ($json -replace "`r`n", "`n") + "`n"

  $utf8NoBom = New-Object System.Text.UTF8Encoding($false)
  [System.IO.File]::WriteAllText($snapshotPath, $json, $utf8NoBom)

  $hash = (Get-FileHash -LiteralPath $snapshotPath -Algorithm SHA256).Hash.ToLowerInvariant()
  [System.IO.File]::WriteAllText($snapshotShaPath, ($hash + "`n"), $utf8NoBom)

  [pscustomobject]@{
    status = "sealed"
    path   = "snapshot.json"
    sha256 = $hash
  }
}
