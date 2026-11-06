import Foundation

// MARK: - Transaction Request Models
public struct FinancialTransactionRequest {
    public var id: Int?
    public var cari: CariKart
    public var transactionType: String // "Tahsilat", "Ödeme", "Borç Dekontu", "Alacak Dekontu", "Borçlandır", "Alacaklandır"
    public var method: String // "Nakit", "Kredi Kartı", "Havale / EFT", "Çek / Senet"
    public var amount: Double
    public var date: String
    public var description: String
    public var selectedHesap: KasaBanka?
    public var isAcilisFisi: Bool
    
    public init(
        id: Int? = nil,
        cari: CariKart,
        transactionType: String,
        method: String,
        amount: Double,
        date: String = AppFormatters.isoDate.string(from: Date()),
        description: String = "",
        selectedHesap: KasaBanka? = nil,
        isAcilisFisi: Bool = false
    ) {
        self.id = id
        self.cari = cari
        self.transactionType = transactionType
        self.method = method
        self.amount = amount
        self.date = date
        self.description = description
        self.selectedHesap = selectedHesap
        self.isAcilisFisi = isAcilisFisi
    }
}

public struct InvoiceTransactionRequest {
    public var id: Int?
    public var faturaNo: String
    public var tarih: String
    public var vadeTarihi: String?
    public var cari: CariKart
    public var tur: String // "Satış", "Alış"
    public var durum: String // "Açık", "Kapalı"
    public var odemeSekli: String // "Açık Hesap", "Nakit", "Kredi Kartı", "Banka Havalesi"
    public var kasaId: String?
    public var bankaId: String?
    public var dovizTuru: String
    public var dovizKuru: Double
    public var baglantiEvrakNo: String?
    public var aciklama: String?
    public var items: [FaturaKalem]
    
