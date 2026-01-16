param(
  [Parameter(Mandatory = $false)]
  [switch]$Evidence
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$root = Split-Path -Parent $MyInvocation.MyCommand.Path
$runner = Join-Path $root "run.ps1"

Write-Host "WFSL eco-engine v2"
Write-Host "Running safely..."

if ($Evidence) {
  powershell -NoProfile -ExecutionPolicy Bypass -File $runner -EmitEvidence
} else {
  powershell -NoProfile -ExecutionPolicy Bypass -File $runner
}

Write-Host "Done. Use view-proof.ps1 to inspect proof."
