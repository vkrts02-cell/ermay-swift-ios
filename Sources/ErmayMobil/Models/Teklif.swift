import Foundation

public struct Teklif: Identifiable, Codable, Hashable {
    public var id: String
    public var teklifNo: String
    public var cariId: String?
    public var cariUnvan: String?
    public var tarih: String
    public var gecerlilikTarihi: String?
    public var araToplam: Double
    public var kdvToplami: Double
    public var genelToplam: Double
    public var durum: String // "TASLAK", "GONDERILDI", "ONAYLANDI", "REDDEDILDI"
    public var aciklama: String?
    public var kalemler: [TeklifKalem]?
    public var syncGuid: String?
    public var tenantId: String?
    
    enum CodingKeys: String, CodingKey {
        case id
        case teklifNo = "teklif_no"
        case cariId = "cari_id"
        case cariUnvan = "cari_unvan"
        case tarih
        case gecerlilikTarihi = "gecerlilik_tarihi"
        case araToplam = "ara_toplam"
        case kdvToplami = "kdv_toplami"
        case genelToplam = "genel_toplam"
        case durum
        case aciklama
        case kalemler
        case syncGuid = "sync_guid"
        case tenantId = "tenant_id"
    }
}

public struct TeklifKalem: Identifiable, Codable, Hashable {
    public var id: String
    public var teklifId: String?
    public var stokId: String?
    public var stokAdi: String
    public var miktar: Double
    public var birim: String?
    public var birimFiyat: Double
    public var kdvOrani: Double
    public var tutar: Double
    
    enum CodingKeys: String, CodingKey {
        case id
        case teklifId = "teklif_id"
        case stokId = "stok_id"
        case stokAdi = "stok_adi"
        case miktar
        case birim
        case birimFiyat = "birim_fiyat"
        case kdvOrani = "kdv_orani"
        case tutar
    }
}

