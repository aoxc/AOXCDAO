# Security Assumptions: AOXC v2 Prime – Akdeniz

## 1. Purpose
This document lists the main security assumptions for the **AOXC v2 Prime** protocol. It defines trust boundaries and the expected environment needed to keep the system reliable. These assumptions form the basis of the Threat Model.

---

## 2. Governance & Consensus
- Governance participants are expected to act in the long-term interest of the protocol.  
- Governance capture is recognized as a risk; mitigated by timelocks and role separation.  
- Participants are assumed to prioritize solvency over short-term gain.  

---

## 3. Cryptography & Key Management
- Privileged roles (`Governor`, `Guardian`, `Authorizer`) should be managed via multisignature wallets or secure hardware.  
- Private keys are expected to be stored in secure environments (HSM, hardware wallets).  
- Key compromise is treated as an operational failure, not a protocol flaw.  

---

## 4. Guardians & Emergency Response
- Guardians are assumed to be independent and non-colluding.  
- Emergency actions (circuit breakers, pauses) are expected to be used only under verified threats.  
- Guardians are assumed to monitor signals (`monitoring/ForensicPulse.sol`) and respond within agreed timeframes.  

---

## 5. External Dependencies
- Oracles (`infrastructure/PriceOracleAdapter.sol`) are assumed to be reliable and correctly configured.  
- Bridges (`infrastructure/BridgeAdapter.sol`) are assumed to be isolated; external failures should not affect AOXC Core state.  
- The underlying EVM-compatible layer is assumed to resist persistent consensus attacks.  

---

## 6. Participants & End-Users
- Users are responsible for their own private key security.  
- Individual account compromises are considered out-of-scope and not protocol-level incidents.  

---

## 7. Residual Risks
Even with these assumptions, risks remain:
- Zero-day compiler or library vulnerabilities  
- Economic attacks not yet modeled  
- Governance collusion beyond quorum thresholds  

These are managed through:
1. Continuous monitoring (`monitoring/SequenceManager.sol`, `monitoring/RiskSignals.sol`)  
2. Invariant testing (`monitoring/AOXCInvariantChecker.sol`)  
3. Periodic third-party audits  

---

*"Security is not static; it requires ongoing verification."*
