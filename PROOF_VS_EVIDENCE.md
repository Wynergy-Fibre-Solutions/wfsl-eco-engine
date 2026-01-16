Proof vs Evidence

WFSL Internal Boundary Document

1\. Why This Distinction Exists



Most systems collapse proof and evidence into the same concept.

This creates ambiguity, liability, and false confidence.



WFSL explicitly separates them.



This separation is foundational and non-negotiable.



2\. Definitions

Proof



Proof is a deterministic, machine-verifiable artefact that demonstrates:



A system behaved as declared



Under declared conditions



At a declared time



Without interpretation



Proof is:



Binary



Repeatable



Deterministic



Context-independent



Proof answers only one question:



“Did this system do exactly what it claimed to do?”



Evidence



Evidence is a contextual artefact intended for human or institutional evaluation.



Evidence may include:



Proof artefacts



Logs



Policies



Signatures



Metadata



External attestations



Evidence is:



Contextual



Interpretable



Time-bound



Audience-dependent



Evidence answers a different question:



“What does this demonstrate to a reasonable reviewer?”



3\. WFSL’s Position



WFSL produces proof by default.



WFSL produces evidence optionally.



WFSL does not produce conclusions.



WFSL does not interpret outcomes.



WFSL does not assert compliance, legality, or correctness beyond enforcement guarantees.



4\. Proof Characteristics (Non-Negotiable)



For an artefact to be considered proof within WFSL systems, it must be:



Cryptographically bound



Deterministically reproducible



Immutable once emitted



Independently verifiable



Free of narrative or explanation



If any of these conditions are not met, the artefact is not proof.



5\. Evidence Characteristics (Permissive)



Evidence may:



Aggregate multiple proofs



Include third-party material



Be incomplete



Be audience-specific



Be curated or filtered



Evidence may change over time.



Proof may not.



6\. Responsibility Boundary



WFSL is responsible for:



Correct proof generation



Correct enforcement of declared rules



Accurate verification mechanisms



WFSL is not responsible for:



How evidence is interpreted



Decisions made using evidence



Regulatory conclusions



Business or legal outcomes



Responsibility transfers at the evidence boundary.



7\. Failure Modes (Explicit)



The following are considered category errors within WFSL systems:



Treating logs as proof



Treating dashboards as proof



Treating signatures alone as proof



Treating evidence bundles as deterministic



Treating proof as sufficient evidence in all contexts



WFSL software is designed to prevent these errors where possible.



8\. Why This Matters



This distinction allows WFSL systems to:



Remain minimal without being weak



Be correct without being prescriptive



Be safe without being obstructive



Be valuable without being opinionated



It also prevents WFSL from becoming:



A compliance vendor



A legal arbiter



A risk underwriter



A decision authority



9\. Product Implications



Because of this boundary:



Open-source WFSL tools emit proof



Commercial WFSL tooling assembles evidence



Verification tools validate proof



Humans interpret evidence



This division is intentional.



10\. Status



This document is stable.



It should change only if:



Cryptographic assumptions fail



Determinism is no longer achievable



Regulatory environments fundamentally shift



Absent those conditions, this boundary stands.



End of document.

