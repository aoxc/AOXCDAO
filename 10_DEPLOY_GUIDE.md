# 🚀 Deployment Guide: AOXC v2 Prime – Akdeniz

---

## 📑 Purpose
This guide defines the canonical deployment and initialization sequence for **AOXC v2 Prime – Akdeniz**.  
It ensures that the modular architecture is interconnected with zero-error tolerance.  
This is a **ready-phase** procedure for internal operators and auditors.

---

## 🛠 Deployment Environment
- **Target Network:** X Layer (EVM-Compatible)  
- **Development Suite:** Foundry  
- **Compiler Version:** Solidity 0.8.33  
- **Security Standard:** OpenZeppelin 5.5.x  
- **Prerequisite:** Deployment accounts must be pre-funded and keys secured via HSM.  

---

## 🏗️ Deployment Sequence (13 Steps)

### Phase A – Foundations
1. `RoleAuthority` → Root permission and role hierarchy  
2. `MonitoringHub` → Telemetry activation  
3. `IdentityRegistry` → Identity verification layer  
4. `JurisdictionRegistry` → Jurisdictional constraints  

### Phase B – Security
5. `ComplianceRegistry` → Aggregated compliance logic  
6. `GuardianRegistry` → Emergency guardians  
7. `ThreatSurface` → Risk scoring and signaling  
8. `TransferPolicyEngine` → Transfer validation rules  

### Phase C – Core
9. `AOXCStorage` → Frozen storage layout  
10. `AOXC` → Core token logic  
11. `Treasury` → Asset custody  
12. `MintController / RedeemController` → Supply management  

### Phase D – Governance
13. `AOXCGovernor + Timelock` → DAO authority handover  

---

## ✅ Ready Checklist
- [ ] Role assignments validated  
- [ ] Policy hooks integrated (`AOXC.sol → TransferPolicyEngine`)  
- [ ] Emergency halt tested (`EmergencyPauseGuard`)  
- [ ] Invariant tests executed via Foundry  

---

## 📝 Operational Notes
- **Strict Order:** Any deviation requires review.  
- **Status:** Construction phase complete, governance handover pending.  
- **Traceability:** Deployment logs stored in `broadcast/` folder.  

---

*"Ready is not final; it is the disciplined state before sovereignty."*
