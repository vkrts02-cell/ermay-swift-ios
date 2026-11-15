// Sources/ErmayMobil/Services/OfflineQueueService.swift
import Foundation
import Network
#if canImport(UIKit)
import UIKit
#endif

public struct OfflineQueueItem: Identifiable, Sendable {
    public let id: String
    public let endpoint: String
    public let method: String
    public let payload: String
    public let createdAt: String
    public var retryCount: Int
    public var status: String
    public var lastError: String?
    public var nextRetryAt: String?
    
    public init(
        id: String = UUID().uuidString,
        endpoint: String,
        method: String,
        payload: String,
        createdAt: String = ISO8601DateFormatter().string(from: Date()),
        retryCount: Int = 0,
        status: String = "pending",
        lastError: String? = nil,
        nextRetryAt: String? = nil
    ) {
        self.id = id
        self.endpoint = endpoint
        self.method = method
        self.payload = payload
        self.createdAt = createdAt
        self.retryCount = retryCount
        self.status = status
        self.lastError = lastError
        self.nextRetryAt = nextRetryAt
    }
}

public final class OfflineQueueService: @unchecked Sendable {
    public static let shared = OfflineQueueService()
    
    private let lock = NSLock()
    private let monitor = NWPathMonitor()
    private let monitorQueue = DispatchQueue(label: "com.ermay.offlinequeue.network")
    private var isMonitoring = false
    private var isProcessing = false
    private var timer: Timer?
    
    public var isOnline: Bool = true
    
    private init() {}
    
    public func startAutoProcessing(interval: TimeInterval = 30.0) {
        lock.lock()
        guard !isMonitoring else {
            lock.unlock()
            return
        }
        isMonitoring = true
        lock.unlock()
        
        // 1. Ağ bağlantısı geri geldiğinde otomatik tetikleme
        monitor.pathUpdateHandler = { [weak self] path in
            guard let self = self else { return }
            let satisfied = (path.status == .satisfied)
            self.isOnline = satisfied
            if satisfied {
                Task {
                    await self.processQueue()
                }
            }
        }
        monitor.start(queue: monitorQueue)
        
        // 2. Belirlenen periyotta otomatik deneme
        DispatchQueue.main.async { [weak self] in
            self?.timer?.invalidate()
            self?.timer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { _ in
                Task { [weak self] in
                    await self?.processQueue()
                }
            }
        }
        
        // 3. Uygulama ön plana geldiğinde tetikleme
        #if canImport(UIKit)
        NotificationCenter.default.addObserver(
            forName: UIApplication.didBecomeActiveNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            Task { [weak self] in
                await self?.processQueue()
            }
        }
        #endif
        
        // Başlangıç tetiklemesi
        Task {
            await processQueue()
        }
    }
    
    public func stopAutoProcessing() {
        lock.lock()
        isMonitoring = false
        lock.unlock()
        
        monitor.cancel()
        DispatchQueue.main.async { [weak self] in
            self?.timer?.invalidate()
            self?.timer = nil
        }
    }
    
    // MARK: - Enqueue Operations
    public func enqueueAsync(endpoint: String, method: String, payload: String) async {
        let itemId = UUID().uuidString
        do {
            try await LocalDatabaseService.shared.enqueueOfflineItem(
                id: itemId,
                endpoint: endpoint,
                method: method,
                payload: payload
            )
            print("[OfflineQueueService] Successfully queued item \(itemId) for \(endpoint)")
        } catch {
            print("[OfflineQueueService] Enqueue error: \(error)")
        }
    }

    public func enqueue(endpoint: String, method: String, payload: String) {
        Task {
            await enqueueAsync(endpoint: endpoint, method: method, payload: payload)
        }
    }
    
