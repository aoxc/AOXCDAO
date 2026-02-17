# Threat Model: AOXC v2 Prime – Akdeniz

## 1. Purpose
This document describes the main security risks for the **AOXC v2 Prime** protocol. It highlights possible adversaries, critical components, and the mitigations applied. The aim is to provide clarity on which risks are handled on-chain and which are managed through governance.

---

## 2. System Scope & Boundaries

### 2.1 In-Scope
- **Core Ledger:** `core/AOXC.sol`, `core/AOXCStorage.sol`, `asset/MintController.sol`, `asset/RedeemController.sol`
- **Governance Logic:** `governance/AOXCGovernor.sol`, `governance/AOXCTimelock.sol`
- **Asset Integrity:** `infrastructure/Treasury.sol`, `asset/AssetBackingLedger.sol`
- **Compliance:** `compliance/IdentityRegistry.sol`, `policy/TransferPolicyEngine.sol`
- **Gateways:** `infrastructure/BridgeAdapter.sol`, `infrastructure/RelayerGateway.sol`, `infrastructure/PriceOracleAdapter.sol`

### 2.2 Out-of-Scope
- End-user private key management  
- Frontend/UI phishing or DNS hijacking  
- Layer-1 / L2 consensus failures  

---

## 3. Adversary Model

### 3.1 External Attacker
- **Capabilities:** Flash loans, MEV reordering, oracle manipulation  
- **Targets:** Collateral draining, supply inflation, bypassing compliance  

### 3.2 Privileged Insider
- **Capabilities:** Compromised governance or controller keys  
- **Targets:** Unauthorized minting, censorship, malicious upgrades  

### 3.3 Colluding Entities
- **Capabilities:** Multi-role collusion  
- **Targets:** Value extraction, erosion of trust  

---

## 4. Threat Categories & Mitigations

| Threat Category        | Attack Vector                  | Mitigation |
| ---------------------- | ------------------------------ | ---------- |
| Unauthorized Minting   | Hidden inflation, re-entrancy  | `onlyController`, `security/AOXCReentrancyGuard.sol`, supply/collateral invariant |
| Oracle Manipulation    | Price staleness, flash loan skew | Timestamp checks, deviation thresholds, circuit breakers (`security/AOXCCircuitBreaker.sol`) |
| Governance Abuse       | Flash proposals, hostile takeover | Delay periods, quorum requirements, guardian override (`security/GuardianRegistry.sol`) |
| Upgrade Attacks        | Proxy hijacking, storage collision | `core/AOXCUpgradeAuthorizer.sol`, frozen storage layout |
| Compliance Bypass      | Jurisdictional evasion         | Hooks in `policy/TransferPolicyEngine.sol` |
| Bridge Exploits        | Double-spending, replay attacks | State isolation, rate limiting, replay protection |

---

## 5. Failure Modes

- **Oracle Staleness:** Mint/Redeem functions revert immediately.  
- **Governance Deadlock:** Guardians may trigger a temporary freeze.  
- **Bridge Compromise:** Bridge adapter disconnected; core state remains secure.  

---

## 6. Validation Methods
- **Fuzzing:** Invariant testing on mint/redeem logic  
- **Static Analysis:** No high-severity findings tolerated  
- **Formal Verification:** Proof of collateral ratio correctness  

---

## 7. Residual Risks
- Layer-1 censorship or halts  
- Compiler or library zero-day vulnerabilities  
- Majority governance collusion  

---

*"Security is not assumed; it is continuously engineered."*
