/**
 * @file fleet.ts
 * @namespace AOXCDAO.Core.Fleet
 * @version 2.0.0
 * @description Digital Footprint & Fleet Identification Codes - (Fleet-Locked)
 * Maps operational DAOs to their respective Smart Contract logic.
 */

/**
 * @constant FLEET_ID
 * @description Unique identification codes for each vessel in the AOXC ecosystem.
 */
export const FLEET_ID = {
    ANDROMEDA: 0x00, // Central Command (Mother-Core)
    VIRGO:     0x01, // Asset Fabricator & Resource Management
    AQUILA:    0x02, // Exchange, Swap & Liquidity Engine
    CENTAURUS: 0x03, // Bridge & Inter-Chain Communications
    PEGASUS:   0x04, // Oracle, Data Intelligence & External Feeds
    QUASAR:    0x05, // Security Sentinel Alpha (Active Defense)
    SOMBRERO:  0x06, // Security Sentinel Beta (Forensic Monitoring)
    VETERAN:   0x07, // Reputation & Soulbound Token (SBT) Layer
} as const;

/**
 * @constant CONTRACT_MAP
 * @description Mapping of Fleet IDs to their corresponding production Smart Contracts.
 */
export const CONTRACT_MAP = {
    [FLEET_ID.ANDROMEDA]: "ANDROMEDA_CORE.sol",
    [FLEET_ID.VIRGO]:     "VIRGO_FABRICATOR.sol",
    [FLEET_ID.AQUILA]:    "AQUILA_EXCHANGE.sol",
    [FLEET_ID.CENTAURUS]: "CENTAURUS_BRIDGE.sol",
    [FLEET_ID.PEGASUS]:   "PEGASUS_ORACLE.sol",
    [FLEET_ID.QUASAR]:    "QUASAR_SENTRY.sol",
    [FLEET_ID.SOMBRERO]:  "SOMBRERO_SENTINEL.sol",
    [FLEET_ID.VETERAN]:   "AOXCHonorSBT.sol",
} as const;

// -----------------------------------------------------------------------------
// ACADEMIC TYPE DEFINITIONS (v2.0.0 UPDATED)
// -----------------------------------------------------------------------------

export type VesselID = (typeof FLEET_ID)[keyof typeof FLEET_ID];

/**
 * @interface IFleetDeployment
 * @description Formal structure for tracking the deployment state of each vessel.
 */
export interface IFleetDeployment {
    readonly vessel_id: VesselID;
    readonly contract_name: string;
    readonly deployment_address: string; 
    readonly footprint_prefix: string; 
    readonly is_operational: boolean;
}

/**
 * @class FleetIntelligence
 * @description Active logic for fleet identification, footprinting, and vessel verification.
 */
export class FleetIntelligence {
    /**
     * @method generateFootprint
     * @description Generates the official Digital Footprint for any operation.
     */
    public static generateFootprint(vessel: VesselID, txHash: string): string {
        const prefix = `0x0${vessel.toString(16)}`;
        return `${prefix.toUpperCase()}:${txHash}`;
    }

    /**
     * @method getContractByVessel
     * @description Returns the source code filename for a specific vessel.
     */
    public static getContractByVessel(vessel: VesselID): string {
        return CONTRACT_MAP[vessel] || "UNKNOWN_LOGIC.sol";
    }

    /**
     * @method isSecurityVessel
     * @description Identifies if a vessel belongs to the Security/Sentinel class.
     */
    public static isSecurityVessel(vessel: VesselID): boolean {
        return vessel === FLEET_ID.QUASAR || vessel === FLEET_ID.SOMBRERO;
    }

    /**
     * @method validateFootprintFormat
     * @description Ensures a footprint follows the AOXC standard 0x0[ID]:[HASH].
     */
    public static validateFootprintFormat(footprint: string): boolean {
        const regex = /^0X0[0-7]:0X[A-F0-9]{64}$/i;
        return regex.test(footprint);
    }

    /**
     * @method getVesselByAddress
     * @description (Abstract) Would match an EVM address back to its Vessel ID from a deployment registry.
     */
    public static resolveVesselFromDeployment(deployments: IFleetDeployment[], address: string): VesselID | null {
        const match = deployments.find(d => d.deployment_address.toLowerCase() === address.toLowerCase());
        return match ? match.vessel_id : null;
    }
}

/**
 * @function generateFootprint
 * @description Legacy functional wrapper for footprint generation.
 */
export const generateFootprint = (vessel: VesselID, txHash: string): string => {
    return FleetIntelligence.generateFootprint(vessel, txHash);
};

export const FLEET_REGISTRY_LOADED: boolean = true;
