/**
 * @file footprint.types.ts
 * @namespace AOXCDAO.Core.Forensics
 * @version 2.0.0
 * @description Dynamic Entity Footprint & Authority Traces - (Legitimacy-Locked)
 * OS Compatibility: Debian/GNU Linux / POSIX
 */

/**
 * @constant MANDATE_FOOTPRINT
 * @description Records the footprint of the captain's electoral legitimacy and mandate lifecycle.
 */
export const MANDATE_FOOTPRINT = {
    TRACE_MANDATE_INIT: 0xb1, // Election sequence initialization trace
    TRACE_MANDATE_VOTE: 0xb2, // Active voting process participation trace
    TRACE_MANDATE_SEAL: 0xb3, // Final inauguration and cryptographic sealing
} as const;

/**
 * @constant ACTIVITY_FOOTPRINT
 * @description Operational traces for personnel and passenger interactions across the fleet.
 */
export const ACTIVITY_FOOTPRINT = {
    TRACE_OP_COMMAND:   0xc1, // Executed authorized Captain/Command action
    TRACE_OP_STAFF:     0xc2, // Personnel technical or operational action
    TRACE_OP_PASSENGER: 0xc3, // Civil/Passenger interaction or movement trace
} as const;

/**
 * @constant VALIDATION_METRICS
 * @description Automated metrics for forensic verification of entity actions.
 */
export const VALIDATION_METRICS = {
    VERIFY_RANK_MATCH:  0x71, // Forensic check: Rank/Action alignment
    VERIFY_TERM_VALID:  0x72, // Temporal check: Active mandate verification
    VERIFY_FAIL_ILLEGAL: 0x73, // Alert: Unauthorized authority attempt
} as const;

// -----------------------------------------------------------------------------
// ACADEMIC TYPE DEFINITIONS (v2.0.0 UPDATED)
// -----------------------------------------------------------------------------

export type MandateTrace = (typeof MANDATE_FOOTPRINT)[keyof typeof MANDATE_FOOTPRINT];
export type ActivityTrace = (typeof ACTIVITY_FOOTPRINT)[keyof typeof ACTIVITY_FOOTPRINT];
export type ValidationMetric = (typeof VALIDATION_METRICS)[keyof typeof VALIDATION_METRICS];

/**
 * @interface IForensicFootprint
 * @description Standardized trace structure for the ForensicPulse and MonitoringHub.
 */
export interface IForensicFootprint {
    readonly trace_code: MandateTrace | ActivityTrace;
    readonly validation_status: ValidationMetric;
    readonly entity_id: string; 
    readonly vessel_context: string; 
    readonly timestamp: number; 
}

/**
 * @class FootprintAnalyst
 * @description Active logic for verifying the legitimacy of footprints left by entities.
 */
export class FootprintAnalyst {
    /**
     * @method isCommandAuthorized
     * @description Checks if a command trace is backed by a valid rank verification.
     */
    public static isCommandAuthorized(footprint: IForensicFootprint): boolean {
        return (
            footprint.trace_code === ACTIVITY_FOOTPRINT.TRACE_OP_COMMAND &&
            footprint.validation_status === VALIDATION_METRICS.VERIFY_RANK_MATCH
        );
    }

    /**
     * @method validateMandateLifeCycle
     * @description Ensures mandate traces follow the logical sequence (Init -> Vote -> Seal).
     */
    public static validateMandateSequence(prevTrace: MandateTrace, currentTrace: MandateTrace): boolean {
        const sequence = [
            MANDATE_FOOTPRINT.TRACE_MANDATE_INIT,
            MANDATE_FOOTPRINT.TRACE_MANDATE_VOTE,
            MANDATE_FOOTPRINT.TRACE_MANDATE_SEAL
        ];
        
        const prevIndex = sequence.indexOf(prevTrace);
        const currentIndex = sequence.indexOf(currentTrace);

        return currentIndex === prevIndex + 1;
    }

    /**
     * @method detectAnomalousActivity
     * @description Identifies footprints that lack proper rank/term verification.
     */
    public static detectAnomalousActivity(footprint: IForensicFootprint): boolean {
        return (
            footprint.validation_status === VALIDATION_METRICS.VERIFY_FAIL_ILLEGAL ||
            (Date.now() / 1000 - footprint.timestamp) > 86400 // Stale audit trace (>24h)
        );
    }

    /**
     * @method generateAuditLog
     * @description Formats the footprint for the MonitoringHub UI.
     */
    public static generateAuditLog(footprint: IForensicFootprint): string {
        const type = footprint.trace_code >= 0xc1 ? "ACTIVITY" : "MANDATE";
        return `[${type}_TRACE] Entity: ${footprint.entity_id} | Vessel: ${footprint.vessel_context} | Status: 0x${footprint.validation_status.toString(16)}`;
    }
}

/**
 * @description Verification flag for system-wide integrity checks.
 */
export const FORENSIC_FOOTPRINT_LOADED: boolean = true;
