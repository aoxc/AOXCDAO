# Security Policy

## Supported Versions

The following table outlines which versions of AOXCDAO are actively maintained with security updates. Versions not listed as supported should be considered deprecated and may contain unresolved vulnerabilities.

| Version | Supported          |
| ------- | ------------------ |
| 0.1.x   | ✅                 |
| < 0.1   | ❌                 |

> **Note:** AOXCDAO is currently in its *Level 1 – Construction Phase*. While security updates are provided for the latest release, the project is not yet recommended for production-critical deployments.

---

## Reporting a Vulnerability

We take the security of AOXCDAO seriously and appreciate responsible disclosure of potential vulnerabilities. If you discover a security issue, please follow the process below:

1. **Private Disclosure**  
   - Submit a report via [GitHub Issues](https://github.com/aoxc/AOXCDAO/issues) using the **Security** label.  
   - For critical vulnerabilities, please contact the repository owner directly ([@aoxc](https://github.com/aoxc)) to avoid public exposure before mitigation.

2. **Response Timeline**  
   - Initial acknowledgment will be provided within **72 hours** of receiving the report.  
   - A preliminary assessment and mitigation plan will be shared within **7 business days**.  
   - Security patches will be prioritized and released as soon as feasible, depending on severity.

3. **Outcome**  
   - Accepted vulnerabilities will be documented in the changelog and patched in the next release.  
   - Declined reports will include a clear rationale to ensure transparency.  
   - Contributors who responsibly disclose severe vulnerabilities may be credited in release notes, unless anonymity is requested.

---

## Security Principles

AOXCDAO adheres to the following guiding principles:

- **Transparency:** All confirmed vulnerabilities and their fixes will be publicly documented.  
- **Minimal Exposure:** Sensitive information should never be disclosed in public issue threads.  
- **Continuous Improvement:** Security assumptions and threat models are regularly updated in supporting documents (`SECURITY_ASSUMPTIONS.md`, `THREAT_MODEL.md`, `EMERGENCY_PLAYBOOK.md`).  

---

## Additional Resources

- [Threat Model](./THREAT_MODEL.md)  
- [Security Assumptions](./SECURITY_ASSUMPTIONS.md)  
- [Emergency Playbook](./EMERGENCY_PLAYBOOK.md)  

---

Maintaining security is a collaborative effort. We encourage all contributors and users to remain vigilant and proactive in identifying and reporting potential risks.
