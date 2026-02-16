/**
 * @file external_risk.ts
 * @namespace AOXCDAO.Core.Interstellar
 * @version 2.0.0
 * @description External Chain Crisis and Risk Management - (Crisis-Locked)
 * Monitors and responds to failures in external blockchain ecosystems.
 */

/**
 * @enum NETWORK_FAILURE_TYPE
 * @description Classification of external network anomalies and collapses.
 */
export enum NETWORK_FAILURE_TYPE {
    NETWORK_HALT      = 0xcf1, // Chain stopped producing blocks
    REORG_ATTACK      = 0xcf2, // Deep chain reorganization (51% attack)
    BRIDGE_EXPLOIT    = 0xcf3, // Liquidity drained from the bridge
    ORACLE_CORRUPTION = 0xcf4, // Toxic/Manipulated external data
    RPC_TIMEOUT       = 0xcf5, // Infrastructure unresponsive
}

/**
 * @enum CRISIS_RESPONSE_LEVEL
 * @description Automated defense actions based on failure severity.
 */
export enum CRISIS_RESPONSE_LEVEL {
    MONITOR_ONLY   = 0x10, // Minor latency detected
    SUSPEND_TRADE  = 0x20, // Risk detected: Disable swaps
    EMERGENCY_EXIT = 0x30, // High risk: Withdraw liquidity to AOXC Mainnet
    SCORCHED_EARTH = 0x40, // Total collapse: Sever all links permanently
}

/**
 * @constant RISK_THRESHOLDS
 * @description Parameters for triggering automated crisis responses.
 */
export const RISK_THRESHOLDS = {
    MAX_REORG_DEPTH:     12,  // Blocks depth limit
    MAX_PRICE_DEVIATION: 15.0, // 15% Drift limit
    MAX_RPC_RETRY:       5,   // Connection retry limit
    HEARTBEAT_TIMEOUT:   300, // 5 Minute halt limit
} as const;

// -----------------------------------------------------------------------------
// ACADEMIC TYPE DEFINITIONS (v2.0.0 UPDATED)
// -----------------------------------------------------------------------------

/**
 * @interface IExternalChainStatus
 * @description Real-time health audit of a foreign blockchain network.
 */
export interface IExternalChainStatus {
    readonly chain_id: number;
    readonly last_synced_block: number;
    readonly failure_state: NETWORK_FAILURE_TYPE | null;
    readonly response_tier: CRISIS_RESPONSE_LEVEL;
    readonly is_liquidity_locked: boolean;
    readonly audit_hash: string; 
}

/**
 * @class CrisisManager
 * @description Logic for assessing external health and executing circuit breakers.
 */
export class CrisisManager {
    /**
     * @method evaluateRisk
     * @description Determines the response tier based on detected external anomalies.
     */
    public static evaluateRisk(failure: NETWORK_FAILURE_TYPE | null): CRISIS_RESPONSE_LEVEL {
        if (!failure) return CRISIS_RESPONSE_LEVEL.MONITOR_ONLY;

        switch (failure) {
            case NETWORK_FAILURE_TYPE.BRIDGE_EXPLOIT:
                return CRISIS_RESPONSE_LEVEL.SCORCHED_EARTH;
            case NETWORK_FAILURE_TYPE.NETWORK_HALT:
            case NETWORK_FAILURE_TYPE.REORG_ATTACK:
                return CRISIS_RESPONSE_LEVEL.EMERGENCY_EXIT;
            case NETWORK_FAILURE_TYPE.ORACLE_CORRUPTION:
            case NETWORK_FAILURE_TYPE.RPC_TIMEOUT:
                return CRISIS_RESPONSE_LEVEL.SUSPEND_TRADE;
            default:
                return CRISIS_RESPONSE_LEVEL.MONITOR_ONLY;
        }
    }

    /**
     * @method shouldTriggerCircuitBreaker
     * @description Checks if heartbeat or reorg depth exceeds safe limits.
     */
    public static shouldTriggerCircuitBreaker(blockDrift: number, lastSeenSeconds: number): boolean {
        const isHalted = lastSeenSeconds >= RISK_THRESHOLDS.HEARTBEAT_TIMEOUT;
        const isDeepReorg = blockDrift >= RISK_THRESHOLDS.MAX_REORG_DEPTH;
        
        return isHalted || isDeepReorg;
    }

    /**
     * @method getMitigationStrategy
     * @description Returns a text-based strategy for the MonitoringHub.
     */
    public static getMitigationStrategy(level: CRISIS_RESPONSE_LEVEL): string {
        switch (level) {
            case CRISIS_RESPONSE_LEVEL.SCORCHED_EARTH:
                return "PROTOCOL_SEVERANCE: Burning Bridge Credentials.";
            case CRISIS_RESPONSE_LEVEL.EMERGENCY_EXIT:
                return "LIQUIDITY_RECALL: Executing Vault Withdrawals.";
            case CRISIS_RESPONSE_LEVEL.SUSPEND_TRADE:
                return "MARKET_PAUSE: Disabling External Swap Routes.";
            default:
                return "PASSIVE_OBSERVATION: Monitoring Network Health.";
        }
    }
}

/**
 * @function evaluateRisk
 * @description Legacy functional wrapper for risk evaluation.
 */
export const evaluateRisk = (failure: NETWORK_FAILURE_TYPE): CRISIS_RESPONSE_LEVEL => {
    return CrisisManager.evaluateRisk(failure);
};

export const EXTERNAL_RISK_SYSTEM_LOADED: boolean = true;
