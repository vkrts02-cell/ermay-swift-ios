import SwiftUI

public struct DovizView: View {
    @State private var kurlar: [DovizKuru] = [
        DovizKuru(kod: "USD", ad: "Amerikan Doları", alis: 34.25, satis: 34.32, degisim: 0.15, tarih: "02.11.2026"),
        DovizKuru(kod: "EUR", ad: "Euro", alis: 37.10, satis: 37.18, degisim: -0.08, tarih: "02.11.2026"),
        DovizKuru(kod: "GBP", ad: "İngiliz Sterlini", alis: 44.50, satis: 44.62, degisim: 0.22, tarih: "02.11.2026"),
        DovizKuru(kod: "ALTIN", ad: "Gram Altın (TL)", alis: 3020.00, satis: 3035.00, degisim: 0.45, tarih: "02.11.2026")
    ]
    
    // Çevirici State
    @State private var girilenTutar: String = "1000"
    @State private var seciliKaynak: String = "USD"
    @State private var seciliHedef: String = "TL"
    
    public init() {}
    
    public var hesaplananSonuc: Double {
        let tutar = Double(girilenTutar) ?? 0.0
        let usdRate = kurlar.first(where: { $0.kod == "USD" })?.satis ?? 34.30
        let eurRate = kurlar.first(where: { $0.kod == "EUR" })?.satis ?? 37.15
        
        var tutarTL = tutar
        if seciliKaynak == "USD" { tutarTL = tutar * usdRate }
        else if seciliKaynak == "EUR" { tutarTL = tutar * eurRate }
        
        if seciliHedef == "TL" { return tutarTL }
        else if seciliHedef == "USD" { return tutarTL / usdRate }
        else if seciliHedef == "EUR" { return tutarTL / eurRate }
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
                                                Text("₺\(String(format: "%.2f", kur.satis))")
                                                    .font(.system(size: 14, weight: .bold))
                                                    .foregroundColor(AppTheme.textPrimary)
                                            }
                                            Spacer()
                                            VStack(alignment: .trailing, spacing: 1) {
                                                Text("Alış")
                                                    .font(.system(size: 9))
                                                    .foregroundColor(AppTheme.textMuted)
                                                Text("₺\(String(format: "%.2f", kur.alis))")
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
        }
    }
}

