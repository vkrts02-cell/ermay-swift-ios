import SwiftUI

public struct FinansView: View {
    @State private var selectedTab: String = "ozet" // "ozet", "hesaplar", "hareketler"
    @State private var period: String = "Aylık" // "Haftalık", "Aylık", "6 Aylık", "Yıllık"
    @State private var hesaplar: [KasaBanka] = [
        KasaBanka(id: "1", hesapAdi: "Merkez TL Kasası", hesapTuru: "KASA", bakiye: 45850.50),
        KasaBanka(id: "2", hesapAdi: "Garanti BBVA Ticari TL", hesapTuru: "BANKA", bankaAdi: "Garanti BBVA", iban: "TR12 0006 2000 1234 5678 9012 34", bakiye: 154000.00),
        KasaBanka(id: "3", hesapAdi: "İş Bankası Şirket Hesabı", hesapTuru: "BANKA", bankaAdi: "Türkiye İş Bankası", iban: "TR64 0006 4000 0012 3456 7890 12", bakiye: 46000.00)
    ]
    @State private var hareketler: [KasaHareket] = [
        KasaHareket(id: "1", tarih: "02.11.2026", evrakNo: "THS-094", islemTuru: "Tahsilat", aciklama: "Ermay Bilişim Nakit Tahsilat", tutar: 15000.0),
        KasaHareket(id: "2", tarih: "01.11.2026", evrakNo: "EFT-102", islemTuru: "Ödeme", aciklama: "Akıncılar Çelik Döküm Malzeme Bedeli", tutar: 28000.0),
        KasaHareket(id: "3", tarih: "30.10.2026", evrakNo: "VRM-003", islemTuru: "Virman", aciklama: "Kasadan Bankaya Nakit Yatırma", tutar: 10000.0)
    ]
    
    // Sheets
    @State private var showTahsilatForm: Bool = false
    @State private var isTahsilat: Bool = true
    @State private var isLoading: Bool = false
    
    public init() {}
    
    public var toplamBakiye: Double {
        hesaplar.reduce(0.0) { $0 + $1.bakiye }
    }
    
    public var body: some View {
        NavigationStack {
            ZStack {
                AppTheme.background.ignoresSafeArea()
                
                VStack(spacing: 12) {
                    // Header Bar
                    HStack {
                        Text("Finans Yönetimi")
                            .font(.system(size: 24, weight: .black))
                            .foregroundColor(AppTheme.textPrimary)
                        
                        Spacer()
                        
                        HStack(spacing: 8) {
                            Button {
                                isTahsilat = true
                                showTahsilatForm = true
                            } label: {
                                Image(systemName: "arrow.down.left.circle.fill")
                                    .font(.system(size: 24))
                                    .foregroundColor(AppTheme.success)
                            }
                            
                            Button {
                                isTahsilat = false
                                showTahsilatForm = true
                            } label: {
                                Image(systemName: "arrow.up.right.circle.fill")
                                    .font(.system(size: 24))
                                    .foregroundColor(AppTheme.danger)
                            }
                        }
                    }
                    .padding(.horizontal)
                    .padding(.top, 8)
                    
                    // Segmented Tabs (Özet & Akış / Hesaplar / Hareketler)
                    HStack(spacing: 4) {
                        TabFilterButton(title: "Özet & Akış", isSelected: selectedTab == "ozet") {
                            selectedTab = "ozet"
                        }
                        TabFilterButton(title: "Kasa & Banka", isSelected: selectedTab == "hesaplar") {
                            selectedTab = "hesaplar"
                        }
                        TabFilterButton(title: "Hareketler", isSelected: selectedTab == "hareketler") {
                            selectedTab = "hareketler"
                        }
                    }
                    .padding(.horizontal)
                    
                    ScrollView {
                        VStack(spacing: 16) {
                            if selectedTab == "ozet" {
                                renderOzetView()
                            } else if selectedTab == "hesaplar" {
                                renderHesaplarView()
                            } else {
                                renderHareketlerView()
                            }
                        }
                        .padding(.top, 4)
                        
                        Spacer().frame(height: 80)
                    }
                }
            }
            .navigationBarHidden(true)
            .sheet(isPresented: $showTahsilatForm) {
                TahsilatFormView(isTahsilat: isTahsilat) { h in
                    hareketler.insert(h, at: 0)
                }
            }
            .task {
                await loadFinansData()
            }
        }
    }
    
    // 1. ÖZET & AKIŞ GÖRÜNÜMÜ (Exact match to FinansScreen.tsx)
    @ViewBuilder
    private func renderOzetView() -> some View {
        // Dönem Filtresi
        VStack(alignment: .leading, spacing: 8) {
            Text("DÖNEM FİLTRESİ")
                .font(.system(size: 11, weight: .bold))
                .foregroundColor(AppTheme.textSecondary)
                .padding(.horizontal)
            
            HStack(spacing: 6) {
                ForEach(["Haftalık", "Aylık", "6 Aylık", "Yıllık"], id: \.self) { p in
                    Button {
                        period = p
                    } label: {
                        Text(p)
                            .font(.system(size: 11, weight: period == p ? .bold : .medium))
                            .foregroundColor(period == p ? .white : AppTheme.textSecondary)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 7)
                            .background(period == p ? AppTheme.primary : AppTheme.cardSecondary)
                            .cornerRadius(8)
                    }
                }
            }
            .padding(.horizontal)
        }
        
