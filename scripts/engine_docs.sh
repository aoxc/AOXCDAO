#!/usr/bin/env bash
# -----------------------------------------------------------------------
# AOXC DAO - PRO ULTIMATE DOCUMENTATION ENGINE
# Version: 3.0.0 (Deterministic / Hardened / CI-Safe)
# Standard: Academic Registry | Solidity 0.8.33
# -----------------------------------------------------------------------

set -Eeuo pipefail
IFS=$'\n\t'

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

LOGGER="$SCRIPT_DIR/logger.sh"
if [[ ! -f "$LOGGER" ]]; then
    echo "Fatal: logger.sh missing"
    exit 1
fi
# shellcheck disable=SC1090
source "$LOGGER"

L_LANG="${2:-TR}"

DATA_ROOT="$ROOT_DIR/data"
DOC_DIR="$ROOT_DIR/docs"
SRC_DIR="$DOC_DIR/src"
THEME_DIR="$DOC_DIR/theme"
NOTE_FILE="$DATA_ROOT/notes/history.md"

mkdir -p "$DATA_ROOT/notes"

# --------------------------------------------------
# Dependency Check
# --------------------------------------------------
if ! command -v mdbook >/dev/null 2>&1; then
    log_error "mdbook not installed"
    exit 1
fi

# --------------------------------------------------
# Corporate Colors
# --------------------------------------------------
AOXC_PURPLE="#bc8cf2"
AOXC_GOLD="#e3b341"
AOXC_DEEP_DARK="#0d1117"
AOXC_NAVY="#161b22"

# --------------------------------------------------
# Safe Copy (Atomic)
# --------------------------------------------------
safe_copy() {
    local src="$1"
    local dest="$2"

    if [[ -f "$src" ]]; then
        local tmp="${dest}.tmp"
        cp "$src" "$tmp"
        mv "$tmp" "$dest"
    fi
}

# --------------------------------------------------
# INIT REGISTRY
# --------------------------------------------------
init_registry() {

    log_info "🏛️ AOXC Registry infrastructure initializing..."

    mkdir -p \
        "$SRC_DIR/core" \
        "$SRC_DIR/compliance" \
        "$SRC_DIR/asset" \
        "$SRC_DIR/monitoring" \
        "$THEME_DIR/css" \
        "$THEME_DIR/scripts"

    cat > "$DOC_DIR/book.toml" <<EOF
[book]
authors = ["AOXC Core Engineering"]
language = "en"
multilingual = false
src = "src"
title = "AOXC DAO | Akdeniz V3 Registry"

[output.html]
theme = "navy"
default-theme = "navy"
preferred-dark-theme = "navy"
copy-fonts = true
additional-css = ["theme/css/aoxc-institutional.css"]
EOF

    cat > "$THEME_DIR/css/aoxc-institutional.css" <<EOF
:root {
    --sidebar-bg: ${AOXC_DEEP_DARK};
    --sidebar-active: ${AOXC_PURPLE};
    --link-color: ${AOXC_GOLD};
}

.content main h1 {
    color: ${AOXC_GOLD};
    border-bottom: 2px solid ${AOXC_PURPLE};
}
EOF

    cat > "$SRC_DIR/SUMMARY.md" <<EOF
# AOXC DAO REGISTRY

- [System Hub](index.md)
EOF

    cat > "$SRC_DIR/index.md" <<EOF
# AOXC DAO – Akdeniz Framework

**SECURITY_LEVEL:** FORENSIC_GRADE  
**COMPILER:** Solidity 0.8.33  
EOF

    if mdbook build "$DOC_DIR"; then
        log_success "Registry initialized successfully."
    else
        log_error "mdBook build failed"
        exit 1
    fi
}

# --------------------------------------------------
# BUILD REGISTRY
# --------------------------------------------------
build_registry() {

    log_info "🔄 Updating registry..."

    TIMESTAMP="$(date +'%Y-%m-%d %H:%M:%S')"

    safe_copy \
        "$DATA_ROOT/logs/audits/slither/security_checklist.md" \
        "$SRC_DIR/audit_log.md"

    safe_copy \
        "$DATA_ROOT/logs/gas/gas_evolution_diff.md" \
        "$SRC_DIR/gas_report.md"

    if [[ -f "$DATA_ROOT/logs/audits/formal/formal_proof.log" ]]; then
        {
            echo "# Formal Verification Results"
            echo '```text'
            cat "$DATA_ROOT/logs/audits/formal/formal_proof.log"
            echo '```'
        } > "$SRC_DIR/formal_proof.md"
    fi

    if mdbook build "$DOC_DIR"; then
        log_success "Registry rebuilt: $DOC_DIR/book/index.html"
        echo "- [$TIMESTAMP] 📚 DOCS: Registry updated." >> "$NOTE_FILE"
    else
        log_error "Registry build failed"
        exit 1
    fi
}

# --------------------------------------------------
# Command Router
# --------------------------------------------------
case "${1:-}" in
    init) init_registry ;;
    build) build_registry ;;
    *)
        log_warn "Usage: $0 {init|build}"
        exit 1
        ;;
esac

