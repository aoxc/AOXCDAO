# Upgrade Policy: AOXC v2 Prime – Akdeniz

## 1. Purpose
This document explains how upgrades to the **AOXC v2 Prime** protocol are managed. The goal is to allow improvements while keeping user balances, governance rules, and compliance records safe from unintended changes.

---

## 2. Principles
- **Transparency:** All upgrades must be documented and reviewed.  
- **Delay Requirement:** No instant upgrades; every change requires a timelock period.  
- **Role Separation:** Governance proposes, Authorizer executes.  
- **State Safety:** Storage layout and balances must remain consistent across upgrades.  

---

## 3. Components

### 3.1 Upgradeable
- **Core Logic:** `core/AOXC.sol`, `asset/MintController.sol`, `asset/RedeemController.sol`  
- **Policy Engines:** `policy/TransferPolicyEngine.sol`  
- **Infrastructure:** `infrastructure/BridgeAdapter.sol`, `infrastructure/PriceOracleAdapter.sol`  

### 3.2 Frozen
- **Storage:** `core/AOXCStorage.sol` (layout is fixed)  
- **Trust Root:** `governance/RoleAuthority.sol`  
- **Historical Records:** `compliance/IdentityRegistry.sol`, `compliance/JurisdictionRegistry.sol`  

---

## 4. Authorization Flow
Upgrades require three steps:
1. **Governance Approval:** Proposal via `governance/AOXCGovernor.sol`  
2. **Timelock Delay:** Enforced by `governance/AOXCTimelock.sol`  
3. **Final Check:** Validation by `core/AOXCUpgradeAuthorizer.sol`  

---

## 5. Storage Standards
- New variables must be appended, not reordered.  
- Use explicit namespaces to avoid collisions.  
- Run automated diff checks (`forge inspect storage`).  

---

## 6. Pre-Upgrade Checklist
- [ ] Invariant and fuzz tests pass (`monitoring/AOXCInvariantChecker.sol`)  
- [ ] Code diff reviewed manually and automatically  
- [ ] Backward compatibility confirmed  
- [ ] Guardian pause readiness verified (`security/GuardianRegistry.sol`)  

---

## 7. Emergency Protocol
If a critical vulnerability is found:
- Pause via `security/GuardianRegistry.sol`  
- Governance may adjust quorum, but timelock remains mandatory  
- A post-mortem report must be published within 48 hours  

---

## 8. Audit Trail
For each upgrade, archive:
- Proposal hash  
- Bytecode diff  
- Test logs  

---

## 9. Governance of Policy
This policy itself can only be changed through the same governance and timelock process.

---
*"Upgrades must serve progress without risking integrity."*
