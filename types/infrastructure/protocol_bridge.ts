/**
 * @file discipline.ts
 * @namespace AOXCDAO.Core.Governance
 * @version 2.0.0
 * @description Protocol Compliance & Disciplinary Constants - (Strict-Compliance)
 * Defines protocol adherence levels, enforcement mechanisms, and penalty structures.
 */

/**
 * @enum ADHERENCE_LEVELS
 * @description Status of an entity's compliance with fleet protocols.
 */
export enum ADHERENCE_LEVELS {
    FULL            = 0xa01, // Total compliance
    PARTIAL         = 0xa02, // Minor deviations (Drift)
    VIOLATION       = 0xa03, // Intentional or negligent violation
    CRITICAL_BREACH = 0xa04, // Strategic breach (Security compromised)
}

/**
 * @enum ENFORCEMENT_MODES
 * @description Methods of enforcing protocol compliance.
 */
export enum ENFORCEMENT_MODES {
    AUTO_LOCK        = 0xe01, // Instant system lockdown
    CAPTAIN_OVERRIDE = 0xe02, // Authorized deviation
    SOVEREIGN_VETO   = 0xe03, // Root-level protocol suspension
}

/**
 * @constant DISCIPLINARY_ACTIONS
 * @description Penalties applied based on violation severity.
 */
export const DISCIPLINARY_ACTIONS = {
    ISOLATION:     0x1f, // Digital quarantine
    RANK_DEMOTION: 0x2f, // Reduction in Command Rank
    MERIT_STRIP:   0x3f, // Total erasure of Merit points
    VOID_ACCESS:   0x4f, // Revocation of all authority credentials
} as const;

/**
 * @enum AUDIT_TRIGGERS
 * @description Triggers for formal protocol adherence reviews.
 */
export enum AUDIT_TRIGGERS {
    SCHEDULED   = 0x91, // Routine cycles
    EVENT_BASED = 0x92, // Triggered by forensic events
}

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
    readonly enforcer_vessel: number; 
    readonly justification_hash: string; 
    readonly violation_count: number; // Tracker for repeat offenders
    readonly timestamp: number;
}

/**
 * @class DisciplineManager
 * @description Operational logic for enforcing protocol discipline and penalty mapping.
 */
export class DisciplineManager {
    /**
     * @method calculatePenalty
     * @description Automatically maps an adherence level to a specific penalty.
     */
    public static calculatePenalty(level: ADHERENCE_LEVELS, repeatOffender: boolean): number {
        switch (level) {
            case ADHERENCE_LEVELS.PARTIAL:
                return repeatOffender ? DISCIPLINARY_ACTIONS.RANK_DEMOTION : DISCIPLINARY_ACTIONS.ISOLATION;
            case ADHERENCE_LEVELS.VIOLATION:
                return DISCIPLINARY_ACTIONS.MERIT_STRIP;
            case ADHERENCE_LEVELS.CRITICAL_BREACH:
                return DISCIPLINARY_ACTIONS.VOID_ACCESS;
            default:
                return 0x00;
        }
    }

    /**
     * @method isOverrideAllowed
     * @description Validates if a Captain or Sovereign can override a specific enforcement mode.
     */
    public static isOverrideAllowed(mode: ENFORCEMENT_MODES, callerClearance: number): boolean {
        if (callerClearance === 0xff) return true; // Sovereign always overrides
        if (mode === ENFORCEMENT_MODES.CAPTAIN_OVERRIDE && callerClearance >= 0xf1) return true;
        return false;
    }

    /**
     * @method needsAudit
     * @description Checks if a forensic event (from error.ts) requires a formal audit.
     */
    public static needsAudit(errorCode: number): boolean {
        // High-level error codes (e.g., above 0x500) trigger automatic audits
        return errorCode >= 0x500;
    }

    /**
     * @method generateLegalHash
     * @description Signs a disciplinary record for on-chain finality.
     */
    public static generateLegalHash(record: IDisciplinaryRecord): string {
        return `JUDICIAL_SEAL:${record.record_id}:${record.entity_address}:${record.timestamp}`;
    }
}

/**
 * @description Verification flag for Disciplinary System operational status.
 */
export const DISCIPLINE_SYSTEM_ACTIVE: boolean = true;
