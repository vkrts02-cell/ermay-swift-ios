import Foundation
#if canImport(UIKit)
import UIKit
import PDFKit
#endif

public final class PDFService {
    public static let shared = PDFService()
    public let cloudPdfUrl: String = "https://ermay-pdf-api-390930978984.europe-west1.run.app"
    
    private init() {}
    
    #if canImport(UIKit)
    // MARK: - 1. FATURA QUEST PDF (Cloud Run & Local Fallback)
    public func fetchOrGenerateFaturaPDF(
        fatura: Fatura,
        kalemler: [FaturaKalem],
        firma: FirmaProfili = FirmaProfili.varsayilan
    ) async -> Data? {
        if let cloudPdf = await fetchCloudFaturaPdf(fatura: fatura, kalemler: kalemler) {
            return cloudPdf
        }
        return generateFaturaPDF(fatura: fatura, firma: firma)
    }
    
    private func fetchCloudFaturaPdf(fatura: Fatura, kalemler: [FaturaKalem]) async -> Data? {
        guard let url = URL(string: "\(cloudPdfUrl)/generate/fatura") else { return nil }
        
        let fId = Int(fatura.id) ?? 1
        let cId = Int(fatura.cariId ?? "0") ?? 0
        
        let faturaDict: [String: Any] = [
            "Id": fId,
            "FaturaNo": fatura.faturaNo,
            "FaturaTuru": fatura.faturaTuru,
            "CariId": cId,
            "CariUnvan": fatura.cariUnvan ?? "Perakende Müşteri",
            "Tarih": fatura.tarih,
            "VadeTarihi": fatura.vadeTarihi ?? "",
            "AraToplam": fatura.araToplam,
            "KdvToplam": fatura.kdvToplami,
            "IskontoToplam": fatura.iskontoToplami,
            "GenelToplam": fatura.genelToplam,
            "Aciklama": fatura.aciklama ?? ""
        ]
        
        let detaylarArray: [[String: Any]] = kalemler.enumerated().map { idx, k in
            let stId = Int(k.stokId ?? "") ?? (idx + 1)
            return [
                "Id": idx + 1,
                "FaturaId": fId,
                "StokId": stId,
                "StokKodu": k.stokKodu ?? "STK-\(idx + 1)",
                "StokAdi": k.stokAdi,
                "Miktar": k.miktar,
                "Birim": k.birim,
                "BirimFiyat": k.birimFiyat,
                "KdvOrani": k.kdvOrani,
                "ToplamTutar": k.toplamTutar
            ]
        }
        
        let payload: [String: Any] = [
            "Fatura": faturaDict,
            "Detaylar": detaylarArray,
            "ShowLogo": false
        ]
        
        return await postToCloudRun(url: url, payload: payload)
    }
    
    // MARK: - 2. TEKLİF QUEST PDF (Cloud Run & Local Fallback)
    public func fetchOrGenerateTeklifPDF(
        teklif: Teklif,
        kalemler: [TeklifKalem],
        cari: CariKart? = nil,
        firma: FirmaProfili = FirmaProfili.varsayilan
    ) async -> Data? {
        if let cloudPdf = await fetchCloudTeklifPdf(teklif: teklif, kalemler: kalemler, cari: cari) {
            return cloudPdf
        }
        return generateTeklifPDF(teklif: teklif, kalemler: kalemler, cari: cari, firma: firma)
    }
    
    private func fetchCloudTeklifPdf(teklif: Teklif, kalemler: [TeklifKalem], cari: CariKart?) async -> Data? {
        guard let url = URL(string: "\(cloudPdfUrl)/generate/teklif") else { return nil }
        
        let tId = Int(teklif.id) ?? 1
        let cId = Int(teklif.cariId ?? "0") ?? 0
        
        let teklifDict: [String: Any] = [
            "Id": tId,
            "TeklifNo": teklif.teklifNo,
            "CariId": cId,
            "CariUnvan": teklif.cariUnvan ?? (cari?.unvan ?? "Müşteri"),
            "Tarih": teklif.tarih,
            "GecerlilikTarihi": teklif.gecerlilikTarihi ?? "",
            "AraToplam": teklif.araToplam,
            "KdvToplam": teklif.kdvToplami,
            "GenelToplam": teklif.genelToplam,
            "Aciklama": teklif.aciklama ?? ""
        ]
        
        let detaylarArray: [[String: Any]] = kalemler.enumerated().map { idx, k in
            let stId = Int(k.stokId ?? "") ?? (idx + 1)
            return [
                "Id": idx + 1,
                "TeklifId": tId,
                "StokId": stId,
                "StokKodu": k.stokKodu ?? "STK-\(idx + 1)",
                "StokAdi": k.stokAdi,
                "Miktar": k.miktar,
                "Birim": k.birim,
                "BirimFiyat": k.birimFiyat,
                "KdvOrani": k.kdvOrani,
                "ToplamTutar": k.toplamTutar
            ]
        }
        
        var payload: [String: Any] = [
            "Teklif": teklifDict,
            "Detaylar": detaylarArray,
            "ShowLogo": false
        ]
        
        if let c = cari {
            payload["Cari"] = [
                "Id": Int(c.id) ?? cId,
                "Unvan": c.unvan,
                "CariKodu": c.cariKodu ?? "",
                "VergiDairesi": c.vergiDairesi ?? "",
                "VergiNo": c.vergiNo ?? "",
                "Telefon": c.telefon ?? ""
            ]
        }
        
        return await postToCloudRun(url: url, payload: payload)
    }
    