        // Kendi Kasamızda Kalan Net Paralar 4'lü Izgara
        VStack(alignment: .leading, spacing: 10) {
            Text("KENDİ KASAMIZDA KALAN NET PARALAR")
                .font(.system(size: 11, weight: .bold))
                .foregroundColor(AppTheme.textSecondary)
                .padding(.horizontal)
            
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                FinansStatCard(title: "Nakit Kasa", val: 45850.50, color: Color(hex: "30D158"))
                FinansStatCard(title: "Banka EFT/Havale", val: 200000.00, color: Color(hex: "0A84FF"))
                FinansStatCard(title: "Kredi Kartı", val: 32400.00, color: Color(hex: "BF5AF2"))
                FinansStatCard(title: "Portföy Çek/Senet", val: 78500.00, color: Color(hex: "FF9F0A"))
            }
            .padding(.horizontal)
        }
        
        // Tedarikçiye Yönlendirilen Paralar (Ciro)
        VStack(alignment: .leading, spacing: 10) {
            Text("TEDARİKÇİYE YÖNLENDİRİLEN PARALAR (CİRO)")
                .font(.system(size: 11, weight: .bold))
                .foregroundColor(AppTheme.textSecondary)
                .padding(.horizontal)
            
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                FinansStatCard(title: "Ciro Edilen Çek", val: 42000.00, color: Color(hex: "EF4444"))
                FinansStatCard(title: "Havale/EFT Çıkış", val: 65000.00, color: Color(hex: "F97316"))
            }
            .padding(.horizontal)
        }
    }
    
    // 2. KASA & BANKA HESAPLARI GÖRÜNÜMÜ
    @ViewBuilder
    private func renderHesaplarView() -> some View {
        // Toplam Bakiye Kartı
        GlassCard(cornerRadius: 16, padding: 16) {
            VStack(spacing: 8) {
                Text("TOPLAM LİKİDİTE MEVCUDU")
                    .font(.system(size: 11, weight: .bold))
                    .foregroundColor(AppTheme.textSecondary)
                Text(AppFormatters.money(toplamBakiye))
                    .font(.system(size: 26, weight: .heavy))
                    .foregroundColor(Color(hex: "00FF87"))
            }
        }
        .padding(.horizontal)
        
        VStack(spacing: 10) {
            ForEach(hesaplar) { h in
                GlassCard(cornerRadius: 14, padding: 14) {
                    HStack(spacing: 12) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 10)
                                .fill(AppTheme.primary.opacity(0.15))
                                .frame(width: 40, height: 40)
                            Image(systemName: h.hesapTuru == "KASA" ? "wallet.pass.fill" : "building.columns.fill")
                                .foregroundColor(AppTheme.primary)
                        }
                        
                        VStack(alignment: .leading, spacing: 3) {
                            Text(h.hesapAdi)
                                .font(.system(size: 14, weight: .bold))
                                .foregroundColor(AppTheme.textPrimary)
                            if let iban = h.iban {
                                Text(iban)
                                    .font(.system(size: 10, design: .monospaced))
                                    .foregroundColor(AppTheme.textMuted)
                            } else {
                                Text("Nakit TL Kasası")
                                    .font(.system(size: 11))
                                    .foregroundColor(AppTheme.textMuted)
                            }
                        }
                        
                        Spacer()
                        
                        Text(AppFormatters.money(h.bakiye))
                            .font(.system(size: 14, weight: .heavy))
                            .foregroundColor(AppTheme.textPrimary)
                    }
                }
            }
        }
        .padding(.horizontal)
    }
    
    // 3. FİNANS HAREKETLERİ GÖRÜNÜMÜ
    @ViewBuilder
    private func renderHareketlerView() -> some View {
        VStack(spacing: 10) {
            ForEach(hareketler) { h in
                let isIn = h.islemTuru == "Tahsilat"
                GlassCard(cornerRadius: 14, padding: 12) {
                    HStack(spacing: 12) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 10)
                                .fill((isIn ? Color(hex: "10B981") : Color(hex: "EF4444")).opacity(0.15))
                                .frame(width: 36, height: 36)
                            Image(systemName: isIn ? "arrow.down.left" : "arrow.up.right")
                                .font(.system(size: 14, weight: .bold))
                                .foregroundColor(isIn ? Color(hex: "10B981") : Color(hex: "EF4444"))
                        }
                        
                        VStack(alignment: .leading, spacing: 3) {
                            Text(h.aciklama ?? (h.islemTuru ?? "Finans Hareketi"))
                                .font(.system(size: 13, weight: .bold))
                                .foregroundColor(AppTheme.textPrimary)
                                .lineLimit(1)
                            
                            HStack(spacing: 4) {
                                Text(h.islemTuru ?? "İşlem")
                                Text("•")
                                Text(h.tarih ?? "02.11.2026")
                            }
                            .font(.system(size: 11))
                            .foregroundColor(AppTheme.textMuted)
                        }
                        
                        Spacer()
                        
                        Text((isIn ? "+" : "-") + AppFormatters.money(h.tutar))
                            .font(.system(size: 13, weight: .heavy))
                            .foregroundColor(isIn ? Color(hex: "10B981") : Color(hex: "EF4444"))
                    }
                }
            }
        }
        .padding(.horizontal)
    }
    
    private func loadFinansData() async {
        isLoading = true
        do {
            let items: [KasaBanka] = try await SupabaseService.shared.fetch(from: "kasalar")
            if !items.isEmpty {
                await MainActor.run {
                    self.hesaplar = items
                }
            }
        } catch {
            print("Finans load notice: \(error.localizedDescription)")
        }
        isLoading = false
    }
}

struct FinansStatCard: View {
    let title: String
    let val: Double
    let color: Color
    
    var body: some View {
        GlassCard(cornerRadius: 14, padding: 14) {
            VStack(alignment: .leading, spacing: 6) {
                Text(AppFormatters.money(val))
                    .font(.system(size: 16, weight: .heavy))
                    .foregroundColor(color)
                    .lineLimit(1)
                Text(title)
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(AppTheme.textSecondary)
                    .lineLimit(1)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}
