# WFSL Deterministic Proof Verification Guide

This document explains how to independently verify a WFSL proof bundle
produced by CI or a trusted build environment.

No access to WFSL source code is required beyond the verifier script.

---

## What is a WFSL proof bundle

A proof bundle is a self-contained directory containing:

- policy.v2.json
- policy.sha256
- snapshot.json
- snapshot.sha256
- evidence.json
- evidence.sha256
- evidence.self.sha256

Together, these artefacts describe:
- What policy was enforced.
- What execution context was used.
- What evidence binds them.
- Cryptographic hashes proving integrity.

Nothing is inferred.
Nothing is fetched.
Nothing is trusted implicitly.

---

## Obtaining a proof bundle

1. Open a GitHub Actions run for this repository.
2. Download the artefact named:

   **wfsl-proof**

3. Extract the archive to a local directory, for example:

