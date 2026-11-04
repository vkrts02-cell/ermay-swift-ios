import Foundation
#if canImport(UIKit)
import UIKit
import PDFKit
#endif

public final class PDFService {
    public static let shared = PDFService()
    private init() {}
    
    #if canImport(UIKit)
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
            
            // Header
            let titleFont = UIFont.boldSystemFont(ofSize: 20)
            let bodyFont = UIFont.systemFont(ofSize: 10)
            let boldFont = UIFont.boldSystemFont(ofSize: 10)
            
            // Firma Başlığı
            let titleAttributes: [NSAttributedString.Key: Any] = [.font: titleFont, .foregroundColor: UIColor.black]
            (firma.firmaAdi as NSString).draw(at: CGPoint(x: 36, y: 36), withAttributes: titleAttributes)
            
            let firmaSub = "\(firma.unvan)\nVergi No: \(firma.vergiNo ?? "-") | VD: \(firma.vergiDairesi ?? "-")\nTel: \(firma.telefon ?? "-")"
            (firmaSub as NSString).draw(at: CGPoint(x: 36, y: 64), withAttributes: [.font: bodyFont, .foregroundColor: UIColor.darkGray])
            
            // Belge Bilgileri (Sağ üst)
            let docInfo = "FATURA NO: \(fatura.faturaNo)\nTARİH: \(fatura.tarih)\nVADE: \(fatura.vadeTarihi ?? "-")\nTÜR: \(fatura.faturaTuru)"
            let docInfoRect = CGRect(x: 350, y: 36, width: 210, height: 70)
            (docInfo as NSString).draw(in: docInfoRect, withAttributes: [.font: boldFont, .foregroundColor: UIColor.black])
            
            // Müşteri / Cari Bilgileri
            let cariBox = CGRect(x: 36, y: 130, width: 523, height: 60)
            let path = UIBezierPath(roundedRect: cariBox, cornerRadius: 4)
            UIColor.systemGray6.setFill()
            path.fill()
            
            let cariTitle = "SAYIN: \(fatura.cariUnvan ?? "Perakende Müşteri")"
            (cariTitle as NSString).draw(at: CGPoint(x: 48, y: 140), withAttributes: [.font: boldFont, .foregroundColor: UIColor.black])
            
            // Kalemler Tablosu Başlığı
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
                    (item.stokAdi as NSString).draw(at: CGPoint(x: 44, y: currentY), withAttributes: [.font: bodyFont])
                    ("\(String(format: "%.2f", item.miktar)) \(item.birim ?? "")" as NSString).draw(at: CGPoint(x: 280, y: currentY), withAttributes: [.font: bodyFont])
                    (AppFormatters.money(item.birimFiyat) as NSString).draw(at: CGPoint(x: 360, y: currentY), withAttributes: [.font: bodyFont])
                    ("%\(Int(item.kdvOrani))" as NSString).draw(at: CGPoint(x: 430, y: currentY), withAttributes: [.font: bodyFont])
                    (AppFormatters.money(item.netTutar) as NSString).draw(at: CGPoint(x: 485, y: currentY), withAttributes: [.font: boldFont])
                    
