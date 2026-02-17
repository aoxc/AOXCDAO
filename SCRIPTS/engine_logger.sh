#!/usr/bin/env bash
# -----------------------------------------------------------------------
# AOXC DAO - OMNISCIENT LOGGER ENGINE (v2.5.0 - Forensic Aware)
# Purpose: Every event, every error, every pulse recorded.
# -----------------------------------------------------------------------

set -Eeuo pipefail

# ---- DYNAMIC PATHS ----
BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
LOG_DIR="${BASE_DIR}/data/logs"
MASTER_LOG="${LOG_DIR}/aoxc_master.log"
TRACE_LOG="${LOG_DIR}/trace_forensic.log"
HISTORY_NOTE="${BASE_DIR}/data/notes/history.md"

mkdir -p "${LOG_DIR}" "${BASE_DIR}/data/notes"

# ---- UI COLORS (Neural Palette) ----
if [[ -t 1 ]]; then
    V_RED='\033[38;5;196m'; V_GREEN='\033[38;5;82m'; V_YELLOW='\033[38;5;226m'
    V_BLUE='\033[38;5;33m'; V_MAGENTA='\033[38;5;135m'; V_GREY='\033[38;5;244m'
    NC='\033[0m'
else
    V_RED=''; V_GREEN=''; V_YELLOW=''; V_BLUE=''; V_MAGENTA=''; V_GREY=''; NC=''
fi

# ---- TELEMETRY (Her Şeyden Haberdar Olma Kısmı) ----
get_system_snap() {
    # Sistem yükü ve Bellek bilgisini loga ekle (Adli Kanıt)
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        echo " [LOAD:$(awk '{print $1}' /proc/loadavg)] [MEM:$(free -h | awk '/^Mem:/ {print $3 "/" $2}')]"
    else
        echo " [OSX-NODE]"
    fi
}

# ---- INTERNAL WRITE (Atomic Lock) ----
_write_log() {
    local entry="$1"
    flock -x "${MASTER_LOG}.lock" -c "echo '${entry}' >> '${MASTER_LOG}'" 2>/dev/null || echo "${entry}" >> "${MASTER_LOG}"
}

# ---- CORE DISPATCHER (The Eye) ----
logger_dispatch() {
    local level="$1"
    shift
    local message="$*"
    local snap
    snap=$(get_system_snap)

    case "${level}" in
        INFO)    color="$V_BLUE";    icon="🔹 ";;
        SUCCESS) color="$V_GREEN";   icon="✔️ ";;
        WARN)    color="$V_YELLOW";  icon="⚠️ ";;
        ERROR)   color="$V_RED";     icon="🚫";;
        AUDIT)   color="$V_MAGENTA"; icon="🏛️ ";;
        TRACE)   color="$V_GREY";    icon="🧬";;
        *)       color="$NC";        icon="▪️ ";;
    esac

    local ts_iso=$(date -u +'%Y-%m-%dT%H:%M:%SZ')
    local formatted="[$ts_iso] ${level}: ${message}${snap}"

    # 1. Console Output
    echo -e "${color}${icon} ${formatted}${NC}"

    # 2. Master Log (Locked)
    _write_log "${formatted}"

    # 3. Smart History Integration
    if [[ "${level}" =~ ^(SUCCESS|ERROR|AUDIT)$ ]]; then
        echo "- [$(date +'%Y-%m-%d %H:%M:%S')] **${level}**: ${message}" >> "${HISTORY_NOTE}"
    fi
}

# ---- ERROR TRAP (Sistemin Kulağı) ----
# Herhangi bir script hata verip patlarsa bu fonksiyon onu yakalar
aoxc_panic_trap() {
    local exit_code=$?
    local line_no=$1
    if [[ $exit_code -ne 0 ]]; then
        logger_dispatch ERROR "Unexpected termination at line ${line_no} (Exit: ${exit_code})"
    fi
}

# ---- SHORTCUTS ----
log_info()    { logger_dispatch INFO "$@"; }
log_success() { logger_dispatch SUCCESS "$@"; }
log_warn()    { logger_dispatch WARN "$@"; }
log_error()   { logger_dispatch ERROR "$@"; }
log_audit()   { logger_dispatch AUDIT "$@"; }
log_trace()   { logger_dispatch TRACE "$@"; }

# ---- CLI MODE ----
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    logger_dispatch "$@"
fi
