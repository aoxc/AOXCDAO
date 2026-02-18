/**
 * @file cpx00_AoxcGenesisMaster_180226.ts
 * @namespace AOXCDAO.Core.PlanC
 * @version 2.0.0 AOXCDAO V2 AKDENIZ
 * @status CRITICAL_EMERGENCY_ROOT
 * @compiler Solidity 0.8.33 Compatibility
 * @description 
 * Extreme Emergency Protocols (Plan C). Defines the parameters for system-wide 
 * freezing, asset evacuation to X Layer/OKX, and sovereign data recovery.
 */


/**
 * @enum EXIT_THRESHOLD
 * @description Defines the severity levels that trigger Plan C.
 */
export enum EXIT_THRESHOLD {
    NEURAL_COMPROMISE = 0x01, // AI logic is corrupted or hijacked
    SHARD_COLLAPSE    = 0x02, // More than 51% of Shards are unresponsive
    LIQUIDITY_BLACK_HOLE = 0x03, // Bank00 total depletion threat
    EXTINCTION_EVENT  = 0xFF  // Total hostile takeover/System-wide failure
}

/**
 * @enum RECOVERY_DESTINATION
 * @description Where the data and assets are moved during the collapse.
 */
export enum RECOVERY_DESTINATION {
    OKX_S_WALLET      = 0x10, // Sovereign Multi-Sig Cold Wallets on OKX
    X_LAYER_VAULT     = 0x20, // Emergency Smart Contract on X Layer L2
    ADMIRAL_HANDHELD  = 0x30, // Direct transfer to Admiral's private keys
    DEEP_SPACE_CACHING = 0xFF  // Fragmented data encryption across nodes
}

/**
 * @interface IPlanCManifest
 * @description The structure of the "Last Block" recorded before system freeze.
 */
export interface IPlanCManifest {
    readonly triggerId: string;
    readonly severity: EXIT_THRESHOLD;
    readonly totalAssetsAtExit: bigint;
    readonly snapshotBlock: bigint;   // The final point of truth
    readonly targetGateway: RECOVERY_DESTINATION;
    readonly emergencyAdminHash: string; // Final verification key (Admiral only)
}

/**
 * @section PLAN_C_EXECUTION_CONSTANTS
 * @description Hard-coded limits for the evacuation process.
 */
export const PLAN_C_CONFIG = {
    /** @description Time (in blocks) to complete evacuation before full system wipe. */
    EVACUATION_WINDOW_BLOCKS: 500, 
    
    /** @description If TRUE, all private keys and sensitive logs are auto-encrypted. */
    AUTO_ENCRYPTION_MANDATORY: true,
    
    /** @description Minimum Shard agreement to cancel Plan C (if triggered). */
    ABORT_QUORUM: 0.95, // 95% - Almost impossible to stop once started
    
    /** @description Percentage of assets prioritized for civilian evacuation. */
    CIVILIAN_RESCUE_PRIORITY_PCT: 100 
} as const;

export const PLAN_C_GENESIS_LOADED: boolean = true;
