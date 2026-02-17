/**
 * @file hierarchy.ts
 * @namespace AOXCDAO.Core.Society
 * @version 2.0.0
 * @description Social Hierarchy & Ranking System - (Rank-Locked)
 * Defines the formal command structure and authority levels for all entities.
 */

/**
 * @enum COMMAND_RANKS
 * @description Standard roles across the 7-vessel fleet.
 */
export enum COMMAND_RANKS {
    CAPTAIN   = 0xf1, // Absolute local authority over a vessel
    OFFICER   = 0xf2, // Departmental managers
    STAFF     = 0xf3, // Operational personnel / Crew
    PASSENGER = 0xf4, // Civilian/Visitor status
}

/**
 * @constant ACCESS_AUTHORITY
 * @description Logical access tiers for system resources and secure sectors.
 */
export const ACCESS_AUTHORITY = {
    OMEGA: 0xff, // Sovereign Access (Andromeda Prime + Chief)
    DELTA: 0xaa, // Departmental Access (Officers/Captains)
    GUEST: 0x11, // Restricted/Public Access (Read-only)
} as const;

/**
 * @constant RANK_REQUIREMENTS
 * @description Merit-based thresholds for maintaining or achieving ranks.
 */
export const RANK_REQUIREMENTS = {
    [COMMAND_RANKS.CAPTAIN]: 5000, // 5000+ Merit required
    [COMMAND_RANKS.OFFICER]: 2000, // 2000+ Merit required
    [COMMAND_RANKS.STAFF]:   500,  // 500+ Merit required
    [COMMAND_RANKS.PASSENGER]: 0,  // Base entry
} as const;

// -----------------------------------------------------------------------------
// ACADEMIC TYPE DEFINITIONS (v2.0.0 UPDATED)
// -----------------------------------------------------------------------------

/**
 * @interface IRankCredential
 * @description Standardized identity structure for rank verification.
 */
export interface IRankCredential {
    readonly entity_address: string; 
    readonly current_rank: COMMAND_RANKS;
    readonly auth_level: number; 
    readonly issued_vessel: number; 
    readonly is_active: boolean; 
    readonly merit_threshold: number; 
}

/**
 * @class HierarchyManager
 * @description Active logic for rank verification, promotion, and authority checks.
 */
export class HierarchyManager {
    /**
     * @method hasAuthority
     * @description Checks if a rank meets or exceeds the required authority tier.
     */
    public static hasAuthority(credential: IRankCredential, required: number): boolean {
        if (!credential.is_active) return false;
        return credential.auth_level >= required;
    }

    /**
     * @method canCommand
     * @description Determines if Entity A can issue commands to Entity B.
     * Rule: Lower hex value in COMMAND_RANKS = Higher priority.
     */
    public static canCommand(commander: COMMAND_RANKS, subordinate: COMMAND_RANKS): boolean {
        return commander < subordinate;
    }

    /**
     * @method evaluatePromotion
     * @description Checks if an entity is eligible for a rank promotion based on merit.
     */
    public static isEligibleForPromotion(currentMerit: number, targetRank: COMMAND_RANKS): boolean {
        const required = RANK_REQUIREMENTS[targetRank];
        return currentMerit >= required;
    }

    /**
     * @method getAuthorityByRank
     * @description Maps a command rank to its default authority level.
     */
    public static getAuthorityByRank(rank: COMMAND_RANKS): number {
        switch (rank) {
            case COMMAND_RANKS.CAPTAIN: return ACCESS_AUTHORITY.DELTA;
            case COMMAND_RANKS.OFFICER: return ACCESS_AUTHORITY.DELTA;
            case COMMAND_RANKS.PASSENGER: return ACCESS_AUTHORITY.GUEST;
            default: return ACCESS_AUTHORITY.GUEST;
        }
    }

    /**
     * @method generateRankTrace
     * @description Creates a forensic trace for rank-related activities.
     */
    public static generateRankTrace(credential: IRankCredential): string {
        return `RANK_VERIFIED:${credential.current_rank}:${credential.entity_address}`;
    }
}

/**
 * @description Verification flag for system-wide integrity checks.
 */
export const HIERARCHY_SYSTEM_LOADED: boolean = true;