    // MARK: - 3. SİPARİŞ QUEST PDF (Cloud Run & Local Fallback)
    public func fetchOrGenerateSiparisPDF(
        siparis: Siparis,
        kalemler: [SiparisKalem],
        cari: CariKart? = nil,
        firma: FirmaProfili = FirmaProfili.varsayilan
    ) async -> Data? {
        if let cloudPdf = await fetchCloudSiparisPdf(siparis: siparis, kalemler: kalemler, cari: cari) {
            return cloudPdf
        }
        return generateSiparisPDF(siparis: siparis, kalemler: kalemler, cari: cari, firma: firma)
    }
    
    private func fetchCloudSiparisPdf(siparis: Siparis, kalemler: [SiparisKalem], cari: CariKart?) async -> Data? {
        guard let url = URL(string: "\(cloudPdfUrl)/generate/siparis") else { return nil }
        
        let sId = Int(siparis.id) ?? 1
        let cId = Int(siparis.cariId ?? "0") ?? 0
        
        let siparisDict: [String: Any] = [
            "Id": sId,
            "SiparisNo": siparis.siparisNo,
            "SiparisTuru": siparis.siparisTuru,
            "CariId": cId,
            "CariUnvan": siparis.cariUnvan ?? (cari?.unvan ?? "Müşteri"),
            "Tarih": siparis.tarih,
            "TeslimTarihi": siparis.teslimTarihi ?? "",
            "AraToplam": siparis.araToplam,
            "KdvToplam": siparis.kdvToplami,
            "GenelToplam": siparis.genelToplam,
            "Aciklama": siparis.aciklama ?? ""
        ]
        
        let detaylarArray: [[String: Any]] = kalemler.enumerated().map { idx, k in
            let stId = Int(k.stokId ?? "") ?? (idx + 1)
            return [
                "Id": idx + 1,
                "SiparisId": sId,
                "StokId": stId,
                "StokKodu": k.stokKodu ?? "STK-\(idx + 1)",
                "StokAdi": k.stokAdi,
                "Miktar": k.miktar,
                "Birim": k.birim,
                "BirimFiyat": k.birimFiyat,
                "KdvOrani": k.kdvOrani,
                "ToplamTutar": k.toplamTutar
            ]
        }
        
        var payload: [String: Any] = [
            "Siparis": siparisDict,
            "Detaylar": detaylarArray,
            "ShowLogo": false
        ]
        
        if let c = cari {
            payload["Cari"] = [
                "Id": Int(c.id) ?? cId,
                "Unvan": c.unvan,
                "CariKodu": c.cariKodu ?? "",
                "VergiDairesi": c.vergiDairesi ?? "",
                "VergiNo": c.vergiNo ?? "",
                "Telefon": c.telefon ?? ""
            ]
        }
        
        return await postToCloudRun(url: url, payload: payload)
    }
    
    // MARK: - 4. CARİ EKSTRE & DETAYLI EKSTRE (Cloud Run & Local Fallback)
    public func fetchOrGenerateCariEkstrePDF(
        cari: CariKart,
        hareketler: [CariHareket],
        detayli: Bool = false,
        firma: FirmaProfili = FirmaProfili.varsayilan
    ) async -> Data? {
        if let cloudPdf = await fetchCloudQuestPdf(cari: cari, hareketler: hareketler, detayli: detayli) {
            return cloudPdf
        }
        return generateCariEkstrePDF(cari: cari, hareketler: hareketler, detayli: detayli, firma: firma)
    }
    
    private func fetchCloudQuestPdf(
        cari: CariKart,
        hareketler: [CariHareket],
        detayli: Bool
    ) async -> Data? {
        let endpoint = detayli ? "ekstre-detayli" : "ekstre"
        guard let url = URL(string: "\(cloudPdfUrl)/generate/\(endpoint)") else {
            return nil
        }
        
        let cId = Int(cari.id) ?? 1
        let cariDict: [String: Any] = [
            "Id": cId,
            "Unvan": cari.unvan,
            "CariKodu": cari.cariKodu ?? "",
            "VergiDairesi": cari.vergiDairesi ?? "",
            "VergiNo": cari.vergiNo ?? "",
            "Telefon": cari.telefon ?? "",
            "Email": cari.email ?? "",
            "Yetkili": cari.yetkili ?? "",
            "Bakiye": cari.bakiye
        ]
        
        let hareketlerArray: [[String: Any]] = hareketler.enumerated().map { idx, h in
            var dict: [String: Any] = [
                "Id": idx + 1,
                "CariId": cId,
                "Tarih": h.tarih ?? ISO8601DateFormatter().string(from: Date()),
                "IslemTuru": h.islemTuru ?? "İşlem",
                "Aciklama": h.aciklama ?? "-",
                "Borc": h.borc,
                "Alacak": h.alacak,
                "Bakiye": h.bakiye,
                "EvrakNo": h.belgeNo ?? ""
            ]
            if let fIdStr = h.belgeNo?.replacingOccurrences(of: "FT-", with: "").replacingOccurrences(of: "MB-", with: "").replacingOccurrences(of: "FTR-", with: ""),
               let fId = Int(fIdStr) {
                dict["FaturaId"] = fId
            } else {
                dict["FaturaId"] = idx + 100
            }
            return dict
        }
        
        var requestPayload: [String: Any] = [
            "Cari": cariDict,
            "Hareketler": hareketlerArray,
            "ShowLogo": false
        ]
        
        if detayli {
            var detayDict: [String: [[String: Any]]] = [:]
            for (idx, h) in hareketler.enumerated() {
                let fId: Int
                if let fIdStr = h.belgeNo?.replacingOccurrences(of: "FT-", with: "").replacingOccurrences(of: "MB-", with: "").replacingOccurrences(of: "FTR-", with: ""),
                   let parsed = Int(fIdStr) {
                    fId = parsed
                } else {
                    fId = idx + 100
                }
                
                let isSale = h.borc > 0
                let tutar = isSale ? h.borc : h.alacak
                let item: [String: Any] = [
                    "StokAdi": h.aciklama ?? (isSale ? "Hizmet / Satış Kalemi" : "İşlem Kalemi"),
                    "StokKodu": h.belgeNo ?? "STK-\(idx + 1)",
                    "Miktar": 1.0,
                    "Birim": "Adet",
                    "BirimFiyat": tutar,
                    "KdvOrani": 20,
                    "ToplamTutar": tutar
                ]
                detayDict["\(fId)"] = [item]
            }
            requestPayload["DetayDictionary"] = detayDict
        }
        
        return await postToCloudRun(url: url, payload: requestPayload)
    }
    