    public init(
        id: Int? = nil,
        faturaNo: String,
        tarih: String,
        vadeTarihi: String? = nil,
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

// MARK: - PostgREST Strict Insert Payloads (INTEGER NOT NULL ve Foreign Key Uyumlu)
private struct FaturaInsertPayload: Encodable {
    let id: Int
    let fatura_no: String
    let fatura_turu: String
    let cari_id: Int?
    let cari_unvan: String?
    let tarih: String
    let vade_tarihi: String?
    let ara_toplam: Double
    let kdv_toplam: Double
    let iskonto_toplam: Double
    let genel_toplam: Double
    let odeme_durumu: String
    let durum: String
    let aciklama: String?
    let tenant_id: String
    let uuid: String
    let version: Int
}

private struct FaturaDetayInsertPayload: Encodable {
    let id: Int
    let fatura_id: Int
    let stok_id: Int?
    let stok_kodu: String?
    let stok_adi: String?
    let miktar: Double
    let birim: String
    let birim_fiyat: Double
    let kdv_orani: Double
    let kdv_tutari: Double
    let iskonto_orani: Double
    let iskonto_tutari: Double
    let toplam_tutar: Double
    let aciklama: String?
    let tenant_id: String
    let uuid: String
    let version: Int
}

private struct StokHareketStrictPayload: Encodable {
    let id: Int
    let stok_id: Int?
    let tarih: String
    let islem_turu: String
    let hareket_turu: String
    let hareket_tipi: String
    let giren: Double
    let cikan: Double
    let evrak_no: String
    let miktar: Double
    let birim_fiyat: Double
    let toplam_tutar: Double
    let fatura_id: Int
    let cari_id: Int?
    let aciklama: String?
    let tenant_id: String
    let uuid: String
}

private struct CariHareketStrictPayload: Encodable {
    let id: Int
    let cari_id: Int?
    let tarih: String
    let evrak_no: String
    let belge_no: String
    let islem_turu: String
    let borc: Double
    let alacak: Double
    let bakiye: Double
    let fatura_id: Int
    let aciklama: String?
    let tenant_id: String
    let uuid: String
    var device_id: String = "iPhone-App"
    var mali_yil: Int = Calendar.current.component(.year, from: Date())
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
        let chId = req.id ?? IdGenerator.generateMobileRecordId()
        let evrakNo = getEvrakNoPrefix(method: req.method) + AppFormatters.isoDate.string(from: Date()).replacingOccurrences(of: "-", with: "") + "\(Int.random(in: 100...999))"
        let isAcilis = req.isAcilisFisi
        
        let islemTuru = isAcilis ? "\(req.transactionType) (Açılış Fişi)" : "\(req.transactionType) (\(req.method))"
        let aciklama = isAcilis ? "[Açılış Fişi] \(req.description)".trimmingCharacters(in: .whitespaces) : "[\(req.method)] \(req.description)".trimmingCharacters(in: .whitespaces)
        
        let cIdInt = Int(req.cari.id)
        
        // 1. Cari Hareket (Strict Integer PK)
        let chPayload = CariHareketStrictPayload(
            id: chId,
            cari_id: cIdInt,
            tarih: req.date,
            evrak_no: evrakNo,
            belge_no: evrakNo,
            islem_turu: islemTuru,
            borc: isOdeme ? req.amount : 0,
            alacak: !isOdeme ? req.amount : 0,
            bakiye: req.cari.bakiye + (isOdeme ? -req.amount : req.amount),
            fatura_id: chId,
            aciklama: aciklama,
            tenant_id: tenantId,
            uuid: UUID().uuidString
        )
        try await SupabaseService.shared.insert(into: "cari_hareketler", item: chPayload)
        
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
            try await SupabaseService.shared.insert(into: isKasa ? "kasa_hareketler" : "banka_hareketler", item: kasaHareket)
            
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
        let currentId = req.id ?? IdGenerator.generateMobileRecordId()
        let isPaid = req.odemeSekli != "Açık Hesap"
        let isSatis = req.tur == "Satış" || req.tur.contains("SATIS")
        
        let subtotal = req.items.reduce(0.0) { $0 + ($1.miktar * $1.birimFiyat) }
        let totalIskonto = req.items.reduce(0.0) { $0 + $1.iskontoTutari }
        let totalKdv = req.items.reduce(0.0) { $0 + $1.kdvTutari }
        let grandTotal = subtotal - totalIskonto + totalKdv
        
        let cIdInt = Int(req.cari.id)
        let tenantId = SupabaseService.shared.tenantId
        
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
            durum: isPaid ? "Kapalı" : req.durum,
            aciklama: req.aciklama,
            kalemler: req.items,
            syncGuid: UUID().uuidString,
            tenantId: tenantId
        )
        
        // 0. PostgreSQL Atomik ACID RPC Denemesi
        do {
            let rpcPayload = AtomicInvoicePayload(
                tenant_id: tenantId,
                idempotency_key: "swift-\(UUID().uuidString)",
                fatura: AtomicFaturaData(
                    uuid: UUID().uuidString,
                    fatura_no: fatura.faturaNo,
                    fatura_turu: fatura.faturaTuru,
                    cari_id: cIdInt ?? 0,
                    cari_unvan: req.cari.unvan,
                    tarih: req.tarih,
                    vade_tarihi: req.vadeTarihi ?? req.tarih,
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
                stok_hareketler: req.items.compactMap { (it: FaturaKalem) -> AtomicStokHareketData? in
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
                        cari_id: cIdInt ?? 0,
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
            print("[TransactionService] Atomik RPC atlandı veya yok, siralı REST kayit ile devam ediliyor...")
        }

        // 1. Faturayı Kaydet (PostgREST Strict Payload)
        let fPayload = FaturaInsertPayload(
            id: currentId,
            fatura_no: fatura.faturaNo,
            fatura_turu: isSatis ? "Satış" : "Alış",
            cari_id: cIdInt,
            cari_unvan: req.cari.unvan,
            tarih: req.tarih,
            vade_tarihi: req.vadeTarihi,
            ara_toplam: subtotal,
            kdv_toplam: totalKdv,
            iskonto_toplam: totalIskonto,
            genel_toplam: grandTotal,
            odeme_durumu: isPaid ? "Ödendi" : "Bekliyor",
            durum: isPaid ? "Kapalı" : req.durum,
            aciklama: req.aciklama,
            tenant_id: tenantId,
            uuid: UUID().uuidString,
            version: 1
        )
        try await SupabaseService.shared.insert(into: "faturalar", item: fPayload)
        
        // 2. Fatura Detay Kalemlerini Kaydet
        for item in req.items {
            let detailId = IdGenerator.generateMobileRecordId()
            let intStokId = (item.stokId != nil) ? Int(item.stokId!) : nil
            
            let fdPayload = FaturaDetayInsertPayload(
                id: detailId,
                fatura_id: currentId,
                stok_id: intStokId, // Geçerli int veya nil
                stok_kodu: item.stokKodu,
                stok_adi: item.stokAdi,
                miktar: item.miktar,
                birim: item.birim ?? "Adet",
                birim_fiyat: item.birimFiyat,
                kdv_orani: item.kdvOrani,
                kdv_tutari: item.kdvTutari,
                iskonto_orani: item.iskontoOrani,
                iskonto_tutari: item.iskontoTutari,
                toplam_tutar: item.netTutar,
                aciklama: item.aciklama,
                tenant_id: tenantId,
                uuid: UUID().uuidString,
                version: 1
            )
            do {
                try await SupabaseService.shared.insert(into: "fatura_detaylar", item: fdPayload)
            } catch {
                print("[TransactionService] FaturaDetay insert uyarısı: \(error.localizedDescription)")
            }
            
            // 3. Stok Hareketi
            if let sId = intStokId {
                let shId = IdGenerator.generateMobileRecordId()
                let shPayload = StokHareketStrictPayload(
                    id: shId,
                    stok_id: sId,
                    tarih: req.tarih,
                    islem_turu: isSatis ? "Satış Faturası" : "Alış Faturası",
                    hareket_turu: isSatis ? "CIKIS" : "GIRIS",
                    hareket_tipi: isSatis ? "CIKIS" : "GIRIS",
                    giren: !isSatis ? item.miktar : 0,
                    cikan: isSatis ? item.miktar : 0,
                    evrak_no: req.faturaNo,
                    miktar: item.miktar,
                    birim_fiyat: item.birimFiyat,
                    toplam_tutar: item.netTutar,
                    fatura_id: currentId,
                    cari_id: cIdInt,
                    aciklama: "Fatura No: \(req.faturaNo)",
                    tenant_id: tenantId,
                    uuid: UUID().uuidString
                )
                do {
                    try await SupabaseService.shared.insert(into: "stok_hareketler", item: shPayload)
                } catch {
                    print("[TransactionService] StokHareket insert uyarısı: \(error.localizedDescription)")
                }
            }
        }
        
        // 4. Cari Hareket ve Bakiye Güncelle
        let chId = IdGenerator.generateMobileRecordId()
        let chPayload = CariHareketStrictPayload(
            id: chId,
            cari_id: cIdInt,
            tarih: req.tarih,
            evrak_no: req.faturaNo,
            belge_no: req.faturaNo,
            islem_turu: isSatis ? "Satış Faturası" : "Alış Faturası",
            borc: isSatis ? Double(grandTotal) : 0,
            alacak: !isSatis ? Double(grandTotal) : 0,
            bakiye: req.cari.bakiye + (isSatis ? Double(grandTotal) : -Double(grandTotal)),
            fatura_id: currentId,
            aciklama: req.aciklama ?? "Fatura Kesildi",
            tenant_id: tenantId,
            uuid: UUID().uuidString
        )
        do {
            try await SupabaseService.shared.insert(into: "cari_hareketler", item: chPayload)
        } catch {
            print("[TransactionService] CariHareket insert uyarısı: \(error.localizedDescription)")
        }
        
        let deltaBakiye = isSatis ? grandTotal : -grandTotal
        let sonBakiye = req.cari.bakiye + deltaBakiye
        try? await SupabaseService.shared.update(
            table: "cariler",
            id: req.cari.id,
            item: CariBakiyeUpdate(bakiye: abs(sonBakiye), bakiyeTuru: sonBakiye >= 0 ? "A" : "B")
        )
        
        // 5. Eğer Fatura "Kapalı" ise Kasa/Banka Tahsilatı
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
                try? await SupabaseService.shared.insert(into: "kasa_hareketler", item: kh)
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
                try? await SupabaseService.shared.insert(into: "banka_hareketler", item: bh)
            }
        }
        
        return fatura
    }
}
