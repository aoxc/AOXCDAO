/**
 * @file sustenance.ts
 * @namespace AOXCDAO.Core.BioSupport
 * @version 2.0.0
 * @description Sustenance & Life Support Constants - (Life-Locked)
 * Defines living standards, resource allocation, and social merit multipliers.
 * OS Compatibility: POSIX / Debian GNU Linux / XLayer Optimized
 */

import { MANDATE_ROLES, TRANSITIONAL_ROLES, UnifiedRank } from "../core/merit.ts";

/**
 * @constant RESOURCE_QUOTAS
 * @description Daily limits per individual based on basic survival requirements.
 */
export const RESOURCE_QUOTAS = {
    ENERGY_BASE:    100, // Units: Daily module energy requirement
    DATA_BANDWIDTH: 50,  // Units: Communication limit (MB/Day)
    OXYGEN_NOMINAL: 550, // Units: Liters per day per entity
} as const;

/**
 * @enum OCCUPANCY_STATES
 * @description Operational states of living quarters and personnel activity.
 */
export enum OCCUPANCY_STATES {
    ACTIVE           = 0x01, // Personnel on duty / Full power
    REST             = 0x02, // Sleep/Rest mode / Low power
    EMERGENCY_STASIS = 0x03, // Resource conservation / Maximum survival mode
    DEEP_QUARANTINE  = 0x04, // Isolated metabolic monitoring
}

/**
 * @constant MERIT_MULTIPLIERS
 * @description Reward multipliers linked to hierarchy and performance.
 */
export const MERIT_MULTIPLIERS = {
    SOVEREIGN: 2.0, // High-stakes oversight reward
    CAPTAIN:   1.5, // Vessel Command reward
    STAFF:     1.0, // Standard operational crew
    GUEST:     0.5, // Temporary/Civilian entities
} as const;

// -----------------------------------------------------------------------------
// ACADEMIC TYPE DEFINITIONS (v2.0.0 UPDATED)
// -----------------------------------------------------------------------------

/**
 * @interface ILifeSupportStatus
 * @description Represents the biological and resource status of a specific vessel sector.
 */
export interface ILifeSupportStatus {
    readonly vessel_id: number;
    readonly current_state: OCCUPANCY_STATES;
    readonly total_energy_consumption: number;
    readonly active_personnel_count: number;
    readonly is_stasis_active: boolean;
    readonly resource_efficiency: number; // Percentage (0-100)
    readonly last_update: number;
}

/**
 * @class SustenanceEngine
 * @description Operational logic for resource distribution and reward scaling.
 */
export class SustenanceEngine {
    /**
     * @method getMeritMultiplier
     * @description Dynamically maps a UnifiedRank to its corresponding merit multiplier.
     */
    public static getMeritMultiplier(rank: UnifiedRank): number {
        if (rank === MANDATE_ROLES.SOVEREIGN)     return MERIT_MULTIPLIERS.SOVEREIGN;
        if (rank === MANDATE_ROLES.CAPTAIN_ELECT) return MERIT_MULTIPLIERS.CAPTAIN;
        if (rank >= TRANSITIONAL_ROLES.CREW)      return MERIT_MULTIPLIERS.STAFF;
        return MERIT_MULTIPLIERS.GUEST;
    }

    /**
     * @method calculateTotalEnergyNeed
     * @description Estimates energy requirements based on personnel count and state.
     */
    public static calculateTotalEnergyNeed(personnel: number, state: OCCUPANCY_STATES): number {
        const base = personnel * RESOURCE_QUOTAS.ENERGY_BASE;
        switch (state) {
            case OCCUPANCY_STATES.ACTIVE:           return base * 1.2; // Extra power for duty
            case OCCUPANCY_STATES.REST:             return base * 0.7; // Conservation during sleep
            case OCCUPANCY_STATES.EMERGENCY_STASIS: return base * 0.1; // Critical survival floor
            default: return base;
        }
    }

    /**
     * @method isStasisRequired
     * @description Determines if low energy levels necessitate emergency stasis.
     */
    public static isStasisRequired(availableEnergy: number, requiredEnergy: number): boolean {
        // If energy is below 15% of requirement, trigger stasis
        return availableEnergy < (requiredEnergy * 0.15);
    }

    /**
     * @method validateConsumption
     * @description Ensures a sector is not exceeding its allocated data/energy bandwidth.
     */
    public static validateConsumption(current: number, quota: number): boolean {
        return current <= quota;
    }
}

/**
 * @description Verification flag for Sustenance system status.
 */
export const SUSTENANCE_ACTIVE: boolean = true;
