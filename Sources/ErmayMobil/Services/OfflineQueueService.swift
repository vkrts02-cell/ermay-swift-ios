import Foundation

public struct OfflineQueueItem: Identifiable, Codable {
    public var id: String = UUID().uuidString
    public var action: String // "INSERT", "UPDATE", "DELETE"
    public var table: String
    public var payload: Data?
    public var recordId: String?
    public var createdAt: Date = Date()
}

public final class OfflineQueueService: @unchecked Sendable {
    public static let shared = OfflineQueueService()
    
    private let queueKey = "ermay_offline_sync_queue"
    private let lock = NSLock()
    
    private init() {}
    
    public func enqueue(action: String, table: String, recordId: String?, payload: Data?) {
        lock.lock()
        defer { lock.unlock() }
        
        var items = getQueue()
        let newItem = OfflineQueueItem(action: action, table: table, payload: payload, recordId: recordId)
        items.append(newItem)
        saveQueue(items)
    }
    
    public func getQueue() -> [OfflineQueueItem] {
        guard let data = UserDefaults.standard.data(forKey: queueKey),
              let items = try? JSONDecoder().decode([OfflineQueueItem].self, from: data) else {
            return []
        }
        return items
    }
    
    private func saveQueue(_ items: [OfflineQueueItem]) {
        if let data = try? JSONEncoder().encode(items) {
            UserDefaults.standard.set(data, forKey: queueKey)
        }
    }
    
    public func processQueue() async {
        let items = getQueue()
        guard !items.isEmpty else { return }
        
        var remaining: [OfflineQueueItem] = []
        for item in items {
            do {
                switch item.action.uppercased() {
                case "DELETE":
                    if let id = item.recordId {
                        try await SupabaseService.shared.delete(table: item.table, id: id)
                    }
                case "INSERT":
                    if let payload = item.payload {
                        try await SupabaseService.shared.insertRaw(into: item.table, data: payload)
                    }
                case "UPDATE":
                    if let id = item.recordId, let payload = item.payload {
                        try await SupabaseService.shared.updateRaw(table: item.table, id: id, data: payload)
                    }
                default:
                    break
                }
            } catch {
                remaining.append(item)
            }
        }
        
        lock.lock()
        saveQueue(remaining)
        lock.unlock()
    }
}

