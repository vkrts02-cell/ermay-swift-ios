import Foundation

public struct BankaKart: Identifiable, Codable, Sendable {
    public var id: String
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
        id: String = UUID().uuidString,
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
}

public struct BankaHareket: Identifiable, Codable, Sendable {
    public var id: String
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
        id: String = UUID().uuidString,
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

