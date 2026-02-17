#!/bin/bash
# -----------------------------------------------------------------------
# AOXC DAO - PRO ULTIMATE MASTER DATA ORCHESTRATOR (v6.8.2)
# -----------------------------------------------------------------------
# [Standard: 0.8.33] [Role: Central Data & Logic Hub]
# [Integrated Engines: Forge, Audit, Gas, Fuzz, Formal, Deploy]
# -----------------------------------------------------------------------

set -e
VENV_DIR=".venv"
[ -d "$VENV_DIR" ] && source "$VENV_DIR/bin/activate" || { echo "CRITICAL: VENV Not Found!"; exit 1; }

L_LANG=${1:-TR}
DATA_DIR="data/notes"
REG_DIR="data/registry"
mkdir -p $DATA_DIR $REG_DIR

# 📊 System Telemetry Extraction
FILE_COUNT=$(find src -name "*.sol" 2>/dev/null | wc -l)
SEC_COUNT=$(find src/security -name "*.sol" 2>/dev/null | wc -l)
LAST_LOG=$(tail -n 1 "$DATA_DIR/history.md" 2>/dev/null | cut -c 25-80 || echo "No History Recorded")
TIME_NOW=$(date +'%H:%M:%S')

# 🎨 Palette
V_CYAN='\033[38;5;51m'; V_BLUE='\033[38;5;33m'; V_GREEN='\033[38;5;82m'
V_GOLD='\033[38;5;220m'; V_RED='\033[38;5;196m'; V_GREY='\033[38;5;244m'
V_WHITE='\033[38;5;255m'; NC='\033[0m'

# 🌐 Localization Matrix
declare -A MSG
if [ "$L_LANG" == "TR" ]; then
    H_STATUS="DATA_HUB: ÇEVRİMİÇİ"
    MSG_CMD="MASTER_COMMAND [build/test/security/gas/fuzz/formal/deploy/exit]: "
    L_LAST="SON KAYIT"
    MSG[build]="Build & Metadata Sync"
    MSG[test]="Test Suite Execution"
    MSG[security]="Slither Forensic Audit"
    MSG[gas]="Gas Analysis"
    MSG[fuzz]="Echidna Chaos Testing"
    MSG[formal]="Halmos Formal Proof"
    MSG[deploy]="X-Layer Deployment"
else
    H_STATUS="DATA_HUB: ONLINE"
    MSG_CMD="MASTER_COMMAND [build/test/security/gas/fuzz/formal/deploy/exit]: "
    L_LAST="LAST LOG"
    MSG[build]="Build & Metadata Sync"
    MSG[test]="Test Suite Execution"
    MSG[security]="Slither Forensic Audit"
    MSG[gas]="Gas Analysis"
    MSG[fuzz]="Echidna Chaos Testing"
    MSG[formal]="Halmos Formal Proof"
    MSG[deploy]="X-Layer Deployment"
fi

log_action() {
    echo "- [$(date +'%Y-%m-%d %H:%M:%S')] ACTION: $1 | STATUS: $2 | SRC: $FILE_COUNT" >> "$DATA_DIR/history.md"
}

draw_ui() {
    clear
    echo -e "${V_BLUE}🌀«««─────────────────────────────────────────────────────────────────»»»🌀${NC}"
    echo -e "${V_BLUE}║${NC}  ${V_CYAN}AOXC MASTER DATA HUB${NC} ${V_GREY}v6.8.2${NC} ${V_BLUE}»»»${NC}  ${V_WHITE}$H_STATUS${NC}  ${V_BLUE}«««${NC}  ${V_WHITE}T:${NC} ${V_GREY}$TIME_NOW${NC}  ${V_BLUE}║${NC}"
    echo -e "${V_BLUE}╟─────────────────────────────────────────────────────────────────────╢${NC}"
    echo -e "  ${V_GREY}📊 HUB_METRICS »»»${NC} [${V_WHITE}SRC:${NC} ${V_GREEN}$FILE_COUNT${NC}] [${V_WHITE}SEC:${NC} ${V_GREEN}$SEC_COUNT${NC}] [${V_WHITE}HUB:${NC} ${V_GREEN}SYNCED${NC}]"
    echo -e "  ${V_GREY}🧠 $L_LAST »»»${NC} ${V_GOLD}$LAST_LOG${NC}"
    echo -e "${V_BLUE}╟─────────────────────────────────────────────────────────────────────╢${NC}"
    # Master Menu Options
    printf "  ${V_GREEN}%-10s${NC} ${V_WHITE}%-25s${NC} | ${V_RED}%-10s${NC} ${V_WHITE}%-25s${NC}\n" "build" "${MSG[build]}" "fuzz" "${MSG[fuzz]}"
    printf "  ${V_GREEN}%-10s${NC} ${V_WHITE}%-25s${NC} | ${V_RED}%-10s${NC} ${V_WHITE}%-25s${NC}\n" "test" "${MSG[test]}" "formal" "${MSG[formal]}"
    printf "  ${V_GREEN}%-10s${NC} ${V_WHITE}%-25s${NC} | ${V_GOLD}%-10s${NC} ${V_WHITE}%-25s${NC}\n" "security" "${MSG[security]}" "deploy" "${MSG[deploy]}"
    printf "  ${V_GREEN}%-10s${NC} ${V_WHITE}%-25s${NC} | ${V_GREY}%-10s${NC} ${V_WHITE}%-25s${NC}\n" "gas" "${MSG[gas]}" "exit" "Shutdown Hub"
    echo -e "${V_BLUE}╟─────────────────────────────────────────────────────────────────────╢${NC}"
}

while true; do
    draw_ui
    echo -ne "\n${V_GOLD}  [#] $MSG_CMD ${NC}"
    read USER_CMD
    case $USER_CMD in
        "build") ./scripts/engine_forge.sh build $L_LANG && log_action "BUILD" "OK" || log_action "BUILD" "FAIL"; sleep 2 ;;
        "test") ./scripts/engine_forge.sh test $L_LANG && log_action "TEST" "OK" || log_action "TEST" "FAIL"; sleep 2 ;;
        "security") ./scripts/engine_audit.sh $L_LANG && log_action "AUDIT" "OK" || log_action "AUDIT" "FAIL"; sleep 2 ;;
        "gas") ./scripts/engine_gas.sh $L_LANG && log_action "GAS" "OK" || log_action "GAS" "FAIL"; sleep 2 ;;
        "fuzz") ./scripts/engine_fuzz.sh $L_LANG && log_action "FUZZ" "OK" || log_action "FUZZ" "FAIL"; sleep 2 ;;
        "formal") ./scripts/engine_halmos.sh $L_LANG && log_action "FORMAL" "OK" || log_action "FORMAL" "FAIL"; sleep 2 ;;
        "deploy") ./scripts/engine_deploy.sh testnet $L_LANG && log_action "DEPLOY" "OK" || log_action "DEPLOY" "FAIL"; sleep 2 ;;
        "exit") log_action "HUB_SHUTDOWN" "CLEAN"; exit 0 ;;
        *) echo -e "${V_RED}Invalid Command!${NC}"; sleep 1 ;;
    esac
done
