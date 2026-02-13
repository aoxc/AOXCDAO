# 🚀 Deployment Guide: AOXC v2 Prime – Akdeniz

## 📑 Purpose
This document defines the canonical deployment and initialization sequence for **AOXC v2 Prime – Akdeniz**. It ensures that the modular architecture is interconnected with zero-error tolerance. This is a **Pro-Ultimate** grade procedure for internal operators and auditors.

---

## 🛠 Deployment Environment
* **Target Network:** X Layer (EVM-Compatible)
* **Development Suite:** `Foundry`
* **Compiler Version:** `Solidity 0.8.33`
* **Security Standard:** OpenZeppelin `5.5.x`
* **Prerequisite:** Deployment accounts must be pre-funded and keys secured via Hardware Security Modules (HSM).

---

## 🏗️ Canonical Deployment Sequence (The 13 Steps)

To maintain system integrity, the shipyard follows a strict dependency injection order:

### Phase A: The Command & Signal (Foundations)
1.  **`RoleAuthority`**
    * *Purpose:* Establishes the root permission and role hierarchy (RBAC).
2.  **`MonitoringHub`**
    * *Purpose:* Enables protocol-wide telemetry from the first block (The Eyes).
3.  **`IdentityRegistry`**
    * *Purpose:* Initializes the institutional identity verification layer.
4.  **`JurisdictionRegistry`**
    * *Purpose:* Applies jurisdictional constraints (MiCA/FinCEN readiness).

### Phase B: The Shield & Policy (Security)
5.  **`ComplianceRegistry`**
    * *Purpose:* Aggregates multi-layer compliance logic.
6.  **`GuardianRegistry`**
    * *Purpose:* Registers emergency and security guardians for the federation.
7.  **`ThreatSurface`**
    * *Purpose:* Activates risk scoring and real-time threat signaling.
8.  **`TransferPolicyEngine`**
    * *Purpose:* Enforces high-fidelity transfer validation rules.

### Phase C: The Anchor & Vault (Core)
9.  **`AOXCStorage`**
    * *Purpose:* Deploys the frozen storage layout to ensure future-proof upgradeability.
10. **`AOXC` (The Anchor)**
    * *Purpose:* Deploys the core token logic and anchors it to the system.
11. **`Treasury`**
    * *Purpose:* Initializes asset custody and management protocols.
12. **`MintController / RedeemController`**
    * *Purpose:* Activates supply management and asset-backing validation.

### Phase D: Sovereign Handover
13. **`Governance (Governor + Timelock)`**
    * *Purpose:* Transfers final authority to the on-chain DAO, sealing the shipyard phase.

---

## 🧪 Post-Deployment Verification (Level 1 Checklist)
- [ ] **Role Validation:** Ensure `DEFAULT_ADMIN_ROLE` is correctly distributed.
- [ ] **Hook Integrity:** Confirm `AOXC.sol` correctly calls `TransferPolicyEngine`.
- [ ] **Emergency Test:** Validate `EmergencyPauseGuard` functionality in a local fork.
- [ ] **Zero-Mock Invariants:** Run all Foundry invariant tests against the deployed state.

---

## 📝 Operational Notes
* **Strict Order:** Any deviation from this sequence triggers a mandatory architectural review.
* **Status:** Currently validating Step 1-Step 10 in the **Level 1: Construction Phase**.
* **Traceability:** All deployment logs must be stored in the `broadcast/` folder of the Foundry suite.

---
*"Precision is the difference between a project and a federation."*
