#!/usr/bin/env bash
# -----------------------------------------------------------------------
# AOXC DAO - PRO ULTIMATE ACADEMIC METRICS ENGINE (v2.2.0-HARDENED)
# -----------------------------------------------------------------------

set -euo pipefail
IFS=$'\n\t'

# -----------------------------------------------------------------------
# 1. Environment Configuration
# -----------------------------------------------------------------------

L_LANG=${1:-TR}
DATA_ROOT="data"
METRICS_DIR="$DATA_ROOT/logs/metrics"
REPORT_FILE="$METRICS_DIR/complexity_report.md"
NOTE_FILE="$DATA_ROOT/notes/history.md"
LOGGER="./scripts/logger.sh"

mkdir -p "$METRICS_DIR"
mkdir -p "$(dirname "$NOTE_FILE")"

# -----------------------------------------------------------------------
# 2. Dependency & Preflight Checks
# -----------------------------------------------------------------------

require_binary() {
    if ! command -v "$1" >/dev/null 2>&1; then
        echo "[FATAL] Required binary missing: $1"
        exit 1
    fi
}

preflight() {
    require_binary solidity-metrics
    require_binary find
    require_binary wc
    require_binary sort
    require_binary date

    if [[ ! -f "$LOGGER" ]]; then
        echo "[FATAL] Logger not found: $LOGGER"
        exit 1
    fi

    if [[ ! -d "src" ]]; then
        echo "[FATAL] src directory not found."
        exit 1
    fi
}

preflight

# -----------------------------------------------------------------------
# 3. Execution
# -----------------------------------------------------------------------

if [[ "$L_LANG" == "TR" ]]; then
    "$LOGGER" INFO "AOXC Akademik Kod Metrik Analizi Başlatılıyor..."
else
    "$LOGGER" INFO "Starting AOXC Academic Code Metrics Analysis..."
fi

TIMESTAMP="$(date +'%Y-%m-%d %H:%M:%S')"

# Güvenli dosya listesi oluştur
mapfile -t SOL_FILES < <(find src -type f -name "*.sol")

if [[ ${#SOL_FILES[@]} -eq 0 ]]; then
    echo "[FATAL] No Solidity files found."
    exit 1
fi

# Metrics üretimi
if ! solidity-metrics "${SOL_FILES[@]}" > "$REPORT_FILE" 2>/dev/null; then
    "$LOGGER" ERROR "solidity-metrics execution failed."
    exit 1
fi

"$LOGGER" SUCCESS "Academic report generated: $REPORT_FILE"

# -----------------------------------------------------------------------
# 4. Source Code Statistics
# -----------------------------------------------------------------------

echo -e "\n\033[38;5;33m««« AOXC SOURCE CODE STATISTICS »»»\033[0m"

TOTAL_LINES=0
for file in "${SOL_FILES[@]}"; do
    lines=$(wc -l < "$file")
    printf "%8d %s\n" "$lines" "$file"
    TOTAL_LINES=$((TOTAL_LINES + lines))
done | sort -nr | head -n 5

echo "-------------------------------------------"
echo "TOTAL LINES: $TOTAL_LINES"

# -----------------------------------------------------------------------
# 5. Risk Detection
# -----------------------------------------------------------------------

COMPLEX_FUNCS=0
if [[ -f "$REPORT_FILE" ]]; then
    COMPLEX_FUNCS=$(grep -c "Complexity" "$REPORT_FILE" || true)
fi

if [[ "$COMPLEX_FUNCS" -gt 0 ]]; then
    "$LOGGER" WARN "$COMPLEX_FUNCS complex functions detected."

    {
        printf -- "- [%s] 📊 METRICS OK: %d complex nodes detected\n" \
        "$TIMESTAMP" "$COMPLEX_FUNCS"
    } >> "$NOTE_FILE"
else
    "$LOGGER" SUCCESS "Codebase complexity within acceptable academic thresholds."

    {
        printf -- "- [%s] ✅ METRICS: Code health optimal\n" \
        "$TIMESTAMP"
    } >> "$NOTE_FILE"
fi

# -----------------------------------------------------------------------
# 6. Archiving
# -----------------------------------------------------------------------

ARCHIVE_NAME="metrics_$(date +%Y%m%d_%H%M%S).md"
cp "$REPORT_FILE" "$METRICS_DIR/$ARCHIVE_NAME"

"$LOGGER" INFO "Timestamped archive created: $METRICS_DIR/$ARCHIVE_NAME"

exit 0

