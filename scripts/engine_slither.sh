#!/usr/bin/env bash
# -----------------------------------------------------------------------
# AOXC DAO - PRO ULTIMATE SLITHER ENGINE (v2.3.0-HARDENED)
# -----------------------------------------------------------------------

set -euo pipefail
IFS=$'\n\t'

# -----------------------------------------------------------------------
# 1. Configuration
# -----------------------------------------------------------------------

L_LANG=${1:-TR}
FAIL_ON_HIGH=${2:-true}

DATA_ROOT="data"
REPORT_DIR="$DATA_ROOT/logs/audits/slither"
STATE_DIR="$DATA_ROOT/state"
NOTE_FILE="$DATA_ROOT/notes/history.md"
LOGGER="./scripts/logger.sh"

mkdir -p "$REPORT_DIR" "$STATE_DIR"
mkdir -p "$(dirname "$NOTE_FILE")"

# -----------------------------------------------------------------------
# 2. Preflight
# -----------------------------------------------------------------------

require_binary() {
    command -v "$1" >/dev/null 2>&1 || {
        echo "[FATAL] Missing required binary: $1"
        exit 1
    }
}

preflight() {
    require_binary slither
    require_binary jq
    require_binary date

    if [[ ! -f "$LOGGER" ]]; then
        echo "[FATAL] Logger not found."
        exit 1
    fi

    if [[ ! -d "src" ]]; then
        echo "[FATAL] Solidity source directory not found."
        exit 1
    fi
}

preflight

# -----------------------------------------------------------------------
# 3. Execution
# -----------------------------------------------------------------------

if [[ "$L_LANG" == "TR" ]]; then
    "$LOGGER" INFO "AOXC Slither Denetimi Başlatıldı..."
else
    "$LOGGER" INFO "AOXC Slither Audit Started..."
fi

TIMESTAMP="$(date +'%Y-%m-%d %H:%M:%S')"

if ! slither . \
    --triage-database "$STATE_DIR/slither.db.json" \
    --json "$REPORT_DIR/slither_raw.json" \
    --checklist > "$REPORT_DIR/security_checklist.md" 2>&1
then
    "$LOGGER" ERROR "Slither execution failed."
    exit 1
fi

# -----------------------------------------------------------------------
# 4. Printers
# -----------------------------------------------------------------------

slither . --print permission > "$REPORT_DIR/map_permissions.txt" 2>/dev/null || true
slither . --print variable-order > "$REPORT_DIR/map_variables.txt" 2>/dev/null || true

# -----------------------------------------------------------------------
# 5. Risk Analysis (JSON-Based)
# -----------------------------------------------------------------------

HIGH_RISK=0

if [[ -f "$REPORT_DIR/slither_raw.json" ]]; then
    HIGH_RISK=$(jq '[.results.detectors[] | select(.impact=="High")] | length' \
        "$REPORT_DIR/slither_raw.json" 2>/dev/null || echo "0")
fi

if [[ "$HIGH_RISK" -gt 0 ]]; then

    "$LOGGER" ERROR "$HIGH_RISK High severity findings detected."

    {
        printf -- "- [%s] ❌ SECURITY ALERT: %d High findings detected.\n" \
        "$TIMESTAMP" "$HIGH_RISK"
    } >> "$NOTE_FILE"

    if [[ "$FAIL_ON_HIGH" == "true" ]]; then
        exit 1
    fi

else

    "$LOGGER" SUCCESS "No High severity vulnerabilities detected."

    {
        printf -- "- [%s] ✅ AUDIT: Slither passed (no High severity).\n" \
        "$TIMESTAMP"
    } >> "$NOTE_FILE"

fi

# -----------------------------------------------------------------------
# 6. Archiving
# -----------------------------------------------------------------------

ARCHIVE_NAME="audit_$(date +%Y%m%d_%H%M%S).md"
cp "$REPORT_DIR/security_checklist.md" "$REPORT_DIR/$ARCHIVE_NAME"

"$LOGGER" INFO "Report archived: $REPORT_DIR/$ARCHIVE_NAME"

exit 0

