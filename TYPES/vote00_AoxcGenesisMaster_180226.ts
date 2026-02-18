/**
 * @file vote00_AoxcGenesisMaster_180226.ts
 * @namespace AOXCDAO.Core.Governance
 * @version 2.0.0 AOXCDAO V2 AKDENIZ
 * @status IMMUTABLE_GOVERNANCE_ROOT
 * @compiler Solidity 0.8.33 Compatibility
 * @description 1B-Scale Neural Consensus. Quadratic Weighting mühürlendi.
 */

// Import path corrected to reference the Sovereign Master
// Not: sys00 dosyasının varlığından emin olmalıyız.
import { AOXC_GENESIS } from './sys00_AoxcGenesisMaster_180226.ts';

export enum PROPOSAL_TYPE {
    FLEET_DIRECTION = 0x01, 
    RESOURCE_REALLOC = 0x02, 
    SECURITY_LOCK    = 0x03, 
    CONSTITUTION     = 0x04, 
    CITIZEN_REWARD   = 0x05,
    SHARD_EVOLUTION  = 0x06  
}

export interface IGovernancePhysics {
    readonly QUORUM_PERCENTAGE: number; 
    readonly QUADRATIC_COEFFICIENT: number; 
    readonly VOTING_WINDOW_BLOCKS: number;  
    readonly VETO_THRESHOLD: number;     
}

export const GOVERNANCE_CONFIG = {
    PROTOCOL: 'NEURAL_VOTE_V6_QUADRATIC',
    TOTAL_SHARDS: AOXC_GENESIS.SCALE.TOTAL_SHARDS,
    MIN_MERIT_TO_PROPOSE: 10000, 
    VOTING_PRECISION: 18,
    VESSEL_ID: 0x05 // QUASAR
} as const;

export class GenesisGovernanceEngine {
    
    /**
     * @method calculateQuadraticWeight
     * @description Babylonian Method with truncation guard. 
     * Weight = sqrt(Merit * 10^18) for high-precision quadratic math.
     */
    public static calculateQuadraticWeight(meritScore: bigint): bigint {
        if (meritScore === BigInt(0)) return BigInt(0);
        
        const precisionMultiplier = BigInt(10) ** BigInt(18);
        const x = meritScore * precisionMultiplier;
        
        let z = (x + BigInt(1)) / BigInt(2);
        let y = x;
        while (z < y) {
            y = z;
            z = (x / z + z) / BigInt(2);
        }
        return y; 
    }

    /**
     * @method validateShardQuorum
     * @description Shard bazlı katılım kontrolü. 10% Quorum mühürlendi.
     */
    public static validateShardQuorum(shardPopulation: number, votesCast: number): boolean {
        if (shardPopulation === 0) return false;
        return (votesCast * 100) / shardPopulation >= 10;
    }

    /**
     * @method processGalacticConsensus
     * @description 1024 Shard'ın 2/3 (Super-majority) mutabakat kontrolü.
     */
    public static processGalacticConsensus(activeShardVotes: Map<number, boolean>): boolean {
        const totalActive = activeShardVotes.size;
        const MIN_SHARDS = GOVERNANCE_CONFIG.TOTAL_SHARDS / 2;
        
        if (totalActive < MIN_SHARDS) return false; 

        let support = 0;
        activeShardVotes.forEach((vote) => { if (vote) support++; });

        return (support * 100) / totalActive >= 67;
    }

    /**
     * @method executeSovereignVeto
     * @description sys00 RANK sabitlerine bağlandı.
     */
    public static executeSovereignVeto(authLevel: number, consensusCount: number): boolean {
        if (authLevel === AOXC_GENESIS.RANK.ADMIRAL) return true; 
        return authLevel >= AOXC_GENESIS.RANK.CAPTAIN && consensusCount >= 5; 
    }
}

export const VOTE_GENESIS_LOADED: boolean = true;
