// Sources/ErmayMobil/Services/LocalDatabaseService.swift
import Foundation
import SQLite3

private let SQLITE_TRANSIENT = unsafeBitCast(-1, to: sqlite3_destructor_type.self)

public actor LocalDatabaseService {
    public static let shared = LocalDatabaseService()
    
    private nonisolated(unsafe) var db: OpaquePointer?
    private let lock = NSRecursiveLock()
    private let dbFileName = "ermay_local.sqlite3"
    
    private init() {
        initializeDatabaseSync()
    }
    
    private nonisolated func initializeDatabaseSync() {
        lock.lock()
        defer { lock.unlock() }
        do {
            let fileManager = FileManager.default
            let folderURL = try fileManager.url(
                for: .applicationSupportDirectory,
                in: .userDomainMask,
                appropriateFor: nil,
                create: true
            )
            let dbURL = folderURL.appendingPathComponent(dbFileName)
            var conn: OpaquePointer?
            let flags = SQLITE_OPEN_READWRITE | SQLITE_OPEN_CREATE | SQLITE_OPEN_FULLMUTEX
            if sqlite3_open_v2(dbURL.path, &conn, flags, nil) == SQLITE_OK, let c = conn {
                self.db = c
                sqlite3_busy_timeout(c, 5000)
                execSQLSync("PRAGMA journal_mode = WAL;")
                execSQLSync("PRAGMA synchronous = NORMAL;")
                execSQLSync("""
                CREATE TABLE IF NOT EXISTS cariler (
                    uuid TEXT PRIMARY KEY,
                    id INTEGER,
                    tenant_id TEXT,
                    cari_kodu TEXT,
                    unvan TEXT,
                    cari_turu TEXT,
                    yetkili TEXT,
                    telefon TEXT,
                    gsm TEXT,
                    vergi_no TEXT,
                    is_deleted INTEGER DEFAULT 0,
                    json_data TEXT NOT NULL
                );
                CREATE INDEX IF NOT EXISTS idx_cariler_unvan ON cariler(unvan);
                CREATE INDEX IF NOT EXISTS idx_cariler_kod ON cariler(cari_kodu);
                
                CREATE TABLE IF NOT EXISTS stoklar (
                    uuid TEXT PRIMARY KEY,
                    id INTEGER,
                    tenant_id TEXT,
                    stok_kodu TEXT,
                    stok_adi TEXT,
                    barkod TEXT,
                    grup_adi TEXT,
                    mevcut_miktar REAL DEFAULT 0,
                    is_deleted INTEGER DEFAULT 0,
                    json_data TEXT NOT NULL
                );
                CREATE INDEX IF NOT EXISTS idx_stoklar_adi ON stoklar(stok_adi);
                CREATE INDEX IF NOT EXISTS idx_stoklar_kod ON stoklar(stok_kodu);
                
                CREATE TABLE IF NOT EXISTS faturalar (
                    uuid TEXT PRIMARY KEY,
                    id INTEGER,
                    tenant_id TEXT,
                    fatura_no TEXT,
                    fatura_turu TEXT,
                    cari_unvan TEXT,
                    tarih TEXT,
                    is_deleted INTEGER DEFAULT 0,
                    json_data TEXT NOT NULL
                );
                CREATE INDEX IF NOT EXISTS idx_faturalar_tarih ON faturalar(tarih);
                
                CREATE TABLE IF NOT EXISTS fatura_detaylar (
                    uuid TEXT PRIMARY KEY,
                    fatura_uuid TEXT,
                    is_deleted INTEGER DEFAULT 0,
                    json_data TEXT NOT NULL
                );
                CREATE INDEX IF NOT EXISTS idx_fatura_detaylar_fuuid ON fatura_detaylar(fatura_uuid);
                
                CREATE TABLE IF NOT EXISTS offline_queue (
                    id TEXT PRIMARY KEY,
                    endpoint TEXT NOT NULL,
                    method TEXT NOT NULL,
                    payload TEXT NOT NULL,
                    created_at TEXT NOT NULL,
                    retry_count INTEGER DEFAULT 0,
                    status TEXT DEFAULT 'pending',
                    last_error TEXT,
                    next_retry_at TEXT
                );
                CREATE INDEX IF NOT EXISTS idx_offline_queue_status_retry ON offline_queue(status, next_retry_at);
                """)
            }
        } catch {
            print("[LocalDatabaseService] Initialization error: \(error)")
        }
    }
    
    private nonisolated func execSQLSync(_ sql: String) {
        guard let db = db else { return }
        sqlite3_exec(db, sql, nil, nil, nil)
    }
    
    private nonisolated func bindText(_ stmt: OpaquePointer?, _ index: Int32, _ value: String?) {
        if let val = value {
            sqlite3_bind_text(stmt, index, (val as NSString).utf8String, -1, SQLITE_TRANSIENT)
        } else {
            sqlite3_bind_null(stmt, index)
        }
    }
    
    private nonisolated func columnString(_ stmt: OpaquePointer?, _ index: Int32) -> String? {
        guard let cStr = sqlite3_column_text(stmt, index) else { return nil }
        return String(cString: cStr)
    }
    
    // MARK: - Synchronous Cache Helpers (Nonisolated)
    public nonisolated func getCachedCariler() -> [CariKart] {
        return fetchCarilerSync()
    }
    
    public nonisolated func getCachedStoklar() -> [StokKart] {
        return fetchStoklarSync()
    }
    
    public nonisolated func getCachedFaturalar() -> [Fatura] {
        return fetchFaturalarSync()
    }
    
    public nonisolated func searchCachedCariler(query: String, limit: Int = 50) -> [CariKart] {
        return fetchCarilerSync(query: query, limit: limit)
    }
    
    private nonisolated func fetchCarilerSync(query: String? = nil, filterGrup: String? = nil, limit: Int = 5000) -> [CariKart] {
        lock.lock()
        defer { lock.unlock() }
        guard let db = db else { return [] }
        
        var sql = "SELECT json_data FROM cariler WHERE is_deleted = 0"
        var params: [String] = []
        
        if let q = query?.trimmingCharacters(in: .whitespacesAndNewlines), !q.isEmpty {
            sql += " AND (unvan LIKE ? OR cari_kodu LIKE ? OR yetkili LIKE ? OR telefon LIKE ? OR gsm LIKE ? OR vergi_no LIKE ?)"
            let p = "%\(q)%"
            params.append(contentsOf: [p, p, p, p, p, p])
        }
        if let filter = filterGrup, filter != "Tümü" {
            if filter == "Müşteri" {
                sql += " AND (cari_turu LIKE '%Müşteri%' OR cari_turu LIKE '%musteri%')"
            } else if filter == "Tedarikçi" {
                sql += " AND cari_turu LIKE '%Tedarik%'"
            }
        }
        sql += " ORDER BY unvan ASC LIMIT \(limit);"
        
        var stmt: OpaquePointer?
        var results: [CariKart] = []
        let decoder = JSONDecoder()
        if sqlite3_prepare_v2(db, sql, -1, &stmt, nil) == SQLITE_OK {
            for (idx, param) in params.enumerated() {
                bindText(stmt, Int32(idx + 1), param)
            }
            while sqlite3_step(stmt) == SQLITE_ROW {
                if let jsonStr = columnString(stmt, 0),
                   let data = jsonStr.data(using: .utf8),
                   let item = try? decoder.decode(CariKart.self, from: data) {
                    results.append(item)
                }
            }
        }
        sqlite3_finalize(stmt)
        return results
    }
    
    private nonisolated func fetchStoklarSync(query: String? = nil, onlyWithBalance: Bool = false, limit: Int = 5000) -> [StokKart] {
        lock.lock()
        defer { lock.unlock() }
        guard let db = db else { return [] }
        
        var sql = "SELECT json_data FROM stoklar WHERE is_deleted = 0"
        var params: [String] = []
        
        if let q = query?.trimmingCharacters(in: .whitespacesAndNewlines), !q.isEmpty {
            sql += " AND (stok_adi LIKE ? OR stok_kodu LIKE ? OR barkod LIKE ? OR grup_adi LIKE ?)"
            let p = "%\(q)%"
            params.append(contentsOf: [p, p, p, p])
        }
        if onlyWithBalance {
            sql += " AND mevcut_miktar > 0"
        }
        sql += " ORDER BY stok_adi ASC LIMIT \(limit);"
        
        var stmt: OpaquePointer?
        var results: [StokKart] = []
        let decoder = JSONDecoder()
        if sqlite3_prepare_v2(db, sql, -1, &stmt, nil) == SQLITE_OK {
            for (idx, param) in params.enumerated() {
                bindText(stmt, Int32(idx + 1), param)
            }
            while sqlite3_step(stmt) == SQLITE_ROW {
                if let jsonStr = columnString(stmt, 0),
                   let data = jsonStr.data(using: .utf8),
                   let item = try? decoder.decode(StokKart.self, from: data) {
                    results.append(item)
                }
            }
        }
        sqlite3_finalize(stmt)
        return results
    }
    
    private nonisolated func fetchFaturalarSync(query: String? = nil, tur: String? = nil, limit: Int = 5000) -> [Fatura] {
        lock.lock()
        defer { lock.unlock() }
        guard let db = db else { return [] }
        
        var sql = "SELECT json_data FROM faturalar WHERE is_deleted = 0"
        var params: [String] = []
        
        if let q = query?.trimmingCharacters(in: .whitespacesAndNewlines), !q.isEmpty {
            sql += " AND (fatura_no LIKE ? OR cari_unvan LIKE ?)"
            let p = "%\(q)%"
            params.append(contentsOf: [p, p])
        }
        if let t = tur, t != "Tümü" {
            sql += " AND fatura_turu LIKE ?"
            params.append("%\(t)%")
        }
        sql += " ORDER BY tarih DESC LIMIT \(limit);"
        
        var stmt: OpaquePointer?
        var results: [Fatura] = []
        let decoder = JSONDecoder()
        if sqlite3_prepare_v2(db, sql, -1, &stmt, nil) == SQLITE_OK {
            for (idx, param) in params.enumerated() {
                bindText(stmt, Int32(idx + 1), param)
            }
            while sqlite3_step(stmt) == SQLITE_ROW {
                if let jsonStr = columnString(stmt, 0),
                   let data = jsonStr.data(using: .utf8),
                   let item = try? decoder.decode(Fatura.self, from: data) {
                    results.append(item)
                }
            }
        }
        sqlite3_finalize(stmt)
        return results
    }
    
    private nonisolated func fetchPendingOfflineBlobs() -> [String] {
        guard let db = db else { return [] }
        var pendingBlobs: [String] = []
        var qStmt: OpaquePointer?
        if sqlite3_prepare_v2(db, "SELECT id, payload FROM offline_queue WHERE status != 'completed';", -1, &qStmt, nil) == SQLITE_OK {
            while sqlite3_step(qStmt) == SQLITE_ROW {
                if let idStr = columnString(qStmt, 0) { pendingBlobs.append(idStr) }
                if let payloadStr = columnString(qStmt, 1) { pendingBlobs.append(payloadStr) }
            }
        }
        sqlite3_finalize(qStmt)
        return pendingBlobs
    }

    private nonisolated func isReferencedByPendingOfflineQueue(_ key: String, pendingBlobs: [String]) -> Bool {
        guard !key.isEmpty, !pendingBlobs.isEmpty else { return false }
        return pendingBlobs.contains { blob in
            blob.localizedCaseInsensitiveContains(key)
        }
    }

    /// Removes local cache rows that no longer exist in the cloud snapshot (e.g. deleted on PC),
    /// while strictly preserving any local records referenced by pending offline_queue items.
    private nonisolated func pruneRemovedRowsPreservingOfflineQueue(table: String, incomingUuids: Set<String>, pendingBlobs: [String]) {
        guard let db = db else { return }
        let normalizedIncoming = Set(incomingUuids.map { $0.lowercased() })

        var existingUuids: [String] = []
        var sStmt: OpaquePointer?
        if sqlite3_prepare_v2(db, "SELECT uuid FROM \(table);", -1, &sStmt, nil) == SQLITE_OK {
            while sqlite3_step(sStmt) == SQLITE_ROW {
                if let u = columnString(sStmt, 0) { existingUuids.append(u) }
            }
        }
        sqlite3_finalize(sStmt)

        var delStmt: OpaquePointer?
        if sqlite3_prepare_v2(db, "DELETE FROM \(table) WHERE uuid = ?;", -1, &delStmt, nil) == SQLITE_OK {
            for existing in existingUuids {
                if normalizedIncoming.contains(existing.lowercased()) { continue }
                if isReferencedByPendingOfflineQueue(existing, pendingBlobs: pendingBlobs) { continue }
                sqlite3_reset(delStmt)
                sqlite3_clear_bindings(delStmt)
                bindText(delStmt, 1, existing)
                sqlite3_step(delStmt)
            }
        }
        sqlite3_finalize(delStmt)
    }

    // MARK: - Async CRUD: Cariler
    public func upsertCariler(_ list: [CariKart], replaceAll: Bool = false) throws {
        lock.lock()
        defer { lock.unlock() }
        guard let db = db else { return }
        let encoder = JSONEncoder()
        execSQLSync("BEGIN TRANSACTION;")
        let pendingBlobs = fetchPendingOfflineBlobs()
        if replaceAll {
            let incomingUuids = Set(list.map { ($0.syncGuid?.isEmpty == false ? $0.syncGuid! : $0.id) })
            pruneRemovedRowsPreservingOfflineQueue(table: "cariler", incomingUuids: incomingUuids, pendingBlobs: pendingBlobs)
        }
        let sql = """
        INSERT OR REPLACE INTO cariler (uuid, id, tenant_id, cari_kodu, unvan, cari_turu, yetkili, telefon, gsm, vergi_no, is_deleted, json_data)
        VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?);
        """
        var stmt: OpaquePointer?
        if sqlite3_prepare_v2(db, sql, -1, &stmt, nil) == SQLITE_OK {
            for item in list {
                let safeUuid = (item.syncGuid?.isEmpty == false ? item.syncGuid! : item.id)
                if isReferencedByPendingOfflineQueue(safeUuid, pendingBlobs: pendingBlobs) { continue }
                guard let data = try? encoder.encode(item),
                      let jsonStr = String(data: data, encoding: .utf8) else { continue }
                sqlite3_reset(stmt)
                sqlite3_clear_bindings(stmt)
                bindText(stmt, 1, safeUuid)
                if let intId = Int64(item.id) {
                    sqlite3_bind_int64(stmt, 2, intId)
                } else {
                    sqlite3_bind_null(stmt, 2)
                }
                bindText(stmt, 3, item.tenantId ?? SupabaseService.shared.tenantId)
                bindText(stmt, 4, item.cariKodu)
                bindText(stmt, 5, item.unvan)
                bindText(stmt, 6, item.cariTuru)
                bindText(stmt, 7, item.yetkili)
                bindText(stmt, 8, item.telefon)
                bindText(stmt, 9, item.gsm)
                bindText(stmt, 10, item.vergiNo)
                sqlite3_bind_int(stmt, 11, item.isDeleted ? 1 : 0)
                bindText(stmt, 12, jsonStr)
                sqlite3_step(stmt)
            }
        }
        sqlite3_finalize(stmt)
        execSQLSync("COMMIT;")
    }
    
    public func fetchCariler(query: String? = nil, filterGrup: String? = nil) throws -> [CariKart] {
        return fetchCarilerSync(query: query, filterGrup: filterGrup)
    }
    
    public func searchCariler(query: String, limit: Int = 50) throws -> [CariKart] {
        return fetchCarilerSync(query: query, limit: limit)
    }
    
    public nonisolated func markCariDeleted(uuid: String) {
        lock.lock()
        defer { lock.unlock() }
        guard let db = db else { return }
        let sql = "UPDATE cariler SET is_deleted = 1 WHERE uuid = ? OR id = ?;"
        var stmt: OpaquePointer?
        if sqlite3_prepare_v2(db, sql, -1, &stmt, nil) == SQLITE_OK {
            bindText(stmt, 1, uuid)
            bindText(stmt, 2, uuid)
            sqlite3_step(stmt)
        }
        sqlite3_finalize(stmt)
    }
    
    // MARK: - Async CRUD: Stoklar
    public func upsertStoklar(_ list: [StokKart], replaceAll: Bool = false) throws {
        lock.lock()
        defer { lock.unlock() }
        guard let db = db else { return }
        let encoder = JSONEncoder()
        execSQLSync("BEGIN TRANSACTION;")
        let pendingBlobs = fetchPendingOfflineBlobs()
        if replaceAll {
            let incomingUuids = Set(list.map { ($0.syncGuid?.isEmpty == false ? $0.syncGuid! : $0.id) })
            pruneRemovedRowsPreservingOfflineQueue(table: "stoklar", incomingUuids: incomingUuids, pendingBlobs: pendingBlobs)
        }
        let sql = """
        INSERT OR REPLACE INTO stoklar (uuid, id, tenant_id, stok_kodu, stok_adi, barkod, grup_adi, mevcut_miktar, is_deleted, json_data)
        VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?);
        """
        var stmt: OpaquePointer?
        if sqlite3_prepare_v2(db, sql, -1, &stmt, nil) == SQLITE_OK {
            for item in list {
                let safeUuid = (item.syncGuid?.isEmpty == false ? item.syncGuid! : item.id)
                if isReferencedByPendingOfflineQueue(safeUuid, pendingBlobs: pendingBlobs) { continue }
                guard let data = try? encoder.encode(item),
                      let jsonStr = String(data: data, encoding: .utf8) else { continue }
                sqlite3_reset(stmt)
                sqlite3_clear_bindings(stmt)
                bindText(stmt, 1, safeUuid)
                if let intId = Int64(item.id) {
                    sqlite3_bind_int64(stmt, 2, intId)
                } else {
                    sqlite3_bind_null(stmt, 2)
                }
                bindText(stmt, 3, item.tenantId ?? SupabaseService.shared.tenantId)
                bindText(stmt, 4, item.stokKodu)
                bindText(stmt, 5, item.stokAdi)
                bindText(stmt, 6, item.barkod)
                bindText(stmt, 7, item.grupAdi)
                sqlite3_bind_double(stmt, 8, item.mevcutMiktar)
                sqlite3_bind_int(stmt, 9, item.isDeleted ? 1 : 0)
                bindText(stmt, 10, jsonStr)
                sqlite3_step(stmt)
            }
        }
        sqlite3_finalize(stmt)
        execSQLSync("COMMIT;")
    }
    
    public func fetchStoklar(query: String? = nil, onlyWithBalance: Bool = false) throws -> [StokKart] {
        return fetchStoklarSync(query: query, onlyWithBalance: onlyWithBalance)
    }
    
    public func searchStoklar(query: String, limit: Int = 50) throws -> [StokKart] {
        return fetchStoklarSync(query: query, limit: limit)
    }
    
    public nonisolated func markStokDeleted(uuid: String) {
        lock.lock()
        defer { lock.unlock() }
        guard let db = db else { return }
        let sql = "UPDATE stoklar SET is_deleted = 1 WHERE uuid = ? OR id = ?;"
        var stmt: OpaquePointer?
        if sqlite3_prepare_v2(db, sql, -1, &stmt, nil) == SQLITE_OK {
            bindText(stmt, 1, uuid)
            bindText(stmt, 2, uuid)
            sqlite3_step(stmt)
        }
        sqlite3_finalize(stmt)
    }
    
    // MARK: - Async CRUD: Faturalar
    public func upsertFaturalar(_ list: [Fatura], replaceAll: Bool = false) throws {
        lock.lock()
        defer { lock.unlock() }
        guard let db = db else { return }
        let encoder = JSONEncoder()
        execSQLSync("BEGIN TRANSACTION;")
        let pendingBlobs = fetchPendingOfflineBlobs()
        if replaceAll {
            let incomingUuids = Set(list.map { ($0.syncGuid?.isEmpty == false ? $0.syncGuid! : $0.id) })
            pruneRemovedRowsPreservingOfflineQueue(table: "faturalar", incomingUuids: incomingUuids, pendingBlobs: pendingBlobs)
        }
        let sql = """
        INSERT OR REPLACE INTO faturalar (uuid, id, tenant_id, fatura_no, fatura_turu, cari_unvan, tarih, is_deleted, json_data)
        VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?);
        """
        var stmt: OpaquePointer?
        if sqlite3_prepare_v2(db, sql, -1, &stmt, nil) == SQLITE_OK {
            for item in list {
                let safeUuid = (item.syncGuid?.isEmpty == false ? item.syncGuid! : item.id)
                if isReferencedByPendingOfflineQueue(safeUuid, pendingBlobs: pendingBlobs) { continue }
                guard let data = try? encoder.encode(item),
                      let jsonStr = String(data: data, encoding: .utf8) else { continue }
                sqlite3_reset(stmt)
                sqlite3_clear_bindings(stmt)
                bindText(stmt, 1, safeUuid)
                if let intId = Int64(item.id) {
                    sqlite3_bind_int64(stmt, 2, intId)
                } else {
                    sqlite3_bind_null(stmt, 2)
                }
                bindText(stmt, 3, item.tenantId ?? SupabaseService.shared.tenantId)
                bindText(stmt, 4, item.faturaNo)
                bindText(stmt, 5, item.faturaTuru)
                bindText(stmt, 6, item.cariUnvan)
                bindText(stmt, 7, item.tarih)
                sqlite3_bind_int(stmt, 8, item.isDeleted ? 1 : 0)
                bindText(stmt, 9, jsonStr)
                sqlite3_step(stmt)
            }
        }
        sqlite3_finalize(stmt)
        execSQLSync("COMMIT;")
    }
    
    public func fetchFaturalar(query: String? = nil, tur: String? = nil) throws -> [Fatura] {
        return fetchFaturalarSync(query: query, tur: tur)
    }
    
    public func fetchFaturaKalemler(faturaUuid: String) throws -> [FaturaKalem] {
        lock.lock()
        defer { lock.unlock() }
        guard let db = db else { return [] }
        let sql = "SELECT json_data FROM fatura_detaylar WHERE fatura_uuid = ? AND is_deleted = 0;"
        var stmt: OpaquePointer?
        var results: [FaturaKalem] = []
        let decoder = JSONDecoder()
        if sqlite3_prepare_v2(db, sql, -1, &stmt, nil) == SQLITE_OK {
            bindText(stmt, 1, faturaUuid)
            while sqlite3_step(stmt) == SQLITE_ROW {
                if let jsonStr = columnString(stmt, 0),
                   let data = jsonStr.data(using: .utf8),
                   let item = try? decoder.decode(FaturaKalem.self, from: data) {
                    results.append(item)
                }
            }
        }
        sqlite3_finalize(stmt)
        return results
    }
    
    // MARK: - SQLite-Backed Offline Queue
    public func enqueueOfflineItem(id: String = UUID().uuidString, endpoint: String, method: String, payload: String) throws {
        lock.lock()
        defer { lock.unlock() }
        guard let db = db else { return }
        let nowStr = ISO8601DateFormatter().string(from: Date())
        let sql = """
        INSERT OR REPLACE INTO offline_queue (id, endpoint, method, payload, created_at, retry_count, status, last_error, next_retry_at)
        VALUES (?, ?, ?, ?, ?, 0, 'pending', NULL, NULL);
        """
        var stmt: OpaquePointer?
        if sqlite3_prepare_v2(db, sql, -1, &stmt, nil) == SQLITE_OK {
            bindText(stmt, 1, id)
            bindText(stmt, 2, endpoint)
            bindText(stmt, 3, method)
            bindText(stmt, 4, payload)
            bindText(stmt, 5, nowStr)
            sqlite3_step(stmt)
        }
        sqlite3_finalize(stmt)
    }
    
    public func fetchPendingOfflineItems(limit: Int = 10) throws -> [OfflineQueueItem] {
        lock.lock()
        defer { lock.unlock() }
        guard let db = db else { return [] }
        let nowStr = ISO8601DateFormatter().string(from: Date())
        let sql = """
        SELECT id, endpoint, method, payload, created_at, retry_count, status, last_error, next_retry_at
        FROM offline_queue
        WHERE status = 'pending' AND (next_retry_at IS NULL OR next_retry_at <= ?)
        ORDER BY created_at ASC
        LIMIT \(limit);
        """
        var stmt: OpaquePointer?
        var items: [OfflineQueueItem] = []
        if sqlite3_prepare_v2(db, sql, -1, &stmt, nil) == SQLITE_OK {
            bindText(stmt, 1, nowStr)
            while sqlite3_step(stmt) == SQLITE_ROW {
                let id = columnString(stmt, 0) ?? UUID().uuidString
                let endpoint = columnString(stmt, 1) ?? ""
                let method = columnString(stmt, 2) ?? "POST"
                let payload = columnString(stmt, 3) ?? "{}"
                let createdAt = columnString(stmt, 4) ?? nowStr
                let retryCount = Int(sqlite3_column_int(stmt, 5))
                let status = columnString(stmt, 6) ?? "pending"
                let lastError = columnString(stmt, 7)
                let nextRetryAt = columnString(stmt, 8)
                items.append(OfflineQueueItem(
                    id: id,
                    endpoint: endpoint,
                    method: method,
                    payload: payload,
                    createdAt: createdAt,
                    retryCount: retryCount,
                    status: status,
                    lastError: lastError,
                    nextRetryAt: nextRetryAt
                ))
            }
        }
        sqlite3_finalize(stmt)
        return items
    }
    
    public func updateOfflineItemFailure(id: String, errorDesc: String, nextRetryAt: String?, isDeadLetter: Bool) throws {
        lock.lock()
        defer { lock.unlock() }
        guard let db = db else { return }
        if isDeadLetter {
            let sql = "UPDATE offline_queue SET retry_count = 3, status = 'dead_letter', last_error = ?, next_retry_at = NULL WHERE id = ?;"
            var stmt: OpaquePointer?
            if sqlite3_prepare_v2(db, sql, -1, &stmt, nil) == SQLITE_OK {
                bindText(stmt, 1, errorDesc)
                bindText(stmt, 2, id)
                sqlite3_step(stmt)
            }
            sqlite3_finalize(stmt)
        } else {
            let sql = "UPDATE offline_queue SET retry_count = retry_count + 1, status = 'pending', last_error = ?, next_retry_at = ? WHERE id = ?;"
            var stmt: OpaquePointer?
            if sqlite3_prepare_v2(db, sql, -1, &stmt, nil) == SQLITE_OK {
                bindText(stmt, 1, errorDesc)
                bindText(stmt, 2, nextRetryAt)
                bindText(stmt, 3, id)
                sqlite3_step(stmt)
            }
            sqlite3_finalize(stmt)
        }
    }
    
    public func removeOfflineItem(id: String) throws {
        lock.lock()
        defer { lock.unlock() }
        guard let db = db else { return }
        let sql = "DELETE FROM offline_queue WHERE id = ?;"
        var stmt: OpaquePointer?
        if sqlite3_prepare_v2(db, sql, -1, &stmt, nil) == SQLITE_OK {
            bindText(stmt, 1, id)
            sqlite3_step(stmt)
        }
        sqlite3_finalize(stmt)
    }
    
    public func retryDeadLetterItem(id: String) throws {
        lock.lock()
        defer { lock.unlock() }
        guard let db = db else { return }
        let sql = "UPDATE offline_queue SET retry_count = 0, status = 'pending', last_error = NULL, next_retry_at = NULL WHERE id = ?;"
        var stmt: OpaquePointer?
        if sqlite3_prepare_v2(db, sql, -1, &stmt, nil) == SQLITE_OK {
            bindText(stmt, 1, id)
            sqlite3_step(stmt)
        }
        sqlite3_finalize(stmt)
    }
}
