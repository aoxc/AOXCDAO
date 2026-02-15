#!/usr/bin/env bash
# -----------------------------------------------------------------------
# AOXC DAO - FORMAL VERIFICATION ENGINE (v3.0.0-STABLE)
# -----------------------------------------------------------------------
# Solidity: 0.8.33
# SMT Solver: Halmos (Z3 / CVC4 backend)
# -----------------------------------------------------------------------

set -Eeuo pipefail

# -----------------------------------------------------------------------
# 1. Environment Configuration
# -----------------------------------------------------------------------

L_LANG="${1:-TR}"

DATA_ROOT="data"
REPORT_DIR="${DATA_ROOT}/logs/audits/formal"
LOG_FILE="${REPORT_DIR}/formal_proof.log"
NOTE_FILE="${DATA_ROOT}/notes/history.md"
LOGGER="./scripts/logger.sh"

mkdir -p "${REPORT_DIR}"
mkdir -p "$(dirname "${NOTE_FILE}")"

TIMESTAMP_START="$(date '+%Y-%m-%d %H:%M:%S')"

# -----------------------------------------------------------------------
# 2. Dependency Checks
# -----------------------------------------------------------------------

if ! command -v forge >/dev/null 2>&1; then
    echo "Forge is not installed or not in PATH."
    exit 1
fi

if ! command -v halmos >/dev/null 2>&1; then
    if [[ "${L_LANG}" == "TR" ]]; then
        echo "Halmos SMT motoru bulunamadı! 'pip install halmos' ile kurun."
    else
        echo "Halmos SMT engine not found! Please run 'pip install halmos'."
    fi
    exit 1
fi

if [[ ! -x "${LOGGER}" ]]; then
    echo "Logger not found or not executable: ${LOGGER}"
    exit 1
fi

# -----------------------------------------------------------------------
# 3. Pre-Build for IR & Bytecode
# -----------------------------------------------------------------------

if [[ "${L_LANG}" == "TR" ]]; then
    "${LOGGER}" INFO "Sistem derleniyor ve matematiksel ispat için hazırlanıyor... (Solc 0.8.33)"
else
    "${LOGGER}" INFO "Compiling system for mathematical proof... (Solc 0.8.33)"
fi

if ! forge build --via-ir > /dev/null 2>&1; then
    "${LOGGER}" ERROR "Forge build failed before formal verification."
    exit 1
fi

# -----------------------------------------------------------------------
# 4. Formal Verification Execution
# -----------------------------------------------------------------------

if [[ "${L_LANG}" == "TR" ]]; then
    "${LOGGER}" INFO "Matematiksel Kanıtlama (Halmos SMT) Başlatılıyor..."
else
    "${LOGGER}" INFO "Starting Formal Verification (Halmos SMT)..."
fi

if halmos \
    --contracts-dir src \
    --test-dir test \
    --loop 2 \
    --solver-timeout 30000 \
    > "${LOG_FILE}" 2>&1
then

    if [[ "${L_LANG}" == "TR" ]]; then
        "${LOGGER}" SUCCESS "KUSURSUZ: Tüm matematiksel invariantlar doğrulandı."
    else
        "${LOGGER}" SUCCESS "PERFECT: All invariants verified."
    fi

    echo "- [${TIMESTAMP_START}] FORMAL_PROOF: All contracts verified." >> "${NOTE_FILE}"

else

    if [[ "${L_LANG}" == "TR" ]]; then
        "${LOGGER}" ERROR "FORMAL KANIT BAŞARISIZ: Assertion ihlali saptandı!"
    else
        "${LOGGER}" ERROR "FORMAL PROOF FAILED: Assertion violation detected!"
    fi

    echo
    echo "[FORENSIC SUMMARY]"
    grep -A 10 "Counterexample" "${LOG_FILE}" | tail -n 12 || true
    echo

    echo "- [${TIMESTAMP_START}] FORMAL_ALERT: Assertion violation detected." >> "${NOTE_FILE}"
    exit 1
fi

# -----------------------------------------------------------------------
# 5. Archiving
# -----------------------------------------------------------------------

ARCHIVE_NAME="formal_report_$(date '+%Y%m%d_%H%M%S').log"
ARCHIVE_PATH="${REPORT_DIR}/${ARCHIVE_NAME}"

cp "${LOG_FILE}" "${ARCHIVE_PATH}"

if [[ "${L_LANG}" == "TR" ]]; then
    "${LOGGER}" INFO "İspat raporu arşivlendi: ${ARCHIVE_PATH}"
else
    "${LOGGER}" INFO "Formal report archived: ${ARCHIVE_PATH}"
fi

