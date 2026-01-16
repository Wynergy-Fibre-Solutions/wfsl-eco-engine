# WFSL Policy (eco-engine-v1)
# Deterministic policy sealing into an existing proof directory.
# Emits:
#   proof\policy.v2.json
#   proof\policy.sha256
# No network access. No telemetry.

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

function Write-PolicyV2 {
  [CmdletBinding()]
  param(
    [Parameter(Mandatory = $true)]
    [string]$PolicyPath,

    # Must already exist. This function will not create directories.
    [Parameter(Mandatory = $true)]
    [string]$OutDir
  )

  if ([string]::IsNullOrWhiteSpace($PolicyPath)) { throw "Write-PolicyV2: PolicyPath is empty" }
  if (-not (Test-Path -LiteralPath $PolicyPath)) { throw "Write-PolicyV2: policy not found: $PolicyPath" }

  if ([string]::IsNullOrWhiteSpace($OutDir)) { throw "Write-PolicyV2: OutDir is empty" }
  if (-not (Test-Path -LiteralPath $OutDir)) { throw "Write-PolicyV2: output directory not found: $OutDir" }

  $outRoot = (Resolve-Path -LiteralPath $OutDir).Path

  # Proof contract fixed filenames
  $policyOutPath = Join-Path $outRoot "policy.v2.json"
  $policyShaPath = Join-Path $outRoot "policy.sha256"

  # Copy policy artefact into proof dir (self-contained proof)
  $srcPolicy = (Resolve-Path -LiteralPath $PolicyPath).Path
  Copy-Item -LiteralPath $srcPolicy -Destination $policyOutPath -Force

  # Hash the copied artefact (not the source path)
  $hash = (Get-FileHash -LiteralPath $policyOutPath -Algorithm SHA256).Hash.ToLowerInvariant()

  # Write sha file (lowercase hex + newline)
  $utf8NoBom = New-Object System.Text.UTF8Encoding($false)
  [System.IO.File]::WriteAllText($policyShaPath, ($hash + "`n"), $utf8NoBom)

  # Return status object
  $bytes = (Get-Item -LiteralPath $policyOutPath).Length

  [pscustomobject]@{
    status = "sealed"
    path   = "policy.v2.json"
    sha256 = $hash
    bytes  = $bytes
  }
}
