/**
 * @file diplomacy_trade.ts
 * @namespace AOXCDAO.Core.Interstellar
 * @version 2.0.0
 * @description Inter-Chain Diplomacy and Universal Trade Constants - (Diplomacy-Locked)
 */

/**
 * @enum DIPLOMATIC_STATUS
 * @description Formal relationship status with external chains or foreign fleets.
 */
export enum DIPLOMATIC_STATUS {
    ALLIED_PARTNER  = 0xd1, // Full trust: Shared liquidity
    NEUTRAL_TRADER  = 0xd2, // Standard trade: Subject to tariffs
    RESTRICTED_ZONE = 0xd3, // Suspicious: Monitoring active
    HOSTILE_ENTITY  = 0xd4, // Sanctioned: All bridges locked
}

/**
 * @enum TRADE_ASSET_CLASS
 * @description Standardized categories for assets being swapped or traded.
 */
export enum TRADE_ASSET_CLASS {
    LIQUID_CURRENCY    = 0xc1, // Native coins
    GOVERNANCE_FUEL    = 0xc2, // Voting power/Gas
    COMMODITY_RESOURCE = 0xc3, // Raw materials
    INTELLECTUAL_DATA  = 0xc4, // Forensic data/AI models
}

/**
 * @enum EXCHANGE_PROTOCOL
 * @description Methods of cross-chain asset movement and settlement.
 */
export enum EXCHANGE_PROTOCOL {
    ATOMIC_SWAP       = 0xe1, // Trustless P2P
    LIQUIDITY_BRIDGE  = 0xe2, // AMM routing
    ESCROW_SETTLEMENT = 0xe3, // Council verified trade
}

/**
 * @constant GLOBAL_COMMERCE_RULES
 * @description Standardized taxes and limits for external chain interaction.
 */
export const GLOBAL_COMMERCE_RULES = {
    DEFAULT_INTERCHAIN_TAX: 0.02, // 2% Operational fee
    MIN_DIPLOMATIC_MERIT:   500,  // Min Merit for trade
    MAX_BRIDGE_SLIPPAGE:    1.0,  // 1.0% max slippage
} as const;

// -----------------------------------------------------------------------------
// ACADEMIC TYPE DEFINITIONS (v2.0.0 UPDATED)
// -----------------------------------------------------------------------------

/**
 * @interface ITradeManifest
 * @description Formal structure for an inter-chain trade agreement.
 */
export interface ITradeManifest {
    readonly trade_id: string; 
    readonly target_chain_id: number; 
    readonly asset_class: TRADE_ASSET_CLASS;
    readonly amount: bigint;
    readonly protocol: EXCHANGE_PROTOCOL;
    readonly diplomatic_clearance: DIPLOMATIC_STATUS;
    readonly timestamp: number;
    readonly ayra_approval_sig: string; 
}

/**
 * @class DiplomaticBridgeController
 * @description Logic for cross-chain trade authorization and fiscal calculations.
 */
export class DiplomaticBridgeController {
    /**
     * @method canInitiateTrade
     * @description Enforces diplomatic clearance for commerce.
     */
    public static canInitiateTrade(status: DIPLOMATIC_STATUS): boolean {
        return (
            status === DIPLOMATIC_STATUS.ALLIED_PARTNER || 
            status === DIPLOMATIC_STATUS.NEUTRAL_TRADER
        );
    }

    /**
     * @method calculateNetSettlement
     * @description Computes the final amount after applying diplomatic tariffs.
     */
    public static calculateNetSettlement(amount: bigint, status: DIPLOMATIC_STATUS): bigint {
        // Allied partners pay 0% tax, others pay DEFAULT_INTERCHAIN_TAX
        if (status === DIPLOMATIC_STATUS.ALLIED_PARTNER) return amount;
        
        const taxRate = GLOBAL_COMMERCE_RULES.DEFAULT_INTERCHAIN_TAX;
        const taxAmount = BigInt(Math.floor(Number(amount) * taxRate));
        return amount - taxAmount;
    }

    /**
     * @method validateSlippage
     * @description Ensures the trade price movement is within the XLayer safety buffer.
     */
    public static validateSlippage(predicted: number, actual: number): boolean {
        const slippage = Math.abs((actual - predicted) / predicted) * 100;
        return slippage <= GLOBAL_COMMERCE_RULES.MAX_BRIDGE_SLIPPAGE;
    }

    /**
     * @method getProtocolRisk
     * @description Returns a risk coefficient based on the chosen exchange protocol.
     */
    public static getProtocolRisk(protocol: EXCHANGE_PROTOCOL): number {
        switch (protocol) {
            case EXCHANGE_PROTOCOL.ATOMIC_SWAP: return 0.1; // Low risk
            case EXCHANGE_PROTOCOL.ESCROW_SETTLEMENT: return 0.2; // Medium (Council delay)
            case EXCHANGE_PROTOCOL.LIQUIDITY_BRIDGE: return 0.4; // Higher (Liquidity risk)
            default: return 0.5;
        }
    }
}

/**
 * @function canInitiateTrade
 * @description Legacy functional wrapper for diplomatic checks.
 */
export const canInitiateTrade = (status: DIPLOMATIC_STATUS): boolean => {
    return DiplomaticBridgeController.canInitiateTrade(status);
};

export const DIPLOMACY_SYSTEM_LOADED: boolean = true;
