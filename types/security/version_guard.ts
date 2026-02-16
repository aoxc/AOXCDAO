/**
 * @file version_guard.ts
 * @namespace AOXCDAO.Security
 * @version 2.0.0
 * @description Version Integrity Enforcer - (Karujan-Standard)
 * Validates that all active modules align with the Zero-Point (2.0.0) mandate.
 */

import { GLOBAL_SYSTEM_VERSION } from "../core/lifecycle.ts";

/**
 * @enum VERSION_INTEGRITY_LEVEL
 * @description Severity of a version mismatch event.
 */
export enum VERSION_INTEGRITY_LEVEL {
    MATCHED = 0x00, // Integrity verified
    WARNING = 0x01, // Minor patch version drift (e.g., 2.0.1)
    BREACH  = 0x02, // Major/Minor version mismatch (Critical)
}

/**
 * @class VersionGuard
 * @description Academic engine to enforce version consistency across the AOXC ecosystem.
 */
export class VersionGuard {
    /**
     * @method validateModuleVersion
     * @description Compares a module's version against the global sovereign version.
     * @throws {Error} If a breach is detected in a critical core module.
     */
    public static validateModuleVersion(moduleName: string, moduleVersion: string): VERSION_INTEGRITY_LEVEL {
        // Strict Check: Zero-Point Mandate (2.0.0)
        if (moduleVersion === GLOBAL_SYSTEM_VERSION) {
            return VERSION_INTEGRITY_LEVEL.MATCHED;
        }

        // Analytical Check: Is it a patch or a total breach?
        const [gMajor, gMinor] = GLOBAL_SYSTEM_VERSION.split('.');
        const [mMajor, mMinor] = moduleVersion.split('.');

        if (gMajor === mMajor && gMinor === mMinor) {
            console.warn(`[VERSION_DRIFT] Module ${moduleName} is at ${moduleVersion}. Minimal drift detected.`);
            return VERSION_INTEGRITY_LEVEL.WARNING;
        }

        // Terminal Action: Version Breach
        this.logVersionBreach(moduleName, moduleVersion);
        
        throw new Error(
            `[VERSION_BREACH] Module ${moduleName} (${moduleVersion}) is incompatible with ${GLOBAL_SYSTEM_VERSION}. 
             Core Engine requires strict Zero-Point alignment.`
        );
    }

    /**
     * @method isSystemLegacy
     * @description Helper to identify if a version string belongs to the V1 era.
     */
    public static isSystemLegacy(version: string): boolean {
        return version.startsWith("1.");
    }

    /**
     * @method logVersionBreach
     * @description Formats the breach for the forensic log engine (Ref: forensic.ts)
     */
    private static logVersionBreach(name: string, version: string): void {
        const timestamp = new Date().toISOString();
        const seal = `0x_BREACH_${name.toUpperCase()}_${version.replace(/\./g, '_')}`;
        console.error(`[${timestamp}] CRITICAL_INTEGRITY_FAILURE::${seal}`);
    }
}

/**
 * @function validateModuleVersion
 * @description Legacy-compliant wrapper for the VersionGuard engine.
 */
export const validateModuleVersion = (moduleName: string, moduleVersion: string): void => {
    VersionGuard.validateModuleVersion(moduleName, moduleVersion);
};

export const INTEGRITY_GUARD_ACTIVE: boolean = true;
