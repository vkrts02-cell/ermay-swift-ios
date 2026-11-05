import Foundation

public struct Teklif: Identifiable, Codable, Hashable {
    public var id: String
    public var teklifNo: String
    public var cariId: String?
    public var cariUnvan: String?
    public var tarih: String
    public var gecerlilikTarihi: String?
    public var araToplam: Double
    public var kdvToplami: Double
    public var genelToplam: Double
    public var durum: String // "TASLAK", "GONDERILDI", "ONAYLANDI", "REDDEDILDI"
    public var aciklama: String?
    public var kalemler: [TeklifKalem]?
    public var syncGuid: String?
    public var tenantId: String?
    
    enum CodingKeys: String, CodingKey {
        case id
        case teklifNo = "teklif_no"
        case cariId = "cari_id"
        case cariUnvan = "cari_unvan"
        case tarih
        case gecerlilikTarihi = "gecerlilik_tarihi"
        case araToplam = "ara_toplam"
        case kdvToplami = "kdv_toplami"
        case kdvToplam = "kdv_toplam"
        case genelToplam = "genel_toplam"
        case durum
        case aciklama
        case kalemler
        case syncGuid = "sync_guid"
        case uuid
        case tenantId = "tenant_id"
    }
    
    public init(
        id: String = UUID().uuidString,
        teklifNo: String = "",
        cariId: String? = nil,
        cariUnvan: String? = nil,
        tarih: String = AppFormatters.isoDate.string(from: Date()),
        gecerlilikTarihi: String? = nil,
        araToplam: Double = 0.0,
        kdvToplami: Double = 0.0,
        genelToplam: Double = 0.0,
        durum: String = "TASLAK",
        aciklama: String? = nil,
        kalemler: [TeklifKalem]? = nil,
        syncGuid: String? = nil,
        tenantId: String? = nil
    ) {
        self.id = id
        self.teklifNo = teklifNo
        self.cariId = cariId
        self.cariUnvan = cariUnvan
        self.tarih = tarih
        self.gecerlilikTarihi = gecerlilikTarihi
        self.araToplam = araToplam
        self.kdvToplami = kdvToplami
        self.genelToplam = genelToplam
        self.durum = durum
        self.aciklama = aciklama
        self.kalemler = kalemler
        self.syncGuid = syncGuid
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
        
        self.teklifNo = (try? c.decode(String.self, forKey: .teklifNo)) ?? ""
        
        if let intCariId = try? c.decode(Int.self, forKey: .cariId) {
            self.cariId = String(intCariId)
        } else {
            self.cariId = try? c.decode(String.self, forKey: .cariId)
        }
        
        self.cariUnvan = try? c.decode(String.self, forKey: .cariUnvan)
        self.tarih = (try? c.decode(String.self, forKey: .tarih)) ?? ""
        self.gecerlilikTarihi = try? c.decode(String.self, forKey: .gecerlilikTarihi)
        
        if let dAra = try? c.decode(Double.self, forKey: .araToplam) {
            self.araToplam = dAra
        } else if let iAra = try? c.decode(Int.self, forKey: .araToplam) {
            self.araToplam = Double(iAra)
        } else {
            self.araToplam = 0.0
        }
        
        if let dKdv = try? c.decode(Double.self, forKey: .kdvToplami) {
            self.kdvToplami = dKdv
        } else if let dKdv2 = try? c.decode(Double.self, forKey: .kdvToplam) {
            self.kdvToplami = dKdv2
        } else if let iKdv = try? c.decode(Int.self, forKey: .kdvToplami) {
            self.kdvToplami = Double(iKdv)
        } else {
            self.kdvToplami = 0.0
        }
        
        if let dGen = try? c.decode(Double.self, forKey: .genelToplam) {
            self.genelToplam = dGen
        } else if let iGen = try? c.decode(Int.self, forKey: .genelToplam) {
            self.genelToplam = Double(iGen)
        } else {
            self.genelToplam = 0.0
        }
        
        self.durum = (try? c.decode(String.self, forKey: .durum)) ?? "TASLAK"
        self.aciklama = try? c.decode(String.self, forKey: .aciklama)
        self.kalemler = try? c.decode([TeklifKalem].self, forKey: .kalemler)
        self.syncGuid = (try? c.decode(String.self, forKey: .syncGuid)) ?? (try? c.decode(String.self, forKey: .uuid))
        self.tenantId = try? c.decode(String.self, forKey: .tenantId)
    }
}

