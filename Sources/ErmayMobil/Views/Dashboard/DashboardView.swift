import SwiftUI
#if canImport(Charts)
import Charts
#endif

struct WeeklyGoalData: Identifiable {
    let id = UUID()
    let week: String
    let target: Double
    let actual: Double
}

struct DashboardListItem: Identifiable {
    let id: String
    let title: String
    let description: String
    let date: String
    let vadeGun: Int?
    let amount: Double
    let type: String // "In" or "Out"
}

public struct DashboardView: View {
    @State private var alacaklar: Double = 98400.00
    @State private var borclar: Double = 34200.00
    @State private var kasaBanka: Double = 245850.50
    @State private var activeTab: String = "recents" // "recents", "alacak", "borc"
    @State private var isWeekly: Bool = true
    @State private var isLoading: Bool = false
    
    // Sheet Forms
    @State private var showSatisFaturaForm: Bool = false
    @State private var showAlisFaturaForm: Bool = false
    @State private var showSiparisForm: Bool = false
    @State private var showTeklifForm: Bool = false
    
    // Loaded Data
    @State private var carilerList: [CariKart] = []
    @State private var faturalarList: [Fatura] = []
    
    // Hedef Verileri
    @State private var goalData: [WeeklyGoalData] = [
        WeeklyGoalData(week: "44.H", target: 62500, actual: 58000),
        WeeklyGoalData(week: "45.H", target: 62500, actual: 64200),
        WeeklyGoalData(week: "46.H", target: 62500, actual: 49000),
        WeeklyGoalData(week: "47.H", target: 62500, actual: 71000),
        WeeklyGoalData(week: "48.H", target: 62500, actual: 53125)
    ]
    
    public init() {}
    
    public var netLikidite: Double {
        kasaBanka + alacaklar - borclar
    }
    
    public var toplamHedef: Double {
        goalData.reduce(0.0) { $0 + $1.target }
    }
    
    public var toplamGerceklesen: Double {
        goalData.reduce(0.0) { $0 + $1.actual }
    }
    
    public var completionRate: Int {
        guard toplamHedef > 0 else { return 0 }
        return min(100, Int((toplamGerceklesen / toplamHedef) * 100))
    }
    
