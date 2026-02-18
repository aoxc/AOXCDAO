/**
 * @file xtc00_AoxcGenesisMaster_180226.ts
 * @namespace AOXCDAO.Core.XLayer
 * @version 2.0.0 AOXCDAO V2 AKDENIZ
 * @status IMMUTABLE_X_GATEWAY
 * @compiler Solidity 0.8.33 Compatibility
 * @description 
 * Sovereign Bridge and Financial Terminal for OKX & X Layer Integration.
 * Manages cross-chain liquidity, automated swaps, and emergency external protocols.
 */


/**
 * @enum X_EXCHANGE_PROTOCOL
 * @description Native and external swap protocols supported within the X Layer.
 */
export enum X_EXCHANGE_PROTOCOL {
    X_SWAP_NATIVE = 0x01, // Direct OKX X-Layer DEX interaction
    AOXC_INTERNAL = 0x02, // Peer-to-peer within the fleet
    CROSS_CHAIN   = 0x03, // Bridge to other L1/L2 networks
    INSTITUTIONAL = 0x04  // Direct OKX Institutional Liquidity
}

/**
 * @enum EMERGENCY_SIGNAL
 * @description High-priority signals for external network events.
 */
export enum EMERGENCY_SIGNAL {
    NETWORK_CONGESTION = 0x10,
    LIQUIDITY_CRUNCH   = 0x20,
    BRIDGE_HALT        = 0x30,
    SOVEREIGN_EXIT     = 0xFF // Emergency evacuation of all assets to OKX safe-wallets
}

/**
 * @interface IXLayerTerminal
 * @description Configuration for high-frequency financial operations on X Layer.
 */
export interface IXLayerTerminal {
    readonly providerId: string;       // e.g., "OKX_X_LAYER_MAIN"
    readonly gasLimitStrategy: number; // Aggressive, Neutral, or Economic
    readonly defaultSlippageBips: number; // Max 50 (0.5%) for fleet safety
    readonly routerAddress: string;    // The immutable address of the X-Swap router
}

/**
 * @section EXTERNAL_FINANCE_CONFIG
 * @description Rules for asset migration and swap efficiency.
 */
export const X_LAYER_CONFIG = {
    BRIDGE_CONFIRMATIONS: 12,          // Number of blocks for secure asset arrival
    MAX_SWAP_VOLUME_PER_EPOCH: 1000000,// Maximum automated trade volume
    STAKING_REWARD_PRECISION: 10**18,  // Standardized decimals
    FLASH_LOAN_PROTECTION: true        // Anti-exploit mechanism for X Layer
} as const;

export const XTC_GENESIS_LOADED: boolean = true;
