import Foundation

public typealias IslemTuru = String // "Tahsilat" | "Ödeme" | "Alacak Dekontu" | "Borç Dekontu"
public typealias OdemeYontemi = String // "Nakit" | "Kredi Kartı" | "Havale/EFT" | "Çek" | "Banka"

public struct FinancialTransactionRequest {
    public var id: Int?
    public var cari: CariKart
    public var amount: Double
    public var date: String
    public var transactionType: IslemTuru
    public var method: OdemeYontemi
    public var description: String
    public var isAcilisFisi: Bool
    public var selectedHesap: KasaBanka?
    public var bankaAdi: String?
    public var kartHesapNo: String?
    public var slipDekontPath: String?
    public var directedSupplier: CariKart?
    public var yonlendirmeTarihi: String?
    public var cekDetay: CekSenet?
    
    public init(
        id: Int? = nil,
        cari: CariKart,
        amount: Double,
        date: String,
        transactionType: IslemTuru,
        method: OdemeYontemi,
        description: String,
        isAcilisFisi: Bool = false,
        selectedHesap: KasaBanka? = nil,
        bankaAdi: String? = nil,
        kartHesapNo: String? = nil,
        slipDekontPath: String? = nil,
        directedSupplier: CariKart? = nil,
        yonlendirmeTarihi: String? = nil,
        cekDetay: CekSenet? = nil
    ) {
        self.id = id
        self.cari = cari
        self.amount = amount
        self.date = date
        self.transactionType = transactionType
        self.method = method
        self.description = description
        self.isAcilisFisi = isAcilisFisi
        self.selectedHesap = selectedHesap
        self.bankaAdi = bankaAdi
        self.kartHesapNo = kartHesapNo
        self.slipDekontPath = slipDekontPath
        self.directedSupplier = directedSupplier
        self.yonlendirmeTarihi = yonlendirmeTarihi
        self.cekDetay = cekDetay
    }
}

public struct InvoiceTransactionRequest {
    public var id: Int?
    public var faturaNo: String
    public var tarih: String
    public var vadeTarihi: String
    public var cari: CariKart
    public var tur: String // "Satış" | "Alış"
    public var durum: String // "Açık" | "Kapalı"
    public var odemeSekli: String // "Açık Hesap" | "Nakit" | "Kredi Kartı"
    public var kasaId: String?
    public var bankaId: String?
    public var dovizTuru: String // "TL", "USD", "EUR"
    public var dovizKuru: Double
    public var baglantiEvrakNo: String?
    public var aciklama: String?
    public var items: [FaturaKalem]
    
    public init(
        id: Int? = nil,
        faturaNo: String,
        tarih: String,
        vadeTarihi: String,
        cari: CariKart,
        tur: String = "Satış",
        durum: String = "Açık",
        odemeSekli: String = "Açık Hesap",
        kasaId: String? = nil,
        bankaId: String? = nil,
        dovizTuru: String = "TL",
        dovizKuru: Double = 1.0,
        baglantiEvrakNo: String? = nil,
        aciklama: String? = nil,
        items: [FaturaKalem] = []
    ) {
        self.id = id
        self.faturaNo = faturaNo
        self.tarih = tarih
        self.vadeTarihi = vadeTarihi
        self.cari = cari
        self.tur = tur
        self.durum = durum
        self.odemeSekli = odemeSekli
        self.kasaId = kasaId
        self.bankaId = bankaId
        self.dovizTuru = dovizTuru
        self.dovizKuru = dovizKuru
        self.baglantiEvrakNo = baglantiEvrakNo
        self.aciklama = aciklama
        self.items = items
    }
}

public final class TransactionService: @unchecked Sendable {
    public static let shared = TransactionService()
    private init() {}
    
    private func getEvrakNoPrefix(method: String) -> String {
        if method.contains("Kredi") { return "KK-" }
        if method.contains("EFT") || method.contains("Havale") { return "EFT-" }
        if method.contains("Çek") { return "CK-" }
        return "TS-"
    }
    
