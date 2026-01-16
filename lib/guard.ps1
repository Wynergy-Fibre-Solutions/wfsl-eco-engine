Set-StrictMode -Version Latest

function Deny-IfPastedTranscript {
  param(
    [Parameter(Mandatory = $true)]
    [string]$RawText
  )

  # Reject common pasted transcript markers that cause accidental execution.
  $patterns = @(
    '^\s*PS\s+[A-Z]:\\',          # "PS C:\..."
    '^\s*>>\s+',                  # continuation prompt
    '^\s*\+\s+CategoryInfo',      # PowerShell error transcript
    '^\s*\+\s+FullyQualifiedErrorId',
    '^\s*At\s+line:\d+\s+char:\d+' # error location lines
  )

  foreach ($p in $patterns) {
    if ($RawText -match $p) {
      throw "GUARD: Detected pasted console transcript content. Refusing to run."
    }
  }
}

function Require-ExplicitInvocation {
  param(
    [Parameter(Mandatory = $true)]
    [string]$InvocationName
  )

  # Enforce explicit execution via file invocation.
  if (-not $InvocationName -or $InvocationName.Trim().Length -eq 0) {
    throw "GUARD: Invocation context is missing."
  }

  # Basic protection against dot-sourcing and implicit invocation.
  if ($InvocationName -match '^\s*\.') {
    throw "GUARD: Dot-sourcing is not permitted for v1. Use explicit file invocation."
  }
}

function Write-DeterministicFile {
  param(
    [Parameter(Mandatory = $true)]
    [string]$Path,

    [Parameter(Mandatory = $true)]
    [string]$ContentUtf8
  )

  $dir = Split-Path -Parent $Path
  if (-not (Test-Path $dir)) {
    New-Item -ItemType Directory -Path $dir -Force | Out-Null
  }

  # Deterministic UTF-8 without BOM
  $utf8NoBom = New-Object System.Text.UTF8Encoding($false)
  [System.IO.File]::WriteAllText($Path, $ContentUtf8, $utf8NoBom)
}

function Get-Sha256Hex {
  param(
    [Parameter(Mandatory = $true)]
    [byte[]]$Bytes
  )

  $sha = [System.Security.Cryptography.SHA256]::Create()
  try {
    $hash = $sha.ComputeHash($Bytes)
    return ($hash | ForEach-Object { $_.ToString("x2") }) -join ""
  }
  finally {
    $sha.Dispose()
  }
}
