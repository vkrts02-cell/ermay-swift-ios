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

// MARK: - Models for save_invoice_atomic RPC
public struct AtomicFaturaData: Codable {
    public var uuid: String
    public var fatura_no: String
    public var fatura_turu: String
    public var cari_id: Int
    public var cari_unvan: String
    public var tarih: String
    public var vade_tarihi: String
    public var ara_toplam: Double
    public var iskonto_toplami: Double
    public var kdv_toplami: Double
    public var genel_toplam: Double
    public var odeme_durumu: String
    public var aciklama: String?
}

public struct AtomicFaturaDetayData: Codable {
    public var stok_id: Int
    public var miktar: Double
    public var birim_fiyat: Double
    public var kdv_orani: Double
    public var kdv_tutari: Double
    public var iskonto_orani: Double
    public var iskonto_tutari: Double
    public var net_tutar: Double
}

public struct AtomicStokHareketData: Codable {
    public var stok_id: Int
    public var tarih: String
    public var islem_turu: String
    public var belge_no: String
    public var miktar: Double
    public var birim_fiyat: Double
    public var toplam_tutar: Double
    public var aciklama: String?
}

public struct AtomicCariHareketData: Codable {
    public var cari_id: Int
    public var tarih: String
    public var belge_no: String
    public var islem_turu: String
    public var borc: Double
    public var alacak: Double
    public var aciklama: String?
}

public struct AtomicInvoicePayload: Codable {
    public var tenant_id: String
    public var idempotency_key: String
    public var fatura: AtomicFaturaData
    public var detaylar: [AtomicFaturaDetayData]
    public var stok_hareketler: [AtomicStokHareketData]
    public var cari_hareketler: [AtomicCariHareketData]
}

public struct AtomicRpcWrapper: Encodable {
    public var p_payload: AtomicInvoicePayload
}

public struct AtomicRpcResponse: Decodable {
    public var success: Bool
    public var fatura_id: String?
    public var message: String?
}

public final class TransactionService: @unchecked Sendable {
    public static let shared = TransactionService()
    private init() {}
    
    private func getEvrakNoPrefix(method: String) -> String {
        if method.contains("Kredi") { return "MB-KK-" }
        if method.contains("EFT") || method.contains("Havale") { return "MB-EFT-" }
        if method.contains("Çek") { return "MB-CK-" }
        return "MB-TS-"
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
            item: CariBakiyeUpdate(bakiye: abs(yeniBakiye), bakiyeTuru: yeniBakiyeTuru)
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
            faturaNo: req.faturaNo.hasPrefix("MB-") ? req.faturaNo : "MB-\(req.faturaNo)",
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
        
        // 0. PostgreSQL Atomik ACID RPC Denemesi (Tüm işlem tek bir ACID transaction'da commit edilir)
        do {
            let rpcPayload = AtomicInvoicePayload(
                tenant_id: SupabaseService.shared.tenantId,
                idempotency_key: "swift-\(UUID().uuidString)",
                fatura: AtomicFaturaData(
                    uuid: UUID().uuidString,
                    fatura_no: fatura.faturaNo,
                    fatura_turu: fatura.faturaTuru,
                    cari_id: Int(req.cari.id) ?? 0,
                    cari_unvan: req.cari.unvan,
                    tarih: req.tarih,
                    vade_tarihi: req.vadeTarihi,
                    ara_toplam: subtotal,
                    iskonto_toplami: totalIskonto,
                    kdv_toplami: totalKdv,
                    genel_toplam: grandTotal,
                    odeme_durumu: isPaid ? "ODENDI" : "BEKLIYOR",
                    aciklama: req.aciklama
                ),
                detaylar: req.items.map { it in
                    AtomicFaturaDetayData(
                        stok_id: it.stokId != nil ? (Int(it.stokId!) ?? 0) : 0,
                        miktar: it.miktar,
                        birim_fiyat: it.birimFiyat,
                        kdv_orani: it.kdvOrani,
                        kdv_tutari: it.kdvTutari,
                        iskonto_orani: it.iskontoOrani,
                        iskonto_tutari: it.iskontoTutari,
                        net_tutar: it.netTutar
                    )
                },
                stok_hareketler: req.items.compactMap { it in
                    guard let sId = it.stokId, let intStokId = Int(sId) else { return nil }
                    return AtomicStokHareketData(
                        stok_id: intStokId,
                        tarih: req.tarih,
                        islem_turu: isSatis ? "Satış Faturası" : "Alış Faturası",
                        belge_no: req.faturaNo,
                        miktar: it.miktar,
                        birim_fiyat: it.birimFiyat,
                        toplam_tutar: it.netTutar,
                        aciklama: "Fatura No: \(req.faturaNo)"
                    )
                },
                cari_hareketler: [
                    AtomicCariHareketData(
                        cari_id: Int(req.cari.id) ?? 0,
                        tarih: req.tarih,
                        belge_no: req.faturaNo,
                        islem_turu: isSatis ? "Satış Faturası" : "Alış Faturası",
                        borc: isSatis ? grandTotal : 0,
                        alacak: !isSatis ? grandTotal : 0,
                        aciklama: req.aciklama ?? "Fatura Kesildi"
                    )
                ]
            )
            
            let res: AtomicRpcResponse = try await SupabaseService.shared.rpc(
                function: "save_invoice_atomic",
                params: AtomicRpcWrapper(p_payload: rpcPayload)
            )
            if res.success {
                print("[TransactionService] Fatura PostgreSQL atomik RPC ile tek ACID transaction'da kaydedildi.")
                return fatura
            }
        } catch {
            print("[TransactionService] Atomik RPC ulasilamadi veya basarisiz (\(error.localizedDescription)), siralı REST kayit fallback'e geciliyor...")
        }

        // 1. Faturayı Kaydet (Fallback Sıralı Kayıt)
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
                    try await SupabaseService.shared.update(table: "stoklar", id: stokId, item: StokMiktarUpdate(mevcutMiktar: yeniMiktar))
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
            item: CariBakiyeUpdate(bakiye: abs(sonBakiye), bakiyeTuru: sonBakiye >= 0 ? "A" : "B")
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
                    try await SupabaseService.shared.update(table: "stoklar", id: stId, item: StokMiktarUpdate(mevcutMiktar: yeniMiktar))
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
                    item: CariBakiyeUpdate(bakiye: abs(revertBakiye), bakiyeTuru: revertBakiye >= 0 ? "A" : "B")
                )
            }
        }
        
        // 5. Faturayı sil
        try await SupabaseService.shared.delete(table: "faturalar", id: fatura.id)
        return true
    }
}

