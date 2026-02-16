/**
 * @file passenger_types.ts
 * @namespace AOXCDAO.Core.BioMetric
 * @version 2.0.0
 * @description Comprehensive Passenger Life & Status Registry - (Life-Locked)
 * Defines biological, social, and operational categories for all vessel inhabitants.
 */

/**
 * @enum PASSENGER_CLASS
 * @description Social stratification and vessel access priority within the DAO.
 */
export enum PASSENGER_CLASS {
    SOVEREIGN_ELITE   = 0xa1, // Founder Council
    COMMAND_OFFICER   = 0xa2, // Fleet/Vessel Command
    OPERATIONAL_CREW  = 0xa3, // Technical/Security
    RESEARCH_SCIENTIST = 0xa4, // Academic/Data
    CIVILIAN_PASSENGER = 0xa5, // Standard Residents
    GUEST_ENTITY      = 0xa6, // External Envoys
}

/**
 * @enum BIOLOGICAL_CONDITION
 * @description Medical and physical health states monitored by the Bio-Registry.
 */
export enum BIOLOGICAL_CONDITION {
    OPTIMAL_HEALTH     = 0xb1, // Peak performance
    MINOR_AILMENT      = 0xb2, // Fatigue/Dehydration
    CRITICAL_ILLNESS   = 0xb3, // Immediate isolation required
    RADIATION_EXPOSURE = 0xb4, // Toxicity detected
    STASIS_SLEEP       = 0xb5, // Suspended animation
}

/**
 * @enum DAILY_ROUTINE_STATE
 * @description Time-based behavioral cycles for resource management.
 */
export enum DAILY_ROUTINE_STATE {
    DUTY_SHIFT      = 0xd1, 
    RECREATION      = 0xd2, 
    NUTRITION_CYCLE = 0xd3, 
    HYGIENE_RESET   = 0xd4, 
    DEEP_SLEEP      = 0xd5, 
}

/**
 * @enum EQUIPMENT_CLASS
 * @description Standardized clothing and gear required for vessel environments.
 */
export enum EQUIPMENT_CLASS {
    FORMAL_UNIFORM = 0xe1, 
    FLIGHT_SUIT    = 0xe2, 
    LAB_GEAR       = 0xe3, 
    CIVILIAN_WEAR  = 0xe4, 
    EV_SUIT        = 0xe5, // Lunar Surface Capable
}

/**
 * @constant LIFE_CONSTRAINTS
 * @description Strict physiological limits for maintaining biological integrity.
 */
export const LIFE_CONSTRAINTS = {
    MAX_RADIATION_DOSE:     50,   // mSv per Annum
    MIN_CALORIE_INTAKE:     1800, // Survival minimum
    OXYGEN_RESERVE_PERCENT: 15,   // Emergency threshold
    MAX_STRESS_INDEX:       85,   // Threshold for forced rest
} as const;

// -----------------------------------------------------------------------------
// ACADEMIC TYPE DEFINITIONS (v2.0.0 UPDATED)
// -----------------------------------------------------------------------------

/**
 * @interface IPassengerManifest
 * @description The formal digital identity and biological status of a vessel inhabitant.
 */
export interface IPassengerManifest {
    readonly entity_id: string; 
    readonly p_class: PASSENGER_CLASS; 
    readonly health_status: BIOLOGICAL_CONDITION;
    readonly current_routine: DAILY_ROUTINE_STATE;
    readonly active_gear: EQUIPMENT_CLASS;
    readonly merit_score: number; 
    readonly stress_level: number; // 0-100
    readonly assigned_vessel: number; 
}

/**
 * @class BioRegistryEngine
 * @description Logic for health monitoring, routine validation, and emergency triage.
 */
export class BioRegistryEngine {
    /**
     * @method isFitForDuty
     * @description Checks if a passenger's health and stress allow for duty assignment.
     */
    public static isFitForDuty(manifest: IPassengerManifest): boolean {
        const isHealthy = manifest.health_status === BIOLOGICAL_CONDITION.OPTIMAL_HEALTH || 
                          manifest.health_status === BIOLOGICAL_CONDITION.MINOR_AILMENT;
        const isCalm = manifest.stress_level < LIFE_CONSTRAINTS.MAX_STRESS_INDEX;
        
        return isHealthy && isCalm;
    }

    /**
     * @method requiresMedicalIsolation
     * @description Identifies entities that pose a biological or physical risk.
     */
    public static requiresMedicalIsolation(status: BIOLOGICAL_CONDITION): boolean {
        return status === BIOLOGICAL_CONDITION.CRITICAL_ILLNESS || 
               status === BIOLOGICAL_CONDITION.RADIATION_EXPOSURE;
    }

    /**
     * @method validateEVReadiness
     * @description Ensures a passenger has the correct gear for Lunar Surface activity.
     */
    public static canPerformEVA(manifest: IPassengerManifest): boolean {
        return manifest.active_gear === EQUIPMENT_CLASS.EV_SUIT && 
               this.isFitForDuty(manifest);
    }

    /**
     * @method getAccessPriority
     * @description Calculates resource priority based on class and health.
     * Rule: Higher class + Critical health = Priority triage.
     */
    public static getResourcePriority(manifest: IPassengerManifest): number {
        let priority = 255 - manifest.p_class; // Higher class = Higher value
        if (manifest.health_status === BIOLOGICAL_CONDITION.CRITICAL_ILLNESS) {
            priority += 50;
        }
        return priority;
    }
}

/**
 * @description Verification flag for Bio-Metric System integrity.
 */
export const BIOMETRIC_SYSTEM_LOADED: boolean = true;
