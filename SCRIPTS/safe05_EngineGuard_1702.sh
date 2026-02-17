#!/usr/bin/env bash
# -----------------------------------------------------------------------
# AOXC DAO - SCRIPT SECURITY GUARD & LINTER (v2.0.0-STABLE)
# -----------------------------------------------------------------------
# ShellCheck Integrated | Zero-Injection Policy | CI Ready
# -----------------------------------------------------------------------

set -Eeuo pipefail
shopt -s nullglob

LOGGER="./scripts/logger.sh"
L_LANG="${1:-TR}"
GUARD_LOG="data/logs/security_guard.log"
SCRIPTS_DIR="scripts"

mkdir -p "data/logs"

# -----------------------------------------------------------------------
# Dependency Checks
# -----------------------------------------------------------------------

if [[ ! -x "${LOGGER}" ]]; then
    echo "Fatal: Logger missing or not executable."
    exit 1
fi

source "${LOGGER}"

# -----------------------------------------------------------------------
# Localization
# -----------------------------------------------------------------------

declare -A MSG

if [[ "${L_LANG}" == "TR" ]]; then
    MSG[start]="Güvenlik Denetimi Başlatılıyor: ./scripts/*.sh"
    MSG[sc_check]="ShellCheck statik analizi yapılıyor..."
    MSG[inj_check]="Command Injection ve hassas veri taraması yapılıyor..."
    MSG[pass]="DENETİM BAŞARILI: Tüm scriptler güvenli."
    MSG[fail]="KRİTİK UYARI: Güvenlik açığı veya lint hatası tespit edildi!"
else
    MSG[start]="Initiating Security Audit: ./scripts/*.sh"
    MSG[sc_check]="Running ShellCheck static analysis..."
    MSG[inj_check]="Scanning for command injection & sensitive data..."
    MSG[pass]="AUDIT PASSED: All scripts are secure."
    MSG[fail]="CRITICAL: Vulnerabilities or lint errors detected!"
fi

log_info "${MSG[start]}"

# -----------------------------------------------------------------------
# 1. ShellCheck Audit
# -----------------------------------------------------------------------

audit_lint() {
    log_info "${MSG[sc_check]}"

    if ! command -v shellcheck >/dev/null 2>&1; then
        log_warn "ShellCheck not installed. Skipping lint stage."
        return 0
    fi

    local failed=0
    for sh_file in "${SCRIPTS_DIR}"/*.sh; do
        if ! shellcheck -s bash -o all -e SC1091 "${sh_file}" >/dev/null; then
            log_error "Lint fail: ${sh_file}"
            failed=1
        fi
    done

    return "${failed}"
}

# -----------------------------------------------------------------------
# 2. Malicious Pattern Scan
# -----------------------------------------------------------------------

audit_patterns() {
    log_info "${MSG[inj_check]}"

    local risks=(
        'base64[[:space:]]+-d'
        'base64[[:space:]]+--decode'
        'curl.*\|.*bash'
        'wget.*\|.*bash'
        'rm[[:space:]]+-rf[[:space:]]+/'
        'PRIVATE[[:space:]_]?KEY'
        'eval[[:space:]]'
        '\$\(.+\)'
    )

    local failed=0

    for pattern in "${risks[@]}"; do
        if grep -RInE "${pattern}" "${SCRIPTS_DIR}" \
            --exclude="engine_guard.sh" \
            --exclude-dir="logs" \
            >/dev/null 2>&1
        then
            log_error "Risky pattern detected: ${pattern}"
            failed=1
        fi
    done

    return "${failed}"
}

# -----------------------------------------------------------------------
# Execution
# -----------------------------------------------------------------------

if audit_lint && audit_patterns; then
    log_success "${MSG[pass]}"
    echo "$(date '+%Y-%m-%d %H:%M:%S') - SUCCESS - Scripts cleared." >> "${GUARD_LOG}"
else
    log_error "${MSG[fail]}"
    echo "$(date '+%Y-%m-%d %H:%M:%S') - FAILURE - Violations found." >> "${GUARD_LOG}"
    exit 1
fi

