Set-StrictMode -Version Latest

function Get-EcdsaPublicKeyFromJson {
  param(
    [Parameter(Mandatory = $true)]
    [string]$Path
  )

  if (-not (Test-Path $Path)) { throw "AUTHORITY: Public key file missing: $Path" }

  $raw = Get-Content -Raw $Path
  Deny-IfPastedTranscript -RawText $raw

  try { $j = $raw | ConvertFrom-Json -ErrorAction Stop } catch { throw "AUTHORITY: Invalid public key JSON." }

  if ($j.schema -ne "wfsl.authority.pub.v1") { throw "AUTHORITY: Unsupported public key schema." }
  if ($j.alg -ne "ES256") { throw "AUTHORITY: Unsupported alg. Expected ES256." }
  if (-not $j.x -or -not $j.y) { throw "AUTHORITY: Missing x/y coordinates." }

  $x = [Convert]::FromBase64String([string]$j.x)
  $y = [Convert]::FromBase64String([string]$j.y)

  if ($x.Length -ne 32 -or $y.Length -ne 32) { throw "AUTHORITY: Invalid key coordinate length." }

  $params = New-Object System.Security.Cryptography.ECParameters
  $params.Curve = [System.Security.Cryptography.ECCurve+NamedCurves]::nistP256
  $params.Q = New-Object System.Security.Cryptography.ECPoint
  $params.Q.X = $x
  $params.Q.Y = $y

  return [System.Security.Cryptography.ECDsa]::Create($params)
}

function Verify-DetachedPolicySignature {
  param(
    [Parameter(Mandatory = $true)]
    [string]$PolicyPath,

    [Parameter(Mandatory = $true)]
    [string]$SignaturePath,

    [Parameter(Mandatory = $true)]
    [string]$PublicKeyPath
  )

  if (-not (Test-Path $PolicyPath)) { throw "AUTHORITY: Policy missing: $PolicyPath" }
  if (-not (Test-Path $SignaturePath)) { throw "AUTHORITY: Signature missing: $SignaturePath" }

  $policyRaw = Get-Content -Raw $PolicyPath
  Deny-IfPastedTranscript -RawText $policyRaw

  $sigB64 = (Get-Content -Raw $SignaturePath).Trim()
  if (-not $sigB64) { throw "AUTHORITY: Signature file empty." }

  $sig = [Convert]::FromBase64String($sigB64)

  $utf8NoBom = New-Object System.Text.UTF8Encoding($false)
  $data = $utf8NoBom.GetBytes($policyRaw)

  $ecdsa = Get-EcdsaPublicKeyFromJson -Path $PublicKeyPath

  $ok = $ecdsa.VerifyData($data, $sig, [System.Security.Cryptography.HashAlgorithmName]::SHA256)

  if (-not $ok) { throw "AUTHORITY: Policy signature verification failed." }
}
