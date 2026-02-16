/**
 * @file xlayer_bridge.ts
 * @namespace AOXCDAO.Core.Network
 * @version 2.0.0
 * @description XLayer (OKX L2) Native Integration Constants - (Home-Locked)
 * Defines the operational parameters for the AOXC fleet within the XLayer environment.
 */

/**
 * @constant XLAYER_NETWORK_PARAMS
 * @description Core network identification for XLayer Mainnet/Testnet.
 */
export const XLAYER_NETWORK_PARAMS = {
    CHAIN_ID: 196, // XLayer Mainnet Identifier
    TESTNET_ID: 195, // XLayer Testnet Identifier
    NATIVE_TOKEN: "OKB", // Primary fuel for transaction gas
    CONSENSUS_TYPE: "zkEVM", // Zero-Knowledge Rollup Architecture
    BLOCK_TIME_MS: 2000, // Targeted block production speed
} as const;

/**
 * @enum XLAYER_GAS_STRATEGY
 * @description Optimized gas tiers for XLayer's prioritized transaction lane.
 */
export enum XLAYER_GAS_STRATEGY {
    INSTANT_FINALITY = 0xaa1, // Highest priority: Critical execution/emergency
    STANDARD_ROLLUP = 0xaa2, // Normal operations: Balanced cost
    BATCH_SUBMISSION = 0xaa3, // Low priority: Mass data footprints (Ref: optimization.ts)
}

/**
 * @constant ZK_PROOF_THRESHOLDS
 * @description Parameters for Zero-Knowledge proof verification and finalization.
 */
export const ZK_PROOF_THRESHOLDS = {
    PROOF_GENERATION_TIMEOUT: 1200, // Seconds before a proof is considered delayed
    BATCH_GAS_LIMIT: 30000000, // Maximum gas per ZK-batch
    MIN_CONFIRMATIONS: 1, // L2 provides near-instant finality
} as const;

/**
 * @enum OKX_ECOSYSTEM_HOOKS
 * @description Points of integration within the broader OKX environment.
 */
export enum OKX_ECOSYSTEM_HOOKS {
    WALLET_INTEGRATION = 0x901, // OKX Wallet connection status
    DEX_LIQUIDITY = 0x902, // OKX DEX (XSwap) liquidity interface
    ORACLE_PRICE_FEED = 0x903, // XLayer native price oracles
}

// -----------------------------------------------------------------------------
// ACADEMIC TYPE DEFINITIONS (v2.0.0)
// -----------------------------------------------------------------------------

/**
 * @interface IXLayerState
 * @description Monitors the synchronization health between AOXC and XLayer.
 */
export interface IXLayerState {
    readonly current_l2_block: number;
    readonly l1_finalized_block: number; // Ethereum L1 anchor block
    readonly is_sequencer_online: boolean;
    readonly active_gas_price: bigint;
    readonly zk_proof_status: "VALIDATED" | "PENDING" | "FAILED";
}

/**
 * @function getXLayerExplorerUrl
 * @description Generates the official explorer link for forensic auditing.
 */
export const getXLayerExplorerUrl = (txHash: string): string => {
    return `https://www.okx.com/explorer/xlayer/tx/${txHash}`;
};
