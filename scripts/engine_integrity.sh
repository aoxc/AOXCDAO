#!/usr/bin/env bash
# ------------------------------------------------------------------
# AOXC DAO - ENGINE INTEGRITY LOCK (v2.1.0 - Hardened)
# ------------------------------------------------------------------

set -euo pipefail
IFS=$'\n\t'

# ---- CONFIG -------------------------------------------------------

BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SCRIPTS_DIR="$BASE_DIR/scripts"
VAULT_DIR="$BASE_DIR/data/registry/.forensic_vault"
SEAL_FILE="$VAULT_DIR/origin.seal"
LOG_FILE="$BASE_DIR/data/logs/forensic_audit.log"

# ---- UI COLORS ----------------------------------------------------

C_RED='\033[38;5;196m'
C_GREEN='\033[38;5;82m'
C_GOLD='\033[38;5;220m'
NC='\033[0m'

# ---- PRE-FLIGHT CHECKS -------------------------------------------

require_binary() {
    if ! command -v "$1" >/dev/null 2>&1; then
        echo -e "${C_RED}[✘] Required binary missing: $1${NC}"
        exit 1
    fi
}

preflight() {
    require_binary sha512sum
    require_binary find
    require_binary sort
    require_binary awk

    if [[ ! -d "$SCRIPTS_DIR" ]]; then
        echo -e "${C_RED}[✘] Scripts directory not found: $SCRIPTS_DIR${NC}"
        exit 1
    fi
}

ensure_directories() {
    mkdir -p "$VAULT_DIR"
    mkdir -p "$(dirname "$LOG_FILE")"
}

# ---- HASH FUNCTION ------------------------------------------------

calculate_hash() {
    find "$SCRIPTS_DIR" -type f ! -name "engine_integrity.sh" -print0 \
    | sort -z \
    | xargs -0 sha512sum \
    | sha512sum \
    | awk '{print $1}'
}

# ---- CREATE SEAL --------------------------------------------------

create_seal() {
    ensure_directories

    local hash
    hash="$(calculate_hash)"

    echo "$hash" > "$SEAL_FILE"
    chmod 444 "$SEAL_FILE"

    # Immutable flag (Linux only)
    if command -v chattr >/dev/null 2>&1; then
        chattr +i "$SEAL_FILE" 2>/dev/null || true
    fi

    echo -e "${C_GREEN}[✔] Integrity Seal Created${NC}"
}

# ---- VERIFY -------------------------------------------------------

verify_integrity() {

    if [[ ! -f "$SEAL_FILE" ]]; then
        echo -e "${C_GOLD}[!] No seal found. Creating initial seal...${NC}"
        create_seal
        return 0
    fi

    local current_hash
    local original_hash

    current_hash="$(calculate_hash)"
    original_hash="$(<"$SEAL_FILE")"

    if [[ "$current_hash" != "$original_hash" ]]; then
        {
            echo "[$(date +'%Y-%m-%d %H:%M:%S')]"
            echo "INTEGRITY_FAIL"
            echo "Original : $original_hash"
            echo "Current  : $current_hash"
            echo "---------------------------------------"
        } >> "$LOG_FILE"

        echo -e "${C_RED}"
        echo "--------------------------------------------------"
        echo "🚨 INTEGRITY VIOLATION DETECTED"
        echo "Original : $original_hash"
        echo "Current  : $current_hash"
        echo "System halted."
        echo "--------------------------------------------------"
        echo -e "${NC}"

        exit 1
    fi

    echo -e "${C_GREEN}🛡 Integrity Verified${NC}"
}

# ---- ENTRY --------------------------------------------------------

main() {
    preflight

    case "${1:-verify}" in
        seal)
            create_seal
            ;;
        verify|*)
            verify_integrity
            ;;
    esac
}

main "$@"

