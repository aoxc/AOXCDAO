/**
 * @file registry.types.ts
 * @namespace AOXCDAO.Core.Registry
 * @version 2.0.0
 * @description Fleet Identity & Core Authority Registry - (Registry-Locked)
 * Defines the unique identifiers for the 7-ship fleet and their power hierarchy.
 */

/**
 * @constant FLEET_REGISTRY
 * @description The immutable identification codes for all vessels in the AOXC ecosystem.
 */
export const FLEET_REGISTRY = {
    // THE SUPREME CORE
    ANDROMEDA: 0x00, // Central Hub Authority (Master Control)

    // THE 7-SHIP FLEET
    VIRGO:     0x01, // Asset Fabrication & Minting Control
    AQUILA:    0x02, // Liquidity, Swap & Exchange Engine
    CENTAURUS: 0x03, // Inter-Chain Bridging & Relay
    PEGASUS:   0x04, // Information, Oracles & Data Feeds
    QUASAR:    0x05, // Security Sentinel Alpha (Active Defense)
    SOMBRERO:  0x06, // Security Sentinel Beta (Forensic Monitoring)
    VETERAN:   0x07, // Reputation, HonorSBT & Merit Layer
} as const;

/**
 * @constant AUTHORITY_LEVELS
 * @description Cryptographic power levels for command and control sequences.
 */
export const AUTHORITY_LEVELS = {
    ROOT_COMMAND: 0xff, // Full Fleet Command (Universal Arbiter)
    SHIP_COMMAND: 0xaa, // Single Ship Command (Vessel Captain)
    DECK_ACCESS:  0x55, // Operational/Technical Access (Crew)
    GUEST_VIEW:   0x11, // Restricted Observer (ReadOnly)
} as const;

// -----------------------------------------------------------------------------
// ACADEMIC TYPE DEFINITIONS (v2.0.0 UPDATED)
// -----------------------------------------------------------------------------

export type VesselID = (typeof FLEET_REGISTRY)[keyof typeof FLEET_REGISTRY];
export type AuthorityLvl = (typeof AUTHORITY_LEVELS)[keyof typeof AUTHORITY_LEVELS];

/**
 * @interface IVesselIdentity
 * @description Comprehensive identity structure for on-chain vessel registration.
 */
export interface IVesselIdentity {
    readonly ship_id: VesselID;
    readonly name: keyof typeof FLEET_REGISTRY;
    readonly commander_lvl: AuthorityLvl;
    readonly registry_hash: string; 
    readonly is_active: boolean;
    readonly commission_block: number; // Deployment timestamp (block height)
}

/**
 * @class RegistryEngine
 * @description Logic for vessel validation, authority mapping, and identity integrity.
 */
export class RegistryEngine {
    /**
     * @method isValidVessel
     * @description Verifies if a given ID exists within the fleet registry.
     */
    public static isValidVessel(id: number): boolean {
        return Object.values(FLEET_REGISTRY).includes(id as VesselID);
    }

    /**
     * @method hasRootAuthority
     * @description Checks if the clearance level matches the Sovereign Root (0xFF).
     */
    public static hasRootAuthority(level: number): boolean {
        return level === AUTHORITY_LEVELS.ROOT_COMMAND;
    }

    /**
     * @method getShipName
     * @description Translates a Hex ID back into its academic designation name.
     */
    public static getShipName(id: VesselID): string {
        const entry = Object.entries(FLEET_REGISTRY).find(([_, value]) => value === id);
        return entry ? entry[0] : "UNKNOWN_GHOST_VESSEL";
    }

    /**
     * @method verifyIdentityHash
     * @description Validates the registry hash against the vessel's primary attributes.
     * Simulated keccak256 check.
     */
    public static verifyIdentityHash(vessel: IVesselIdentity, expectedHash: string): boolean {
        return vessel.registry_hash === expectedHash;
    }

    /**
     * @method isSecurityVessel
     * @description Flags if the vessel belongs to the Security Sentinel pair (Quasar/Sombrero).
     */
    public static isSecurityVessel(id: VesselID): boolean {
        return id === FLEET_REGISTRY.QUASAR || id === FLEET_REGISTRY.SOMBRERO;
    }
}

/**
 * @description Global verification flag for Registry system integrity.
 */
export const FLEET_REGISTRY_LOADED: boolean = true;
