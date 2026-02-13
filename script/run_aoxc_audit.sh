#!/usr/bin/env bash
set -e

# =========================
# AOXC V2 PRIME – AUDIT RUNNER
# =========================

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
REPORT_BASE="$ROOT_DIR/report"
DATE_STR="$(date +%Y-%m-%d)"
TIME_STR="$(date +%H-%M-%S)"

# Incremental run number
RUN_ID=$(ls "$REPORT_BASE" 2>/dev/null | grep "^$DATE_STR-" | wc -l | tr -d ' ')
RUN_ID=$((RUN_ID + 1))

RUN_DIR="$REPORT_BASE/${DATE_STR}-${RUN_ID}"
LOG_DIR="$RUN_DIR/logs"
SUMMARY_FILE="$RUN_DIR/SUMMARY.txt"

mkdir -p "$LOG_DIR"

echo "AOXC V2 PRIME – AUTOMATED TEST RUN"            | tee "$SUMMARY_FILE"
echo "Date      : $DATE_STR"                         | tee -a "$SUMMARY_FILE"
echo "Run ID    : $RUN_ID"                           | tee -a "$SUMMARY_FILE"
echo "Timestamp : $TIME_STR"                         | tee -a "$SUMMARY_FILE"
echo "----------------------------------------"     | tee -a "$SUMMARY_FILE"

cd "$ROOT_DIR"

# -------------------------
# 1. Formatting
# -------------------------
echo "[1/4] Running forge fmt..."
forge fmt > "$LOG_DIR/01_fmt.log" 2>&1
echo "✓ Formatting completed" | tee -a "$SUMMARY_FILE"

# -------------------------
# 2. Build
# -------------------------
echo "[2/4] Running forge build..."
forge build --sizes > "$LOG_DIR/02_build.log" 2>&1
echo "✓ Build successful" | tee -a "$SUMMARY_FILE"

# -------------------------
# 3. Tests
# -------------------------
echo "[3/4] Running forge tests..."
forge test -vvv > "$LOG_DIR/03_tests.log" 2>&1
echo "✓ Tests executed" | tee -a "$SUMMARY_FILE"

# -------------------------
# 4. Gas Report
# -------------------------
echo "[4/4] Generating gas report..."
forge test --gas-report > "$LOG_DIR/04_gas_report.log" 2>&1
echo "✓ Gas report generated" | tee -a "$SUMMARY_FILE"

# -------------------------
# Metadata
# -------------------------
echo "" >> "$SUMMARY_FILE"
echo "Artifacts:" >> "$SUMMARY_FILE"
echo "- logs/01_fmt.log"        >> "$SUMMARY_FILE"
echo "- logs/02_build.log"      >> "$SUMMARY_FILE"
echo "- logs/03_tests.log"      >> "$SUMMARY_FILE"
echo "- logs/04_gas_report.log" >> "$SUMMARY_FILE"

echo "" >> "$SUMMARY_FILE"
echo "Status: COMPLETED" >> "$SUMMARY_FILE"

echo "----------------------------------------"
echo "Report generated at:"
echo "$RUN_DIR"

