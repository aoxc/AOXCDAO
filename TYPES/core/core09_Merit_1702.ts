/**
 * @file merit.types.ts
 * @namespace AOXCDAO.Core.Hierarchy
 * @version 2.0.0
 * @description Dynamic Merit and Authority Hierarchy - (Fluid-Roster-Locked)
 * OS Compatibility: POSIX / Debian GNU Linux / XLayer Optimized
 */

/**
 * @constant MANDATE_ROLES
 * @description Formal authority ranks derived from cryptographic elections and appointments.
 */
export const MANDATE_ROLES = {
    SOVEREIGN:     0xff, // ANDROMEDA_PRIME: Sovereign Oversight (Root Authority)
    CAPTAIN_ELECT: 0xe1, // Elected Vessel Commander: Term-limited
    OFFICER:       0xa0, // Strategic Personnel: Departmental authority
} as const;

/**
 * @constant TRANSITIONAL_ROLES
 * @description Non-elected, fluid population tiers within the AOXC ecosystem.
 */
export const TRANSITIONAL_ROLES = {
    CREW:      0x40, // Certified Operational Staff
    PASSENGER: 0x10, // Authorized observer or civilian
    GUEST:     0x01, // Unverified/External Entry (Sandboxed)
} as const;

/**
 * @enum ENTITY_DYNAMIC_STATUS
 * @description Real-time operational states tracking an entity's current role execution.
 */
export enum ENTITY_DYNAMIC_STATUS {
    IN_MANDATE = 0xb1, // Currently holding an elected/appointed office
    ON_DUTY    = 0xb2, // Active operational status
    TRANSIT    = 0xb3, // Temporary status during cross-vessel movements
    SUSPENDED  = 0xbf, // Post-disciplinary or mandate-expired state
}

// -----------------------------------------------------------------------------
// ACADEMIC TYPE DEFINITIONS (v2.0.0 UPDATED)
// -----------------------------------------------------------------------------

export type MandateRank = (typeof MANDATE_ROLES)[keyof typeof MANDATE_ROLES];
export type FluidRank = (typeof TRANSITIONAL_ROLES)[keyof typeof TRANSITIONAL_ROLES];
export type UnifiedRank = MandateRank | FluidRank;

/**
 * @interface IAuthorityProfile
 * @description The official cryptographic profile of an entity's standing in the fleet.
 */
export interface IAuthorityProfile {
    readonly entity_hash: string; 
    readonly primary_rank: UnifiedRank; 
    readonly current_status: ENTITY_DYNAMIC_STATUS;
    readonly vessel_assignment: string; 
    readonly merit_score: number; // Quantitative merit value
    readonly mandate_expiry?: number; 
}

/**
 * @class MeritRankEngine
 * @description Operational logic for validating authority mandates and merit-based access.
 */
export class MeritRankEngine {
    /**
     * @method isMandateValid
     * @description Checks if an elected official's mandate has expired.
     */
    public static isMandateValid(profile: IAuthorityProfile): boolean {
        if (profile.primary_rank !== MANDATE_ROLES.CAPTAIN_ELECT) return true;
        if (!profile.mandate_expiry) return false;
        
        return (Date.now() / 1000) < profile.mandate_expiry;
    }

    /**
     * @method canAccessBridge
     * @description Determines if the rank is high enough to enter command sectors.
     */
    public static canAccessBridge(rank: UnifiedRank): boolean {
        return rank >= MANDATE_ROLES.OFFICER;
    }

    /**
     * @method calculateRankTier
     * @description Maps numeric merit scores to transitional roles.
     */
    public static calculateFluidRank(merit: number): FluidRank {
        if (merit >= 1000) return TRANSITIONAL_ROLES.CREW;
        if (merit >= 100)  return TRANSITIONAL_ROLES.PASSENGER;
        return TRANSITIONAL_ROLES.GUEST;
    }

    /**
     * @method validateSovereignSingularity
     * @description Ensures only the Karujan Prime holds the 0xFF rank.
     */
    public static isSovereign(rank: UnifiedRank): boolean {
        return rank === MANDATE_ROLES.SOVEREIGN;
    }

    /**
     * @method generateAuthorityReport
     * @description Formats the profile for forensic audit logs.
     */
    public static generateAuthorityReport(profile: IAuthorityProfile): string {
        const validity = this.isMandateValid(profile) ? "VALID" : "EXPIRED";
        return `[RANK:0x${profile.primary_rank.toString(16).toUpperCase()}] ENTITY:${profile.entity_hash} STATUS:${profile.current_status} MANDATE:${validity}`;
    }
}

/**
 * @description Verification flag for Merit System integrity.
 */
export const MERIT_SYSTEM_LOADED: boolean = true;
