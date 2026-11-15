import Foundation

public final class IdGenerator: @unchecked Sendable {
    private static let appEpochOffset: Int64 = 1704067200 // 1 Ocak 2024 UTC
    private static let mobileIdBase: Int = 1_000_000_000 // 1 Milyar havuzu (Masaüstü SQLite 1..500M ile asla çakışmaz)
    private static let maxSafeInt32: Int = 1_499_999_999
    
    private static var lastGeneratedId: Int = 1_000_000_000
    private static let lock = NSLock()
    
    /// Signed 32-bit integer güvenli pozitif mobil kayıt ID üreticisi (Eski yöntem - PostgreSQL sequence ve UUID tercih edilmelidir)
    @available(*, deprecated, message: "Standardize on PostgreSQL sequences and UUIDv4")
    public static func generateMobileRecordId() -> Int {
        lock.lock()
        defer { lock.unlock() }
        
        let now = Int64(Date().timeIntervalSince1970)
        let delta = max(0, Int(now - appEpochOffset))
        var newId = mobileIdBase + delta
        
        if newId <= lastGeneratedId {
            newId = lastGeneratedId + 1
        }
        
        if newId >= maxSafeInt32 {
            newId = mobileIdBase
        }
        
        lastGeneratedId = newId
        return newId
    }

    /// Çakışmasız dağıtık kayıt tanımlayıcısı üretir (UUIDv4)
    public static func generateRecordUuid() -> String {
        return UUID().uuidString
    }
}

