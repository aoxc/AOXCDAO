#!/usr/bin/env bash
# -----------------------------------------------------------------------
# AOXC DAO - Deterministic Deployment & Verification Engine
# Version: 3.0.0 (Hardened / Deterministic / Production-Grade)
# -----------------------------------------------------------------------

set -Eeuo pipefail
IFS=$'\n\t'

# --------------------------------------------------
# Exit Codes
# 0 = Success
# 1 = Deployment Failed
# 2 = Config Missing / Invalid
# 3 = Tool Missing
# --------------------------------------------------

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
LOGGER="$SCRIPT_DIR/logger.sh"

if [[ ! -f "$LOGGER" ]]; then
    echo "Fatal: logger.sh missing"
    exit 2
fi
# shellcheck disable=SC1090
source "$LOGGER"

# --------------------------------------------------
# Safe .env Loader (No Code Execution)
# --------------------------------------------------
ENV_FILE="$ROOT_DIR/.env"

if [[ ! -f "$ENV_FILE" ]]; then
    log_error ".env file missing"
    exit 2
fi

while IFS='=' read -r key value; do
    [[ -z "$key" || "$key" =~ ^# ]] && continue
    key="$(echo "$key" | xargs)"
    value="$(echo "$value" | xargs)"
    export "$key=$value"
done < "$ENV_FILE"

# --------------------------------------------------
# Network Selection + Validation
# --------------------------------------------------
NETWORK="${1:-${DEFAULT_NETWORK:-testnet}}"
LANGUAGE="${2:-EN}"

VALID_NETWORKS=("mainnet" "testnet" "sepolia" "arbitrum")

if [[ ! " ${VALID_NETWORKS[*]} " =~ " $NETWORK " ]]; then
    log_error "Invalid network: $NETWORK"
    exit 2
fi

# --------------------------------------------------
# Tool Check
# --------------------------------------------------
if ! command -v forge >/dev/null 2>&1; then
    log_error "forge not installed"
    exit 3
fi

# --------------------------------------------------
# Network Configuration
# --------------------------------------------------
RPC_VAR="RPC_${NETWORK^^}"
CHAIN_VAR="CHAIN_ID_${NETWORK^^}"
VERIFIER_VAR="VERIFIER_URL_${NETWORK^^}"

RPC_URL="${!RPC_VAR:-}"
CHAIN_ID="${!CHAIN_VAR:-}"
VERIFIER_URL="${!VERIFIER_VAR:-${DEFAULT_VERIFIER_URL:-}}"

if [[ -z "$RPC_URL" || -z "$CHAIN_ID" ]]; then
    log_error "Missing RPC or Chain ID for network: $NETWORK"
    exit 2
fi

if [[ -z "${PRIVATE_KEY:-}" ]]; then
    log_error "PRIVATE_KEY not set in .env"
    exit 2
fi

# Prevent CLI leakage
export ETH_PRIVATE_KEY="$PRIVATE_KEY"

# --------------------------------------------------
# Mandatory Security Gate
# --------------------------------------------------
AUDIT_SCRIPT="$SCRIPT_DIR/engine_audit.sh"

if [[ ! -x "$AUDIT_SCRIPT" ]]; then
    log_error "Security Gate missing or not executable"
    exit 1
fi

log_info "Running Security Gate..."
if ! "$AUDIT_SCRIPT" all "$LANGUAGE"; then
    log_error "Deploy blocked by Security Gate"
    exit 1
fi

# --------------------------------------------------
# Logging Setup
# --------------------------------------------------
DATA_ROOT="${DATA_ROOT:-data}"
DEPLOY_LOG="$DATA_ROOT/logs/deployments"
NOTE_FILE="$DATA_ROOT/notes/history.md"

mkdir -p "$DEPLOY_LOG"
mkdir -p "$(dirname "$NOTE_FILE")"

TIMESTAMP="$(date +'%Y-%m-%d %H:%M:%S')"
LOG_FILE="$DEPLOY_LOG/deploy_$(date +%Y%m%d_%H%M%S).log"

GIT_HASH="$(git rev-parse --short HEAD 2>/dev/null || echo "no-git")"

log_info "Deployment initiated"
log_info "Network: $NETWORK | Chain ID: $CHAIN_ID | Commit: $GIT_HASH"

# --------------------------------------------------
# Deterministic Forge Args
# --------------------------------------------------
FORGE_ARGS=(
    --rpc-url "$RPC_URL"
    --chain-id "$CHAIN_ID"
    --broadcast
    --verify
    --via-ir
    --slow
    -vvvv
)

[[ -n "$VERIFIER_URL" ]] && FORGE_ARGS+=(--verifier-url "$VERIFIER_URL")
[[ -n "${OKLINK_API_KEY:-}" ]] && FORGE_ARGS+=(--api-key "$OKLINK_API_KEY")

# --------------------------------------------------
# Deployment Execution
# --------------------------------------------------
log_warn "Broadcasting transactions..."

if forge script script/Deploy.s.sol:DeployScript \
    "${FORGE_ARGS[@]}" | tee "$LOG_FILE"; then
    DEPLOY_EXIT_CODE=0
else
    DEPLOY_EXIT_CODE=1
fi

# --------------------------------------------------
# Bytecode Hash Extraction (If Available)
# --------------------------------------------------
BYTECODE_HASH="unknown"

if [[ -f "$ROOT_DIR/out/Deploy.s.sol/DeployScript.json" ]]; then
    BYTECODE_HASH="$(sha256sum "$ROOT_DIR/out/Deploy.s.sol/DeployScript.json" | cut -d ' ' -f1)"
fi

# --------------------------------------------------
# Result Handling
# --------------------------------------------------
if [[ "$DEPLOY_EXIT_CODE" -eq 0 ]]; then
    log_success "Deployment successful"

    echo "- [$TIMESTAMP] 🚀 DEPLOY SUCCESS | NET:$NETWORK | CHAIN:$CHAIN_ID | COMMIT:$GIT_HASH | BYTECODE:$BYTECODE_HASH" \
        >> "$NOTE_FILE"

    exit 0
else
    log_error "Deployment failed"

    echo "- [$TIMESTAMP] ❌ DEPLOY FAIL | NET:$NETWORK | COMMIT:$GIT_HASH" \
        >> "$NOTE_FILE"

    exit 1
fi

