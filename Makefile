# -----------------------------------------------------------------------
# AOXC DAO - PRO ULTIMATE ORCHESTRATOR (V1.1.0-HARDENED)
# -----------------------------------------------------------------------
# Standard: Solidity 0.8.33
# Core    : GNU Make 4.0+
# Mode    : DEV | RELEASE
# -----------------------------------------------------------------------

SHELL            := /bin/bash
.SHELLFLAGS      := -eu -o pipefail -c

LANG             ?= TR
VERSION          := 1.1.0
MODE             ?= DEV          # DEV or RELEASE

# ---- Core Paths ----------------------------------------------------

SCRIPTS          := ./scripts
DATA_DIRS        := data/registry data/notes data/state data/logs logs/audits reports docs/src

INTEGRITY_ENG    := $(SCRIPTS)/engine_integrity.sh
SHIELD           := $(SCRIPTS)/engine_shield.sh
USER_GUARD       := $(SCRIPTS)/engine_user.sh
KERNEL           := $(SCRIPTS)/kernel.sh
CLI_ENG          := $(SCRIPTS)/engine_cli.sh
FORGE_ENG        := $(SCRIPTS)/engine_forge.sh
AUDIT_ENG        := $(SCRIPTS)/engine_audit.sh
SLITHER_ENG      := $(SCRIPTS)/engine_slither.sh
FORMAL_ENG       := $(SCRIPTS)/engine_formal.sh
DATA_ENG         := $(SCRIPTS)/engine_data.sh
FUZZ_ENG         := $(SCRIPTS)/engine_fuzz.sh

# ---- UI ------------------------------------------------------------

C_GREEN          := \033[38;5;82m
C_GOLD           := \033[38;5;220m
C_RED            := \033[38;5;196m
NC               := \033[0m

# ---- PATH Repair ---------------------------------------------------

V_ENV_PATH_REPAIR := export PATH="$$PATH:$$(pnpm bin -g 2>/dev/null || yarn global bin 2>/dev/null || npm bin -g 2>/dev/null):$$(pwd)/node_modules/.bin:$$HOME/.foundry/bin"

# ---- Core Wrapper --------------------------------------------------

define secure_env
	@mkdir -p $(DATA_DIRS)
	@chmod +x $(SCRIPTS)/*.sh 2>/dev/null || true
	@$(USER_GUARD) $(LANG)
	@if [ "$(MODE)" = "RELEASE" ]; then \
		$(INTEGRITY_ENG) verify; \
	fi
	@$(SHIELD) audit
	@$(V_ENV_PATH_REPAIR)
	@$(1)
endef

# ---- Phony ---------------------------------------------------------

.PHONY: all setup build test security slither formal fuzz seal clean terminal update help

# --------------------------------------------------------------------
# 🚀 Default Gateway
# --------------------------------------------------------------------

all: terminal

# --------------------------------------------------------------------
# ⚙️ Setup
# --------------------------------------------------------------------

setup:
	@chmod +x $(SCRIPTS)/*.sh
	@$(USER_GUARD) $(LANG)
	@./$(KERNEL) $(LANG)
	@$(call secure_env, forge install)
	@echo "$$(date) - Setup V$(VERSION) Complete" >> data/notes/history.md
	@echo -e "$(C_GREEN)[✔] Setup Complete (Mode: $(MODE))$(NC)"

# --------------------------------------------------------------------
# 🛠 Build & Test
# --------------------------------------------------------------------

build:
	$(call secure_env, $(FORGE_ENG) build $(LANG))

test:
	$(call secure_env, $(FORGE_ENG) test $(LANG))

# --------------------------------------------------------------------
# 🔍 Analysis
# --------------------------------------------------------------------

security:
	$(call secure_env, $(AUDIT_ENG) all $(LANG))

slither:
	$(call secure_env, $(SLITHER_ENG) $(LANG))

formal:
	$(call secure_env, $(FORMAL_ENG) $(LANG))

fuzz:
	$(call secure_env, $(FUZZ_ENG) $(LANG))

# --------------------------------------------------------------------
# 🔐 Integrity Management
# --------------------------------------------------------------------

seal:
	@chmod +x $(INTEGRITY_ENG)
	@$(INTEGRITY_ENG) seal
	@echo -e "$(C_GREEN)[✔] System sealed for release.$(NC)"

# --------------------------------------------------------------------
# 🖥 CLI Terminal
# --------------------------------------------------------------------

terminal:
	$(call secure_env, $(CLI_ENG) $(LANG))

# --------------------------------------------------------------------
# 🧹 Maintenance
# --------------------------------------------------------------------

clean:
	@$(V_ENV_PATH_REPAIR)
	@forge clean || true
	@rm -rf out cache data/registry/.user_accepted
	@echo -e "$(C_GOLD)[!] System cleaned (V$(VERSION)).$(NC)"

update:
	@git pull origin main
	@$(MAKE) setup

# --------------------------------------------------------------------
# 📖 Help
# --------------------------------------------------------------------

help:
	@echo ""
	@echo "AOXC DAO - Orchestrator V$(VERSION)"
	@echo "Mode: $(MODE)"
	@echo ""
	@echo "Targets:"
	@echo "  make setup"
	@echo "  make build"
	@echo "  make test"
	@echo "  make security"
	@echo "  make seal"
	@echo "  make terminal"
	@echo ""