    // MARK: - Save Financial Transaction (Tahsilat / Ödeme / Virman / Çek)
    public func saveFinancialTransaction(req: FinancialTransactionRequest) async throws -> Bool {
        guard req.amount > 0 else { return false }
        
        let tenantId = SupabaseService.shared.tenantId
        let isOdeme = req.transactionType == "Ödeme" || req.transactionType == "Borç Dekontu" || req.transactionType == "Borçlandır"
        let chId = req.id ?? Int.random(in: 100000...999999)
        let evrakNo = getEvrakNoPrefix(method: req.method) + AppFormatters.isoDate.string(from: Date()).replacingOccurrences(of: "-", with: "") + "\(Int.random(in: 100...999))"
        let isAcilis = req.isAcilisFisi
        
        let islemTuru = isAcilis ? "\(req.transactionType) (Açılış Fişi)" : "\(req.transactionType) (\(req.method))"
        let aciklama = isAcilis ? "[Açılış Fişi] \(req.description)".trimmingCharacters(in: .whitespaces) : "[\(req.method)] \(req.description)".trimmingCharacters(in: .whitespaces)
        
        // 1. Cari Hareket
        let cariHareket = CariHareket(
            id: String(chId),
            cariId: req.cari.id,
            tarih: req.date,
            belgeNo: evrakNo,
            islemTuru: islemTuru,
            aciklama: aciklama,
            borc: isOdeme ? req.amount : 0,
            alacak: !isOdeme ? req.amount : 0,
            bakiye: req.cari.bakiye + (isOdeme ? -req.amount : req.amount),
            syncGuid: UUID().uuidString
        )
        _ = try await SupabaseService.shared.insert(into: "cari_hareketler", item: cariHareket)
        
        // Cari Bakiye Güncelleme
        let yeniBakiye = req.cari.bakiye + (isOdeme ? -req.amount : req.amount)
        let yeniBakiyeTuru = yeniBakiye >= 0 ? "A" : "B"
        try await SupabaseService.shared.update(
            table: "cariler",
            id: req.cari.id,
            item: ["bakiye": abs(yeniBakiye), "bakiye_turu": yeniBakiyeTuru]
        )
        
        // 2. Kasa veya Banka Hareketi
        if !isAcilis, let hesap = req.selectedHesap {
            let isKasa = hesap.hesapTuru == "KASA"
            let kasaHareket = KasaHareket(
                id: UUID().uuidString,
                hesapId: hesap.id,
                tarih: req.date,
                islemTuru: isOdeme ? "TEDIYE" : "TAHSILAT",
                cariId: req.cari.id,
                cariUnvan: req.cari.unvan,
                belgeNo: evrakNo,
                tutar: req.amount,
                aciklama: aciklama,
                syncGuid: UUID().uuidString,
                tenantId: tenantId
            )
            _ = try await SupabaseService.shared.insert(into: isKasa ? "kasa_hareketler" : "banka_hareketler", item: kasaHareket)
            
            // Hesap Bakiyesi Güncelleme
            let yeniHesapBakiye = hesap.bakiye + (isOdeme ? -req.amount : req.amount)
            try await SupabaseService.shared.update(
                table: isKasa ? "kasalar" : "bankalar",
                id: hesap.id,
                item: ["bakiye": yeniHesapBakiye]
            )
        }
        
        return true
    }
    
