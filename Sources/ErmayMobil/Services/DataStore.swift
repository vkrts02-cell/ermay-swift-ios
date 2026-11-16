// Sources/ErmayMobil/Services/DataStore.swift
import Foundation
import Combine
import SwiftUI

@MainActor
public final class DataStore: ObservableObject {
    public static let shared = DataStore()
    
    // Published State for SwiftUI Direct Binding
    @Published public var cariler: [CariKart] = []
    @Published public var stoklar: [StokKart] = []
    @Published public var faturalar: [Fatura] = []
    
    // Loading Indicators
    @Published public var isLoadingCariler: Bool = false
    @Published public var isLoadingStoklar: Bool = false
    @Published public var isLoadingFaturalar: Bool = false
    @Published public var isSyncingAll: Bool = false
    
    // Metadata
    @Published public var lastSyncDate: Date? = nil
    @Published public var syncErrorMessage: String? = nil
    
    private init() {
        Task {
            await warmUpLocalCache()
        }
    }
    
    public func warmUpLocalCache() async {
        do {
            async let cachedCariler = LocalDatabaseService.shared.fetchCariler()
            async let cachedStoklar = LocalDatabaseService.shared.fetchStoklar()
            async let cachedFaturalar = LocalDatabaseService.shared.fetchFaturalar()
            
            let (c, s, f) = try await (cachedCariler, cachedStoklar, cachedFaturalar)
            if !c.isEmpty { self.cariler = c }
            if !s.isEmpty { self.stoklar = s }
            if !f.isEmpty { self.faturalar = f }
        } catch {
            print("[DataStore] Warm-up local cache error: \(error)")
        }
    }
    
    // MARK: - Cache-First Cariler
    public func loadCarilerCacheFirst(forceCloudRefresh: Bool = true) async {
        // 1. Instant Local Read (0ms latency)
        do {
            let cached = try await LocalDatabaseService.shared.fetchCariler()
            if !cached.isEmpty {
                self.cariler = cached
            }
        } catch {
            print("[DataStore] Local SQLite cariler read error: \(error)")
        }
        
        // 2. Cloud Synchronization
        guard forceCloudRefresh, SupabaseService.shared.isConfigured else { return }
        isLoadingCariler = self.cariler.isEmpty
        
        do {
            let cloudCariler = try await SupabaseService.shared.fetchCariler()
            try await LocalDatabaseService.shared.upsertCariler(cloudCariler, replaceAll: false)
            self.cariler = try await LocalDatabaseService.shared.fetchCariler()
            self.lastSyncDate = Date()
        } catch {
            print("[DataStore] Supabase cariler sync failed, maintaining local cache: \(error)")
            // Crucial: Cache preserved, lists are NEVER emptied on network error
        }
        isLoadingCariler = false
    }
    
    // MARK: - Cache-First Stoklar
    public func loadStoklarCacheFirst(forceCloudRefresh: Bool = true) async {
        do {
            let cached = try await LocalDatabaseService.shared.fetchStoklar()
            if !cached.isEmpty {
                self.stoklar = cached
            }
        } catch {
            print("[DataStore] Local SQLite stoklar read error: \(error)")
        }
        
        guard forceCloudRefresh, SupabaseService.shared.isConfigured else { return }
        isLoadingStoklar = self.stoklar.isEmpty
        
        do {
            let cloudStoklar = try await SupabaseService.shared.fetchStoklar()
            try await LocalDatabaseService.shared.upsertStoklar(cloudStoklar, replaceAll: false)
            self.stoklar = try await LocalDatabaseService.shared.fetchStoklar()
            self.lastSyncDate = Date()
        } catch {
            print("[DataStore] Supabase stoklar sync failed, maintaining local cache: \(error)")
        }
        isLoadingStoklar = false
    }
    
    // MARK: - Cache-First Faturalar
    public func loadFaturalarCacheFirst(forceCloudRefresh: Bool = true) async {
        do {
            let cached = try await LocalDatabaseService.shared.fetchFaturalar()
            if !cached.isEmpty {
                self.faturalar = cached
            }
        } catch {
            print("[DataStore] Local SQLite faturalar read error: \(error)")
        }
        
        guard forceCloudRefresh, SupabaseService.shared.isConfigured else { return }
        isLoadingFaturalar = self.faturalar.isEmpty
        
        do {
            let cloudFaturalar: [Fatura] = try await SupabaseService.shared.fetch(from: "faturalar", orderBy: "tarih.desc", limit: 5000)
            try await LocalDatabaseService.shared.upsertFaturalar(cloudFaturalar, replaceAll: false)
            self.faturalar = try await LocalDatabaseService.shared.fetchFaturalar()
            self.lastSyncDate = Date()
        } catch {
            print("[DataStore] Supabase faturalar sync failed, maintaining local cache: \(error)")
        }
        isLoadingFaturalar = false
    }
    
    // MARK: - Global Full Sync
    public func refreshAll(force: Bool = true) async {
        await syncAll()
    }

    public func syncAll() async {
        guard !isSyncingAll else { return }
        isSyncingAll = true
        defer { isSyncingAll = false }
        
        await loadCarilerCacheFirst(forceCloudRefresh: true)
        await loadStoklarCacheFirst(forceCloudRefresh: true)
        await loadFaturalarCacheFirst(forceCloudRefresh: true)
    }
}
