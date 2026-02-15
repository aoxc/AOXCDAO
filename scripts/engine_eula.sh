#!/usr/bin/env bash
# -----------------------------------------------------------------------
# AOXC DAO - ENTERPRISE EULA GATEWAY (Forensic + Telemetry Edition)
# Version: 2.0.0-ENTERPRISE
# Standard: ISO/IEC 27001 Readiness
# Logging: Forensic-Grade Immutable Acceptance
# -----------------------------------------------------------------------

set -Eeuo pipefail

# -----------------------------------------------------------------------
# Dependencies
# -----------------------------------------------------------------------
if [[ -f "./scripts/logger.sh" ]]; then
    # shellcheck disable=SC1091
    source ./scripts/logger.sh
else
    echo "Fatal: logger.sh not found."
    exit 1
fi

# -----------------------------------------------------------------------
# Configuration
# -----------------------------------------------------------------------
VERSION="2.0.0"
EULA_VERSION_HASH="AOXC_EULA_V${VERSION}"
DATA_DIR="data"
REGISTRY_DIR="${DATA_DIR}/registry"
LOG_DIR="${DATA_DIR}/logs"
LOCK_FILE="${REGISTRY_DIR}/.eula_acceptance.lock"
FORENSIC_LOG="${LOG_DIR}/forensic_audit.log"

mkdir -p "${REGISTRY_DIR}" "${LOG_DIR}"

# -----------------------------------------------------------------------
# System Fingerprint
# -----------------------------------------------------------------------
USER_NAME="$(whoami)"
USER_ID="$(id -u)"
HOST_NAME="$(hostname)"
SHELL_TYPE="${SHELL:-unknown}"
TIMESTAMP="$(date -u +'%Y-%m-%dT%H:%M:%SZ')"
LOCAL_IP="$(hostname -I 2>/dev/null | awk '{print $1}')"

SYSTEM_FINGERPRINT="${USER_NAME}|${USER_ID}|${HOST_NAME}|${SHELL_TYPE}|${LOCAL_IP}|${TIMESTAMP}|${EULA_VERSION_HASH}"
ACCEPTANCE_HASH="$(printf "%s" "${SYSTEM_FINGERPRINT}" | sha256sum | awk '{print $1}')"

# -----------------------------------------------------------------------
# Academic Enterprise EULA
# -----------------------------------------------------------------------
print_eula() {
    clear
    echo "═══════════════════════════════════════════════════════════════════════"
    echo "AOXC DAO - ENTERPRISE END USER LICENSE AGREEMENT (EULA)"
    echo "Version ${VERSION}"
    echo "ISO/IEC 27001 Readiness | Forensic Logging Enabled"
    echo "═══════════════════════════════════════════════════════════════════════"
    echo
    echo "1. TECHNICAL QUALIFICATION REQUIREMENT"
    echo "This infrastructure is intended exclusively for operators possessing"
    echo "advanced proficiency in Solidity, EVM architecture, and Unix-based"
    echo "systems. Improper usage may result in irreversible financial loss."
    echo
    echo "2. ASSUMPTION OF RISK AND LIABILITY"
    echo "By executing any script within this repository, the Operator assumes"
    echo "full legal and financial responsibility for all outcomes, including"
    echo "software defects, exploits, misconfigurations, and network failures."
    echo
    echo "3. LIMITATION OF LIABILITY"
    echo "AOXC DAO contributors and maintainers shall not be held liable for"
    echo "any direct, indirect, incidental, or consequential damages."
    echo
    echo "4. INTEGRITY CLAUSE"
    echo "Modification of core infrastructure files (scripts/*.sh) may"
    echo "invalidate operational guarantees and void system integrity."
    echo
    echo "5. NO WARRANTY"
    echo "This software is provided 'AS IS' without warranties of any kind."
    echo
    echo "═══════════════════════════════════════════════════════════════════════"
    echo
}

# -----------------------------------------------------------------------
# Telemetry Payload (Local Only - Extendable)
# -----------------------------------------------------------------------
generate_telemetry_payload() {
    cat <<EOF
{
  "event": "EULA_ACCEPTANCE",
  "version": "${VERSION}",
  "timestamp": "${TIMESTAMP}",
  "user": "${USER_NAME}",
  "uid": "${USER_ID}",
  "host": "${HOST_NAME}",
  "shell": "${SHELL_TYPE}",
  "ip": "${LOCAL_IP}",
  "fingerprint_hash": "${ACCEPTANCE_HASH}"
}
EOF
}

# -----------------------------------------------------------------------
# Acceptance Flow
# -----------------------------------------------------------------------
check_eula() {

    if [[ -f "${LOCK_FILE}" ]]; then
        return 0
    fi

    print_eula

    read -rp "I confirm that I have read and accept full OPERATOR liability (y/N): " choice

    if [[ "${choice}" =~ ^[Yy]$ ]]; then

        echo "ACCEPTED:${ACCEPTANCE_HASH}" > "${LOCK_FILE}"
        chmod 600 "${LOCK_FILE}"

        printf "[%s] EULA_ACCEPTED | HASH:%s | USER:%s | HOST:%s\n" \
            "${TIMESTAMP}" "${ACCEPTANCE_HASH}" "${USER_NAME}" "${HOST_NAME}" \
            >> "${FORENSIC_LOG}"

        TELEMETRY_JSON="$(generate_telemetry_payload)"

        printf "%s\n" "${TELEMETRY_JSON}" >> "${LOG_DIR}/telemetry_events.log"

        log_success "EULA accepted. Operator liability activated."
        sleep 1

    else
        log_error "Agreement not accepted. Execution terminated."
        exit 1
    fi
}

# -----------------------------------------------------------------------
# Execute
# -----------------------------------------------------------------------
check_eula

