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
    
    // MARK: - Cari Hesap Ekstresi PDF Üretimi (Masaüstü CariEkstreDialog Formatında)
    public func generateCariEkstrePDF(
        cari: CariKart,
        hareketler: [CariHareket],
        detayli: Bool = false,
        firma: FirmaProfili = FirmaProfili.varsayilan
    ) -> Data? {
        let pdfMetaData = [
            kCGPDFContextCreator: "Ermay Muhasebe Mobil",
            kCGPDFContextAuthor: firma.firmaAdi,
            kCGPDFContextTitle: "Cari Hesap Ekstresi - \(cari.unvan)"
        ]
        let format = UIGraphicsPDFRendererFormat()
        format.documentInfo = pdfMetaData as [String: Any]
        
        let pageWidth: CGFloat = 595.2
        let pageHeight: CGFloat = 841.8
        let pageRect = CGRect(x: 0, y: 0, width: pageWidth, height: pageHeight)
        
        let renderer = UIGraphicsPDFRenderer(bounds: pageRect, format: format)
        
        let data = renderer.pdfData { (context) in
            context.beginPage()
            
            let boldLarge = UIFont.boldSystemFont(ofSize: 15)
            let boldMed = UIFont.boldSystemFont(ofSize: 10)
            let body = UIFont.systemFont(ofSize: 9)
            let bodyBold = UIFont.boldSystemFont(ofSize: 9)
            let small = UIFont.systemFont(ofSize: 8)
            
            // 1. Kurumsal Header
            let headerRect = CGRect(x: 30, y: 26, width: 535, height: 60)
            UIColor(red: 15/255, green: 23/255, blue: 42/255, alpha: 1.0).setFill()
            UIBezierPath(roundedRect: headerRect, cornerRadius: 8).fill()
            
            (firma.firmaAdi as NSString).draw(at: CGPoint(x: 42, y: 35), withAttributes: [.font: boldLarge, .foregroundColor: UIColor.white])
            let sub = "\(firma.unvan)\nTel: \(firma.telefon ?? "-") | E-posta: \(firma.email ?? "-")"
            (sub as NSString).draw(at: CGPoint(x: 42, y: 55), withAttributes: [.font: small, .foregroundColor: UIColor(white: 0.85, alpha: 1.0)])
            
            let typeBadge = detayli ? "DETAYLI CARİ EKSTRESİ" : "CARİ HESAP EKSTRESİ"
            (typeBadge as NSString).draw(at: CGPoint(x: 375, y: 36), withAttributes: [.font: UIFont.boldSystemFont(ofSize: 11), .foregroundColor: UIColor(red: 96/255, green: 165/255, blue: 250/255, alpha: 1.0)])
            
            let printDate = "Tarih: \(ISO8601DateFormatter().string(from: Date()).prefix(10))"
            (printDate as NSString).draw(at: CGPoint(x: 375, y: 56), withAttributes: [.font: small, .foregroundColor: UIColor.white])
            
            // 2. Cari Bilgi Kartı
            let cariBox = CGRect(x: 30, y: 96, width: 535, height: 75)
            UIColor(red: 248/255, green: 250/255, blue: 252/255, alpha: 1.0).setFill()
            UIBezierPath(roundedRect: cariBox, cornerRadius: 6).fill()
            UIColor(red: 226/255, green: 232/255, blue: 240/255, alpha: 1.0).setStroke()
            UIBezierPath(roundedRect: cariBox, cornerRadius: 6).stroke()
            
            ("SAYIN: \(cari.unvan)" as NSString).draw(at: CGPoint(x: 42, y: 104), withAttributes: [.font: boldMed, .foregroundColor: UIColor.black])
            
            let cariInfo1 = "Cari Kodu: \(cari.cariKodu ?? "-")\nVergi D./No: \(cari.vergiDairesi ?? "-") / \(cari.vergiNo ?? "-")\nYetkili: \(cari.yetkili ?? "-")"
            (cariInfo1 as NSString).draw(in: CGRect(x: 42, y: 122, width: 250, height: 45), withAttributes: [.font: small, .foregroundColor: UIColor.darkGray])
            
            let isBorclu = cari.bakiyeTuru == "B"
            let bakiyeStr = "GÜNCEL BAKİYE\n\(AppFormatters.money(cari.bakiye))\n\(isBorclu ? "(Borçlu)" : "(Alacaklı)")"
            let bColor = isBorclu ? UIColor(red: 239/255, green: 68/255, blue: 68/255, alpha: 1.0) : UIColor(red: 16/255, green: 185/255, blue: 129/255, alpha: 1.0)
            (bakiyeStr as NSString).draw(in: CGRect(x: 380, y: 104, width: 175, height: 60), withAttributes: [.font: boldMed, .foregroundColor: bColor])
            
            // 3. Hareket Tablosu
            var currentY: CGFloat = 185
            let tableLeft: CGFloat = 30
            let tableWidth: CGFloat = 535
            
            // Kolonlar: Tarih (65), Evrak No (85), İşlem Türü (85), Açıklama (120), Borç (60), Alacak (60), Bakiye (60)
            let thRect = CGRect(x: tableLeft, y: currentY, width: tableWidth, height: 22)
            UIColor(red: 37/255, green: 99/255, blue: 235/255, alpha: 1.0).setFill()
            UIBezierPath(roundedRect: thRect, cornerRadius: 4).fill()
            
            let thAttr: [NSAttributedString.Key: Any] = [.font: bodyBold, .foregroundColor: UIColor.white]
            ("Tarih" as NSString).draw(at: CGPoint(x: tableLeft + 6, y: currentY + 5), withAttributes: thAttr)
            ("Belge No" as NSString).draw(at: CGPoint(x: tableLeft + 72, y: currentY + 5), withAttributes: thAttr)
            ("İşlem Türü" as NSString).draw(at: CGPoint(x: tableLeft + 155, y: currentY + 5), withAttributes: thAttr)
            ("Açıklama" as NSString).draw(at: CGPoint(x: tableLeft + 240, y: currentY + 5), withAttributes: thAttr)
            ("Borç" as NSString).draw(at: CGPoint(x: tableLeft + 360, y: currentY + 5), withAttributes: thAttr)
            ("Alacak" as NSString).draw(at: CGPoint(x: tableLeft + 425, y: currentY + 5), withAttributes: thAttr)
            ("Bakiye" as NSString).draw(at: CGPoint(x: tableLeft + 485, y: currentY + 5), withAttributes: thAttr)
            
            currentY += 26
            
            var totalBorc: Double = 0
            var totalAlacak: Double = 0
            var runningBakiye: Double = 0
            
            for (idx, h) in hareketler.enumerated() {
                if currentY > 770 {
                    context.beginPage()
                    currentY = 40
                }
                
                totalBorc += h.borc
                totalAlacak += h.alacak
                runningBakiye += (h.borc - h.alacak)
                
                if idx % 2 == 1 {
                    let rBg = CGRect(x: tableLeft, y: currentY, width: tableWidth, height: 18)
                    UIColor(red: 248/255, green: 250/255, blue: 252/255, alpha: 1.0).setFill()
                    UIBezierPath(rect: rBg).fill()
                }
                
                (h.tarih ?? "-" as NSString).draw(at: CGPoint(x: tableLeft + 6, y: currentY + 3), withAttributes: [.font: small, .foregroundColor: UIColor.darkGray])
                (h.belgeNo ?? "-" as NSString).draw(at: CGPoint(x: tableLeft + 72, y: currentY + 3), withAttributes: [.font: small, .foregroundColor: UIColor.black])
                (h.islemTuru ?? "-" as NSString).draw(at: CGPoint(x: tableLeft + 155, y: currentY + 3), withAttributes: [.font: small, .foregroundColor: UIColor.black])
                (h.aciklama ?? "-" as NSString).draw(in: CGRect(x: tableLeft + 240, y: currentY + 3, width: 115, height: 16), withAttributes: [.font: small, .foregroundColor: UIColor.darkGray])
                
                let borcStr = h.borc > 0 ? AppFormatters.money(h.borc) : "-"
                (borcStr as NSString).draw(at: CGPoint(x: tableLeft + 360, y: currentY + 3), withAttributes: [.font: bodyBold, .foregroundColor: h.borc > 0 ? UIColor(red: 239/255, green: 68/255, blue: 68/255, alpha: 1.0) : UIColor.gray])
                
                let alacakStr = h.alacak > 0 ? AppFormatters.money(h.alacak) : "-"
                (alacakStr as NSString).draw(at: CGPoint(x: tableLeft + 425, y: currentY + 3), withAttributes: [.font: bodyBold, .foregroundColor: h.alacak > 0 ? UIColor(red: 16/255, green: 185/255, blue: 129/255, alpha: 1.0) : UIColor.gray])
                
                let runStr = AppFormatters.money(abs(runningBakiye))
                (runStr as NSString).draw(at: CGPoint(x: tableLeft + 485, y: currentY + 3), withAttributes: [.font: bodyBold, .foregroundColor: UIColor.black])
                
                currentY += 20
            }
            
            // Dip Toplamlar
            let totalsY = max(currentY + 15, 730)
            let totRect = CGRect(x: tableLeft, y: totalsY, width: tableWidth, height: 35)
            UIColor(red: 241/255, green: 245/255, blue: 249/255, alpha: 1.0).setFill()
            UIBezierPath(roundedRect: totRect, cornerRadius: 6).fill()
            
            ("TOPLAMLAR" as NSString).draw(at: CGPoint(x: tableLeft + 15, y: totalsY + 10), withAttributes: [.font: boldMed, .foregroundColor: UIColor.black])
            
            let totBorcText = "Top. Borç: \(AppFormatters.money(totalBorc))"
            (totBorcText as NSString).draw(at: CGPoint(x: tableLeft + 160, y: totalsY + 10), withAttributes: [.font: boldMed, .foregroundColor: UIColor(red: 239/255, green: 68/255, blue: 68/255, alpha: 1.0)])
            
            let totAlacakText = "Top. Alacak: \(AppFormatters.money(totalAlacak))"
            (totAlacakText as NSString).draw(at: CGPoint(x: tableLeft + 310, y: totalsY + 10), withAttributes: [.font: boldMed, .foregroundColor: UIColor(red: 16/255, green: 185/255, blue: 129/255, alpha: 1.0)])
            
            let netBakiyeText = "Net: \(AppFormatters.money(abs(totalBorc - totalAlacak)))"
            (netBakiyeText as NSString).draw(at: CGPoint(x: tableLeft + 440, y: totalsY + 10), withAttributes: [.font: boldMed, .foregroundColor: UIColor(red: 37/255, green: 99/255, blue: 235/255, alpha: 1.0)])
            
            // Footer
            let footer = "Ermay Muhasebe • İtiraz süresi TTK gereği 8 gündür."
            (footer as NSString).draw(at: CGPoint(x: 32, y: 815), withAttributes: [.font: small, .foregroundColor: UIColor.lightGray])
        }
        
        return data
    }
    #endif
}
