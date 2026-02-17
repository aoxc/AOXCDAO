/**
 * @file isolation.types.ts
 * @namespace AOXCDAO.Core.Privacy
 * @version 2.0.0
 * @description Inter-Vessel Isolation & Contractual Aid - (Privacy-Locked)
 * Ensures zero-knowledge-style privacy between vessels unless a formal Aid Contract exists.
 */

import { FLEET_ID, VesselID } from "../core/fleet.ts";

/**
 * @enum AID_CONTRACT_STATUS
 * @description Status of the contractual bridge allowing data sharing between two vessels.
 */
export enum AID_CONTRACT_STATUS {
    INACTIVE        = 0x00, // Strict Isolation: No data sharing
    REQUESTED       = 0x01, // Handshake initiated: Pending Sovereign approval
    CONTRACT_SIGNED = 0x02, // Bridge Active: P2P forensic access granted
    REVOKED         = 0x03, // Emergency severance of the data bridge
}

/**
 * @constant ACCESS_PRIVILEGES
 * @description Logic-based access responses for the Privacy Engine.
 */
export const ACCESS_PRIVILEGES = {
    GRANTED_SOVEREIGN:    "ACCESS_GRANTED_SOVEREIGN",    // Full oversight (Andromeda)
    GRANTED_LOCAL:        "ACCESS_GRANTED_LOCAL",        // Self-access only
    GRANTED_BY_CONTRACT:  "ACCESS_GRANTED_BY_CONTRACT",  // Temporary P2P access
    DENIED_BREACH:        "ACCESS_DENIED_PRIVACY_BREACH", // Unauthorized attempt
    DENIED_EXPIRED:       "ACCESS_DENIED_BRIDGE_EXPIRED", // Bridge time-out
} as const;

// -----------------------------------------------------------------------------
// ACADEMIC TYPE DEFINITIONS (v2.0.0 UPDATED)
// -----------------------------------------------------------------------------

/**
 * @interface IAidBridge
 * @description The structure of a temporary data-sharing bridge between two vessels.
 */
export interface IAidBridge {
    readonly bridge_id: string; 
    readonly provider_vessel: VesselID; 
    readonly consumer_vessel: VesselID; 
    readonly status: AID_CONTRACT_STATUS;
    readonly expiration_block: number; 
    readonly scope: string[]; // Allowed forensic codes or data sectors
}

/**
 * @class PrivacyEngine
 * @description Enforces data isolation and validates cross-vessel data requests.
 */
export class PrivacyEngine {
    /**
     * @method checkAccessPermission
     * @description Verifies data visibility based on roles, contracts, and block timing.
     */
    public static checkAccessPermission(
        viewer: VesselID,
        target: VesselID,
        bridge: IAidBridge | null,
        currentBlock: number
    ): string {
        // CASE 1: ANDROMEDA PRIME (Sovereign Authority)
        if (viewer === FLEET_ID.ANDROMEDA) {
            return ACCESS_PRIVILEGES.GRANTED_SOVEREIGN;
        }

        // CASE 2: SELF-ACCESS (Internal Node View)
        if (viewer === target) {
            return ACCESS_PRIVILEGES.GRANTED_LOCAL;
        }

        // CASE 3: NO BRIDGE EXISTS
        if (!bridge) return ACCESS_PRIVILEGES.DENIED_BREACH;

        // CASE 4: BRIDGE EXPIRED (Temporal Check)
        if (currentBlock > bridge.expiration_block) {
            return ACCESS_PRIVILEGES.DENIED_EXPIRED;
        }

        // CASE 5: CONTRACTUAL AID (Active Peer-to-Peer)
        if (bridge.status === AID_CONTRACT_STATUS.CONTRACT_SIGNED) {
            return ACCESS_PRIVILEGES.GRANTED_BY_CONTRACT;
        }

        return ACCESS_PRIVILEGES.DENIED_BREACH;
    }

    /**
     * @method isScopeAuthorized
     * @description Ensures the requested data field is within the bridge's legal scope.
     */
    public static isScopeAuthorized(bridge: IAidBridge, requestedField: string): boolean {
        return bridge.scope.includes(requestedField) || bridge.scope.includes("*");
    }

    /**
     * @method generateBridgeID
     * @description Creates a unique cryptographic handle for a data bridge.
     */
    public static generateBridgeID(provider: VesselID, consumer: VesselID): string {
        return `BRIDGE_AID_${provider}_TO_${consumer}_${Date.now()}`;
    }
}

/**
 * @description Verification flag for privacy engine operational status.
 */
export const PRIVACY_ENGINE_LOADED: boolean = true;
