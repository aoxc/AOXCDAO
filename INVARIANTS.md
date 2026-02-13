# 🛡️ PROTOCOL INVARIANTS: THE IRON LAWS OF AOXC

## 1. Purpose
This document defines the non-negotiable, mathematically provable invariants of the **AOXC v2 Prime** protocol. These laws must hold true across all state transitions, upgrades, and emergency procedures. 

**Any invariant violation is a terminal failure.**

---

## 2. Supply & Collateral Integrity
### 2.1 Full-Collateral Backing
**Invariant:** `$AOXC.totalSupply \le AssetBackingLedger.totalCollateralValue$`
* **Rationale:** Prevents unbacked inflation. Every token must have a verifiable RWA or liquid backing.
* **Failure Response:** Immediate minting halt + Emergency Circuit Breaker.

### 2.2 Minting Sovereignty
**Invariant:** `onlyRole(MINT_CONTROLLER_ROLE) increases totalSupply`
* **Rationale:** Eliminates hidden minting paths. No direct minting allowed in the core contract.

---

## 3. Transfer & Compliance Sanctity
### 3.1 Policy Enforcement Loop
**Invariant:** `P(x) validation must return TRUE for all Transfer(from, to, amount)`
* **Rationale:** Identity (KYC) and Jurisdictional (MiCA/FinCEN) checks cannot be bypassed.
* **Enforcement:** Mandatory hook in `_update` logic.

### 3.2 Deterministic Pause Behavior
**Invariant:** `If (state == PAUSED) → {transfer, mint, redeem} == DISABLED`
* **Rationale:** Guarantees zero activity during threat mitigation.

---

## 4. Governance & Structural Safety
### 4.1 Triple-Gate Upgradeability
**Invariant:** `Upgrade = (Governor Vote) + (Timelock Delay) + (Authorizer Execution)`
* **Rationale:** Prevents malicious "flash upgrades."

### 4.2 Storage Layout Persistence
**Invariant:** `Slot(n) identity must remain constant across logic migrations`
* **Rationale:** Prevents state corruption and "storage collisions."

---

## 5. Oracle & Forensic Invariants
### 5.1 Temporal Price Freshness
**Invariant:** `Current_Block_Time - Price_Timestamp \le Staleness_Threshold`
* **Rationale:** Prevents arbitrage on outdated data.

### 5.2 Forensic Isolation
**Invariant:** `MonitoringHub.stateMutation == FALSE`
* **Rationale:** Observability (The Eyes) must not affect the Core (The Anchor).

---

## 6. Bridge & Cross-Chain Shielding
### 6.1 Fault Isolation
**Invariant:** `Bridge_State_Corruption \cap Core_State == \emptyset`
* **Rationale:** A failure in an external L2 or bridge must not affect the main X Layer registry.

---

## 7. Verification Standards
Every invariant listed here **MUST** be:
1.  **Fuzzed:** Tested via Foundry Invariant Testing (`testInvariant_...`).
2.  **Linter-Clean:** Zero violations in static analysis.
3.  **NatSpec Documented:** Linked in the source code via `@custom:invariant`.

---
*"In mathematics we trust; in invariants we settle."*
