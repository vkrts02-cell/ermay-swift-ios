import Foundation

public final class SupabaseService: @unchecked Sendable {
    public static let shared = SupabaseService()
    
    public var baseUrl: String = "https://fqgbdymffknglqeqoogt.supabase.co"
    public var anonKey: String = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImZxZ2JkeW1mZmtuZ2xxZXFvb2d0Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODk1ODUzMDEsImV4cCI6MjEwNTE2MTMwMX0.pBeE2ivWpbkAd8KSN1y2pXNZPIr_1mGMLXXHYPzjTDg"
    public var tenantId: String = "tenant_ermay_master"
    public var authToken: String? = nil
    
    private let session: URLSession
    private let decoder: JSONDecoder
    private let encoder: JSONEncoder
    
    private init() {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 30
        config.timeoutIntervalForResource = 60
        self.session = URLSession(configuration: config)
        
        self.decoder = JSONDecoder()
        self.encoder = JSONEncoder()
    }
    
    private func defaultHeaders(prefer: String? = nil) -> [String: String] {
        var headers: [String: String] = [
            "apikey": anonKey,
            "Authorization": "Bearer \(authToken ?? anonKey)",
            "Content-Type": "application/json"
        ]
        if let prefer = prefer {
            headers["Prefer"] = prefer
        }
        return headers
    }
    
    // MARK: - PostgREST GET / Fetch
    public func fetch<T: Decodable>(
        from table: String,
        select: String = "*",
        filters: [String: String] = [:],
        orderBy: String? = nil,
        limit: Int? = nil,
        applyTenantFilter: Bool = true
    ) async throws -> [T] {
        var components = URLComponents(string: "\(baseUrl)/rest/v1/\(table)")
        var queryItems = [
            URLQueryItem(name: "select", value: select)
        ]
        
        if applyTenantFilter {
            // Canlı veritabanındaki tenant_id çeşitliliğini kapsayan filtre
            queryItems.append(URLQueryItem(name: "or", value: "(tenant_id.eq.\(tenantId),tenant_id.eq.default,tenant_id.is.null)"))
        }

        // Soft-delete filtresi: Silinmiş kayıtları getirme
        if !filters.keys.contains("deleted_at") && !filters.keys.contains("is_deleted") {
            queryItems.append(URLQueryItem(name: "deleted_at", value: "is.null"))
        }
        
        for (key, val) in filters {
            queryItems.append(URLQueryItem(name: key, value: val))
        }
        
        if let orderBy = orderBy {
            queryItems.append(URLQueryItem(name: "order", value: orderBy))
        }
        
        if let limit = limit {
            queryItems.append(URLQueryItem(name: "limit", value: "\(limit)"))
        }
        
        components?.queryItems = queryItems
        guard let url = components?.url else {
            throw URLError(.badURL)
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        defaultHeaders().forEach { request.setValue($0.value, forHTTPHeaderField: $0.key) }
        
        let (data, response) = try await session.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
            let errorMsg = String(data: data, encoding: .utf8) ?? "Bilinmeyen Sunucu Hatası"
            throw NSError(domain: "SupabaseError", code: (response as? HTTPURLResponse)?.statusCode ?? 500, userInfo: [NSLocalizedDescriptionKey: errorMsg])
        }
        
        return try decoder.decode([T].self, from: data)
    }
    
    // MARK: - Convenience Fetch Methods for Exact Desktop Parity
    public func fetchCariler() async throws -> [CariKart] {
        return try await fetch(from: "cariler", orderBy: "unvan.asc", limit: 5000)
    }
    
    public func fetchCariHareketler(cariId: String) async throws -> [CariHareket] {
        return try await fetch(
            from: "cari_hareketler",
            filters: ["cari_id": "eq.\(cariId)"],
            orderBy: "tarih.desc",
            limit: 2000,
            applyTenantFilter: false
        )
    }
    
    public func fetchStoklar() async throws -> [StokKart] {
        return try await fetch(from: "stoklar", orderBy: "stok_adi.asc", limit: 5000)
    }
    
