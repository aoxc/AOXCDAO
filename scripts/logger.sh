#!/usr/bin/env bash
# -----------------------------------------------------------------------
# AOXC DAO - ENTERPRISE LOGGER ENGINE (v2.0.0)
# Purpose: ISO-8601 Traceability, Forensic Logging & Memory Integration
# Standard: Production Safe / ShellCheck Clean
# -----------------------------------------------------------------------

set -Eeuo pipefail

# -----------------------------------------------------------------------
# Color Matrix (Only if TTY)
# -----------------------------------------------------------------------
if [[ -t 1 ]]; then
    V_RED='\033[38;5;196m'
    V_GREEN='\033[38;5;82m'
    V_YELLOW='\033[38;5;226m'
    V_BLUE='\033[38;5;33m'
    V_MAGENTA='\033[38;5;135m'
    V_GREY='\033[38;5;244m'
    NC='\033[0m'
else
    V_RED=''; V_GREEN=''; V_YELLOW=''
    V_BLUE=''; V_MAGENTA=''; V_GREY=''
    NC=''
fi

# -----------------------------------------------------------------------
# Directories
# -----------------------------------------------------------------------
LOG_DIR="data/logs"
MASTER_LOG="${LOG_DIR}/aoxc_master.log"
HISTORY_NOTE="data/notes/history.md"

mkdir -p "${LOG_DIR}" "data/notes"
touch "${MASTER_LOG}" "${HISTORY_NOTE}"

# -----------------------------------------------------------------------
# Time Functions
# -----------------------------------------------------------------------
timestamp() { date -u +'%Y-%m-%dT%H:%M:%SZ'; }
note_time() { date +'%Y-%m-%d %H:%M:%S'; }

# -----------------------------------------------------------------------
# Internal Write (File Lock Protected)
# -----------------------------------------------------------------------
_write_log() {
    local entry="$1"
    (
        flock -w 5 200 || exit 1
        echo "${entry}" >> "${MASTER_LOG}"
    ) 200>"${MASTER_LOG}.lock"
}

# -----------------------------------------------------------------------
# Core Dispatcher
# -----------------------------------------------------------------------
logger_dispatch() {
    if [[ $# -lt 2 ]]; then
        echo "Logger usage: LEVEL MESSAGE"
        return 1
    fi

    local level="$1"
    shift
    local message="$*"

    local color="$NC"
    local icon="ℹ️"

    case "${level}" in
        INFO)    color="$V_BLUE";    icon="ℹ️ " ;;
        SUCCESS) color="$V_GREEN";   icon="✅" ;;
        WARN)    color="$V_YELLOW";  icon="⚠️ " ;;
        ERROR)   color="$V_RED";     icon="❌" ;;
        AUDIT)   color="$V_MAGENTA"; icon="🏛️ " ;;
        DEBUG)   color="$V_GREY";    icon="🔍" ;;
        *)
            echo "Invalid log level: ${level}"
            return 1
        ;;
    esac

    local formatted="[$(timestamp)] ${level}: ${message}"

    # 1. Console Output
    echo -e "${color}${icon} ${formatted}${NC}"

    # 2. Master Log (Locked)
    _write_log "${formatted}"

    # 3. Memory Integration (Critical Levels Only)
    if [[ "${level}" == "SUCCESS" || "${level}" == "ERROR" || "${level}" == "AUDIT" ]]; then
        echo "- [$(note_time)] **${level}**: ${message}" >> "${HISTORY_NOTE}"
    fi
}

# -----------------------------------------------------------------------
# Exported Shortcuts (Source Friendly)
# -----------------------------------------------------------------------
log_info()    { logger_dispatch INFO "$@"; }
log_success() { logger_dispatch SUCCESS "$@"; }
log_warn()    { logger_dispatch WARN "$@"; }
log_error()   { logger_dispatch ERROR "$@"; }
log_audit()   { logger_dispatch AUDIT "$@"; }
log_debug()   { logger_dispatch DEBUG "$@"; }

# -----------------------------------------------------------------------
# CLI Mode
# -----------------------------------------------------------------------
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    logger_dispatch "$@"
fi

