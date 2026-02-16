/**
 * @file entity.types.ts
 * @namespace AOXCDAO.Core.Registry
 * @version 2.0.0
 * @description AOXC Official Vessel Registry & Entity Definitions.
 * Strictly maps to the astronomical vessel names found in the smart contracts.
 */

/**
 * @constant VESSEL_IDENTIFIERS
 * @description The only authorized vessels within the AOXC ecosystem.
 * Each vessel operates an isolated treasury and local logic.
 */
export const VESSEL_IDENTIFIERS = {
    ANDROMEDA: "ANDROMEDA_CORE", // The Hub (Master Vessel)
    VIRGO:     "VIRGO_FABRICATOR",
    AQUILA:    "AQUILA_EXCHANGE",
    CENTAURUS: "CENTAURUS_BRIDGE",
    PEGASUS:   "PEGASUS_ORACLE",
    QUASAR:    "QUASAR_SENTRY",
    SOMBRERO:  "SOMBRERO_SENTINEL",
} as const;

/**
 * @enum ENTITY_CLASS
 * @description Defines the authority level of an entity within a vessel's jurisdiction.
 */
export enum ENTITY_CLASS {
    VesselAdmin  = 0x01, // Full control over vessel-local treasury
    FleetOfficer = 0x02, // Operational authority across multiple vessels
    SystemAgent  = 0x03, // Automated service or bot entity
    Sentinel     = 0x04, // Security and monitoring node
}

/**
 * @type VesselName
 * @description Type-safe union of all authorized vessel names.
 */
export type VesselName = keyof typeof VESSEL_IDENTIFIERS;

/**
 * @interface IVesselManifest
 * @description Formal specification of a vessel's on-chain presence.
 */
export interface IVesselManifest {
    readonly name: VesselName;
    readonly registry_id: string; 
    readonly treasury_address: string; 
    readonly logic_address: string; 
    readonly isActive: boolean;
}

/**
 * @class RegistryAuthority
 * @description Operational logic for managing vessel registration and entity hierarchy.
 */
export class RegistryAuthority {
    /**
     * @method isMasterHub
     * @description Verifies if the vessel is the central command (Andromeda).
     */
    public static isMasterHub(name: VesselName): boolean {
        return name === "ANDROMEDA";
    }

    /**
     * @method getAccessRank
     * @description Assigns a numeric priority weight to each Entity Class.
     */
    public static getAccessRank(entityClass: ENTITY_CLASS): number {
        switch (entityClass) {
            case ENTITY_CLASS.VesselAdmin:  return 100;
            case ENTITY_CLASS.FleetOfficer: return 80;
            case ENTITY_CLASS.Sentinel:     return 50;
            case ENTITY_CLASS.SystemAgent:   return 30;
            default: return 0;
        }
    }

    /**
     * @method validateManifest
     * @description Ensures a vessel's manifest contains valid on-chain addresses.
     */
    public static validateManifest(manifest: IVesselManifest): boolean {
        const addressRegex = /^0x[a-fA-F0-9]{40}$/;
        return (
            addressRegex.test(manifest.treasury_address) &&
            addressRegex.test(manifest.logic_address) &&
            manifest.isActive
        );
    }

    /**
     * @method getVesselByDesignation
     * @description Returns the key from a designation string (e.g., "VIRGO_FABRICATOR" -> "VIRGO").
     */
    public static getVesselByDesignation(designation: string): VesselName | undefined {
        return (Object.keys(VESSEL_IDENTIFIERS) as VesselName[]).find(
            (key) => VESSEL_IDENTIFIERS[key] === designation
        );
    }
}

/**
 * @description Verification flag for system-wide integrity checks.
 */
export const ENTITY_REGISTRY_LOADED: boolean = true;
