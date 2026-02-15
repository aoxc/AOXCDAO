#!/usr/bin/env bash
# -----------------------------------------------------------------------
# AOXC DAO - PRO ULTIMATE VISUALIZATION ENGINE (v1.4.0-STABLE)
# Purpose: Forensic Architectural Mapping & Dependency Intelligence
# Standard: Solidity 0.8.33
# -----------------------------------------------------------------------

set -Eeuo pipefail
shopt -s globstar nullglob

# -----------------------------------------------------------------------
# Configuration
# -----------------------------------------------------------------------
L_LANG="${1:-TR}"
DATA_ROOT="data"
VISUAL_DIR="${DATA_ROOT}/registry/visuals"
LOG_NOTE="${DATA_ROOT}/notes/history.md"
LOGGER_PATH="./scripts/logger.sh"

mkdir -p "${VISUAL_DIR}"
mkdir -p "$(dirname "${LOG_NOTE}")"

# -----------------------------------------------------------------------
# Logger Initialization
# -----------------------------------------------------------------------
if [[ -f "${LOGGER_PATH}" ]]; then
    # shellcheck disable=SC1091
    source "${LOGGER_PATH}"
else
    echo "Fatal: logger.sh not found."
    exit 1
fi

# -----------------------------------------------------------------------
# Dependency Verification
# -----------------------------------------------------------------------
check_dep() {
    if ! command -v "$1" >/dev/null 2>&1; then
        log_error "Dependency missing: $1"
        exit 1
    fi
}

check_dep "surya"
check_dep "sol2uml"
check_dep "dot"

# -----------------------------------------------------------------------
# Localization
# -----------------------------------------------------------------------
if [[ "${L_LANG}" == "TR" ]]; then
    log_info "AOXC Mimari Görselleştirme Operasyonu Başlatıldı..."
    log_info "Call-Graph, Inheritance ve UML diyagramları üretiliyor..."
    SUCCESS_MSG="MİMARİ HARİTALAMA BAŞARILI"
    ERROR_MSG="Görselleştirme başarısız. Kaynak kod veya bağımlılıkları kontrol edin."
else
    log_info "AOXC Architectural Visualization Sequence Initiated..."
    log_info "Generating Call-Graph, Inheritance Tree and UML Diagram..."
    SUCCESS_MSG="ARCHITECTURAL MAPPING SUCCESS"
    ERROR_MSG="Visualization failed. Check source code or dependencies."
fi

# -----------------------------------------------------------------------
# File Collection
# -----------------------------------------------------------------------
SOL_FILES=(src/**/*.sol)

if [[ ${#SOL_FILES[@]} -eq 0 ]]; then
    log_error "No Solidity files found under ./src"
    exit 1
fi

DATE_TAG="$(date +%Y%m%d_%H%M%S)"

CALL_GRAPH_FILE="${VISUAL_DIR}/call_graph_${DATE_TAG}.png"
INHERIT_FILE="${VISUAL_DIR}/inheritance_${DATE_TAG}.png"
UML_FILE="${VISUAL_DIR}/class_diagram_${DATE_TAG}.svg"

# -----------------------------------------------------------------------
# Visualization Execution
# -----------------------------------------------------------------------
log_info "Generating Call Graph..."
if ! surya graph "${SOL_FILES[@]}" | dot -Tpng -o "${CALL_GRAPH_FILE}"; then
    log_error "Call Graph generation failed."
    exit 1
fi

log_info "Generating Inheritance Tree..."
if ! surya inheritance "${SOL_FILES[@]}" | dot -Tpng -o "${INHERIT_FILE}"; then
    log_error "Inheritance diagram generation failed."
    exit 1
fi

log_info "Generating UML Class Diagram..."
if ! sol2uml class ./src -o "${UML_FILE}"; then
    log_error "UML diagram generation failed."
    exit 1
fi

# -----------------------------------------------------------------------
# Reporting & Audit Note
# -----------------------------------------------------------------------
log_success "${SUCCESS_MSG}: ${VISUAL_DIR}"

{
    echo "- [$(date +'%Y-%m-%d %H:%M:%S')] VISUAL SNAPSHOT"
    echo "  - Call Graph: ${CALL_GRAPH_FILE}"
    echo "  - Inheritance: ${INHERIT_FILE}"
    echo "  - UML Diagram: ${UML_FILE}"
    echo ""
} >> "${LOG_NOTE}"

echo "----------------------------------------"
echo "Call Graph   : OK"
echo "Inheritance  : OK"
echo "UML Diagram  : OK"
echo "----------------------------------------"

