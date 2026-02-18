/**
 * @section AI_CONSISTENCY_AUDIT_CONSTANTS
 * @description These constants ensure that every AI decision is derived from 
 * historical on-chain events, making the AI's logic fully auditable and stable.
 */

export const AI_AUDIT_CONFIG = {
    /** * @constant LOGIC_DERIVATION_MANDATORY 
     * @description AI must link every decision to at least one historical 'MomentHash'.
     */
    LOGIC_DERIVATION_MANDATORY: true,

    /** * @constant ANALYTICAL_CONSISTENCY_BANDS 
     * @description Deviation limit between similar past decisions and current action.
     * Prevents erratic behavior (Max 0.5% variance).
     */
    MAX_LOGIC_DEVIATION_BIPS: 50, 

    /** * @constant PROOF_OF_HISTORY_REQUIRED 
     * @description Requires a cryptographic link to a previous block for context.
     */
    PROOF_OF_HISTORY_REQUIRED: true
} as const;

/**
 * @interface IAuditTrace
 * @description The structure used by auditors to verify AI decision consistency.
 */
export interface IAuditTrace {
    readonly decisionId: string;
    readonly historicalReferenceHash: string; // "Hatırlanan" geçmiş veri referansı
    readonly consistencyScore: number;         // Geçmişle olan mantıksal uyum puanı
    readonly auditorClearanceLevel: number;    // Bu analizi kimler görebilir?
}
