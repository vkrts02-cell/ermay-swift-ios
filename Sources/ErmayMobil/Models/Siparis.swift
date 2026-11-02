import Foundation

public struct Siparis: Identifiable, Codable, Hashable {
    public var id: String
    public var siparisNo: String
    public var siparisTuru: String // "ALINAN", "VERILEN"
    public var cariId: String?
    public var cariUnvan: String?
    public var tarih: String
    public var teslimTarihi: String?
    public var araToplam: Double
    public var kdvToplami: Double
    public var iskontoToplami: Double
    public var genelToplam: Double
    public var durum: String // "BEKLIYOR", "HAZIRLANIYOR", "SEVK_EDILDI", "TAMAMLANDI", "IPTAL"
    public var aciklama: String?
    public var kalemler: [SiparisKalem]?
    public var syncGuid: String?
    public var tenantId: String?
    
    enum CodingKeys: String, CodingKey {
        case id
        case siparisNo = "siparis_no"
        case siparisTuru = "siparis_turu"
        case cariId = "cari_id"
        case cariUnvan = "cari_unvan"
        case tarih
        case teslimTarihi = "teslim_tarihi"
        case araToplam = "ara_toplam"
        case kdvToplami = "kdv_toplami"
        case iskontoToplami = "iskonto_toplami"
        case genelToplam = "genel_toplam"
        case durum
        case aciklama
        case kalemler
        case syncGuid = "sync_guid"
        case tenantId = "tenant_id"
    }
}

public struct SiparisKalem: Identifiable, Codable, Hashable {
    public var id: String
    public var siparisId: String?
    public var stokId: String?
    public var stokAdi: String
    public var miktar: Double
    public var birim: String?
    public var birimFiyat: Double
    public var kdvOrani: Double
    public var tutar: Double
    
    enum CodingKeys: String, CodingKey {
        case id
        case siparisId = "siparis_id"
        case stokId = "stok_id"
        case stokAdi = "stok_adi"
        case miktar
        case birim
        case birimFiyat = "birim_fiyat"
        case kdvOrani = "kdv_orani"
        case tutar
    }
}

