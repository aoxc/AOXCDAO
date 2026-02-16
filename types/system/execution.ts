/**
 * @file execution.ts
 * @namespace AOXCDAO.Core.Execution
 * @version 2.0.0
 * @description Contractual Execution Mapper - (Execution-Locked)
 * Links Forensic Error Signatures to Automated Smart Contract Actions.
 */

import { SECURITY_ERRORS, ECONOMIC_ERRORS, type GlobalErrorSignature } from "../security/error.ts";
export { EXECUTION_STATUS } from "../infrastructure/contract.ts";

/**
 * @enum CONTRACT_ACTIONS
 * @description Pre-defined automated responses for contract-level intervention.
 */
export enum CONTRACT_ACTIONS {
    LOCK_VAULT        = 0xf101, // Secure all assets in the vessel's vault
    REVOKE_VISA       = 0xf102, // Downgrade entity rank instantly
    HALT_SWAP         = 0xe101, // Pause DEX/Liquidity operations
    LIMIT_WITHDRAWAL  = 0xe102, // Set withdrawal cap to emergency limits
    NOTIFY_SOVEREIGN  = 0xff01, // Direct alert to Andromeda Prime
}

/**
 * @constant EXECUTION_MAP
 * @description Academic mapping of Error Signatures to Automated Actions.
 */
export const EXECUTION_MAP: Partial<Record<GlobalErrorSignature, CONTRACT_ACTIONS[]>> = {
    [SECURITY_ERRORS.ERR_SIG_BREACH]: [
        CONTRACT_ACTIONS.LOCK_VAULT, 
        CONTRACT_ACTIONS.REVOKE_VISA
    ],
    [ECONOMIC_ERRORS.ERR_SIG_DRAIN]: [
        CONTRACT_ACTIONS.HALT_SWAP,
        CONTRACT_ACTIONS.LIMIT_WITHDRAWAL,
    ],
    [ECONOMIC_ERRORS.ERR_SIG_ORACLE_FAIL]: [
        CONTRACT_ACTIONS.NOTIFY_SOVEREIGN
    ],
};

/**
 * @constant EXECUTION_CONFIG
 * @description Operational parameters for automated execution.
 */
export const EXECUTION_CONFIG = {
    AUTO_THRESHOLD:    0.95, // 95% Confidence requirement
    RETRY_LIMIT:       3,    // Max attempts before manual override
    ACTION_TIMEOUT:    10,   // Seconds for confirmation
} as const;

// -----------------------------------------------------------------------------
// ACADEMIC TYPE DEFINITIONS (v2.0.0 UPDATED)
// -----------------------------------------------------------------------------

/**
 * @interface IExecutionTrigger
 * @description Structure of an automated intervention request.
 */
export interface IExecutionTrigger {
    readonly trigger_id: string; 
    readonly error_sig: GlobalErrorSignature;
    readonly target_actions: CONTRACT_ACTIONS[];
    readonly confidence_score: number; 
    readonly is_automated: boolean;
    readonly timestamp: number;
}

/**
 * @class ExecutionDispatcher
 * @description Active logic for dispatching and validating automated interventions.
 */
export class ExecutionDispatcher {
    /**
     * @method getActionsForError
     * @description Retrieves the mapped actions for a given error signature.
     */
    public static getActionsForError(sig: GlobalErrorSignature): CONTRACT_ACTIONS[] {
        return EXECUTION_MAP[sig] || [CONTRACT_ACTIONS.NOTIFY_SOVEREIGN];
    }

    /**
     * @method validateExecution
     * @description Ensures the trigger meets the minimum confidence threshold for auto-action.
     */
    public static validateExecution(trigger: IExecutionTrigger): boolean {
        const isConfident = trigger.confidence_score >= EXECUTION_CONFIG.AUTO_THRESHOLD;
        const isNotExpired = (Date.now() - trigger.timestamp) < (EXECUTION_CONFIG.ACTION_TIMEOUT * 1000);
        
        return isConfident && isNotExpired;
    }

    /**
     * @method requiresHumanApproval
     * @description Determines if the incident is too severe for automated resolution.
     */
    public static requiresHumanApproval(sig: GlobalErrorSignature, confidence: number): boolean {
        // Security breaches or low confidence always require a Chief's intervention
        const isSecurity = sig.toString(16).startsWith('fb');
        return isSecurity || confidence < EXECUTION_CONFIG.AUTO_THRESHOLD;
    }

    /**
     * @method logExecutionAttempt
     * @description Creates an immutable record of the execution attempt.
     */
    public static generateExecutionID(sig: GlobalErrorSignature): string {
        return `EXE_ACT_${sig}_${Date.now()}`;
    }
}

/**
 * @description Verification flag for system-wide integrity checks.
 */
export const EXECUTION_SYSTEM_LOADED: boolean = true;
