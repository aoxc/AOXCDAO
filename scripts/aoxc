#!/usr/bin/env bash
# -----------------------------------------------------------------------
# PROJECT  : AOXC DAO FRAMEWORK
# MODULE   : MASTER KERNEL (THE SENTINEL)
# VERSION  : 2.0.0-STABLE
# AUTHORITY: AUTONOMOUS SYSTEM ARCHITECT
# -----------------------------------------------------------------------

set -Eeuo pipefail
IFS=$'\n\t'

# ---- 1. GLOBAL CONTEXT RESOLUTION ----
export AOXC_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
export SCRIPTS_DIR="$AOXC_ROOT/scripts"
export DATA_DIR="$AOXC_ROOT/data"
export LOG_FILE="$DATA_DIR/logs/kernel_forensic.log"

# Çeviri Katmanını Entegre Et
if [[ -f "$SCRIPTS_DIR/engine_translator.sh" ]]; then
    source "$SCRIPTS_DIR/engine_translator.sh"
else
    printf "\033[38;5;196m[FATAL] Translator Layer Missing. System Aborting.\033[0m\n"
    exit 1
fi

# ---- 2. FORENSIC TELEMETRY & ERROR TRAPPING ----
mkdir -p "$(dirname "$LOG_FILE")"

log_telemetry() {
    local level=$1; shift
    printf "[%s] [%-8s] %s\n" "$(date +'%Y-%m-%d %H:%M:%S')" "$level" "$*" >> "$LOG_FILE"
}

# Gelişmiş Hata Yakalama (Post-Mortem Analysis)
handle_termination() {
    local exit_code=$?
    local line_no=$1
    if [[ $exit_code -ne 0 ]]; then
        printf "\n\033[38;5;196m┌──[ FORENSIC BREACH DETECTED ]──────────────────────────────┐\033[0m\n"
        printf "\033[38;5;196m│\033[0m EXIT_CODE : %s\n" "$exit_code"
        printf "\033[38;5;196m│\033[0m LINE_NO   : %s\n" "$line_no"
        printf "\033[38;5;196m│\033[0m RUNTIME   : %s\n" "$AOXC_OS"
        printf "\033[38;5;196m└─────────────────────────────────────────────────────────────┘\033[0m\n"
        log_telemetry "CRITICAL" "Execution failed at line $line_no with status $exit_code"
    fi
}
trap 'handle_termination $LINENO' ERR

# ---- 3. RUNTIME VALIDATION & STABILIZATION ----
orchestrate_runtime() {
    log_telemetry "INFO" "Stabilizing environment for $AOXC_OS..."
    
    local venv_path
    venv_path=$(resolve_venv_path)
    
    if [[ ! -f "$venv_path" ]]; then
        log_telemetry "WARN" "Virtual environment void. Reconstructing..."
        python3 -m venv "$AOXC_ROOT/.venv"
    fi
    
    # shellcheck disable=SC1090
    source "$venv_path"
}

# ---- 4. MISSION DISPATCH ----
main() {
    log_telemetry "INFO" "AOXC Genesis sequence initiated."
    
    orchestrate_runtime
    
    printf "\033[38;5;82m[✔] AOXC Kernel v2.0.0 Active | Node: %s | OS: %s\033[0m\n" "$(hostname)" "$AOXC_OS"
    
    # Bridge Handshake
    if [[ -f "$SCRIPTS_DIR/engine_cli.sh" ]]; then
        chmod +x "$SCRIPTS_DIR/engine_cli.sh"
        exec bash "$SCRIPTS_DIR/engine_cli.sh"
    else
        log_telemetry "FATAL" "Command Bridge interface missing."
        exit 1
    fi
}

main "$@"
