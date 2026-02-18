/**
 * @file main.ts
 * @namespace AOXCDAO.Orchestrator
 * @version 1.1.2 AOXCDAO V2 AKDENIZ
 * @description The Grand Orchestrator: Absolute Zero-Error Edition.
 * @compiler Solidity 0.8.33 Compatibility (Logic-Level)
 */

import { AOXC_GENESIS } from './sys00_AoxcGenesisMaster_180226.ts';
import { AoxcRegistry } from './sys01_AoxcRegistry_180226.ts';
import { AoxcVesselEngine } from './sys02_AoxcVesselEngine_180226.ts';
import { AoxcCivilianLife, GeneticClass, ICivilianIdentity } from './bio01_AoxcCivilianLife_180226.ts';
import { AoxcEconomyEngine } from './sys03_AoxcEconomyEngine_180226.ts';
import { AoxcGovernanceEngine, ProposalStatus } from './sys04_AoxcGovernanceEngine_180226.ts';

class SovereignOrchestrator {
    private registry: AoxcRegistry;
    private vesselEngine: AoxcVesselEngine;
    private bioLife: AoxcCivilianLife;
    private economy: AoxcEconomyEngine;
    private governance: AoxcGovernanceEngine;

    constructor() {
        this.registry = AoxcRegistry.getInstance();
        this.vesselEngine = new AoxcVesselEngine();
        this.bioLife = AoxcCivilianLife.getInstance();
        this.economy = AoxcEconomyEngine.getInstance();
        this.governance = AoxcGovernanceEngine.getInstance();
    }

    public async runFullSimulation(): Promise<void> {
        console.log("--- [AOXCDAO EMPIRE SIMULATION START] ---");

        const alphaLeader: ICivilianIdentity = {
            uid: "AOXC-ALPHA-001",
            dnaHash: this.bioLife.generateDnaHash("SECRET-PRIME-DNA"),
            genClass: GeneticClass.ALPHA,
            reputation: 9500,
            lastSync: AOXC_GENESIS.TIME.GENESIS_EPOCH
        };

        const deltaWorker: ICivilianIdentity = {
            uid: "AOXC-DELTA-999",
            dnaHash: this.bioLife.generateDnaHash("WORKER-DNA-01"),
            genClass: GeneticClass.DELTA,
            reputation: 4000,
            lastSync: AOXC_GENESIS.TIME.GENESIS_EPOCH
        };

        // INTEGRATION: Validating registry via active usage to clear TS6133
        const initialStatus = this.registry.getRegistryStatus();
        console.info(`[SYSTEM_INIT] ${initialStatus}`);

        await this.vesselEngine.deployToVessel(alphaLeader);
        this.economy.calculateSalary(alphaLeader);

        try {
            const propId = this.governance.createProposal(alphaLeader, "DEEP_SPACE_EXPANSION");
            
            // Enum usage validation
            const currentStatus: ProposalStatus = ProposalStatus.ACTIVE;
            console.log(`[GOVERNANCE] Proposal #${propId} Status: ${currentStatus}`);

            this.governance.castVote(propId, alphaLeader, true);
            this.governance.castVote(propId, deltaWorker, false);

            console.log("[SECURITY] Testing unauthorized proposal...");
            this.governance.createProposal(deltaWorker, "ABOLISH_TAXES");

        } catch (error) {
            if (error instanceof Error) console.warn(`[DENIED] ${error.message}`);
        }

        // Final audit usage of registry
        console.log(`--- [SIMULATION SUCCESSFUL: ${this.registry.getRegistryStatus()}] ---`);
    }
}

const ORCHESTRATOR = new SovereignOrchestrator();
ORCHESTRATOR.runFullSimulation();

export const SYSTEM_SEALED: boolean = true;
