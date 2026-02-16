/**
 * @file justice_protocol.ts
 * @namespace AOXCDAO.Core.Justice
 * @version 1.0.0
 * @description The Framework of Fairness - (Karujan-Justice-Locked)
 * Ensures authority is exercised with transparency and accountability.
 */

/**
 * @constant JUSTICE_STANDARDS
 * @description Mandatory ethical and operational limits for the AOXC fleet.
 */
export const JUSTICE_STANDARDS = {
    MAX_VETO_REPETITION:   3,     // Maximum consecutive vetoes on a single topic
    TRANSPARENCY_REQUIRED: true,  // Every command MUST include an IPFS justification
    MIN_APPEAL_PERIOD:     86400, // 24-hour window for formal appeals (Seconds)
    EQUITY_RATIO:          0.2,   // 20% Minimum resource allocation for merit-based tiers
} as const;

/**
 * @enum AUDIT_RESULT
 * @description The outcome of a justice review.
 */
export enum AUDIT_RESULT {
    JUSTIFIED   = 0x01, // Action aligns with Justice Standards
    UNJUSTIFIED = 0x02, // Breach of ethics: Action reversible
    VOID        = 0x03, // Action cancelled: Lack of reasoning
}

// -----------------------------------------------------------------------------
// ACADEMIC TYPE DEFINITIONS (v1.0.0 UPDATED)
// -----------------------------------------------------------------------------

/**
 * @interface IJusticeAudit
 * @description Standardized record for every judicial action within the DAO.
 */
export interface IJusticeAudit {
    readonly action_id: string;
    readonly actor_id: string; 
    readonly affected_id: string; 
    readonly justification_hash: string; 
    readonly is_fair_checked: boolean;
    readonly timestamp: number;
    readonly audit_status: AUDIT_RESULT;
}

/**
 * @class JusticeValidator
 * @description Logic for enforcing transparency and merit-based fairness.
 */
export class JusticeValidator {
    /**
     * @method validateVetoCapacity
     * @description Checks if the Karujan/Officer has exceeded their veto limit.
     */
    public static canVeto(currentCount: number): boolean {
        return currentCount < JUSTICE_STANDARDS.MAX_VETO_REPETITION;
    }

    /**
     * @method isAppealWindowOpen
     * @description Verifies if the 24-hour window for appeals is still active.
     */
    public static isAppealWindowOpen(actionTimestamp: number): boolean {
        const now = Math.floor(Date.now() / 1000);
        return (now - actionTimestamp) <= JUSTICE_STANDARDS.MIN_APPEAL_PERIOD;
    }

    /**
     * @method auditAction
     * @description Evaluates an action based on the presence of a justification hash.
     */
    public static auditAction(audit: IJusticeAudit): AUDIT_RESULT {
        if (JUSTICE_STANDARDS.TRANSPARENCY_REQUIRED && !audit.justification_hash) {
            return AUDIT_RESULT.VOID;
        }
        
        return audit.is_fair_checked ? AUDIT_RESULT.JUSTIFIED : AUDIT_RESULT.UNJUSTIFIED;
    }

    /**
     * @method calculateEquityDistribution
     * @description Ensures the 20% equity floor is respected in resource movements.
     */
    public static enforceEquity(amount: bigint): bigint {
        return (amount * BigInt(JUSTICE_STANDARDS.EQUITY_RATIO * 100)) / 100n;
    }
}

/**
 * @description Verification flag for Justice System operationality.
 */
export const JUSTICE_PROTOCOL_ONLINE: boolean = true;
