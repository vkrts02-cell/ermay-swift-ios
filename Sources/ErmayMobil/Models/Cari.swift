import Foundation

public struct CariKart: Identifiable, Codable, Hashable {
    public var id: String
    public var cariKodu: String?
    public var unvan: String
    public var cariTuru: String? // "MUSTERI", "TEDARIKCI", "DIGER"
    public var yetkili: String?
    public var grup: String?
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
        case yetkili
        case grup
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
        yetkili: String? = nil,
        telefon: String? = nil,
        sehir: String? = nil,
        bakiye: Double = 0.0,
        bakiyeTuru: String? = "A",
        cariTuru: String? = "Müşteri",
        grup: String? = "Müşteri",
        vergiDairesi: String? = nil,
        vergiNo: String? = nil,
        tcKimlikNo: String? = nil,
        gsm: String? = nil,
        email: String? = nil,
        webSitesi: String? = nil,
        adres: String? = nil,
        ilce: String? = nil,
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
        self.yetkili = yetkili
        self.telefon = telefon
        self.sehir = sehir
        self.bakiye = bakiye
        self.bakiyeTuru = bakiyeTuru
        self.cariTuru = cariTuru
        self.grup = grup
        self.vergiDairesi = vergiDairesi
        self.vergiNo = vergiNo
        self.tcKimlikNo = tcKimlikNo
        self.gsm = gsm
        self.email = email
        self.webSitesi = webSitesi
        self.adres = adres
        self.ilce = ilce
        self.riskLimiti = riskLimiti
        self.vadeGunu = vadeGunu
        self.islemTarihi = islemTarihi
        self.olusturmaTarihi = olusturmaTarihi
        self.aktif = aktif
        self.syncGuid = syncGuid
        self.tenantId = tenantId
    }
}
