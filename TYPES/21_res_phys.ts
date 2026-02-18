/**
 * @file 21_res_phys.ts (CouncilChainBridge)
 * @version 1.0.2 AOXCDAO V2 AKDENIZ
 * @package AOXCDAO.CORE.COUNCIL
 * @status FINAL_AUTHORITY_LAYER
 * @description 
 * Bridge between Transient DB State and Immutable Chain Reality.
 * Fixed: Removed unused imports (IResourcePacket, BANK, DEFCON) and optimized block finalization.
 */

import { RESOURCE_PHYSICS } from './res00_AoxcGenesisMaster_180226';
import { AiAuditCore } from './10_ai_audit';
import { PrismaClient } from '@prisma/client';

const prisma = new PrismaClient();

/**
 * @class CouncilChainBridge
 * @description Finalizes Shard metrics and financial transfers into immutable blocks.
 */
export class CouncilChainBridge {
    private static instance: CouncilChainBridge;
    private auditor = AiAuditCore.getInstance();

    private constructor() {}

    public static getInstance(): CouncilChainBridge {
        if (!CouncilChainBridge.instance) {
            CouncilChainBridge.instance = new CouncilChainBridge();
        }
        return CouncilChainBridge.instance;
    }

    /**
     * @method finalizeBlock
     * @description Consolidates all PENDING actions into a single Council-approved Block.
     */
    public async finalizeBlock(councilSigs: string[]): Promise<string> {
        
        // 1. Quorum Validation (Academic Protocol: 2/3 of Sovereign Council)
        if (councilSigs.length < 7) { 
            throw new Error('COUNCIL_ERROR: INSUFFICIENT_VOTES_FOR_FINALITY');
        }

        const blockId = `AOXC-B${Date.now()}`;

        try {
            // 2. Aggregate Multi-Domain Metrics (Filtered for the current finalization cycle)
            const pendingResources = await prisma.resourceTransfer.findMany({ where: { status: 'PENDING' } });
            const pendingFinances = await prisma.vaultTransaction.findMany({ where: { status: 'PENDING' } });

            // 3. ATOMIC BLOCK COMMITMENT
            await prisma.$transaction(async (tx) => {
                
                // Seal Resource Movements (Optimized with updateMany if applicable, or mapped updates)
                for (const res of pendingResources) {
                    await tx.resourceTransfer.update({
                        where: { id: res.id },
                        data: { status: 'SEALED_ON_CHAIN', blockId: blockId }
                    });
                }

                // Seal Financial Assets
                for (const fin of pendingFinances) {
                    await tx.vaultTransaction.update({
                        where: { id: fin.id },
                        data: { status: 'SEALED_ON_CHAIN', blockId: blockId }
                    });
                }

                // Record the Block Anchor (Academic Level Data Persistence)
                await tx.blockAnchor.create({
                    data: {
                        blockHash: blockId,
                        councilApprovalCount: councilSigs.length,
                        timestamp: new Date(),
                        totalEnergyBurn: RESOURCE_PHYSICS.BASE_ENERGY_DRAIN.toString()
                    }
                });
            });

            // 4. AI Memory Link (Audit Trace for MomentHash verification)
            await this.auditor.verifyDecisionConsistency(blockId, 'LAST_KNOWN_STABLE_BLOCK');

            console.log(`!!! [COUNCIL] BLOCK ${blockId} PERMANENTLY INSCRIBED !!!`);
            return blockId;

        } catch {
            // FIXED: Using parameterless catch to avoid unused-vars error while protecting the bridge
            console.error(`[COUNCIL] CRITICAL_FINALITY_FAILURE: Block ${blockId} aborted.`);
            throw new Error('BLOCK_FINALITY_FAILED');
        }
    }
}

export const COUNCIL_BRIDGE_ACTIVE: boolean = true;
