# AOXCDAO Functional Properties (Logic Expectations)

## I. Access Control & Roles
- **Veto Dominance:** Only the `VETO_ROLE` holder can transition the protocol to `EMERGENCY_PAUSE` state.
- **Minter Exclusivity:** Only authorized `MintController` addresses can call `AOXC.mint()`.

## II. Compliance & Transfer Policy
- **Jurisdiction Enforcement:** If `policyEnforcementActive` is TRUE, transfers to addresses in the `JurisdictionRegistry` marked as "Blacklisted" must fail.
- **SBT Validation:** Voting power multiplier derived from `calculateKineticVotes` must only apply to holders of `AOXCHonorSBT`.

## III. Execution Logic
- **Fabrication Authenticity:** `VIRGO_FABRICATOR` must verify the underlying asset's proof-of-reserve before signaling the `MintController`.
- **Atomic Redemptions:** A redemption must atomically burn AOXC and release the corresponding asset from the `Ledger`.
