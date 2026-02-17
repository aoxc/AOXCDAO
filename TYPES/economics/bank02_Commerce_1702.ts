/**
 * @file commerce.ts
 * @namespace AOXCDAO.Core.Commerce
 * @version 2.0.0
 * @description Cross-Vessel Commerce & Swap Protocols - (Interoperability-Locked)
 * Standard: Pro-Ultimate Academic English (Zero-Turkish Policy).
 */

import { type FLEET_REGISTRY } from "../system/registry.ts";

/**
 * @constant PRODUCT_ORIGINS
 * @description Unique asset identifiers mapped to their producing Vessel.
 * Format: 0xD + [VESSEL_ID] + [ASSET_ID]
 */
export const PRODUCT_ORIGINS = {
    VIRGO: {
        RAW_WATER: 0xd211, // Standardized Pure Water Resource
        RAW_STEEL: 0xd212, // Refined Industrial Steel
    },
    AQUILA: {
        SOVEREIGN_CREDIT: 0xd321, // Fleet-wide standard liquidity
        GOVERNANCE_BOND:  0xd322, // Yield-bearing governance assets
    },
    PEGASUS: {
        INTEL_FEED:  0xd531, // Validated Data Streams
        AUTH_CERT:   0xd532, // Identity/Validation certificates
    },
} as const;

/**
 * @enum SWAP_STRATEGIES
 * @description Exchange logic types for intra-fleet asset transfers.
 */
export enum SWAP_STRATEGIES {
    FIXED       = 0x01, // 1:1 Pegged Exchange
    DYNAMIC     = 0x02, // Market-driven (Liquidity Pool)
    MERIT_BASED = 0x03, // Price adjusted by Entity's Merit Rank
}

// -----------------------------------------------------------------------------
// ACADEMIC TYPE DEFINITIONS (v2.0.0 UPDATED)
// -----------------------------------------------------------------------------

export type AssetCode =
    | (typeof PRODUCT_ORIGINS.VIRGO)[keyof typeof PRODUCT_ORIGINS.VIRGO]
    | (typeof PRODUCT_ORIGINS.AQUILA)[keyof typeof PRODUCT_ORIGINS.AQUILA]
    | (typeof PRODUCT_ORIGINS.PEGASUS)[keyof typeof PRODUCT_ORIGINS.PEGASUS];

/**
 * @interface ITradeManifest
 * @description Formal structure for an intra-fleet commerce transaction.
 */
export interface ITradeManifest {
    readonly trade_id: string; 
    readonly seller_vessel: number; 
    readonly buyer_vessel: number; 
    readonly asset_code: AssetCode; 
    readonly quantity: bigint; 
    readonly strategy: SWAP_STRATEGIES; 
    readonly timestamp: number; 
}

/**
 * @class CommerceEngine
 * @description Active logic for cross-vessel asset valuation and swap execution.
 */
export class CommerceEngine {
    /**
     * @method verifyAssetOrigin
     * @description Ensures the asset code matches the seller vessel's authorized production line.
     */
    public static verifyAssetOrigin(asset: AssetCode, vesselId: number): boolean {
        const hexStr = asset.toString(16);
        // Logic: 0xD + [VESSEL_ID] + [ASSET_ID]
        // Example: 0xd211 -> Vessel ID is '2'
        const originIdentifier = parseInt(hexStr.substring(1, 2), 16);
        return originIdentifier === vesselId;
    }

    /**
     * @method calculateSwapRate
     * @description Computes the final asset price based on strategy and entity merit.
     * @param basePrice - The raw market or pegged price.
     * @param meritScore - The buyer's reputation/rank (0.0 to 1.0).
     */
    public static calculateSwapRate(
        basePrice: bigint, 
        strategy: SWAP_STRATEGIES, 
        meritScore: number = 0.5
    ): bigint {
        switch (strategy) {
            case SWAP_STRATEGIES.FIXED: {
                return basePrice;
            }
            case SWAP_STRATEGIES.MERIT_BASED: {
                // Logic: Higher merit equals lower price (up to 20% discount)
                const discount = 1 - (meritScore * 0.2);
                return BigInt(Math.floor(Number(basePrice) * discount));
            }
            case SWAP_STRATEGIES.DYNAMIC: {
                // Injected with 5% volatility buffer by default
                const volatility = 1.05;
                return BigInt(Math.floor(Number(basePrice) * volatility));
            }
            default: {
                return basePrice;
            }
        }
    }

    /**
     * @method generateTradeHash
     * @description Creates a unique identifier for the trade manifest.
     */
    public static generateTradeHash(manifest: Omit<ITradeManifest, 'trade_id'>): string {
        return `TRD_${manifest.asset_code}_${manifest.timestamp}_${manifest.seller_vessel}`;
    }
}

export { type FLEET_REGISTRY };
export const COMMERCE_SYSTEM_LOADED: boolean = true;
