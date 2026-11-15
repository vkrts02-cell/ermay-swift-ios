import Foundation

public final class ReportCalculationService: @unchecked Sendable {
    public static let shared = ReportCalculationService()
    private init() {}
    
    // MARK: - Core Calculation Dispatcher
    public func calculateReport(
        report: ReportItemInfo,
        dateFilter: String,
        cariName: String? = nil
    ) async -> (headers: [String], rows: [[String]]) {
        let title = report.title
        let trimmedCariFilter = cariName?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        
        var cariler: [CariKart] = (try? await SupabaseService.shared.fetch(from: "cariler")) ?? []
        if cariler.isEmpty {
            cariler = LocalDatabaseService.shared.getCachedCariler()
        }
        
        var stoklar: [StokKart] = (try? await SupabaseService.shared.fetch(from: "stoklar")) ?? []
        if stoklar.isEmpty {
            stoklar = LocalDatabaseService.shared.getCachedStoklar()
        }
        
        var faturalar: [Fatura] = (try? await SupabaseService.shared.fetch(from: "faturalar")) ?? []
        if faturalar.isEmpty {
            faturalar = LocalDatabaseService.shared.getCachedFaturalar()
        }
        
        let kasalar: [KasaBanka] = (try? await SupabaseService.shared.fetch(from: "kasalar")) ?? []
        let bankalar: [BankaKart] = (try? await SupabaseService.shared.fetch(from: "bankalar")) ?? []
        let cariHareketler: [CariHareket] = (try? await SupabaseService.shared.fetch(from: "cari_hareketler")) ?? []
        let cekSenetler: [CekSenet] = (try? await SupabaseService.shared.fetch(from: "cekler")) ?? []
        
        if !trimmedCariFilter.isEmpty {
            let needle = trimmedCariFilter.lowercased()
            cariler = cariler.filter { $0.unvan.lowercased().contains(needle) }
            faturalar = faturalar.filter { ($0.cariUnvan ?? "").lowercased().contains(needle) }
        }
        
        switch title {
        // 1. Genel Durum
        case "Genel Özet":
            var topAlacak: Double = 0
            var topBorc: Double = 0
            for c in cariler {
                if c.bakiye >= 0 && c.bakiyeTuru != "A" {
                    topAlacak += abs(c.bakiye)
                } else {
                    topBorc += abs(c.bakiye)
                }
            }
            
            let kasaTop = kasalar.reduce(0.0) { $0 + $1.bakiye }
            let bankaTop = bankalar.reduce(0.0) { $0 + $1.bakiye }
            
            var topStokAdet: Double = 0
            var topStokDeger: Double = 0
            for s in stoklar {
                topStokAdet += s.mevcutMiktar
                topStokDeger += (s.mevcutMiktar * s.alisFiyati)
            }
            
            let headers = ["Rapor Kalemi", "Tutar / Değer"]
            let rows: [[String]] = [
                ["Toplam Alacaklar (Borçlu Cariler)", AppFormatters.money(topAlacak)],
                ["Toplam Borçlar (Alacaklı Cariler)", AppFormatters.money(topBorc)],
                ["Kasa ve Banka Mevcudu", AppFormatters.money(kasaTop + bankaTop)],
                ["Toplam Stok Miktarı", "\(Int(topStokAdet)) Adet"],
                ["Stok Maliyet Değeri", AppFormatters.money(topStokDeger)],
                ["Net İşletme Sermayesi", AppFormatters.money(topAlacak - topBorc + kasaTop + bankaTop)],
                ["Aktif Cari Kart Sayısı", "\(cariler.count) Firma"]
            ]
            return (headers, rows)
            
        // 2. Finans
        case "Aylık Tahsilat ve Ödeme Analizi":
            let headers = ["Ay/Yıl", "Nakit (Alınan)", "Nakit (Ödenen)", "K.Kartı (Alınan)", "K.Kartı (Ödenen)", "Havale (Alınan)", "Havale (Ödenen)", "Çek (Alınan)", "Çek (Ödenen)"]
            var monthlyStats: [String: (nakitAl: Double, nakitOd: Double, kkAl: Double, kkOd: Double, havAl: Double, havOd: Double, cekAl: Double, cekOd: Double)] = [:]
            
            for h in cariHareketler {
                let rawDate = String((h.tarih ?? "").prefix(7))
                let monthKey = rawDate.isEmpty ? "Genel" : rawDate
                var entry = monthlyStats[monthKey] ?? (0, 0, 0, 0, 0, 0, 0, 0)
                let tur = (h.islemTuru ?? "").uppercased()
                let alinan = h.alacak
                let odenen = h.borc
                if tur.contains("KART") || tur.contains("POS") {
                    entry.kkAl += alinan
                    entry.kkOd += odenen
                } else if tur.contains("HAVALE") || tur.contains("EFT") || tur.contains("BANKA") {
                    entry.havAl += alinan
                    entry.havOd += odenen
                } else if tur.contains("ÇEK") || tur.contains("CEK") || tur.contains("SENET") {
                    entry.cekAl += alinan
                    entry.cekOd += odenen
                } else if tur.contains("NAKİT") || tur.contains("NAKIT") || tur.contains("TAHSİLAT") || tur.contains("TEDİYE") {
                    entry.nakitAl += alinan
                    entry.nakitOd += odenen
                }
                monthlyStats[monthKey] = entry
            }
            
            let rows: [[String]] = monthlyStats.keys.sorted(by: >).compactMap { key in
                guard let st = monthlyStats[key] else { return nil }
                return [
                    key,
                    AppFormatters.money(st.nakitAl),
                    AppFormatters.money(st.nakitOd),
                    AppFormatters.money(st.kkAl),
                    AppFormatters.money(st.kkOd),
                    AppFormatters.money(st.havAl),
                    AppFormatters.money(st.havOd),
                    AppFormatters.money(st.cekAl),
                    AppFormatters.money(st.cekOd)
                ]
            }
            return (headers, rows)
            
        case "Kredi Kartı Detay Raporu":
            let headers = ["Tarih", "Kimden Alındı", "Banka/Kart", "Kime Yönlendirildi", "Tutar", "Durum"]
            let rows: [[String]] = cariHareketler.filter {
                let t = ($0.islemTuru ?? "").uppercased()
                return t.contains("KART") || t.contains("POS")
            }.map { h in
                [
                    String((h.tarih ?? "-").prefix(10)),
                    h.cariUnvan ?? "-",
                    h.islemTuru ?? "Kredi Kartı",
                    "-",
                    AppFormatters.money(max(h.alacak, h.borc)),
                    h.alacak > 0 ? "Tahsil Edildi" : "Ödendi"
                ]
            }
            return (headers, rows)
            
        case "Nakit İşlem Detay Raporu":
            let headers = ["Tarih", "Cari Ünvan", "İşlem", "Açıklama", "Giren", "Çıkan"]
            let rows: [[String]] = cariHareketler.filter {
                let t = ($0.islemTuru ?? "").uppercased()
                return t.contains("NAKİT") || t.contains("NAKIT") || t.contains("KASA") || t.contains("TAHSİLAT") || t.contains("TEDİYE")
            }.map { h in
                [
                    String((h.tarih ?? "-").prefix(10)),
                    h.cariUnvan ?? "-",
                    h.islemTuru ?? "Nakit İşlem",
                    h.aciklama ?? "-",
                    AppFormatters.money(h.alacak),
                    AppFormatters.money(h.borc)
                ]
            }
            return (headers, rows)
            
        case "Çek Detay Raporu":
            let headers = ["Vade", "Çek No", "Cari Ünvan", "Banka/Şube", "Tutar", "Durum"]
            let rows: [[String]] = cekSenetler.map { c in
                [
                    String(c.vadeTarihi.prefix(10)),
                    c.cekSenetNo,
                    c.cariUnvan ?? "-",
                    c.bankaAdi ?? "-",
                    AppFormatters.money(c.tutar),
                    c.durum
                ]
            }
            return (headers, rows)
            
        case "Havale / EFT Detay Raporu":
            let headers = ["Tarih", "Müşteri", "Banka/Hesap", "Dekont No", "Tutar", "Durum"]
            let rows: [[String]] = cariHareketler.filter {
                let t = ($0.islemTuru ?? "").uppercased()
                return t.contains("HAVALE") || t.contains("EFT") || t.contains("BANKA")
            }.map { h in
                [
                    String((h.tarih ?? "-").prefix(10)),
                    h.cariUnvan ?? "-",
                    h.islemTuru ?? "Banka Transferi",
                    h.belgeNo ?? "-",
                    AppFormatters.money(max(h.alacak, h.borc)),
                    "Onaylandı"
                ]
            }
            return (headers, rows)
            
        // 3. Cari Hesap Raporları
        case "Cari Bakiye Raporu":
            let headers = ["Ünvan", "Şehir", "Borç", "Alacak", "Bakiye", "Durum"]
            let rows: [[String]] = cariler.map { c in
                let absB = abs(c.bakiye)
                let isBorclu = c.bakiye >= 0 && c.bakiyeTuru != "A"
                let borc = isBorclu ? absB : 0
                let alacak = isBorclu ? 0 : absB
                return [
                    c.unvan,
                    c.sehir ?? "-",
                    AppFormatters.money(borc),
                    AppFormatters.money(alacak),
                    AppFormatters.money(absB),
                    isBorclu ? "Borçlu (B)" : "Alacaklı (A)"
                ]
            }
            return (headers, rows)
            
        case "Cari Hareket Dökümü":
            let headers = ["Tarih", "İşlem Türü", "Evrak No", "Açıklama", "Borç", "Alacak", "Bakiye"]
            let rows: [[String]] = cariHareketler.map { h in
                [
                    String((h.tarih ?? "-").prefix(10)),
                    h.islemTuru ?? "-",
                    h.belgeNo ?? "-",
                    h.aciklama ?? "-",
                    AppFormatters.money(h.borc),
                    AppFormatters.money(h.alacak),
                    AppFormatters.money(h.bakiye)
                ]
            }
            return (headers, rows)
            
        case "Yaşlandırma Raporu":
            let headers = ["Ünvan", "0-30 Gün", "31-60 Gün", "61-90 Gün", "90+ Gün", "Toplam"]
            let now = Date()
            let rows: [[String]] = cariler.filter { abs($0.bakiye) > 0.01 }.map { c in
                let cariFats = faturalar.filter { ($0.cariId != nil && $0.cariId == c.id) || ($0.cariUnvan ?? "") == c.unvan }
                var b0_30: Double = 0
                var b31_60: Double = 0
                var b61_90: Double = 0
                var b90Plus: Double = 0
                
                if cariFats.isEmpty {
                    b0_30 = abs(c.bakiye)
                } else {
                    for f in cariFats {
                        let fDate = AppFormatters.parseDate(String(f.tarih.prefix(10))) ?? now
                        let days = max(0, Calendar.current.dateComponents([.day], from: fDate, to: now).day ?? 0)
                        if days <= 30 { b0_30 += f.genelToplam }
                        else if days <= 60 { b31_60 += f.genelToplam }
                        else if days <= 90 { b61_90 += f.genelToplam }
                        else { b90Plus += f.genelToplam }
                    }
                }
                return [
                    c.unvan,
                    AppFormatters.money(b0_30),
                    AppFormatters.money(b31_60),
                    AppFormatters.money(b61_90),
                    AppFormatters.money(b90Plus),
                    AppFormatters.money(abs(c.bakiye))
                ]
            }
            return (headers, rows)
            
        case "Hareketsiz Cariler":
            let headers = ["Ünvan", "Grup", "Telefon", "Son İşlem", "Bakiye"]
            let activeCariIds = Set(cariHareketler.compactMap { $0.cariId })
            let rows: [[String]] = cariler.filter { c in
                guard let cid = c.id else { return true }
                return !activeCariIds.contains(cid)
            }.map { c in
                [
                    c.unvan,
                    c.cariTipi,
                    c.telefon ?? "-",
                    "Hareket Yok",
                    AppFormatters.money(abs(c.bakiye))
                ]
            }
            return (headers, rows)
            
        case "Vadesi Geçmiş Alacaklar":
            let headers = ["Müşteri", "Cari Bakiyesi", "Fatura / Evrak No", "Fatura Tarihi", "Fatura Tutarı", "Gecikme (Gün)"]
            let now = Date()
            var rows: [[String]] = []
            for f in faturalar {
                let vadeStr = f.vadeTarihi ?? f.tarih
                if let vadeDate = AppFormatters.parseDate(String(vadeStr.prefix(10))) {
                    let days = Calendar.current.dateComponents([.day], from: vadeDate, to: now).day ?? 0
                    if days > 0 {
                        let matchedCari = cariler.first { $0.id == f.cariId || $0.unvan == f.cariUnvan }
                        rows.append([
                            f.cariUnvan ?? matchedCari?.unvan ?? "-",
                            AppFormatters.money(abs(matchedCari?.bakiye ?? f.genelToplam)),
                            f.faturaNo,
                            String(f.tarih.prefix(10)),
                            AppFormatters.money(f.genelToplam),
                            "\(days) Gün"
                        ])
                    }
                }
            }
            return (headers, rows)
            
        // 4. Stok Raporları
        case "Stok Mevcudu":
            let headers = ["Stok Kodu", "Stok Adı", "Kategori", "Miktar", "Alış F.", "Satış F.", "Stok Değeri"]
            let rows: [[String]] = stoklar.map { s in
                [
                    s.stokKodu ?? "STK-\(s.id ?? 0)",
                    s.stokAdi,
                    s.kategori ?? "Genel",
                    "\(String(format: "%.1f", s.mevcutMiktar)) \(s.birim ?? "Adet")",
                    AppFormatters.money(s.alisFiyati),
                    AppFormatters.money(s.satisFiyati),
                    AppFormatters.money(s.mevcutMiktar * s.alisFiyati)
                ]
            }
            return (headers, rows)
            
        case "Stok Hareketleri":
            let headers = ["Tarih", "Fatura No", "Cari Ünvan", "İşlem Türü", "Ara Toplam", "KDV", "Genel Toplam"]
            let rows: [[String]] = faturalar.map { f in
                [
                    String(f.tarih.prefix(10)),
                    f.faturaNo,
                    f.cariUnvan ?? "-",
                    f.faturaTuru,
                    AppFormatters.money(f.araToplam),
                    AppFormatters.money(f.kdvToplami),
                    AppFormatters.money(f.genelToplam)
                ]
            }
            return (headers, rows)
            
        case "Kritik Stok Seviyesi":
            let headers = ["Stok Kodu", "Stok Adı", "Mevcut", "Min. Seviye", "Durum", "Satış Fiyatı"]
            let rows: [[String]] = stoklar.compactMap { s in
                let minSev = s.kritikMiktar ?? 10.0
                guard s.mevcutMiktar <= minSev else { return nil }
                return [
                    s.stokKodu ?? "STK-\(s.id ?? 0)",
                    s.stokAdi,
                    "\(String(format: "%.1f", s.mevcutMiktar)) \(s.birim ?? "Adet")",
                    "\(String(format: "%.1f", minSev))",
                    "KRİTİK SEVİYE",
                    AppFormatters.money(s.satisFiyati)
                ]
            }
            return (headers, rows)
            
        case "Ölü Stok Raporu":
            let headers = ["Stok Adı", "Barkod", "Stok Kodu", "Mevcut Miktar", "Stok Maliyeti"]
            let rows: [[String]] = stoklar.filter { $0.mevcutMiktar > 0 }.map { s in
                [
                    s.stokAdi,
                    s.barkod ?? "-",
                    s.stokKodu ?? "STK-\(s.id ?? 0)",
                    "\(String(format: "%.1f", s.mevcutMiktar)) \(s.birim ?? "Adet")",
                    AppFormatters.money(s.mevcutMiktar * s.alisFiyati)
                ]
            }
            return (headers, rows)
            
        case "Stok Devir Hızı":
            let headers = ["Stok Adı", "Mevcut Stok", "Alış Fiyatı", "Satış Fiyatı", "Kategori"]
            let rows: [[String]] = stoklar.map { s in
                [
                    s.stokAdi,
                    "\(String(format: "%.1f", s.mevcutMiktar)) \(s.birim ?? "Adet")",
                    AppFormatters.money(s.alisFiyati),
                    AppFormatters.money(s.satisFiyati),
                    s.kategori ?? "Genel"
                ]
            }
            return (headers, rows)
            
        // 5. Satış & Karlılık Raporları
        case "Satış Faturası Dökümü":
            let headers = ["Fatura No", "Tarih", "Müşteri", "Ara Toplam", "KDV", "Genel Toplam"]
            let rows: [[String]] = faturalar.filter { f in
                let tur = f.faturaTuru.uppercased()
                return tur.contains("SATIS") || tur.contains("SATIŞ") || tur.contains("SAT")
            }.map { f in
                [
                    f.faturaNo,
                    String(f.tarih.prefix(10)),
                    f.cariUnvan ?? "-",
                    AppFormatters.money(f.araToplam),
                    AppFormatters.money(f.kdvToplami),
                    AppFormatters.money(f.genelToplam)
                ]
            }
            return (headers, rows)
            
        case "Ürün Karlılık Raporu":
            let headers = ["Ürün Adı", "Alış Fiyatı", "Satış Fiyatı", "Birim Kar", "Kar Marjı %"]
            let rows: [[String]] = stoklar.map { s in
                let kar = s.satisFiyati - s.alisFiyati
                let marj = s.satisFiyati > 0 ? (kar / s.satisFiyati) * 100 : 0
                return [
                    s.stokAdi,
                    AppFormatters.money(s.alisFiyati),
                    AppFormatters.money(s.satisFiyati),
                    AppFormatters.money(kar),
                    "%\(String(format: "%.1f", marj))"
                ]
            }
            return (headers, rows)
            
        case "Müşteri Karlılık Analizi":
            let headers = ["Müşteri", "Toplam Satış", "KDV Hariç Net", "KDV Toplamı", "Fatura Sayısı"]
            var grouped: [String: (topSatis: Double, araTop: Double, kdvTop: Double, count: Int)] = [:]
            for f in faturalar {
                let tur = f.faturaTuru.uppercased()
                guard tur.contains("SAT") else { continue }
                let name = f.cariUnvan ?? "Genel Müşteri"
                var cur = grouped[name] ?? (0, 0, 0, 0)
                cur.topSatis += f.genelToplam
                cur.araTop += f.araToplam
                cur.kdvTop += f.kdvToplami
                cur.count += 1
                grouped[name] = cur
            }
            let rows: [[String]] = grouped.sorted { $0.value.topSatis > $1.value.topSatis }.map { k, v in
                [
                    k,
                    AppFormatters.money(v.topSatis),
                    AppFormatters.money(v.araTop),
                    AppFormatters.money(v.kdvTop),
                    "\(v.count) Fatura"
                ]
            }
            return (headers, rows)
            
        case "En Çok Satan Ürünler":
            let headers = ["Sıra", "Ürün Adı", "Mevcut Stok", "Satış Fiyatı", "Kategori"]
            let rows: [[String]] = stoklar.enumerated().map { idx, s in
                [
                    "\(idx + 1)",
                    s.stokAdi,
                    "\(String(format: "%.1f", s.mevcutMiktar)) \(s.birim ?? "Adet")",
                    AppFormatters.money(s.satisFiyati),
                    s.kategori ?? "Genel"
                ]
            }
            return (headers, rows)
            
        case "Gelir Tablosu":
            let headers = ["Kalem", "Tutar"]
            var brutSatis: Double = 0
            var satisIade: Double = 0
            var alisToplam: Double = 0
            for f in faturalar {
                let tur = f.faturaTuru.uppercased()
                if tur.contains("İADE") || tur.contains("IADE") {
                    satisIade += f.araToplam
                } else if tur.contains("SAT") {
                    brutSatis += f.araToplam
                } else if tur.contains("AL") {
                    alisToplam += f.araToplam
                }
            }
            let netSatis = brutSatis - satisIade
            let brutKar = netSatis - alisToplam
            let rows: [[String]] = [
                ["Brüt Satış Gelirleri", AppFormatters.money(brutSatis)],
                ["Satış İadeleri (-)", AppFormatters.money(satisIade)],
                ["Net Satışlar", AppFormatters.money(netSatis)],
                ["Alış / Maliyet Toplamı (-)", AppFormatters.money(alisToplam)],
                ["DÖNEM BRÜT KÂRI", AppFormatters.money(brutKar)]
            ]
            return (headers, rows)
            
        case "Detaylı Gelir ve Maliyet Analizi":
            let headers = ["Tarih", "Fatura No", "Müşteri", "Tür", "Ara Toplam", "KDV", "Genel Toplam"]
            let rows: [[String]] = faturalar.map { f in
                [
                    String(f.tarih.prefix(10)),
                    f.faturaNo,
                    f.cariUnvan ?? "-",
                    f.faturaTuru,
                    AppFormatters.money(f.araToplam),
                    AppFormatters.money(f.kdvToplami),
                    AppFormatters.money(f.genelToplam)
                ]
            }
            return (headers, rows)
            
        case "Nakit Akış Tablosu":
            let headers = ["Tarih", "Açıklama", "Giren", "Çıkan", "Bakiye"]
            var running: Double = 0
            let rows: [[String]] = cariHareketler.reversed().map { h in
                running += (h.alacak - h.borc)
                return [
                    String((h.tarih ?? "-").prefix(10)),
                    h.aciklama ?? h.islemTuru ?? "-",
                    AppFormatters.money(h.alacak),
                    AppFormatters.money(h.borc),
                    AppFormatters.money(running)
                ]
            }
            return (headers, rows)
            
        // 6. Stratejik ve Analitik Raporlar
        case "Müşteri ABC Analizi":
            let headers = ["Müşteri", "Toplam Satış", "Pay %", "Sınıf"]
            var salesByCari: [String: Double] = [:]
            var grandTotal: Double = 0
            for f in faturalar where f.faturaTuru.uppercased().contains("SAT") {
                let name = f.cariUnvan ?? "Genel Müşteri"
                salesByCari[name, default: 0] += f.genelToplam
                grandTotal += f.genelToplam
            }
            let sorted = salesByCari.sorted { $0.value > $1.value }
            var cumulativePct: Double = 0
            let rows: [[String]] = sorted.map { name, total in
                let pct = grandTotal > 0 ? (total / grandTotal) * 100.0 : 0
                cumulativePct += pct
                let sinif: String
                if cumulativePct <= 70 { sinif = "A Sınıfı (Önemli)" }
                else if cumulativePct <= 90 { sinif = "B Sınıfı (Orta)" }
                else { sinif = "C Sınıfı (Standart)" }
                return [
                    name,
                    AppFormatters.money(total),
                    "%\(String(format: "%.1f", pct))",
                    sinif
                ]
            }
            return (headers, rows)
            
        case "Kar-Zarar Mukayesesi":
            let headers = ["Dönem", "Satış Cirosu", "Alış Tutarı", "Net Fark", "Oran %"]
            var byMonth: [String: (satis: Double, alis: Double)] = [:]
            for f in faturalar {
                let m = String(f.tarih.prefix(7))
                let key = m.isEmpty ? "Genel" : m
                var cur = byMonth[key] ?? (0, 0)
                if f.faturaTuru.uppercased().contains("SAT") {
                    cur.satis += f.genelToplam
                } else {
                    cur.alis += f.genelToplam
                }
                byMonth[key] = cur
            }
            let rows: [[String]] = byMonth.keys.sorted(by: >).compactMap { k in
                guard let v = byMonth[k] else { return nil }
                let diff = v.satis - v.alis
                let pct = v.alis > 0 ? (diff / v.alis) * 100.0 : 100.0
                return [
                    k,
                    AppFormatters.money(v.satis),
                    AppFormatters.money(v.alis),
                    AppFormatters.money(diff),
                    "%\(String(format: "%.1f", pct))"
                ]
            }
            return (headers, rows)
            
        case "Müşteri Kayıp (Churn)":
            let headers = ["Müşteri", "Son İşlem", "Bakiye", "Durum"]
            let rows: [[String]] = cariler.map { c in
                let lastFatura = faturalar.first { $0.cariId == c.id || $0.cariUnvan == c.unvan }
                let lastDateStr = lastFatura.map { String($0.tarih.prefix(10)) } ?? "İşlem Yok"
                let durum = lastFatura == nil ? "Hareketsiz (İzleniyor)" : "Aktif"
                return [
                    c.unvan,
                    lastDateStr,
                    AppFormatters.money(abs(c.bakiye)),
                    durum
                ]
            }
            return (headers, rows)
            
        case "Fiyat Dalgalanma Raporu":
            let headers = ["Ürün", "Alış Fiyatı", "Satış Fiyatı", "Marj Tutarı", "Fark %"]
            let rows: [[String]] = stoklar.map { s in
                let diff = s.satisFiyati - s.alisFiyati
                let pct = s.alisFiyati > 0 ? (diff / s.alisFiyati) * 100.0 : 0
                return [
                    s.stokAdi,
                    AppFormatters.money(s.alisFiyati),
                    AppFormatters.money(s.satisFiyati),
                    AppFormatters.money(diff),
                    "%\(String(format: "%.1f", pct))"
                ]
            }
            return (headers, rows)
            
        case "Müşteri Sadakat (LTV)":
            let headers = ["Müşteri", "İlk Alışveriş", "Son Alışveriş", "Toplam Harcama", "Ortalama Sepet"]
            var stats: [String: (dates: [String], total: Double, count: Int)] = [:]
            for f in faturalar where f.faturaTuru.uppercased().contains("SAT") {
                let name = f.cariUnvan ?? "Genel Müşteri"
                var cur = stats[name] ?? ([], 0, 0)
                cur.dates.append(String(f.tarih.prefix(10)))
                cur.total += f.genelToplam
                cur.count += 1
                stats[name] = cur
            }
            let rows: [[String]] = stats.sorted { $0.value.total > $1.value.total }.map { name, st in
                let sortedDates = st.dates.sorted()
                let firstD = sortedDates.first ?? "-"
                let lastD = sortedDates.last ?? "-"
                let avg = st.count > 0 ? (st.total / Double(st.count)) : 0
                return [
                    name,
                    firstD,
                    lastD,
                    AppFormatters.money(st.total),
                    AppFormatters.money(avg)
                ]
            }
            return (headers, rows)
            
        case "Finansal Isı Haritası":
            let headers = ["Tarih", "Satış", "Alış", "Tahsilat", "Ödeme", "Net Akış"]
            var daily: [String: (satis: Double, alis: Double, tahsilat: Double, odeme: Double)] = [:]
            for f in faturalar {
                let d = String(f.tarih.prefix(10))
                guard !d.isEmpty else { continue }
                var cur = daily[d] ?? (0, 0, 0, 0)
                if f.faturaTuru.uppercased().contains("SAT") { cur.satis += f.genelToplam }
                else { cur.alis += f.genelToplam }
                daily[d] = cur
            }
            for h in cariHareketler {
                let d = String((h.tarih ?? "").prefix(10))
                guard !d.isEmpty else { continue }
                var cur = daily[d] ?? (0, 0, 0, 0)
                cur.tahsilat += h.alacak
                cur.odeme += h.borc
                daily[d] = cur
            }
            let rows: [[String]] = daily.keys.sorted(by: >).compactMap { d in
                guard let v = daily[d] else { return nil }
                let net = (v.satis + v.tahsilat) - (v.alis + v.odeme)
                return [
                    d,
                    AppFormatters.money(v.satis),
                    AppFormatters.money(v.alis),
                    AppFormatters.money(v.tahsilat),
                    AppFormatters.money(v.odeme),
                    AppFormatters.money(net)
                ]
            }
            return (headers, rows)
            
        case "Tahsilat Süresi (DSO)":
            let headers = ["Müşteri", "Ortalama Vade (Gün)", "Toplam Alacak", "Durum"]
            let rows: [[String]] = cariler.filter { $0.bakiye > 0 && $0.bakiyeTuru != "A" }.map { c in
                let vade = c.vadeGunu ?? 0
                let durum = vade <= 30 ? "Normal (Vadesinde)" : "Uzun Vadeli"
                return [
                    c.unvan,
                    "\(vade) Gün",
                    AppFormatters.money(abs(c.bakiye)),
                    durum
                ]
            }
            return (headers, rows)
            
        case "Bütçe / Hedef Takibi":
            let headers = ["Dönem (Ay)", "Gerçekleşen Satış", "Fatura Adedi", "Ortalama Fatura"]
            var byMonth: [String: (total: Double, count: Int)] = [:]
            for f in faturalar where f.faturaTuru.uppercased().contains("SAT") {
                let m = String(f.tarih.prefix(7))
                let key = m.isEmpty ? "Genel" : m
                var cur = byMonth[key] ?? (0, 0)
                cur.total += f.genelToplam
                cur.count += 1
                byMonth[key] = cur
            }
            let rows: [[String]] = byMonth.keys.sorted(by: >).compactMap { k in
                guard let v = byMonth[k] else { return nil }
                let avg = v.count > 0 ? v.total / Double(v.count) : 0
                return [
                    k,
                    AppFormatters.money(v.total),
                    "\(v.count) Adet",
                    AppFormatters.money(avg)
                ]
            }
            return (headers, rows)
            
        default:
            return (report.headers, [])
        }
    }
}
