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
        grupAdi: String? = "Genel",
        birim: String? = "Adet",
        alisFiyati: Double = 0.0,
        satisFiyati: Double = 0.0,
        kdvOrani: Double = 20.0,
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
        self.grupAdi = grupAdi
        self.birim = birim
        self.alisFiyati = alisFiyati
        self.satisFiyati = satisFiyati
        self.kdvOrani = kdvOrani
        self.mevcutMiktar = mevcutMiktar
        self.kritikMiktar = kritikMiktar
        self.aciklama = aciklama
        self.aktif = aktif
        self.syncGuid = syncGuid
        self.tenantId = tenantId
    }
}

public struct StokHareket: Identifiable, Codable, Hashable {
    public var id: String
    public var stokId: String?
    public var tarih: String?
    public var islemTuru: String? // "Giriş", "Çıkış", "Sayım Fazlası", "Sayım Eksiği"
    public var belgeNo: String?
    public var miktar: Double
    public var birimFiyat: Double
    public var toplamTutar: Double
    public var aciklama: String?
    public var syncGuid: String?
    
    enum CodingKeys: String, CodingKey {
        case id
        case stokId = "stok_id"
        case tarih
        case islemTuru = "islem_turu"
        case belgeNo = "belge_no"
        case miktar
        case birimFiyat = "birim_fiyat"
        case toplamTutar = "toplam_tutar"
        case aciklama
        case syncGuid = "sync_guid"
    }
}

public struct StokGrup: Identifiable, Codable, Hashable {
    public var id: String
    public var grupAdi: String
    public var aciklama: String?
    
    enum CodingKeys: String, CodingKey {
        case id
        case grupAdi = "grup_adi"
        case aciklama
    }
    
    public init(id: String = UUID().uuidString, grupAdi: String, aciklama: String? = nil) {
        self.id = id
        self.grupAdi = grupAdi
        self.aciklama = aciklama
    }
}

