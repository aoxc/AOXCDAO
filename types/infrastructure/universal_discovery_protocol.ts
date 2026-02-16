/**
 * @file universal_discovery_protocol.ts
 * @namespace AOXCDAO.Core.Discovery
 * @version 1.0.0
 * @description First Contact & Interstellar Diplomacy Protocol - (Galactic-Locked)
 * Standardized interface for identifying and communicating with external civilizations.
 */

import { DEFENSE_LAYER } from "../security/security_protocols.ts";

/**
 * @enum CIVILIZATION_TYPE
 * @description Classification based on energy usage and technological advancement (Kardashev Scale).
 */
export enum CIVILIZATION_TYPE {
    TYPE_0_SUB_PLANETARY = 0xd0, // Pre-spaceflight (Monitor only)
    TYPE_I_PLANETARY     = 0xd1, // Harnesses all home planet energy
    TYPE_II_STELLAR      = 0xd2, // Harnesses star energy (Dyson Spheres)
    TYPE_III_GALACTIC    = 0xd3, // Harnesses entire galaxy energy
    TYPE_IV_UNIVERSAL    = 0xd4, // Harnesses multi-galactic energy
}

/**
 * @enum DIPLOMATIC_STANCE
 * @description Automated stance taken by the Karujan Fleet upon first contact.
 */
export enum DIPLOMATIC_STANCE {
    NEUTRAL_OBSERVANCE = 0x01, // Passive data gathering
    OPEN_TRADE         = 0x02, // Initiating commerce
    DEFENSIVE_BUFFER   = 0x03, // Escalating to Plan B
    ALLIANCE_FORMED    = 0x04, // Merging governance nodes
    TOTAL_ISOLATION    = 0x05, // Stealth mode active
}

/**
 * @constant GALACTIC_COMM_PARAMS
 * @description Technical standards for the Universal Language (The Math-Based Language).
 */
export const GALACTIC_COMM_PARAMS = {
    BASE_ENCODING:       "PRIME_NUMBERS",
    BROADCAST_BEACON_HZ: 1420.4,   // The Hydrogen Line
    RESPONSE_WAIT_TIME:  31536000, // 1 Solar Year
    AUTOMATED_GREETING:  "01001011-01000001-01010010-01010101-01001010-01000001-01001110", // KARUJAN
} as const;

// -----------------------------------------------------------------------------
// ACADEMIC TYPE DEFINITIONS (v1.0.0 UPDATED)
// -----------------------------------------------------------------------------

/**
 * @interface IDiscoveryEvent
 * @description The formal record of an encounter with a new entity or planet.
 */
export interface IDiscoveryEvent {
    readonly discovery_id: string;
    readonly galaxy_coordinates: [number, number, number]; // X, Y, Z
    readonly civ_level: CIVILIZATION_TYPE;
    readonly current_stance: DIPLOMATIC_STANCE;
    readonly biological_signature: boolean; // Organic or Synthetic
    readonly recorded_at: number;
    readonly verified_by_ai: boolean; 
}

/**
 * @class DiscoveryEngine
 * @description Logic for threat assessment, civilization mapping, and diplomatic escalation.
 */
export class DiscoveryEngine {
    /**
     * @method assessDiplomaticRisk
     * @description Determines if a civilization poses a threat to the Karujan Fleet.
     */
    public static assessDiplomaticRisk(civ: CIVILIZATION_TYPE): DEFENSE_LAYER {
        // High-level civilizations (Type II+) automatically trigger Plan B (Isolation) 
        // until intentions are verified.
        if (civ >= CIVILIZATION_TYPE.TYPE_II_STELLAR) {
            return DEFENSE_LAYER.PLAN_B_ISOLATION;
        }
        return DEFENSE_LAYER.PLAN_A_STABILITY;
    }

    /**
     * @method generatePrimeSequence
     * @description Generates a mathematical handshake to prove intelligence.
     */
    public static generateHandshake(length: number): number[] {
        const primes: number[] = [];
        let num = 2;
        while (primes.length < length) {
            let isPrime = true;
            for (let i = 2; i <= Math.sqrt(num); i++) {
                if (num % i === 0) { isPrime = false; break; }
            }
            if (isPrime) primes.push(num);
            num++;
        }
        return primes;
    }

    /**
     * @method validateCoordinates
     * @description Ensures the discovery is within known sector boundaries.
     */
    public static validateCoordinates(coords: [number, number, number]): boolean {
        return coords.every(c => Math.abs(c) < 1000000); // 1 Million Light-Year Radius
    }

    /**
     * @method initiateContact
     * @description Formats the universal greeting for broadcast.
     */
    public static initiateContact(stance: DIPLOMATIC_STANCE): string {
        const handshake = this.generateHandshake(5).join("-");
        return `[GALACTIC_BEACON]::MODE_${DIPLOMATIC_STANCE[stance]}::SIG_${handshake}`;
    }
}

/**
 * @function initiateContact
 * @description Legacy wrapper for direct contact commands.
 */
export const initiateContact = (stance: DIPLOMATIC_STANCE): string => {
    return DiscoveryEngine.initiateContact(stance);
};

export const DISCOVERY_PROTOCOL_READY: boolean = true;
