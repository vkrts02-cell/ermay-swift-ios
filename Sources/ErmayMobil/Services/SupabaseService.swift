import Foundation

public final class SupabaseService: @unchecked Sendable {
    public static let shared = SupabaseService()
    
    public var baseUrl: String = "https://fqgbdymffknglqeqoogt.supabase.co"
    public var anonKey: String = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImZxZ2JkeW1mZmtuZ2xxZXFvb2d0Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODk1ODUzMDEsImV4cCI6MjEwNTE2MTMwMX0.pBeE2ivWpbkAd8KSN1y2pXNZPIr_1mGMLXXHYPzjTDg"
    public var tenantId: String = "tenant_vkrts1992_gmail_com"
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
        limit: Int? = nil
    ) async throws -> [T] {
        var components = URLComponents(string: "\(baseUrl)/rest/v1/\(table)")
        var queryItems = [
            URLQueryItem(name: "select", value: select),
            URLQueryItem(name: "tenant_id", value: "eq.\(tenantId)")
        ]
        
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
        guard let url = URL(string: "\(baseUrl)/rest/v1/\(table)?id=eq.\(id)&tenant_id=eq.\(tenantId)") else {
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
        guard let url = URL(string: "\(baseUrl)/rest/v1/\(table)?id=eq.\(id)&tenant_id=eq.\(tenantId)") else {
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
    
    // MARK: - PostgREST Delete
    public func delete(table: String, id: String) async throws {
        guard let url = URL(string: "\(baseUrl)/rest/v1/\(table)?id=eq.\(id)&tenant_id=eq.\(tenantId)") else {
            throw URLError(.badURL)
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        defaultHeaders().forEach { request.setValue($0.value, forHTTPHeaderField: $0.key) }
        
        let (data, response) = try await session.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
            let errorMsg = String(data: data, encoding: .utf8) ?? "Silme Başarısız"
            throw NSError(domain: "SupabaseError", code: (response as? HTTPURLResponse)?.statusCode ?? 500, userInfo: [NSLocalizedDescriptionKey: errorMsg])
        }
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
}