    // MARK: - 5. GENERİC RAPOR QUEST PDF (31+ Rapor)
    public func fetchOrGenerateReportPDF(
        title: String,
        category: String,
        headers: [String],
        rows: [[String]],
        dateFilter: String,
        cariName: String? = nil,
        isHeatmap: Bool = false,
        firma: FirmaProfili = FirmaProfili.varsayilan
    ) async -> Data? {
        return await fetchOrGenerateGenericReportPDF(
            title: title,
            category: category,
            headers: headers,
            rows: rows,
            dateFilter: dateFilter,
            cariName: cariName,
            isHeatmap: isHeatmap,
            firma: firma
        )
    }

    public func fetchOrGenerateGenericReportPDF(
        title: String,
        category: String,
        headers: [String],
        rows: [[String]],
        dateFilter: String,
        cariName: String? = nil,
        isHeatmap: Bool = false,
        firma: FirmaProfili = FirmaProfili.varsayilan
    ) async -> Data? {
        if let cloudPdf = await fetchCloudGenericReportPdf(title: title, headers: headers, rows: rows, subtitle: "Dönem: \(dateFilter)") {
            return cloudPdf
        }
        return generateReportPDF(
            title: title,
            category: category,
            headers: headers,
            rows: rows,
            dateFilter: dateFilter,
            cariName: cariName,
            isHeatmap: isHeatmap,
            firma: firma
        )
    }
    
    private func fetchCloudGenericReportPdf(
        title: String,
        headers: [String],
        rows: [[String]],
        subtitle: String
    ) async -> Data? {
        guard let url = URL(string: "\(cloudPdfUrl)/generate/generic") else { return nil }
        
        let payload: [String: Any] = [
            "Title": title.uppercased(with: Locale(identifier: "tr_TR")),
            "Headers": headers,
            "Rows": rows,
            "Subtitle": subtitle,
            "ShowLogo": false
        ]
        
        return await postToCloudRun(url: url, payload: payload)
    }
    
    // MARK: - 6. MAKBUZ QUEST PDF
    public func fetchOrGenerateMakbuzPDF(
        makbuzTipi: String?,
        cariUnvan: String?,
        tarih: String,
        tutar: Double,
        aciklama: String?,
        firma: FirmaProfili = FirmaProfili.varsayilan
    ) async -> Data? {
        guard let url = URL(string: "\(cloudPdfUrl)/generate/makbuz") else { return nil }
        let payload: [String: Any] = [
            "MakbuzTipi": makbuzTipi ?? "Tahsilat",
            "CariUnvan": cariUnvan ?? "Cari",
            "Tarih": tarih,
            "Tutar": tutar,
            "Aciklama": aciklama ?? "",
            "ShowLogo": false
        ]
        if let cloud = await postToCloudRun(url: url, payload: payload) {
            return cloud
        }
        // Fallback generic makbuz
        return generateReportPDF(
            title: "\(makbuzTipi ?? "Tahsilat") Makbuzu",
            category: "Finans",
            headers: ["Cari Ünvan", "Tarih", "Açıklama", "Tutar"],
            rows: [[cariUnvan ?? "-", tarih, aciklama ?? "-", "₺\(String(format: "%.2f", tutar))"]],
            dateFilter: "Bugün",
            firma: firma
        )
    }
    
    // MARK: - Universal Cloud Run POST Worker
    private func postToCloudRun(url: URL, payload: [String: Any]) async -> Data? {
        guard let httpBody = try? JSONSerialization.data(withJSONObject: payload, options: []) else {
            return nil
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = httpBody
        request.timeoutInterval = 10.0
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            if let httpRes = response as? HTTPURLResponse, httpRes.statusCode == 200, data.count > 500 {
                if let prefix = String(data: data.prefix(5), encoding: .ascii), prefix.hasPrefix("%PDF") {
                    print("[PDFService] Cloud QuestPDF başarıyla üretildi: \(url.lastPathComponent) (\(data.count) bytes).")
                    return data
                }
            } else if let httpRes = response as? HTTPURLResponse {
                print("[PDFService] Cloud QuestPDF status code: \(httpRes.statusCode)")
            }
        } catch {
            print("[PDFService] Cloud QuestPDF hatası: \(error.localizedDescription)")
        }
        return nil
    }
    
