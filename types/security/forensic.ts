/**
 * @file footprint.ts
 * @namespace AOXCDAO.Core.Forensic
 * @version 2.0.0
 * @description Forensic Data Assembly Engine - (DNA-Locked)
 * Defines the formal structure for merging multi-layer hex codes into a single Forensic Trace.
 */

/**
 * @constant FORENSIC_STRUCTURE
 * @description Defines the bit/char positions for the 12-character Forensic DNA.
 * Packet Format: [V][A][L][E][S]
 */
export const FORENSIC_STRUCTURE = {
    VESSEL_POS:    { start: 0, end: 2 },  // [V] - Vessel ID
    AUTHORITY_POS: { start: 2, end: 4 },  // [A] - Authority Rank
    LOCATION_POS:  { start: 4, end: 6 },  // [L] - Location Section
    ENTITY_POS:    { start: 6, end: 8 },  // [E] - Entity Type
    SIGNATURE_POS: { start: 8, end: 12 }, // [S] - Error Signature
} as const;

/**
 * @class ForensicAssembler
 * @description Academic engine to assemble individual operational codes into a unified trace.
 */
export class ForensicAssembler {
    private static readonly PACKET_INIT = "0x";

    /**
     * @method assemble
     * @description Merges segments into a formal 12-character forensic packet.
     */
    public static assemble(
        vessel: string,
        auth: string,
        loc: string,
        entity: string,
        sig: string,
    ): string {
        // Normalize segments to required lengths (2 chars for V,A,L,E; 4 for S)
        const packet = [
            vessel.padStart(2, "0"),
            auth.padStart(2, "0"),
            loc.padStart(2, "0"),
            entity.padStart(2, "0"),
            sig.padStart(4, "0"),
        ]
            .join("")
            .toUpperCase();

        return `${this.PACKET_INIT}${packet}`;
    }

    /**
     * @method decompose
     * @description Breaks down a 12-char DNA string into its constitutional segments.
     */
    public static decompose(trace: string): IForensicPacket['components'] | null {
        const clean = trace.startsWith("0x") ? trace.slice(2) : trace;
        if (!this.validateDNA(clean)) return null;

        return {
            vessel_id:       clean.substring(FORENSIC_STRUCTURE.VESSEL_POS.start, FORENSIC_STRUCTURE.VESSEL_POS.end),
            authority_rank:  clean.substring(FORENSIC_STRUCTURE.AUTHORITY_POS.start, FORENSIC_STRUCTURE.AUTHORITY_POS.end),
            location_sector: clean.substring(FORENSIC_STRUCTURE.LOCATION_POS.start, FORENSIC_STRUCTURE.LOCATION_POS.end),
            entity_type:     clean.substring(FORENSIC_STRUCTURE.ENTITY_POS.start, FORENSIC_STRUCTURE.ENTITY_POS.end),
            signature:       clean.substring(FORENSIC_STRUCTURE.SIGNATURE_POS.start, FORENSIC_STRUCTURE.SIGNATURE_POS.end),
        };
    }

    /**
     * @method validateDNA
     * @description Checks if a forensic trace conforms to the AOXC v2.0.0 standard.
     */
    public static validateDNA(trace: string): boolean {
        const cleanTrace = trace.startsWith("0x") ? trace.slice(2) : trace;
        // Strict length check + Hexadecimal character check
        return /^[0-9A-F]{12}$/i.test(cleanTrace);
    }

    /**
     * @method wrap
     * @description High-level wrapper to create a full IForensicPacket object.
     */
    public static wrap(rawTrace: string): IForensicPacket {
        const components = this.decompose(rawTrace);
        if (!components) throw new Error("CRITICAL_FORENSIC_CORRUPTION");

        return {
            raw_trace: rawTrace.startsWith("0x") ? rawTrace : `0x${rawTrace}`,
            components,
            assembly_timestamp: Date.now()
        };
    }
}

// -----------------------------------------------------------------------------
// ACADEMIC TYPE DEFINITIONS (v2.0.0 UPDATED)
// -----------------------------------------------------------------------------

/**
 * @interface IForensicPacket
 * @description The finalized object representing a complete forensic event.
 */
export interface IForensicPacket {
    readonly raw_trace: string; 
    readonly components: {
        vessel_id: string;
        authority_rank: string;
        location_sector: string;
        entity_type: string;
        signature: string;
    };
    readonly assembly_timestamp: number;
}

/**
 * @description Verification flag for system-wide integrity checks.
 */
export const FORENSIC_ENGINE_LOADED: boolean = true;
