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
    
    public init(
        id: String = UUID().uuidString,
        teklifNo: String = "",
        cariId: String? = nil,
        cariUnvan: String? = nil,
        tarih: String = AppFormatters.isoDate.string(from: Date()),
        gecerlilikTarihi: String? = nil,
        araToplam: Double = 0.0,
        kdvToplami: Double = 0.0,
        genelToplam: Double = 0.0,
        durum: String = "TASLAK",
        aciklama: String? = nil,
        kalemler: [TeklifKalem]? = nil,
        syncGuid: String? = nil,
        tenantId: String? = nil
    ) {
        self.id = id
        self.teklifNo = teklifNo
        self.cariId = cariId
        self.cariUnvan = cariUnvan
        self.tarih = tarih
        self.gecerlilikTarihi = gecerlilikTarihi
        self.araToplam = araToplam
        self.kdvToplami = kdvToplami
        self.genelToplam = genelToplam
        self.durum = durum
        self.aciklama = aciklama
        self.kalemler = kalemler
        self.syncGuid = syncGuid
        self.tenantId = tenantId
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
    public var aciklama: String?
    
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
        case aciklama
    }
    
    public init(
        id: String = UUID().uuidString,
        teklifId: String? = nil,
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
        self.teklifId = teklifId
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
