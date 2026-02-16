/**
 * @file contract.ts
 * @namespace AOXCDAO.Core.Contracts
 * @version 2.0.0
 * @description Smart Contract & Reward Definitions - (Identity-Enhanced)
 * Defines vessel-specific contract types, duration logic, and risk-reward modifiers.
 */

/**
 * @constant VESSEL_CONTRACT_TYPES
 * @description Domain-specific contract identifiers for each vessel's primary function.
 */
export const VESSEL_CONTRACT_TYPES = {
    VIRGO_EXTRACT:    0xb211, // Resource extraction (Defense-Heavy)
    AQUILA_LEND:      0xb321, // Credit/Lending (Economy-Heavy)
    PEGASUS_VALIDATE: 0xb531, // Data validation (Tech-Heavy)
    QUASAR_PATROL:    0xb641, // Security/Patrol (Combat-Heavy)
} as const;

/**
 * @enum CONTRACT_DURATION
 * @description Temporal constants for contract lifecycle management.
 */
export enum CONTRACT_DURATION {
    INSTANT = 0xd01, // Flash contracts (Real-time/Minutes)
    VOYAGE  = 0xd02, // Long-term missions (Multi-cycle/Weeks)
}

/**
 * @constant RISK_MODIFIERS
 * @description Reward multipliers based on mission danger and required Merit.
 */
export const RISK_MODIFIERS = {
    STABLE:   0x01, // 1x Baseline Reward
    CRITICAL: 0x05, // 5x High-Risk Reward
} as const;

/**
 * @enum REWARD_MODES
 * @description Incentivization types for successful contract execution.
 */
export enum REWARD_MODES {
    TOKEN = 0xe1, // Liquid Currency (AOXC-Credits)
    MERIT = 0xe2, // Reputation & Governance Power
    BADGE = 0xe3, // Rank/NFT Titles & Achievement Markers
}

/**
 * @enum EXECUTION_STATUS
 * @description State-machine for contract lifecycle and dispute resolution.
 */
export enum EXECUTION_STATUS {
    INITIATED = 0x71, // Active and ongoing
    COMPLETED = 0x72, // Successfully executed
    FAILED    = 0x73, // Breach detected or mission failure
    DISPUTE   = 0x74, // Frozen for Arbitration
}

// -----------------------------------------------------------------------------
// ACADEMIC TYPE DEFINITIONS (v2.0.0 UPDATED)
// -----------------------------------------------------------------------------

export type ContractType = (typeof VESSEL_CONTRACT_TYPES)[keyof typeof VESSEL_CONTRACT_TYPES];

/**
 * @interface IContractAgreement
 * @description Formal structure for an on-chain contract binding an entity to a mission.
 */
export interface IContractAgreement {
    readonly contract_id: string; 
    readonly type: ContractType;
    readonly contractor: string; 
    readonly duration: CONTRACT_DURATION;
    readonly risk_level: number; 
    readonly reward_mode: REWARD_MODES;
    readonly status: EXECUTION_STATUS;
    readonly collateral_amount: bigint; 
    readonly signed_at: number; 
}

/**
 * @class ContractIntegrityManager
 * @description Active logic for contract validation, reward calculation, and penalties.
 */
export class ContractIntegrityManager {
    /**
     * @method calculateTotalReward
     * @description Computes the final reward based on base amount and risk modifiers.
     */
    public static calculateTotalReward(baseAmount: bigint, riskLevel: number): bigint {
        const multiplier = riskLevel === RISK_MODIFIERS.CRITICAL ? 5n : 1n;
        return baseAmount * multiplier;
    }

    /**
     * @method verifyMeritRequirement
     * @description Checks if the contractor's Merit Rank is sufficient for CRITICAL missions.
     */
    public static verifyMeritRequirement(riskLevel: number, entityMerit: number): boolean {
        if (riskLevel === RISK_MODIFIERS.CRITICAL) {
            // High-risk missions require at least 0.8 (80%) Merit Rank
            return entityMerit >= 0.8;
        }
        return true;
    }

    /**
     * @method processPenalty
     * @description Logic for slashing collateral in case of EXECUTION_STATUS.FAILED.
     */
    public static processPenalty(collateral: bigint, failureReason: string): bigint {
        // Standard penalty: 50% Slash for functional failures, 100% for breaches
        const isBreach = failureReason.includes("SECURITY_BREACH");
        return isBreach ? 0n : collateral / 2n;
    }

    /**
     * @method isEscalationNeeded
     * @description Determines if a dispute requires Andromeda Prime intervention.
     */
    public static isEscalationNeeded(status: EXECUTION_STATUS): boolean {
        return status === EXECUTION_STATUS.DISPUTE;
    }
}

/**
 * @description Verification flag for system-wide integrity checks.
 */
export const CONTRACT_SYSTEM_LOADED: boolean = true;
