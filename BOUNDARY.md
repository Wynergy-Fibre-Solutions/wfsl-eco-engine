\# WFSL Authority Control Plane  

\## Scope and Responsibility Boundary



This document defines the non-negotiable scope, guarantees, and responsibility boundaries of the WFSL Authority Control Plane (ACP).



This document is normative.  

If behaviour conflicts with this document, the behaviour is incorrect.



---



\## 1. Purpose



The WFSL Authority Control Plane exists to determine \*\*whether an action is authorised\*\*, not to ensure that an action succeeds.



It answers one question only:



> “Was this execution permitted by declared authority, under declared policy, at the time it occurred?”



---



\## 2. Definitions



\*\*Authority\*\*  

A cryptographic, time-bound capability to authorise policy-governed execution.



\*\*Policy\*\*  

A machine-readable declaration of allowed actions, constraints, and execution conditions.



\*\*Execution\*\*  

Any action initiated by software that produces a state change, output, or effect.



\*\*Proof\*\*  

Deterministic artefacts emitted by the system that allow independent verification of execution behaviour.



\*\*Verification\*\*  

Offline or online confirmation that proof artefacts are valid, complete, and untampered.



---



\## 3. What WFSL Guarantees



WFSL guarantees the following, and only the following:



1\. Deterministic evaluation of policy and authority inputs.

2\. Explicit denial of execution when policy or authority requirements are not satisfied.

3\. Machine-verifiable proof of execution decisions.

4\. Non-silent failure modes.

5\. Behavioural consistency with published specifications.



WFSL does \*\*not\*\* guarantee that execution will succeed.  

WFSL guarantees that execution will be \*\*correctly permitted or denied\*\*.



---



\## 4. What WFSL Does Not Guarantee



WFSL explicitly does not guarantee:



\- Business continuity

\- Availability of customer systems

\- Correctness of customer-authored policy

\- Correctness of customer-issued authority

\- Remediation of denied execution

\- Override, bypass, or emergency access



If execution is denied, the denial is final by design.



---



\## 5. Authority Boundary



Authority is external to WFSL.



WFSL:

\- Evaluates authority

\- Verifies signatures

\- Enforces authority constraints



WFSL does not:

\- Issue authority by default

\- Assume authority exists

\- Escalate authority

\- Substitute authority



Authority issuance, delegation, and revocation are the responsibility of the customer or a designated authority provider.



---



\## 6. Policy Boundary



Policies are authored and owned by the customer.



WFSL:

\- Enforces deny-by-default semantics

\- Verifies policy integrity

\- Refuses execution on invalid or unsigned policy (when required)



WFSL does not:

\- Modify policy

\- Infer policy intent

\- Auto-correct policy errors

\- Apply implied permissions



Policy failure is not a system failure.  

It is a governance signal.



---



\## 7. Failure Semantics



A failure in WFSL is defined as \*\*correct refusal\*\*.



Failure categories include:

\- Missing or invalid authority

\- Policy violation

\- Determinism mismatch

\- Evidence inconsistency

\- Verification refusal



Failures are expected, deterministic, and auditable.



WFSL failures are \*\*non-destructive\*\* and \*\*non-recovering\*\* by design.



---



\## 8. Evidence and Proof



When enabled, WFSL emits evidence that binds:

\- Policy identity

\- Authority identity

\- Execution decision

\- Engine behaviour



Evidence is:

\- Deterministic

\- Verifiable without WFSL infrastructure

\- Portable across environments



WFSL does not interpret evidence on behalf of third parties.



---



\## 9. Liability Alignment



WFSL software shifts responsibility as follows:



\- WFSL is responsible for correct evaluation and enforcement.

\- Customers are responsible for authority issuance and policy correctness.

\- Denied execution assigns responsibility to governance, not operators.

\- Permitted execution assigns responsibility to declared authority.



WFSL does not accept liability for decisions made by customer-issued authority.



---



\## 10. Non-Goals



WFSL ACP explicitly excludes:



\- System repair

\- Behaviour correction

\- State mutation

\- Emergency override

\- Silent recovery

\- Optimisation for convenience



These exclusions are intentional.



---



\## 11. Invariants



The following invariants are absolute:



1\. WFSL will not execute unauthorised actions.

2\. WFSL will not hide failure.

3\. WFSL will not infer intent.

4\. WFSL will not assume trust.

5\. WFSL will not override governance.



Violation of any invariant constitutes a defect.



---



\## 12. Precedence



In case of conflict, the following precedence applies:



1\. This boundary document

2\. Published technical specifications

3\. Implementation



Marketing materials have no authority.



---



\## 13. Acceptance



Use of WFSL ACP constitutes acceptance of this boundary.



If an organisation requires behaviour outside this boundary, WFSL ACP is not suitable.



---



End of document.



