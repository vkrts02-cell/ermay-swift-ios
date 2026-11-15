import Foundation

public struct BankaKart: Identifiable, Codable, Sendable {
    public var id: Int?
    public var uuid: String
    public var bankaAdi: String
    public var subeAdi: String?
    public var subeKodu: String?
    public var hesapNo: String?
    public var iban: String?
    public var dovizTuru: String? // "TL", "USD", "EUR"
    public var yetkili: String?
    public var telefon: String?
    public var bakiye: Double
    
    public init(
        id: Int? = nil,
        uuid: String = UUID().uuidString,
        bankaAdi: String,
        subeAdi: String? = nil,
        subeKodu: String? = nil,
        hesapNo: String? = nil,
        iban: String? = nil,
        dovizTuru: String? = "TL",
        yetkili: String? = nil,
        telefon: String? = nil,
        bakiye: Double = 0.0
    ) {
        self.id = id
        self.uuid = uuid
        self.bankaAdi = bankaAdi
        self.subeAdi = subeAdi
        self.subeKodu = subeKodu
        self.hesapNo = hesapNo
        self.iban = iban
        self.dovizTuru = dovizTuru
        self.yetkili = yetkili
        self.telefon = telefon
        self.bakiye = bakiye
    }

    public init(
        id: String,
        bankaAdi: String,
        subeAdi: String? = nil,
        subeKodu: String? = nil,
        hesapNo: String? = nil,
        iban: String? = nil,
        dovizTuru: String? = "TL",
        yetkili: String? = nil,
        telefon: String? = nil,
        bakiye: Double = 0.0
    ) {
        self.id = Int(id)
        self.uuid = Int(id) == nil ? id : UUID().uuidString
        self.bankaAdi = bankaAdi
        self.subeAdi = subeAdi
        self.subeKodu = subeKodu
        self.hesapNo = hesapNo
        self.iban = iban
        self.dovizTuru = dovizTuru
        self.yetkili = yetkili
        self.telefon = telefon
        self.bakiye = bakiye
    }
    
    enum CodingKeys: String, CodingKey {
        case id
        case uuid
        case bankaAdi = "banka_adi"
        case subeAdi = "sube_adi"
        case subeKodu = "sube_kodu"
        case hesapNo = "hesap_no"
        case iban
        case dovizTuru = "doviz_turu"
        case yetkili
        case telefon
        case bakiye
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
        self.uuid = (try? c.decode(String.self, forKey: .uuid)) ?? UUID().uuidString
        self.bankaAdi = (try? c.decode(String.self, forKey: .bankaAdi)) ?? ""
        self.subeAdi = try? c.decode(String.self, forKey: .subeAdi)
        self.subeKodu = try? c.decode(String.self, forKey: .subeKodu)
        self.hesapNo = try? c.decode(String.self, forKey: .hesapNo)
        self.iban = try? c.decode(String.self, forKey: .iban)
        self.dovizTuru = try? c.decode(String.self, forKey: .dovizTuru)
        self.yetkili = try? c.decode(String.self, forKey: .yetkili)
        self.telefon = try? c.decode(String.self, forKey: .telefon)
        self.bakiye = (try? c.decode(Double.self, forKey: .bakiye)) ?? 0.0
    }

    public func encode(to encoder: Encoder) throws {
        var c = encoder.container(keyedBy: CodingKeys.self)
        if let intId = self.id, intId > 0 {
            try c.encode(intId, forKey: .id)
        }
        try c.encode(uuid, forKey: .uuid)
        try c.encode(bankaAdi, forKey: .bankaAdi)
        try c.encodeIfPresent(subeAdi, forKey: .subeAdi)
        try c.encodeIfPresent(subeKodu, forKey: .subeKodu)
        try c.encodeIfPresent(hesapNo, forKey: .hesapNo)
        try c.encodeIfPresent(iban, forKey: .iban)
        try c.encodeIfPresent(dovizTuru, forKey: .dovizTuru)
        try c.encodeIfPresent(yetkili, forKey: .yetkili)
        try c.encodeIfPresent(telefon, forKey: .telefon)
        try c.encode(bakiye, forKey: .bakiye)
    }
}

public struct BankaHareket: Identifiable, Codable, Sendable {
    public var id: Int?
    public var uuid: String
    public var bankaId: String?
    public var bankaAdi: String?
    public var iban: String?
    public var tarih: String
    public var evrakNo: String?
    public var islemTuru: String // "GELEN_HAVALE", "GONDERILEN_EFT", "POS_TAHSILAT", "MASRAF"
    public var aciklama: String?
    public var cariUnvan: String?
    public var tutar: Double
    public var girisCikis: String // "GIRIS", "CIKIS"
    
