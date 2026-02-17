/**
 * @file governance.types.ts
 * @namespace AOXCDAO.Core.Legislation
 * @version 2.0.0
 * @description AOXC Master Hub Governance & Proposal Protocols - (Legislation-Locked)
 * Defines the lifecycle of laws and system amendments across the fleet.
 */

/**
 * @constant PROPOSAL_CATEGORIES
 * @description Defines the lifecycle of laws and system amendments across the fleet.
 */
export const PROPOSAL_CATEGORIES = {
    AMENDMENT:  0xa1, // Constitution change (System-wide protocol update)
    RESOURCE:   0xa2, // Resource allocation (Inter-vessel treasury movement)
    EXPULSION:  0xa3, // Entity ban/expulsion (Fleet-wide isolation)
    NEW_VESSEL: 0xa4, // Fleet expansion (Commissioning a new vessel)
} as const;

/**
 * @constant VOTING_MECHANISMS
 * @description Required consensus levels for legislative execution.
 */
export const VOTING_MECHANISMS = {
    QUORUM_SIMPLE:    0x11, // 51% Consensus required
    QUORUM_ABSOLUTE:  0x22, // 75% High-level Consensus
    QUORUM_SOVEREIGN: 0x33, // 100% Unanimous (ANDROMEDA + All 7 Captains)
} as const;

/**
 * @enum PROPOSAL_STATES
 * @description Operational states of a proposal within the AOXC Hub lifecycle.
 */
export enum PROPOSAL_STATES {
    DRAFT       = 0x01, // Initial proposal drafting
    ACTIVE_VOTE = 0x02, // Voting in progress
    EXECUTED    = 0x03, // Implemented on-chain
    VETOED      = 0x04, // Rejected by Council
    EXPIRED     = 0x05, // Failed to reach quorum in time
}

// -----------------------------------------------------------------------------
// ACADEMIC TYPE DEFINITIONS (v2.0.0 UPDATED)
// -----------------------------------------------------------------------------

export type ProposalType = (typeof PROPOSAL_CATEGORIES)[keyof typeof PROPOSAL_CATEGORIES];
export type VotingQuorum = (typeof VOTING_MECHANISMS)[keyof typeof VOTING_MECHANISMS];

/**
 * @interface IAOXCProposalHeader
 * @description Standardized header for all proposals originating from any vessel.
 */
export interface IAOXCProposalHeader {
    readonly proposal_id: string; // Unique legislative hash
    readonly category: ProposalType;
    readonly quorum_requirement: VotingQuorum;
    readonly state: PROPOSAL_STATES;
    readonly origin_vessel: string; 
    readonly initiator: string; 
    readonly timestamp: number; 
    readonly expiry: number; // Deadline for voting
}

/**
 * @class LegislativeEngine
 * @description Active logic for determining governance requirements and proposal validity.
 */
export class LegislativeEngine {
    /**
     * @method getRequiredQuorum
     * @description Automatically determines the required consensus level based on category.
     */
    public static getRequiredQuorum(category: ProposalType): VotingQuorum {
        switch (category) {
            case PROPOSAL_CATEGORIES.AMENDMENT:
            case PROPOSAL_CATEGORIES.NEW_VESSEL:
                return VOTING_MECHANISMS.QUORUM_SOVEREIGN;
            case PROPOSAL_CATEGORIES.EXPULSION:
                return VOTING_MECHANISMS.QUORUM_ABSOLUTE;
            case PROPOSAL_CATEGORIES.RESOURCE:
                return VOTING_MECHANISMS.QUORUM_SIMPLE;
            default:
                return VOTING_MECHANISMS.QUORUM_SOVEREIGN;
        }
    }

    /**
     * @method isVoteActive
     * @description Checks if a proposal is currently in the ACTIVE_VOTE state and not expired.
     */
    public static isVoteActive(header: IAOXCProposalHeader): boolean {
        const now = Date.now();
        return (
            header.state === PROPOSAL_STATES.ACTIVE_VOTE &&
            now < header.expiry
        );
    }

    /**
     * @method canExecute
     * @description Verifies if a proposal has reached the legal status for on-chain execution.
     */
    public static canExecute(state: PROPOSAL_STATES): boolean {
        return state === PROPOSAL_STATES.EXECUTED;
    }

    /**
     * @method generateProposalHash
     * @description Generates a unique identifier for the legislative record.
     */
    public static generateProposalHash(vessel: string, timestamp: number): string {
        return `LAW_${vessel}_${timestamp}`;
    }
}

/**
 * @description Verification flag for system-wide integrity checks.
 */
export const GOVERNANCE_SYSTEM_LOADED: boolean = true;
