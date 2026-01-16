# WFSL Evidence (eco-engine-v1)
# Deterministic evidence emission aligned to verifier contract.
# Emits:
#   proof\evidence.json
#   proof\evidence.sha256
#   proof\evidence.self.sha256

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

function Get-Sha256HexFromBytes {
  param([byte[]]$Bytes)

  $sha = [System.Security.Cryptography.SHA256]::Create()
  try { $hash = $sha.ComputeHash($Bytes) }
  finally { $sha.Dispose() }

  (-join ($hash | ForEach-Object { $_.ToString("x2") }))
}

function Write-Evidence {
  [CmdletBinding()]
  param(
    [Parameter(Mandatory = $true)]
    [string]$ProofDir,

    [Parameter(Mandatory = $true)]
    [string]$SnapshotSha256,

    [Parameter(Mandatory = $true)]
    [string]$PolicySha256
  )

  if ([string]::IsNullOrWhiteSpace($ProofDir)) {
    throw "Write-Evidence: ProofDir is empty"
  }
  if (-not (Test-Path -LiteralPath $ProofDir)) {
    throw "Write-Evidence: output directory not found: $ProofDir"
  }

  $snapshot = $SnapshotSha256.Trim().ToLowerInvariant()
  $policy   = $PolicySha256.Trim().ToLowerInvariant()

  if ($snapshot -notmatch '^[0-9a-f]{64}$') {
    throw "Write-Evidence: invalid SnapshotSha256"
  }
  if ($policy -notmatch '^[0-9a-f]{64}$') {
    throw "Write-Evidence: invalid PolicySha256"
  }

  $outRoot = (Resolve-Path -LiteralPath $ProofDir).Path

  $evidencePath    = Join-Path $outRoot "evidence.json"
  $evidenceShaPath = Join-Path $outRoot "evidence.sha256"
  $selfShaPath     = Join-Path $outRoot "evidence.self.sha256"

  # Minimal, stable schema
  $evidence = [ordered]@{
    schema           = "wfsl-evidence-v1"
    snapshot_sha256  = $snapshot
    policy_sha256    = $policy
  }

  $json = ($evidence | ConvertTo-Json -Depth 5)
  $json = ($json -replace "`r`n", "`n") + "`n"

  $utf8NoBom = New-Object System.Text.UTF8Encoding($false)
  [System.IO.File]::WriteAllText($evidencePath, $json, $utf8NoBom)

  # evidence.sha256 = hash of evidence.json bytes
  $bytes = [System.IO.File]::ReadAllBytes($evidencePath)
  $evidenceHash = Get-Sha256HexFromBytes -Bytes $bytes
  [System.IO.File]::WriteAllText($evidenceShaPath, ($evidenceHash + "`n"), $utf8NoBom)

  # evidence.self.sha256 = hash of the *token* inside evidence.sha256
  $tokenBytes = [System.Text.Encoding]::UTF8.GetBytes($evidenceHash)
  $selfHash = Get-Sha256HexFromBytes -Bytes $tokenBytes
  [System.IO.File]::WriteAllText($selfShaPath, ($selfHash + "`n"), $utf8NoBom)

  [pscustomobject]@{
    status = "sealed"
    path   = "evidence.json"
    sha256 = $evidenceHash
  }
}
