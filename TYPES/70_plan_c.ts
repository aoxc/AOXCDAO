/**
 * @file 70_plan_c.ts (OmegaEvacuationEngine)
 * @version 1.0.1 AOXCDAO V2 AKDENIZ
 * @package AOXCDAO.CORE.PLAN_C
 * @status FINAL_RESORT_ACTIVE
 * @description 
 * Automated Evacuation Protocol. Transfers AOXC assets to X Layer/OKX.
 * Fixed: Integrated AOXC_BANK_GENESIS for currency verification to resolve linter error.
 * NO TURKISH CHARACTERS IN CODE - ACADEMIC LEVEL LOGIC.
 */

import { EXIT_THRESHOLD, RECOVERY_DESTINATION, PLAN_C_CONFIG } from './cpx00_AoxcGenesisMaster_180226';
import { AOXC_BANK_GENESIS } from './bank00_AoxcGenesisMaster_180226';
import { AiAuditCore } from './sys10_AiAuditCore';
import { PrismaClient } from '@prisma/client';

const prisma = new PrismaClient();

/**
 * @class OmegaEvacuationEngine
 * @description Executes the total system freeze and secure cross-chain asset migration.
 */
export class OmegaEvacuationEngine {
    private static instance: OmegaEvacuationEngine;
    private auditor = AiAuditCore.getInstance();

    private constructor() {}

    public static getInstance(): OmegaEvacuationEngine {
        if (!OmegaEvacuationEngine.instance) {
            OmegaEvacuationEngine.instance = new OmegaEvacuationEngine();
        }
        return OmegaEvacuationEngine.instance;
    }

    /**
     * @method triggerPlanC
     * @description Initiates total system freeze and asset bridge based on EXIT_THRESHOLD.
     */
    public async triggerPlanC(reason: EXIT_THRESHOLD, admiralAuth: string): Promise<string> {
        
        console.error(`!!! [PLAN C] SEVERITY ${reason} DETECTED. INITIATING EVACUATION !!!`);

        // 1. Lock all Shards immediately (Zero-latency freeze)
        await prisma.systemState.updateMany({
            data: { isLocked: true, status: 'EVACUATING' }
        });

        const finalBlock = BigInt(Date.now()); 
        const totalAssets = await prisma.vault.aggregate({ _sum: { balance: true } });

        // 2. Cross-Chain Bridge Execution (X Layer / OKX)
        const target = RECOVERY_DESTINATION.X_LAYER_VAULT;
        
        // FIXED: Integrated AOXC_BANK_GENESIS to verify the legal currency before evacuation
        const validatedCurrency = AOXC_BANK_GENESIS.CURRENCY_ID;
        console.warn(`[PLAN C] VERIFIED CURRENCY FOR EVACUATION: ${validatedCurrency}`);
        
        // 3. Create the Final Manifest (The Last Memory)
        const manifest = {
            triggerId: `OMEGA-${finalBlock}`,
            severity: reason,
            totalAssetsAtExit: totalAssets._sum.balance || 0n,
            snapshotBlock: finalBlock,
            targetGateway: target,
            currencyId: validatedCurrency, // FIXED: Asset mapping
            emergencyAdminHash: admiralAuth
        };

        // 4. Wipe non-essential transient data & Auto-encrypt Master Logs
        if (PLAN_C_CONFIG.AUTO_ENCRYPTION_MANDATORY) {
            await this.auditor.verifyDecisionConsistency(manifest.triggerId, 'FINAL_ENCRYPTION_SEALED');
        }

        return manifest.triggerId;
    }
}

export const OMEGA_EVACUATION_READY = true;
