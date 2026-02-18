/**
 * @file res00_AoxcGenesisMaster_180226.ts
 * @namespace AOXCDAO.Core.Resources
 * @version 2.0.0 AOXCDAO V2 AKDENIZ
 * @status IMMUTABLE_RESOURCE_ROOT
 * @description Resource Physics & Consumption Logic for 1B+ Population.
 */


export const RESOURCE_PHYSICS = {
    // Consumption rates per 1M people per Shard cycle
    BASE_OXYGEN_CONSUMPTION: 500, 
    BASE_FOOD_CONSUMPTION: 1200,
    BASE_ENERGY_DRAIN: 2500,

    // Transfer Limits
    MAX_DAILY_RESOURCE_TRANSFER: BigInt(1_000_000), 
    RESOURCE_TRANSFER_TAX_RATE: 2, // %2 Operational Fee

    // Resource Priority
    PRIORITY_LEVELS: {
        LIFE_SUPPORT: 0x01, // Oxygen & Vital Energy
        INFRASTRUCTURE: 0x02, // Repairs
        COMMERCE: 0x03 // Trade & Luxuries
    }
} as const;

export interface IResourcePacket {
    readonly resourceId: number;    // From sys00 (ENERGY, FOOD, etc.)
    readonly amount: bigint;
    readonly sourceShardId: number;
    readonly targetShardId: number;
    readonly timestamp: bigint;
}

export const RESOURCE_GENESIS_LOADED: boolean = true;
