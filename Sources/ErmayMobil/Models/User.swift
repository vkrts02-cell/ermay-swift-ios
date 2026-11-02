import Foundation

public struct User: Identifiable, Codable {
    public var id: String
    public var email: String?
    public var username: String
    public var fullName: String?
    public var role: String // "Admin", "Muhasebe", "Satis", "Kullanici"
    public var tenantId: String
    public var token: String?
    
    public init(
        id: String = UUID().uuidString,
        email: String? = nil,
        username: String,
        fullName: String? = nil,
        role: String = "Admin",
        tenantId: String = "tenant_vkrts1992_gmail_com",
        token: String? = nil
    ) {
        self.id = id
        self.email = email
        self.username = username
        self.fullName = fullName
        self.role = role
        self.tenantId = tenantId
        self.token = token
    }
}

public struct FirmaProfili: Codable {
    public var firmaAdi: String
    public var unvan: String
    public var vergiDairesi: String?
    public var vergiNo: String?
    public var telefon: String?
    public var email: String?
    public var web: String?
    public var adres: String?
    public var sehir: String?
    public var logoData: String? // Base64
    
    public static let varsayilan = FirmaProfili(
        firmaAdi: "ERMAY MUHASEBE",
        unvan: "ERMAY BİLİŞİM VE TİCARET LTD. ŞTİ.",
        vergiDairesi: "Büyükçekmece",
        vergiNo: "1234567890",
        telefon: "+90 555 000 0000",
        email: "info@ermay.com",
        web: "www.ermay.com",
        adres: "İstanbul / Türkiye",
        sehir: "İstanbul"
    )
}

