/**
 * @file vessel_dynamics.ts
 * @namespace AOXCDAO.Core.Physics
 * @version 2.0.0
 * @description Orbital Mechanics and Landing Dynamics - (Physics-Locked)
 * Defines the physical constraints for lunar descent and vessel mobility.
 */

/**
 * @constant LUNAR_ENVIRONMENT
 * @description Physical constants of the lunar landing zone.
 */
export const LUNAR_ENVIRONMENT = {
    GRAVITY_MS2: 1.622,            // Moon surface gravity (m/s^2)
    VACUUM_FRICTION: 0.0,          // Zero atmosphere
    SURFACE_TEMPERATURE_MAX: 390,  // Kelvin (Day)
    SURFACE_TEMPERATURE_MIN: 100,  // Kelvin (Night)
} as const;

/**
 * @enum DESCENT_PHASE
 * @description Critical stages of the lunar landing sequence.
 */
export enum DESCENT_PHASE {
    ORBITAL_STAGING  = 0xf0, // Stable orbit
    DEORBIT_BURN     = 0xf1, // Trajectory initiation
    BRAKING_PHASE    = 0xf2, // Thrust reduction
    TERMINAL_DESCENT = 0xf3, // Final approach
    TOUCHDOWN        = 0xf4, // Contact
    ABORT_SEQUENCE   = 0xff, // Emergency return
}

/**
 * @constant OPERATIONAL_LIMITS
 * @description Safety thresholds for vessel integrity.
 */
export const OPERATIONAL_LIMITS = {
    MAX_DESCENT_VELOCITY:   2.5,   // m/s (Soft landing)
    CRITICAL_FUEL_LEVEL:    10,    // %
    MAX_STRUCTURAL_STRESS:  85,    // %
    COMM_LATENCY_MS:        500,   // Sync limit
} as const;

/**
 * @enum FUEL_TYPE
 * @description Propellant classifications for the 7-Vessel fleet.
 */
export enum FUEL_TYPE {
    ION_PROPULSION    = 0x1a, // Deep space
    CHEMICAL_REACTION = 0x1b, // Landing/Takeoff
    QUANTUM_DRIVE     = 0x1c, // Andromeda-Prime exclusive
}

// -----------------------------------------------------------------------------
// ACADEMIC TYPE DEFINITIONS (v2.0.0 UPDATED)
// -----------------------------------------------------------------------------

/**
 * @interface IVesselTelemetry
 * @description Real-time physical status of a vessel.
 */
export interface IVesselTelemetry {
    readonly vessel_id: number;
    readonly current_phase: DESCENT_PHASE;
    readonly altitude_meters: number;
    readonly velocity_vector: { x: number; y: number; z: number };
    readonly fuel_reserve: number;
    readonly fuel_type: FUEL_TYPE;
    readonly structural_stress: number; 
    readonly hull_temperature: number;
    readonly is_auto_pilot_engaged: boolean;
}

/**
 * @class DynamicsNavigationEngine
 * @description Logic for flight safety, trajectory validation, and propulsion physics.
 */
export class DynamicsNavigationEngine {
    /**
     * @method calculateLandingSafety
     * @description Validates if the current telemetry allows for a safe touchdown.
     */
    public static calculateLandingSafety(telemetry: IVesselTelemetry): boolean {
        const isVelocitySafe = Math.abs(telemetry.velocity_vector.z) <= OPERATIONAL_LIMITS.MAX_DESCENT_VELOCITY;
        const isFuelSafe = telemetry.fuel_reserve > OPERATIONAL_LIMITS.CRITICAL_FUEL_LEVEL;
        const isStressSafe = telemetry.structural_stress < OPERATIONAL_LIMITS.MAX_STRUCTURAL_STRESS;

        return isVelocitySafe && isFuelSafe && isStressSafe;
    }

    /**
     * @method getThrustEfficiency
     * @description Returns the efficiency multiplier based on fuel type and environment.
     */
    public static getThrustEfficiency(fuel: FUEL_TYPE): number {
        switch (fuel) {
            case FUEL_TYPE.QUANTUM_DRIVE:     return 9.9; // Sovereign efficiency
            case FUEL_TYPE.ION_PROPULSION:    return 1.2;
            case FUEL_TYPE.CHEMICAL_REACTION: return 0.8; // High thrust, low efficiency
            default: return 0.5;
        }
    }

    /**
     * @method shouldTriggerAbort
     * @description Checks if environmental or mechanical factors require an emergency abort.
     */
    public static shouldTriggerAbort(telemetry: IVesselTelemetry): boolean {
        // Abort if stress is critical or temperature exceeds hull limits
        if (telemetry.structural_stress >= 95) return true;
        if (telemetry.hull_temperature > LUNAR_ENVIRONMENT.SURFACE_TEMPERATURE_MAX + 50) return true;
        
        return false;
    }

    /**
     * @method predictImpactTime
     * @description Simple Newtonian prediction for touchdown time (t = h / v).
     */
    public static predictImpactTime(telemetry: IVesselTelemetry): number {
        if (telemetry.velocity_vector.z >= 0) return Infinity; // Not descending
        return telemetry.altitude_meters / Math.abs(telemetry.velocity_vector.z);
    }
}

/**
 * @function calculateLandingSafety
 * @description Legacy wrapper for safety checks.
 */
export const calculateLandingSafety = (telemetry: IVesselTelemetry): boolean => {
    return DynamicsNavigationEngine.calculateLandingSafety(telemetry);
};

export const FLIGHT_DYNAMICS_OPERATIONAL: boolean = true;
