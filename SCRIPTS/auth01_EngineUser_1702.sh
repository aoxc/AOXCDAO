#!/usr/bin/env bash
# -----------------------------------------------------------------------
# AOXC DAO - USER COMPLIANCE & LEGAL SHIELD (v1.1.0-HARDENED)
# -----------------------------------------------------------------------

set -euo pipefail
IFS=$'\n\t'

L_LANG=${1:-TR}
NON_INTERACTIVE=${2:-false}
VERSION="1.1.0"

USER_LOCK="data/registry/.user_accepted"
AUDIT_LOG="data/logs/forensic_audit.log"
LOGGER="./scripts/logger.sh"

require_binary() {
    command -v "$1" >/dev/null 2>&1 || {
        echo "[FATAL] Missing required binary: $1"
        exit 1
    }
}

preflight() {
    if [[ ! -f "$LOGGER" ]]; then
        echo "[FATAL] Logger missing."
        exit 1
    fi

    mkdir -p data/registry
    mkdir -p data/logs
}

preflight
source "$LOGGER"

# -----------------------------------------------------------------------
# LEGAL TEXT MATRIX
# -----------------------------------------------------------------------

declare -A MSG

if [[ "$L_LANG" == "TR" ]]; then
    MSG[header]="AOXC DAO - KURUMSAL KULLANICI SÖZLEŞMESİ (v$VERSION)"
    MSG[p1]="Bu sistem ileri seviye teknik bilgi gerektirir."
    MSG[p2]="Scriptleri çalıştıran operatör tüm teknik sorumluluğu kabul eder."
    MSG[p3]="Geliştiriciler finansal kayıplardan sorumlu değildir."
    MSG[p4]="Core script modifikasyonu bütünlüğü bozar."
    MSG[ask]="'OPERATÖR' sorumluluğunu kabul ediyorum (y/N): "
    MSG[declined]="Sözleşme reddedildi."
else
    MSG[header]="AOXC DAO - ENTERPRISE USER AGREEMENT (v$VERSION)"
    MSG[p1]="Advanced technical knowledge required."
    MSG[p2]="Operator assumes full responsibility."
    MSG[p3]="Developers are not liable for financial loss."
    MSG[p4]="Core script modification breaks integrity."
    MSG[ask]="I accept OPERATOR liability (y/N): "
    MSG[declined]="Agreement declined."
fi

# -----------------------------------------------------------------------
# VERSION CHECK
# -----------------------------------------------------------------------

is_valid_lock() {
    [[ -f "$USER_LOCK" ]] || return 1
    grep -q "USER_ACCEPTED_V${VERSION}_" "$USER_LOCK"
}

write_lock() {
    tmpfile="$(mktemp)"
    printf "USER_ACCEPTED_V%s_ON_%s\n" \
        "$VERSION" "$(date +'%Y-%m-%d_%H:%M:%S')" > "$tmpfile"
    mv "$tmpfile" "$USER_LOCK"
    chmod 444 "$USER_LOCK"
}

log_acceptance() {
    printf "[%s] SIGNAL: LEGAL_ACCEPTANCE - V%s\n" \
        "$(date +'%Y-%m-%d %H:%M:%S')" "$VERSION" \
        >> "$AUDIT_LOG"
}

# -----------------------------------------------------------------------
# GATEWAY
# -----------------------------------------------------------------------

check_user_status() {

    if is_valid_lock; then
        return 0
    fi

    if [[ "$NON_INTERACTIVE" == "true" ]]; then
        echo "[FATAL] Legal acceptance required (non-interactive mode)."
        exit 1
    fi

    echo "------------------------------------------------------------"
    echo "${MSG[header]}"
    echo "------------------------------------------------------------"
    echo "${MSG[p1]}"
    echo "${MSG[p2]}"
    echo "${MSG[p3]}"
    echo "${MSG[p4]}"
    echo ""
    read -r -p "${MSG[ask]}" choice

    if [[ "$choice" =~ ^[Yy]$ ]]; then
        write_lock
        log_acceptance
        log_success "Legal acceptance recorded."
    else
        log_error "${MSG[declined]}"
        exit 1
    fi
}

check_user_status

