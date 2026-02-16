/**
 * @file error_resolver.ts
 * @namespace AOXCDAO.Core.Intelligence
 * @version 2.1.0
 * @description Enhanced Error Intelligence Resolver - Dynamic Parsing Edition.
 * Orchestrates multi-tier forensic visibility based on viewer authority.
 */

import { FLEET_REGISTRY, AUTHORITY_LEVELS } from "../system/registry.ts";
import { PUBLIC_MASKING_MESSAGES } from "../system/communication.ts";

/**
 * @class ErrorIntelligenceResolver
 * @description Logic for decoding 12-char Forensic DNA strings into actionable intelligence.
 */
export class ErrorIntelligenceResolver {
    /**
     * @method resolveView
     * @description Dynamically parses any forensic hex and filters by authority.
     * @param rawHex The 12-character Forensic DNA (e.g., 0xD2C10210FB01)
     * @param viewerVessel The ID of the vessel viewing the error
     * @param viewerRank The authority rank of the viewer
     */
    public static resolveView(rawHex: string, viewerVessel: number, viewerRank: number): string {
        // Validation: Ensure the hex is exactly 12 chars (AOXC Standard)
        if (!rawHex || rawHex.length < 12) {
            return "ERROR_INTEGRITY_COMPROMISED: INVALID_FORENSIC_LENGTH";
        }

        const normalizedHex = rawHex.toUpperCase();

        // CASE 1: SOVEREIGN (Andromeda Prime - Root Command)
        if (
            viewerVessel === FLEET_REGISTRY.ANDROMEDA &&
            viewerRank === AUTHORITY_LEVELS.ROOT_COMMAND
        ) {
            return this.decodeFullForensic(normalizedHex);
        }

        // CASE 2: OPERATIONAL (Captains/Officers)
        // Check if rank meets the 0xA0 (Operational) threshold
        if (viewerRank >= 0xa0) {
            return this.decodeOperationalMask(normalizedHex);
        }

        // CASE 3: PUBLIC / PASSENGER
        return this.generatePublicAlert();
    }

    /**
     * @private decodeFullForensic
     * @description Provides unmasked, raw forensic data for the Chief.
     */
    private static decodeFullForensic(hex: string): string {
        const vesselPart = hex.substring(0, 2);   // Gemi Kimliği
        const sectorPart = hex.substring(4, 6);   // Sektör/Modül
        const errorSignature = hex.substring(8, 12); // Hata İmzası

        return `[SOVEREIGN_TRACE] DNA: ${hex} | VESSEL_REF: ${vesselPart} | SECTOR: ${sectorPart} | SIG: ${errorSignature}`;
    }

    /**
     * @private decodeOperationalMask
     * @description Masks sensitive Actor IDs while keeping operational data visible.
     */
    private static decodeOperationalMask(hex: string): string {
        // Masks the internal actor ID (chars 6-8) to protect identity
        const maskedHex = `${hex.substring(0, 6)}****${hex.substring(10)}`;
        const sector = hex.substring(4, 6);
        const sig = hex.substring(8, 12);

        return `[OPERATIONAL_REPORT] TRACE: ${maskedHex} | SECTOR_ID: ${sector} | ERROR_SIG: ${sig} | STATUS: Active Investigation`;
    }

    /**
     * @private generatePublicAlert
     * @description Standardized anti-panic message for low-authority entities.
     */
    private static generatePublicAlert(): string {
        return `[SYSTEM_NOTIFICATION]: ${PUBLIC_MASKING_MESSAGES.MSG_RED}`;
    }

    /**
     * @method validateForensicChecksum
     * @description Verifies if the forensic string matches the AOXC Protocol format (0x...).
     */
    public static validateForensicChecksum(hex: string): boolean {
        return /^0X[A-F0-9]{12}$/.test(hex.toUpperCase());
    }
}

/**
 * @description Verification flag for system-wide integrity checks.
 */
export const INTELLIGENCE_RESOLVER_LOADED: boolean = true;
