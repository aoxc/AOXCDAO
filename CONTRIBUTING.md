# 🏛️ AOXCDAO Contribution Guidelines

Welcome to the **AOXCDAO** ecosystem. To maintain our **Pro Ultimate Academic** standards, all contributors must adhere to the following rigorous development protocols.

---

## ⚖️ General Principles
1. **Academic Excellence:** Write code that is self-documenting, modular, and follows the latest security patterns.
2. **Zero-Warning Policy:** Pull Requests (PRs) with compiler warnings, linting errors, or failing static analysis will be automatically rejected.
3. **Institutional Integrity:** No mock data, no "TODO" comments in production-ready branches, and zero reliance on deprecated libraries.

---

## 🛠️ Technical Requirements
- **Compiler:** Solidity `0.8.33` (Mandatory).
- **Libraries:** OpenZeppelin `5.5.x` (Direct imports only; no upgradeable versions unless specified).
- **Tooling:** Foundry is our primary framework for testing and deployment.
- **Linting:** Must pass `solhint` with the AOXCDAO configuration.

---

## 🛡️ Development Workflow
### 1. Security First
Before writing a single line of code, run the institutional security suite:
```bash
# Static Analysis
semgrep --config="p/solidity"
slither .

# Testing
forge test --gas-report
