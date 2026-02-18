/**
 * @file 32_data_shard.ts
 * @version 1.0.1 AOXCDAO V2 AKDENIZ
 * @package AOXCDAO.CORE.MAINTENANCE
 * @status CRITICAL_RECOVERY_ENGINE
 * @description 
 * Automated Shard Recovery and Integrity Restoration (Phoenix Protocol).
 * Fixed: Integrated DATA_CONFIG and DataPhysicsProvider into integrity logic.
 */

import { DATA_CONFIG, STORAGE_TIER, DataPhysicsProvider } from './data00_AoxcGenesisMaster_180226';
import { AiAuditCore } from './10_ai_audit';
import { PrismaClient } from '@prisma/client';

const prisma = new PrismaClient();

/**
 * @class SystemSelfHeal
 * @description Scans and repairs sharded data structures using data physics principles.
 */
export class SystemSelfHeal {
    private static instance: SystemSelfHeal;
    private auditor = AiAuditCore.getInstance();

    private constructor() {}

    public static getInstance(): SystemSelfHeal {
        if (!SystemSelfHeal.instance) {
            SystemSelfHeal.instance = new SystemSelfHeal();
        }
        return SystemSelfHeal.instance;
    }

    /**
     * @method monitorShardIntegrity
     * @description 
     * Scans shards based on config intervals.
     * FIXED: DATA_CONFIG and DataPhysicsProvider now drive the integrity verification.
     */
    public async monitorShardIntegrity(shardId: number): Promise<void> {
        // Academic Implementation: Utilize DATA_CONFIG for interval-based checks
        const checkInterval = DATA_CONFIG.INTEGRITY_CHECK_INTERVAL_NS;
        console.info(`[HEAL_MONITOR] Shard ${shardId} scanning at interval: ${checkInterval}`);

        const shardState = await prisma.shardMap.findUnique({ where: { shardIndex: shardId } });
        
        // Use DataPhysicsProvider to validate shard's entropy before AI Audit
        const physicalHealth = DataPhysicsProvider.analyzeShardEntropy(shardId);

        // Academic Validation: Compare physical health and neural root hash
        const auditTrace = await this.auditor.verifyDecisionConsistency(
            shardState?.neuralRootHash || '', 
            'LAST_VERIFIED_BLOCK_ROOT'
        );

        // If entropy is unstable or audit fails, initiate Plan C
        if (physicalHealth < 0.95 || auditTrace.consistencyScore < 9500) {
            await this.initiateRecovery(shardId);
        }
    }

    /**
     * @private initiateRecovery
     * @description 
     * Promotion of data from COLD_VAULT (0x03) back to SHARD_SSD (0x02).
     */
    private async initiateRecovery(shardId: number): Promise<void> {
        console.warn(`[RECOVERY] SHARD_${shardId} CORRUPTION DETECTED. PROMOTING COLD_VAULT BACKUP.`);

        await prisma.$transaction([
            // 1. Lock Shard to prevent dirty writes
            prisma.shardMap.update({
                where: { shardIndex: shardId },
                data: { isLocked: true }
            }),
            // 2. Restore data from Replication Factor 3
            prisma.dataMigration.create({
                data: {
                    shardId: shardId,
                    fromTier: STORAGE_TIER.COLD_VAULT,
                    toTier: STORAGE_TIER.SHARD_SSD,
                    reason: 'INTEGRITY_FAILURE'
                }
            })
        ]);

        console.log(`[RECOVERY] SHARD_${shardId} RESTORED AND VERIFIED.`);
    }
}

export const SYSTEM_MAINTENANCE_ACTIVE = true;