    // MARK: - Save Invoice Transaction (Çift Taraflı Tam Muhasebe Kaydı)
    public func saveInvoiceTransaction(req: InvoiceTransactionRequest) async throws -> Fatura {
        let currentId = req.id ?? Int.random(in: 100000...999999)
        let isPaid = req.odemeSekli != "Açık Hesap"
        let finalDurum = isPaid ? "Kapalı" : req.durum
        let isSatis = req.tur == "Satış" || req.tur.contains("SATIS")
        
        let subtotal = req.items.reduce(0.0) { $0 + ($1.miktar * $1.birimFiyat) }
        let totalIskonto = req.items.reduce(0.0) { $0 + $1.iskontoTutari }
        let totalKdv = req.items.reduce(0.0) { $0 + $1.kdvTutari }
        let grandTotal = subtotal - totalIskonto + totalKdv
        
        let fatura = Fatura(
            id: String(currentId),
            faturaNo: req.faturaNo,
            faturaTuru: isSatis ? "SATIS" : "ALIS",
            cariId: req.cari.id,
            cariUnvan: req.cari.unvan,
            tarih: req.tarih,
            vadeTarihi: req.vadeTarihi,
            araToplam: subtotal,
            kdvToplami: totalKdv,
            iskontoToplami: totalIskonto,
            genelToplam: grandTotal,
            odemeDurumu: isPaid ? "ODENDI" : "BEKLIYOR",
            aciklama: req.aciklama,
            kalemler: req.items
        )
        
        // 1. Faturayı Kaydet
        let savedFatura: Fatura = try await SupabaseService.shared.insert(into: "faturalar", item: fatura)
        
        // 2. Fatura Detay Kalemlerini Kaydet
        for item in req.items {
            var kalemData = item
            kalemData.faturaId = String(currentId)
            _ = try await SupabaseService.shared.insert(into: "fatura_detaylar", item: kalemData)
            
            // 3. Stok Hareketini Kaydet & Stok Miktarını Güncelle
            if let stokId = item.stokId {
                let sh = StokHareket(
                    id: UUID().uuidString,
                    stokId: stokId,
                    tarih: req.tarih,
                    islemTuru: isSatis ? "Satış Faturası" : "Alış Faturası",
                    belgeNo: req.faturaNo,
                    miktar: item.miktar,
                    birimFiyat: item.birimFiyat,
                    toplamTutar: item.netTutar,
                    aciklama: "Fatura No: \(req.faturaNo)"
                )
                _ = try await SupabaseService.shared.insert(into: "stok_hareketler", item: sh)
                
                // Mevcut stok miktarını al ve güncelle
                let stoklar: [StokKart] = try await SupabaseService.shared.fetch(from: "stoklar", filters: ["id": "eq.\(stokId)"])
                if let st = stoklar.first {
                    let delta = isSatis ? -item.miktar : item.miktar
                    let yeniMiktar = max(0, st.mevcutMiktar + delta)
                    try await SupabaseService.shared.update(table: "stoklar", id: stokId, item: ["mevcut_miktar": yeniMiktar])
                }
            }
        }
        
        // 4. Cari Hareket ve Bakiye Güncelle
        let cariHareket = CariHareket(
            id: UUID().uuidString,
            cariId: req.cari.id,
            tarih: req.tarih,
            belgeNo: req.faturaNo,
            islemTuru: isSatis ? "Satış Faturası" : "Alış Faturası",
            aciklama: req.aciklama ?? "Fatura Kesildi",
            borc: isSatis ? grandTotal : 0,
            alacak: !isSatis ? grandTotal : 0,
            bakiye: req.cari.bakiye + (isSatis ? grandTotal : -grandTotal)
        )
        _ = try await SupabaseService.shared.insert(into: "cari_hareketler", item: cariHareket)
        
        let deltaBakiye = isSatis ? grandTotal : -grandTotal
        let sonBakiye = req.cari.bakiye + deltaBakiye
        try await SupabaseService.shared.update(
            table: "cariler",
            id: req.cari.id,
            item: ["bakiye": abs(sonBakiye), "bakiye_turu": sonBakiye >= 0 ? "A" : "B"]
        )
        
        // 5. Eğer Fatura "Kapalı" ise Kasa/Banka Tahsilatını Anında Yap
        if isPaid {
            if req.odemeSekli == "Nakit", let kId = req.kasaId {
                let kh = KasaHareket(
                    id: UUID().uuidString,
                    hesapId: kId,
                    tarih: req.tarih,
                    islemTuru: isSatis ? "TAHSILAT" : "TEDIYE",
                    cariId: req.cari.id,
                    cariUnvan: req.cari.unvan,
                    belgeNo: req.faturaNo,
                    tutar: grandTotal,
                    aciklama: "Kapalı Fatura: \(req.faturaNo)"
                )
                _ = try await SupabaseService.shared.insert(into: "kasa_hareketler", item: kh)
            } else if req.odemeSekli == "Kredi Kartı", let bId = req.bankaId {
                let bh = KasaHareket(
                    id: UUID().uuidString,
                    hesapId: bId,
                    tarih: req.tarih,
                    islemTuru: isSatis ? "TAHSILAT" : "TEDIYE",
                    cariId: req.cari.id,
                    cariUnvan: req.cari.unvan,
                    belgeNo: req.faturaNo,
                    tutar: grandTotal,
                    aciklama: "Kapalı Fatura (POS/Kart): \(req.faturaNo)"
                )
                _ = try await SupabaseService.shared.insert(into: "banka_hareketler", item: bh)
            }
        }
        
        return savedFatura
    }
    
    // MARK: - Revert / Delete Fatura Cascade
    public func deleteFaturaCascade(fatura: Fatura) async throws -> Bool {
        // 1. Fatura detaylarını al
        let detaylar: [FaturaKalem] = try await SupabaseService.shared.fetch(from: "fatura_detaylar", filters: ["fatura_id": "eq.\(fatura.id)"])
        let isSatis = fatura.faturaTuru.contains("SATIS")
        
        // 2. Stok hareketlerini ve miktarlarını geri al
        for d in detaylar {
            if let stId = d.stokId {
                let stoklar: [StokKart] = try await SupabaseService.shared.fetch(from: "stoklar", filters: ["id": "eq.\(stId)"])
                if let st = stoklar.first {
                    let revertDelta = isSatis ? d.miktar : -d.miktar
                    let yeniMiktar = max(0, st.mevcutMiktar + revertDelta)
                    try await SupabaseService.shared.update(table: "stoklar", id: stId, item: ["mevcut_miktar": yeniMiktar])
                }
            }
        }
        
        // 3. Fatura detaylarını sil
        try await SupabaseService.shared.delete(table: "fatura_detaylar", id: fatura.id)
        
        // 4. Cari hareketini ve bakiyesini geri al
        if let cId = fatura.cariId {
            let cariler: [CariKart] = try await SupabaseService.shared.fetch(from: "cariler", filters: ["id": "eq.\(cId)"])
            if let cari = cariler.first {
                let revertBakiye = isSatis ? (cari.bakiye - fatura.genelToplam) : (cari.bakiye + fatura.genelToplam)
                try await SupabaseService.shared.update(
                    table: "cariler",
                    id: cId,
                    item: ["bakiye": abs(revertBakiye), "bakiye_turu": revertBakiye >= 0 ? "A" : "B"]
                )
            }
        }
        
        // 5. Faturayı sil
        try await SupabaseService.shared.delete(table: "faturalar", id: fatura.id)
        return true
    }
}

