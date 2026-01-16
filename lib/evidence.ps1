Set-StrictMode -Version Latest

function Write-EvidenceV3 {
  param(
    [Parameter(Mandatory = $true)]
    [string]$OutDir,

    [Parameter(Mandatory = $true)]
    [string]$SnapshotSha256,

    [Parameter(Mandatory = $true)]
    [string]$PolicySha256
  )

  # Evidence must be deterministic. Do not include current timestamps.
  $evidenceCore = [ordered]@{
    schema = "wfsl.eco.evidence.v3"
    evidenceVersion = "3.0.0"
    engine = [ordered]@{
      name = "wfsl-eco-engine"
      behaviourLevel = "v3"
    }
    inputs = [ordered]@{
      snapshotSha256 = $SnapshotSha256
      policySha256   = $PolicySha256
    }
  }

  $jsonCore = $evidenceCore | ConvertTo-Json -Depth 6 -Compress
  Deny-IfPastedTranscript -RawText $jsonCore

  $utf8NoBom = New-Object System.Text.UTF8Encoding($false)
  $bytes = $utf8NoBom.GetBytes($jsonCore)
  $evidenceHash = Get-Sha256Hex -Bytes $bytes

  $evidence = [ordered]@{
    schema = $evidenceCore.schema
    evidenceVersion = $evidenceCore.evidenceVersion
    engine = $evidenceCore.engine
    inputs = $evidenceCore.inputs
    evidenceSha256 = $evidenceHash
  }

  $json = $evidence | ConvertTo-Json -Depth 6 -Compress
  Deny-IfPastedTranscript -RawText $json

  $evidencePath = Join-Path $OutDir "evidence.v3.json"
  $evidenceHashPath = Join-Path $OutDir "evidence.v3.sha256"

  Write-DeterministicFile -Path $evidencePath -ContentUtf8 $json
  Write-DeterministicFile -Path $evidenceHashPath -ContentUtf8 ($evidenceHash + "`n")
}
