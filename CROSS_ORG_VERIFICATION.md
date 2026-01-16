param(

&nbsp; \[Parameter(Mandatory = $false)]

&nbsp; \[string]$ProofDir = ".\\proof",



&nbsp; \[Parameter(Mandatory = $false)]

&nbsp; \[switch]$RequireEvidence,



&nbsp; \[Parameter(Mandatory = $false)]

&nbsp; \[switch]$RequirePolicySignature

)



Set-StrictMode -Version Latest

$ErrorActionPreference = "Stop"



function Pass(\[string]$Msg) { Write-Host ("PASS: " + $Msg) }

function Fail(\[string]$Msg) { throw ("FAIL: " + $Msg) }



function Read-Text(\[string]$Path) {

&nbsp; if (-not (Test-Path -LiteralPath $Path)) { Fail ("missing file: " + $Path) }

&nbsp; return (Get-Content -LiteralPath $Path -Raw)

}



function Get-Sha256HexFromBytes(\[byte\[]]$Bytes) {

&nbsp; $sha = \[System.Security.Cryptography.SHA256]::Create()

&nbsp; try {

&nbsp;   $hash = $sha.ComputeHash($Bytes)

&nbsp;   return (\[BitConverter]::ToString($hash).Replace("-", "")).ToLowerInvariant()

&nbsp; }

&nbsp; finally {

&nbsp;   $sha.Dispose()

&nbsp; }

}



function Get-Utf8NoBomBytes(\[string]$Text) {

&nbsp; $enc = New-Object System.Text.UTF8Encoding($false)

&nbsp; return $enc.GetBytes($Text)

}



function Verify-FileHash(\[string]$DataPath, \[string]$HashPath, \[string]$Label) {

&nbsp; $data = Read-Text $DataPath

&nbsp; $expected = (Read-Text $HashPath).Trim()

&nbsp; $actual = Get-Sha256HexFromBytes (Get-Utf8NoBomBytes $data)

&nbsp; if ($expected -ne $actual) { Fail ("$Label sha256 mismatch. Expected=$expected Actual=$actual") }

&nbsp; Pass ("$Label integrity verified")

&nbsp; return $actual

}



function Resolve-Full(\[string]$Path) {

&nbsp; return \[System.IO.Path]::GetFullPath($Path)

}



$proofFull = Resolve-Full $ProofDir



$snapshotJson = Join-Path $proofFull "snapshot.json"

$snapshotSha  = Join-Path $proofFull "snapshot.sha256"

$policySha    = Join-Path $proofFull "policy.sha256"



$evidenceJson = Join-Path $proofFull "evidence.v3.json"

$evidenceSha  = Join-Path $proofFull "evidence.v3.sha256"



\# 1) Snapshot integrity

$computedSnapshotSha = Verify-FileHash -DataPath $snapshotJson -HashPath $snapshotSha -Label "snapshot"



\# 2) Policy identity integrity (policy.sha256 must exist and be valid hex)

if (-not (Test-Path -LiteralPath $policySha)) {

&nbsp; Fail "policy.sha256 missing"

}



$policyId = (Read-Text $policySha).Trim()

if ($policyId -notmatch '^\[a-f0-9]{64}$') { Fail "policy.sha256 is not a valid sha256 hex string" }

Pass "policy identity loaded from proof"



\# 3) Evidence optional / required

if ($RequireEvidence) {

&nbsp; if (-not (Test-Path -LiteralPath $evidenceJson)) { Fail "evidence required but evidence.v3.json missing" }

&nbsp; if (-not (Test-Path -LiteralPath $evidenceSha))  { Fail "evidence required but evidence.v3.sha256 missing" }



&nbsp; $computedEvidenceSha = Verify-FileHash -DataPath $evidenceJson -HashPath $evidenceSha -Label "evidence"



&nbsp; # Evidence content consistency checks (minimal, deterministic)

&nbsp; $evRaw = Read-Text $evidenceJson

&nbsp; try { $ev = $evRaw | ConvertFrom-Json -ErrorAction Stop } catch { Fail "evidence.v3.json is not valid JSON" }



&nbsp; if ($ev.schema -ne "wfsl.eco.evidence.v3") { Fail "evidence schema mismatch" }



&nbsp; if ($ev.inputs.snapshotSha256 -ne $computedSnapshotSha) {

&nbsp;   Fail ("evidence snapshotSha256 does not match snapshot proof. Evidence=" + $ev.inputs.snapshotSha256 + " Proof=" + $computedSnapshotSha)

&nbsp; }



&nbsp; if ($ev.inputs.policySha256 -ne $policyId) {

&nbsp;   Fail ("evidence policySha256 does not match policy.sha256. Evidence=" + $ev.inputs.policySha256 + " Proof=" + $policyId)

&nbsp; }



&nbsp; if ($ev.evidenceSha256 -ne $computedEvidenceSha) {

&nbsp;   Fail ("evidence self sha mismatch. EvidenceField=" + $ev.evidenceSha256 + " Computed=" + $computedEvidenceSha)

&nbsp; }



&nbsp; Pass "evidence integrity verified"

}

else {

&nbsp; # If evidence exists, we do not fail. We remain permissive unless required.

&nbsp; if ((Test-Path -LiteralPath $evidenceJson) -or (Test-Path -LiteralPath $evidenceSha)) {

&nbsp;   Pass "evidence present (optional)"

&nbsp; }

&nbsp; else {

&nbsp;   Pass "evidence not present (optional)"

&nbsp; }

}



\# 4) Policy signature (optional, can be required)

$policySig = Join-Path (Resolve-Full ".") "policy.v2.json.sig"

$pubKey    = Join-Path (Resolve-Full ".") "authority\\public.authority.es256.json"



if ($RequirePolicySignature) {

&nbsp; if (-not (Test-Path -LiteralPath $policySig)) { Fail "policy signature required but policy.v2.json.sig missing" }

&nbsp; if (-not (Test-Path -LiteralPath $pubKey))    { Fail "policy signature required but public authority key missing" }

&nbsp; Pass "policy signature required (file presence satisfied)"

}

else {

&nbsp; if ((Test-Path -LiteralPath $policySig) -and (Test-Path -LiteralPath $pubKey)) {

&nbsp;   Pass "policy signature present (optional)"

&nbsp; }

&nbsp; else {

&nbsp;   Pass "policy signature not present (optional)"

&nbsp; }

}



Write-Host "OK: verification completed"

exit 0



