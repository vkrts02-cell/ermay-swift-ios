import Foundation

public struct CariKart: Identifiable, Codable, Hashable {
    public var id: String
    public var cariKodu: String?
    public var unvan: String
    public var cariTuru: String? // "MUSTERI", "TEDARIKCI", "DIGER"
    public var vergiDairesi: String?
    public var vergiNo: String?
    public var tcKimlikNo: String?
    public var telefon: String?
    public var gsm: String?
    public var email: String?
    public var webSitesi: String?
    public var adres: String?
    public var sehir: String?
    public var ilce: String?
    public var bakiye: Double
    public var bakiyeTuru: String? // "B" (Borçlu) veya "A" (Alacaklı)
    public var riskLimiti: Double?
    public var vadeGunu: Int?
    public var islemTarihi: String?
    public var olusturmaTarihi: String?
    public var aktif: Bool?
    public var syncGuid: String?
    public var tenantId: String?
    
    enum CodingKeys: String, CodingKey {
        case id
        case cariKodu = "cari_kodu"
        case unvan
        case cariTuru = "cari_turu"
        case vergiDairesi = "vergi_dairesi"
        case vergiNo = "vergi_no"
        case tcKimlikNo = "tc_kimlik_no"
        case telefon
        case gsm
        case email
        case webSitesi = "web_sitesi"
        case adres
        case sehir
        case ilce
        case bakiye
        case bakiyeTuru = "bakiye_turu"
        case riskLimiti = "risk_limiti"
        case vadeGunu = "vade_gunu"
        case islemTarihi = "islem_tarihi"
        case olusturmaTarihi = "olusturma_tarihi"
        case aktif
        case syncGuid = "sync_guid"
        case tenantId = "tenant_id"
    }
    
    public init(
        id: String = UUID().uuidString,
        cariKodu: String? = nil,
        unvan: String,
        cariTuru: String? = "Müşteri",
        vergiDairesi: String? = nil,
        vergiNo: String? = nil,
        tcKimlikNo: String? = nil,
        telefon: String? = nil,
        gsm: String? = nil,
        email: String? = nil,
        webSitesi: String? = nil,
        adres: String? = nil,
        sehir: String? = nil,
        ilce: String? = nil,
        bakiye: Double = 0.0,
        bakiyeTuru: String? = "A",
        riskLimiti: Double? = nil,
        vadeGunu: Int? = 30,
        islemTarihi: String? = nil,
        olusturmaTarihi: String? = nil,
        aktif: Bool? = true,
        syncGuid: String? = UUID().uuidString,
        tenantId: String? = nil
    ) {
        self.id = id
        self.cariKodu = cariKodu
        self.unvan = unvan
        self.cariTuru = cariTuru
        self.vergiDairesi = vergiDairesi
        self.vergiNo = vergiNo
        self.tcKimlikNo = tcKimlikNo
        self.telefon = telefon
        self.gsm = gsm
        self.email = email
        self.webSitesi = webSitesi
        self.adres = adres
        self.sehir = sehir
        self.ilce = ilce
        self.bakiye = bakiye
        self.bakiyeTuru = bakiyeTuru
        self.riskLimiti = riskLimiti
        self.vadeGunu = vadeGunu
        self.islemTarihi = islemTarihi
        self.olusturmaTarihi = olusturmaTarihi
        self.aktif = aktif
        self.syncGuid = syncGuid
        self.tenantId = tenantId
    }
}

public struct CariHareket: Identifiable, Codable, Hashable {
    public var id: String
    public var cariId: String?
    public var tarih: String?
    public var belgeNo: String?
    public var islemTuru: String? // "Fatura", "Tahsilat", "Tediye", "Devir"
    public var aciklama: String?
    public var borc: Double
    public var alacak: Double
    public var bakiye: Double
    public var syncGuid: String?
    
    enum CodingKeys: String, CodingKey {
        case id
        case cariId = "cari_id"
        case tarih
        case belgeNo = "belge_no"
        case islemTuru = "islem_turu"
        case aciklama
        case borc
        case alacak
        case bakiye
        case syncGuid = "sync_guid"
    }
    
    public init(
        id: String = UUID().uuidString,
        cariId: String? = nil,
        tarih: String? = nil,
        belgeNo: String? = nil,
        islemTuru: String? = nil,
        aciklama: String? = nil,
        borc: Double = 0.0,
        alacak: Double = 0.0,
        bakiye: Double = 0.0,
        syncGuid: String? = UUID().uuidString
    ) {
        self.id = id
        self.cariId = cariId
        self.tarih = tarih
        self.belgeNo = belgeNo
        self.islemTuru = islemTuru
        self.aciklama = aciklama
        self.borc = borc
        self.alacak = alacak
        self.bakiye = bakiye
        self.syncGuid = syncGuid
    }
}

