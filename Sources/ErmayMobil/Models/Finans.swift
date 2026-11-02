import Foundation

public struct KasaBanka: Identifiable, Codable, Hashable {
    public var id: String
    public var hesapAdi: String
    public var hesapTuru: String // "KASA", "BANKA", "POS"
    public var bankaAdi: String?
    public var subeAdi: String?
    public var hesapNo: String?
    public var iban: String?
    public var dovizCinsi: String?
    public var bakiye: Double
    public var syncGuid: String?
    public var tenantId: String?
    
    enum CodingKeys: String, CodingKey {
        case id
        case hesapAdi = "hesap_adi"
        case hesapTuru = "hesap_turu"
        case bankaAdi = "banka_adi"
        case subeAdi = "sube_adi"
        case hesapNo = "hesap_no"
        case iban
        case dovizCinsi = "doviz_cinsi"
        case bakiye
        case syncGuid = "sync_guid"
        case tenantId = "tenant_id"
    }
    
    public init(
        id: String = UUID().uuidString,
        hesapAdi: String,
        hesapTuru: String = "KASA",
        bankaAdi: String? = nil,
        subeAdi: String? = nil,
        hesapNo: String? = nil,
        iban: String? = nil,
        dovizCinsi: String? = "TRY",
        bakiye: Double = 0.0,
        syncGuid: String? = UUID().uuidString,
        tenantId: String? = nil
    ) {
        self.id = id
        self.hesapAdi = hesapAdi
        self.hesapTuru = hesapTuru
        self.bankaAdi = bankaAdi
        self.subeAdi = subeAdi
        self.hesapNo = hesapNo
        self.iban = iban
        self.dovizCinsi = dovizCinsi
        self.bakiye = bakiye
        self.syncGuid = syncGuid
        self.tenantId = tenantId
    }
}

public struct KasaHareket: Identifiable, Codable, Hashable {
    public var id: String
    public var hesapId: String?
    public var tarih: String
    public var islemTuru: String // "TAHSILAT", "TEDIYE", "VIRMAN"
    public var cariId: String?
    public var cariUnvan: String?
    public var belgeNo: String?
    public var tutar: Double
    public var aciklama: String?
    public var syncGuid: String?
    public var tenantId: String?
    
    enum CodingKeys: String, CodingKey {
        case id
        case hesapId = "hesap_id"
        case tarih
        case islemTuru = "islem_turu"
        case cariId = "cari_id"
        case cariUnvan = "cari_unvan"
        case belgeNo = "belge_no"
        case tutar
        case aciklama
        case syncGuid = "sync_guid"
        case tenantId = "tenant_id"
    }
    
    public init(
        id: String = UUID().uuidString,
        hesapId: String? = nil,
        tarih: String = AppFormatters.isoDate.string(from: Date()),
        islemTuru: String = "TAHSILAT",
        cariId: String? = nil,
        cariUnvan: String? = nil,
        belgeNo: String? = nil,
        tutar: Double = 0.0,
        aciklama: String? = nil,
        syncGuid: String? = UUID().uuidString,
        tenantId: String? = nil
    ) {
        self.id = id
        self.hesapId = hesapId
        self.tarih = tarih
        self.islemTuru = islemTuru
        self.cariId = cariId
        self.cariUnvan = cariUnvan
        self.belgeNo = belgeNo
        self.tutar = tutar
        self.aciklama = aciklama
        self.syncGuid = syncGuid
        self.tenantId = tenantId
    }
}

