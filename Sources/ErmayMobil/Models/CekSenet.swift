import Foundation

public struct Cek: Identifiable, Codable, Sendable {
    public var id: String
    public var uuid: String
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
    
    public var idInt: Int? { Int(id) }
    public var cekSenetNo: String { cekNo ?? portfoyNo ?? seriNo ?? "-" }
    public var bankaAdi: String? { banka }
    
    public init(
        id: String = UUID().uuidString,
        uuid: String? = nil,
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
        self.uuid = uuid ?? (Int(id) == nil ? id : UUID().uuidString)
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

    public init(
        id: Int?,
        uuid: String = UUID().uuidString,
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
        self.id = id != nil ? String(id!) : uuid
        self.uuid = uuid
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
        case uuid
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

    public init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        if let intId = try? c.decode(Int.self, forKey: .id) {
            self.id = String(intId)
        } else if let strId = try? c.decode(String.self, forKey: .id) {
            self.id = strId
        } else {
            self.id = UUID().uuidString
        }
        self.uuid = (try? c.decode(String.self, forKey: .uuid)) ?? (Int(self.id) == nil ? self.id : UUID().uuidString)
        self.cekNo = try? c.decode(String.self, forKey: .cekNo)
        if let intCariId = try? c.decode(Int.self, forKey: .cariId) {
            self.cariId = intCariId
        } else if let strCariId = try? c.decode(String.self, forKey: .cariId), let intVal = Int(strCariId) {
            self.cariId = intVal
        } else {
            self.cariId = nil
        }
        self.cariUnvan = try? c.decode(String.self, forKey: .cariUnvan)
        self.islemTarihi = try? c.decode(String.self, forKey: .islemTarihi)
        self.portfoyNo = try? c.decode(String.self, forKey: .portfoyNo)
        self.seriNo = try? c.decode(String.self, forKey: .seriNo)
        self.vadeTarihi = (try? c.decode(String.self, forKey: .vadeTarihi)) ?? ""
        self.tutar = (try? c.decode(Double.self, forKey: .tutar)) ?? 0.0
        self.borclu = try? c.decode(String.self, forKey: .borclu)
        self.banka = try? c.decode(String.self, forKey: .banka)
        self.sube = try? c.decode(String.self, forKey: .sube)
        self.hesapNo = try? c.decode(String.self, forKey: .hesapNo)
        self.cekTuru = try? c.decode(String.self, forKey: .cekTuru)
        self.durum = (try? c.decode(String.self, forKey: .durum)) ?? "PORTFOYDE"
        self.aciklama = try? c.decode(String.self, forKey: .aciklama)
    }

    public func encode(to encoder: Encoder) throws {
        var c = encoder.container(keyedBy: CodingKeys.self)
        if let intId = Int(id), intId > 0 {
            try c.encode(intId, forKey: .id)
        }
        let finalUuid = !uuid.isEmpty ? uuid : (Int(id) == nil ? id : UUID().uuidString)
        try c.encode(finalUuid, forKey: .uuid)
        try c.encodeIfPresent(cekNo, forKey: .cekNo)
        try c.encodeIfPresent(cariId, forKey: .cariId)
        try c.encodeIfPresent(cariUnvan, forKey: .cariUnvan)
        try c.encodeIfPresent(islemTarihi, forKey: .islemTarihi)
        try c.encodeIfPresent(portfoyNo, forKey: .portfoyNo)
        try c.encodeIfPresent(seriNo, forKey: .seriNo)
        try c.encode(vadeTarihi, forKey: .vadeTarihi)
        try c.encode(tutar, forKey: .tutar)
        try c.encodeIfPresent(borclu, forKey: .borclu)
        try c.encodeIfPresent(banka, forKey: .banka)
        try c.encodeIfPresent(sube, forKey: .sube)
        try c.encodeIfPresent(hesapNo, forKey: .hesapNo)
        try c.encodeIfPresent(cekTuru, forKey: .cekTuru)
        try c.encode(durum, forKey: .durum)
        try c.encodeIfPresent(aciklama, forKey: .aciklama)
    }
}

public typealias CekSenet = Cek


public struct Senet: Identifiable, Codable, Sendable {
    public var id: String
    public var uuid: String
    public var senetNo: String?
    public var cariId: Int?
    public var cariUnvan: String?
    public var portfoyNo: String?
    public var vadeTarihi: String
    public var tutar: Double
    public var borclu: String?
    public var durum: String // "PORTFOYDE", "TAHSIL_EDILDI", "PROTESTOLU", "IADE"
    public var aciklama: String?
    
    public var idInt: Int? { Int(id) }
    public var cekSenetNo: String { senetNo ?? portfoyNo ?? "-" }
    public var bankaAdi: String? { nil }
    
    public init(
        id: String = UUID().uuidString,
        uuid: String? = nil,
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
        self.uuid = uuid ?? (Int(id) == nil ? id : UUID().uuidString)
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

    public init(
        id: Int?,
        uuid: String = UUID().uuidString,
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
        self.id = id != nil ? String(id!) : uuid
        self.uuid = uuid
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
        case uuid
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

    public init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        if let intId = try? c.decode(Int.self, forKey: .id) {
            self.id = String(intId)
        } else if let strId = try? c.decode(String.self, forKey: .id) {
            self.id = strId
        } else {
            self.id = UUID().uuidString
        }
        self.uuid = (try? c.decode(String.self, forKey: .uuid)) ?? (Int(self.id) == nil ? self.id : UUID().uuidString)
        self.senetNo = try? c.decode(String.self, forKey: .senetNo)
        if let intCariId = try? c.decode(Int.self, forKey: .cariId) {
            self.cariId = intCariId
        } else if let strCariId = try? c.decode(String.self, forKey: .cariId), let intVal = Int(strCariId) {
            self.cariId = intVal
        } else {
            self.cariId = nil
        }
        self.cariUnvan = try? c.decode(String.self, forKey: .cariUnvan)
        self.portfoyNo = try? c.decode(String.self, forKey: .portfoyNo)
        self.vadeTarihi = (try? c.decode(String.self, forKey: .vadeTarihi)) ?? ""
        self.tutar = (try? c.decode(Double.self, forKey: .tutar)) ?? 0.0
        self.borclu = try? c.decode(String.self, forKey: .borclu)
        self.durum = (try? c.decode(String.self, forKey: .durum)) ?? "PORTFOYDE"
        self.aciklama = try? c.decode(String.self, forKey: .aciklama)
    }

    public func encode(to encoder: Encoder) throws {
        var c = encoder.container(keyedBy: CodingKeys.self)
        if let intId = Int(id), intId > 0 {
            try c.encode(intId, forKey: .id)
        }
        let finalUuid = !uuid.isEmpty ? uuid : (Int(id) == nil ? id : UUID().uuidString)
        try c.encode(finalUuid, forKey: .uuid)
        try c.encodeIfPresent(senetNo, forKey: .senetNo)
        try c.encodeIfPresent(cariId, forKey: .cariId)
        try c.encodeIfPresent(cariUnvan, forKey: .cariUnvan)
        try c.encodeIfPresent(portfoyNo, forKey: .portfoyNo)
        try c.encode(vadeTarihi, forKey: .vadeTarihi)
        try c.encode(tutar, forKey: .tutar)
        try c.encodeIfPresent(borclu, forKey: .borclu)
        try c.encode(durum, forKey: .durum)
        try c.encodeIfPresent(aciklama, forKey: .aciklama)
    }
}



