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
    
    public init(
        id: String = UUID().uuidString,
        siparisNo: String = "",
        siparisTuru: String = "ALINAN",
        cariId: String? = nil,
        cariUnvan: String? = nil,
        tarih: String = AppFormatters.isoDate.string(from: Date()),
        teslimTarihi: String? = nil,
        araToplam: Double = 0.0,
        kdvToplami: Double = 0.0,
        iskontoToplami: Double = 0.0,
        genelToplam: Double = 0.0,
        durum: String = "BEKLIYOR",
        aciklama: String? = nil,
        kalemler: [SiparisKalem]? = nil,
        syncGuid: String? = nil,
        tenantId: String? = nil
    ) {
        self.id = id
        self.siparisNo = siparisNo
        self.siparisTuru = siparisTuru
        self.cariId = cariId
        self.cariUnvan = cariUnvan
        self.tarih = tarih
        self.teslimTarihi = teslimTarihi
        self.araToplam = araToplam
        self.kdvToplami = kdvToplami
        self.iskontoToplami = iskontoToplami
        self.genelToplam = genelToplam
        self.durum = durum
        self.aciklama = aciklama
        self.kalemler = kalemler
        self.syncGuid = syncGuid
        self.tenantId = tenantId
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
    public var aciklama: String?
    
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
        case aciklama
    }
    
    public init(
        id: String = UUID().uuidString,
        siparisId: String? = nil,
        stokId: String? = nil,
        stokAdi: String,
        miktar: Double = 1.0,
        birim: String? = "Adet",
        birimFiyat: Double = 0.0,
        kdvOrani: Double = 20.0,
        tutar: Double = 0.0,
        aciklama: String? = nil
    ) {
        self.id = id
        self.siparisId = siparisId
        self.stokId = stokId
        self.stokAdi = stokAdi
        self.miktar = miktar
        self.birim = birim
        self.birimFiyat = birimFiyat
        self.kdvOrani = kdvOrani
        self.tutar = tutar
        self.aciklama = aciklama
    }
}