    // MARK: - Local Fallback PDF Renderers
    public func generateFaturaPDF(fatura: Fatura, firma: FirmaProfili = FirmaProfili.varsayilan) -> Data? {
        let pdfMetaData = [
            kCGPDFContextCreator: "Ermay Muhasebe Mobil",
            kCGPDFContextAuthor: firma.firmaAdi,
            kCGPDFContextTitle: "Fatura - \(fatura.faturaNo)"
        ]
        let format = UIGraphicsPDFRendererFormat()
        format.documentInfo = pdfMetaData as [String: Any]
        
        let pageWidth: CGFloat = 595.2 // A4 portrait
        let pageHeight: CGFloat = 841.8
        let pageRect = CGRect(x: 0, y: 0, width: pageWidth, height: pageHeight)
        
        let renderer = UIGraphicsPDFRenderer(bounds: pageRect, format: format)
        
        let data = renderer.pdfData { (context) in
            context.beginPage()
            
            let titleFont = UIFont.boldSystemFont(ofSize: 20)
            let bodyFont = UIFont.systemFont(ofSize: 10)
            let boldFont = UIFont.boldSystemFont(ofSize: 10)
            
            // Firma Başlığı
            let titleAttributes: [NSAttributedString.Key: Any] = [.font: titleFont, .foregroundColor: UIColor.black]
            (firma.firmaAdi as NSString).draw(at: CGPoint(x: 36, y: 36), withAttributes: titleAttributes)
            
            let firmaSub = "\(firma.unvan)\nVergi No: \(firma.vergiNo ?? "-") | VD: \(firma.vergiDairesi ?? "-")\nTel: \(firma.telefon ?? "-")"
            (firmaSub as NSString).draw(at: CGPoint(x: 36, y: 64), withAttributes: [.font: bodyFont, .foregroundColor: UIColor.darkGray])
            
            // Belge Bilgileri
            let docInfo = "FATURA NO: \(fatura.faturaNo)\nTARİH: \(fatura.tarih)\nVADE: \(fatura.vadeTarihi ?? "-")\nTÜR: \(fatura.faturaTuru)"
            let docInfoRect = CGRect(x: 350, y: 36, width: 210, height: 70)
            (docInfo as NSString).draw(in: docInfoRect, withAttributes: [.font: boldFont, .foregroundColor: UIColor.black])
            
            // Müşteri Bilgileri
            let cariBox = CGRect(x: 36, y: 130, width: 523, height: 60)
            let path = UIBezierPath(roundedRect: cariBox, cornerRadius: 4)
            UIColor.systemGray6.setFill()
            path.fill()
            
            let cariTitle = "SAYIN: \(fatura.cariUnvan ?? "Perakende Müşteri")"
            (cariTitle as NSString).draw(at: CGPoint(x: 48, y: 140), withAttributes: [.font: boldFont, .foregroundColor: UIColor.black])
            
            // Kalemler Tablosu
            let tableHeaderY: CGFloat = 205
            let headerBg = CGRect(x: 36, y: tableHeaderY, width: 523, height: 24)
            UIColor(red: 0/255, green: 97/255, blue: 255/255, alpha: 1.0).setFill()
            UIBezierPath(rect: headerBg).fill()
            
            let headerAttributes: [NSAttributedString.Key: Any] = [.font: boldFont, .foregroundColor: UIColor.white]
            ("ÜRÜN / AÇIKLAMA" as NSString).draw(at: CGPoint(x: 44, y: tableHeaderY + 6), withAttributes: headerAttributes)
            ("MİKTAR" as NSString).draw(at: CGPoint(x: 280, y: tableHeaderY + 6), withAttributes: headerAttributes)
            ("B.FİYAT" as NSString).draw(at: CGPoint(x: 360, y: tableHeaderY + 6), withAttributes: headerAttributes)
            ("KDV" as NSString).draw(at: CGPoint(x: 430, y: tableHeaderY + 6), withAttributes: headerAttributes)
            ("TUTAR" as NSString).draw(at: CGPoint(x: 485, y: tableHeaderY + 6), withAttributes: headerAttributes)
            
            var currentY = tableHeaderY + 30
            if let kalemler = fatura.kalemler {
                for item in kalemler {
                    (item.stokAdi as NSString).draw(at: CGPoint(x: 44, y: currentY), withAttributes: [.font: bodyFont, .foregroundColor: UIColor.black])
                    ("\(String(format: "%.2f", item.miktar)) \(item.birim)" as NSString).draw(at: CGPoint(x: 280, y: currentY), withAttributes: [.font: bodyFont, .foregroundColor: UIColor.black])
                    ("₺\(String(format: "%.2f", item.birimFiyat))" as NSString).draw(at: CGPoint(x: 360, y: currentY), withAttributes: [.font: bodyFont, .foregroundColor: UIColor.black])
                    ("%\(Int(item.kdvOrani))" as NSString).draw(at: CGPoint(x: 430, y: currentY), withAttributes: [.font: bodyFont, .foregroundColor: UIColor.black])
                    ("₺\(String(format: "%.2f", item.toplamTutar))" as NSString).draw(at: CGPoint(x: 485, y: currentY), withAttributes: [.font: boldFont, .foregroundColor: UIColor.black])
                    currentY += 20
                }
            }
            
            // Dip Toplamlar
            let totalsY = max(currentY + 20, 680)
            let totalsBox = CGRect(x: 350, y: totalsY, width: 210, height: 90)
            let tPath = UIBezierPath(roundedRect: totalsBox, cornerRadius: 4)
            UIColor.systemGray6.setFill()
            tPath.fill()
            
            ("Ara Toplam: ₺\(String(format: "%.2f", fatura.araToplam))" as NSString).draw(at: CGPoint(x: 360, y: totalsY + 12), withAttributes: [.font: bodyFont, .foregroundColor: UIColor.black])
            ("KDV Toplamı: ₺\(String(format: "%.2f", fatura.kdvToplami))" as NSString).draw(at: CGPoint(x: 360, y: totalsY + 32), withAttributes: [.font: bodyFont, .foregroundColor: UIColor.black])
            ("GENEL TOPLAM: ₺\(String(format: "%.2f", fatura.genelToplam))" as NSString).draw(at: CGPoint(x: 360, y: totalsY + 56), withAttributes: [.font: UIFont.boldSystemFont(ofSize: 12), .foregroundColor: UIColor(red: 0/255, green: 97/255, blue: 255/255, alpha: 1.0)])
        }
        
        return data
    }
    
