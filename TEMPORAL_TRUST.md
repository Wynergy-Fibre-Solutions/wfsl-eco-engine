Temporal Trust

WFSL Internal Boundary Document

1\. Why Temporal Trust Exists



Trust without time boundaries becomes assumption.



WFSL rejects assumption.



Every assertion within WFSL-governed systems must be anchored to an explicit temporal window. Outside that window, the assertion is invalid by definition.



2\. Definition



Temporal Trust is the explicit declaration and enforcement of:



When an assertion becomes valid



When it expires



Under what conditions it may be renewed



How expiry is verified



Temporal Trust is not inferred.

Temporal Trust is declared.



3\. Time Is a First-Class Constraint



Within WFSL systems:



Authority expires



Policies expire



Evidence ages



Proof remains immutable but time-scoped



No object is timeless.



4\. Validity Windows



All trust-bearing artefacts must declare a validity window:



notBefore



notAfter



An artefact outside its validity window is treated as non-existent.



Expired trust is not “weaker trust”.

It is no trust.



5\. Renewal Is Not Continuation



Renewal requires:



A new issuance event



A new validity window



Explicit acknowledgement



Renewal does not extend the past.

It creates a new present.



6\. Retroactive Legitimacy Is Prohibited



WFSL systems do not permit:



Backdating authority



Retroactive policy validity



Post-hoc justification



“Effective as of” trust without contemporaneous proof



If trust did not exist at the time, it cannot be created later.



7\. Proof and Time



Proof artefacts include:



Emission timestamp



Deterministic content hash



Reference to the validity window in effect



Proof demonstrates what was true at that moment only.



Proof does not age.

Trust does.



8\. Evidence and Time



Evidence must acknowledge time explicitly.



Evidence that ignores expiry, renewal, or revocation is incomplete.



WFSL does not correct evidence for temporal omissions.



9\. Responsibility Boundary



Issuers are responsible for defining validity windows



Operators are responsible for executing within them



WFSL is responsible for enforcing them



Failure due to expiry is a correct outcome.



10\. Failure Modes (Explicit)



The following are invalid within WFSL systems:



Indefinite authority



“Until revoked” without expiry



Silent rollover



Clock-skew forgiveness beyond declared tolerance



Time-based exceptions



Convenience is not a justification.



11\. Why This Matters



Temporal Trust prevents:



Permanent escalation



Forgotten credentials



Undiscoverable risk



Audit ambiguity



Institutional memory loss



It also forces discipline upstream.



12\. Status



This boundary is stable.



It changes only if:



Time itself cannot be trusted



Deterministic clocks become impossible



Cryptographic timestamping collapses



Until then, time governs trust.



End of document.

