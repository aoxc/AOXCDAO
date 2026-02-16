/**
 * @file discipline.ts
 * @namespace AOXCDAO.Core.Governance
 * @version 2.0.0
 * @description Protocol Compliance & Disciplinary Constants - (Strict-Compliance)
 * Defines protocol adherence levels, enforcement mechanisms, and penalty structures.
 */

/**
 * @enum ADHERENCE_LEVELS
 * @description 0xA0X Series: Status of an entity's compliance with fleet protocols.
 */
export enum ADHERENCE_LEVELS {
    FULL            = 0xa01, // Total Alignment: All protocols strictly followed.
    PARTIAL         = 0xa02, // Minor Deviation: Non-critical anomalies detected.
    VIOLATION       = 0xa03, // Protocol Breach: Rules explicitly bypassed.
    CRITICAL_BREACH = 0xa04, // System Threat: Vessel integrity endangered.
}

/**
 * @constant DISCIPLINARY_ACTIONS
 * @description 0xXF Series: Penalties applied based on violation severity.
 */
export const DISCIPLINARY_ACTIONS = {
    ISOLATION:     0x1f, // Digital isolation of the entity/vessel.
    RANK_DEMOTION: 0x2f, // Rank reduction (Ref: hierarchy.ts).
    MERIT_STRIP:   0x3f, // Total revocation of merit points (Ref: merit.ts).
    RECOVERY_MODE: 0x4f, // Forced state-restoration (Ref: autonomous_repair.ts).
} as const;

// -----------------------------------------------------------------------------
// ACADEMIC TYPE DEFINITIONS (v2.0.0 UPDATED)
// -----------------------------------------------------------------------------

/**
 * @interface IDisciplinaryRecord
 * @description Formal record of a protocol violation and the subsequent penalty.
 */
export interface IDisciplinaryRecord {
    readonly record_id: string; 
    readonly entity_address: string; 
    readonly adherence_state: ADHERENCE_LEVELS;
    readonly applied_penalty: number; 
    readonly enforcer_vessel: string; 
    readonly timestamp: number;
    readonly evidence_hash: string; // Cryptographic proof of violation
}

/**
 * @class JudicialEnforcer
 * @description Active logic for identifying protocol drift and executing penalties.
 */
export class JudicialEnforcer {
    /**
     * @method assessAdherence
     * @description Determines the adherence level based on anomaly reports.
     */
    public static assessAdherence(violationCount: number, isSecurityCritical: boolean): ADHERENCE_LEVELS {
        if (isSecurityCritical) return ADHERENCE_LEVELS.CRITICAL_BREACH;
        if (violationCount > 5) return ADHERENCE_LEVELS.VIOLATION;
        if (violationCount > 0) return ADHERENCE_LEVELS.PARTIAL;
        return ADHERENCE_LEVELS.FULL;
    }

    /**
     * @method mapPenalty
     * @description Maps adherence levels to the most appropriate disciplinary action.
     */
    public static mapPenalty(level: ADHERENCE_LEVELS): number {
        switch (level) {
            case ADHERENCE_LEVELS.CRITICAL_BREACH:
                return DISCIPLINARY_ACTIONS.MERIT_STRIP;
            case ADHERENCE_LEVELS.VIOLATION:
                return DISCIPLINARY_ACTIONS.RANK_DEMOTION;
            case ADHERENCE_LEVELS.PARTIAL:
                return DISCIPLINARY_ACTIONS.ISOLATION;
            default:
                return 0x00; // No action needed
        }
    }

    /**
     * @method generateLegalHash
     * @description Generates an immutable hash for the disciplinary record.
     */
    public static generateLegalHash(record: Omit<IDisciplinaryRecord, 'record_id'>): string {
        return `JUDICIAL_CERT_${record.timestamp}_${record.entity_address.substring(0, 8)}`;
    }

    /**
     * @method isRehabilitated
     * @description Checks if enough time has passed to lift the ISOLATION penalty.
     */
    public static isRehabilitated(record: IDisciplinaryRecord, cooldownPeriod: number): boolean {
        const timeElapsed = Date.now() - record.timestamp;
        return (
            record.applied_penalty === DISCIPLINARY_ACTIONS.ISOLATION && 
            timeElapsed > cooldownPeriod
        );
    }
}

/**
 * @description Verification flag for system-wide integrity checks.
 */
export const DISCIPLINE_SYSTEM_LOADED: boolean = true;
