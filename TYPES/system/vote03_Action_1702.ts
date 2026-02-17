/**
 * @file action.ts
 * @namespace AOXCDAO.Communication.Protocols
 * @version 2.0.0
 * @description Operational & Transactional Consensus Codes for AOXC-V2-AKDENIZ.
 * This registry is the "Single Source of Truth" for Cross-Vessel communication.
 */

/**
 * @constant ACTION_REGISTRY
 * @description Hex-encoded operational codes for on-chain and off-chain synchronization.
 */
export const ACTION_REGISTRY = {
    // 0xA0-0xAF: Governance & Proposed Actions
    GOVERNANCE: {
        PROPOSE: 0xa1, // Initial Proposal
        VOTE:    0xa2, // Stake-Weighted Consensus
        COMMIT:  0xa3, // Execution to Internal Ledger
    },

    // 0xB0-0xBF: System & Audit Operations
    AUDIT: {
        TRACE:          0xb1, // Forensic Security Scan
        SYNC_CELL:      0xb2, // Triple-Lock Identity Sync
        EMERGENCY_HALT: 0xff, // Immediate System Shutdown
    },
} as const;

/**
 * @type ActionCode
 * @description Derived type for strict compiler validation across the AOXC ecosystem.
 */
export type ActionCode =
    | (typeof ACTION_REGISTRY.GOVERNANCE)[keyof typeof ACTION_REGISTRY.GOVERNANCE]
    | (typeof ACTION_REGISTRY.AUDIT)[keyof typeof ACTION_REGISTRY.AUDIT];

/**
 * @interface IActionMetadata
 * @description Full structure of an operational command within the fleet.
 */
export interface IActionMetadata {
    readonly code: ActionCode;
    readonly actor_vessel: number;
    readonly timestamp: number;
    readonly payload_hash: string;
    readonly requires_consensus: boolean;
}

/**
 * @class ActionGuard
 * @description Functional utilities to validate and categorize incoming actions.
 */
export class ActionGuard {
    /**
     * @method isGovernanceAction
     * @description Determines if the action code belongs to the Governance domain.
     */
    public static isGovernanceAction(code: ActionCode): boolean {
        return code >= 0xa0 && code <= 0xaf;
    }

    /**
     * @method isAuditAction
     * @description Determines if the action code belongs to the Audit domain.
     */
    public static isAuditAction(code: ActionCode): boolean {
        return code >= 0xb0 && code <= 0xbf;
    }

    /**
     * @method isEmergencyTrigger
     * @description Checks if the action is a system-wide EMERGENCY_HALT.
     */
    public static isEmergencyTrigger(code: ActionCode): boolean {
        return code === ACTION_REGISTRY.AUDIT.EMERGENCY_HALT;
    }

    /**
     * @method validateActionSync
     * @description Ensures the action metadata meets the required integrity flags.
     */
    public static validateActionSync(action: IActionMetadata): boolean {
        if (this.isEmergencyTrigger(action.code)) return true;
        if (action.requires_consensus && !action.payload_hash) return false;
        return action.timestamp <= Date.now();
    }
}

/**
 * @description Verification flag for system-wide integrity checks.
 */
export const ACTION_V2_LOADED: boolean = true;
