\# WFSL Read-Only Verifier v1.0.0



This package contains the authoritative WFSL proof verifier.



It is read-only, offline, and deterministic.



\## Contents



\- wfsl-verify.ps1

\- wfsl-verify.ps1.sha256



\## Usage



Place this verifier alongside a `proof` directory and run:



```powershell

pwsh -NoProfile -ExecutionPolicy Bypass `

&nbsp; -File wfsl-verify.ps1 `

&nbsp; -ProofDir ".\\proof" `

&nbsp; -RequireEvidence



