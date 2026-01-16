Revocation Layer

WFSL Internal Boundary Document

1\. Why Revocation Exists



Trust that cannot be terminated becomes liability.



WFSL treats revocation as a first-class control, not an exception path.

Revocation is not failure. It is governance working as designed.



2\. Definition



Revocation is the explicit, authoritative termination of trust.



Once revoked, an artefact is treated as:



Invalid



Unauthoritative



Non-existent for execution purposes



Revocation does not weaken trust.

It ends it.



3\. Revocation Is Immediate



Within WFSL systems:



Revocation takes effect at recognition



No grace period exists unless explicitly declared



No caching is permitted beyond declared tolerance



Delayed revocation is considered a system fault.



4\. Revocation Scope



Revocation may apply to:



Authority objects



Policies



Evidence assemblies



Delegated issuers



Trust anchors



Revocation scope must be explicit.



Unscoped revocation is invalid.



5\. Propagation Requirement



WFSL systems must ensure that:



Revocation is discoverable



Revocation is verifiable



Revocation is enforced uniformly



A system that continues to honour revoked trust is non-compliant by design.



6\. Revocation vs Expiry



Expiry is passive.

Revocation is active.



Expiry ends trust by time



Revocation ends trust by decision



Both are final.



7\. Irreversibility



Revocation is irreversible.



Restoring trust requires:



New issuance



New identifiers



New validity windows



New proof



Revoked trust cannot be reinstated.



8\. Proof and Revocation



Proof artefacts may reference revoked trust.



Such proof remains valid only as a historical record.



Revoked trust is never honoured for new execution.



9\. Responsibility Boundary



Issuers are responsible for initiating revocation



Operators are responsible for ceasing use



WFSL is responsible for enforcement



WFSL does not arbitrate revocation disputes.



10\. Failure Modes (Explicit)



The following are invalid within WFSL systems:



Silent revocation



Partial revocation



Deferred revocation



Soft-fail revocation



“Best effort” revocation



Revocation is binary.



11\. Why This Matters



This layer prevents:



Ghost authority



Forgotten access



Long-tail compromise



Institutional drift



Legal ambiguity



It also enforces accountability upstream.



12\. Status



This boundary is stable.



It changes only if:



Revocation cannot be propagated deterministically



Trust termination becomes unverifiable



Until then, revocation stands.



End of document.

