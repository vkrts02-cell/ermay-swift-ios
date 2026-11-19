import SwiftUI

public struct DovizView: View {
    @State private var kurlar: [DovizKuru] = [
        DovizKuru(kod: "USD", ad: "Amerikan Doları (TRY)", alis: 50.30, satis: 50.37, degisim: 0.22, tarih: "Canlı"),
        DovizKuru(kod: "EUR", ad: "Euro (TRY)", alis: 55.49, satis: 55.56, degisim: -0.24, tarih: "Canlı"),
        DovizKuru(kod: "ALTIN", ad: "Gram Altın (TRY)", alis: 6271.12, satis: 6280.54, degisim: 0.32, tarih: "Canlı"),
        DovizKuru(kod: "BRENT", ad: "Brent Petrol (USD)", alis: 95.98, satis: 96.13, degisim: 0.32, tarih: "Canlı")
    ]
    
    // Çevirici State
    @State private var girilenTutar: String = "1000"
    @State private var seciliKaynak: String = "USD"
    @State private var seciliHedef: String = "TL"
    
    public init() {}
    
    public var hesaplananSonuc: Double {
        let tutar = Double(girilenTutar.replacingOccurrences(of: ",", with: ".")) ?? 0.0
        let usdRate = kurlar.first(where: { $0.kod == "USD" })?.satis ?? 50.37
        let eurRate = kurlar.first(where: { $0.kod == "EUR" })?.satis ?? 55.56
        let altinRate = kurlar.first(where: { $0.kod == "ALTIN" || $0.kod == "GA" })?.satis ?? 6280.54
        let brentUsdRate = kurlar.first(where: { $0.kod == "BRENT" })?.satis ?? 96.13
        
        var tutarTL = tutar
        if seciliKaynak == "USD" { tutarTL = tutar * usdRate }
        else if seciliKaynak == "EUR" { tutarTL = tutar * eurRate }
        else if seciliKaynak == "ALTIN" { tutarTL = tutar * altinRate }
        else if seciliKaynak == "BRENT" { tutarTL = tutar * brentUsdRate * usdRate }
        
        if seciliHedef == "TL" { return tutarTL }
        else if seciliHedef == "USD" { return tutarTL / usdRate }
        else if seciliHedef == "EUR" { return tutarTL / eurRate }
        else if seciliHedef == "ALTIN" { return tutarTL / altinRate }
        else if seciliHedef == "BRENT" { return tutarTL / (brentUsdRate * usdRate) }
        return tutarTL
    }
    
