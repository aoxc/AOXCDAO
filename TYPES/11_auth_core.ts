/**
 * @file 11_auth_core.ts
 * @version 1.0.2 AOXCDAO V2 AKDENIZ
 * @package AOXCDAO.CORE.ANDROMEDA
 * @status OPERATIONAL_IDENTITY_GATE
 * @description 
 * Andromeda Identity Engine. Optimized for Bitwise Role Authorization.
 * Fixed: 'isCommodore' logic integration, UID type-alignment, and unused imports.
 */

import { GlobalIdentityUID } from './00_sys_master';
import { AUTH_ROLE_FLAGS, ICitizenPassport } from './auth00_AoxcGenesisMaster_180226';
import { PrismaClient } from '@prisma/client';

const prisma = new PrismaClient();

/**
 * @class AndromedaCore
 * @description Manages hierarchical access control via sovereign role flags.
 */
export class AndromedaCore {
    private static instance: AndromedaCore;

    private constructor() {}

    public static getInstance(): AndromedaCore {
        if (!AndromedaCore.instance) {
            AndromedaCore.instance = new AndromedaCore();
        }
        return AndromedaCore.instance;
    }

    /**
     * @method validatePassport
     * @description Verifies passport roles and merit scores for vessel access.
     */
    public async validatePassport(passport: ICitizenPassport, targetVessel: number): Promise<boolean> {
        
        // 1. Bitwise Role Verification
        const isAdmiral = (passport.roleFlags & AUTH_ROLE_FLAGS.ADMIRAL_ROOT) !== 0;
        const isCommodore = (passport.roleFlags & AUTH_ROLE_FLAGS.COMMODORE) !== 0;

        // ACADEMIC FIX: Commodore now has elevated access to strategic sectors
        // Admiral has sovereign access; Commodore has access to all except Core Vessel 0 (Admiral Only)
        if (isAdmiral) return true;
        if (isCommodore && targetVessel !== 0x00) return true;
        if (isCommodore && targetVessel === 0x00) {
            console.warn(`[AUTH] Access Denied: Commodore ${passport.uid} attempted to enter ADMIRAL_ROOT.`);
            return false;
        }

        // 2. Merit-Based Access Gate for standard Citizens
        if (passport.meritScore < 1000n && targetVessel === 0x00) {
            throw new Error('AUTH_DENIED: INSUFFICIENT_MERIT_FOR_CORE_VESSEL');
        }

        // 3. Persistent Session Record in Forensic Audit
        await this.logAuthSession(passport.uid, targetVessel);
        
        return true;
    }

    /**
     * @method hasAuthority
     * @description Direct bitwise check for specific operational authority.
     */
    public hasAuthority(currentFlags: number, requiredFlag: AUTH_ROLE_FLAGS): boolean {
        return (currentFlags & requiredFlag) === requiredFlag;
    }

    /**
     * @private logAuthSession
     * @description Records the authentication event into the forensic audit stream.
     */
    private async logAuthSession(uid: GlobalIdentityUID, vesselId: number): Promise<void> {
        // Aligned with schema.prisma 'AuditLog' model
        await prisma.auditLog.create({
            data: {
                subjectUid: uid,
                targetGateId: `AUTH_GATE:V${vesselId}`,
                actionStatus: 1 // STATUS_AUTHORIZED
            }
        });
    }
}

export const ANDROMEDA_INITIALIZED = true;
