import Foundation

public struct KanbanGorev: Identifiable, Codable, Hashable {
    public var id: String
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
        case baslik
        case aciklama
        case atananPersonelId = "atanan_personel_id"
        case atananPersonelAd = "atanan_personel_ad"
        case durum
        case oncelik
        case sonTarih = "son_tarih"
        case bitisTarihi = "bitis_tarihi"
        case olusturmaTarihi = "olusturma_tarihi"
        case tenantId = "tenant_id"
    }
    
    public init(
        id: String = UUID().uuidString,
        baslik: String,
        aciklama: String? = nil,
        atananPersonelId: Int? = 1,
        atananPersonelAd: String? = "Yönetici",
        durum: String = "Yapılacak",
        oncelik: String = "Normal",
        sonTarih: String = "2026-11-04",
        bitisTarihi: String? = nil,
        olusturmaTarihi: String = "2026-11-04",
        tenantId: String? = nil
    ) {
        self.id = id
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
}