    public func generateTeklifPDF(
        teklif: Teklif,
        kalemler: [TeklifKalem],
        cari: CariKart?,
        firma: FirmaProfili = FirmaProfili.varsayilan
    ) -> Data? {
        let dummyFatura = Fatura(
            id: teklif.id,
            faturaNo: teklif.teklifNo,
            faturaTuru: "Teklif",
            cariId: teklif.cariId,
            cariUnvan: teklif.cariUnvan ?? cari?.unvan,
            tarih: teklif.tarih,
            vadeTarihi: teklif.gecerlilikTarihi,
            araToplam: teklif.araToplam,
            kdvToplami: teklif.kdvToplami,
            iskontoToplami: 0,
            genelToplam: teklif.genelToplam,
            kalemler: kalemler.map { FaturaKalem(stokId: $0.stokId, stokKodu: $0.stokKodu, stokAdi: $0.stokAdi, miktar: $0.miktar, birim: $0.birim ?? "Adet", birimFiyat: $0.birimFiyat, kdvOrani: $0.kdvOrani, toplamTutar: $0.toplamTutar) }
        )
        return generateFaturaPDF(fatura: dummyFatura, firma: firma)
    }
    
    public func generateSiparisPDF(
        siparis: Siparis,
        kalemler: [SiparisKalem],
        cari: CariKart?,
        firma: FirmaProfili = FirmaProfili.varsayilan
    ) -> Data? {
        let dummyFatura = Fatura(
            id: siparis.id,
            faturaNo: siparis.siparisNo,
            faturaTuru: "Sipariş",
            cariId: siparis.cariId,
            cariUnvan: siparis.cariUnvan ?? cari?.unvan,
            tarih: siparis.tarih,
            vadeTarihi: siparis.teslimTarihi,
            araToplam: siparis.araToplam,
            kdvToplami: siparis.kdvToplami,
            iskontoToplami: siparis.iskontoToplami,
            genelToplam: siparis.genelToplam,
            kalemler: kalemler.map { FaturaKalem(stokId: $0.stokId, stokKodu: $0.stokKodu, stokAdi: $0.stokAdi, miktar: $0.miktar, birim: $0.birim ?? "Adet", birimFiyat: $0.birimFiyat, kdvOrani: $0.kdvOrani, toplamTutar: $0.toplamTutar) }
        )
        return generateFaturaPDF(fatura: dummyFatura, firma: firma)
    }
    
    public func generateReportPDF(
        title: String,
        category: String,
        headers: [String],
        rows: [[String]],
        dateFilter: String,
        cariName: String? = nil,
        isHeatmap: Bool = false,
        firma: FirmaProfili = FirmaProfili.varsayilan
    ) -> Data? {
        let pdfMetaData = [
            kCGPDFContextCreator: "Ermay Muhasebe Mobil",
            kCGPDFContextAuthor: firma.firmaAdi,
            kCGPDFContextTitle: "\(title) - Rapor"
        ]
        let format = UIGraphicsPDFRendererFormat()
        format.documentInfo = pdfMetaData as [String: Any]
        
        let pageWidth: CGFloat = 595.2 // A4 portrait
        let pageHeight: CGFloat = 841.8
        let pageRect = CGRect(x: 0, y: 0, width: pageWidth, height: pageHeight)
        
        let renderer = UIGraphicsPDFRenderer(bounds: pageRect, format: format)
        
        let data = renderer.pdfData { (context) in
            context.beginPage()
            
            let titleFont = UIFont.boldSystemFont(ofSize: 16)
            let subTitleFont = UIFont.systemFont(ofSize: 9)
            let headerFont = UIFont.boldSystemFont(ofSize: 9)
            let cellFont = UIFont.systemFont(ofSize: 8.5)
            
            // Üst Başlık & Firma Bilgileri
            let headerBg = CGRect(x: 30, y: 28, width: 535, height: 60)
            UIColor(red: 15/255, green: 23/255, blue: 42/255, alpha: 1.0).setFill()
            UIBezierPath(roundedRect: headerBg, cornerRadius: 8).fill()
            
            let brandAttributes: [NSAttributedString.Key: Any] = [.font: titleFont, .foregroundColor: UIColor.white]
            (firma.firmaAdi as NSString).draw(at: CGPoint(x: 42, y: 38), withAttributes: brandAttributes)
            
            let brandSub = "\(firma.unvan) • \(firma.telefon ?? "")"
            (brandSub as NSString).draw(at: CGPoint(x: 42, y: 62), withAttributes: [.font: subTitleFont, .foregroundColor: UIColor(white: 0.8, alpha: 1.0)])
            
            let dateStr = "Tarih: \(ISO8601DateFormatter().string(from: Date()).prefix(10))\nDönem: \(dateFilter == "All" ? "Tüm Zamanlar" : dateFilter)"
            let dateRect = CGRect(x: 380, y: 38, width: 175, height: 40)
            (dateStr as NSString).draw(in: dateRect, withAttributes: [.font: subTitleFont, .foregroundColor: UIColor(white: 0.85, alpha: 1.0)])
            
            // Rapor Başlığı & Kategori
            var startY: CGFloat = 100
            let rTitle = title.uppercased()
            (rTitle as NSString).draw(at: CGPoint(x: 32, y: startY), withAttributes: [.font: UIFont.boldSystemFont(ofSize: 14), .foregroundColor: UIColor(red: 37/255, green: 99/255, blue: 235/255, alpha: 1.0)])
            
            var metaText = "Kategori: \(category)"
            if let c = cariName, !c.isEmpty {
                metaText += " | Filtre: \(c)"
            }
            (metaText as NSString).draw(at: CGPoint(x: 32, y: startY + 20), withAttributes: [.font: subTitleFont, .foregroundColor: UIColor.darkGray])
            
            startY += 40
            
            // Tablo Çizimi
            let tableLeft: CGFloat = 30
            let tableWidth: CGFloat = 535
            let colCount = max(headers.count, 1)
            let colWidth = tableWidth / CGFloat(colCount)
            
            // Header Satırı
            let thRect = CGRect(x: tableLeft, y: startY, width: tableWidth, height: 22)
            UIColor(red: 241/255, green: 245/255, blue: 249/255, alpha: 1.0).setFill()
            UIBezierPath(roundedRect: thRect, cornerRadius: 4).fill()
            
            for (idx, h) in headers.enumerated() {
                let colX = tableLeft + (CGFloat(idx) * colWidth) + 4
                (h as NSString).draw(at: CGPoint(x: colX, y: startY + 5), withAttributes: [.font: headerFont, .foregroundColor: UIColor(red: 15/255, green: 23/255, blue: 42/255, alpha: 1.0)])
            }
            startY += 26
            
            // Satırlar
            for (_, row) in rows.prefix(35).enumerated() {
                let rowRect = CGRect(x: tableLeft, y: startY, width: tableWidth, height: 18)
                UIColor.white.setFill()
                UIBezierPath(rect: rowRect).fill()
                
                for (colIdx, val) in row.enumerated() {
                    let colX = tableLeft + (CGFloat(colIdx) * colWidth) + 4
                    (val as NSString).draw(
                        in: CGRect(x: colX, y: startY + 2, width: colWidth - 8, height: 16),
                        withAttributes: [.font: cellFont, .foregroundColor: UIColor(red: 51/255, green: 65/255, blue: 85/255, alpha: 1.0)]
                    )
                }
                
                UIColor(white: 0.9, alpha: 1.0).setStroke()
                let line = UIBezierPath()
                line.move(to: CGPoint(x: tableLeft, y: startY + 18))
                line.addLine(to: CGPoint(x: tableLeft + tableWidth, y: startY + 18))
                line.lineWidth = 0.5
                line.stroke()
                
                startY += 19
            }
        }
        return data
    }
    