    public var body: some View {
        NavigationStack {
            ZStack {
                AppTheme.background.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 18) {
                        // Header
                        HStack {
                            Text("Döviz Kurları & Çevirici")
                                .font(.system(size: 24, weight: .bold))
                                .foregroundColor(AppTheme.textPrimary)
                            Spacer()
                        }
                        .padding(.horizontal)
                        .padding(.top, 8)
                        
                        // Canlı Kurlar Grid
                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                            ForEach(kurlar) { kur in
                                GlassCard(cornerRadius: 14, padding: 14) {
                                    VStack(alignment: .leading, spacing: 6) {
                                        HStack {
                                            Text(kur.kod)
                                                .font(.system(size: 16, weight: .heavy))
                                                .foregroundColor(AppTheme.textPrimary)
                                            Spacer()
                                            Text(kur.degisim >= 0 ? "+%\(String(format: "%.2f", kur.degisim))" : "-%\(String(format: "%.2f", abs(kur.degisim)))")
                                                .font(.system(size: 10, weight: .bold))
                                                .foregroundColor(kur.degisim >= 0 ? AppTheme.success : AppTheme.danger)
                                        }
                                        
                                        Text(kur.ad)
                                            .font(.system(size: 11))
                                            .foregroundColor(AppTheme.textMuted)
                                            .lineLimit(1)
                                        
                                        Divider().background(AppTheme.border)
                                        
                                        HStack {
                                            VStack(alignment: .leading, spacing: 1) {
                                                Text("Satış")
                                                    .font(.system(size: 9))
                                                    .foregroundColor(AppTheme.textMuted)
                                                Text(kur.kod == "BRENT" ? "$\(String(format: "%.2f", kur.satis))" : "₺\(String(format: "%.2f", kur.satis))")
                                                    .font(.system(size: 14, weight: .bold))
                                                    .foregroundColor(AppTheme.textPrimary)
                                            }
                                            Spacer()
                                            VStack(alignment: .trailing, spacing: 1) {
                                                Text("Alış")
                                                    .font(.system(size: 9))
                                                    .foregroundColor(AppTheme.textMuted)
                                                Text(kur.kod == "BRENT" ? "$\(String(format: "%.2f", kur.alis))" : "₺\(String(format: "%.2f", kur.alis))")
                                                    .font(.system(size: 13))
                                                    .foregroundColor(AppTheme.textSecondary)
                                            }
                                        }
                                    }
                                }
                            }
                        }
                        .padding(.horizontal)
                        
                        // Hızlı Çevirici Kartı
                        GlassCard(cornerRadius: 18, padding: 18) {
                            VStack(spacing: 14) {
                                HStack {
                                    Text("CANLI DÖVİZ ÇEVİRİCİ")
                                        .font(.system(size: 11, weight: .bold))
                                        .foregroundColor(AppTheme.textSecondary)
                                    Spacer()
                                    Image(systemName: "arrow.triangle.2.circlepath")
                                        .foregroundColor(AppTheme.primary)
                                }
                                
                                FormField(label: "Çevrilecek Miktar", text: $girilenTutar, placeholder: "1000")
                                
                                HStack(spacing: 12) {
                                    Picker("Kaynak", selection: $seciliKaynak) {
                                        Text("USD ($)").tag("USD")
                                        Text("EUR (€)").tag("EUR")
                                        Text("ALTIN (Gr)").tag("ALTIN")
                                        Text("BRENT ($)").tag("BRENT")
                                        Text("TL (₺)").tag("TL")
                                    }
                                    .pickerStyle(.menu)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 8)
                                    .background(AppTheme.cardBackground)
                                    .cornerRadius(10)
                                    
                                    Image(systemName: "arrow.right")
                                        .foregroundColor(AppTheme.textMuted)
                                    
                                    Picker("Hedef", selection: $seciliHedef) {
                                        Text("TL (₺)").tag("TL")
                                        Text("USD ($)").tag("USD")
                                        Text("EUR (€)").tag("EUR")
                                        Text("ALTIN (Gr)").tag("ALTIN")
                                        Text("BRENT ($)").tag("BRENT")
                                    }
                                    .pickerStyle(.menu)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 8)
                                    .background(AppTheme.cardBackground)
                                    .cornerRadius(10)
                                }
                                
                                Divider().background(AppTheme.border)
                                
                                VStack(spacing: 4) {
                                    Text("Hesaplanan Karşılık:")
                                        .font(.system(size: 11))
                                        .foregroundColor(AppTheme.textMuted)
                                    Text(seciliHedef == "TL" ? AppFormatters.money(hesaplananSonuc) : String(format: "%.2f %@", hesaplananSonuc, seciliHedef))
                                        .font(.system(size: 26, weight: .heavy))
                                        .foregroundColor(AppTheme.success)
                                }
                            }
                        }
                        .padding(.horizontal)
                        
