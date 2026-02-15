#!/usr/bin/env bash
# -----------------------------------------------------------------------
# AOXC DAO - PRO FORGE COMMAND ENGINE (v2.0.0-STABLE)
# -----------------------------------------------------------------------
# Solidity: 0.8.33
# Foundry: via-IR optimized build system
# -----------------------------------------------------------------------

set -Eeuo pipefail

# -----------------------------------------------------------------------
# 1. Environment Configuration
# -----------------------------------------------------------------------

COMMAND="${1:-}"
L_LANG="${2:-TR}"

DATA_ROOT="data"
LOG_DIR="${DATA_ROOT}/logs/forge"
ERROR_LOG="${LOG_DIR}/forge_error.log"
SUCCESS_LOG="${LOG_DIR}/forge_success.log"
NOTE_FILE="${DATA_ROOT}/notes/history.md"
LOGGER="./scripts/logger.sh"

mkdir -p "${LOG_DIR}"
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
# 3. Localization Matrix
# -----------------------------------------------------------------------

declare -A MSG

if [[ "${L_LANG}" == "TR" ]]; then
    MSG[start]="AOXC Derleme Motoru Başlatıldı (Solc 0.8.33 / via-IR)..."
    MSG[ok]="Derleme Başarılı (ABI, UserDoc, DevDoc senkronize edildi)."
    MSG[fail]="DERLEME HATASI! Log dosyasını inceleyin:"
    MSG[test]="Extreme Test Suite başlatılıyor..."
    MSG[size]="Bytecode Boyut Analizi (EIP-170)..."
    MSG[gas]="Gaz Snapshot Analizi yapılıyor..."
    MSG[usage]="Kullanım: $0 {build|test|size|gas} [TR|EN]"
else
    MSG[start]="AOXC Build Engine Started (Solc 0.8.33 / via-IR)..."
    MSG[ok]="Build Successful (ABI, UserDoc, DevDoc synchronized)."
    MSG[fail]="BUILD FAILED! Check log file:"
    MSG[test]="Initiating Extreme Test Suite..."
    MSG[size]="Bytecode Size Analysis (EIP-170)..."
    MSG[gas]="Gas Snapshot Analysis running..."
    MSG[usage]="Usage: $0 {build|test|size|gas} [TR|EN]"
fi

# -----------------------------------------------------------------------
# 4. Execution Matrix
# -----------------------------------------------------------------------

case "${COMMAND}" in

    build)
        "${LOGGER}" INFO "${MSG[start]}"

        if forge build \
            --extra-output-files abi userdoc devdoc \
            --via-ir \
            --optimize \
            --optimizer-runs 200 \
            >"${SUCCESS_LOG}" 2>"${ERROR_LOG}"
        then
            "${LOGGER}" SUCCESS "${MSG[ok]}"

            FILE_COUNT="$(find src -type f -name '*.sol' | wc -l | tr -d ' ')"

            echo "- [${TIMESTAMP}] BUILD: Compiled ${FILE_COUNT} contracts successfully." >> "${NOTE_FILE}"
        else
            "${LOGGER}" ERROR "${MSG[fail]} ${ERROR_LOG}"
            echo "- [${TIMESTAMP}] BUILD_ERROR: Compilation failed." >> "${NOTE_FILE}"
            tail -n 15 "${ERROR_LOG}" || true
            exit 1
        fi
        ;;

    test)
        "${LOGGER}" INFO "${MSG[test]}"

        if forge test -vvv --gas-report --summary; then
            echo "- [${TIMESTAMP}] TEST: All tests passed." >> "${NOTE_FILE}"
        else
            echo "- [${TIMESTAMP}] TEST_FAIL: Unit tests failed." >> "${NOTE_FILE}"
            exit 1
        fi
        ;;

    size)
        "${LOGGER}" INFO "${MSG[size]}"
        forge build --sizes
        ;;

    gas)
        "${LOGGER}" INFO "${MSG[gas]}"
        forge snapshot --check-gas
        ;;

    *)
        "${LOGGER}" WARN "${MSG[usage]}"
        exit 1
        ;;
esac

