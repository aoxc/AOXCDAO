/**
 * @file leg00_AoxcGenesisMaster_180226.ts
 * @namespace AOXCDAO.Core.Legacy
 * @version 2.0.0 AOXCDAO V2 AKDENIZ
 * @status IMMUTABLE_LEGACY_ROOT
 * @compiler Solidity 0.8.33 Compatibility
 * @description 
 * Comprehensive Universal Succession and Legacy Protocol. 
 * Manages the transfer of wealth, rank, and historical narrative 
 * across generational entities and dimensional planes.
 */


/**
 * @enum SUCCESSION_TYPE
 * @description 
 * Deterministic logic for asset redistribution upon entity termination. 
 * Covers all sociological and military scenarios.
 */
export enum SUCCESSION_TYPE {
    /** @description Asset transfer to direct genetic or neural descendants. */
    LINEAL      = 0x01, 
    
    /** @description Asset transfer to the next qualified entity in the chain of command. */
    MERITOCRATIC = 0x02, 
    
    /** @description Assets return to the Shard or Fleet treasury for public welfare. */
    COMMUNAL     = 0x03, 
    
    /** @description Permanent removal of assets from the circulation (Deflationary). */
    VOID         = 0xFF  
}

/**
 * @interface ILegacyVault
 * @description 
 * The ultimate repository of an entity's post-termination instructions. 
 * Securely links material wealth with historical memory.
 */
export interface ILegacyVault {
    /** @description Unique Identifier of the deceased or decommissioned entity. */
    readonly ownerId: string;
    
    /** @description Immutable map of recipient IDs and their specific percentage (%) of assets. */
    readonly beneficiaries: Map<string, number>; 
    
    /** @description The protocol followed for the transfer (Lineal, Merit, etc.). */
    readonly successionModel: SUCCESSION_TYPE;
    
    /** @description Cryptographic link to the Logbook (log00) entry for the entity's history. */
    readonly memorialHash: string; 
    
    /** @description 
     * If TRUE, AI (ai00) executes the transfer upon verified termination. 
     * If FALSE, requires manual verification/voting from vote00.
     */
    readonly isAutomated: boolean; 
}

/**
 * @section LEGACY_CONFIG
 * @description Global constants for the maintenance of the Fleet's immortality.
 */
export const LEGACY_CONFIG = {
    /** @description 5% of all transferred assets are retained for Fleet fuel and maintenance. */
    SUCCESSION_TAX_RATE: 5, 
    
    /** @description Blocks to wait before a legacy transfer is finalized (Safety Buffer). */
    VERIFICATION_PERIOD_BLOCKS: 1000, 
    
    /** @description Maximum character limit for the digital epitaph in log00. */
    MEMORIAL_DATA_LIMIT_KB: 512,
    
    /** @description Level of proof required for termination verification. */
    TERMINATION_CONFIRMATION_QUORUM: 0.66 // 66% Shard agreement
} as const;

/**
 * @section IMMORTALITY_FLAGS
 * @description Control signals for the AI and Governance layers.
 */
export const LEGACY_FLAGS = {
    PROTECT_HISTORICAL_LOGS: true,  // History is never overwritten.
    AUTO_BURN_ORPHANED_ASSETS: false // Unclaimed assets go to Communal treasury.
} as const;

export const LEGACY_GENESIS_LOADED: boolean = true;
