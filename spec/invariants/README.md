# AOXCDAO Invariant Specifications (Mathematical Truths)

## I. Monetary Policy & Solvency
- **Supply-Collateral Parity:** Total AOXC supply ($S$) must always be less than or equal to the total verified collateral ($C$) stored in the `AssetBackingLedger`. ($S \leq C$).
- **Cap Integrity:** `totalSupply()` must never exceed `supplyCap` under any state transition.
- **Burn Consistency:** A burn operation must never result in an underflow or inconsistent ledger state regarding the underlying asset.

## II. Governance & Policy Limits
- **Kinetic Ceiling:** `globalEfficiencyMultiplier` in `ANDROMEDACORE` must strictly stay within the range $[100, 600]$.
- **Sector Isolation:** Only sectors registered in the $[1, 7]$ range can execute privileged logic via `ANDROMEDACORE`.

## III. Security & Observation
- **Forensic Continuity:** Every state-changing transaction in `MintController` or `RedeemController` MUST increment the `MonitoringHub` sequence ID.
- **Emergency Halt:** When `isEmergencyHalt` is TRUE, all non-administrative state transitions must revert.
