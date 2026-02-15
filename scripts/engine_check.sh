#!/usr/bin/env bash
# -----------------------------------------------------------------------
# AOXC DAO - CORTEX KERNEL
# Version: 7.0.0 (Deterministic / Hardened / CI-Safe)
# -----------------------------------------------------------------------

set -Eeuo pipefail
IFS=$'\n\t'

trap 'echo -e "\n[CRITICAL] Kernel interrupted"; exit 1' SIGINT SIGTERM

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
LOGGER="$SCRIPT_DIR/logger.sh"

if [[ ! -f "$LOGGER" ]]; then
    echo "Fatal: logger.sh missing"
    exit 1
fi
source "$LOGGER"

LANGUAGE="${1:-EN}"
NON_INTERACTIVE="${NON_INTERACTIVE:-false}"
VENV_DIR="${VENV_DIR:-.venv}"
DATA_HUB="${DATA_HUB:-data/notes/history.md}"

mkdir -p "$(dirname "$DATA_HUB")"

# --------------------------------------------------
# Package Manager Detection
# --------------------------------------------------
detect_pkg_manager() {
    local managers=("pnpm" "yarn" "npm")
    for m in "${managers[@]}"; do
        if command -v "$m" >/dev/null 2>&1; then
            echo "$m"
            return
        fi
    done
    echo "npm"
}

PKG_MANAGER="$(detect_pkg_manager)"
log_info "Package Manager: $PKG_MANAGER"

# --------------------------------------------------
# Python Virtual Environment
# --------------------------------------------------
init_venv() {
    if [[ ! -d "$VENV_DIR" ]]; then
        log_info "Creating virtual environment..."
        command -v python3 >/dev/null 2>&1 || {
            log_error "python3 not installed"
            exit 1
        }
        python3 -m venv "$VENV_DIR"
    fi

    # shellcheck disable=SC1090
    source "$VENV_DIR/bin/activate"

    pip install --upgrade pip setuptools wheel >/dev/null 2>&1
    log_success "Python environment ready"
}

# --------------------------------------------------
# Tool Installer (Controlled)
# --------------------------------------------------
install_tool() {
    local tool="$1"

    case "$tool" in
        forge)
            log_info "Installing Foundry..."
            curl -sSfL https://foundry.paradigm.xyz | bash >/dev/null 2>&1
            export PATH="$HOME/.foundry/bin:$PATH"
            foundryup >/dev/null 2>&1
            ;;
        slither|halmos)
            pip install "$tool" --upgrade >/dev/null 2>&1
            ;;
        solhint)
            "$PKG_MANAGER" install -g solhint >/dev/null 2>&1
            ;;
        node)
            log_error "Node auto-install disabled for safety"
            exit 1
            ;;
        *)
            log_error "Unknown tool: $tool"
            exit 1
            ;;
    esac
}

# --------------------------------------------------
# Dependency Matrix
# --------------------------------------------------
TOOLS=("forge" "slither" "solhint" "halmos")

check_tools() {
    for tool in "${TOOLS[@]}"; do
        if ! command -v "$tool" >/dev/null 2>&1; then
            log_warn "Missing: $tool"

            if [[ "$NON_INTERACTIVE" == "true" ]]; then
                log_error "Non-interactive mode: cannot auto-install $tool"
                exit 1
            fi

            read -r -p "Install $tool? [y/N]: " confirm
            if [[ "$confirm" =~ ^[Yy]$ ]]; then
                install_tool "$tool"
            else
                log_error "Kernel cannot proceed without $tool"
                exit 1
            fi
        else
            VERSION="$("$tool" --version 2>/dev/null | head -n 1 | cut -c1-40)"
            log_success "$tool detected (${VERSION:-active})"
        fi
    done
}

# --------------------------------------------------
# Directory Integrity Check
# --------------------------------------------------
verify_structure() {
    log_info "Verifying directory structure..."

    [[ -d "$ROOT_DIR/src" ]] || {
        log_error "Missing src directory"
        exit 1
    }

    mkdir -p "$ROOT_DIR/data"
    log_success "Structure verified"
}

# --------------------------------------------------
# Memory Seal
# --------------------------------------------------
seal_kernel() {
    local timestamp
    timestamp="$(date +'%Y-%m-%d %H:%M:%S')"
    echo "- [$timestamp] 🧠 KERNEL: Dependencies verified and environment stable." \
        >> "$DATA_HUB"
}

# --------------------------------------------------
# Main Execution
# --------------------------------------------------
clear
echo "AOXC CORTEX KERNEL v7.0.0"

init_venv
check_tools
verify_structure
seal_kernel

log_success "AOXC Kernel Active"

exit 0

