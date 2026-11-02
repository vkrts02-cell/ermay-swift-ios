import Foundation
#if canImport(UIKit)
import UIKit
import PDFKit
#endif

public final class PDFService {
    public static let shared = PDFService()
    private init() {}
    
    #if canImport(UIKit)
    public func generateFaturaPDF(fatura: Fatura, firma: FirmaProfili) -> Data? {
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
    #endif
}

