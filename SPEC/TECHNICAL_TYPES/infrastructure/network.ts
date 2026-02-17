/**
 * @file network.ts
 * @namespace AOXCDAO.Core.Connectivity
 * @version 2.0.0
 * @description Network & Communication Protocols - (Connectivity-Locked)
 * Defines the galactic interfaces, hardware ports, and signal state machine.
 */

/**
 * @enum NETWORK_PROTOCOLS
 * @description Communication layers for different types of inter-vessel data exchange.
 */
export enum NETWORK_PROTOCOLS {
    XLAYER      = 0x71, // Primary Blockchain Interface (XLayer On-Chain)
    FLEET_SYNC  = 0x72, // Intra-fleet Synchronous Protocol (Off-Chain P2P)
    NEURAL_LINK = 0x73, // AI-to-System Neural Interface (AURA Integration)
}

/**
 * @constant INTERFACE_PORTS
 * @description Standardized logical ports for specific command and defense services.
 */
export const INTERFACE_PORTS = {
    COMMAND_CORE: 8080, // Primary Central Control Port
    FLEET_RELAY:  8081, // Inter-vessel data transmission relay
    SENTINEL_SEC: 8443, // Encrypted Sentinel Defense & Forensics Port
} as const;

/**
 * @enum SIGNAL_STATES
 * @description Monitoring indicators for communication integrity and latency.
 */
export enum SIGNAL_STATES {
    STABLE    = 0x01, // 0ms - 50ms: High-fidelity connection
    LATENCY   = 0x02, // 50ms - 500ms: Delay detected, buffering active
    DISRUPTED = 0x03, // > 500ms or Lost: Connection jammed or offline
}

// -----------------------------------------------------------------------------
// ACADEMIC TYPE DEFINITIONS (v2.0.0 UPDATED)
// -----------------------------------------------------------------------------

/**
 * @interface INetworkPacket
 * @description The formal structure for data packets sent over the Neural Link or Fleet Sync.
 */
export interface INetworkPacket {
    readonly packet_id: string; 
    readonly protocol: NETWORK_PROTOCOLS;
    readonly port: number; 
    readonly payload: string; 
    readonly status: SIGNAL_STATES;
    readonly latency_ms: number; 
    readonly checksum: string; 
}

/**
 * @class ConnectivityEngine
 * @description Logic for signal diagnostics, packet routing, and port validation.
 */
export class ConnectivityEngine {
    /**
     * @method diagnoseSignal
     * @description Automatically determines the SIGNAL_STATES based on measured latency.
     */
    public static diagnoseSignal(latency: number): SIGNAL_STATES {
        if (latency < 50)  return SIGNAL_STATES.STABLE;
        if (latency < 500) return SIGNAL_STATES.LATENCY;
        return SIGNAL_STATES.DISRUPTED;
    }

    /**
     * @method isSecurityPort
     * @description Validates if a transmission is occurring over the protected Sentinel port.
     */
    public static isSecurityPort(port: number): boolean {
        return port === INTERFACE_PORTS.SENTINEL_SEC;
    }

    /**
     * @method validatePacketIntegrity
     * @description Checks if the packet's checksum matches the computed payload hash.
     * (Simulated SHA-256 validation for academic standard).
     */
    public static validatePacketIntegrity(packet: INetworkPacket, computedHash: string): boolean {
        return packet.checksum === computedHash;
    }

    /**
     * @method getProtocolName
     * @description Returns the human-readable identifier for a network protocol.
     */
    public static getProtocolName(protocol: NETWORK_PROTOCOLS): string {
        return NETWORK_PROTOCOLS[protocol] || "UNKNOWN_LAYER";
    }

    /**
     * @method createHeader
     * @description Generates a network header for packet encapsulation.
     */
    public static generateTrace(packet: INetworkPacket): string {
        return `[NET_PKT]::${packet.packet_id}::PORT_${packet.port}::LATENCY_${packet.latency_ms}ms`;
    }
}

/**
 * @function isSecurityPort
 * @description Legacy wrapper for direct port checks.
 */
export const isSecurityPort = (port: number): boolean => ConnectivityEngine.isSecurityPort(port);

export const NETWORK_CORE_ONLINE: boolean = true;
