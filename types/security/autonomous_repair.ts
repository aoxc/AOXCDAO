/**
 * @file autonomous_repair.ts
 * @namespace AOXCDAO.Core.Automation
 * @version 3.0.0
 * @description Autonomous System Repair, Evolution & Logic Restoration - (Self-Healing-Locked)
 * Standardized to Karujan Pro-Ultimate requirements for automated fleet maintenance.
 */

import { KARUJAN_SPECIFICATIONS } from "../core/karujan_authority.ts";

/**
 * @enum REPAIR_STRATEGY
 * @description Advanced recovery and evolution strategies.
 */
export enum REPAIR_STRATEGY {
    LOGIC_REBOOT       = 0x301, // Restarting state machines
    STATE_ROLLBACK     = 0x302, // Reverting to last verified on-chain snapshot
    BRIDGE_RECOUP      = 0x303, // Re-syncing liquidity balances after drift
    EVOLUTIONARY_PATCH = 0x304  // APPLYING NEW CODE (Requires Karujan 0xFF)
}

/**
 * @constant REPAIR_LIMITS
 * @description Hard constraints to prevent infinite loop or unauthorized changes.
 */
export const REPAIR_LIMITS = {
    MAX_AUTO_ATTEMPTS: 3,
    RESTORATION_THRESHOLD: 0.99,
    COOL_DOWN_MS: 300000,
    SIGNATURE_MANDATORY: true  // Evolution strategy REQUIRES Karujan proof
} as const;

/**
 * @interface IRepairLog
 * @description Comprehensive record of a repair or evolution event.
 */
export interface IRepairLog {
    readonly incident_id: string;
    readonly target_module: string;
    readonly strategy: REPAIR_STRATEGY;
    readonly success_rate: number;
    readonly repaired_at: number;
    readonly attempt_count: number;
    readonly karujan_approval_hash?: string; // Only present if strategy is 0x304
}

/**
 * @class RepairController
 * @description Orchestrates automated healing and code evolution across the fleet.
 */
export class RepairController {
    /**
     * @method canAttemptRepair
     * @description Enforces COOL_DOWN and MAX_AUTO_ATTEMPTS constraints.
     */
    public static canAttemptRepair(log: IRepairLog): boolean {
        const isWithinLimits = log.attempt_count < REPAIR_LIMITS.MAX_AUTO_ATTEMPTS;
        const isCooldownExpired = (Date.now() - log.repaired_at) > REPAIR_LIMITS.COOL_DOWN_MS;
        
        return isWithinLimits && isCooldownExpired;
    }

    /**
     * @method selectStrategy
     * @description Dynamically selects the least invasive repair method.
     */
    public static selectStrategy(driftScore: number, isSecurityBreach: boolean): REPAIR_STRATEGY {
        if (isSecurityBreach) return REPAIR_STRATEGY.STATE_ROLLBACK;
        if (driftScore > 0.15) return REPAIR_STRATEGY.BRIDGE_RECOUP;
        return REPAIR_STRATEGY.LOGIC_REBOOT;
    }

    /**
     * @method executeEmergencyRollback
     * @description Force-reverts a module to the last known stable state.
     */
    public static executeEmergencyRollback(moduleName: string): string {
        return `[REPAIR_EXECUTION] MODULE: ${moduleName} | STATUS: REVERTED_TO_STABLE_SNAPSHOT`;
    }

    /**
     * @method requestEvolutionaryRepair
     * @description Prepares a patch and requests Karujan's digital seal.
     */
    public static requestEvolutionaryRepair(patchHash: string, clearance: number): string {
        if (clearance < KARUJAN_SPECIFICATIONS.CLEARANCE_LEVEL) {
            return "ERROR: INSUFFICIENT_CLEARANCE_FOR_EVOLUTION";
        }
        return `REPAIR_PENDING_KARUJAN_AUTHORIZATION_${patchHash}`;
    }
}

/**
 * @function requestEvolutionaryRepair
 * @description Legacy wrapper for direct AI-driven evolution requests.
 */
export const requestEvolutionaryRepair = (patchHash: string): string => {
    return RepairController.requestEvolutionaryRepair(patchHash, KARUJAN_SPECIFICATIONS.CLEARANCE_LEVEL);
};

export { KARUJAN_SPECIFICATIONS };
export const REPAIR_SYSTEM_LOADED: boolean = true;
