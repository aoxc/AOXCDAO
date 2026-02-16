/**
 * @file real_world_interface.ts
 * @namespace AOXCDAO.Core.Oracle
 * @version 2.0.0
 * @description Real-World Interface & Off-Chain Data Constants - (Reality-Locked)
 * Defines the protocols for ingesting external data and interacting with physical reality.
 */

/**
 * @enum DATA_TRUST_LEVEL
 * @description Defines the confidence score of incoming off-chain data.
 */
export enum DATA_TRUST_LEVEL {
    SUPREME_ORACLE  = 0x01, // Verified decentralized data (Chainlink / Pyth)
    FIRMWARE_SENSOR = 0x02, // Direct hardware feedback from Vessel sensors
    MANUAL_ATTEST   = 0x03, // Human/Captain manual entry (Multi-sig required)
    UNTRUSTED_WEB   = 0x04, // External API (Requires 3-point validation)
}

/**
 * @enum REALITY_METRIC_TYPE
 * @description Categories of data being pulled from the physical world.
 */
export enum REALITY_METRIC_TYPE {
    GEOSPATIAL_COORDINATES = 0x501, // GPS/Lunar positioning data
    CHRONOLOGICAL_SYNC     = 0x502, // Atomic clock (UTC) synchronization
    ENVIRONMENTAL_DATA     = 0x503, // Atmospheric/Radiation levels
    EXTERNAL_MARKET_PRICE  = 0x504, // Off-chain asset valuation
}

/**
 * @constant ORACLE_SECURITY_PARAMS
 * @description Thresholds to prevent "Oracle Attacks" and data manipulation.
 */
export const ORACLE_SECURITY_PARAMS = {
    MAX_DATA_STALENESS:     300,  // 5 Minutes
    DEVIATION_THRESHOLD:    5.0,  // 5% Panic Threshold
    MIN_ORACLE_SOURCES:     3,    // Minimum independent sources
    REALITY_SYNC_HEARTBEAT: 60,   // Mandatory off-chain pulse
} as const;

// -----------------------------------------------------------------------------
// ACADEMIC TYPE DEFINITIONS (v2.0.0 UPDATED)
// -----------------------------------------------------------------------------

/**
 * @interface IRealWorldIngress
 * @description Structure for data arriving from outside the blockchain.
 */
export interface IRealWorldIngress {
    readonly request_id: string; 
    readonly metric_type: REALITY_METRIC_TYPE;
    readonly payload_hex: string; 
    readonly trust_score: DATA_TRUST_LEVEL;
    readonly source_signature: string; 
    readonly observation_time: number; 
    readonly ingestion_time: number; 
}

/**
 * @class RealityController
 * @description Operational logic for validating and synchronizing off-chain reality data.
 */
export class RealityController {
    /**
     * @method isStale
     * @description Checks if the data ingestion delay exceeds the safety threshold.
     */
    public static isStale(ingress: IRealWorldIngress, currentTime: number): boolean {
        return (currentTime - ingress.observation_time) > ORACLE_SECURITY_PARAMS.MAX_DATA_STALENESS;
    }

    /**
     * @method validateDeviation
     * @description Prevents flash-crashes or fake data spikes.
     * @param previousValue - The last verified value
     * @param newValue - The incoming new value
     */
    public static validateDeviation(previousValue: number, newValue: number): boolean {
        if (previousValue === 0) return true;
        const deviation = Math.abs((newValue - previousValue) / previousValue) * 100;
        return deviation <= ORACLE_SECURITY_PARAMS.DEVIATION_THRESHOLD;
    }

    /**
     * @method calculateTrustWeight
     * @description Assigns a mathematical weight based on the DATA_TRUST_LEVEL.
     */
    public static calculateTrustWeight(level: DATA_TRUST_LEVEL): number {
        switch (level) {
            case DATA_TRUST_LEVEL.SUPREME_ORACLE:  return 1.0;
            case DATA_TRUST_LEVEL.FIRMWARE_SENSOR: return 0.9;
            case DATA_TRUST_LEVEL.MANUAL_ATTEST:   return 0.5;
            default: return 0.1;
        }
    }

    /**
     * @method verifyRealitySync
     * @description Comprehensive check for data integrity and safety.
     */
    public static verifyRealitySync(ingress: IRealWorldIngress, currentTime: number): boolean {
        const notStale = !this.isStale(ingress, currentTime);
        const trustedSource = ingress.trust_score !== DATA_TRUST_LEVEL.UNTRUSTED_WEB;
        const validSignature = !!ingress.source_signature;

        return notStale && trustedSource && validSignature;
    }
}

/**
 * @function verifyRealitySync
 * @description Legacy functional wrapper for reality data validation.
 */
export const verifyRealitySync = (ingress: IRealWorldIngress, currentTime: number): boolean => {
    return RealityController.verifyRealitySync(ingress, currentTime);
};

export const ORACLE_INTERFACE_LOADED: boolean = true;
