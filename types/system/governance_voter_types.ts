/**
 * @file governance_voter_types.ts
 * @namespace AOXCDAO.Core.Governance
 * @version 2.0.1
 * @description Master Voting and Electoral Mechanics - (Power-Locked)
 * Standardized Hex values for Pro-Ultimate system integrity.
 */

/**
 * @enum VOTE_WEIGHT_MULTIPLIER
 * @description Defines the voting power of different classes.
 */
export enum VOTE_WEIGHT_MULTIPLIER {
    SOVEREIGN_ELITE    = 10, // Founder/Captain level: 10x weight
    COMMAND_OFFICER    = 5,  // Senior Officers: 5x weight
    RESEARCH_SCIENTIST = 2,  // Specialized experts: 2x weight
    CIVILIAN_STANDARD  = 1,  // Standard inhabitants: 1x weight
}

/**
 * @enum PROPOSAL_CATEGORY
 * @description Types of decisions that require a formal vote.
 * Using 0xD (Decision) hex prefix for compliant hexadecimal values.
 */
export enum PROPOSAL_CATEGORY {
    COURSE_CORRECTION  = 0xd01, // Changing the vessel's destination
    BUDGET_ALLOCATION  = 0xd02, // Spending from finance.ts treasury
    LAW_AMENDMENT      = 0xd03, // Modifying hierarchy.ts or discipline.ts
    EMERGENCY_OVERRIDE = 0xd04, // Critical safety decisions
}

/**
 * @constant GOVERNANCE_CONSTANTS
 * @description Strict timeframes and thresholds for valid elections.
 */
export const GOVERNANCE_CONSTANTS = {
    VOTING_DURATION_BLOCKS:   43200, // ~24 Hours on XLayer (2s blocks)
    MIN_QUORUM_PERCENT:       15,    // Minimum 15% participation
    MAJORITY_THRESHOLD:       51,    // Standard majority (51%)
    SUPER_MAJORITY_THRESHOLD: 66,    // Critical changes (66%)
    COOL_DOWN_PERIOD_BLOCKS:  21600, // ~12 Hours delay before execution
} as const;

// -----------------------------------------------------------------------------
// ACADEMIC TYPE DEFINITIONS (v2.0.1 UPDATED)
// -----------------------------------------------------------------------------

/**
 * @interface IVotingPower
 * @description Calculates a passenger's influence based on Merit and Class.
 */
export interface IVotingPower {
    readonly entity_id: string;
    readonly base_weight: VOTE_WEIGHT_MULTIPLIER;
    readonly merit_bonus: number; // Percentage increase from merit.ts
    readonly total_power: bigint; // Calculated: (Base * (1 + MeritBonus))
}

/**
 * @interface IProposalManifest
 * @description Structure of a formal AOXC proposal on XLayer.
 */
export interface IProposalManifest {
    readonly proposal_id: string;
    readonly proposer_id: string;
    readonly category: PROPOSAL_CATEGORY;
    readonly description_hash: string; // IPFS CID
    readonly start_block: number;
    readonly end_block: number;
    readonly for_votes: bigint;
    readonly against_votes: bigint;
    readonly is_executed: boolean;
}

/**
 * @class VotingPowerEngine
 * @description Logic for calculating electoral influence and proposal validity.
 */
export class VotingPowerEngine {
    /**
     * @method calculateTotalPower
     * @description Computes final voting power. Formula: BaseWeight * (1 + (MeritBonus / 100))
     * Result is returned as BigInt to prevent precision loss in large-scale DAOs.
     */
    public static calculateTotalPower(base: VOTE_WEIGHT_MULTIPLIER, meritBonus: number): bigint {
        const baseBig = BigInt(base) * 10n ** 18n; // Scale to 18 decimals (Token standard)
        const bonusFactor = 100n + BigInt(Math.floor(meritBonus));
        return (baseBig * bonusFactor) / 100n;
    }

    /**
     * @method isQuorumReached
     * @description Checks if total votes meet the minimum participation threshold.
     */
    public static isQuorumReached(totalVotes: bigint, totalPowerSupply: bigint): boolean {
        if (totalPowerSupply === 0n) return false;
        const participation = (totalVotes * 100n) / totalPowerSupply;
        return participation >= BigInt(GOVERNANCE_CONSTANTS.MIN_QUORUM_PERCENT);
    }

    /**
     * @method getRequiredThreshold
     * @description Returns the percentage required to pass based on category.
     */
    public static getRequiredThreshold(category: PROPOSAL_CATEGORY): number {
        switch (category) {
            case PROPOSAL_CATEGORY.EMERGENCY_OVERRIDE:
            case PROPOSAL_CATEGORY.LAW_AMENDMENT:
                return GOVERNANCE_CONSTANTS.SUPER_MAJORITY_THRESHOLD;
            default:
                return GOVERNANCE_CONSTANTS.MAJORITY_THRESHOLD;
        }
    }

    /**
     * @method isExpired
     * @description Checks if the proposal block window has closed.
     */
    public static isExpired(currentBlock: number, endBlock: number): boolean {
        return currentBlock > endBlock;
    }
}

/**
 * @description Verification flag for system-wide integrity checks.
 */
export const GOVERNANCE_POWER_LOADED: boolean = true;
