/**
 * @file 04_sys_gov.ts
 * @version 1.0.2 AOXCDAO V2 AKDENIZ
 * @package AOXCDAO.CORE.GOVERNANCE
 * @status OPERATIONAL_LOGIC_LAYER
 * @description 
 * Meritocratic Voting and Decree System for 1B+ Citizens. 
 * Fixed: 'GlobalIdentityUID' integration and optimized local interface.
 * NO TURKISH CHARACTERS - ACADEMIC LEVEL LOGIC.
 */

import { AOXC_GENESIS, GlobalIdentityUID } from './00_sys_master';
import { PrismaClient } from '@prisma/client';

const prisma = new PrismaClient();

/**
 * @interface ICivilianIdentity
 * @description Local definition to decouple governance from biological subsystems.
 */
export interface ICivilianIdentity {
    uid: GlobalIdentityUID;
    genClass: number;
    reputation: number;
    dnaHash: string;
}

export enum ProposalStatus {
    PENDING,
    ACTIVE,
    DEFEATED,
    SUCCEEDED,
    EXECUTED
}

export class AoxcGovernanceEngine {
    private static instance: AoxcGovernanceEngine;

    private constructor() {}

    public static getInstance(): AoxcGovernanceEngine {
        if (!AoxcGovernanceEngine.instance) {
            AoxcGovernanceEngine.instance = new AoxcGovernanceEngine();
        }
        return AoxcGovernanceEngine.instance;
    }

    /**
     * @method calculateVotingPower
     * @description Computes voting weight based on DNA Rank and Meritocratic Reputation.
     */
    public calculateVotingPower(citizen: ICivilianIdentity): bigint {
        let basePower: bigint;
        
        switch (citizen.genClass) {
            case 0xFF: basePower = 10000n; break; // ADMIRAL
            case 0x80: basePower = 1000n;  break; // ALPHA
            case 0x40: basePower = 500n;   break; // BETA
            case 0x20: basePower = 200n;   break; // GAMMA
            default:   basePower = 100n;          // DELTA
        }

        const reputationBonus = BigInt(Math.floor(citizen.reputation / 100));
        return (basePower + reputationBonus) * (10n ** 18n);
    }

    /**
     * @method createProposal
     * @description Persists a new decree in the database for qualifying citizens.
     */
    public async createProposal(proposer: ICivilianIdentity, description: string): Promise<number> {
        if (proposer.reputation < 8000) {
            throw new Error('GOVERNANCE_INSUFFICIENT_REPUTATION');
        }

        const proposal = await prisma.proposal.create({
            data: {
                proposerHash: proposer.dnaHash,
                description: description,
                status: ProposalStatus.ACTIVE,
                deadline: AOXC_GENESIS.TIME.GENESIS_EPOCH + AOXC_GENESIS.TIME.WEEK
            }
        });

        return proposal.id;
    }

    /**
     * @method castVote
     * @description Records a vote while ensuring GlobalIdentityUID integrity.
     * FIXED: Integrated GlobalIdentityUID into the logic flow.
     */
    public async castVote(proposalId: number, citizen: ICivilianIdentity, support: boolean): Promise<void> {
        // 1. Identify Voter's current Vessel from GlobalIdentityUID (BigInt)
        const voterUid: GlobalIdentityUID = citizen.uid;
        const voterVesselId = Number((voterUid % BigInt(AOXC_GENESIS.SCALE.TOTAL_SHARDS)) / 128n);

        // 2. Strait Integrity Check
        const vessel = await prisma.vessel.findUnique({ where: { id: voterVesselId } });
        if (vessel?.straitStatus !== AOXC_GENESIS.STRAIT_PROTOCOL.STATUS_SECURE) {
            throw new Error('GOVERNANCE_ACCESS_DENIED: VESSEL_IN_ISOLATION');
        }

        const power = this.calculateVotingPower(citizen);

        // 3. Persistent Vote Recording
        await prisma.vote.create({
            data: {
                proposalId: proposalId,
                voterUid: voterUid.toString(), // Ensuring string mapping for DB compatibility if required
                power: power,
                support: support
            }
        });
    }
}

export const GOVERNANCE_ENGINE_LOADED: boolean = true;
