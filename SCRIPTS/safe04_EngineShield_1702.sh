#!/usr/bin/env bash
# -----------------------------------------------------------------------
# AOXC DAO - SENTINEL INTEGRITY SYSTEM (v3.1.0-HARDENED)
# -----------------------------------------------------------------------

set -euo pipefail
IFS=$'\n\t'

SCRIPTS_DIR="scripts"
REGISTRY_DIR="data/registry"
MANIFEST="$REGISTRY_DIR/integrity.manifest"
ROOT_SEAL="$REGISTRY_DIR/.root_seal"
AUDIT_LOG="data/logs/forensic_audit.log"

C_CYAN='\033[38;5;51m'
C_GOLD='\033[38;5;220m'
C_RED='\033[38;5;196m'
C_GREEN='\033[38;5;82m'
C_GREY='\033[38;5;244m'
NC='\033[0m'

require_binary() {
    command -v "$1" >/dev/null 2>&1 || {
        echo "[FATAL] Missing required binary: $1"
        exit 1
    }
}

preflight() {
    require_binary sha512sum
    require_binary find
    require_binary sort
    require_binary date

    if [[ ! -d "$SCRIPTS_DIR" ]]; then
        echo "[FATAL] scripts directory not found."
        exit 1
    fi

    mkdir -p "$REGISTRY_DIR"
    mkdir -p "$(dirname "$AUDIT_LOG")"
}

log_forensic() {
    printf "[%s] [SIGNAL: %s] - %s\n" \
        "$(date +'%Y-%m-%d %H:%M:%S')" "$1" "$2" \
        >> "$AUDIT_LOG"
}

# -----------------------------------------------------------------------
# SEAL SYSTEM
# -----------------------------------------------------------------------

seal_system() {

    echo -e "${C_CYAN}🌀 AOXC SENTINEL: Seal operation started...${NC}"

    tmp_manifest="$(mktemp)"

    # Deterministic ordering
    find "$SCRIPTS_DIR" -type f -name "*.sh" ! -name "$(basename "$0")" -print0 \
        | sort -z \
        | xargs -0 sha512sum \
        > "$tmp_manifest"

    mv "$tmp_manifest" "$MANIFEST"

    sha512sum "$MANIFEST" | awk '{print $1}' > "$ROOT_SEAL"

    chmod 444 "$MANIFEST" "$ROOT_SEAL"

    # Immutable (Linux only)
    if command -v chattr >/dev/null 2>&1; then
        chattr +i "$MANIFEST" "$ROOT_SEAL" 2>/dev/null || true
    fi

    log_forensic "SEAL" "Scripts sealed with deterministic SHA-512 manifest."

    echo -e "${C_GREEN}[✔] System sealed. Forensic monitoring active.${NC}"
}

# -----------------------------------------------------------------------
# AUDIT SYSTEM
# -----------------------------------------------------------------------

audit_system() {

    if [[ ! -f "$MANIFEST" || ! -f "$ROOT_SEAL" ]]; then
        echo -e "${C_GOLD}[!] No manifest found. Creating baseline seal...${NC}"
        seal_system
        return 0
    fi

    current_root_hash="$(sha512sum "$MANIFEST" | awk '{print $1}')"
    stored_root_hash="$(<"$ROOT_SEAL")"

    if [[ "$current_root_hash" != "$stored_root_hash" ]]; then
        echo -e "${C_RED}🆘 CRITICAL: Manifest integrity compromised!${NC}"
        log_forensic "VIOLATION" "Root seal mismatch."
        exit 1
    fi

    if sha512sum -c "$MANIFEST" --status 2>/dev/null; then
        echo -e "${C_GREEN}🛡 INTEGRITY VERIFIED (AOXC Sentinel)${NC}"
    else
        echo -e "${C_RED}⚠ Scripts modified from sealed baseline!${NC}"
        log_forensic "MODIFIED" "Script content differs from manifest."
        exit 1
    fi
}

# -----------------------------------------------------------------------
# ENTRY
# -----------------------------------------------------------------------

preflight

case "${1:-audit}" in
    seal) seal_system ;;
    audit) audit_system ;;
    *)
        echo "Usage: $0 {seal|audit}"
        exit 1
        ;;
esac

