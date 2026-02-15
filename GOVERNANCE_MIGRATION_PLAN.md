# 🏛 AOXCDAO Governance Migration Plan
## Target Version: 2.0.0

---

# Objective

Transition authority from centralized role holders to governance-controlled architecture.

---

# Phase 1 — Role Hardening

- Transfer DEFAULT_ADMIN_ROLE to multisig
- Transfer UPGRADER_ROLE to multisig
- Verify MINTER_ROLE boundaries
- Isolate PAUSER_ROLE
- Isolate COMPLIANCE_ROLE

---

# Phase 2 — Governance Deployment

- Deploy Governor contract
- Deploy TimelockController
- Delegate token voting power
- Transfer UPGRADER_ROLE to Timelock
- Transfer DEFAULT_ADMIN_ROLE to Timelock

---

# Phase 3 — Production Confirmation

- Verify role separation
- Confirm upgrade authorization path
- Simulate upgrade through governance
- Lock EOA privileges

---

# Final State

- No EOA retains critical authority
- Upgrades executed via governance
- Treasury governed by DAO
- Emergency powers isolated

---

# ==============================================================================
# Governance is not optional.
# It is the security perimeter.
# ==============================================================================
