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
    public var id: Int?
    public var uuid: String
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
    
    // M-02 UYUMLULUK ALIAS'LARI (PostgreSQL & Desktop Eşleştirmesi):
    public var kasaId: String? {
        get { hesapId }
        set { hesapId = newValue }
    }
    public var evrakNo: String? {
        get { belgeNo }
        set { belgeNo = newValue }
    }
    
    enum CodingKeys: String, CodingKey {
        case id
        case uuid
        case kasaId = "kasa_id"
        case evrakNo = "evrak_no"
        case hesapId = "hesap_id"
        case belgeNo = "belge_no"
        case tarih
        case islemTuru = "islem_turu"
        case cariId = "cari_id"
        case cariUnvan = "cari_unvan"
        case tutar
        case aciklama
        case syncGuid = "sync_guid"
        case tenantId = "tenant_id"
    }
    
    public init(
        id: Int? = nil,
        uuid: String = UUID().uuidString,
        hesapId: String? = nil,
        tarih: String = AppFormatters.isoDate.string(from: Date()),
        islemTuru: String = "TAHSILAT",
        cariId: String? = nil,
        cariUnvan: String? = nil,
        belgeNo: String? = nil,
        tutar: Double = 0.0,
        aciklama: String? = nil,
        syncGuid: String? = nil,
        tenantId: String? = nil
    ) {
        self.id = id
        self.uuid = uuid
        self.hesapId = hesapId
        self.tarih = tarih
        self.islemTuru = islemTuru
        self.cariId = cariId
        self.cariUnvan = cariUnvan
        self.belgeNo = belgeNo
        self.tutar = tutar
        self.aciklama = aciklama
        self.syncGuid = syncGuid ?? uuid
        self.tenantId = tenantId
    }

    public init(
        id: String,
        hesapId: String? = nil,
        tarih: String = AppFormatters.isoDate.string(from: Date()),
        islemTuru: String = "TAHSILAT",
        cariId: String? = nil,
        cariUnvan: String? = nil,
        belgeNo: String? = nil,
        tutar: Double = 0.0,
        aciklama: String? = nil,
        syncGuid: String? = nil,
        tenantId: String? = nil
    ) {
        self.id = Int(id)
        self.uuid = Int(id) == nil ? id : (syncGuid ?? UUID().uuidString)
        self.hesapId = hesapId
        self.tarih = tarih
        self.islemTuru = islemTuru
        self.cariId = cariId
        self.cariUnvan = cariUnvan
        self.belgeNo = belgeNo
        self.tutar = tutar
        self.aciklama = aciklama
        self.syncGuid = syncGuid ?? self.uuid
        self.tenantId = tenantId
    }

    public init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        if let intId = try? c.decode(Int.self, forKey: .id) {
            self.id = intId
        } else if let strId = try? c.decode(String.self, forKey: .id), let intVal = Int(strId) {
            self.id = intVal
        } else {
            self.id = nil
        }
        self.uuid = (try? c.decode(String.self, forKey: .uuid)) ?? (try? c.decode(String.self, forKey: .syncGuid)) ?? UUID().uuidString
        if let kId = try? c.decode(String.self, forKey: .kasaId) {
            self.hesapId = kId
        } else if let kIntId = try? c.decode(Int.self, forKey: .kasaId) {
            self.hesapId = String(kIntId)
        } else {
            self.hesapId = try? c.decode(String.self, forKey: .hesapId)
        }
        self.tarih = (try? c.decode(String.self, forKey: .tarih)) ?? AppFormatters.isoDate.string(from: Date())
        self.islemTuru = (try? c.decode(String.self, forKey: .islemTuru)) ?? "TAHSILAT"
        self.cariId = try? c.decode(String.self, forKey: .cariId)
        self.cariUnvan = try? c.decode(String.self, forKey: .cariUnvan)
        self.belgeNo = (try? c.decode(String.self, forKey: .evrakNo)) ?? (try? c.decode(String.self, forKey: .belgeNo))
        self.tutar = (try? c.decode(Double.self, forKey: .tutar)) ?? 0.0
        self.aciklama = try? c.decode(String.self, forKey: .aciklama)
        self.syncGuid = (try? c.decode(String.self, forKey: .syncGuid)) ?? self.uuid
        self.tenantId = try? c.decode(String.self, forKey: .tenantId)
    }

    public func encode(to encoder: Encoder) throws {
        var c = encoder.container(keyedBy: CodingKeys.self)
        if let intId = self.id, intId > 0 {
            try c.encode(intId, forKey: .id)
        }
        try c.encode(uuid, forKey: .uuid)
        if let kid = hesapId {
            if let intKid = Int(kid) {
                try c.encode(intKid, forKey: .kasaId)
            } else {
                try c.encode(kid, forKey: .kasaId)
            }
        }
        try c.encode(tarih, forKey: .tarih)
        try c.encode(islemTuru, forKey: .islemTuru)
        try c.encodeIfPresent(cariId, forKey: .cariId)
        try c.encodeIfPresent(cariUnvan, forKey: .cariUnvan)
        try c.encodeIfPresent(belgeNo, forKey: .evrakNo)
        try c.encode(tutar, forKey: .tutar)
        try c.encodeIfPresent(aciklama, forKey: .aciklama)
        try c.encode(syncGuid ?? uuid, forKey: .syncGuid)
        try c.encodeIfPresent(tenantId ?? SupabaseService.shared.tenantId, forKey: .tenantId)
    }
}

