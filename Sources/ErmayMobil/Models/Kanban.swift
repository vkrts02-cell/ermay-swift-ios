import Foundation

public struct KanbanGorev: Identifiable, Codable, Hashable {
    public var id: String
    public var uuid: String
    public var baslik: String
    public var aciklama: String?
    public var atananPersonelId: Int?
    public var atananPersonelAd: String?
    public var durum: String // 'Yapılacak' | 'Yapılıyor' | 'Bitti'
    public var oncelik: String // 'Düşük' | 'Normal' | 'Acil'
    public var sonTarih: String
    public var bitisTarihi: String?
    public var olusturmaTarihi: String
    public var tenantId: String?
    
    enum CodingKeys: String, CodingKey {
        case id
        case uuid
        case baslik
        case aciklama
        case atananPersonelId = "atanan_personel_id"
        case atananPersonelAd = "atanan_personel_ad"
        case atananKisi = "atanan_kisi"
        case durum
        case oncelik
        case sonTarih = "son_tarih"
        case bitisTarihi = "bitis_tarihi"
        case olusturmaTarihi = "olusturma_tarihi"
        case tarih
        case tenantId = "tenant_id"
    }
    
    public init(
        id: String = UUID().uuidString,
        uuid: String? = nil,
        baslik: String,
        aciklama: String? = nil,
        atananPersonelId: Int? = 1,
        atananPersonelAd: String? = "Yönetici",
        durum: String = "Yapılacak",
        oncelik: String = "Normal",
        sonTarih: String = AppFormatters.isoDate.string(from: Date()),
        bitisTarihi: String? = nil,
        olusturmaTarihi: String = AppFormatters.isoDate.string(from: Date()),
        tenantId: String? = nil
    ) {
        self.id = id
        self.uuid = uuid ?? (Int(id) == nil ? id : UUID().uuidString)
        self.baslik = baslik
        self.aciklama = aciklama
        self.atananPersonelId = atananPersonelId
        self.atananPersonelAd = atananPersonelAd
        self.durum = durum
        self.oncelik = oncelik
        self.sonTarih = sonTarih
        self.bitisTarihi = bitisTarihi
        self.olusturmaTarihi = olusturmaTarihi
        self.tenantId = tenantId
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
        self.baslik = (try? c.decode(String.self, forKey: .baslik)) ?? ""
        self.aciklama = try? c.decode(String.self, forKey: .aciklama)
        self.atananPersonelId = try? c.decode(Int.self, forKey: .atananPersonelId)
        self.atananPersonelAd = (try? c.decode(String.self, forKey: .atananPersonelAd)) ?? (try? c.decode(String.self, forKey: .atananKisi)) ?? "Yönetici"
        let rawDurum = (try? c.decode(String.self, forKey: .durum)) ?? "Yapılacak"
        if rawDurum == "Bekliyor" {
            self.durum = "Yapılacak"
        } else if rawDurum == "Devam Ediyor" {
            self.durum = "Yapılıyor"
        } else if rawDurum == "Tamamlandı" {
            self.durum = "Bitti"
        } else {
            self.durum = rawDurum
        }
        self.oncelik = (try? c.decode(String.self, forKey: .oncelik)) ?? "Normal"
        let defaultDate = AppFormatters.isoDate.string(from: Date())
        self.sonTarih = (try? c.decode(String.self, forKey: .sonTarih)) ?? (try? c.decode(String.self, forKey: .tarih)) ?? defaultDate
        self.bitisTarihi = try? c.decode(String.self, forKey: .bitisTarihi)
        self.olusturmaTarihi = (try? c.decode(String.self, forKey: .olusturmaTarihi)) ?? (try? c.decode(String.self, forKey: .tarih)) ?? defaultDate
        self.tenantId = try? c.decode(String.self, forKey: .tenantId)
    }
    
    public func encode(to encoder: Encoder) throws {
        var c = encoder.container(keyedBy: CodingKeys.self)
        if let intId = Int(id), intId > 0 {
            try c.encode(intId, forKey: .id)
        }
        try c.encode(uuid, forKey: .uuid)
        try c.encode(baslik, forKey: .baslik)
        try c.encodeIfPresent(aciklama, forKey: .aciklama)
        try c.encodeIfPresent(atananPersonelId, forKey: .atananPersonelId)
        try c.encodeIfPresent(atananPersonelAd, forKey: .atananPersonelAd)
        try c.encodeIfPresent(atananPersonelAd, forKey: .atananKisi)
        try c.encode(durum, forKey: .durum)
        try c.encode(oncelik, forKey: .oncelik)
        try c.encode(sonTarih, forKey: .sonTarih)
        try c.encodeIfPresent(bitisTarihi, forKey: .bitisTarihi)
        try c.encode(olusturmaTarihi, forKey: .olusturmaTarihi)
        try c.encodeIfPresent(tenantId ?? SupabaseService.shared.tenantId, forKey: .tenantId)
    }
}
