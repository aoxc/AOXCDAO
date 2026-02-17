# AOXC Protocol Versioning Policy

## 1. Versioning Model

AOXC follows Semantic Versioning (MAJOR.MINOR.PATCH).

- MAJOR: Architectural or breaking storage/layout changes.
- MINOR: Backward-compatible feature additions.
- PATCH: Security fixes, bug corrections, non-breaking improvements.

---

## 2. Major Version Changes

A major version increment (e.g., 2.x.x → 3.0.0) requires:

- Storage compatibility review
- Upgrade safety validation
- Governance approval
- Updated threat model documentation

---

## 3. Minor Version Changes

Minor increments reflect:

- Module additions
- Governance extensions
- Treasury logic upgrades
- Script framework evolution

---

## 4. Patch Releases

Patch versions apply to:

- Bug fixes
- Gas optimizations
- Script corrections
- Security hardening without storage impact

---

## 5. Lifecycle Roadmap

2.0.0 → Architectural Baseline  
2.1.0 → Governance Expansion  
2.2.0 → Treasury Integration  
2.3.0 → Security Hardening  
2.4.0 → Audit Alignment  
2.5.0 → Mainnet Stability Release  

---

## 6. On-Chain Version Standard

All upgradeable contracts MUST expose:

function version() external pure returns (string memory);

Returning the current semantic version.

