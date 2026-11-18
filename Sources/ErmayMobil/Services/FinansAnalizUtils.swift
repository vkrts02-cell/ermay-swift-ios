import Foundation

public struct FinansalKarne {
    public var likiditePuani: Int // 0-100
    public var nakitOrani: Double
    public var toplamVarlik: Double
    public var toplamYukumluluk: Double
    public var netPozisyon: Double
    public var tahsilatPerformansi: Double // %
    public var genelDurumMetni: String
    public var durumSeviyesi: String // "Mukemmel", "Iyi", "Riskli", "Kritik"
}

public struct FinansTrendNoktasi: Identifiable {
    public var id = UUID()
    public var donem: String // "Oca", "Şub", vb.
    public var gelir: Double
    public var gider: Double
    public var net: Double
}

public final class FinansAnalizUtils {
    public static func hesapKarneler(
        kasaBakiye: Double,
        bankaBakiye: Double,
        cekPortfoyBakiye: Double,
        toplamAlacak: Double,
        toplamBorc: Double
    ) -> FinansalKarne {
        let toplamNakit = kasaBakiye + bankaBakiye
        let toplamVarlik = toplamNakit + cekPortfoyBakiye + toplamAlacak
        let netPozisyon = toplamVarlik - toplamBorc
        
        let nakitOrani = toplamBorc > 0 ? (toplamNakit / toplamBorc) : (toplamNakit > 0 ? 1.5 : 1.0)
        
        var puan = 50
        if netPozisyon > 0 { puan += 20 } else if netPozisyon < 0 { puan -= 25 }
        if nakitOrani >= 1.0 { puan += 20 } else if nakitOrani >= 0.5 { puan += 10 } else { puan -= 15 }
        if toplamAlacak > toplamBorc { puan += 10 }
        
        let clampedPuan = max(10, min(100, puan))
        
        let durum: String
        let durumMetni: String
        
        switch clampedPuan {
        case 80...100:
            durum = "Mukemmel"
            durumMetni = "İşletmenin finansal likiditesi çok güçlü. Kısa vadeli tüm borçlarını nakit ve hazır değerleriyle rahatça kapatabilir."
        case 60..<80:
            durum = "Iyi"
            durumMetni = "Finansal denge stabil. Alacak tahsilatları takip edildiği sürece nakit sıkışıklığı riski düşüktür."
        case 40..<60:
            durum = "Riskli"
            durumMetni = "Nakit oranı kritik eşikte. Vadesi geçen alacakların acilen tahsil edilmesi ve gereksiz harcamaların kısılması önerilir."
        default:
            durum = "Kritik"
            durumMetni = "Yüksek likidite riski! Borç yükümlülükleri hazır değerlerin çok üzerinde. Acil nakit planlaması gerekmektedir."
        }
        
        let tahsilatPerf = (toplamNakit + toplamAlacak) > 0 ? ((toplamNakit / (toplamNakit + toplamAlacak)) * 100.0) : 0.0
        
        return FinansalKarne(
            likiditePuani: clampedPuan,
            nakitOrani: nakitOrani,
            toplamVarlik: toplamVarlik,
            toplamYukumluluk: toplamBorc,
            netPozisyon: netPozisyon,
            tahsilatPerformansi: tahsilatPerf,
            genelDurumMetni: durumMetni,
            durumSeviyesi: durum
        )
    }
    
    public static func hesapFinansTrend(aylikFaturalar: [Fatura], kasaHareketler: [KasaHareket]) -> [FinansTrendNoktasi] {
        let ayAdlari = ["Oca", "Şub", "Mar", "Nis", "May", "Haz", "Tem", "Ağu", "Eyl", "Eki", "Kas", "Ara"]
        let cal = Calendar.current
        let now = Date()
        var sonuclar: [FinansTrendNoktasi] = []
        
        for i in (0..<6).reversed() {
            guard let targetDate = cal.date(byAdding: .month, value: -i, to: now) else { continue }
            let yil = cal.component(.year, from: targetDate)
            let ay = cal.component(.month, from: targetDate)
            let prefix1 = String(format: "%04d-%02d", yil, ay)
            let suffix2 = String(format: ".%02d.%04d", ay, yil)
            
            var gelir = 0.0
            var gider = 0.0
            
            for f in aylikFaturalar {
                if f.tarih.hasPrefix(prefix1) || f.tarih.hasSuffix(suffix2) {
                    if f.faturaTuru.localizedCaseInsensitiveContains("satış") || f.faturaTuru.localizedCaseInsensitiveContains("satis") {
                        gelir += f.genelToplam
                    } else if f.faturaTuru.localizedCaseInsensitiveContains("alış") || f.faturaTuru.localizedCaseInsensitiveContains("alis") {
                        gider += f.genelToplam
                    }
                }
            }
            
            for kh in kasaHareketler {
                if kh.tarih.hasPrefix(prefix1) || kh.tarih.hasSuffix(suffix2) {
                    if kh.giren > 0 || kh.cikan > 0 {
                        gelir += kh.giren
                        gider += kh.cikan
                    } else {
                        let up = kh.islemTuru.uppercased()
                        if up.contains("TAHSİLAT") || up.contains("TAHSILAT") || up.contains("GİRİŞ") || up.contains("GIRIS") {
                            gelir += kh.tutar
                        } else {
                            gider += kh.tutar
                        }
                    }
                }
            }
            
            let label = ayAdlari[max(0, min(11, ay - 1))]
            sonuclar.append(FinansTrendNoktasi(donem: label, gelir: gelir, gider: gider, net: gelir - gider))
        }
        return sonuclar
    }
    
    public static func hesapOrtalamaVade(faturalar: [Fatura]) -> Int {
        var toplamGunAğırlıklı = 0.0
        var toplamTutar = 0.0
        
        for f in faturalar {
            if let vt = f.vadeTarihi, let vDate = AppFormatters.parseDate(vt), let fDate = AppFormatters.parseDate(f.tarih) {
                let diff = Calendar.current.dateComponents([.day], from: fDate, to: vDate).day ?? 30
                toplamGunAğırlıklı += Double(diff) * f.genelToplam
                toplamTutar += f.genelToplam
            }
        }
        
        if toplamTutar > 0 {
            return Int(toplamGunAğırlıklı / toplamTutar)
        }
        return 0
    }
}