    /// Compatibility overload for legacy call sites (table/action/payload data)
    public func enqueue(action: String, table: String, recordId: String?, payload: Data?) {
        var payloadString = ""
        if let data = payload, let str = String(data: data, encoding: .utf8) {
            payloadString = str
        } else if let recId = recordId {
            payloadString = "{\"id\":\"\(recId)\"}"
        }
        
        let method: String
        let endpoint: String
        switch action.uppercased() {
        case "DELETE":
            method = "DELETE"
            endpoint = recordId.map { "\(table)/\($0)" } ?? table
        case "UPDATE":
            method = "PUT"
            endpoint = recordId.map { "\(table)/\($0)" } ?? table
        case "RPC":
            method = "RPC"
            endpoint = table
        case "BUNDLE":
            method = "BUNDLE"
            endpoint = table
        default:
            method = "POST"
            endpoint = table
        }
        
        enqueue(endpoint: endpoint, method: method, payload: payloadString)
    }
    
    /// Enqueue an atomic double-entry bundle (e.g. cash + customer movements)
    public func enqueueBundleAsync(payload: [String: Any]) async {
        if let data = try? JSONSerialization.data(withJSONObject: payload),
           let jsonString = String(data: data, encoding: .utf8) {
            await enqueueAsync(endpoint: "financial_bundle", method: "BUNDLE", payload: jsonString)
        }
    }

    public func enqueueBundle(payload: [String: Any]) {
        if let data = try? JSONSerialization.data(withJSONObject: payload),
           let jsonString = String(data: data, encoding: .utf8) {
            enqueue(endpoint: "financial_bundle", method: "BUNDLE", payload: jsonString)
        }
    }
    
    // MARK: - Process Queue with DLQ & Exponential Backoff
    public func processQueue() async {
        lock.lock()
        guard !isProcessing, isOnline else {
            lock.unlock()
            return
        }
        isProcessing = true
        lock.unlock()
        
        defer {
            lock.lock()
            isProcessing = false
            lock.unlock()
        }
        
        do {
            let pendingItems = try await LocalDatabaseService.shared.fetchPendingOfflineItems(limit: 10)
            guard !pendingItems.isEmpty else { return }
            
            for item in pendingItems {
                do {
                    try await executeQueueItem(item)
                    // Success -> delete item from local SQLite queue
                    try await LocalDatabaseService.shared.removeOfflineItem(id: item.id)
                    print("[OfflineQueueService] Item \(item.id) successfully synced and removed from queue.")
                    NotificationCenter.default.post(name: .offlineQueueItemSynced, object: nil, userInfo: ["id": item.id])
                } catch {
                    print("[OfflineQueueService] Execution failed for item \(item.id): \(error)")
                    await handleItemFailure(item, error: error)
                }
            }
        } catch {
            print("[OfflineQueueService] Queue read error: \(error)")
        }
    }
    
    private func executeQueueItem(_ item: OfflineQueueItem) async throws {
        guard let payloadData = item.payload.data(using: .utf8) else {
            throw NSError(domain: "OfflineQueue", code: 400, userInfo: [NSLocalizedDescriptionKey: "Invalid payload encoding"])
        }
        
        switch item.method.uppercased() {
        case "RPC":
            if let dict = try? JSONSerialization.jsonObject(with: payloadData) as? [String: Any] {
                let res = try await SupabaseService.shared.rpcRaw(function: item.endpoint, params: dict)
                if let success = res["success"] as? Bool, !success {
                    let msg = (res["message"] as? String) ?? "Atomic RPC failed"
                    throw NSError(domain: "SupabaseRPC", code: 500, userInfo: [NSLocalizedDescriptionKey: msg])
                }
            }
        case "POST":
            try await SupabaseService.shared.insertRaw(into: item.endpoint, data: payloadData)
        case "PUT":
            let parts = item.endpoint.split(separator: "/")
            if parts.count == 2 {
                let tbl = String(parts[0])
                let recId = String(parts[1])
                try await SupabaseService.shared.updateRaw(table: tbl, id: recId, data: payloadData)
            } else {
                try await SupabaseService.shared.insertRaw(into: item.endpoint, data: payloadData)
            }
        case "DELETE":
            let parts = item.endpoint.split(separator: "/")
            if parts.count == 2 {
                let tbl = String(parts[0])
                let recId = String(parts[1])
                try await SupabaseService.shared.delete(table: tbl, id: recId)
            }
        case "BUNDLE":
            try await executeFinancialBundle(payloadData: payloadData)
        default:
            throw NSError(domain: "OfflineQueue", code: 405, userInfo: [NSLocalizedDescriptionKey: "Unsupported method \(item.method)"])
        }
    }
    