                    currentY += 20
                }
            }
            
            // Alt Toplamlar
            let totalsY = max(currentY + 20, 680)
            let rightAlign: CGFloat = 380
            
            ("Ara Toplam:" as NSString).draw(at: CGPoint(x: rightAlign, y: totalsY), withAttributes: [.font: bodyFont])
            (AppFormatters.money(fatura.araToplam) as NSString).draw(at: CGPoint(x: rightAlign + 100, y: totalsY), withAttributes: [.font: bodyFont])
            
            ("KDV Toplamı:" as NSString).draw(at: CGPoint(x: rightAlign, y: totalsY + 18), withAttributes: [.font: bodyFont])
            (AppFormatters.money(fatura.kdvToplami) as NSString).draw(at: CGPoint(x: rightAlign + 100, y: totalsY + 18), withAttributes: [.font: bodyFont])
            
            ("GENEL TOPLAM:" as NSString).draw(at: CGPoint(x: rightAlign, y: totalsY + 40), withAttributes: [.font: UIFont.boldSystemFont(ofSize: 12)])
            (AppFormatters.money(fatura.genelToplam) as NSString).draw(at: CGPoint(x: rightAlign + 100, y: totalsY + 40), withAttributes: [.font: UIFont.boldSystemFont(ofSize: 12), .foregroundColor: UIColor(red: 0/255, green: 97/255, blue: 255/255, alpha: 1.0)])
        }
        
        return data
    }
    
    // MARK: - Rapor PDF Üretimi (QuestPDF Cloud & Yerel Motor Paritesi)
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
        // 1. Önce 7/24 Canlı Google Cloud Run QuestPDF Sunucusunu Dene
        if let cloudPdf = await fetchCloudReportPdf(
            title: title,
            category: category,
            headers: headers,
            rows: rows,
            dateFilter: dateFilter,
            cariName: cariName
        ) {
            return cloudPdf
        }
        
        // 2. Çevrimdışı / Yerel Motor Fallback
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
    
    private func fetchCloudReportPdf(
        title: String,
        category: String,
        headers: [String],
        rows: [[String]],
        dateFilter: String,
        cariName: String?
    ) async -> Data? {
        guard let url = URL(string: "https://ermay-pdf-api-390930978984.europe-west1.run.app/generate/generic") else {
            return nil
        }
        
        var subtitle = "Kategori: \(category) • Dönem: \(dateFilter == "All" ? "Tüm Zamanlar" : dateFilter)"
        if let c = cariName, !c.isEmpty {
            subtitle += " • Filtre: \(c)"
        }
        
        let requestPayload: [String: Any] = [
            "Title": title.uppercased(with: Locale(identifier: "tr_TR")),
            "Headers": headers,
            "Rows": rows,
            "Subtitle": subtitle,
            "ShowLogo": false
        ]
        
        guard let httpBody = try? JSONSerialization.data(withJSONObject: requestPayload, options: []) else {
            return nil
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = httpBody
        request.timeoutInterval = 7.0
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            if let httpRes = response as? HTTPURLResponse, httpRes.statusCode == 200, data.count > 1000 {
                if let prefix = String(data: data.prefix(5), encoding: .ascii), prefix.hasPrefix("%PDF") {
                    print("[PDFService] Cloud QuestPDF Raporu başarıyla üretildi (\(data.count) bytes).")
                    return data
                }
            }
        } catch {
            print("[PDFService] Cloud QuestPDF Rapor hatası: \(error.localizedDescription)")
        }
        
        return nil
    }
    
    // MARK: - Rapor PDF Üretimi (31+ Rapor ve Isı Haritası)
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
            let cellBoldFont = UIFont.boldSystemFont(ofSize: 8.5)
            
            // 1. Üst Başlık & Firma Bilgileri
            let headerBg = CGRect(x: 30, y: 28, width: 535, height: 60)
            UIColor(red: 15/255, green: 23/255, blue: 42/255, alpha: 1.0).setFill() // Slate 900
            UIBezierPath(roundedRect: headerBg, cornerRadius: 8).fill()
            
            let brandAttributes: [NSAttributedString.Key: Any] = [.font: titleFont, .foregroundColor: UIColor.white]
            (firma.firmaAdi as NSString).draw(at: CGPoint(x: 42, y: 38), withAttributes: brandAttributes)
            
            let brandSub = "\(firma.unvan) • \(firma.telefon ?? "")"
            (brandSub as NSString).draw(at: CGPoint(x: 42, y: 62), withAttributes: [.font: subTitleFont, .foregroundColor: UIColor(white: 0.8, alpha: 1.0)])
            
            let dateStr = "Tarih: \(ISO8601DateFormatter().string(from: Date()).prefix(10))\nDönem: \(dateFilter == "All" ? "Tüm Zamanlar" : dateFilter)"
            let dateRect = CGRect(x: 380, y: 38, width: 175, height: 40)
            (dateStr as NSString).draw(in: dateRect, withAttributes: [.font: subTitleFont, .foregroundColor: UIColor(white: 0.85, alpha: 1.0)])
            
            // 2. Rapor Başlığı & Kategori
            var startY: CGFloat = 100
            let rTitle = title.uppercased()
            (rTitle as NSString).draw(at: CGPoint(x: 32, y: startY), withAttributes: [.font: UIFont.boldSystemFont(ofSize: 14), .foregroundColor: UIColor(red: 37/255, green: 99/255, blue: 235/255, alpha: 1.0)])
            
            var metaText = "Kategori: \(category)"
            if let c = cariName, !c.isEmpty {
                metaText += " | Filtre: \(c)"
            }
            (metaText as NSString).draw(at: CGPoint(x: 32, y: startY + 20), withAttributes: [.font: subTitleFont, .foregroundColor: UIColor.darkGray])
            
            startY += 40
            
            // 3. Tablo Çizimi
            let tableLeft: CGFloat = 30
            let tableWidth: CGFloat = 535
            let colCount = max(headers.count, 1)
            let colWidth = tableWidth / CGFloat(colCount)
            
            // Tablo Başlık Satırı
            let tableHeaderRect = CGRect(x: tableLeft, y: startY, width: tableWidth, height: 22)
            UIColor(red: 241/255, green: 245/255, blue: 249/255, alpha: 1.0).setFill()
            UIBezierPath(roundedRect: tableHeaderRect, cornerRadius: 4).fill()
            
            for (idx, h) in headers.enumerated() {
                let colX = tableLeft + (CGFloat(idx) * colWidth) + 6
                (h as NSString).draw(in: CGRect(x: colX, y: startY + 4, width: colWidth - 8, height: 18), withAttributes: [.font: headerFont, .foregroundColor: UIColor(red: 30/255, green: 41/255, blue: 59/255, alpha: 1.0)])
            }
            
            startY += 26
            
            // Tablo Satırları
            for (rIdx, row) in rows.enumerated() {
                // Sayfa taşma kontrolü
                if startY > 780 {
                    context.beginPage()
                    startY = 40
                }
                
                let rowRect = CGRect(x: tableLeft, y: startY, width: tableWidth, height: 20)
                if rIdx % 2 == 1 {
                    UIColor(red: 248/255, green: 250/255, blue: 252/255, alpha: 1.0).setFill()
                    UIBezierPath(rect: rowRect).fill()
                }
                
                // Alt çizgi
                UIColor(white: 0.9, alpha: 1.0).setStroke()
                let border = UIBezierPath()
                border.move(to: CGPoint(x: tableLeft, y: startY + 20))
                border.addLine(to: CGPoint(x: tableLeft + tableWidth, y: startY + 20))
                border.lineWidth = 0.5
                border.stroke()
                
                for (cIdx, cell) in row.enumerated() {
                    if cIdx < colCount {
                        let colX = tableLeft + (CGFloat(cIdx) * colWidth) + 6
                        let isPositive = cell.contains("+") || cell.contains("Kâr")
                        let isNegative = cell.contains("-") || cell.contains("Zarar")
                        
                        var textColor = UIColor(red: 51/255, green: 65/255, blue: 85/255, alpha: 1.0)
                        if isPositive { textColor = UIColor(red: 16/255, green: 185/255, blue: 129/255, alpha: 1.0) }
                        else if isNegative { textColor = UIColor(red: 239/255, green: 68/255, blue: 68/255, alpha: 1.0) }
                        
                        let font = (cIdx == 0 || isPositive || isNegative) ? cellBoldFont : cellFont
                        (cell as NSString).draw(in: CGRect(x: colX, y: startY + 4, width: colWidth - 8, height: 16), withAttributes: [.font: font, .foregroundColor: textColor])
                    }
                }
                
                startY += 20
            }
            
            // Alt Bilgi (Footer)
            let footerText = "Ermay Muhasebe Bilgi Sistemi • Bu rapor sistem tarafından otomatik olarak üretilmiştir."
            (footerText as NSString).draw(at: CGPoint(x: 32, y: 815), withAttributes: [.font: subTitleFont, .foregroundColor: UIColor.lightGray])
        }
        
        return data
    }
    
    // MARK: - Cari Hesap Ekstresi PDF Üretimi (Masaüstü QuestPDF Formatında)
    public func fetchOrGenerateCariEkstrePDF(
        cari: CariKart,
        hareketler: [CariHareket],
        detayli: Bool = false,
        firma: FirmaProfili = FirmaProfili.varsayilan
    ) async -> Data? {
        // 1. Önce 7/24 Canlı Google Cloud Run QuestPDF Sunucusunu Dene
        if let cloudPdf = await fetchCloudQuestPdf(cari: cari, hareketler: hareketler, detayli: detayli) {
            return cloudPdf
        }
        
        // 2. Sunucuya erişilemezse veya çevrimdışıysa yerel piksel-piksel QuestPDF motoru üretir
        return generateCariEkstrePDF(cari: cari, hareketler: hareketler, detayli: detayli, firma: firma)
    }
    
    // Cloud Run QuestPDF API İsteği
    private func fetchCloudQuestPdf(
        cari: CariKart,
        hareketler: [CariHareket],
        detayli: Bool
    ) async -> Data? {
        let endpoint = detayli ? "ekstre-detayli" : "ekstre"
        guard let url = URL(string: "https://ermay-pdf-api-390930978984.europe-west1.run.app/generate/\(endpoint)") else {
            return nil
        }
        
        let cariDict: [String: Any] = [
            "Id": Int(cari.id) ?? 1,
            "Unvan": cari.unvan,
            "CariKodu": cari.cariKodu ?? "",
            "VergiDairesi": cari.vergiDairesi ?? "",
            "VergiNo": cari.vergiNo ?? "",
            "Telefon": cari.telefon ?? "",
            "Email": cari.email ?? "",
            "Yetkili": cari.yetkili ?? ""
        ]
        
        let hareketlerArray: [[String: Any]] = hareketler.enumerated().map { idx, h in
            var dict: [String: Any] = [
                "Id": idx + 1,
                "Tarih": h.tarih ?? ISO8601DateFormatter().string(from: Date()),
                "IslemTuru": h.islemTuru ?? "İşlem",
                "Aciklama": h.aciklama ?? "-",
                "Borc": h.borc,
                "Alacak": h.alacak,
                "EvrakNo": h.belgeNo ?? ""
            ]
            if let fIdStr = h.belgeNo?.replacingOccurrences(of: "FT-", with: "").replacingOccurrences(of: "MB-", with: ""),
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
            // Detaylı ekstre için fatura kalemleri
            var detayDict: [String: [[String: Any]]] = [:]
            for (idx, h) in hareketler.enumerated() {
                let fId: Int
                if let fIdStr = h.belgeNo?.replacingOccurrences(of: "FT-", with: "").replacingOccurrences(of: "MB-", with: ""),
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
                    "KDVOrani": 20,
                    "ToplamTutar": tutar
                ]
                detayDict["\(fId)"] = [item]
            }
            requestPayload["DetayDictionary"] = detayDict
        }
        
        guard let httpBody = try? JSONSerialization.data(withJSONObject: requestPayload, options: []) else {
            return nil
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = httpBody
        request.timeoutInterval = 7.0
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            if let httpRes = response as? HTTPURLResponse, httpRes.statusCode == 200, data.count > 1000 {
                // PDF dosya doğrulaması (%PDF başlığı)
                if let prefix = String(data: data.prefix(5), encoding: .ascii), prefix.hasPrefix("%PDF") {
                    print("[PDFService] Cloud QuestPDF başarıyla üretildi (\(data.count) bytes).")
                    return data
                }
            }
        } catch {
            print("[PDFService] Cloud QuestPDF erişim hatası, yerel motora geçiliyor: \(error.localizedDescription)")
        }
        
        return nil
    }
    
    // MARK: - Yerel QuestPDF Şablon Motoru (Masaüstü PdfService.cs Birebir)
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
        
        // Masaüstü Renk Sabitleri (PdfService.cs)
        let colorRed = UIColor(red: 204/255, green: 0/255, blue: 0/255, alpha: 1.0) // #cc0000
        let colorGreen = UIColor(red: 0/255, green: 128/255, blue: 0/255, alpha: 1.0) // #008000
        let colorHeaderBg = UIColor(red: 249/255, green: 249/255, blue: 249/255, alpha: 1.0) // #f9f9f9
        let colorBorder = UIColor(red: 238/255, green: 238/255, blue: 238/255, alpha: 1.0) // #eeeeee
        let colorCardBorder = UIColor(red: 221/255, green: 221/255, blue: 221/255, alpha: 1.0) // #dddddd
        let colorMuted = UIColor(red: 51/255, green: 51/255, blue: 51/255, alpha: 1.0) // #333333
        let colorCardBg = UIColor(red: 253/255, green: 253/255, blue: 254/255, alpha: 1.0)
        
        let fontTitle = UIFont.boldSystemFont(ofSize: 11)
        let fontBold9 = UIFont.boldSystemFont(ofSize: 9)
        let fontReg9 = UIFont.systemFont(ofSize: 9)
        let fontBold8 = UIFont.boldSystemFont(ofSize: 8)
        let fontReg8 = UIFont.systemFont(ofSize: 8)
        let fontBadge = UIFont.boldSystemFont(ofSize: 7)
        let fontSub = UIFont.systemFont(ofSize: 6.5)
        let fontSubBold = UIFont.boldSystemFont(ofSize: 6.5)
        
        let margin: CGFloat = 28.35 // 1 cm QuestPDF margin
        let usableWidth = pageWidth - (margin * 2) // 538.5 pt
        
        // Hesaplamalar
        var toplamBorc: Double = 0
        var toplamAlacak: Double = 0
        for h in hareketler {
            toplamBorc += h.borc
            toplamAlacak += h.alacak
        }
        let netBakiye = toplamBorc - toplamAlacak
        
        let data = renderer.pdfData { (context) in
            context.beginPage()
            
            // 1. ÜST BİLGİ (HEADER - FİRMA & BELGE TÜRÜ)
            let headerY: CGFloat = margin
            (firma.firmaAdi as NSString).draw(
                at: CGPoint(x: margin, y: headerY),
                withAttributes: [.font: UIFont.boldSystemFont(ofSize: 15), .foregroundColor: UIColor(red: 30/255, green: 41/255, blue: 59/255, alpha: 1.0)]
            )
            
            let firmaSub = "\(firma.unvan) • Tel: \(firma.telefon ?? "-")"
            (firmaSub as NSString).draw(
                at: CGPoint(x: margin, y: headerY + 18),
                withAttributes: [.font: fontReg8, .foregroundColor: UIColor.darkGray]
            )
            
            let docTitle = detayli ? "DETAYLI CARİ EKSTRESİ" : "CARİ HESAP EKSTRESİ"
            let docTitleAttrs: [NSAttributedString.Key: Any] = [
                .font: UIFont.boldSystemFont(ofSize: 12),
                .foregroundColor: UIColor(red: 37/255, green: 99/255, blue: 235/255, alpha: 1.0) // #2563EB
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
            
            // 2. GENEL BİLGİLER CARD (Masaüstü Border(0.5f).BorderColor("#dddddd").Padding(10))
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
            
            // 2 Sütunlu Bilgi Tablosu
            let infoY = currentY + 28
            let col1X = margin + 10
            let col1ValX = margin + 85
            let col2X = margin + 280
            let col2ValX = margin + 360
            
            // Müşteri Adı
            ("Müşteri Adı:" as NSString).draw(at: CGPoint(x: col1X, y: infoY), withAttributes: [.font: fontBold9, .foregroundColor: UIColor.black])
            (cari.unvan as NSString).draw(in: CGRect(x: col1ValX, y: infoY, width: 180, height: 16), withAttributes: [.font: fontReg9, .foregroundColor: UIColor.black])
            
            // Toplam Satış
            ("Toplam Satış:" as NSString).draw(at: CGPoint(x: col2X, y: infoY), withAttributes: [.font: fontBold9, .foregroundColor: UIColor.black])
            ("₺\(String(format: "%.2f", toplamBorc))" as NSString).draw(at: CGPoint(x: col2ValX, y: infoY), withAttributes: [.font: fontReg9, .foregroundColor: UIColor.black])
            
            // Toplam Ödeme
            ("Toplam Ödeme:" as NSString).draw(at: CGPoint(x: col1X, y: infoY + 20), withAttributes: [.font: fontBold9, .foregroundColor: UIColor.black])
            ("₺\(String(format: "%.2f", toplamAlacak))" as NSString).draw(at: CGPoint(x: col1ValX, y: infoY + 20), withAttributes: [.font: fontReg9, .foregroundColor: UIColor.black])
            
            // Bakiye (Renkli: netBakiye > 0 ? ColorRed : ColorGreen)
            ("Bakiye:" as NSString).draw(at: CGPoint(x: col2X, y: infoY + 20), withAttributes: [.font: fontBold9, .foregroundColor: UIColor.black])
            let bColor = netBakiye > 0 ? colorRed : colorGreen
            let bLabel = netBakiye > 0 ? " (Borçlu)" : " (Alacaklı)"
            let bakiyeString = "₺\(String(format: "%.2f", abs(netBakiye)))\(bLabel)"
            (bakiyeString as NSString).draw(at: CGPoint(x: col2ValX, y: infoY + 20), withAttributes: [.font: fontBold9, .foregroundColor: bColor])
            
            currentY += cardHeight + 12
            
            // 3. İŞLEM DETAYLARI CARD & TABLOSU
            let tableStartY = currentY
            
            // Başlık
            ("İşlem Detayları" as NSString).draw(
                at: CGPoint(x: margin + 8, y: currentY),
                withAttributes: [.font: fontTitle, .foregroundColor: UIColor.black]
            )
            currentY += 18
            
            // Tablo Kolon Tanımları (QuestPDF Sütun Oranları: 12, 10, 38, 13, 13, 14 = Toplam 100)
            let colTarihW: CGFloat = usableWidth * 0.12     // ~64.6 pt
            let colTipW: CGFloat = usableWidth * 0.11       // ~59.2 pt
            let colAciklamaW: CGFloat = usableWidth * 0.37  // ~199.2 pt
            let colBorcW: CGFloat = usableWidth * 0.13      // ~70.0 pt
            let colAlacakW: CGFloat = usableWidth * 0.13    // ~70.0 pt
            let colBakiyeW: CGFloat = usableWidth * 0.14    // ~75.4 pt
            
            let xTarih = margin
            let xTip = xTarih + colTarihW
            let xAciklama = xTip + colTipW
            let xBorc = xAciklama + colAciklamaW
            let xAlacak = xBorc + colBorcW
            let xBakiye = xAlacak + colAlacakW
            
            // Header Satırı (#f9f9f9 arka plan, #eeeeee kenarlık)
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
            
            // Sağa Hizalı Header Hücreleri
            drawRightText("Borç", atX: xBorc + colBorcW - 4, y: currentY + 4, attrs: thAttrs)
            drawRightText("Alacak", atX: xAlacak + colAlacakW - 4, y: currentY + 4, attrs: thAttrs)
            drawRightText("Bakiye", atX: xBakiye + colBakiyeW - 4, y: currentY + 4, attrs: thAttrs)
            
            currentY += thHeight
            
            // Tablo Satırları
            if hareketler.isEmpty {
                let emptyRect = CGRect(x: margin, y: currentY, width: usableWidth, height: 30)
                let emptyText = "Bu müşteri için herhangi bir işlem bulunamadı."
                (emptyText as NSString).draw(
                    in: emptyRect,
                    withAttributes: [.font: fontReg8, .foregroundColor: colorMuted]
                )
                currentY += 30
            } else {
                var runningBalance: Double = 0
                
                for (_, h) in hareketler.enumerated() {
                    // Sayfa taşma kontrolü (Footer payı: 35pt)
                    if currentY > pageHeight - margin - 50 {
                        context.beginPage()
                        currentY = margin + 10
                        
                        // Yeni sayfada tablo başlığını tekrarla
                        colorHeaderBg.setFill()
                        UIBezierPath(rect: CGRect(x: margin, y: currentY, width: usableWidth, height: thHeight)).fill()
                        ("Tarih" as NSString).draw(at: CGPoint(x: xTarih + 4, y: currentY + 4), withAttributes: thAttrs)
                        ("İşlem Tipi" as NSString).draw(at: CGPoint(x: xTip + 4, y: currentY + 4), withAttributes: thAttrs)
                        ("Açıklama" as NSString).draw(at: CGPoint(x: xAciklama + 4, y: currentY + 4), withAttributes: thAttrs)
                        drawRightText("Borç", atX: xBorc + colBorcW - 4, y: currentY + 4, attrs: thAttrs)
                        drawRightText("Alacak", atX: xAlacak + colAlacakW - 4, y: currentY + 4, attrs: thAttrs)
                        drawRightText("Bakiye", atX: xBakiye + colBakiyeW - 4, y: currentY + 4, attrs: thAttrs)
                        currentY += thHeight
                    }
                    
                    let isSale = h.borc > 0
                    runningBalance += (h.borc - h.alacak)
                    
                    let rowHeight: CGFloat = detayli ? 34 : 20
                    let rowRect = CGRect(x: margin, y: currentY, width: usableWidth, height: rowHeight)
                    
                    // Alt sınır çizgisi
                    colorBorder.setStroke()
                    let line = UIBezierPath()
                    line.move(to: CGPoint(x: margin, y: currentY + rowHeight))
                    line.addLine(to: CGPoint(x: margin + usableWidth, y: currentY + rowHeight))
                    line.lineWidth = 0.5
                    line.stroke()
                    
                    // Tarih
                    let dateDisplay = String((h.tarih ?? "-").prefix(10))
                    (dateDisplay as NSString).draw(at: CGPoint(x: xTarih + 4, y: currentY + 4), withAttributes: [.font: fontReg8, .foregroundColor: UIColor.black])
                    
                    // İşlem Tipi Badge (ComposeBadge mantığı)
                    let (badgeColor, badgeTitle) = resolveBadge(rawTuru: h.islemTuru ?? "")
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
                    
                    // Açıklama (ve Ödeme Yöntemi Etiketi)
                    var desc = h.aciklama ?? "-"
                    if !isSale {
                        let method = resolvePaymentMethod(desc)
                        if method != "-" {
                            desc = "\(desc) (\(method))"
                        }
                    }
                    (desc as NSString).draw(
                        in: CGRect(x: xAciklama + 4, y: currentY + 4, width: colAciklamaW - 8, height: 14),
                        withAttributes: [.font: fontReg8, .foregroundColor: UIColor.black]
                    )
                    
                    // Borç (kırmızı bold)
                    if isSale {
                        let borcText = "₺\(String(format: "%.2f", h.borc))"
                        drawRightText(borcText, atX: xBorc + colBorcW - 4, y: currentY + 4, attrs: [.font: fontBold8, .foregroundColor: colorRed])
                    } else {
                        drawRightText("-", atX: xBorc + colBorcW - 4, y: currentY + 4, attrs: [.font: fontReg8, .foregroundColor: UIColor.gray])
                    }
                    
                    // Alacak (yeşil bold)
                    if !isSale {
                        let alacakText = "₺\(String(format: "%.2f", h.alacak))"
                        drawRightText(alacakText, atX: xAlacak + colAlacakW - 4, y: currentY + 4, attrs: [.font: fontBold8, .foregroundColor: colorGreen])
                    } else {
                        drawRightText("-", atX: xAlacak + colAlacakW - 4, y: currentY + 4, attrs: [.font: fontReg8, .foregroundColor: UIColor.gray])
                    }
                    
                    // Bakiye (bold)
                    let bakText = "₺\(String(format: "%.2f", runningBalance))"
                    drawRightText(bakText, atX: xBakiye + colBakiyeW - 4, y: currentY + 4, attrs: [.font: fontBold8, .foregroundColor: UIColor.black])
                    
                    // DETAYLI EKSTREDE: FATURA DETAY KALEMLERİ (Alt Tablo - QuestPDF Girintili)
                    if detayli {
                        let subY = currentY + 18
                        let subX = margin + 25
                        let subW = usableWidth - 40
                        
                        // Alt tablo başlıkları
                        let subTh = "• Kalemler: \(desc) | Miktar: 1 Adet | KDV: %20 | Tutar: ₺\(String(format: "%.2f", isSale ? h.borc : h.alacak))"
                        (subTh as NSString).draw(
                            in: CGRect(x: subX, y: subY, width: subW, height: 12),
                            withAttributes: [.font: fontSubBold, .foregroundColor: UIColor(white: 0.35, alpha: 1.0)]
                        )
                    }
                    
                    currentY += rowHeight
                }
            }
            
            // Dış Çerçeve (Tüm tablonun etrafına QuestPDF gibi Border)
            colorCardBorder.setStroke()
            let tableFrame = CGRect(x: margin, y: tableStartY + 14, width: usableWidth, height: currentY - (tableStartY + 14))
            let framePath = UIBezierPath(rect: tableFrame)
            framePath.lineWidth = 0.5
            framePath.stroke()
            
            // 4. FOOTER: Sayfa Numarası Ortada
            let footerText = "Ermay Muhasebe • Sayfa 1 / 1"
            let footerAttrs: [NSAttributedString.Key: Any] = [.font: fontSub, .foregroundColor: colorMuted]
            let footerSize = (footerText as NSString).size(withAttributes: footerAttrs)
            (footerText as NSString).draw(
                at: CGPoint(x: (pageWidth - footerSize.width) / 2, y: pageHeight - margin),
                withAttributes: footerAttrs
            )
        }
        
        return data
    }
    
    // Sağ hizalı metin çizici yardımcı fonksiyon
    private func drawRightText(_ text: String, atX: CGFloat, y: CGFloat, attrs: [NSAttributedString.Key: Any]) {
        let size = (text as NSString).size(withAttributes: attrs)
        (text as NSString).draw(at: CGPoint(x: atX - size.width, y: y), withAttributes: attrs)
    }
    
    // Masaüstü ComposeBadge Renk & Başlık Eşleştirmesi (PdfService.cs:682-700)
    private func resolveBadge(rawTuru: String) -> (UIColor, String) {
        let t = rawTuru.uppercased(with: Locale(identifier: "tr_TR"))
        if t.contains("SATIŞ") || t.contains("SATIS") || t.contains("FATURA") || t.contains("GİRİŞ") || t.contains("GIRIS") {
            return (UIColor(red: 47/255, green: 111/255, blue: 237/255, alpha: 1.0), "Satış") // #2F6FED
        } else if t.contains("ALIŞ") || t.contains("ALIS") || t.contains("ÇIKIŞ") || t.contains("CIKIS") {
            return (UIColor(red: 245/255, green: 158/255, blue: 11/255, alpha: 1.0), "Alış") // #F59E0B
        } else if t.contains("TAHSİLAT") || t.contains("TAHSILAT") {
            return (UIColor(red: 16/255, green: 185/255, blue: 129/255, alpha: 1.0), "Tahsilat") // #10B981
        } else if t.contains("ÖDEME") || t.contains("ODEME") {
            return (UIColor(red: 239/255, green: 68/255, blue: 68/255, alpha: 1.0), "Ödeme") // #EF4444
        } else if t.contains("ÇEK") || t.contains("CEK") || t.contains("SENET") {
            return (UIColor(red: 139/255, green: 92/255, blue: 246/255, alpha: 1.0), "Çek/Senet") // #8B5CF6
        } else if t.contains("KREDİ") || t.contains("KREDI") {
            return (UIColor(red: 30/255, green: 58/255, blue: 138/255, alpha: 1.0), "Kredi") // #1E3A8A
        } else if t.contains("ALACAK") {
            return (UIColor(red: 16/255, green: 185/255, blue: 129/255, alpha: 1.0), "Alacak")
        } else if t.contains("BORÇ") || t.contains("BORC") {
            return (UIColor(red: 239/255, green: 68/255, blue: 68/255, alpha: 1.0), "Borç")
        } else {
            return (UIColor(red: 107/255, green: 114/255, blue: 128/255, alpha: 1.0), "İşlem") // #6B7280
        }
    }
    
    // Masaüstü GetPaymentMethodLabel Eşleştirmesi (PdfService.cs:1577-1587)
    private func resolvePaymentMethod(_ aciklama: String) -> String {
        let upper = aciklama.uppercased(with: Locale(identifier: "tr_TR"))
        if upper.contains("NAKİT") || upper.contains("NAKIT") { return "Nakit" }
        if upper.contains("KREDİ") || upper.contains("KREDI") { return "Kredi Kartı" }
        if upper.contains("HAVALE") || upper.contains("EFT") { return "Havale" }
        if upper.contains("ÇEK") || upper.contains("CEK") { return "Çek" }
        if upper.contains("BANKA") { return "Banka Havalesi" }
        return "-"
    }
    #endif
}
