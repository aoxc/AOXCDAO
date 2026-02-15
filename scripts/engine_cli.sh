#!/usr/bin/env bash
# -----------------------------------------------------------------------
# AOXC DAO - PRO ELITE COMMAND CENTER
# Version: 7.1.0 (Hardened / Shellcheck Clean)
# -----------------------------------------------------------------------

set -Eeuo pipefail
IFS=$'\n\t'

trap 'echo -e "\n[!] Use \"exit\" or \"q\" to shutdown."; exit 1' SIGINT

VENV_DIR=".venv"

if [[ ! -d "$VENV_DIR" ]]; then
    echo "CRITICAL: VENV Not Found!"
    exit 1
fi

# shellcheck disable=SC1091
source "$VENV_DIR/bin/activate"

LOGGER="./scripts/logger.sh"
if [[ ! -f "$LOGGER" ]]; then
    echo "Fatal Error: logger.sh not found."
    exit 1
fi
source "$LOGGER"

# --------------------------------------------------
# Colors
# --------------------------------------------------
V_CYAN='\033[38;5;51m'
V_BLUE='\033[38;5;33m'
V_GREEN='\033[38;5;82m'
V_GOLD='\033[38;5;220m'
V_RED='\033[38;5;196m'
V_GREY='\033[38;5;244m'
V_WHITE='\033[38;5;255m'
NC='\033[0m'

DATA_DIR="data/notes"
REG_DIR="data/registry"

mkdir -p "$DATA_DIR" "$REG_DIR"

# --------------------------------------------------
# Language Selection
# --------------------------------------------------
initialize_system() {
    clear
    echo -e "${V_BLUE}AOXC OPERATIONAL INTERFACE${NC}"
    echo -e "${V_CYAN}[1] TR | [2] EN${NC}"
    read -r -n 1 selection
    echo
    if [[ "$selection" == "2" ]]; then
        AOXC_LANG="EN"
    else
        AOXC_LANG="TR"
    fi
    export AOXC_LANG
}

# --------------------------------------------------
# Telemetry
# --------------------------------------------------
get_telemetry() {
    FILE_COUNT="$(find src -name "*.sol" 2>/dev/null | wc -l || echo 0)"
    SEC_COUNT="$(find src/security -name "*.sol" 2>/dev/null | wc -l || echo 0)"
    TIME_NOW="$(date +'%H:%M:%S')"

    if [[ -f "$DATA_DIR/history.md" ]]; then
        LAST_LOG="$(tail -n 1 "$DATA_DIR/history.md" | cut -c 1-80)"
    else
        LAST_LOG="Registry Empty"
    fi
}

# --------------------------------------------------
# Memory Log
# --------------------------------------------------
log_action() {
    local action="$1"
    local status="$2"
    echo "- [$(date +'%Y-%m-%d %H:%M:%S')] ACTION: $action | STATUS: $status | SRC: $FILE_COUNT" \
        >> "$DATA_DIR/history.md"
}

# --------------------------------------------------
# Safe Command Executor
# --------------------------------------------------
run_and_log() {
    local label="$1"
    shift

    if "$@"; then
        log_action "$label" "OK"
    else
        log_action "$label" "FAIL"
    fi
}

# --------------------------------------------------
# UI
# --------------------------------------------------
draw_ui() {
    get_telemetry
    clear

    echo -e "${V_BLUE}══════════════════════════════════════════════${NC}"
    echo -e "${V_CYAN}AOXC OS v7.1.0${NC}  ${V_WHITE}TIME:${NC} ${V_GREY}$TIME_NOW${NC}"
    echo -e "${V_GREY}SRC:${FILE_COUNT}  SEC:${SEC_COUNT}${NC}"
    echo -e "${V_GOLD}MEM:${NC} ${LAST_LOG}"
    echo -e "${V_BLUE}══════════════════════════════════════════════${NC}"
}

# --------------------------------------------------
# Main Loop
# --------------------------------------------------
initialize_system

while true; do
    draw_ui

    printf "${V_BLUE}@AOXC[%s]» ${NC}" "$AOXC_LANG"
    read -r cmd

    case "${cmd,,}" in
        build)
            run_and_log "BUILD" ./scripts/engine_forge.sh build "$AOXC_LANG"
            sleep 2
            ;;
        test)
            run_and_log "TEST" ./scripts/engine_forge.sh test "$AOXC_LANG"
            sleep 2
            ;;
        security)
            run_and_log "SECURITY" ./scripts/engine_audit.sh "$AOXC_LANG"
            sleep 2
            ;;
        gas)
            run_and_log "GAS" ./scripts/engine_gas.sh "$AOXC_LANG"
            sleep 2
            ;;
        formal)
            run_and_log "FORMAL" ./scripts/engine_halmos.sh "$AOXC_LANG"
            sleep 2
            ;;
        disasm)
            run_and_log "ASM" ./scripts/engine_asm.sh "$AOXC_LANG"
            sleep 2
            ;;
        docs)
            run_and_log "DOCS" ./scripts/engine_docs.sh build "$AOXC_LANG"
            sleep 2
            ;;
        deploy)
            run_and_log "DEPLOY" ./scripts/engine_deploy.sh testnet "$AOXC_LANG"
            sleep 2
            ;;
        c|clear)
            clear
            ;;
        q|exit|quit)
            log_action "SHUTDOWN" "CLEAN"
            echo -e "${V_RED}SYSTEM OFFLINE${NC}"
            exit 0
            ;;
        "")
            continue
            ;;
        *)
            echo -e "${V_RED}Invalid Command${NC}"
            sleep 1
            ;;
    esac
done

