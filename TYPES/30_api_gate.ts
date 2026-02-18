/**
 * @file sys11_AndromedaAuthCore.ts
 * @version 2.0.2 AOXCDAO V2 AKDENIZ
 * @package AOXCDAO.CORE.ANDROMEDA
 * @status IMMUTABLE_AUTH_FINAL
 * @description 
 * Andromeda Root Authority. 
 * Fixed: Unused API_CONFIG, integrated isAdmin logic for bypass, and aligned shard routing.
 */

import { GalacticGatewayEngine } from './api00_AoxcGenesisMaster_180226';
import { AUTH_ROLE_FLAGS, ICitizenPassport } from './auth00_AoxcGenesisMaster_180226';
import { AiAuditCore } from './10_ai_audit';
import { PrismaClient } from '@prisma/client';

const prisma = new PrismaClient();

/**
 * @class AndromedaAuthCore
 * @description Enforces sovereign access control using Quantum Merkle Proofs and Bitwise logic.
 */
export class AndromedaAuthCore {
    private static instance: AndromedaAuthCore;
    private auditor = AiAuditCore.getInstance();
    private seenHashes: Set<string> = new Set();

    private constructor() {}

    public static getInstance(): AndromedaAuthCore {
        if (!AndromedaAuthCore.instance) {
            AndromedaAuthCore.instance = new AndromedaAuthCore();
        }
        return AndromedaAuthCore.instance;
    }

    /**
     * @method sovereignAccessCheck
     * @description Validates identity via Neural Handshake and enforces Bitwise routing security.
     */
    public async sovereignAccessCheck(
        passport: ICitizenPassport, 
        merkleProof: string[], 
        merkleRoot: string,
        requestHash: string
    ): Promise<boolean> {
        
        // 1. Idempotency & Replay Protection
        if (!GalacticGatewayEngine.enforceIdempotency(requestHash, this.seenHashes)) {
            throw new Error('AUTH_DENIED: REPLAY_ATTACK_DETECTED');
        }

        // 2. Role-Based Sovereign Verification (ACADEMIC FIX: isAdmin now utilized)
        const isAdmin = (passport.roleFlags & AUTH_ROLE_FLAGS.ADMIRAL_ROOT) !== 0;

        // Admirals bypass Merkle validation for emergency core access (Emergency Protocol 0xFF)
        if (!isAdmin) {
            // 3. Quantum Merkle Validation for standard citizens
            const isVerified = GalacticGatewayEngine.validateNeuralHandshake(
                merkleProof, 
                merkleRoot, 
                passport.uid
            );

            if (!isVerified) {
                throw new Error('AUTH_DENIED: INVALID_QUANTUM_SIGNATURE');
            }
        }

        // 4. Bitwise Shard-Vessel Integrity Check
        const { vesselId, shardId } = GalacticGatewayEngine.fastRoute(BigInt(passport.uid));
        
        // Logical verification: Ensure the passport matches the calculated routing
        if (!isAdmin && (vesselId !== passport.issuingVessel || shardId !== passport.homeShardId)) {
            throw new Error('AUTH_DENIED: SHARD_IDENTITY_MISMATCH');
        }

        // 5. Audit Trace: Record the event in the Forensic Log
        await this.auditor.verifyDecisionConsistency(requestHash, 'ROOT_IDENTITY_VERIFICATION');

        // 6. DB Session Log (Using Prisma to finalize the handshake)
        await prisma.auditLog.create({
            data: {
                subjectUid: BigInt(passport.uid),
                targetGateId: `ANDROMEDA_GATE_V${vesselId}`,
                actionStatus: isAdmin ? 0xFF : 1 // 0xFF for Root Authority access
            }
        });

        console.log(`[ANDROMEDA] ACCESS GRANTED: UID_${passport.uid} | ROLE_${isAdmin ? 'ADMIRAL' : 'CITIZEN'}`);
        return true;
    }
}

export const ANDROMEDA_SEALED: boolean = true;
