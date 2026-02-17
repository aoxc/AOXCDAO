#!/usr/bin/env bash
# -----------------------------------------------------------------------
# MODULE   : AOXC UNIVERSAL TRANSLATOR
# VERSION  : 2.0.0-GENESIS
# PURPOSE  : Hardware Abstraction & OS Neutralization
# -----------------------------------------------------------------------

# Deterministik İşletim Sistemi Analizi
detect_environment() {
    local os_raw
    os_raw="$(uname -s)"
    case "$os_raw" in
        Linux*)   export AOXC_OS="LINUX" ;;
        Darwin*)  export AOXC_OS="MACOS" ;;
        MINGW*)   export AOXC_OS="WINDOWS" ;;
        *)        export AOXC_OS="POSIX_COMPLIANT" ;;
    esac
}

# Sanal Ortam (Virtualenv) Yol Standardizasyonu
resolve_venv_path() {
    if [[ "${AOXC_OS:-}" == "WINDOWS" ]]; then
        echo "$AOXC_ROOT/.venv/Scripts/activate"
    else
        echo "$AOXC_ROOT/.venv/bin/activate"
    fi
}

# Adli Mühürleme Protokolleri (Immutable Flag Management)
execute_seal_protocol() {
    local mode=$1    # [seal | unseal]
    local target=$2
    
    if [[ "$AOXC_OS" == "LINUX" ]]; then
        if [[ "$mode" == "seal" ]]; then
            sudo chattr +i "$target" 2>/dev/null || true
        else
            sudo chattr -i "$target" 2>/dev/null || true
        fi
    elif [[ "$AOXC_OS" == "MACOS" ]]; then
        if [[ "$mode" == "seal" ]]; then
            sudo chflags uchg "$target" 2>/dev/null || true
        else
            sudo chflags nouchg "$target" 2>/dev/null || true
        fi
    fi
}

detect_environment
