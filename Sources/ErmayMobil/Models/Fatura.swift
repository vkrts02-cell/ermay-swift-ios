import Foundation

public struct Fatura: Identifiable, Codable, Hashable {
    public var id: String
    public var faturaNo: String
    public var faturaTuru: String // "SATIS", "ALIS", "SATIS_IADE", "ALIS_IADE"
    public var cariId: String?
    public var cariUnvan: String?
    public var tarih: String
    public var vadeTarihi: String?
    public var araToplam: Double
    public var kdvToplami: Double
    public var iskontoToplami: Double
    public var genelToplam: Double
    public var tevkifatTutari: Double?
    public var odemeDurumu: String? // "ODENDI", "BEKLIYOR", "PARCIAL"
    public var aciklama: String?
    public var kalemler: [FaturaKalem]?
    public var syncGuid: String?
    public var tenantId: String?
    
    public var durum: String {
        get { odemeDurumu ?? "Açık" }
        set { odemeDurumu = newValue }
    }
    
    enum CodingKeys: String, CodingKey {
        case id
        case faturaNo = "fatura_no"
        case faturaTuru = "fatura_turu"
        case cariId = "cari_id"
        case cariUnvan = "cari_unvan"
        case tarih
        case vadeTarihi = "vade_tarihi"
        case araToplam = "ara_toplam"
        case kdvToplami = "kdv_toplami"
        case iskontoToplami = "iskonto_toplami"
        case genelToplam = "genel_toplam"
        case tevkifatTutari = "tevkifat_tutari"
        case odemeDurumu = "odeme_durumu"
        case aciklama
        case kalemler
        case syncGuid = "sync_guid"
        case tenantId = "tenant_id"
    }
    
    public init(
        id: String = UUID().uuidString,
        faturaNo: String = "",
        faturaTuru: String = "SATIS",
        cariId: String? = nil,
        cariUnvan: String? = nil,
        tarih: String = AppFormatters.isoDate.string(from: Date()),
        vadeTarihi: String? = nil,
        araToplam: Double = 0.0,
        kdvToplami: Double = 0.0,
        iskontoToplami: Double = 0.0,
        genelToplam: Double = 0.0,
        tevkifatTutari: Double? = 0.0,
        odemeDurumu: String? = "BEKLIYOR",
        durum: String? = nil,
        aciklama: String? = nil,
        kalemler: [FaturaKalem]? = [],
        syncGuid: String? = UUID().uuidString,
        tenantId: String? = nil
    ) {
        self.id = id
        self.faturaNo = faturaNo
        self.faturaTuru = faturaTuru
        self.cariId = cariId
        self.cariUnvan = cariUnvan
        self.tarih = tarih
        self.vadeTarihi = vadeTarihi
        self.araToplam = araToplam
        self.kdvToplami = kdvToplami
        self.iskontoToplami = iskontoToplami
        self.genelToplam = genelToplam
        self.tevkifatTutari = tevkifatTutari
        self.odemeDurumu = durum ?? odemeDurumu
        self.aciklama = aciklama
        self.kalemler = kalemler
        self.syncGuid = syncGuid
        self.tenantId = tenantId
    }
}

public struct FaturaKalem: Identifiable, Codable, Hashable {
    public var id: String
    public var faturaId: String?
    public var stokId: String?
    public var stokKodu: String?
    public var stokAdi: String
    public var birim: String?
    public var miktar: Double
    public var birimFiyat: Double
    public var kdvOrani: Double
    public var kdvTutari: Double
    public var iskontoOrani: Double
    public var iskontoTutari: Double
    public var netTutar: Double
    public var aciklama: String?
    public var syncGuid: String?
    
    enum CodingKeys: String, CodingKey {
        case id
        case faturaId = "fatura_id"
        case stokId = "stok_id"
        case stokKodu = "stok_kodu"
        case stokAdi = "stok_adi"
        case birim
        case miktar
        case birimFiyat = "birim_fiyat"
        case kdvOrani = "kdv_orani"
        case kdvTutari = "kdv_tutari"
        case iskontoOrani = "iskonto_orani"
        case iskontoTutari = "iskonto_tutari"
        case netTutar = "net_tutar"
        case aciklama
        case syncGuid = "sync_guid"
    }
    
    public init(
        id: String = UUID().uuidString,
        faturaId: String? = nil,
        stokId: String? = nil,
        stokKodu: String? = nil,
        stokAdi: String = "",
        birim: String? = "Adet",
        miktar: Double = 1.0,
        birimFiyat: Double = 0.0,
        kdvOrani: Double = 20.0,
        iskontoOrani: Double = 0.0,
        aciklama: String? = nil
    ) {
        self.id = id
        self.faturaId = faturaId
        self.stokId = stokId
        self.stokKodu = stokKodu
        self.stokAdi = stokAdi
        self.birim = birim
        self.miktar = miktar
        self.birimFiyat = birimFiyat
        self.kdvOrani = kdvOrani
        self.iskontoOrani = iskontoOrani
        self.aciklama = aciklama
        
        let brüt = miktar * birimFiyat
        let isk = brüt * (iskontoOrani / 100.0)
        let matrah = brüt - isk
        let kdv = matrah * (kdvOrani / 100.0)
        
        self.iskontoTutari = isk
        self.kdvTutari = kdv
        self.netTutar = matrah + kdv
        self.syncGuid = UUID().uuidString
    }
}

