import Foundation

public struct StokKart: Identifiable, Codable, Hashable {
    public var id: String
    public var stokKodu: String?
    public var stokAdi: String
    public var barkod: String?
    public var grupAdi: String?
    public var birim: String?
    public var alisFiyati: Double
    public var satisFiyati: Double
    public var kdvOrani: Double
    public var mevcutMiktar: Double
    public var kritikMiktar: Double?
    public var aciklama: String?
    public var aktif: Bool?
    public var syncGuid: String?
    public var tenantId: String?
    
    // Compatibility properties
    public var kategori: String? {
        get { grupAdi }
        set { grupAdi = newValue }
    }
    
    public var bakiye: Double {
        get { mevcutMiktar }
        set { mevcutMiktar = newValue }
    }
    
    enum CodingKeys: String, CodingKey {
        case id
        case stokKodu = "stok_kodu"
        case stokAdi = "stok_adi"
        case barkod
        case grupAdi = "grup_adi"
        case birim
        case alisFiyati = "alis_fiyati"
        case satisFiyati = "satis_fiyati"
        case kdvOrani = "kdv_orani"
        case mevcutMiktar = "mevcut_miktar"
        case kritikMiktar = "kritik_miktar"
        case aciklama
        case aktif
        case syncGuid = "sync_guid"
        case tenantId = "tenant_id"
    }
    
    public init(
        id: String = UUID().uuidString,
        stokKodu: String? = nil,
        stokAdi: String,
        barkod: String? = nil,
        birim: String? = "Adet",
        alisFiyati: Double = 0.0,
        satisFiyati: Double = 0.0,
        kdvOrani: Double = 20.0,
        bakiye: Double = 0.0,
        kategori: String? = "Genel",
        grupAdi: String? = "Genel",
        mevcutMiktar: Double = 0.0,
        kritikMiktar: Double? = 5.0,
        aciklama: String? = nil,
        aktif: Bool? = true,
        syncGuid: String? = UUID().uuidString,
        tenantId: String? = nil
    ) {
        self.id = id
        self.stokKodu = stokKodu
        self.stokAdi = stokAdi
        self.barkod = barkod
        self.grupAdi = (kategori != "Genel") ? (kategori ?? grupAdi) : grupAdi
        self.birim = birim
        self.alisFiyati = alisFiyati
        self.satisFiyati = satisFiyati
        self.kdvOrani = kdvOrani
        self.mevcutMiktar = bakiye > 0 ? bakiye : mevcutMiktar
        self.kritikMiktar = kritikMiktar
        self.aciklama = aciklama
        self.aktif = aktif
        self.syncGuid = syncGuid
        self.tenantId = tenantId
    }
}
