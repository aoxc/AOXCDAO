#!/usr/bin/env bash
# -----------------------------------------------------------------------
# AOXC DAO - GAS EVOLUTION TRACKER (v2.0.0-STABLE)
# -----------------------------------------------------------------------
# Solidity: 0.8.33
# Foundry: via-IR optimized snapshot analysis
# -----------------------------------------------------------------------

set -Eeuo pipefail

# -----------------------------------------------------------------------
# 1. Environment Configuration
# -----------------------------------------------------------------------

L_LANG="${1:-TR}"

DATA_ROOT="data"
GAS_DIR="${DATA_ROOT}/logs/gas"
SNAPSHOT_FILE="${GAS_DIR}/master.gas"
OLD_SNAPSHOT="${SNAPSHOT_FILE}.old"
DIFF_REPORT="${GAS_DIR}/gas_evolution_diff.md"
NOTE_FILE="${DATA_ROOT}/notes/history.md"
LOGGER="./scripts/logger.sh"

mkdir -p "${GAS_DIR}"
mkdir -p "$(dirname "${NOTE_FILE}")"

TIMESTAMP="$(date '+%Y-%m-%d %H:%M:%S')"

# -----------------------------------------------------------------------
# 2. Dependency Checks
# -----------------------------------------------------------------------

if ! command -v forge >/dev/null 2>&1; then
    echo "Forge is not installed or not in PATH."
    exit 1
fi

if [[ ! -x "${LOGGER}" ]]; then
    echo "Logger not found or not executable: ${LOGGER}"
    exit 1
fi

# -----------------------------------------------------------------------
# 3. Localization
# -----------------------------------------------------------------------

if [[ "${L_LANG}" == "TR" ]]; then
    MSG_START="AOXC Gaz Evrim Analizi başlatılıyor (0.8.33 via-IR)..."
    MSG_DIFF="Eski snapshot bulundu. Gaz fark raporu oluşturuluyor..."
    MSG_FIRST="İlk gaz snapshot oluşturuldu."
    MSG_DONE="Gaz analizi tamamlandı."
else
    MSG_START="Initiating AOXC Gas Evolution Analysis..."
    MSG_DIFF="Previous snapshot detected. Generating diff report..."
    MSG_FIRST="Initial gas snapshot created."
    MSG_DONE="Gas analysis complete."
fi

"${LOGGER}" INFO "${MSG_START}"

# -----------------------------------------------------------------------
# 4. Snapshot Capture
# -----------------------------------------------------------------------

HAS_OLD=false

if [[ -f "${SNAPSHOT_FILE}" ]]; then
    cp "${SNAPSHOT_FILE}" "${OLD_SNAPSHOT}"
    HAS_OLD=true
fi

if ! forge snapshot --via-ir --optimize --optimizer-runs 200 > "${SNAPSHOT_FILE}"; then
    "${LOGGER}" ERROR "Forge snapshot failed."
    exit 1
fi

# -----------------------------------------------------------------------
# 5. Differential Analysis
# -----------------------------------------------------------------------

if [[ "${HAS_OLD}" == true ]]; then

    "${LOGGER}" AUDIT "${MSG_DIFF}"

    {
        echo "# AOXC DAO - Gas Evolution Report"
        echo "Timestamp: ${TIMESTAMP}"
        echo
        echo "## Gas Variance Table"
        echo
        echo '```diff'
        diff -u "${OLD_SNAPSHOT}" "${SNAPSHOT_FILE}" || true
        echo '```'
    } > "${DIFF_REPORT}"

    # Count real diff lines (ignore headers)
    CHANGE_COUNT="$(
        diff -u "${OLD_SNAPSHOT}" "${SNAPSHOT_FILE}" \
        | grep -E '^[+-]' \
        | grep -Ev '^\+\+\+|^---' \
        | wc -l \
        | tr -d ' '
    )"

    if [[ "${CHANGE_COUNT}" -gt 0 ]]; then
        if [[ "${L_LANG}" == "TR" ]]; then
            "${LOGGER}" WARN "GAS_EVOL: ${CHANGE_COUNT} değişiklik saptandı."
        else
            "${LOGGER}" WARN "GAS_EVOL: ${CHANGE_COUNT} changes detected."
        fi

        echo "- [${TIMESTAMP}] GAS_DIFF: ${CHANGE_COUNT} changes detected." >> "${NOTE_FILE}"

        echo
        echo "[SUMMARY OF CHANGES]"
        diff -u "${OLD_SNAPSHOT}" "${SNAPSHOT_FILE}" \
            | grep -E '^[+-]' \
            | grep -Ev '^\+\+\+|^---' \
            | head -n 10 || true
        echo
    else
        echo "- [${TIMESTAMP}] GAS: No changes detected." >> "${NOTE_FILE}"
    fi

else
    "${LOGGER}" SUCCESS "${MSG_FIRST}"
    echo "- [${TIMESTAMP}] GAS_INIT: Master snapshot established." >> "${NOTE_FILE}"
fi

# -----------------------------------------------------------------------
# 6. Finalization
# -----------------------------------------------------------------------

"${LOGGER}" SUCCESS "${MSG_DONE}"

