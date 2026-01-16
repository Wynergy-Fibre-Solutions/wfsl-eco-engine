Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$root = Split-Path -Parent $MyInvocation.MyCommand.Path
$proof = Join-Path $root "proof"

if (-not (Test-Path $proof)) {
  throw "No proof directory found."
}

$files = @(
  "snapshot.json",
  "snapshot.sha256",
  "policy.sha256",
  "evidence.v3.json",
  "evidence.v3.sha256"
)

foreach ($name in $files) {
  $path = Join-Path $proof $name
  if (Test-Path $path) {
    notepad.exe $path
  }
}