public struct TeklifKalem: Identifiable, Codable, Hashable {
    public var id: String
    public var teklifId: String?
    public var stokId: String
    public var stokKodu: String?
    public var stokAdi: String
    public var miktar: Double
    public var birim: String
    public var birimFiyat: Double
    public var kdvOrani: Double
    public var toplamTutar: Double
    
    enum CodingKeys: String, CodingKey {
        case id
        case teklifId = "teklif_id"
        case stokId = "stok_id"
        case stokKodu = "stok_kodu"
        case stokAdi = "stok_adi"
        case miktar
        case birim
        case birimFiyat = "birim_fiyat"
        case kdvOrani = "kdv_orani"
        case toplamTutar = "toplam_tutar"
        case tutar
    }
    
    public init(
        id: String = UUID().uuidString,
        teklifId: String? = nil,
        stokId: String,
        stokKodu: String? = nil,
        stokAdi: String,
        miktar: Double = 1.0,
        birim: String = "Adet",
        birimFiyat: Double = 0.0,
        kdvOrani: Double = 20.0,
        toplamTutar: Double = 0.0
    ) {
        self.id = id
        self.teklifId = teklifId
        self.stokId = stokId
        self.stokKodu = stokKodu
        self.stokAdi = stokAdi
        self.miktar = miktar
        self.birim = birim
        self.birimFiyat = birimFiyat
        self.kdvOrani = kdvOrani
        self.toplamTutar = toplamTutar
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
        
        if let intTId = try? c.decode(Int.self, forKey: .teklifId) {
            self.teklifId = String(intTId)
        } else {
            self.teklifId = try? c.decode(String.self, forKey: .teklifId)
        }
        
        if let intStokId = try? c.decode(Int.self, forKey: .stokId) {
            self.stokId = String(intStokId)
        } else {
            self.stokId = (try? c.decode(String.self, forKey: .stokId)) ?? ""
        }
        
        self.stokKodu = try? c.decode(String.self, forKey: .stokKodu)
        self.stokAdi = (try? c.decode(String.self, forKey: .stokAdi)) ?? ""
        
        if let dMiktar = try? c.decode(Double.self, forKey: .miktar) {
            self.miktar = dMiktar
        } else if let iMiktar = try? c.decode(Int.self, forKey: .miktar) {
            self.miktar = Double(iMiktar)
        } else {
            self.miktar = 1.0
        }
        
        self.birim = (try? c.decode(String.self, forKey: .birim)) ?? "Adet"
        
        if let dFiyat = try? c.decode(Double.self, forKey: .birimFiyat) {
            self.birimFiyat = dFiyat
        } else if let iFiyat = try? c.decode(Int.self, forKey: .birimFiyat) {
            self.birimFiyat = Double(iFiyat)
        } else {
            self.birimFiyat = 0.0
        }
        
        if let dKdv = try? c.decode(Double.self, forKey: .kdvOrani) {
            self.kdvOrani = dKdv
        } else if let iKdv = try? c.decode(Int.self, forKey: .kdvOrani) {
            self.kdvOrani = Double(iKdv)
        } else {
            self.kdvOrani = 20.0
        }
        
        if let dTop = try? c.decode(Double.self, forKey: .toplamTutar) {
            self.toplamTutar = dTop
        } else if let dTop2 = try? c.decode(Double.self, forKey: .tutar) {
            self.toplamTutar = dTop2
        } else {
            self.toplamTutar = self.miktar * self.birimFiyat
        }
    }
}