    // Format cari name cleanly for mobile dashboard
    private func formatCariName(_ raw: String) -> String {
        return raw
            .replacingOccurrences(of: "SANAYİ VE TİCARET LİMİTED ŞİRKETİ", with: "LTD.")
            .replacingOccurrences(of: "SANAYİ VE TİCARET ANONİM ŞİRKETİ", with: "A.Ş.")
            .replacingOccurrences(of: "SAN. VE TİC. LTD. ŞTİ.", with: "LTD.")
            .replacingOccurrences(of: "SAN. VE TİC. A.Ş.", with: "A.Ş.")
            .replacingOccurrences(of: "LİMİTED ŞİRKETİ", with: "LTD.")
            .replacingOccurrences(of: "ANONİM ŞİRKETİ", with: "A.Ş.")
            .trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    private var currentListData: [DashboardListItem] {
        switch activeTab {
        case "alacak":
            let items = carilerList.filter { $0.bakiyeTuru == "A" && $0.bakiye > 0 }
                .sorted { $0.bakiye > $1.bakiye }
                .prefix(5)
            if !items.isEmpty {
                return items.map { c in
                    DashboardListItem(
                        id: c.id,
                        title: formatCariName(c.unvan),
                        description: "Müşteri",
                        date: "Alacak",
                        vadeGun: 15,
                        amount: c.bakiye,
                        type: "In"
                    )
                }
            } else {
                return [
                    DashboardListItem(id: "a1", title: "Ermay Bilişim Sanayi Ltd.", description: "Müşteri", date: "Alacak", vadeGun: 12, amount: 45200.0, type: "In"),
                    DashboardListItem(id: "a2", title: "Mega Plastik San.", description: "Müşteri", date: "Alacak", vadeGun: 28, amount: 28400.0, type: "In"),
                    DashboardListItem(id: "a3", title: "Kaya Metal A.Ş.", description: "Müşteri", date: "Alacak", vadeGun: 5, amount: 24800.0, type: "In")
                ]
            }
        case "borc":
            let items = carilerList.filter { $0.bakiyeTuru == "B" && $0.bakiye > 0 }
                .sorted { $0.bakiye > $1.bakiye }
                .prefix(5)
            if !items.isEmpty {
                return items.map { c in
                    DashboardListItem(
                        id: c.id,
                        title: formatCariName(c.unvan),
                        description: "Tedarikçi",
                        date: "Borç",
                        vadeGun: 8,
                        amount: c.bakiye,
                        type: "Out"
                    )
                }
            } else {
                return [
                    DashboardListItem(id: "b1", title: "Akıncılar Çelik Döküm A.Ş.", description: "Tedarikçi", date: "Borç", vadeGun: 14, amount: 22800.0, type: "Out"),
                    DashboardListItem(id: "b2", title: "Özkanlar Ambalaj Ltd.", description: "Tedarikçi", date: "Borç", vadeGun: 3, amount: 11400.0, type: "Out")
                ]
            }
        default: // recents
            if !faturalarList.isEmpty {
                return faturalarList.prefix(5).map { f in
                    let isIn = f.faturaTuru.uppercased().contains("SATIS") || f.faturaTuru.uppercased().contains("SATIŞ")
                    return DashboardListItem(
                        id: f.id,
                        title: formatCariName(f.cariUnvan ?? "İşlem"),
                        description: "\(f.faturaTuru) Faturası",
                        date: f.tarih,
                        vadeGun: nil,
                        amount: f.genelToplam,
                        type: isIn ? "In" : "Out"
                    )
                }
            } else {
                return [
                    DashboardListItem(id: "r1", title: "Ermay Bilişim Ltd. Şti.", description: "Satış Faturası", date: "02.11.2026", vadeGun: 15, amount: 14500.0, type: "In"),
                    DashboardListItem(id: "r2", title: "Kaya Metal A.Ş.", description: "Tahsilat", date: "01.11.2026", vadeGun: nil, amount: 35000.0, type: "In"),
                    DashboardListItem(id: "r3", title: "Akıncılar Çelik Döküm", description: "Tediye", date: "31.10.2026", vadeGun: nil, amount: 6200.0, type: "Out"),
                    DashboardListItem(id: "r4", title: "Mega Plastik San.", description: "Alış Faturası", date: "30.10.2026", vadeGun: 22, amount: 22800.0, type: "Out")
                ]
            }
        }
    }
    
    public var body: some View {
        NavigationStack {
            ZStack {
                AppTheme.background.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 16) {
                        // Üst Header
                        HStack {
                            VStack(alignment: .leading, spacing: 3) {
                                Text("Gösterge Paneli")
                                    .font(.system(size: 24, weight: .black))
                                    .foregroundColor(AppTheme.textPrimary)
                                Text("Masaüstü sürümü ile anlık senkronize")
                                    .font(.system(size: 11, weight: .medium))
                                    .foregroundColor(AppTheme.textMuted)
                            }
                            
                            Spacer()
                            
                            Button {
                                Task { await loadDashboardData() }
                            } label: {
                                Image(systemName: "arrow.clockwise.circle.fill")
                                    .font(.system(size: 26))
                                    .foregroundColor(AppTheme.primary)
                            }
                        }
                        .padding(.horizontal)
                        .padding(.top, 8)
                        
                        // 4'lü 2x2 Izgara Kartları
                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                            DashboardMetricCard(
                                title: "ALACAKLAR",
                                value: AppFormatters.money(alacaklar),
                                subtitle: "Bekleyen",
                                icon: "arrow.up.right",
                                color: Color(hex: "0A84FF")
                            )
                            
                            DashboardMetricCard(
                                title: "BORÇLAR",
                                value: AppFormatters.money(borclar),
                                subtitle: "Ödenecek",
                                icon: "banknote.fill",
                                color: Color(hex: "FF453A")
                            )
                            
                            DashboardMetricCard(
                                title: "KASA & BANKA",
                                value: AppFormatters.money(kasaBanka),
                                subtitle: "Toplam Mevcut",
                                icon: "wallet.pass.fill",
                                color: Color(hex: "30D158")
                            )
                            
                            // NET Kartı (Özel Parlak Vurgu)
                            GlassCard(cornerRadius: 16, padding: 14) {
                                VStack(alignment: .leading, spacing: 8) {
                                    HStack {
                                        Text("NET")
                                            .font(.system(size: 11, weight: .bold))
                                            .foregroundColor(Color(hex: "00FF87"))
                                        Spacer()
                                        Image(systemName: "chart.line.uptrend.xyaxis")
                                            .foregroundColor(Color(hex: "00FF87"))
                                    }
                                    Text(AppFormatters.money(netLikidite))
                                        .font(.system(size: 16, weight: .heavy))
                                        .foregroundColor(Color(hex: "00FF87"))
                                    Text("Net Likidite Durumu")
                                        .font(.system(size: 10))
                                        .foregroundColor(Color(hex: "00FF87").opacity(0.85))
                                }
                            }
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(Color(hex: "00FF87").opacity(0.3), lineWidth: 1.5)
                            )
                        }
                        .padding(.horizontal)
                        
                        // HIZLI İŞLEMLER Bölümü
                        GlassCard(cornerRadius: 18, padding: 16) {
                            VStack(alignment: .leading, spacing: 12) {
                                Text("HIZLI İŞLEMLER")
                                    .font(.system(size: 11, weight: .bold))
                                    .foregroundColor(AppTheme.textSecondary)
                                    .tracking(0.5)
                                
                                HStack(spacing: 8) {
                                    QuickActionBox(title: "Alış Faturası", icon: "doc.text.fill", color: Color(hex: "FF9F0A")) {
                                        showAlisFaturaForm = true
                                    }
                                    QuickActionBox(title: "Satış Faturası", icon: "doc.text.fill", color: Color(hex: "30D158")) {
                                        showSatisFaturaForm = true
                                    }
                                    QuickActionBox(title: "Yeni Sipariş", icon: "bag.fill", color: Color(hex: "0A84FF")) {
                                        showSiparisForm = true
                                    }
                                    QuickActionBox(title: "Yeni Teklif", icon: "plus.circle.fill", color: Color(hex: "BF5AF2")) {
                                        showTeklifForm = true
                                    }
                                }
                            }
                        }
                        .padding(.horizontal)
                        
                        // HEDEF & GERÇEKLEŞME Performans Kartı
                        GlassCard(cornerRadius: 18, padding: 16) {
                            VStack(spacing: 14) {
                                HStack {
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text("HEDEF & GERÇEKLEŞME")
                                            .font(.system(size: 12, weight: .bold))
                                            .foregroundColor(AppTheme.textPrimary)
                                        Text(isWeekly ? "Son 5 Haftalık Performans" : "12 Aylık Performans")
                                            .font(.system(size: 10))
                                            .foregroundColor(AppTheme.textMuted)
                                    }
                                    
                                    Spacer()
                                    
                                    HStack(spacing: 2) {
                                        Button {
                                            isWeekly = true
                                        } label: {
                                            Text("Hafta")
                                                .font(.system(size: 11, weight: isWeekly ? .bold : .medium))
                                                .foregroundColor(isWeekly ? .white : AppTheme.textSecondary)
                                                .padding(.horizontal, 10)
                                                .padding(.vertical, 4)
                                                .background(isWeekly ? AppTheme.primary : Color.clear)
                                                .cornerRadius(6)
                                        }
                                        
                                        Button {
                                            isWeekly = false
                                        } label: {
                                            Text("Ay")
                                                .font(.system(size: 11, weight: !isWeekly ? .bold : .medium))
                                                .foregroundColor(!isWeekly ? .white : AppTheme.textSecondary)
                                                .padding(.horizontal, 10)
                                                .padding(.vertical, 4)
                                                .background(!isWeekly ? AppTheme.primary : Color.clear)
                                                .cornerRadius(6)
                                        }
                                    }
                                    .padding(2)
                                    .background(AppTheme.cardSecondary)
                                    .cornerRadius(8)
                                }
                                
                                // Apple Dairesel Progress + 3 Mini İstatistik
                                HStack(spacing: 16) {
                                    // Dairesel Progress Ring
                                    ZStack {
                                        Circle()
                                            .stroke(AppTheme.border, lineWidth: 8)
                                            .frame(width: 80, height: 80)
                                        Circle()
                                            .trim(from: 0, to: CGFloat(completionRate) / 100.0)
                                            .stroke(
                                                LinearGradient(colors: [Color(hex: "00FF87"), Color(hex: "10B981")], startPoint: .topLeading, endPoint: .bottomTrailing),
                                                style: StrokeStyle(lineWidth: 8, lineCap: .round)
                                            )
                                            .rotationEffect(.degrees(-90))
                                            .frame(width: 80, height: 80)
                                        
                                        VStack(spacing: 0) {
                                            Text("%\(completionRate)")
                                                .font(.system(size: 16, weight: .heavy))
                                                .foregroundColor(AppTheme.textPrimary)
                                            Text("BAŞARILI")
                                                .font(.system(size: 8, weight: .bold))
                                                .foregroundColor(Color(hex: "00FF87"))
                                        }
                                    }
                                    
                                    // 3 Mini Rozet
                                    VStack(spacing: 6) {
                                        MiniStatBadge(title: "🎯 Haftalık Hedef", val: AppFormatters.money(toplamHedef), color: Color(hex: "6366F1"))
                                        MiniStatBadge(title: "🚀 Gerçekleşen", val: AppFormatters.money(toplamGerceklesen), color: Color(hex: "00FF87"))
                                        let fark = toplamGerceklesen - toplamHedef
                                        MiniStatBadge(title: "⚖️ Fark", val: (fark >= 0 ? "+" : "") + AppFormatters.money(fark), color: fark >= 0 ? Color(hex: "00FF87") : Color(hex: "EF4444"))
                                    }
                                }
                                
                                Divider().background(AppTheme.border)
                                
                                // Çift Kolon Bar Grafiği
                                HStack(alignment: .bottom, spacing: 14) {
                                    ForEach(goalData) { g in
                                        VStack(spacing: 4) {
                                            HStack(alignment: .bottom, spacing: 3) {
                                                // Hedef Barı (Mor)
                                                RoundedRectangle(cornerRadius: 3)
                                                    .fill(Color(hex: "6366F1"))
                                                    .frame(width: 10, height: CGFloat(min(80, (g.target / 80000) * 80)))
                                                // Gerçekleşen Barı (Neon Yeşil)
                                                RoundedRectangle(cornerRadius: 3)
                                                    .fill(Color(hex: "00FF87"))
                                                    .frame(width: 10, height: CGFloat(min(80, (g.actual / 80000) * 80)))
                                            }
                                            Text(g.week)
                                                .font(.system(size: 9, weight: .medium))
                                                .foregroundColor(AppTheme.textMuted)
                                        }
                                    }
                                }
                                .frame(height: 100)
                            }
                        }
                        .padding(.horizontal)
                        
                        // Son İşlemler (3 Sekmeli Liste: Son İşlemler / Alacak Takibi / Borç Takibi)
                        GlassCard(cornerRadius: 18, padding: 16) {
                            VStack(spacing: 12) {
                                HStack(spacing: 6) {
                                    TabFilterButton(title: "Son İşlemler", isSelected: activeTab == "recents") {
                                        activeTab = "recents"
                                    }
                                    TabFilterButton(title: "Alacak Takibi", isSelected: activeTab == "alacak") {
                                        activeTab = "alacak"
                                    }
                                    TabFilterButton(title: "Borç Takibi", isSelected: activeTab == "borc") {
                                        activeTab = "borc"
                                    }
                                }
                                
                                VStack(spacing: 10) {
                                    if currentListData.isEmpty {
                                        Text("Kayıt bulunamadı.")
                                            .font(.system(size: 12))
                                            .foregroundColor(AppTheme.textMuted)
                                            .padding(.vertical, 20)
                                    } else {
                                        ForEach(currentListData) { item in
                                            HStack(spacing: 12) {
                                                ZStack {
                                                    RoundedRectangle(cornerRadius: 10)
                                                        .fill((item.type == "In" ? Color(hex: "00FF87") : Color(hex: "FF416C")).opacity(0.15))
                                                        .frame(width: 36, height: 36)
                                                    Text(item.type == "In" ? "G" : "Ç")
                                                        .font(.system(size: 14, weight: .bold))
                                                        .foregroundColor(item.type == "In" ? Color(hex: "00FF87") : Color(hex: "FF416C"))
                                                }
                                                
                                                VStack(alignment: .leading, spacing: 3) {
                                                    Text(item.title)
                                                        .font(.system(size: 13, weight: .bold))
                                                        .foregroundColor(AppTheme.textPrimary)
                                                        .lineLimit(1)
                                                    
                                                    HStack(spacing: 4) {
                                                        Text(item.description)
                                                        Text("•")
                                                        Text(item.date)
                                                        if let vg = item.vadeGun {
                                                            Text("•")
                                                            Text("\(vg) G")
                                                        }
                                                    }
                                                    .font(.system(size: 11))
                                                    .foregroundColor(AppTheme.textMuted)
                                                }
                                                
                                                Spacer()
                                                
                                                Text((item.type == "In" ? "+" : "-") + AppFormatters.money(item.amount))
                                                    .font(.system(size: 13, weight: .heavy))
                                                    .foregroundColor(item.type == "In" ? Color(hex: "00FF87") : Color(hex: "FF416C"))
                                            }
                                            .padding(.vertical, 4)
                                            
                                            if item.id != currentListData.last?.id {
                                                Divider().background(AppTheme.border.opacity(0.6))
                                            }
                                        }
                                    }
                                }
                            }
                        }
                        .padding(.horizontal)
                        
                        Spacer().frame(height: 70)
                    }
                }
            }
            .navigationBarHidden(true)
            .sheet(isPresented: $showAlisFaturaForm) {
                FaturaFormView(initialTur: "ALIS")
            }
            .sheet(isPresented: $showSatisFaturaForm) {
                FaturaFormView(initialTur: "SATIS")
            }
            .sheet(isPresented: $showSiparisForm) {
                SiparisFormView()
            }
            .sheet(isPresented: $showTeklifForm) {
                TeklifFormView()
            }
            .task {
                await loadDashboardData()
            }
        }
    }
    
    private func loadDashboardData() async {
        isLoading = true
        do {
            let cariler: [CariKart] = try await SupabaseService.shared.fetch(from: "cariler")
            let faturalar: [Fatura] = (try? await SupabaseService.shared.fetch(from: "faturalar")) ?? []
            
            let alacak = cariler.filter { $0.bakiyeTuru == "A" }.reduce(0.0) { $0 + $1.bakiye }
            let borc = cariler.filter { $0.bakiyeTuru == "B" }.reduce(0.0) { $0 + $1.bakiye }
            
            await MainActor.run {
                self.carilerList = cariler
                self.faturalarList = faturalar
                if alacak > 0 { self.alacaklar = alacak }
                if borc > 0 { self.borclar = borc }
            }
        } catch {
            print("Dashboard fetch error: \(error.localizedDescription)")
        }
        isLoading = false
    }
}