    public func generateCariEkstrePDF(
        cari: CariKart,
        hareketler: [CariHareket],
        detayli: Bool = false,
        firma: FirmaProfili = FirmaProfili.varsayilan
    ) -> Data? {
        let pdfMetaData = [
            kCGPDFContextCreator: "Ermay Muhasebe Mobil (QuestPDF Engine)",
            kCGPDFContextAuthor: firma.firmaAdi,
            kCGPDFContextTitle: "\(detayli ? "Detaylı Cari Ekstresi" : "Cari Hesap Ekstresi") - \(cari.unvan)"
        ]
        let format = UIGraphicsPDFRendererFormat()
        format.documentInfo = pdfMetaData as [String: Any]
        
        let pageWidth: CGFloat = 595.2 // A4 portrait
        let pageHeight: CGFloat = 841.8
        let pageRect = CGRect(x: 0, y: 0, width: pageWidth, height: pageHeight)
        
        let renderer = UIGraphicsPDFRenderer(bounds: pageRect, format: format)
        
        let data = renderer.pdfData { (context) in
            context.beginPage()
            
            let margin: CGFloat = 28
            let usableWidth = pageWidth - (margin * 2)
            
            let fontBrand = UIFont.boldSystemFont(ofSize: 14)
            let fontSub = UIFont.systemFont(ofSize: 8)
            let fontTitle = UIFont.boldSystemFont(ofSize: 11)
            let fontBold9 = UIFont.boldSystemFont(ofSize: 9)
            let fontReg9 = UIFont.systemFont(ofSize: 9)
            let fontBold8 = UIFont.boldSystemFont(ofSize: 8)
            let fontReg8 = UIFont.systemFont(ofSize: 8)
            let fontBadge = UIFont.boldSystemFont(ofSize: 7.5)
            let fontSubBold = UIFont.boldSystemFont(ofSize: 7.5)
            
            let colorPrimary = UIColor(red: 47/255, green: 111/255, blue: 237/255, alpha: 1.0)
            let colorCardBg = UIColor(red: 250/255, green: 250/255, blue: 250/255, alpha: 1.0)
            let colorCardBorder = UIColor(red: 221/255, green: 221/255, blue: 221/255, alpha: 1.0)
            let colorHeaderBg = UIColor(red: 249/255, green: 249/255, blue: 249/255, alpha: 1.0)
            let colorBorder = UIColor(red: 238/255, green: 238/255, blue: 238/255, alpha: 1.0)
            let colorMuted = UIColor(red: 102/255, green: 102/255, blue: 102/255, alpha: 1.0)
            let colorRed = UIColor(red: 239/255, green: 68/255, blue: 68/255, alpha: 1.0)
            let colorGreen = UIColor(red: 16/255, green: 185/255, blue: 129/255, alpha: 1.0)
            
            var toplamBorc: Double = 0
            var toplamAlacak: Double = 0
            for h in hareketler {
                toplamBorc += h.borc
                toplamAlacak += h.alacak
            }
            let netBakiye = toplamBorc - toplamAlacak
            
            // Üst Başlık
            let headerY: CGFloat = margin
            (firma.firmaAdi as NSString).draw(
                at: CGPoint(x: margin, y: headerY),
                withAttributes: [.font: fontBrand, .foregroundColor: colorPrimary]
            )
            
            let brandSub = "\(firma.unvan) • \(firma.telefon ?? "")"
            (brandSub as NSString).draw(
                at: CGPoint(x: margin, y: headerY + 18),
                withAttributes: [.font: fontSub, .foregroundColor: colorMuted]
            )
            
            let docTitle = (detayli ? "DETAYLI CARİ HESAP EKSTRESİ" : "CARİ HESAP EKSTRESİ").uppercased(with: Locale(identifier: "tr_TR"))
            let docTitleAttrs: [NSAttributedString.Key: Any] = [
                .font: UIFont.boldSystemFont(ofSize: 12),
                .foregroundColor: UIColor(red: 37/255, green: 99/255, blue: 235/255, alpha: 1.0)
            ]
            let docTitleSize = (docTitle as NSString).size(withAttributes: docTitleAttrs)
            (docTitle as NSString).draw(
                at: CGPoint(x: pageWidth - margin - docTitleSize.width, y: headerY),
                withAttributes: docTitleAttrs
            )
            
            let dateStr = "Tarih: \(ISO8601DateFormatter().string(from: Date()).prefix(10))"
            let dateAttrs: [NSAttributedString.Key: Any] = [.font: fontReg8, .foregroundColor: colorMuted]
            let dateSize = (dateStr as NSString).size(withAttributes: dateAttrs)
            (dateStr as NSString).draw(
                at: CGPoint(x: pageWidth - margin - dateSize.width, y: headerY + 18),
                withAttributes: dateAttrs
            )
            
            var currentY = headerY + 38
            
            // Genel Bilgiler Kartı
            let cardHeight: CGFloat = 82
            let cardRect = CGRect(x: margin, y: currentY, width: usableWidth, height: cardHeight)
            let cardPath = UIBezierPath(roundedRect: cardRect, cornerRadius: 4)
            colorCardBg.setFill()
            cardPath.fill()
            colorCardBorder.setStroke()
            cardPath.lineWidth = 0.5
            cardPath.stroke()
            
            ("Genel Bilgiler" as NSString).draw(
                at: CGPoint(x: margin + 10, y: currentY + 8),
                withAttributes: [.font: fontTitle, .foregroundColor: UIColor.black]
            )
            
            let infoY = currentY + 28
            let col1X = margin + 10
            let col1ValX = margin + 85
            let col2X = margin + 280
            let col2ValX = margin + 360
            
            ("Müşteri Adı:" as NSString).draw(at: CGPoint(x: col1X, y: infoY), withAttributes: [.font: fontBold9, .foregroundColor: UIColor.black])
            (cari.unvan as NSString).draw(in: CGRect(x: col1ValX, y: infoY, width: 180, height: 16), withAttributes: [.font: fontReg9, .foregroundColor: UIColor.black])
            
            ("Toplam Satış:" as NSString).draw(at: CGPoint(x: col2X, y: infoY), withAttributes: [.font: fontBold9, .foregroundColor: UIColor.black])
            ("₺\(String(format: "%.2f", toplamBorc))" as NSString).draw(at: CGPoint(x: col2ValX, y: infoY), withAttributes: [.font: fontReg9, .foregroundColor: UIColor.black])
            
            ("Toplam Ödeme:" as NSString).draw(at: CGPoint(x: col1X, y: infoY + 20), withAttributes: [.font: fontBold9, .foregroundColor: UIColor.black])
            ("₺\(String(format: "%.2f", toplamAlacak))" as NSString).draw(at: CGPoint(x: col1ValX, y: infoY + 20), withAttributes: [.font: fontReg9, .foregroundColor: UIColor.black])
            
            ("Bakiye:" as NSString).draw(at: CGPoint(x: col2X, y: infoY + 20), withAttributes: [.font: fontBold9, .foregroundColor: UIColor.black])
            let bColor = netBakiye > 0 ? colorRed : colorGreen
            let bLabel = netBakiye > 0 ? " (Borçlu)" : " (Alacaklı)"
            let bakiyeString = "₺\(String(format: "%.2f", abs(netBakiye)))\(bLabel)"
            (bakiyeString as NSString).draw(at: CGPoint(x: col2ValX, y: infoY + 20), withAttributes: [.font: fontBold9, .foregroundColor: bColor])
            
            currentY += cardHeight + 12
            
            // Tablo Kolonları
            let colTarihW: CGFloat = usableWidth * 0.12
            let colTipW: CGFloat = usableWidth * 0.11
            let colAciklamaW: CGFloat = usableWidth * 0.37
            let colBorcW: CGFloat = usableWidth * 0.13
            let colAlacakW: CGFloat = usableWidth * 0.13
            let colBakiyeW: CGFloat = usableWidth * 0.14
            
            let xTarih = margin
            let xTip = xTarih + colTarihW
            let xAciklama = xTip + colTipW
            let xBorc = xAciklama + colAciklamaW
            let xAlacak = xBorc + colBorcW
            let xBakiye = xAlacak + colAlacakW
            
            let thHeight: CGFloat = 20
            let thRect = CGRect(x: margin, y: currentY, width: usableWidth, height: thHeight)
            colorHeaderBg.setFill()
            UIBezierPath(rect: thRect).fill()
            colorBorder.setStroke()
            let thBorder = UIBezierPath(rect: thRect)
            thBorder.lineWidth = 0.5
            thBorder.stroke()
            
            let thAttrs: [NSAttributedString.Key: Any] = [.font: fontBold8, .foregroundColor: UIColor.black]
            ("Tarih" as NSString).draw(at: CGPoint(x: xTarih + 4, y: currentY + 4), withAttributes: thAttrs)
            ("İşlem Tipi" as NSString).draw(at: CGPoint(x: xTip + 4, y: currentY + 4), withAttributes: thAttrs)
            ("Açıklama" as NSString).draw(at: CGPoint(x: xAciklama + 4, y: currentY + 4), withAttributes: thAttrs)
            
            let drawR = { (text: String, x: CGFloat, y: CGFloat, attrs: [NSAttributedString.Key: Any]) in
                let sz = (text as NSString).size(withAttributes: attrs)
                (text as NSString).draw(at: CGPoint(x: x - sz.width, y: y), withAttributes: attrs)
            }
            
            drawR("Borç", xBorc + colBorcW - 4, currentY + 4, thAttrs)
            drawR("Alacak", xAlacak + colAlacakW - 4, currentY + 4, thAttrs)
            drawR("Bakiye", xBakiye + colBakiyeW - 4, currentY + 4, thAttrs)
            
            currentY += thHeight
            
            var runningBalance: Double = 0
            for (_, h) in hareketler.enumerated() {
                if currentY > pageHeight - margin - 50 {
                    context.beginPage()
                    currentY = margin + 10
                }
                
                let isSale = h.borc > 0
                runningBalance += (h.borc - h.alacak)
                
                let rowHeight: CGFloat = detayli ? 34 : 20
                
                colorBorder.setStroke()
                let line = UIBezierPath()
                line.move(to: CGPoint(x: margin, y: currentY + rowHeight))
                line.addLine(to: CGPoint(x: margin + usableWidth, y: currentY + rowHeight))
                line.lineWidth = 0.5
                line.stroke()
                
                let dateDisplay = String((h.tarih ?? "-").prefix(10))
                (dateDisplay as NSString).draw(at: CGPoint(x: xTarih + 4, y: currentY + 4), withAttributes: [.font: fontReg8, .foregroundColor: UIColor.black])
                
                let (badgeColor, badgeTitle) = self.resolveBadge(rawTuru: h.islemTuru ?? "")
                let badgeRect = CGRect(x: xTip + 2, y: currentY + 3, width: colTipW - 6, height: 14)
                let badgePath = UIBezierPath(roundedRect: badgeRect, cornerRadius: 3)
                badgeColor.setFill()
                badgePath.fill()
                
                let badgeTitleAttrs: [NSAttributedString.Key: Any] = [.font: fontBadge, .foregroundColor: UIColor.white]
                let bTextSize = (badgeTitle as NSString).size(withAttributes: badgeTitleAttrs)
                (badgeTitle as NSString).draw(
                    at: CGPoint(x: badgeRect.midX - (bTextSize.width / 2), y: badgeRect.midY - (bTextSize.height / 2)),
                    withAttributes: badgeTitleAttrs
                )
                
                var desc = h.aciklama ?? "-"
                (desc as NSString).draw(
                    in: CGRect(x: xAciklama + 4, y: currentY + 4, width: colAciklamaW - 8, height: 14),
                    withAttributes: [.font: fontReg8, .foregroundColor: UIColor.black]
                )
                
                if isSale {
                    drawR("₺\(String(format: "%.2f", h.borc))", xBorc + colBorcW - 4, currentY + 4, [.font: fontBold8, .foregroundColor: colorRed])
                    drawR("-", xAlacak + colAlacakW - 4, currentY + 4, [.font: fontReg8, .foregroundColor: UIColor.gray])
                } else {
                    drawR("-", xBorc + colBorcW - 4, currentY + 4, [.font: fontReg8, .foregroundColor: UIColor.gray])
                    drawR("₺\(String(format: "%.2f", h.alacak))", xAlacak + colAlacakW - 4, currentY + 4, [.font: fontBold8, .foregroundColor: colorGreen])
                }
                
                drawR("₺\(String(format: "%.2f", runningBalance))", xBakiye + colBakiyeW - 4, currentY + 4, [.font: fontBold8, .foregroundColor: UIColor.black])
                
                if detayli {
                    let subY = currentY + 18
                    let subTh = "• Kalemler: \(desc) | Miktar: 1 Adet | KDV: %20 | Tutar: ₺\(String(format: "%.2f", isSale ? h.borc : h.alacak))"
                    (subTh as NSString).draw(
                        in: CGRect(x: margin + 25, y: subY, width: usableWidth - 40, height: 12),
                        withAttributes: [.font: fontSubBold, .foregroundColor: UIColor(white: 0.35, alpha: 1.0)]
                    )
                }
                
                currentY += rowHeight
            }
            
            // Footer
            let footerText = "Ermay Muhasebe • QuestPDF Engine"
            let footerAttrs: [NSAttributedString.Key: Any] = [.font: fontSub, .foregroundColor: colorMuted]
            let footerSize = (footerText as NSString).size(withAttributes: footerAttrs)
            (footerText as NSString).draw(
                at: CGPoint(x: (pageWidth - footerSize.width) / 2, y: pageHeight - margin),
                withAttributes: footerAttrs
            )
        }
        return data
    }
    
