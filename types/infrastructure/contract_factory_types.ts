/**
 * @file contract_factory_types.ts
 * @namespace AOXCDAO.Core.Synthesis
 * @version 2.4.0
 * @description Smart Contract Generation and Logic Standards - (Engine-Locked)
 */

/**
 * @enum SOLIDITY_VERSION
 * @description Supported compiler versions for AOXC-generated smart contracts.
 */
export enum SOLIDITY_VERSION {
    STABLE_LATEST = 0x81c, // v0.8.28 - Optimized for XLayer
    LEGACY_COMPAT = 0x814, // v0.8.20 - Base compatibility
}

/**
 * @enum CONTRACT_TEMPLATE_TYPE
 * @description Standardized templates for new sovereign legislation.
 */
export enum CONTRACT_TEMPLATE_TYPE {
    GOVERNANCE_AMENDMENT = 0x10a, // Governance updates
    FLEET_EXPANSION      = 0x10b, // New Vessel/Asset contracts
    TRADE_AGREEMENT      = 0x10c, // Atomic Swaps/Escrows
    JUDICIAL_VERDICT     = 0x10d, // Immutable legal records
}

/**
 * @constant SYNTHESIS_CONSTRAINTS
 * @description Technical limits for contract deployment on XLayer.
 */
export const SYNTHESIS_CONSTRAINTS = {
    MAX_CONTRACT_SIZE_KB:      24, 
    DEFAULT_OPTIMIZATION_RUNS: 999, 
    MIN_SIGNATURE_THRESHOLD:   3, 
    GAS_RESERVE_FOR_DEPLOY:    15_000_000, 
} as const;

/**
 * @enum LOGIC_GATE_STATUS
 * @description Operational states for programmable smart-logic triggers.
 */
export enum LOGIC_GATE_STATUS {
    PENDING_VALIDATION = 0x0, // Audit phase
    ACTIVE_DEPLOYED    = 0x1, // Live on XLayer
    DEPRECATED_VOID    = 0x2, // Expired or replaced
    EMERGENCY_PAUSED   = 0x3, // Halted via Risk Protocol
}

// -----------------------------------------------------------------------------
// ACADEMIC TYPE DEFINITIONS (v2.4.0 UPDATED)
// -----------------------------------------------------------------------------

/**
 * @interface IContractBlueprint
 * @description The structural DNA required to synthesize a new AOXC smart contract.
 */
export interface IContractBlueprint {
    readonly blueprint_id: string; 
    readonly template: CONTRACT_TEMPLATE_TYPE;
    readonly compiler: SOLIDITY_VERSION;
    readonly oz_version: "5.5.0"; 
    readonly target_address?: string; 
    readonly authorized_by: string[]; 
    readonly created_at: number;
    readonly is_upgradeable: boolean; 
    readonly bytecode_hash: string; // Added for integrity tracking
}

/**
 * @class ProtocolSynthesizer
 * @description Logic for validating, versioning, and authorizing new contract blueprints.
 */
export class ProtocolSynthesizer {
    /**
     * @method validateBlueprint
     * @description Ensures the blueprint meets size, signature, and optimization standards.
     */
    public static validateBlueprint(blueprint: IContractBlueprint, sizeKb: number): boolean {
        const isSizeValid = sizeKb <= SYNTHESIS_CONSTRAINTS.MAX_CONTRACT_SIZE_KB;
        const isAuthorized = blueprint.authorized_by.length >= SYNTHESIS_CONSTRAINTS.MIN_SIGNATURE_THRESHOLD;
        const hasHash = !!blueprint.bytecode_hash;

        return isSizeValid && isAuthorized && hasHash;
    }

    /**
     * @method getCompilerFlag
     * @description Returns the human-readable Solidity version for the compiler.
     */
    public static getCompilerFlag(version: SOLIDITY_VERSION): string {
        switch (version) {
            case SOLIDITY_VERSION.STABLE_LATEST: return "0.8.28";
            case SOLIDITY_VERSION.LEGACY_COMPAT: return "0.8.20";
            default: return "0.8.28";
        }
    }

    /**
     * @method requiresProxy
     * @description Checks if the template type requires a UUPS or Transparent Proxy.
     */
    public static requiresProxy(template: CONTRACT_TEMPLATE_TYPE): boolean {
        // Governance and Fleet expansions are always upgradeable by mandate
        return (
            template === CONTRACT_TEMPLATE_TYPE.GOVERNANCE_AMENDMENT || 
            template === CONTRACT_TEMPLATE_TYPE.FLEET_EXPANSION
        );
    }

    /**
     * @method calculateDeploymentRisk
     * @description Assesses risk based on bytecode size and upgradeability.
     */
    public static calculateDeploymentRisk(sizeKb: number, isUpgradeable: boolean): number {
        let riskScore = (sizeKb / SYNTHESIS_CONSTRAINTS.MAX_CONTRACT_SIZE_KB);
        if (isUpgradeable) riskScore += 0.2; // Higher complexity, higher risk
        return Math.min(riskScore, 1.0);
    }
}

/**
 * @function validateBlueprint
 * @description Legacy functional wrapper for synthesis validation.
 */
export const validateBlueprint = (size: number, sigCount: number): boolean => {
    return (
        size <= SYNTHESIS_CONSTRAINTS.MAX_CONTRACT_SIZE_KB &&
        sigCount >= SYNTHESIS_CONSTRAINTS.MIN_SIGNATURE_THRESHOLD
    );
};

export const CONTRACT_FACTORY_LOADED: boolean = true;
