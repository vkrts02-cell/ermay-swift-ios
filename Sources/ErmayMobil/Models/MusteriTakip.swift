import Foundation

public struct MusteriTakipKayit: Identifiable, Codable, Hashable {
    public var id: String
    public var cariId: String?
    public var cariUnvan: String
    public var gorusmeTarihi: String
    public var gorusmeTuru: String // "ZIYARET", "TELEFON", "ONLINE", "EPOSTA"
    public var konu: String
    public var notlar: String?
    public var sonrakiEylem: String?
    public var sonrakiEylemTarihi: String?
    public var lokasyon: String?
    public var personelAdi: String?
    public var durum: String // "PLANLANDI", "TAMAMLANDI", "IPTAL"
    public var syncGuid: String?
    public var tenantId: String?
    
    enum CodingKeys: String, CodingKey {
        case id
        case cariId = "cari_id"
        case cariUnvan = "cari_unvan"
        case gorusmeTarihi = "gorusme_tarihi"
        case gorusmeTuru = "gorusme_turu"
        case konu
        case notlar
        case sonrakiEylem = "sonraki_eylem"
        case sonrakiEylemTarihi = "sonraki_eylem_tarihi"
        case lokasyon
        case personelAdi = "personel_adi"
        case durum
        case syncGuid = "sync_guid"
        case tenantId = "tenant_id"
    }
}

