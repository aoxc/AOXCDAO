#!/usr/bin/env bash
# ==============================================================================
# 🏛️ AOXCDAO INSTITUTIONAL QUALITY ASSURANCE (QA) ENGINE
# 🛡️ FRAMEWORK: Foundry / Forge / Solidity 0.8.33
# 📊 SCOPE: Formatting, Compilation, Testing, and Gas Telemetry
# 🎓 LEVEL: Pro Ultimate Academic
# ==============================================================================

set -e # Hata oluşursa scripti durdur

# --- 📁 Directory Configuration ---
ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
REPORT_BASE="$ROOT_DIR/reports/audit_ledger"
DATE_STR="$(date +%Y-%m-%d)"
TIME_STR="$(date +%H:%M:%S)"

# --- 🆔 Sequential Run Identification ---
RUN_ID=$(ls "$REPORT_BASE" 2>/dev/null | grep "^$DATE_STR-" | wc -l | tr -d ' ')
RUN_ID=$((RUN_ID + 1))
RUN_DIR="$REPORT_BASE/${DATE_STR}-RUN-${RUN_ID}"
LOG_DIR="$RUN_DIR/telemetry_logs"
SUMMARY_FILE="$RUN_DIR/ACCERDITATION_SUMMARY.txt"

# Create secure directory structure
mkdir -p "$LOG_DIR"

# --- 🖋️ Header & Metadata ---
{
    echo "=============================================================================="
    echo "🏛️ AOXCDAO PROTOCOL ACCREDITATION REPORT"
    echo "=============================================================================="
    echo "Date          : $DATE_STR"
    echo "Timestamp     : $TIME_STR"
    echo "Session ID    : $RUN_ID"
    echo "Environment   : Foundry / Solidity 0.8.33"
    echo "Status        : IN_PROGRESS"
    echo "------------------------------------------------------------------------------"
} | tee "$SUMMARY_FILE"

cd "$ROOT_DIR"

# --- 🧼 [1/4] SYNTATIC ALIGNMENT (Formatting) ---
echo -e "\n\033[1;34m[1/4] EXECUTING SYNTATIC ALIGNMENT...\033[0m"
if forge fmt; then
    echo "✓ Formatting: COMPLIANT" | tee -a "$SUMMARY_FILE"
else
    echo "✗ Formatting: NON-COMPLIANT" | tee -a "$SUMMARY_FILE"
    exit 1
fi

# --- 🏗️ [2/4] ARCHITECTURAL INTEGRITY (Build) ---
echo -e "\033[1;34m[2/4] VERIFYING ARCHITECTURAL INTEGRITY...\033[0m"
forge build --sizes > "$LOG_DIR/build_artifacts.log" 2>&1
if [ $? -eq 0 ]; then
    echo "✓ Build: VERIFIED" | tee -a "$SUMMARY_FILE"
else
    echo "✗ Build: FAILED" | tee -a "$SUMMARY_FILE"
    exit 1
fi

# --- 🧪 [3/4] FUNCTIONAL VALIDATION (Testing) ---
echo -e "\033[1;34m[3/4] CONDUCTING FUNCTIONAL VALIDATION...\033[0m"
if forge test -vvv > "$LOG_DIR/test_execution.log" 2>&1; then
    echo "✓ Functional Tests: PASSED" | tee -a "$SUMMARY_FILE"
else
    echo "✗ Functional Tests: FAILED" | tee -a "$SUMMARY_FILE"
    exit 1
fi

# --- ⛽ [4/4] GAS ECONOMICS TELEMETRY ---
echo -e "\033[1;34m[4/4] ANALYZING GAS ECONOMICS...\033[0m"
forge test --gas-report > "$LOG_DIR/gas_telemetry.log" 2>&1
echo "✓ Gas Report: GENERATED" | tee -a "$SUMMARY_FILE"

# --- 📜 Finalization ---
echo -e "\n------------------------------------------------------------------------------" >> "$SUMMARY_FILE"
echo "ACCREDITATION STATUS: SUCCESSFUL" >> "$SUMMARY_FILE"
echo "------------------------------------------------------------------------------" >> "$SUMMARY_FILE"

echo -e "\n\033[1;32m[✔ SUCCESS]\033[0m Accreditation cycle completed."
echo -e "\033[1;33m[📂 REPORT]\033[0m $RUN_DIR\n"
