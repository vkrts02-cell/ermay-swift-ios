import Foundation

public struct Cek: Identifiable, Codable, Sendable {
    public var id: String
    public var cekNo: String?
    public var cariId: Int?
    public var cariUnvan: String?
    public var islemTarihi: String?
    public var portfoyNo: String?
    public var seriNo: String?
    public var vadeTarihi: String
    public var tutar: Double
    public var borclu: String?
    public var banka: String?
    public var sube: String?
    public var hesapNo: String?
    public var cekTuru: String? // "MUSTERI", "FIRMA"
    public var durum: String // "PORTFOYDE", "BANKADA", "TAHSIL_EDILDI", "KARSILIKSIZ", "IADE"
    public var aciklama: String?
    
    public init(
        id: String = UUID().uuidString,
        cekNo: String? = nil,
        cariId: Int? = nil,
        cariUnvan: String? = nil,
        islemTarihi: String? = nil,
        portfoyNo: String? = nil,
        seriNo: String? = nil,
        vadeTarihi: String,
        tutar: Double,
        borclu: String? = nil,
        banka: String? = nil,
        sube: String? = nil,
        hesapNo: String? = nil,
        cekTuru: String? = "MUSTERI",
        durum: String = "PORTFOYDE",
        aciklama: String? = nil
    ) {
        self.id = id
        self.cekNo = cekNo
        self.cariId = cariId
        self.cariUnvan = cariUnvan
        self.islemTarihi = islemTarihi
        self.portfoyNo = portfoyNo
        self.seriNo = seriNo
        self.vadeTarihi = vadeTarihi
        self.tutar = tutar
        self.borclu = borclu
        self.banka = banka
        self.sube = sube
        self.hesapNo = hesapNo
        self.cekTuru = cekTuru
        self.durum = durum
        self.aciklama = aciklama
    }
    
    enum CodingKeys: String, CodingKey {
        case id
        case cekNo = "cek_no"
        case cariId = "cari_id"
        case cariUnvan = "cari_unvan"
        case islemTarihi = "islem_tarihi"
        case portfoyNo = "portfoy_no"
        case seriNo = "seri_no"
        case vadeTarihi = "vade_tarihi"
        case tutar
        case borclu
        case banka
        case sube
        case hesapNo = "hesap_no"
        case cekTuru = "cek_turu"
        case durum
        case aciklama
    }
}

public struct Senet: Identifiable, Codable, Sendable {
    public var id: String
    public var senetNo: String?
    public var cariId: Int?
    public var cariUnvan: String?
    public var portfoyNo: String?
    public var vadeTarihi: String
    public var tutar: Double
    public var borclu: String?
    public var durum: String // "PORTFOYDE", "TAHSIL_EDILDI", "PROTESTOLU", "IADE"
    public var aciklama: String?
    
    public init(
        id: String = UUID().uuidString,
        senetNo: String? = nil,
        cariId: Int? = nil,
        cariUnvan: String? = nil,
        portfoyNo: String? = nil,
        vadeTarihi: String,
        tutar: Double,
        borclu: String? = nil,
        durum: String = "PORTFOYDE",
        aciklama: String? = nil
    ) {
        self.id = id
        self.senetNo = senetNo
        self.cariId = cariId
        self.cariUnvan = cariUnvan
        self.portfoyNo = portfoyNo
        self.vadeTarihi = vadeTarihi
        self.tutar = tutar
        self.borclu = borclu
        self.durum = durum
        self.aciklama = aciklama
    }
    
    enum CodingKeys: String, CodingKey {
        case id
        case senetNo = "senet_no"
        case cariId = "cari_id"
        case cariUnvan = "cari_unvan"
        case portfoyNo = "portfoy_no"
        case vadeTarihi = "vade_tarihi"
        case tutar
        case borclu
        case durum
        case aciklama
    }
}

