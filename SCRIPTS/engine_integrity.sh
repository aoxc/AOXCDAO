#!/usr/bin/env bash
# ------------------------------------------------------------------
# AOXC DAO - ENGINE INTEGRITY LOCK (v2.0.0 - Advanced Technician)
# ------------------------------------------------------------------

set -euo pipefail
IFS=$'\n\t'

# ---- CONFIG -------------------------------------------------------
BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SCRIPTS_DIR="$BASE_DIR/scripts"
VAULT_DIR="$BASE_DIR/data/registry/.forensic_vault"
SEAL_FILE="$VAULT_DIR/origin.seal"
MANIFEST_DB="$VAULT_DIR/manifest.db"
LOG_FILE="$BASE_DIR/data/logs/forensic_audit.log"

# ---- UI COLORS ----------------------------------------------------
C_RED='\033[38;5;196m'
C_GREEN='\033[38;5;82m'
C_GOLD='\033[38;5;220m'
C_BLUE='\033[38;5;39m'
NC='\033[0m'

# ---- TOOLS CHECK -------------------------------------------------
preflight() {
    for tool in sha512sum find sort awk diff; do
        if ! command -v "$tool" >/dev/null 2>&1; then
            echo -e "${C_RED}[✘] Required binary missing: $tool${NC}"; exit 1
        fi
    done
}

# ---- CORE LOGIC (Usta Dokunuşu) ----------------------------------

# Hangi dosyanın değiştiğini şak diye bulur
identify_culprit() {
    if [[ -f "$MANIFEST_DB" ]]; then
        echo -e "${C_BLUE}[*] Investigating script integrity...${NC}"
        find "$SCRIPTS_DIR" -type f ! -name "engine_integrity.sh" -exec sha512sum {} + | sort > "$MANIFEST_DB.current"
        
        echo -e "${C_GOLD}--- DEĞİŞEN DOSYALAR / CHANGED FILES ---${NC}"
        diff --color=always "$MANIFEST_DB" "$MANIFEST_DB.current" | grep "^[<>]" || echo "No granular diff found."
        rm -f "$MANIFEST_DB.current"
    fi
}

calculate_full_state() {
    # 1. Tüm dosyaları tek tek listele ve hashle (Veritabanı oluştur)
    find "$SCRIPTS_DIR" -type f ! -name "engine_integrity.sh" -print0 \
    | xargs -0 sha512sum \
    | sort > "$MANIFEST_DB.tmp"
    
    # 2. Bu listeden ana sistem mührünü (Seal) üret
    sha512sum "$MANIFEST_DB.tmp" | awk '{print $1}'
}

# ---- ACTIONS ------------------------------------------------------

create_seal() {
    mkdir -p "$VAULT_DIR" "$(dirname "$LOG_FILE")"
    
    # Kilit açma (v2 usta manevrası)
    if [[ -f "$SEAL_FILE" ]]; then
        sudo chattr -i "$SEAL_FILE" 2>/dev/null || true
        chmod 644 "$SEAL_FILE"
    fi

    local hash
    hash="$(calculate_full_state)"
    
    # Atomik kayıt
    mv "$MANIFEST_DB.tmp" "$MANIFEST_DB"
    echo "$hash" > "$SEAL_FILE.tmp"
    mv "$SEAL_FILE.tmp" "$SEAL_FILE"
    
    # Yeniden kilitle
    chmod 444 "$SEAL_FILE"
    # sudo chattr +i "$SEAL_FILE" 2>/dev/null || true # Opsiyonel: Çok sert koruma
    
    echo -e "${C_GREEN}[✔] System Sealed at v2.0.0${NC}"
    echo "[$(date)] SEAL_UPDATED: $hash" >> "$LOG_FILE"
}

verify_integrity() {
    if [[ ! -f "$SEAL_FILE" ]]; then
        echo -e "${C_GOLD}[!] No seal found. Initializing v2.0.0...${NC}"
        create_seal
        return 0
    fi

    local current_hash
    local original_hash
    current_hash="$(calculate_full_state)"
    original_hash="$(cat "$SEAL_FILE")"

    if [[ "$current_hash" != "$original_hash" ]]; then
        echo -e "${C_RED}🚨 INTEGRITY VIOLATION DETECTED!${NC}"
        identify_culprit
        
        {
            echo "--- BREACH @ $(date) ---"
            echo "Expected: $original_hash"
            echo "Received: $current_hash"
        } >> "$LOG_FILE"
        
        echo -e "${C_RED}--------------------------------------------------${NC}"
        echo -e "System halted. Run 'make seal' if these changes are intentional."
        exit 1
    fi

    echo -e "${C_GREEN}🛡 Integrity Verified${NC}"
}

# ---- ENTRY --------------------------------------------------------

main() {
    preflight
    case "${1:-verify}" in
        seal) create_seal ;;
        *)    verify_integrity ;;
    esac
}

main "$@"