    public init(
        id: Int? = nil,
        uuid: String = UUID().uuidString,
        bankaId: String? = nil,
        bankaAdi: String? = nil,
        iban: String? = nil,
        tarih: String,
        evrakNo: String? = nil,
        islemTuru: String,
        aciklama: String? = nil,
        cariUnvan: String? = nil,
        tutar: Double,
        girisCikis: String = "GIRIS"
    ) {
        self.id = id
        self.uuid = uuid
        self.bankaId = bankaId
        self.bankaAdi = bankaAdi
        self.iban = iban
        self.tarih = tarih
        self.evrakNo = evrakNo
        self.islemTuru = islemTuru
        self.aciklama = aciklama
        self.cariUnvan = cariUnvan
        self.tutar = tutar
        self.girisCikis = girisCikis
    }

    public init(
        id: String,
        bankaId: String? = nil,
        bankaAdi: String? = nil,
        iban: String? = nil,
        tarih: String,
        evrakNo: String? = nil,
        islemTuru: String,
        aciklama: String? = nil,
        cariUnvan: String? = nil,
        tutar: Double,
        girisCikis: String = "GIRIS"
    ) {
        self.id = Int(id)
        self.uuid = Int(id) == nil ? id : UUID().uuidString
        self.bankaId = bankaId
        self.bankaAdi = bankaAdi
        self.iban = iban
        self.tarih = tarih
        self.evrakNo = evrakNo
        self.islemTuru = islemTuru
        self.aciklama = aciklama
        self.cariUnvan = cariUnvan
        self.tutar = tutar
        self.girisCikis = girisCikis
    }
    
    enum CodingKeys: String, CodingKey {
        case id
        case uuid
        case bankaId = "banka_id"
        case bankaAdi = "banka_adi"
        case iban
        case tarih
        case evrakNo = "evrak_no"
        case islemTuru = "islem_turu"
        case aciklama
        case cariUnvan = "cari_unvan"
        case tutar
        case girisCikis = "giris_cikis"
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
        self.uuid = (try? c.decode(String.self, forKey: .uuid)) ?? UUID().uuidString
        self.bankaId = try? c.decode(String.self, forKey: .bankaId)
        self.bankaAdi = try? c.decode(String.self, forKey: .bankaAdi)
        self.iban = try? c.decode(String.self, forKey: .iban)
        self.tarih = (try? c.decode(String.self, forKey: .tarih)) ?? ""
        self.evrakNo = try? c.decode(String.self, forKey: .evrakNo)
        self.islemTuru = (try? c.decode(String.self, forKey: .islemTuru)) ?? ""
        self.aciklama = try? c.decode(String.self, forKey: .aciklama)
        self.cariUnvan = try? c.decode(String.self, forKey: .cariUnvan)
        self.tutar = (try? c.decode(Double.self, forKey: .tutar)) ?? 0.0
        self.girisCikis = (try? c.decode(String.self, forKey: .girisCikis)) ?? "GIRIS"
    }

    public func encode(to encoder: Encoder) throws {
        var c = encoder.container(keyedBy: CodingKeys.self)
        if let intId = self.id, intId > 0 {
            try c.encode(intId, forKey: .id)
        }
        try c.encode(uuid, forKey: .uuid)
        try c.encodeIfPresent(bankaId, forKey: .bankaId)
        try c.encodeIfPresent(bankaAdi, forKey: .bankaAdi)
        try c.encodeIfPresent(iban, forKey: .iban)
        try c.encode(tarih, forKey: .tarih)
        try c.encodeIfPresent(evrakNo, forKey: .evrakNo)
        try c.encode(islemTuru, forKey: .islemTuru)
        try c.encodeIfPresent(aciklama, forKey: .aciklama)
        try c.encodeIfPresent(cariUnvan, forKey: .cariUnvan)
        try c.encode(tutar, forKey: .tutar)
        try c.encode(girisCikis, forKey: .girisCikis)
    }
}

public struct EftIslem: Identifiable, Codable, Sendable {
    public var id: String
    public var gonderenBankaId: String?
    public var aliciIban: String
    public var aliciUnvan: String
    public var tutar: Double
    public var tarih: String
    public var aciklama: String?
    public var durum: String // "BEKLIYOR", "TAMAMLANDI", "IPTAL"
    
    public init(
        id: String = UUID().uuidString,
        gonderenBankaId: String? = nil,
        aliciIban: String,
        aliciUnvan: String,
        tutar: Double,
        tarih: String,
        aciklama: String? = nil,
        durum: String = "TAMAMLANDI"
    ) {
        self.id = id
        self.gonderenBankaId = gonderenBankaId
        self.aliciIban = aliciIban
        self.aliciUnvan = aliciUnvan
        self.tutar = tutar
        self.tarih = tarih
        self.aciklama = aciklama
        self.durum = durum
    }
    
    enum CodingKeys: String, CodingKey {
        case id
        case gonderenBankaId = "gonderen_banka_id"
        case aliciIban = "alici_iban"
        case aliciUnvan = "alici_unvan"
        case tutar
        case tarih
        case aciklama
        case durum
    }
}

