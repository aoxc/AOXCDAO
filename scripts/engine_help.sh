#!/usr/bin/env bash
# -----------------------------------------------------------------------
# AOXC DAO - ELITE VECTOR COMMAND CENTER (v7.0.0-STABLE)
# -----------------------------------------------------------------------
# Solidity: 0.8.33
# OpenZeppelin: 5.5.x
# -----------------------------------------------------------------------

set -Eeuo pipefail
shopt -s nullglob

L_LANG="${1:-TR}"

DATA_ROOT="data"
NOTE_FILE="${DATA_ROOT}/notes/history.md"

TIME_NOW="$(date '+%H:%M:%S')"

# -----------------------------------------------------------------------
# Safe Metrics Collection
# -----------------------------------------------------------------------

count_sol() {
    local dir="$1"
    if [[ -d "${dir}" ]]; then
        find "${dir}" -type f -name '*.sol' 2>/dev/null | wc -l | tr -d ' '
    else
        echo "0"
    fi
}

FILE_COUNT="$(count_sol src)"
SEC_COUNT="$(count_sol src/security)"
INFRA_COUNT="$(count_sol src/infrastructure)"

if [[ -f "${NOTE_FILE}" ]]; then
    LAST_OP="$(tail -n 1 "${NOTE_FILE}" | cut -c 1-60)"
else
    LAST_OP="No History"
fi

# -----------------------------------------------------------------------
# Colors
# -----------------------------------------------------------------------

V_CYAN='\033[38;5;51m'
V_BLUE='\033[38;5;33m'
V_GREEN='\033[38;5;82m'
V_WHITE='\033[38;5;255m'
V_GOLD='\033[38;5;220m'
V_RED='\033[38;5;196m'
V_GREY='\033[38;5;244m'
NC='\033[0m'

# -----------------------------------------------------------------------
# Localization
# -----------------------------------------------------------------------

if [[ "${L_LANG}" == "TR" ]]; then
    H_TITLE="AOXC ADLİ YÖNETİŞİM KOMUTA MERKEZİ"
    H_STATUS="SİSTEM ÇEVRİMİÇİ"
    L_MEM="HAFIZA_İLERLEME"
    FOOTER="Sistem Solidity 0.8.33 & OpenZeppelin 5.5.x ile kalibre."
    DESC_BUILD="Derleme ve Akıllı Optimizasyon (via-IR)"
    DESC_TEST="Extreme Test Suite (Fuzz/Invariant/Unit)"
    DESC_GAS="Gaz Snapshot ve Verimlilik Raporu"
    DESC_SEC="Derin Güvenlik Taraması"
    DESC_FORM="Sembolik Mantık Doğrulama"
    DESC_MET="Kod Karmaşıklık & Risk Analizi"
    DESC_VIS="Mimari Bağımlılık Haritası"
    DESC_DEP="X-Layer Deploy & Verify"
else
    H_TITLE="AOXC FORENSIC COMMAND CENTER"
    H_STATUS="SYSTEM ONLINE"
    L_MEM="MEMORY_PROGRESS"
    FOOTER="System calibrated to Solidity 0.8.33 & OpenZeppelin 5.5.x."
    DESC_BUILD="Build & Optimization (via-IR)"
    DESC_TEST="Extreme Test Suite"
    DESC_GAS="Gas Snapshot & Efficiency"
    DESC_SEC="Deep Security Sweep"
    DESC_FORM="Symbolic Verification"
    DESC_MET="Code Complexity Analysis"
    DESC_VIS="Architecture Dependency Map"
    DESC_DEP="X-Layer Deploy & Verify"
fi

# -----------------------------------------------------------------------
# UI Render
# -----------------------------------------------------------------------

if [[ -t 1 ]]; then
    clear
fi

echo -e "${V_BLUE}🌀«««──────────────────────────────────────────────────────────────»»»🌀${NC}"
echo -e "${V_BLUE}║${NC} ${V_CYAN}AOXC OS PRO${NC} ${V_GREY}v7.0.0${NC} ${V_BLUE}»»»${NC} ${V_WHITE}${H_STATUS}${NC} ${V_BLUE}«««${NC} ${V_WHITE}T:${NC} ${V_GREY}${TIME_NOW}${NC} ${V_BLUE}║${NC}"
echo -e "${V_BLUE}╟────────────────────────────────────────────────────────────────────╢${NC}"

echo -e "  ${V_CYAN}🌀 ${H_TITLE}${NC} ${V_GREEN}INTEGRITY_LOCKED${NC}"
echo -e "${V_BLUE}╟────────────────────────────────────────────────────────────────────╢${NC}"

echo -e "  ${V_GREY}📊 DATA_METRICS »»»${NC} [${V_WHITE}FILES:${NC} ${V_GREEN}${FILE_COUNT}${NC}] [${V_WHITE}INFRA:${NC} ${V_GREEN}${INFRA_COUNT}${NC}] [${V_WHITE}SEC:${NC} ${V_GREEN}${SEC_COUNT}${NC}]"
echo -e "  ${V_GREY}🧠 ${L_MEM} »»»${NC} ${V_GOLD}${LAST_OP}${NC}"
echo -e "${V_BLUE}╟────────────────────────────────────────────────────────────────────╢${NC}"

# Core
printf "  ${V_GREEN}%-14s${NC} ${V_WHITE}%s${NC}\n" "make build"   "${DESC_BUILD}"
printf "  ${V_GREEN}%-14s${NC} ${V_WHITE}%s${NC}\n" "make test"    "${DESC_TEST}"
printf "  ${V_GREEN}%-14s${NC} ${V_WHITE}%s${NC}\n" "make gas"     "${DESC_GAS}"

echo

# Security
printf "  ${V_RED}%-14s${NC} ${V_WHITE}%s${NC}\n" "make security" "${DESC_SEC}"
printf "  ${V_RED}%-14s${NC} ${V_WHITE}%s${NC}\n" "make formal"   "${DESC_FORM}"

echo

# Analysis
printf "  ${V_CYAN}%-14s${NC} ${V_WHITE}%s${NC}\n" "make metrics"  "${DESC_MET}"
printf "  ${V_CYAN}%-14s${NC} ${V_WHITE}%s${NC}\n" "make visual"   "${DESC_VIS}"

echo

# Network
printf "  ${V_GOLD}%-14s${NC} ${V_WHITE}%s${NC}\n" "make deploy"   "${DESC_DEP}"

echo -e "${V_BLUE}🌀«««──────────────────────────────────────────────────────────────»»»🌀${NC}"
echo -e "  ${V_GREY}💡 ${FOOTER}${NC}"