struct DashboardMetricCard: View {
    let title: String
    let value: String
    let subtitle: String
    let icon: String
    let color: Color
    
    var body: some View {
        GlassCard(cornerRadius: 16, padding: 14) {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text(title)
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(AppTheme.textSecondary)
                    Spacer()
                    Image(systemName: icon)
                        .foregroundColor(color)
                }
                Text(value)
                    .font(.system(size: 16, weight: .heavy))
                    .foregroundColor(AppTheme.textPrimary)
                Text(subtitle)
                    .font(.system(size: 10))
                    .foregroundColor(AppTheme.textMuted)
            }
        }
    }
}

struct QuickActionBox: View {
    let title: String
    let icon: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 6) {
                ZStack {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(color.opacity(0.15))
                        .frame(width: 44, height: 44)
                    Image(systemName: icon)
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(color)
                }
                Text(title)
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundColor(AppTheme.textPrimary)
                    .lineLimit(1)
            }
            .frame(maxWidth: .infinity)
        }
    }
}

struct MiniStatBadge: View {
    let title: String
    let val: String
    let color: Color
    
    var body: some View {
        HStack {
            Text(title)
                .font(.system(size: 10))
                .foregroundColor(AppTheme.textSecondary)
            Spacer()
            Text(val)
                .font(.system(size: 11, weight: .bold))
                .foregroundColor(color)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 4)
        .background(AppTheme.cardSecondary)
        .cornerRadius(6)
        .overlay(
            Rectangle()
                .fill(color)
                .frame(width: 3),
            alignment: .leading
        )
    }
}

struct TabFilterButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 11, weight: isSelected ? .bold : .medium))
                .foregroundColor(isSelected ? .white : AppTheme.textSecondary)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 6)
                .background(isSelected ? AppTheme.primary : Color.clear)
                .cornerRadius(8)
        }
    }
}
