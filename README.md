# WFSL Eco Engine

Deterministic execution and authority-bound governance for environments where proof matters.

---

## What this is

WFSL Eco Engine is a deterministic execution and verification engine designed for organisations that must **prove how software behaved**, not merely assert it.

It is built for environments where logs, screenshots, platform assurances, or vendor claims are insufficient.

---

## Core guarantees

WFSL Eco Engine provides the following guarantees when executed correctly:

### Deterministic execution
- Identical inputs produce identical outputs
- Behaviour is repeatable across runs
- Any deviation is detected and surfaced explicitly

### Policy-bound behaviour
- Execution is governed by an explicit policy file
- Deny-by-default semantics are enforced
- Execution halts if policy requirements are not met

### Machine-verifiable proof
- Execution emits structured proof artefacts
- Proofs are cryptographically hashed
- Proofs can be verified independently, offline

### Optional evidence emission
- Evidence emission is opt-in
- Evidence binds snapshot, policy, and engine behaviour
- Evidence artefacts are deterministic and re-verifiable

### No platform trust assumptions
- No cloud dependency
- No telemetry
- No licence server
- No vendor infrastructure required for verification

---

## What this does not do

WFSL Eco Engine does **not**:

- Infer intent
- Auto-correct policy
- Hide execution failures
- Trust the host platform
- Require network access
- Depend on external authorities to verify results

If execution is denied, it is denied explicitly.

---

## Why v3 is free

Version 3 of WFSL Eco Engine is intentionally available without charge.

This allows any organisation to:

- Validate behaviour independently
- Reproduce results without obligation
- Verify claims without sales engagement

Verifiability must precede trust.

---

## Where commercial value begins

Commercial value begins when **authority matters**.

Some organisations do not merely need to know *what* ran.  
They need to prove **who authorised it**, **under what governance**, and **with what liability attached**.

This is where Signature-Required Mode applies.

---

## Signature-Required Mode (Governance Tier)

Signature-Required Mode enforces a single rule:

> Execution is only permitted when the governing policy is cryptographically signed by a recognised authority.

When enabled:
- Unsigned policies are rejected
- Tampered policies are rejected
- Authority identity becomes part of the proof chain
- Execution becomes non-repudiable

This elevates the engine from *policy-aware* to **authority-locked**.

---

## Behavioural comparison

| Capability | v3 (Free) | Signature-Required Mode |
|-----------|-----------|------------------------|
| Deterministic execution | Yes | Yes |
| Policy enforcement | Yes | Yes |
| Evidence emission | Optional | Required (configurable) |
| Authority binding | No | Yes |
| Non-repudiation | No | Yes |
| Contractual defensibility | Limited | Strong |
| Regulatory posture | Informational | Enforceable |

---

## Who this is for

Signature-Required Mode is intended for organisations that must:

- Demonstrate regulatory compliance
- Defend execution decisions under audit
- Reduce operational or legal risk
- Prove chain-of-authority
- Transfer responsibility from individuals to governance

---

## What is licensed

WFSL does not licence execution.

Execution is free.

WFSL licences **authority**.

Commercial arrangements relate to:
- Recognised signing authorities
- Signature enforcement guarantees
- Governance and certification workflows
- Liability alignment

---

## Summary

WFSL Eco Engine is not software that asks to be trusted.

It is software that can be **verified**, **challenged**, and **independently confirmed**.

Version 3 proves the engine.  
Signature-Required Mode proves the organisation using it.
