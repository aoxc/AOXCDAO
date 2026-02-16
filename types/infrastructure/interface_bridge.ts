/**
 * @file interface_bridge.ts
 * @namespace AOXCDAO.Bridge
 * @version 1.0.0
 * @description The Universal Translator - (CLI-AI-CONTRACT-BRIDGE)
 * Connects the Karujan's CLI commands to the Smart Contracts and AI Core.
 */

import { KARUJAN_DIRECTIVES } from "../core/karujan_authority.ts";
import { AI_SYNC_STATE } from "../system/ai_neural_sync.ts";

/**
 * @enum COMMAND_SOURCE
 * @description Defines where the signal is coming from.
 */
export enum COMMAND_SOURCE {
    KARUJAN_CLI = 0x11, // Your terminal (orcun@ns1)
    AURA_AI     = 0x22, // AI neural suggestions
    ON_CHAIN    = 0x33, // Smart contract events
}

/**
 * @interface IUnifiedSignal
 * @description The common packet that moves through the whole AOXC system.
 */
export interface IUnifiedSignal {
    readonly source: COMMAND_SOURCE;
    readonly directive: KARUJAN_DIRECTIVES;
    readonly payload: string; // Hex-encoded action data
    readonly status: AI_SYNC_STATE;
    readonly timestamp: number;
    readonly signature: string; // Validated on XLayer
}

/**
 * @constant MISSION_STATUS
 * @description Real-time progress towards the Moon (Lunar Landing).
 */
export const MISSION_STATUS = {
    ORBITAL_STABILITY: 0.99,
    FUEL_EFFICIENCY:   1.0,
    LUNAR_PROXIMITY:   0.0, // Progress counter for contract deployment
    READY_FOR_LAUNCH:  true,
} as const;

/**
 * @class BridgeProcessor
 * @description Active engine for translating and routing signals between human, AI, and chain.
 */
export class BridgeProcessor {
    /**
     * @method createSignal
     * @description Encapsulates a command into a unified signal packet.
     */
    public static createSignal(
        source: COMMAND_SOURCE,
        directive: KARUJAN_DIRECTIVES,
        data: string,
        sig: string
    ): IUnifiedSignal {
        return {
            source,
            directive,
            payload: data.startsWith("0x") ? data : `0x${data}`,
            status: AI_SYNC_STATE.SYNCHRONIZED,
            timestamp: Date.now(),
            signature: sig
        };
    }

    /**
     * @method validateMissionCritical
     * @description Ensures no command executes if orbital stability is compromised.
     */
    public static isLaunchReady(): boolean {
        return (
            MISSION_STATUS.ORBITAL_STABILITY > 0.95 && 
            MISSION_STATUS.READY_FOR_LAUNCH
        );
    }

    /**
     * @method calculateLunarProgress
     * @description Updates mission progress based on deployed contract clusters.
     */
    public static getLunarProximity(deployedCount: number, totalNeeded: number): number {
        const progress = (deployedCount / totalNeeded) * 100;
        return Math.min(progress, 100);
    }

    /**
     * @method getSourceTag
     * @description Returns a human-readable tag for the CLI logs.
     */
    public static getSourceTag(source: COMMAND_SOURCE): string {
        switch (source) {
            case COMMAND_SOURCE.KARUJAN_CLI: return "[COMMANDER]";
            case COMMAND_SOURCE.AURA_AI:     return "[NEURAL_LINK]";
            case COMMAND_SOURCE.ON_CHAIN:    return "[BLOCKCHAIN]";
            default: return "[UNKNOWN]";
        }
    }
}

/**
 * @description Verification flag for bridge operational status.
 */
export const BRIDGE_ONLINE: boolean = true;
