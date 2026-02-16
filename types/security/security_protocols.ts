/**
 * @file security_protocols.ts
 * @namespace AOXCDAO.Core.Security
 * @version 2.0.0
 * @description Layered Security Contingency (Plan A, B, C) - (Security-Locked)
 * Defines the defense escalation levels and automated response protocols.
 */

/**
 * @enum DEFENSE_LAYER
 * @description Tactical escalation levels (Plan A, B, and C).
 */
export enum DEFENSE_LAYER {
    PLAN_A_STABILITY = 0xa1, // Normal Ops: Passive Monitoring
    PLAN_B_ISOLATION = 0xb2, // High Threat: Vault Locking & Network Segregation
    PLAN_C_SCORCHED  = 0xc3, // Total Compromise: Data Purge & Stasis
}

/**
 * @enum THREAT_TYPE
 * @description Internal and external threat classifications.
 */
export enum THREAT_TYPE {
    CYBER_ATTACK     = 0x10, // Exploit / DDoS
    BIO_THREAT       = 0x20, // Life Support Failure
    INTERNAL_MUTINY  = 0x30, // Unauthorized Command / Fraud
    EXTERNAL_HOSTILE = 0x40, // Bridge Hijack / Fleet Aggression
}

/**
 * @constant SECURITY_LEVEL_A (Standard Defense)
 */
export const SECURITY_LEVEL_A = {
    IDENT_CHECK_FREQUENCY:   3600,   // Hourly re-verification
    MINTING_LIMIT_PER_BLOCK: 1000,   // Prevent liquidity drain
    AUTO_LOG_STORAGE:        "HEX_ONLY",
} as const;

/**
 * @constant SECURITY_LEVEL_B (Active Lockdown)
 */
export const SECURITY_LEVEL_B = {
    HALT_EXTERNAL_BRIDGES:   true, 
    RESTRICT_OFFICER_ACCESS: true, 
    WITHDRAWAL_DELAY:        86400,  // 24-Hour delay
    QUARANTINE_SECTOR_ID:    0x99, 
} as const;

/**
 * @constant SECURITY_LEVEL_C (Terminal Response)
 */
export const SECURITY_LEVEL_C = {
    EMERGENCY_SHUTDOWN:      true, 
    SELF_CUSTODY_PULL:       true, 
    DATA_WIPE_NON_CRITICAL:  true, 
    STASIS_FORCE_TRIGGER:    true, // Force survival sleep
} as const;

// -----------------------------------------------------------------------------
// ACADEMIC TYPE DEFINITIONS (v2.0.0 UPDATED)
// -----------------------------------------------------------------------------

/**
 * @interface ISecurityState
 * @description Real-time status of the fleet's defensive posture.
 */
export interface ISecurityState {
    readonly current_layer: DEFENSE_LAYER;
    readonly active_threats: THREAT_TYPE[];
    readonly last_incident_hash: string;
    readonly is_bridge_locked: boolean;
    readonly is_stasis_active: boolean;
    readonly authorized_by: string; 
    readonly timestamp: number;
}

/**
 * @class TacticalDefenseEngine
 * @description Operational logic for automated escalation and response execution.
 */
export class TacticalDefenseEngine {
    /**
     * @method determineEscalation
     * @description Assigns a defense layer based on threat severity.
     */
    public static determineEscalation(threats: THREAT_TYPE[]): DEFENSE_LAYER {
        if (threats.includes(THREAT_TYPE.INTERNAL_MUTINY)) return DEFENSE_LAYER.PLAN_C_SCORCHED;
        
        if (threats.includes(THREAT_TYPE.EXTERNAL_HOSTILE) || 
            threats.includes(THREAT_TYPE.CYBER_ATTACK)) {
            return DEFENSE_LAYER.PLAN_B_ISOLATION;
        }

        return DEFENSE_LAYER.PLAN_A_STABILITY;
    }

    /**
     * @method validateStateTransition
     * @description Ensures security levels only escalate automatically, never de-escalate without Root auth.
     */
    public static canDeescalate(current: DEFENSE_LAYER, next: DEFENSE_LAYER, authRank: number): boolean {
        // De-escalation (e.g., C -> B) requires Sovereign Rank (0xFF)
        if (next < current) return authRank === 0xff;
        return true; // Escalation is always allowed by system
    }

    /**
     * @method getActionPayload
     * @description Returns the specific security constraints for the active plan.
     */
    public static getActionPayload(layer: DEFENSE_LAYER): object {
        switch (layer) {
            case DEFENSE_LAYER.PLAN_C_SCORCHED:  return SECURITY_LEVEL_C;
            case DEFENSE_LAYER.PLAN_B_ISOLATION: return SECURITY_LEVEL_B;
            default: return SECURITY_LEVEL_A;
        }
    }

    /**
     * @method triggerScorchedEarth
     * @description Seals the terminal response log.
     */
    public static sealTerminalLog(incidentHash: string): string {
        return `SCORCHED_EARTH_SEAL::${incidentHash}::TIMESTAMP_${Date.now()}`;
    }
}

/**
 * @function determineEscalation
 * @description Legacy wrapper for direct threat assessment.
 */
export const determineEscalation = (threat: THREAT_TYPE): DEFENSE_LAYER => {
    return TacticalDefenseEngine.determineEscalation([threat]);
};

export const DEFENSE_SYSTEM_ARMED: boolean = true;
