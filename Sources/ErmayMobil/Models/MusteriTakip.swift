import Foundation

public struct MusteriTakipKlasor: Identifiable, Codable, Hashable {
    public var id: Int
    public var tenantId: String?
    public var cariId: Int
    public var cariUnvan: String
    public var cariKod: String?
    public var telefon: String?
    public var yetkili: String?
    public var etiket: String?
    public var renk: String?
    public var olusturmaTarihi: String
    public var sonIslemTarihi: String
    public var aciklama: String?
    public var isDeleted: Bool?
    
    enum CodingKeys: String, CodingKey {
        case id
        case tenantId = "tenant_id"
        case cariId = "cari_id"
        case cariUnvan = "cari_unvan"
        case cariKod = "cari_kod"
        case telefon
        case yetkili
        case etiket
        case renk
        case olusturmaTarihi = "olusturma_tarihi"
        case sonIslemTarihi = "son_islem_tarihi"
        case aciklama
        case isDeleted = "is_deleted"
    }
    
    public init(
        id: Int,
        tenantId: String? = nil,
        cariId: Int,
        cariUnvan: String,
        cariKod: String? = nil,
        telefon: String? = nil,
        yetkili: String? = nil,
        etiket: String? = "Yeni İletişim",
        renk: String? = "#0A84FF",
        olusturmaTarihi: String = ISO8601DateFormatter().string(from: Date()),
        sonIslemTarihi: String = ISO8601DateFormatter().string(from: Date()),
        aciklama: String? = nil,
        isDeleted: Bool? = false
    ) {
        self.id = id
        self.tenantId = tenantId
        self.cariId = cariId
        self.cariUnvan = cariUnvan
        self.cariKod = cariKod
        self.telefon = telefon
        self.yetkili = yetkili
        self.etiket = etiket
        self.renk = renk
        self.olusturmaTarihi = olusturmaTarihi
        self.sonIslemTarihi = sonIslemTarihi
        self.aciklama = aciklama
        self.isDeleted = isDeleted
    }
}

public struct MusteriTakipDetay: Identifiable, Codable, Hashable {
    public var id: Int
    public var tenantId: String?
    public var klasorId: Int
    public var cariId: Int
    public var baslik: String
    public var icerik: String?
    public var tip: String // "Gorusme" | "Fiyat" | "Gorsel" | "Not"
    public var fiyatBilgisi: Double?
    public var paraBirimi: String?
    public var dosyaYolu: String?
    public var gorselBase64: String?
    public var tarih: String
    public var isDeleted: Bool?
    
    enum CodingKeys: String, CodingKey {
        case id
        case tenantId = "tenant_id"
        case klasorId = "klasor_id"
        case cariId = "cari_id"
        case baslik
        case icerik
        case tip
        case fiyatBilgisi = "fiyat_bilgisi"
        case paraBirimi = "para_birimi"
        case dosyaYolu = "dosya_yolu"
        case gorselBase64 = "gorsel_base64"
        case tarih
        case isDeleted = "is_deleted"
    }
    
    public init(
        id: Int,
        tenantId: String? = nil,
        klasorId: Int,
        cariId: Int,
        baslik: String,
        icerik: String? = nil,
        tip: String,
        fiyatBilgisi: Double? = nil,
        paraBirimi: String? = "₺",
        dosyaYolu: String? = nil,
        gorselBase64: String? = nil,
        tarih: String = ISO8601DateFormatter().string(from: Date()),
        isDeleted: Bool? = false
    ) {
        self.id = id
        self.tenantId = tenantId
        self.klasorId = klasorId
        self.cariId = cariId
        self.baslik = baslik
        self.icerik = icerik
        self.tip = tip
        self.fiyatBilgisi = fiyatBilgisi
        self.paraBirimi = paraBirimi
        self.dosyaYolu = dosyaYolu
        self.gorselBase64 = gorselBase64
        self.tarih = tarih
        self.isDeleted = isDeleted
    }
}

// Legacy DTO compatibility
public struct MusteriTakipKayit: Identifiable, Codable, Hashable {
    public var id: String
    public var cariId: String?
    public var cariUnvan: String
    public var gorusmeTarihi: String
    public var gorusmeTuru: String
    public var konu: String
    public var notlar: String?
    public var sonrakiEylem: String?
    public var sonrakiEylemTarihi: String?
    public var lokasyon: String?
    public var personelAdi: String?
    public var durum: String
    public var syncGuid: String?
    public var tenantId: String?
    
    public init(
        id: String,
        cariId: String? = nil,
        cariUnvan: String,
        gorusmeTarihi: String = "",
        gorusmeTuru: String = "ZIYARET",
        konu: String = "",
        notlar: String? = nil,
        sonrakiEylem: String? = nil,
        sonrakiEylemTarihi: String? = nil,
        lokasyon: String? = nil,
        personelAdi: String? = nil,
        durum: String = "PLANLANDI",
        syncGuid: String? = nil,
        tenantId: String? = nil
    ) {
        self.id = id
        self.cariId = cariId
        self.cariUnvan = cariUnvan
        self.gorusmeTarihi = gorusmeTarihi
        self.gorusmeTuru = gorusmeTuru
        self.konu = konu
        self.notlar = notlar
        self.sonrakiEylem = sonrakiEylem
        self.sonrakiEylemTarihi = sonrakiEylemTarihi
        self.lokasyon = lokasyon
        self.personelAdi = personelAdi
        self.durum = durum
        self.syncGuid = syncGuid
        self.tenantId = tenantId
    }
}
