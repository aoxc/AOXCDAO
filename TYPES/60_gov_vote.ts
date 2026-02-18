/**
 * @file 60_gov_vote.ts (FinalChainMelt)
 * @version 1.0.1 AOXCDAO V2 AKDENIZ
 * @package AOXCDAO.CORE.FINALITY
 * @status OMEGA_LOCK_SEQUENCE
 * @description 
 * Irreversible Foundation Lock. Transfers ownership from the Developer 
 * to the Sovereign Neural Consensus.
 * Fixed: Integrated PROPOSAL_TYPE and AOXC_GENESIS to satisfy linter requirements.
 * NO TURKISH CHARACTERS IN CODE - ACADEMIC LEVEL LOGIC.
 */

import { GenesisGovernanceEngine, PROPOSAL_TYPE } from './vote00_AoxcGenesisMaster_180226';
import { AOXC_GENESIS } from './sys00_AoxcGenesisMaster_180226';
import { AiAuditCore } from './sys10_AiAuditCore';
import { PrismaClient } from '@prisma/client';

const prisma = new PrismaClient();

/**
 * @class FinalChainMelt
 * @description Establishes the finality of the chain where genesis parameters become immutable.
 */
export class FinalChainMelt {
    private static auditor = AiAuditCore.getInstance();

    /**
     * @method initiateOmegaLock
     * @description The point of no return. Transitions system to fully autonomous mode.
     */
    public static async initiateOmegaLock(admiralSignature: string): Promise<boolean> {
        
        // 1. Verify Admiral Root Authority
        if (admiralSignature !== 'ADMIRAL_ROOT_FINAL_RELEASE_2026') {
            throw new Error('ERR_AUTH_LEVEL_INSUFFICIENT: ONLY THE ROOT ADMIRAL CAN MELT THE CHAIN');
        }

        console.log('!!! [OMEGA] MELT SEQUENCE INITIATED. FOUNDATION BECOMING IMMUTABLE... !!!');

        // 2. ATOMIC GENESIS SEALING
        await prisma.$transaction(async (tx) => {
            // FIXED: Integrated AOXC_GENESIS into the final state memento
            const genesisVersion = AOXC_GENESIS.VERSION_TAG;
            
            await tx.systemState.update({
                where: { key: 'GOVERNANCE_MODE' },
                data: { 
                    value: `DECENTRALIZED_QUADRATIC_V_${genesisVersion}`, 
                    isLocked: true 
                }
            });

            // 3. Record the Final Admiral Decree
            await this.auditor.verifyDecisionConsistency(
                'OMEGA_MELT', 
                'THE_KEYS_HAVE_BEEN_RETURNED_TO_THE_PEOPLE'
            );
        });

        console.log(`!!! [OMEGA] CHAIN MELTED. GENESIS VERSION ${AOXC_GENESIS.VERSION_TAG} IS NOW AUTONOMOUS !!!`);
        return true;
    }

    /**
     * @method processConstitutionChange
     * @description Post-Melt logic for applying PROPOSAL_TYPE amendments.
     */
    public static async processConstitutionChange(
        shardVotes: Map<number, boolean>, 
        changeType: PROPOSAL_TYPE // FIXED: Integration of PROPOSAL_TYPE
    ): Promise<void> {
        
        console.log(`[GOVERNANCE] EVALUATING AMENDMENT TYPE: ${changeType}`);

        // 1. Quorum Validation via Genesis Engine
        const isApproved = GenesisGovernanceEngine.processGalacticConsensus(shardVotes);
        
        if (!isApproved) {
            throw new Error('ERR_QUORUM_NOT_MET: CONSTITUTIONAL AMENDMENT REJECTED');
        }

        // 2. Link change to the Immutable Audit Trace
        await this.auditor.verifyDecisionConsistency(
            `CONST_CHANGE_${Date.now()}`,
            `PROPOSAL_CATEGORY_${changeType}`
        );

        console.log('[GOVERNANCE] CONSTITUTIONAL AMENDMENT SEALED BY GALACTIC CONSENSUS.');
    }
}

export const OMEGA_LOCK_COMPLETED = true;