    public func fetchFaturalar() async throws -> [Fatura] {
        return try await fetch(from: "faturalar", orderBy: "tarih.desc", limit: 5000)
    }
    
    public func fetchSiparisler() async throws -> [Siparis] {
        return try await fetch(from: "siparisler", orderBy: "tarih.desc", limit: 5000)
    }
    
    public func fetchTeklifler() async throws -> [Teklif] {
        return try await fetch(from: "teklifler", orderBy: "tarih.desc", limit: 5000)
    }
    
    // MARK: - PostgREST Insert
    public func insert<T: Encodable>(into table: String, item: T) async throws {
        let data = try encoder.encode(item)
        try await insertRaw(into: table, data: data)
    }
    
    public func insert<T: Encodable, R: Decodable>(into table: String, item: T) async throws -> R {
        guard let url = URL(string: "\(baseUrl)/rest/v1/\(table)") else {
            throw URLError(.badURL)
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        defaultHeaders(prefer: "return=representation").forEach { request.setValue($0.value, forHTTPHeaderField: $0.key) }
        
        request.httpBody = try encoder.encode(item)
        
        let (data, response) = try await session.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
            let errorMsg = String(data: data, encoding: .utf8) ?? "Kayıt Eklenemedi"
            throw NSError(domain: "SupabaseError", code: (response as? HTTPURLResponse)?.statusCode ?? 500, userInfo: [NSLocalizedDescriptionKey: errorMsg])
        }
        
        let results = try decoder.decode([R].self, from: data)
        guard let first = results.first else {
            throw NSError(domain: "SupabaseError", code: 404, userInfo: [NSLocalizedDescriptionKey: "Sonuç bulunamadı"])
        }
        return first
    }
    
