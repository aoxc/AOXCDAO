/**
 * @file 00_sys_master.ts
 * @version 1.0.0
 * @package AOXCDAO.CORE
 * @date 2026-02-18
 * @status IMMUTABLE_SOVEREIGN_ROOT
 * @compiler_parity Solidity 0.8.33 (Logic-Level)
 * @description 
 * Centralized configuration manifest for the AOXC Fleet. 
 * Defines the foundational parameters for sharding 1B+ population, 
 * the 77-channel gateway architecture, and the Strait-severance protocols.
 * All values are constant and serve as the single source of truth for the DAO.
 */

/**
 * @constant AOXC_GENESIS
 * @description Global constants for the decentralized autonomous fleet.
 */
export const AOXC_GENESIS = {
    // I. THE FLEET (8 Sovereigns)
    // Each entity operates its own smart contract and isolation strait.
    FLEET: {
        0x00: 'ARMAGEDDON', // Core Logic, Global State & Dispatcher
        0x01: 'ANDROMEDA',  // Identity Sharding & Authentication
        0x02: 'AQUILA',     // Capital Reserve & Treasury Management
        0x03: 'CENTAURUS',  // Encrypted Inter-Vessel Communication Link
        0x04: 'PEGASUS',    // Distributed API & External Data Gateways
        0x05: 'QUASAR',     // Governance, Proposals & Voting Logic
        0x06: 'SOMBRERO',   // Security Infrastructure & Forensic Vaults
        0x07: 'VIRGO',      // Massive Sharded Data Storage Units
    },

    // II. THE 77-CHANNEL ARCHITECTURE (11 Gates per Sovereign Vessel)
    // 7 Operational Vessels x 11 Gates = 77 Strategic Channels.
    CHANNELS: {
        GATE_1_BRIDGE:     0x01, // Command Center Access
        GATE_2_TREASURY:   0x02, // Financial Interaction
        GATE_3_SECURITY:   0x03, // Threat Screening
        GATE_4_ENGINE:     0x04, // Propulsion & Core Logic
        GATE_5_LOGISTICS:  0x05, // Resource Distribution
        GATE_6_DIPLOMACY:  0x06, // External Entity Relations
        GATE_7_HABITAT:    0x07, // Population Environment
        GATE_8_INTEL:      0x08, // Information Gathering
        GATE_9_REPAIR:     0x09, // Autonomous Maintenance
        GATE_10_RESERVE:   0x0A, // Redundant Capsule Docking
        GATE_11_EMERGENCY: 0x0B  // Critical Evacuation Path
    },

    // III. STRAIT PROTOCOL STATES
    // Shared isolation status across CLI, API, and Smart Contracts.
    STRAIT_PROTOCOL: {
        STATUS_SECURE:   0xE1, // Path verified, traffic permitted.
        STATUS_WARNING:  0xE2, // Anomaly detected, monitoring active.
        STATUS_SEVERED:  0xE3, // Breach detected, Strait severed via Guillotine.
        STATUS_BYPASS:   0xE4  // Emergency recovery override active.
    },

    // IV. SCALE (1 Billion+ Population Architecture)
    // Sharding mathematics for massive horizontal scaling.
    SCALE: {
        TOTAL_POPULATION_TARGET: 1_000_000_000,
        TOTAL_SHARDS:            1024,
        PEOPLE_PER_SHARD:        976_562,
        NODES_PER_VESSEL:        128
    },

    // V. RANK MATRIX (Universal Authority & Permission Map)
    // Hierarchical access levels for 1 billion entities across 77 channels.
    RANK: {
        ADMIRAL:   0xFF, // Absolute Authority, Master Override
        CAPTAIN:   0x80, // Full Sovereign Vessel Authority
        OFFICER:   0x40, // Specialized Channel Authority
        PERSONNEL: 0x20, // Technical Operation Permission
        CITIZEN:   0x01, // Standard Resident Access
        VISITOR:   0x00  // Restricted Temporary Access
    },

    // VI. TIME ENGINE (Temporal Sovereignty Logic)
    // BigInt values for direct compatibility with Solidity uint256 seconds.
    TIME: {
        GENESIS_EPOCH:      1771286400n, // UTC: 2026-02-18 00:00:00
        SECOND:             1n,
        MINUTE:             60n,
        HOUR:               3600n,
        DAY:                86400n,
        WEEK:               604800n,
        MONTH:              2592000n,    // Standardized 30-day period
        YEAR:               31536000n,   // Standardized 365-day period
        VOTING_PERIOD:      259200n,     // Governance window (3 Days)
        EXECUTION_DELAY:    172800n,     // Security Timelock (2 Days)
        HEARTBEAT_INTERVAL: 300n         // Strait Integrity Check (5 Minutes)
    }
} as const;

/**
 * @type GlobalIdentityUID
 * @description 256-bit Immutable Identifier Mapping:
 * [Vessel:8bit][Channel:8bit][Shard:10bit][Rank:8bit][Unique:222bit]
 */
export type GlobalIdentityUID = bigint;

export const GENESIS_INITIALIZED: boolean = true;
