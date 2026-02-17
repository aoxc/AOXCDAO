# Protocol Invariants: AOXC v2 Prime – Akdeniz

## 1. Purpose
This document describes the key invariants of the **AOXC v2 Prime** protocol. These rules are expected to hold across all state transitions, upgrades, and emergency procedures. Any violation indicates a serious failure.

---

## 2. Supply & Collateral
### 2.1 Collateral Backing
**Invariant:** `AOXC.totalSupply <= AssetBackingLedger.totalCollateralValue`  
- Ensures that every token is backed by verifiable collateral.  
- If violated, minting halts and the circuit breaker is triggered.  

### 2.2 Controlled Minting
**Invariant:** Only `MintController` can increase supply.  
- Prevents hidden minting paths.  
- Core contract does not allow direct minting.  

---

## 3. Transfers & Compliance
### 3.1 Policy Enforcement
**Invariant:** All transfers must pass compliance checks.  
- Identity and jurisdiction rules cannot be bypassed.  
- Enforced via hooks in `_update` logic.  

### 3.2 Pause Behavior
**Invariant:** If paused, transfers, minting, and redeeming are disabled.  
- Guarantees inactivity during threat mitigation.  

---

## 4. Governance & Upgrades
### 4.1 Triple-Gate Upgrade
**Invariant:** Upgrade requires Governor vote + Timelock delay + Authorizer execution.  
- Prevents fast or unauthorized upgrades.  

### 4.2 Storage Safety
**Invariant:** Storage slots remain consistent across migrations.  
- Protects against state corruption.  

---

## 5. Oracles & Monitoring
### 5.1 Price Freshness
**Invariant:** Price data must be within allowed staleness threshold.  
- Prevents use of outdated oracle values.  

### 5.2 Monitoring Isolation
**Invariant:** Monitoring components cannot mutate core state.  
- Observability must not affect protocol integrity.  

---

## 6. Bridges & Cross-Chain
**Invariant:** External bridge failures cannot alter AOXC Core state.  
- Ensures isolation between external adapters and main ledger.  

---

## 7. Verification
Each invariant must be:  
1. Tested with fuzzing (`monitoring/AOXCInvariantChecker.sol`).  
2. Free of high-severity static analysis findings.  
3. Documented in code with `@custom:invariant`.  

---

*"Security depends on rules that remain constant."*