    private func executeFinancialBundle(payloadData: Data) async throws {
        guard let json = try JSONSerialization.jsonObject(with: payloadData) as? [String: Any] else {
            throw NSError(domain: "Bundle", code: 400, userInfo: [NSLocalizedDescriptionKey: "Invalid JSON bundle"])
        }
        
        // 1. Kasa / Banka Hareketi (Idempotent upsert on uuid)
        if let kasa = json["kasa_hareket"] as? [String: Any] {
            let data = try JSONSerialization.data(withJSONObject: kasa)
            try await SupabaseService.shared.upsertRaw(into: "kasa_hareketler", data: data, onConflict: "uuid")
        } else if let banka = json["banka_hareket"] as? [String: Any] {
            let data = try JSONSerialization.data(withJSONObject: banka)
            try await SupabaseService.shared.upsertRaw(into: "banka_hareketler", data: data, onConflict: "uuid")
        }
        
        // 2. Cari Hareketi (Idempotent upsert on uuid)
        if let cari = json["cari_hareket"] as? [String: Any] {
            let data = try JSONSerialization.data(withJSONObject: cari)
            try await SupabaseService.shared.upsertRaw(into: "cari_hareketler", data: data, onConflict: "uuid")
        }
        
        // 3. Cari Bakiye Güncelleme
        if let cid = json["cari_id"] as? Int,
           let bakiye = json["yeni_cari_bakiye"] as? Double,
           let bakiyeTuru = json["yeni_cari_bakiye_turu"] as? String {
            let updateDict: [String: Any] = ["bakiye": bakiye, "bakiye_turu": bakiyeTuru]
            if let updateData = try? JSONSerialization.data(withJSONObject: updateDict) {
                try await SupabaseService.shared.updateRaw(
                    table: "cariler",
                    id: "\(cid)",
                    data: updateData
                )
            }
        }
    }
    
    private func handleItemFailure(_ item: OfflineQueueItem, error: Error) async {
        let newRetry = item.retryCount + 1
        let errorDesc = error.localizedDescription
        
        if newRetry >= 3 {
            // Move to Dead-Letter Queue (DLQ)
            do {
                try await LocalDatabaseService.shared.updateOfflineItemFailure(
                    id: item.id,
                    errorDesc: errorDesc,
                    nextRetryAt: nil,
                    isDeadLetter: true
                )
                print("[OfflineQueueService] Item \(item.id) reached max retries. Moved to DLQ.")
                NotificationCenter.default.post(
                    name: .offlineQueueDeadLetterDetected,
                    object: nil,
                    userInfo: ["id": item.id, "error": errorDesc, "endpoint": item.endpoint]
                )
            } catch {
                print("[OfflineQueueService] Failed to move to DLQ: \(error)")
            }
        } else {
            // Exponential Backoff (2s, 4s, 8s) + Jitter
            let delay = pow(2.0, Double(newRetry)) + Double.random(in: 0.0...0.5)
            let nextDate = Date().addingTimeInterval(delay)
            let nextStr = ISO8601DateFormatter().string(from: nextDate)
            
            do {
                try await LocalDatabaseService.shared.updateOfflineItemFailure(
                    id: item.id,
                    errorDesc: errorDesc,
                    nextRetryAt: nextStr,
                    isDeadLetter: false
                )
                print("[OfflineQueueService] Item \(item.id) failed (attempt \(newRetry)). Backoff until \(nextStr)")
            } catch {
                print("[OfflineQueueService] Failed to update backoff: \(error)")
            }
        }
    }
    
    public func retryDeadLetterItem(id: String) async {
        do {
            try await LocalDatabaseService.shared.retryDeadLetterItem(id: id)
            await processQueue()
        } catch {
            print("[OfflineQueueService] retryDeadLetterItem error: \(error)")
        }
    }
}

extension Notification.Name {
    public static let offlineQueueItemSynced = Notification.Name("offlineQueueItemSynced")
    public static let offlineQueueDeadLetterDetected = Notification.Name("offlineQueueDeadLetterDetected")
    public static let userToastNotification = Notification.Name("userToastNotification")
}