                        Spacer().frame(height: 40)
                    }
                }
            }
            .navigationBarHidden(true)
            .task {
                await loadKurlar()
            }
            .onReceive(NotificationCenter.default.publisher(for: .supabaseRealtimeDataChanged)) { _ in
                Task {
                    await loadKurlar()
                }
            }
        }
    }
    
    private func parseDovizComDouble(_ raw: String) -> Double {
        var cleaned = raw
            .replacingOccurrences(of: "$", with: "")
            .replacingOccurrences(of: "₺", with: "")
            .replacingOccurrences(of: "€", with: "")
            .replacingOccurrences(of: "%", with: "")
            .replacingOccurrences(of: "+", with: "")
            .trimmingCharacters(in: .whitespacesAndNewlines)
        if cleaned.contains(",") {
            cleaned = cleaned.replacingOccurrences(of: ".", with: "")
                             .replacingOccurrences(of: ",", with: ".")
        }
        return Double(cleaned) ?? 0.0
    }
    
    private func extractDovizComAttr(_ html: String, key: String, attr: String) -> Double {
        let escapedKey = NSRegularExpression.escapedPattern(for: key)
        let escapedAttr = NSRegularExpression.escapedPattern(for: attr)
        let patterns = [
            "data-socket-key=\"\(escapedKey)\"[^>]*data-socket-attr=\"\(escapedAttr)\"[^>]*>\\s*([^<]+?)\\s*<",
            "data-socket-attr=\"\(escapedAttr)\"[^>]*data-socket-key=\"\(escapedKey)\"[^>]*>\\s*([^<]+?)\\s*<"
        ]
        for pattern in patterns {
            if let regex = try? NSRegularExpression(pattern: pattern, options: []),
               let match = regex.firstMatch(in: html, options: [], range: NSRange(html.startIndex..., in: html)),
               let range = Range(match.range(at: 1), in: html) {
                return parseDovizComDouble(String(html[range]))
            }
        }
        return 0.0
    }
    
    private func loadKurlar() async {
        // 1. Öncelikle https://www.doviz.com/ üzerinden canlı USD/TRY, EUR/TRY, Gram Altın TRY ve Brent USD verilerini çek
        if let dovizUrl = URL(string: "https://www.doviz.com/") {
            var request = URLRequest(url: dovizUrl)
            request.setValue("Mozilla/5.0 (iPhone; CPU iPhone OS 17_0 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.0 Mobile/15E148 Safari/604.1", forHTTPHeaderField: "User-Agent")
            if let (data, _) = try? await URLSession.shared.data(for: request),
               let html = String(data: data, encoding: .utf8) {
                let targets: [(socketKey: String, kod: String, ad: String)] = [
                    ("USD", "USD", "Amerikan Doları (TRY)"),
                    ("EUR", "EUR", "Euro (TRY)"),
                    ("gram-altin", "ALTIN", "Gram Altın (TRY)"),
                    ("BRENT", "BRENT", "Brent Petrol (USD)")
                ]
                var liveList: [DovizKuru] = []
                for t in targets {
                    let satis = extractDovizComAttr(html, key: t.socketKey, attr: "s")
                    if satis > 0 {
                        let degisim = extractDovizComAttr(html, key: t.socketKey, attr: "c")
                        let alis = (satis * 0.9985 * 10000).rounded() / 10000
                        liveList.append(DovizKuru(kod: t.kod, ad: t.ad, alis: alis, satis: satis, degisim: degisim, tarih: "Canlı (Doviz.com)"))
                    }
                }
                if !liveList.isEmpty {
                    await MainActor.run {
                        self.kurlar = liveList
                    }
                    return
                }
            }
        }
        
        // 2. Fallback: Supabase doviz_kurlari tablosu
        do {
            let fetched: [DovizKuru] = try await SupabaseService.shared.fetch(from: "doviz_kurlari")
            if !fetched.isEmpty {
                await MainActor.run {
                    self.kurlar = fetched
                }
                return
            }
        } catch {}
        
        // 3. Fallback: TCMB yedek kur servisi
        guard let url = URL(string: "https://hasanadiguzel.com.tr/api/kurgetir") else { return }
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
               let tcmbList = json["TCMB_AnlikKurBilgileri"] as? [[String: Any]] {
                var newKurlar: [DovizKuru] = []
                for item in tcmbList {
                    let kod = (item["Isim"] as? String) ?? (item["CurrencyCode"] as? String) ?? ""
                    let alis = Double("\(item["ForexBuying"] ?? 0)") ?? 0.0
                    let satis = Double("\(item["ForexSelling"] ?? 0)") ?? 0.0
                    if kod == "US DOLLAR" || item["CurrencyCode"] as? String == "USD" {
                        newKurlar.append(DovizKuru(kod: "USD", ad: "Amerikan Doları (TRY)", alis: alis, satis: satis, degisim: 0.12, tarih: "Bugün"))
                    } else if kod == "EURO" || item["CurrencyCode"] as? String == "EUR" {
                        newKurlar.append(DovizKuru(kod: "EUR", ad: "Euro (TRY)", alis: alis, satis: satis, degisim: -0.05, tarih: "Bugün"))
                    } else if kod == "POUND STERLING" || item["CurrencyCode"] as? String == "GBP" {
                        newKurlar.append(DovizKuru(kod: "GBP", ad: "İngiliz Sterlini (TRY)", alis: alis, satis: satis, degisim: 0.20, tarih: "Bugün"))
                    }
                }
                if !newKurlar.isEmpty {
                    await MainActor.run {
                        self.kurlar = newKurlar
                    }
                }
            }
        } catch {}
    }
}

