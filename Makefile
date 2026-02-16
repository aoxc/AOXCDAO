# -----------------------------------------------------------------------
# PROJECT  : AOXC DAO (AKDENIZ-V2)
# MODULE   : PRO ULTIMATE ORCHESTRATOR (THE MAESTRO)
# VERSION  : 2.0.0 (STABLE_GENESIS)
# ARCH     : Autonomous / Seal-Aware / JIT-Privileged
# -----------------------------------------------------------------------

SHELL        := /bin/bash
.SHELLFLAGS  := -eu -o pipefail -c

# ---- 1. ARCHITECTURE -------------------------------------------------
ROOT_DIR     := $(shell pwd)
SCRIPTS      := $(ROOT_DIR)/scripts
DATA_REG     := $(ROOT_DIR)/data/registry
MASTER_EXE   := $(SCRIPTS)/aoxc
INTEGRITY    := $(SCRIPTS)/engine_integrity.sh

# ---- 2. UI TELEMETRY -------------------------------------------------
C_CYAN       := \033[38;5;51m
C_GOLD       := \033[38;5;220m
C_RED        := \033[38;5;196m
C_GREEN      := \033[38;5;82m
NC           := \033[0m

# ---- 3. ORCHESTRATION PROTOCOLS (Zırh Delici Yetkiler) ---------------

# UNLOCK: Mühürleri sök ve tüm orkestrayı (24 engine) hazırla
define unlock_vault
	@echo -e "$(C_GOLD)[!] Orchestrator: Breaking Forensic Seals...$(NC)"
	@# 'chattr -i' ile işletim sistemi kilidini esnetiyoruz
	@sudo chattr -i $(SCRIPTS)/engine_*.sh $(SCRIPTS)/aoxc 2>/dev/null || true
	@# Tüm enstrümanlara icra yetkisi veriyoruz
	@chmod +x $(SCRIPTS)/aoxc $(SCRIPTS)/engine_*.sh
endef

# LOCK: Orkestrayı sessize al ve mühürle
define lock_vault
	@echo -e "$(C_RED)[!] Orchestrator: Engaging Dormant State...$(NC)"
	@chmod -x $(SCRIPTS)/aoxc $(SCRIPTS)/engine_*.sh 2>/dev/null || true
endef

# DISPATCH: Güvenlik süzgecinden geçerek icra et
define dispatch_v2
	$(call unlock_vault)
	@echo -e "$(C_CYAN)[v2.0.0] Forensic Integrity Check...$(NC)"
	@bash $(INTEGRITY) verify || (echo -e "$(C_RED)[ALERT] Integrity Void!$(NC)" && $(call lock_vault) && exit 1)
	@$(1)
	$(call lock_vault)
endef

# ---- 4. MISSION TARGETS ----------------------------------------------

.PHONY: all setup build audit seal terminal clean

all: terminal

# [GENESIS] 24 Engine'i sistemle tanıştır
setup:
	@echo -e "$(C_GOLD)[*] Establishing v2.0.0 Autonomous Baseline...$(NC)"
	$(call unlock_vault)
	@test -f $(MASTER_EXE) || (echo -e "$(C_RED)ERROR: Kernel $(MASTER_EXE) missing!$(NC)" && exit 1)
	@bash $(MASTER_EXE) --initialize-only
	@$(MAKE) seal
	$(call lock_vault)
	@echo -e "$(C_GREEN)[✔] System Genesis 2.0.0 Finalized & Locked.$(NC)"

# [BRIDGE] Terminali aç ve 24 motoru emrine sun
terminal:
	$(call unlock_vault)
	@echo -e "$(C_CYAN)[*] Opening Secure Bridge Session...$(NC)"
	@# Sentinel'i (aoxc) ateşle
	@bash $(MASTER_EXE)
	$(call lock_vault)
	@echo -e "$(C_GOLD)[!] Session Closed. Subsystems Re-Locked.$(NC)"

# [MORTAL_LOCK] Tüm cephaneliği kriptografik mühürle
seal:
	$(call unlock_vault)
	@echo -e "$(C_RED)[⚠️] APPLYING CRYPTOGRAPHIC MASTER SEAL TO ALL ENGINES...$(NC)"
	@bash $(INTEGRITY) seal
	@# Forensic vault ve tüm scriptleri fiziksel olarak dondur
	@sudo chattr +i $(DATA_REG)/.forensic_vault/*.seal $(SCRIPTS)/engine_*.sh $(SCRIPTS)/aoxc 2>/dev/null || true
	@echo -e "$(C_GREEN)[✔] All 24 Engines Sealed Immutable.$(NC)"

# [SYNTHESIS] 194 Dosyayı Derle
build:
	@$(call dispatch_v2, forge build --via-ir --optimize --optimizer-runs 200)

clean:
	@echo -e "$(C_GOLD)[!] Purging Synthesis Artifacts...$(NC)"
	@forge clean
	@rm -rf out cache
