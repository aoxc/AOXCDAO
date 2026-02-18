/**
 * @file sys00_AoxcGenesisMaster_180226.ts
 * @version 2.1.0 AOXCDAO V2 AKDENIZ
 * @date 18.02.2026
 * @status IMMUTABLE_SOVEREIGN_ROOT
 * @compiler Solidity 0.8.33 Compatibility (Logic-Level)
 * @description Universal Constants and Temporal Sovereignty for 1B+ Population.
 */

export const AOXC_GENESIS = {
    // I. THE FLEET (8 Sovereigns)
    FLEET: {
        0x00: 'ARMAGEDDON', // core/
        0x01: 'ANDROMEDA',  // auth/
        0x02: 'AQUILA',     // bank/
        0x03: 'CENTAURUS',  // link/
        0x04: 'PEGASUS',    // api/
        0x05: 'QUASAR',     // vote/
        0x06: 'SOMBRERO',   // safe/
        0x07: 'VIRGO',      // data/
    },

    // II. THE 70-CHANNEL ARCHITECTURE (7 Gates per Vessel)
    CHANNELS: {
        GATE_1_BRIDGE:    0x01, 
        GATE_2_TREASURY:  0x02, 
        GATE_3_SECURITY:  0x03, 
        GATE_4_ENGINE:    0x04, 
        GATE_5_LOGISTICS: 0x05, 
        GATE_6_DIPLOMACY: 0x06, 
        GATE_7_HABITAT:   0x07  
    },

    // III. LIFE & MATERIAL CATEGORIES
    RESOURCES: {
        SUSTENANCE: {
            ENERGY: 0x11, 
            FOOD:   0x12, 
            OXYGEN: 0x13  
        },
        MATERIAL: {
            RAW_ORE:   0x21, 
            EQUIPMENT: 0x22, 
            LUXURY:    0x23  
        },
        DIGITAL: {
            CURRENCY: 0x31, 
            INTEL:    0x32, 
            REPUTATION: 0x33 
        }
    },

    // IV. UNIVERSE STATES
    UNIVERSE_STATE: {
        PEACE:     0xA1, 
        WAR:       0xA2, 
        DISCOVERY: 0xA3, 
        EMERGENCY: 0xA4, 
        REPAIR:    0xA5  
    },

    // V. AUTHORITY MATRIX
    RANK: {
        ADMIRAL:   0xFF, 
        CAPTAIN:   0x80, 
        OFFICER:   0x40, 
        PERSONNEL: 0x20, 
        CITIZEN:   0x01, 
        VISITOR:   0x00  
    },

    // VI. SCALABILITY CONSTANTS (The Billion-Body Guard)
    SCALE: {
        TOTAL_POPULATION_TARGET: 1_000_000_000,
        TOTAL_SHARDS: 1024,
        PEOPLE_PER_SHARD: 976_562, 
        NODES_PER_VESSEL: 128      
    },

    // VII. TEMPORAL SOVEREIGNTY (Sovereign Time Engine)
    // All values in BigInt to match Solidity uint256 seconds.
    TIME: {
        GENESIS_EPOCH: 1771286400n, // UTC: 2026-02-18 00:00:00
        SECOND: 1n,
        MINUTE: 60n,
        HOUR: 3600n,
        DAY: 86400n,
        WEEK: 604800n,
        MONTH: 2592000n,   // Standard 30-day window
        YEAR: 31536000n,   // Standard 365-day window
        VOTING_PERIOD: 259200n,    // 3 Days
        EXECUTION_DELAY: 172800n,  // 2 Days Timelock
        HEARTBEAT_INTERVAL: 300n   // 5 Minutes Sync
    }
} as const;

/**
 * @type GlobalIdentityUID
 * @description 256-bit Identifier Mapping:
 * [Vessel:8bit][Channel:8bit][Shard:10bit][Rank:8bit][Unique:222bit]
 */
export type GlobalIdentityUID = string;

export const GENESIS_INITIALIZED: boolean = true;
