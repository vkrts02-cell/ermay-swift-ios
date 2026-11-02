import Foundation

public enum GorevDurumu: String, Codable, CaseIterable {
    case todo = "YAPILACAK"
    case inProgress = "DEVAM_EDIYOR"
    case done = "TAMAMLANDI"
    
    public var title: String {
        switch self {
        case .todo: return "Yapılacak"
        case .inProgress: return "Devam Ediyor"
        case .done: return "Tamamlandı"
        }
    }
}

public struct KanbanGorev: Identifiable, Codable, Hashable {
    public var id: String
    public var baslik: String
    public var aciklama: String?
    public var durum: GorevDurumu
    public var oncelik: String // "DUSUK", "ORTA", "YUKSEK", "ACIL"
    public var atananKisi: String?
    public var bitisTarihi: String?
    public var syncGuid: String?
    public var tenantId: String?
    
    enum CodingKeys: String, CodingKey {
        case id
        case baslik
        case aciklama
        case durum
        case oncelik
        case atananKisi = "atanan_kisi"
        case bitisTarihi = "bitis_tarihi"
        case syncGuid = "sync_guid"
        case tenantId = "tenant_id"
    }
    
    public init(
        id: String = UUID().uuidString,
        baslik: String,
        aciklama: String? = nil,
        durum: GorevDurumu = .todo,
        oncelik: String = "ORTA",
        atananKisi: String? = nil,
        bitisTarihi: String? = nil,
        syncGuid: String? = UUID().uuidString,
        tenantId: String? = nil
    ) {
        self.id = id
        self.baslik = baslik
        self.aciklama = aciklama
        self.durum = durum
        self.oncelik = oncelik
        self.atananKisi = atananKisi
        self.bitisTarihi = bitisTarihi
        self.syncGuid = syncGuid
        self.tenantId = tenantId
    }
}

