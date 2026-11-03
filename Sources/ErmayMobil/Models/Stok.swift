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
        grupAdi: String? = "Genel",
        birim: String? = "Adet",
        alisFiyati: Double = 0.0,
        satisFiyati: Double = 0.0,
        kdvOrani: Double = 20.0,
        bakiye: Double = 0.0,
        kategori: String? = "Genel",
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

    public init(
        id: String = UUID().uuidString,
        stokKodu: String? = nil,
        stokAdi: String,
        barkod: String? = nil,
        birim: String? = "Adet",
        grupAdi: String? = "Genel",
        alisFiyati: Double = 0.0,
        satisFiyati: Double = 0.0,
        kdvOrani: Double = 20.0,
        bakiye: Double = 0.0,
        kategori: String? = "Genel",
        mevcutMiktar: Double = 0.0,
        kritikMiktar: Double? = 5.0,
        aciklama: String? = nil,
        aktif: Bool? = true,
        syncGuid: String? = UUID().uuidString,
        tenantId: String? = nil
    ) {
        self.init(id: id, stokKodu: stokKodu, stokAdi: stokAdi, barkod: barkod, grupAdi: grupAdi, birim: birim, alisFiyati: alisFiyati, satisFiyati: satisFiyati, kdvOrani: kdvOrani, bakiye: bakiye, kategori: kategori, mevcutMiktar: mevcutMiktar, kritikMiktar: kritikMiktar, aciklama: aciklama, aktif: aktif, syncGuid: syncGuid, tenantId: tenantId)
    }
}

public struct StokMiktarUpdate: Codable {
    public var mevcut_miktar: Double
    public init(mevcutMiktar: Double) {
        self.mevcut_miktar = mevcutMiktar
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
    
    public init(
        id: String = UUID().uuidString,
        stokId: String? = nil,
        tarih: String? = nil,
        belgeNo: String? = nil,
        islemTuru: String? = nil,
        miktar: Double = 0.0,
        birimFiyat: Double = 0.0,
        toplamTutar: Double = 0.0,
        aciklama: String? = nil,
        syncGuid: String? = UUID().uuidString
    ) {
        self.id = id
        self.stokId = stokId
        self.tarih = tarih
        self.belgeNo = belgeNo
        self.islemTuru = islemTuru
        self.miktar = miktar
        self.birimFiyat = birimFiyat
        self.toplamTutar = toplamTutar
        self.aciklama = aciklama
        self.syncGuid = syncGuid
    }

    public init(
        id: String = UUID().uuidString,
        stokId: String? = nil,
        tarih: String? = nil,
        islemTuru: String? = nil,
        belgeNo: String? = nil,
        miktar: Double = 0.0,
        birimFiyat: Double = 0.0,
        toplamTutar: Double = 0.0,
        aciklama: String? = nil,
        syncGuid: String? = UUID().uuidString
    ) {
        self.init(id: id, stokId: stokId, tarih: tarih, belgeNo: belgeNo, islemTuru: islemTuru, miktar: miktar, birimFiyat: birimFiyat, toplamTutar: toplamTutar, aciklama: aciklama, syncGuid: syncGuid)
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

