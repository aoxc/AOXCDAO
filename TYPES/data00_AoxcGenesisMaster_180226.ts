/**
 * @file data00_AoxcGenesisMaster_180226.ts
 * @namespace AOXCDAO.Core.Data
 * @version 2.0.0 AOXCDAO V2 AKDENIZ
 * @status IMMUTABLE_DATA_ROOT
 * @compiler Solidity 0.8.33 Compatibility
 * @description Constants for 1 Billion Passenger Neural Storage. Final Logic Mühürlendi.
 */


/**
 * @enum STORAGE_TIER
 * @description Verinin "Sıcaklığına" göre fiziksel konumunu belirler.
 */
export enum STORAGE_TIER {
    NEURAL_RAM = 0x01,  // Gerçek zamanlı yaşam desteği verisi
    SHARD_SSD  = 0x02,  // Aktif shard işlemleri (TX)
    COLD_VAULT = 0x03,  // Tarihsel kayıtlar ve yedekler
    DEEP_VOID  = 0x04   // Arşivlenmiş veya silinmiş veriler
}

export const DATA_CONFIG = {
    VESSEL_ID: 0x07, // VIRGO
    SCHEMA_VERSION: 1, 
    TOTAL_SHARDS: 1024,
    SHARD_MASK: 0x3FF, // 1024 Shard için 10-bit maske
    MAX_RECORDS_PER_SHARD: 1_000_000, 
    BLOCK_SIZE_BYTES: 4096,           
    REPLICATION_FACTOR: 3,            
    INTEGRITY_CHECK_INTERVAL_NS: 1000 
} as const;

/**
 * @interface IShardMap
 * @description Vatandaş ve Shard arasındaki matematiksel köprü.
 */
export interface IShardMap {
    readonly shardIndex: number;      // 0 - 1023
    readonly physicalVesselId: number; // 0x00 - 0x07 (Hex ID daha güvenli)
    readonly neuralRootHash: string;  // Shard'ın Merkle/ZK-Root özeti
    readonly isLocked: boolean;       // Yazma koruması
}

/**
 * @class DataPhysicsProvider
 * @description Veri katmanının fiziksel limitlerini kontrol eden statik sağlayıcı.
 */
export class DataPhysicsProvider {
    /**
     * @method getShardFromId
     * @description CitizenId üzerinden hangi Shard'a gidileceğini hesaplar.
     */
    public static getShardFromId(citizenId: bigint): number {
        return Number(citizenId & BigInt(DATA_CONFIG.SHARD_MASK));
    }
}

export const DATA_GENESIS_LOADED: boolean = true;
