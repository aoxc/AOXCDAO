#!/usr/bin/env bash
# -----------------------------------------------------------------------
# AOXC DAO - PRO ULTIMATE SYMBOLIC EXECUTION ENGINE (v2.2.0-HARDENED)
# -----------------------------------------------------------------------

set -euo pipefail
IFS=$'\n\t'

# -----------------------------------------------------------------------
# 1. Environment Configuration
# -----------------------------------------------------------------------

L_LANG=${1:-TR}
DATA_ROOT="data"
WORKSPACE="$DATA_ROOT/logs/manticore/results"
MANTICORE_LOG_DIR="$DATA_ROOT/logs/manticore"
STREAM_LOG="$MANTICORE_LOG_DIR/manticore_stream.log"
NOTE_FILE="$DATA_ROOT/notes/history.md"
LOGGER="./scripts/logger.sh"

TARGET_CONTRACT="${2:-src/core/AOXCHub.sol}"

mkdir -p "$WORKSPACE"
mkdir -p "$MANTICORE_LOG_DIR"
mkdir -p "$(dirname "$NOTE_FILE")"

# -----------------------------------------------------------------------
# 2. Preflight Checks
# -----------------------------------------------------------------------

require_binary() {
    if ! command -v "$1" >/dev/null 2>&1; then
        echo "[FATAL] Required binary missing: $1"
        exit 1
    fi
}

preflight() {
    require_binary manticore
    require_binary tee
    require_binary date

    if [[ ! -f "$LOGGER" ]]; then
        echo "[FATAL] Logger not found: $LOGGER"
        exit 1
    fi

    if [[ ! -f "$TARGET_CONTRACT" ]]; then
        echo "[FATAL] Target contract not found: $TARGET_CONTRACT"
        exit 1
    fi
}

preflight

# -----------------------------------------------------------------------
# 3. Execution Preparation
# -----------------------------------------------------------------------

if [[ "$L_LANG" == "TR" ]]; then
    "$LOGGER" INFO "Manticore Sembolik Analiz Başlatıldı (Deep State Exploration)..."
    "$LOGGER" WARN "HEDEF: $TARGET_CONTRACT"
    "$LOGGER" WARN "UYARI: Bu işlem yüksek CPU/RAM tüketir."
else
    "$LOGGER" INFO "Manticore Symbolic Analysis Initiated..."
    "$LOGGER" WARN "TARGET: $TARGET_CONTRACT"
    "$LOGGER" WARN "WARNING: High CPU/RAM consumption expected."
fi

TIMESTAMP_START="$(date +'%Y-%m-%d %H:%M:%S')"

# -----------------------------------------------------------------------
# 4. Trap (Interrupt Protection)
# -----------------------------------------------------------------------

cleanup() {
    echo "[INTERRUPTED] $(date +'%Y-%m-%d %H:%M:%S')" >> "$NOTE_FILE"
    exit 1
}

trap cleanup INT TERM

# -----------------------------------------------------------------------
# 5. Symbolic Execution
# -----------------------------------------------------------------------

if ! manticore "$TARGET_CONTRACT" \
    --workspace "$WORKSPACE" \
    --no-state-merging \
    --evm.prover z3 \
    2>&1 | tee "$STREAM_LOG"
then

    if [[ "$L_LANG" == "TR" ]]; then
        "$LOGGER" ERROR "Sembolik analiz başarısız!"
    else
        "$LOGGER" ERROR "Symbolic analysis failed!"
    fi

    {
        printf -- "- [%s] ❌ SYMBOLIC ERROR: %s\n" \
        "$TIMESTAMP_START" "$TARGET_CONTRACT"
    } >> "$NOTE_FILE"

    exit 1
fi

# -----------------------------------------------------------------------
# 6. Success Handling
# -----------------------------------------------------------------------

if [[ "$L_LANG" == "TR" ]]; then
    "$LOGGER" SUCCESS "Sembolik analiz tamamlandı."
    "$LOGGER" SUCCESS "Rapor dizini: $WORKSPACE"
else
    "$LOGGER" SUCCESS "Symbolic analysis completed."
    "$LOGGER" SUCCESS "Report directory: $WORKSPACE"
fi

{
    printf -- "- [%s] 🧬 SYMBOLIC OK: %s\n" \
    "$TIMESTAMP_START" "$TARGET_CONTRACT"
} >> "$NOTE_FILE"

# -----------------------------------------------------------------------
# 7. Archiving
# -----------------------------------------------------------------------

ARCHIVE_NAME="manticore_$(date +%Y%m%d_%H%M%S).log"
cp "$STREAM_LOG" "$MANTICORE_LOG_DIR/$ARCHIVE_NAME"

exit 0

