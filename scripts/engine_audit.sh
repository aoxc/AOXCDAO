#!/usr/bin/env bash
# -----------------------------------------------------------------------
# AOXC DAO - Deterministic Security Gate
# Version: 7.0.0 (Deploy-Enforced)
# -----------------------------------------------------------------------

set -Eeuo pipefail
IFS=$'\n\t'

# -------------------------
# Exit Codes
# 0 = Clean
# 1 = Risk Found
# 2 = Tool Missing
# 3 = Corrupted Output
# -------------------------

# Logger Required
if [[ ! -f "./scripts/logger.sh" ]]; then
    echo "Fatal: logger.sh missing"
    exit 2
fi
source ./scripts/logger.sh

COMMAND="${1:-}"
LANGUAGE="${2:-EN}"

AUDIT_DIR="data/registry/audits"
mkdir -p "$AUDIT_DIR"

SCRIPT_PATH="$(realpath "$0")"

# -------------------------
# Required Tools
# -------------------------
require_tool() {
    command -v "$1" >/dev/null 2>&1 || {
        log_error "Missing required tool: $1"
        exit 2
    }
}

# -------------------------
# Risk Policy
# -------------------------
CRITICAL=0
HIGH=0
MEDIUM=0

evaluate_risk() {
    if (( CRITICAL > 0 )); then
        return 1
    fi

    if (( HIGH > 0 )); then
        return 1
    fi

    if (( MEDIUM > 5 )); then
        return 1
    fi

    return 0
}

# -------------------------
# LINT
# -------------------------
run_lint() {
    require_tool solhint

    if solhint "src/**/*.sol" --max-warnings 0 >/dev/null 2>&1; then
        log_success "Lint: Clean"
    else
        log_error "Lint: Failed"
        exit 1
    fi
}

# -------------------------
# STATIC ANALYSIS
# -------------------------
run_static() {
    require_tool slither

    log_info "Running Slither..."

    slither . \
        --foundry-out-directory out \
        --exclude-dependencies \
        --filter-paths "lib/|test/" \
        --json "$AUDIT_DIR/slither.json" \
        >/dev/null 2>&1 || {
            log_error "Slither execution failed"
            exit 3
        }

    if [[ ! -f "$AUDIT_DIR/slither.json" ]]; then
        log_error "Slither output missing"
        exit 3
    fi

    # Parse severity counts (minimal deterministic parsing)
    CRITICAL=$(grep -c '"impact": "High"' "$AUDIT_DIR/slither.json" || true)
    HIGH=$CRITICAL
    MEDIUM=$(grep -c '"impact": "Medium"' "$AUDIT_DIR/slither.json" || true)

    evaluate_risk || {
        log_error "Static Analysis: Risk detected"
        exit 1
    }

    log_success "Static Analysis: Clean"
}

# -------------------------
# MYTHRIL
# -------------------------
run_mythril() {
    require_tool myth

    log_info "Running Mythril..."

    myth analyze src/core/AOXCHub.sol \
        --execution-timeout 300 \
        >/dev/null 2>&1 || {
            log_error "Mythril execution failed"
            exit 3
        }

    log_success "Mythril: Completed"
}

# -------------------------
# ALL
# -------------------------
run_all() {
    "$SCRIPT_PATH" lint "$LANGUAGE"
    "$SCRIPT_PATH" static "$LANGUAGE"
    "$SCRIPT_PATH" mythril "$LANGUAGE"

    log_success "Security Gate: PASSED"
}

# -------------------------
# Command Dispatcher
# -------------------------
case "$COMMAND" in
    lint)
        run_lint
        ;;
    static)
        run_static
        ;;
    mythril)
        run_mythril
        ;;
    all)
        run_all
        ;;
    *)
        echo "Usage: $0 {lint|static|mythril|all} [TR|EN]"
        exit 1
        ;;
esac

exit 0

