/**
 * @file recovery.ts
 * @namespace AOXCDAO.Core.Resilience
 * @version 2.0.0
 * @description Self-Healing & Recovery Protocol - (Resilience-Locked)
 * Defines the state restoration logic and mandatory multi-sig authentication for system resets.
 */

import { FLEET_ID } from "../core/fleet.ts";
import { COMMAND_RANKS } from "../core/hierarchy.ts";

/**
 * @enum RECOVERY_MODES
 * @description Restoration strategies for vessels following a critical forensic event.
 */
export enum RECOVERY_MODES {
    IDLE       = 0x00, // Nominal state
    ROLLBACK   = 0x01, // Revert to last verified integrity block
    HARD_RESET = 0x02, // Full logical reboot: Re-sync from Core
    EMERGENCY_PATCH = 0x03, // Hot-fix injection during live state
}

/**
 * @constant RECOVERY_SECURITY
 * @description Mandatory authentication requirements for triggering a restoration.
 */
export const RECOVERY_SECURITY = {
    REQUIRED_VESSEL: FLEET_ID.ANDROMEDA,
    REQUIRED_RANK:   COMMAND_RANKS.CAPTAIN, 
    MANDATORY_MULTI_SIG: true,
    MIN_SIGNATURES: 2, // Andromeda Prime + One Sentry Node
} as const;

// -----------------------------------------------------------------------------
// ACADEMIC TYPE DEFINITIONS (v2.0.0 UPDATED)
// -----------------------------------------------------------------------------

/**
 * @interface IRecoveryOperation
 * @description Formal structure for a restoration event within the fleet.
 */
export interface IRecoveryOperation {
    readonly operation_id: string; 
    readonly target_vessel: number; 
    readonly mode: RECOVERY_MODES;
    readonly snapshot_hash: string; 
    readonly auth_signatures: string[]; 
    readonly initiated_at: number;
    readonly completion_status: boolean;
}

/**
 * @class ResilienceEngine
 * @description Operational logic for system restoration, multi-sig validation, and state healing.
 */
export class ResilienceEngine {
    /**
     * @method canTriggerRecovery
     * @description Validates if the calling entity has sufficient clearance.
     */
    public static canTriggerRecovery(vesselId: number, rank: number): boolean {
        return (
            vesselId === RECOVERY_SECURITY.REQUIRED_VESSEL && 
            rank === RECOVERY_SECURITY.REQUIRED_RANK
        );
    }

    /**
     * @method validateMultiSig
     * @description Ensures enough authoritative signatures are present for a reset.
     */
    public static validateMultiSig(signatures: string[]): boolean {
        return signatures.length >= RECOVERY_SECURITY.MIN_SIGNATURES;
    }

    /**
     * @method verifySnapshotIntegrity
     * @description Compares the current state hash with the provided clean snapshot.
     */
    public static verifySnapshotIntegrity(currentHash: string, snapshotHash: string): boolean {
        // Academic rule: Reversion only possible if snapshot differs from corrupted state
        return currentHash !== snapshotHash && snapshotHash.startsWith("0x_CLEAN_");
    }

    /**
     * @method executeRecovery
     * @description Final logic gate for executing a vessel restoration.
     */
    public static executeRecovery(op: IRecoveryOperation, currentVesselRank: number): boolean {
        if (!this.canTriggerRecovery(op.target_vessel, currentVesselRank)) return false;
        if (!this.validateMultiSig(op.auth_signatures)) return false;

        // Mode-specific execution logic
        switch (op.mode) {
            case RECOVERY_MODES.ROLLBACK:
                return true; // Log: "Vessel state reverted to snapshot"
            case RECOVERY_MODES.HARD_RESET:
                return true; // Log: "Full logic purge and core resync initiated"
            default:
                return false;
        }
    }
}

/**
 * @function canTriggerRecovery
 * @description Legacy wrapper for direct clearance checks.
 */
export const canTriggerRecovery = (vesselId: number, rank: number): boolean => {
    return ResilienceEngine.canTriggerRecovery(vesselId, rank);
};

export const RESILIENCE_SYSTEM_ARMED: boolean = true;
