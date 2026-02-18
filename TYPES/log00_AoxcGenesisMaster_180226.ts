/**
 * @file log00_AoxcGenesisMaster_180226.ts
 * @namespace AOXCDAO.Core.Logbook
 * @version 2.0.0 AOXCDAO V2 AKDENIZ
 * @status IMMUTABLE_LOG_ROOT
 * @compiler Solidity 0.8.33 Compatibility
 * @description Captain's Log & Historical Chronicle. Records the soul of the fleet.
 */


/**
 * @enum LOG_CATEGORY
 * @description Classification of the chronicle entry.
 */
export enum LOG_CATEGORY {
    ADMIRAL_DECREE = 0x01, // Sovereign orders and personal logs
    DISCOVERY      = 0x02, // New planets, dimensions, or species
    COMBAT_RECORD  = 0x03, // Historical battles and outcomes
    FLEET_MIGRATION = 0x04, // Movement between sectors
    BLACK_BOX      = 0xFF  // Emergency/Critical final recordings
}

/**
 * @interface ILogEntry
 * @description The structural DNA of a historical moment in the AOXC timeline.
 */
export interface ILogEntry {
    readonly logId: string;           // Unique chronicle ID
    readonly category: LOG_CATEGORY;
    readonly vesselId: number;        // Which ship is recording?
    readonly officerId: string;       // Who is writing? (Admiral or AI)
    readonly narrative: string;       // The actual story/entry
    readonly stardate: bigint;        // Relativistic time index
    readonly sectorHash: string;      // Location during the entry (from dim00)
    readonly isPublic: boolean;       // Is this for the citizens or the High Command?
}

export const LOGBOOK_CONFIG = {
    RETENTION_POLICY: 'ETERNAL',      // Logs are never deleted
    ENCRYPTION_LEVEL: 'S-GRADE',      // Sovereign Grade Encryption
    MAX_ENTRY_LENGTH: 4096            // Maximum character count for detail
} as const;

export const LOG_GENESIS_LOADED: boolean = true;
