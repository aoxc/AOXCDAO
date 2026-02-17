/**
 * @file dimensions.ts
 * @namespace AOXCDAO.Core.Dimensions
 * @version 2.0.0
 * @description Universal Dimensions & Thresholds - (Measure-Locked)
 * Defines standard units, temporal scales, and safety trigger points.
 */

/**
 * @constant PHYSICAL_THRESHOLDS
 * @description Hard limits for hardware and data flow to prevent system fatigue.
 */
export const PHYSICAL_THRESHOLDS = {
    MAX_VELOCITY:   0xfa,  // 250 units - Max safe navigation/flow speed
    CRITICAL_TEMP:  0x1bc, // 444 units - Critical hardware temperature
    MIN_ENERGY_PCT: 0x0a,  // 10% - Critical energy reserve limit
} as const;

/**
 * @constant TEMPORAL_UNITS
 * @description Time-based constants for system synchronization (POSIX Standard).
 */
export const TEMPORAL_UNITS = {
    SYSTEM_HEARTBEAT: 10,    // 10-second system pulse
    CONTRACT_TTL:      86400, // 24 Hours
} as const;

/**
 * @enum QUANTITY_SCALES
 * @description Standardized scales for transaction batches and resource allocation.
 */
export enum QUANTITY_SCALES {
    MICRO = 0x01, // Minimum atomic unit
    MACRO = 0xff, // 255 - Bulk-Transaction Cap
}

// -----------------------------------------------------------------------------
// ACADEMIC TYPE DEFINITIONS (v2.0.0 UPDATED)
// -----------------------------------------------------------------------------

/**
 * @interface ISensorTelemetry
 * @description Formal structure for reporting physical health from any Vessel.
 */
export interface ISensorTelemetry {
    readonly vessel_id: number;
    readonly current_velocity: number; 
    readonly current_temp: number; 
    readonly energy_level: number; 
    readonly timestamp: number; 
}

/**
 * @class DimensionController
 * @description Active monitoring logic for physical thresholds and temporal sync.
 */
export class DimensionController {
    /**
     * @method isWithinSafetyLimits
     * @description Validates if a vessel's telemetry is within AOXC safety standards.
     */
    public static isWithinSafetyLimits(telemetry: ISensorTelemetry): boolean {
        const isTempSafe = telemetry.current_temp <= PHYSICAL_THRESHOLDS.CRITICAL_TEMP;
        const isEnergySafe = telemetry.energy_level > PHYSICAL_THRESHOLDS.MIN_ENERGY_PCT;
        const isVelocitySafe = telemetry.current_velocity <= PHYSICAL_THRESHOLDS.MAX_VELOCITY;

        return isTempSafe && isEnergySafe && isVelocitySafe;
    }

    /**
     * @method getHealthScore
     * @description Calculates a health percentage (0-100) based on telemetry data.
     */
    public static getHealthScore(telemetry: ISensorTelemetry): number {
        const tempStress = Math.max(0, (telemetry.current_temp / PHYSICAL_THRESHOLDS.CRITICAL_TEMP));
        const energyStatus = (telemetry.energy_level / 100);
        
        // Simple linear health model: Energy weight 0.6, Temp weight 0.4
        const score = (energyStatus * 0.6) + ((1 - tempStress) * 0.4);
        return Math.floor(Math.min(1, Math.max(0, score)) * 100);
    }

    /**
     * @method isStaleData
     * @description Checks if the telemetry data is older than the system heartbeat.
     */
    public static isStaleData(timestamp: number): boolean {
        const drift = (Date.now() / 1000) - timestamp;
        return drift > (TEMPORAL_UNITS.SYSTEM_HEARTBEAT * 2);
    }

    /**
     * @method formatScale
     * @description Ensures batch quantities do not exceed MACRO limits.
     */
    public static enforceMacroScale(quantity: number): number {
        return Math.min(quantity, QUANTITY_SCALES.MACRO);
    }
}

/**
 * @description Verification flag for system-wide integrity checks.
 */
export const DIMENSIONS_LOADED: boolean = true;