    // MARK: - PostgREST Raw Insert
    public func insertRaw(into table: String, data: Data) async throws {
        guard let url = URL(string: "\(baseUrl)/rest/v1/\(table)") else {
            throw URLError(.badURL)
        }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        defaultHeaders(prefer: "return=minimal").forEach { request.setValue($0.value, forHTTPHeaderField: $0.key) }
        request.httpBody = data
        let (resData, response) = try await session.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
            let errorMsg = String(data: resData, encoding: .utf8) ?? "Ham Kayıt Eklenemedi"
            throw NSError(domain: "SupabaseError", code: (response as? HTTPURLResponse)?.statusCode ?? 500, userInfo: [NSLocalizedDescriptionKey: errorMsg])
        }
    }
    
    // MARK: - PostgREST Raw Update
    public func updateRaw(table: String, id: String, data: Data) async throws {
        guard let url = URL(string: "\(baseUrl)/rest/v1/\(table)?id=eq.\(id)") else {
            throw URLError(.badURL)
        }
        var request = URLRequest(url: url)
        request.httpMethod = "PATCH"
        defaultHeaders(prefer: "return=minimal").forEach { request.setValue($0.value, forHTTPHeaderField: $0.key) }
        request.httpBody = data
        let (resData, response) = try await session.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
            let errorMsg = String(data: resData, encoding: .utf8) ?? "Ham Güncelleme Başarısız"
            throw NSError(domain: "SupabaseError", code: (response as? HTTPURLResponse)?.statusCode ?? 500, userInfo: [NSLocalizedDescriptionKey: errorMsg])
        }
    }
    
    // MARK: - PostgREST Update
    public func update<T: Encodable>(table: String, id: String, item: T) async throws {
        guard let url = URL(string: "\(baseUrl)/rest/v1/\(table)?id=eq.\(id)") else {
            throw URLError(.badURL)
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "PATCH"
        defaultHeaders(prefer: "return=minimal").forEach { request.setValue($0.value, forHTTPHeaderField: $0.key) }
        request.httpBody = try encoder.encode(item)
        
        let (data, response) = try await session.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
            let errorMsg = String(data: data, encoding: .utf8) ?? "Güncelleme Başarısız"
            throw NSError(domain: "SupabaseError", code: (response as? HTTPURLResponse)?.statusCode ?? 500, userInfo: [NSLocalizedDescriptionKey: errorMsg])
        }
    }
    
    // MARK: - PostgREST Soft Delete (Silinen kayıtlar deleted_at ile işaretlenir, diğer cihazlara yayılır)
    public func delete(table: String, id: String) async throws {
        let nowStr = ISO8601DateFormatter().string(from: Date())
        let softDeletePayload: [String: Any] = [
            "deleted_at": nowStr,
            "is_deleted": true,
            "updated_at": nowStr,
            "device_id": "iPhone-App"
        ]
        
        let jsonData = try JSONSerialization.data(withJSONObject: softDeletePayload)
        try await updateRaw(table: table, id: id, data: jsonData)
    }
    
    // MARK: - RPC Calls
    public func rpc<T: Encodable, R: Decodable>(function: String, params: T) async throws -> R {
        guard let url = URL(string: "\(baseUrl)/rest/v1/rpc/\(function)") else {
            throw URLError(.badURL)
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        defaultHeaders().forEach { request.setValue($0.value, forHTTPHeaderField: $0.key) }
        request.httpBody = try encoder.encode(params)
        
        let (data, response) = try await session.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
            let errorMsg = String(data: data, encoding: .utf8) ?? "RPC Çağrısı Başarısız"
            throw NSError(domain: "SupabaseError", code: (response as? HTTPURLResponse)?.statusCode ?? 500, userInfo: [NSLocalizedDescriptionKey: errorMsg])
        }
        
        return try decoder.decode(R.self, from: data)
    }
    
    // MARK: - Supabase Realtime WebSocket Listener (Phoenix Channel)
    private var webSocketTask: URLSessionWebSocketTask? = nil
    private var isRealtimeActive: Bool = false
    
    public func startRealtimeListener() {
        guard !isRealtimeActive else { return }
        isRealtimeActive = true
        
        let wsHost = baseUrl.replacingOccurrences(of: "https://", with: "wss://").replacingOccurrences(of: "http://", with: "ws://")
        guard let wsUrl = URL(string: "\(wsHost)/realtime/v1/websocket?apikey=\(anonKey)&vsn=1.0.0") else { return }
        
        webSocketTask = session.webSocketTask(with: wsUrl)
        webSocketTask?.resume()
        
        // Join public channel
        let joinMessage = """
        {"topic":"realtime:public","event":"phx_join","payload":{"config":{"postgres_changes":[{"event":"*","schema":"public"}]}},"ref":"1"}
        """
        webSocketTask?.send(.string(joinMessage)) { _ in }
        
        listenWebSocketMessages()
    }
    
    public func stopRealtimeListener() {
        isRealtimeActive = false
        webSocketTask?.cancel(with: .normalClosure, reason: nil)
        webSocketTask = nil
    }
    
    private func listenWebSocketMessages() {
        guard isRealtimeActive, let task = webSocketTask else { return }
        
        task.receive { [weak self] result in
            guard let self = self, self.isRealtimeActive else { return }
            
            switch result {
            case .success(let message):
                if case .string(let text) = message {
                    if text.contains("postgres_changes") || text.contains("INSERT") || text.contains("UPDATE") || text.contains("DELETE") {
                        DispatchQueue.main.async {
                            NotificationCenter.default.post(name: .supabaseRealtimeDataChanged, object: nil)
                        }
                    }
                }
                self.listenWebSocketMessages()
            case .failure:
                // Yeniden bağlanma (Reconnection with 5s delay)
                DispatchQueue.global().asyncAfter(deadline: .now() + 5) { [weak self] in
                    if self?.isRealtimeActive == true {
                        self?.webSocketTask = nil
                        self?.isRealtimeActive = false
                        self?.startRealtimeListener()
                    }
                }
            }
        }
    }
}

public extension Notification.Name {
    static let supabaseRealtimeDataChanged = Notification.Name("supabaseRealtimeDataChanged")
}
