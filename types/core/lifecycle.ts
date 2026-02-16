/**
 * @file lifecycle.ts
 * @namespace AOXCDAO.Core.Lifecycle
 * @version 2.0.0
 * @description Transaction Lifecycle States - (Execution-Locked)
 * Defines the evolutionary stages of a transaction from proposal to archival.
 */

/** * @constant GLOBAL_SYSTEM_VERSION
 * @description Master version mandate for the Karujan Protocol (v2.0.0).
 */
export const GLOBAL_SYSTEM_VERSION = "2.0.0";

/**
 * @enum TX_LIFECYCLE_STATES
 * @description Standardized states for tracking transaction progression.
 * Hex Series: 0xEX - Denotes Execution/Evolution Flow.
 */
export enum TX_LIFECYCLE_STATES {
    PROPOSED   = 0xe0, // Initial request stage
    VALIDATING = 0xe1, // Pegasus/Quasar verification in progress
    AUTHORIZED = 0xe2, // Consensus reached: Permission granted
    EXECUTED   = 0xe3, // Finality: Action written to ledger
    ARCHIVED   = 0xe4, // Forensic History: Cold storage
    REVERTED   = 0xef, // Failure: Transaction rolled back (Emergency State)
}

// -----------------------------------------------------------------------------
// ACADEMIC TYPE DEFINITIONS (v2.0.0 UPDATED)
// -----------------------------------------------------------------------------

/**
 * @interface ITxStateHistory
 * @description Formal audit trail for a transaction's journey through the lifecycle.
 */
export interface ITxStateHistory {
    readonly tx_hash: string;
    readonly current_state: TX_LIFECYCLE_STATES;
    readonly transition_log: {
        readonly from: TX_LIFECYCLE_STATES | null;
        readonly to: TX_LIFECYCLE_STATES;
        readonly timestamp: number;
        readonly node_id?: string; // Which node processed this transition
    }[];
    readonly validator_signature?: string; 
    readonly execution_block?: number; 
}

/**
 * @class LifecycleEngine
 * @description Active state machine for enforcing the Karujan Execution Protocol.
 */
export class LifecycleEngine {
    /**
     * @method isTransitionValid
     * @description Enforces strict state progression.
     * Rules: Sequential flow (0xEX -> 0xEX+1) or Emergency Reversion (-> 0xEF).
     */
    public static isTransitionValid(current: TX_LIFECYCLE_STATES, next: TX_LIFECYCLE_STATES): boolean {
        // Allow Emergency Reversion from any state except ARCHIVED
        if (next === TX_LIFECYCLE_STATES.REVERTED && current !== TX_LIFECYCLE_STATES.ARCHIVED) {
            return true;
        }

        // Standard Academic Rule: Transitions must be sequential
        return next === current + 1;
    }

    /**
     * @method getStatusMetadata
     * @description Returns operational instructions based on the current lifecycle state.
     */
    public static getStatusMetadata(state: TX_LIFECYCLE_STATES): string {
        switch (state) {
            case TX_LIFECYCLE_STATES.PROPOSED:   return "AWAITING_ORACLE_CONSENSUS";
            case TX_LIFECYCLE_STATES.VALIDATING: return "PEER_REVIEW_ACTIVE";
            case TX_LIFECYCLE_STATES.AUTHORIZED: return "X_LAYER_STAGING_READY";
            case TX_LIFECYCLE_STATES.EXECUTED:   return "LEDGER_FINALIZED";
            case TX_LIFECYCLE_STATES.ARCHIVED:   return "COLD_STORAGE_MIGRATION";
            case TX_LIFECYCLE_STATES.REVERTED:   return "CRITICAL_LOGIC_FAILURE_ROLLBACK";
            default: return "UNKNOWN_STATE_VOID";
        }
    }

    /**
     * @method isFinalized
     * @description Checks if the transaction has reached a terminal state.
     */
    public static isFinalized(state: TX_LIFECYCLE_STATES): boolean {
        return state === TX_LIFECYCLE_STATES.EXECUTED || 
               state === TX_LIFECYCLE_STATES.ARCHIVED || 
               state === TX_LIFECYCLE_STATES.REVERTED;
    }
}

/**
 * @function isTransitionValid
 * @description Legacy wrapper for backward compatibility.
 */
export const isTransitionValid = (current: TX_LIFECYCLE_STATES, next: TX_LIFECYCLE_STATES): boolean => {
    return LifecycleEngine.isTransitionValid(current, next);
};

export const LIFECYCLE_CORE_READY: boolean = true;