    private func resolveBadge(rawTuru: String) -> (UIColor, String) {
        let t = rawTuru.uppercased(with: Locale(identifier: "tr_TR"))
        if t.contains("SATIŞ") || t.contains("SATIS") || t.contains("FATURA") || t.contains("GİRİŞ") || t.contains("GIRIS") {
            return (UIColor(red: 47/255, green: 111/255, blue: 237/255, alpha: 1.0), "Satış")
        } else if t.contains("ALIŞ") || t.contains("ALIS") || t.contains("ÇIKIŞ") || t.contains("CIKIS") {
            return (UIColor(red: 245/255, green: 158/255, blue: 11/255, alpha: 1.0), "Alış")
        } else if t.contains("TAHSİLAT") || t.contains("TAHSILAT") {
            return (UIColor(red: 16/255, green: 185/255, blue: 129/255, alpha: 1.0), "Tahsilat")
        } else if t.contains("ÖDEME") || t.contains("ODEME") {
            return (UIColor(red: 239/255, green: 68/255, blue: 68/255, alpha: 1.0), "Ödeme")
        } else if t.contains("ÇEK") || t.contains("CEK") || t.contains("SENET") {
            return (UIColor(red: 139/255, green: 92/255, blue: 246/255, alpha: 1.0), "Çek/Senet")
        } else {
            return (UIColor(red: 107/255, green: 114/255, blue: 128/255, alpha: 1.0), "İşlem")
        }
    }
    #endif
}
