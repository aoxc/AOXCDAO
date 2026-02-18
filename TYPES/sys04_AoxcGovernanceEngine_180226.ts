/**
 * @file sys04_AoxcGovernanceEngine_180226.ts
 * @namespace AOXCDAO.Core.Governance
 * @version 1.0.0 AOXCDAO V2 AKDENIZ
 * @description Meritocratic Voting and Proposal System for 1B Citizens.
 * @compiler Solidity 0.8.33 Compatibility (Logic-Level)
 */

import { AOXC_GENESIS } from './sys00_AoxcGenesisMaster_180226.ts';
import { ICivilianIdentity, GeneticClass } from './bio01_AoxcCivilianLife_180226.ts';

/**
 * @enum ProposalStatus
 * @description Lifecycle of a Sovereign Decree.
 */
export enum ProposalStatus {
    PENDING,
    ACTIVE,
    DEFEATED,
    SUCCEEDED,
    EXECUTED
}

/**
 * @interface IProposal
 * @description Structure of a fleet-wide legislative change.
 */
interface IProposal {
    id: number;
    proposer: string; // DNA Hash
    description: string;
    votesFor: bigint;
    votesAgainst: bigint;
    status: ProposalStatus;
    deadline: bigint;
}

export class AoxcGovernanceEngine {
    private static instance: AoxcGovernanceEngine;
    private proposals: Map<number, IProposal>;
    private proposalCount: number = 0;

    private constructor() {
        this.proposals = new Map();
    }

    public static getInstance(): AoxcGovernanceEngine {
        if (!AoxcGovernanceEngine.instance) {
            AoxcGovernanceEngine.instance = new AoxcGovernanceEngine();
        }
        return AoxcGovernanceEngine.instance;
    }

    /**
     * @method calculateVotingPower
     * @description Deterministic weight calculation based on DNA and Merit.
     */
    public calculateVotingPower(citizen: ICivilianIdentity): bigint {
        let basePower: bigint;
        
        // Meritocratic Multiplier: ALPHA=1000, BETA=500, GAMMA=200, DELTA=100
        switch (citizen.genClass) {
            case GeneticClass.ALPHA: basePower = 1000n; break;
            case GeneticClass.BETA:  basePower = 500n; break;
            case GeneticClass.GAMMA: basePower = 200n; break;
            case GeneticClass.DELTA: basePower = 100n; break;
            default: basePower = 1n;
        }

        const reputationBonus = BigInt(Math.floor(citizen.reputation / 100));
        return (basePower + reputationBonus) * (10n ** 18n); // Standardized to 18 decimals
    }

    /**
     * @method createProposal
     * @description Citizens with high reputation can submit new decrees.
     */
    public createProposal(proposer: ICivilianIdentity, description: string): number {
        if (proposer.reputation < 8000) {
            throw new Error("GOVERNANCE_LOW_REPUTATION: Minimum 8000 REP required to propose.");
        }

        const id = ++this.proposalCount;
        const newProposal: IProposal = {
            id: id,
            proposer: proposer.dnaHash,
            description: description,
            votesFor: 0n,
            votesAgainst: 0n,
            status: ProposalStatus.ACTIVE,
            deadline: AOXC_GENESIS.TIME.GENESIS_EPOCH + 604800n // 1 Week Duration
        };

        this.proposals.set(id, newProposal);
        return id;
    }

    public castVote(proposalId: number, citizen: ICivilianIdentity, support: boolean): void {
        const proposal = this.proposals.get(proposalId);
        if (!proposal || proposal.status !== ProposalStatus.ACTIVE) {
            throw new Error("GOVERNANCE_INVALID_PROPOSAL: Proposal not found or inactive.");
        }

        const power = this.calculateVotingPower(citizen);
        if (support) {
            proposal.votesFor += power;
        } else {
            proposal.votesAgainst += power;
        }
    }

    public getGovernanceStatus(): string {
        return `GOVERNANCE:ONLINE | PROPOSALS: ${this.proposalCount}`;
    }
}

export const GOVERNANCE_ENGINE_LOADED: boolean = true;
