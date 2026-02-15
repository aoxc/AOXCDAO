#!/usr/bin/env bash
# -----------------------------------------------------------------------
# AOXC DAO - PRO ULTIMATE EVM DISASSEMBLER ENGINE
# Version: 7.0.0 (Deterministic / Hardened / CI-Safe)
# Standard: Solidity 0.8.33 | EIP-170 Audit Ready
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

L_LANG="${1:-TR}"
ASM_DIR="$ROOT_DIR/logs/asm"
mkdir -p "$ASM_DIR"

LIMIT=24576
NON_COMPLIANT=0

# --------------------------------------------------
# Dependency Check
# --------------------------------------------------
if ! command -v forge >/dev/null 2>&1; then
    log_error "forge not installed"
    exit 1
fi

# --------------------------------------------------
# Build
# --------------------------------------------------
if [[ "$L_LANG" == "TR" ]]; then
    log_info "Proje derleniyor ve bytecode ayıklanıyor... (0.8.33 via-IR)"
else
    log_info "Compiling project and extracting bytecode... (0.8.33 via-IR)"
fi

if ! forge build --via-ir --optimize --optimizer-runs 200 >/dev/null; then
    log_error "Build failed"
    exit 1
fi

# --------------------------------------------------
# Contract Discovery (Array Safe)
# --------------------------------------------------
mapfile -t CONTRACTS < <(find "$ROOT_DIR/src" -type f -name "*.sol" -exec basename {} .sol \;)

if [[ ${#CONTRACTS[@]} -eq 0 ]]; then
    log_warn "No contracts found in src/"
    exit 0
fi

if [[ "$L_LANG" == "TR" ]]; then
    log_info "Adli Bytecode Analizi Başlatıldı (${#CONTRACTS[@]} Kontrat)..."
else
    log_info "Forensic Bytecode Analysis Initiated (${#CONTRACTS[@]} Contracts)..."
fi

# --------------------------------------------------
# Analysis Loop
# --------------------------------------------------
for contract in "${CONTRACTS[@]}"; do

    BYTECODE="$(forge inspect "$contract" deployedBytecode 2>/dev/null || true)"

    if [[ -z "$BYTECODE" || "$BYTECODE" == "0x" ]]; then
        continue
    fi

    CLEAN_HEX="${BYTECODE#0x}"
    SIZE=$(( ${#CLEAN_HEX} / 2 ))

    forge inspect "$contract" deployedBytecode > "$ASM_DIR/${contract}_raw.hex"
    forge inspect "$contract" opcodes > "$ASM_DIR/${contract}_ops.asm"

    if (( SIZE > LIMIT )); then
        NON_COMPLIANT=1
        if [[ "$L_LANG" == "TR" ]]; then
            log_warn "🚨 KRİTİK: $contract EIP-170 limitini aşıyor! (${SIZE}B / Max: ${LIMIT})"
        else
            log_warn "🚨 CRITICAL: $contract exceeds EIP-170 limit! (${SIZE}B / Max: ${LIMIT})"
        fi
    else
        printf "\033[38;5;82m  [✔] %-25s | Size: %dB\033[0m\n" "$contract" "$SIZE"
    fi
done

# --------------------------------------------------
# Final Report
# --------------------------------------------------
echo
echo "-----------------------------------------------------------------------"

if (( NON_COMPLIANT == 1 )); then
    if [[ "$L_LANG" == "TR" ]]; then
        log_error "EIP-170 uyumsuz kontratlar tespit edildi."
    else
        log_error "Non-compliant contracts detected (EIP-170)."
    fi
    exit 1
else
    if [[ "$L_LANG" == "TR" ]]; then
        log_success "Tüm kontratlar EIP-170 uyumlu."
    else
        log_success "All contracts are EIP-170 compliant."
    fi
    log_success "EVM Opcodes and Hex data archived: $ASM_DIR/"
    exit 0
fi

