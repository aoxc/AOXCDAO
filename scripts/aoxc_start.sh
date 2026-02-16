#!/usr/bin/env bash
# -----------------------------------------------------------------------
# PROJECT  : AOXC DAO FRAMEWORK
# MODULE   : MASTER CONTROL INTERFACE (MCI) - NEURAL CORE INTEGRATED
# VERSION  : 2.1.0-STABLE (Autonomous / Multi-AI Ready)
# IDENTITY : Path-Agnostic / Fair-Access Architecture
# -----------------------------------------------------------------------

set -Eeuo pipefail
IFS=$'\n\t'

# ---- 1. DYNAMIC ROOT DISCOVERY (OTONOM TESPİT) ----
export AOXC_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CURRENT_DIR_NAME=$(basename "$AOXC_ROOT")

if [[ "$CURRENT_DIR_NAME" != "AOXCDAO" ]]; then
    echo -e "\033[38;5;196m[CRITICAL] AUTHORITY VOID: Directory must be named 'AOXCDAO'\033[0m"
    exit 1
fi

export SCRIPTS_DIR="$AOXC_ROOT/scripts"
export VENV_DIR="$AOXC_ROOT/.venv"
export DATA_DIR="$AOXC_ROOT/data"

# ---- 2. COMPONENT REGISTRY (LOCAL & NEURAL INJECTION) ----
ENGINE_LOGGER="$SCRIPTS_DIR/engine_logger.sh"
ENGINE_INTEGRITY="$SCRIPTS_DIR/engine_integrity.sh"
ENGINE_CLI="$SCRIPTS_DIR/engine_cli.sh"
ENGINE_AI="$SCRIPTS_DIR/engine_ai_observer.sh" # AI Gözlem Çekirdeği

# ---- 3. TELEMETRY COLORS ----
C_BLUE='\033[38;5;33m'; C_GOLD='\033[38;5;220m'; C_GREEN='\033[38;5;82m'
C_RED='\033[38;5;196m'; C_PURPLE='\033[38;5;129m'; NC='\033[0m'; V_WHITE='\033[38;5;255m'

# ---- 4. CORE SUBSYSTEM PROCEDURES ----

log_internal() {
    local level=$1; shift
    if [[ -f "$ENGINE_LOGGER" ]]; then
        bash "$ENGINE_LOGGER" "$level" "$*"
    else
        echo -e "${C_BLUE}[$level]${NC} $*"
    fi
}

# [AI_ADJUSTMENT_LAYER] - Adil ve Sınırlı Erişim Protokolü
initialize_neural_bridge() {
    log_internal "INFO" "Syncing Neural Bridge (AI-Equity-Protocol)..."
    if [[ -f "$ENGINE_AI" ]]; then
        # @academic: AI sadece 'READ_ONLY' modda ayağa kalkar. 
        # Yetki genişletmesi ancak DAO Kontrat mühürüyle mümkündür.
        bash "$ENGINE_AI" --onboard-only
        log_internal "SUCCESS" "Neural Core (Observer-Mode) linked. Authority: DAO-Gated."
    else
        log_internal "WARN" "Neural Core offline. System proceeding in classic autonomous mode."
    fi
}

ensure_environment() {
    if [[ ! -d "$VENV_DIR" ]]; then
        log_internal "WARN" "Isolation sandbox missing. Constructing local runtime..."
        python3 -m venv "$VENV_DIR"
        source "$VENV_DIR/bin/activate" || source "$VENV_DIR/Scripts/activate"
        pip install --upgrade pip --quiet 2>/dev/null || true
        log_internal "SUCCESS" "Local runtime stabilized."
    else
        source "$VENV_DIR/bin/activate" || source "$VENV_DIR/Scripts/activate"
    fi
}

verify_registry() {
    chmod +x "$SCRIPTS_DIR"/engine_*.sh 2>/dev/null || true
    log_internal "INFO" "Executing cryptographic integrity heuristics..."
    if [[ -f "$ENGINE_INTEGRITY" ]]; then
        if ! bash "$ENGINE_INTEGRITY" verify > /dev/null 2>&1; then
            log_internal "WARN" "Integrity breach! Re-aligning forensic seals..."
            bash "$ENGINE_INTEGRITY" seal
            log_internal "SUCCESS" "System re-aligned."
        fi
    fi
}

# ---- 5. MASTER EXECUTION PIPELINE ----

main() {
    clear
    echo -e "${C_BLUE}==============================================================${NC}"
    echo -e "   ${C_GOLD}AOXC MASTER ENGINE v2.1.0${NC} | ${C_PURPLE}AI_OBSERVER: ACTIVE${NC}"
    echo -e "   ${V_WHITE}NAMESPACE: $CURRENT_DIR_NAME | EQUITY: MULTI-AI READY${NC}"
    echo -e "${C_BLUE}==============================================================${NC}"

    ensure_environment
    
    # AI Çekirdeğini dürüstlük ve adalet ilkeleriyle bağla
    initialize_neural_bridge
    
    verify_registry

    log_internal "SUCCESS" "All systems synchronized. Transferring to Command Bridge..."
    sleep 1

    if [[ -f "$ENGINE_CLI" ]]; then
        exec bash "$ENGINE_CLI"
    else
        log_internal "FATAL" "Command Bridge (engine_cli.sh) not found!"
        exit 1
    fi
}

main "$@"
