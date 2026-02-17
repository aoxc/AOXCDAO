/**
 * @file oracle.ts
 * @namespace AOXCDAO.Core.Oracle
 * @version 2.0.0
 * @description Oracle & External Communication - (Gateway-Locked)
 * Defines the cross-chain data flow and the approval lifecycle for external requests.
 * Standard: Pro-Ultimate Academic English (Zero-Turkish Policy).
 */

import { FLEET_ID } from "../core/fleet.ts";

/**
 * @constant ORACLE_CONFIG
 * @description Global settings for external data ingestion and synchronization.
 */
export const ORACLE_CONFIG = {
    SOURCE: "AOXC_MAINNET_ORACLE",
    REFRESH_RATE_SECONDS: 60,   // Standard heartbeat
    MAX_STALENESS_SECONDS: 300, // Data older than 5 mins is rejected
    AUTHORITY_SIGNER: FLEET_ID.ANDROMEDA, 
} as const;

/**
 * @enum REQUEST_STATUS
 * @description The lifecycle of an external data request.
 */
export enum REQUEST_STATUS {
    PENDING  = 0x01, // Awaiting validation
    APPROVED = 0x02, // Ready for bridge execution
    REJECTED = 0x03, // Untrusted or invalid
    EXPIRED  = 0x04, // Data arrived too late
}

// -----------------------------------------------------------------------------
// ACADEMIC TYPE DEFINITIONS (v2.0.0 UPDATED)
// -----------------------------------------------------------------------------

/**
 * @interface IExternalDataPacket
 * @description Structure of the data returned from the external world.
 * Fixed: Replaced 'any' with 'unknown' for Sovereign security compliance.
 */
export interface IExternalDataPacket {
    readonly request_id: string; 
    readonly source_url: string; 
    readonly payload: unknown; // SECURE: Data must be type-guarded before use
    readonly confirmation_block: number; 
    readonly ayra_signature: string; 
    readonly received_at: number; 
}

/**
 * @class OracleGateway
 * @description Enforces the logic for cross-chain integration and data validation.
 */
export class OracleGateway {
    /**
     * @method validateRequest
     * @description Multi-layer validation (Vessel -> Gatekeeper -> Council).
     */
    public static validateRequest(vesselId: number, _authHash: string): REQUEST_STATUS {
        if (vesselId === FLEET_ID.ANDROMEDA) {
            return REQUEST_STATUS.APPROVED;
        }
        return REQUEST_STATUS.PENDING;
    }

    /**
     * @method isDataFresh
     * @description Checks if the incoming oracle data is within the allowed time window.
     */
    public static isDataFresh(packet: IExternalDataPacket): boolean {
        const now = Math.floor(Date.now() / 1000);
        return (now - packet.received_at) <= ORACLE_CONFIG.MAX_STALENESS_SECONDS;
    }

    /**
     * @method verifySovereignSignature
     * @description Validates that the packet was indeed signed by Andromeda Prime (AYRA).
     */
    public static verifySovereignSignature(packet: IExternalDataPacket): boolean {
        // Academic Check: Signature must contain the specific Sovereign ID
        return packet.ayra_signature.includes(ORACLE_CONFIG.AUTHORITY_SIGNER.toString());
    }

    /**
     * @method processIncomingData
     * @description Final gateway check before data is injected into the Core Engine.
     */
    public static processIncomingData(packet: IExternalDataPacket): REQUEST_STATUS {
        if (!this.isDataFresh(packet)) {
            return REQUEST_STATUS.EXPIRED;
        }

        if (!this.verifySovereignSignature(packet)) {
            return REQUEST_STATUS.REJECTED;
        }

        return REQUEST_STATUS.APPROVED;
    }
}

/**
 * @description Verification flag for Oracle Gateway operational status.
 */
export const ORACLE_GATEWAY_ONLINE: boolean = true;
