# 🔍 AOXCDAO Audit Scope
**Protocol Version: 2.0.0**  
**Architecture Generation: II**  
**Audit Status: Pre-Mainnet Preparation**

---

# 1. Objective

This document defines the technical audit scope for AOXCDAO v2.0.0.

The purpose of the audit is to:

- Identify security vulnerabilities
- Validate upgrade safety
- Verify role isolation
- Confirm treasury protection
- Review governance logic integrity

---

# 2. In-Scope Components

## 2.1 Core Contracts

Located in:

```
src/
```

Including but not limited to:

- Governance core contract
- UUPS upgradeable modules
- Treasury management contract
- Role management logic
- Emergency pause mechanism

All upgradeable contracts must be reviewed for:

- `_authorizeUpgrade()` correctness
- Storage slot integrity
- Inheritance order correctness
- AccessControl enforcement

---

## 2.2 Upgrade Architecture

- UUPS proxy implementation
- Upgrade authorization logic
- Storage layout compatibility
- Version transition handling
- Major vs Minor release constraints

Reference:
- UPGRADE_POLICY.md
- STORAGE_LAYOUT.md
- VERSIONING_POLICY.md

---

## 2.3 Role-Based Access Control

Review:

- Role assignment safety
- Privilege escalation risks
- DEFAULT_ADMIN_ROLE exposure
- GOVERNANCE_ROLE boundaries
- EMERGENCY_ROLE containment

Reference:
- ROLE_MATRIX.md
- GOVERNANCE_CHARTER.md

---

## 2.4 Treasury System

Review:

- Fund custody model
- Transfer authorization flow
- Governance approval enforcement
- Reentrancy protection
- Emergency override absence

---

## 2.5 Emergency Mechanisms

Review:

- Pause functionality
- Scope of pause
- Inability to upgrade during emergency
- State integrity during paused state

---

# 3. Out of Scope

Unless explicitly requested:

- Frontend code
- Off-chain infrastructure
- Sentinel bots
- Monitoring services
- CI/CD pipeline
- Node configuration

---

# 4. Threat Model Focus

Auditors should validate mitigation against:

- Reentrancy
- Upgrade hijacking
- Storage collision
- Role takeover
- Governance manipulation
- Treasury drain attacks
- Initialization front-running

Reference:
- THREAT_MODEL.md
- SECURITY_ASSUMPTIONS.md

---

# 5. Tooling Used Internally

The project uses:

- Foundry
- Slither
- Echidna
- Static analysis pipelines

Audit may include independent verification beyond these tools.

---

# 6. Test Coverage

Auditors should evaluate:

- Unit test completeness
- Invariant testing
- Fuzz testing coverage
- Upgrade simulation tests

Located in:

```
test/
```

---

# 7. Version Discipline

Audit applies to:

- Version: 2.0.0
- Commit hash: (to be specified at audit submission)
- Tag: v2.0.0

Any change after audit invalidates findings.

---

# 8. Reporting Expectations

Audit report should include:

- Critical vulnerabilities
- High severity issues
- Medium/Low findings
- Informational notes
- Gas optimization suggestions
- Upgrade risk assessment

---

# 9. Security Contact

Security disclosures should be reported privately via:

security@aoxcdao.org (placeholder)

Public disclosure only after coordinated resolution.

---

# ==============================================================================
# AOXCDAO SECURITY DECLARATION
# No upgrade without audit.
# No authority without boundary.
# No treasury without governance.
# ==============================================================================

