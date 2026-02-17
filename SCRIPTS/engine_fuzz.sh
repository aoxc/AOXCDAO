#!/usr/bin/env bash
# -----------------------------------------------------------------------
# AOXC DAO - FUZZING ENGINE (v3.0.0-STABLE)
# -----------------------------------------------------------------------
# Solidity: 0.8.33
# Property-Based Testing: Echidna
# -----------------------------------------------------------------------

set -Eeuo pipefail

# -----------------------------------------------------------------------
# 1. Environment Configuration
# -----------------------------------------------------------------------

L_LANG="${1:-TR}"

DATA_ROOT="data"
FUZZ_DIR="${DATA_ROOT}/logs/fuzz"
CORPUS_DIR="${FUZZ_DIR}/corpus"
LOG_FILE="${FUZZ_DIR}/echidna_results.log"
CONFIG_FILE="echidna.config.yml"
NOTE_FILE="${DATA_ROOT}/notes/history.md"
LOGGER="./scripts/logger.sh"

mkdir -p "${FUZZ_DIR}"
mkdir -p "${CORPUS_DIR}"
mkdir -p "$(dirname "${NOTE_FILE}")"

TIMESTAMP_START="$(date '+%Y-%m-%d %H:%M:%S')"

# -----------------------------------------------------------------------
# 2. Dependency Checks
# -----------------------------------------------------------------------

if ! command -v echidna >/dev/null 2>&1; then
    echo "Echidna engine not found in PATH."
    exit 1
fi

if [[ ! -x "${LOGGER}" ]]; then
    echo "Logger not found or not executable: ${LOGGER}"
    exit 1
fi

# -----------------------------------------------------------------------
# 3. Config Validation / Creation
# -----------------------------------------------------------------------

if [[ ! -f "${CONFIG_FILE}" ]]; then
    "${LOGGER}" WARN "Config not found. Creating default academic config..."

    cat > "${CONFIG_FILE}" <<EOF
testMode: assertion
corpusDir: ${CORPUS_DIR}
format: text
testLimit: 50000
EOF
fi

# -----------------------------------------------------------------------
# 4. Fuzz Execution
# -----------------------------------------------------------------------

if [[ "${L_LANG}" == "TR" ]]; then
    "${LOGGER}" INFO "Echidna Fuzzing Engine başlatılıyor..."
    "${LOGGER}" WARN "Yoğun CPU kullanımı! 50.000+ iterasyon hedefleniyor."
else
    "${LOGGER}" INFO "Launching Echidna Fuzzing Engine..."
    "${LOGGER}" WARN "CPU intensive operation! Targeting 50,000+ iterations."
fi

if echidna . --config "${CONFIG_FILE}" > "${LOG_FILE}" 2>&1; then

    if [[ "${L_LANG}" == "TR" ]]; then
        "${LOGGER}" SUCCESS "KUSURSUZ: Fuzzing testi başarılı."
    else
        "${LOGGER}" SUCCESS "PERFECT: Fuzzing test successful."
    fi

    echo "- [${TIMESTAMP_START}] FUZZ: Property-based testing passed." >> "${NOTE_FILE}"

else

    if [[ "${L_LANG}" == "TR" ]]; then
        "${LOGGER}" ERROR "FUZZING İHLALİ! Mantıksal açık saptandı."
    else
        "${LOGGER}" ERROR "FUZZING VIOLATION detected."
    fi

    echo
    echo "[INVARIANTS FAILED]"
    grep "failing!" "${LOG_FILE}" | head -n 5 || true
    echo

    echo "- [${TIMESTAMP_START}] FUZZ_ALERT: Invariant violation detected." >> "${NOTE_FILE}"
    exit 1
fi

# -----------------------------------------------------------------------
# 5. Archiving
# -----------------------------------------------------------------------

ARCHIVE_NAME="fuzz_report_$(date '+%Y%m%d_%H%M%S').log"
ARCHIVE_PATH="${FUZZ_DIR}/${ARCHIVE_NAME}"

cp "${LOG_FILE}" "${ARCHIVE_PATH}"

if [[ "${L_LANG}" == "TR" ]]; then
    "${LOGGER}" INFO "Fuzzing raporu arşivlendi: ${ARCHIVE_PATH}"
else
    "${LOGGER}" INFO "Fuzzing report archived: ${ARCHIVE_PATH}"
fi

