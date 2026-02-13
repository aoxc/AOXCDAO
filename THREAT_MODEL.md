# ⚔️ THREAT MODEL: AOXC v2 PRIME – AKDENİZ

## 1. Purpose
This document defines the comprehensive threat landscape for the **AOXC v2 Prime** protocol. It identifies credible adversaries, protected assets, trust boundaries, and the technical mitigations enforced by the architecture.

The goal is to provide transparency on which risks are addressed **on-chain (programmatic)** and which are managed **operationally (governance)**.

---

## 2. System Scope & Boundaries

### 2.1 In-Scope (The Protected Surface)
* **Core Ledger:** `AOXC.sol`, `AOXCStorage.sol`, `Mint/RedeemControllers`.
* **Governance Logic:** `AOXCGovernor.sol`, `AOXCTimelock.sol`.
* **Asset Integrity:** `Treasury.sol`, `AssetBackingLedger.sol`.
* **Compliance:** `IIdentityRegistry.sol`, `TransferPolicyEngine.sol`.
* **Gateways:** `BridgeAdapters`, `RelayerGateways`, `PriceOracle`.

### 2.2 Out-of-Scope (External Risks)
* End-user private key management (Self-custody).
* Frontend/UI phishing or DNS hijacking.
* Underlying Layer-1 / L2 (X Layer) consensus failures.

---

## 3. Adversary Model & Attack Vectors

### 3.1 External Attacker (The Predator)
* **Capabilities:** Flash loans, MEV reordering, oracle front-running, arbitrary contract calls.
* **Primary Targets:** Draining collateral, inflating supply, bypassing KYC.

### 3.2 Privileged Insider (The Malicious Actor)
* **Capabilities:** Compromised Guardian, Controller, or Governor key.
* **Primary Targets:** Unauthorized minting, censorship, malicious upgrades.

### 3.3 Colluding Entities (The Federation Breach)
* **Capabilities:** Multi-role collusion (e.g., Guardian + Controller).
* **Primary Targets:** Systemic value extraction and permanent trust erosion.

---

## 4. Threat Categories & Programmatic Mitigations

| Threat Category | Attack Vector | Technical Mitigation |
| :--- | :--- | :--- |
| **Unauthorized Minting** | Hidden inflation / Re-entrancy | `onlyController` modifier + `ReentrancyGuard` + `totalSupply <= collateralValue` invariant. |
| **Oracle Manipulation** | Price staleness / Flash loan skew | `Timestamp` validation + `Deviation Thresholds` + `Emergency Circuit Breakers`. |
| **Governance Abuse** | Flash proposal / Hostile takeover | `Governance_Delay` ($T_{delay}$) + `Quorum` requirements + `Guardian` override. |
| **Upgrade Attacks** | Proxy hijacking / Storage collision | `AOXCUpgradeAuthorizer` + `Frozen Storage Layout` + `Explicit Namespace Protection`. |
| **Compliance Bypass** | Jurisdictional evasion | `TransferPolicyEngine` hook in the atomic `_update` path. |
| **Bridge Exploits** | Double-spending / Message forgery | `Core State Isolation` + `Rate Limiting` + `Replay Protection`. |

---

## 5. Failure Modes & Expected State

* **Scenario: Oracle Staleness Detected** * *Behavior:* `AssetBackingLedger` returns error → Mint/Redeem functions revert immediately.
* **Scenario: Governance Deadlock** * *Behavior:* Emergency Guardians trigger a temporary protocol freeze until the deadlock is resolved via `RoleAuthority`.
* **Scenario: Bridge Compromise** * *Behavior:* Bridge adapter is disconnected via `Guardian` call; **AOXC Core** state remains immutable and secure.

---

## 6. Testing & Validation Matrix
To ensure this threat model remains valid, the following protocols are enforced:
1. **Fuzzing:** Targeted attacks on `MintController` invariants.
2. **Static Analysis:** Zero-tolerance for Slither/Solhint high-severity findings.
3. **Formal Verification:** Mathematical proof of the **Supply-to-Collateral** ratio.

---

## 7. Residual Risk Statement
The protocol acknowledges residual risks from:
* Extreme L1 censorship or network halts.
* Zero-day vulnerabilities in the Solidity compiler or OpenZeppelin core.
* Majority governance collusion ($>67\%$).

---
*"We do not hope for safety; we engineer it."*
