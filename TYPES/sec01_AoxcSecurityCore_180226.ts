/**
 * @file sec01_AoxcSecurityCore_180226.ts
 * @version 1.0.0 AOXCDAO V2 AKDENIZ
 * @description Emergency Quarantine and System Recovery Protocols (Plan C).
 */

import { AOXC_GENESIS } from './sys00_AoxcGenesisMaster_180226.ts';

export enum SecurityLevel {
    STABLE,     // Normal Operations
    WARNED,     // Anomaly Detected
    LOCKED,     // Vessel Isolated
    TERMINATED  // Permanent Node Erasure
}

interface IVesselSecurityState {
    vesselId: string;
    integrityScore: number; // 0-100
    status: SecurityLevel;
}

export class AoxcSecurityCore {
    private static instance: AoxcSecurityCore;
    private vesselStates: Map<string, IVesselSecurityState>;

    private constructor() {
        this.vesselStates = new Map();
    }

    public static getInstance(): AoxcSecurityCore {
        if (!AoxcSecurityCore.instance) {
            AoxcSecurityCore.instance = new AoxcSecurityCore();
        }
        return AoxcSecurityCore.instance;
    }

    /**
     * @method triggerQuarantine
     * @description If a vessel is compromised, it is cut off from the Treasury and Governance.
     */
    public triggerQuarantine(vesselId: string): void {
        const state = this.vesselStates.get(vesselId);
        if (state) {
            state.status = SecurityLevel.LOCKED;
            state.integrityScore = 0;
            console.error(`[CRITICAL] VESSEL ${vesselId} QUARANTINED. ACCESS REVOKED.`);
        }
    }

    /**
     * @method validateAccess
     * @description Every transaction/vote checks the integrity of the vessel first.
     */
    public validateAccess(vesselId: string): boolean {
        const state = this.vesselStates.get(vesselId);
        if (!state || state.status === SecurityLevel.LOCKED) {
            return false; // Forbidden access
        }
        return true;
    }

    public reportStatus(): string {
        return `SECURITY_CORE: ACTIVE | EPOCH: ${AOXC_GENESIS.TIME.GENESIS_EPOCH}`;
    }
}

export const SECURITY_SEALED = true;
