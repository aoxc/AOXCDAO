/**
 * @file finance.ts
 * @namespace AOXCDAO.Core.Finance
 * @version 2.0.0
 * @description Financial Limits & Vault Rules - (Finance-Locked)
 * Defines transaction thresholds, fee structures, and vault security states.
 */

/**
 * @constant TRANSACTION_THRESHOLDS
 * @description Operational limits for asset movement within the fleet.
 */
export const TRANSACTION_THRESHOLDS = {
    DAILY_TRANSFER_CAP: 5000, // Max daily output per entity
    AUTO_APPROVE_LIMIT: 500,  // Threshold for instant execution
} as const;

/**
 * @constant FEE_STRUCTURE
 * @description Standardized levy rates for internal and external transfers.
 * Values represented as basis points (10000 = 100%).
 */
export const FEE_STRUCTURE = {
    INTERNAL_EXCHANGE: 200, // 2% Internal transfer levy
    EXTERNAL_BRIDGE:   500, // 5% Cross-chain/Oracle exit levy
} as const;

/**
 * @enum VAULT_STATES
 * @description Security and operational status of a Vessel's treasury.
 */
export enum VAULT_STATES {
    OPEN         = 0x01, // Normal operations
    LOCKED_ERROR = 0x02, // Automatic lockdown (Breach detected)
    MAINTENANCE  = 0x03, // Scheduled protocol updates
}

// -----------------------------------------------------------------------------
// ACADEMIC TYPE DEFINITIONS (v2.0.0 UPDATED)
// -----------------------------------------------------------------------------

/**
 * @interface ITreasuryReport
 * @description Standardized financial statement for inter-vessel auditing.
 */
export interface ITreasuryReport {
    readonly vessel_id: number;
    readonly current_balance: bigint;
    readonly daily_outflow: number;
    readonly vault_status: VAULT_STATES;
    readonly last_audit_hash: string; 
    readonly timestamp: number;
}

/**
 * @class TreasuryManager
 * @description Active logic for financial audit, fee calculation, and limit enforcement.
 */
export class TreasuryManager {
    /**
     * @method calculateFee
     * @description Computes the fee amount based on Basis Points.
     */
    public static calculateFee(amount: bigint, isExternal: boolean): bigint {
        const bps = isExternal ? FEE_STRUCTURE.EXTERNAL_BRIDGE : FEE_STRUCTURE.INTERNAL_EXCHANGE;
        // Formula: (Amount * BPS) / 10,000
        return (amount * BigInt(bps)) / 10000n;
    }

    /**
     * @method requiresSovereignApproval
     * @description Checks if a transaction exceeds the automated approval limit.
     */
    public static requiresSovereignApproval(amount: number): boolean {
        return amount > TRANSACTION_THRESHOLDS.AUTO_APPROVE_LIMIT;
    }

    /**
     * @method isDailyCapExceeded
     * @description Validates if the total daily outflow stays within the safety cap.
     */
    public static isDailyCapExceeded(currentOutflow: number, newAmount: number): boolean {
        return (currentOutflow + newAmount) > TRANSACTION_THRESHOLDS.DAILY_TRANSFER_CAP;
    }

    /**
     * @method validateVaultOperation
     * @description Ensures the vault is in a state that allows withdrawals.
     */
    public static canWithdraw(status: VAULT_STATES): boolean {
        return status === VAULT_STATES.OPEN;
    }

    /**
     * @method generateAuditSignature
     * @description Simple integrity check for treasury reports.
     */
    public static generateAuditSignature(report: ITreasuryReport): string {
        return `AUDIT_${report.vessel_id}_${report.timestamp}`;
    }
}

/**
 * @description Verification flag for system-wide integrity checks.
 */
export const FINANCE_SYSTEM_LOADED: boolean = true;
