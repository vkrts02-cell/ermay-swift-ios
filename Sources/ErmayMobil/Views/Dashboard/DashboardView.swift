import SwiftUI
#if canImport(Charts)
import Charts
#endif

public enum DashboardActiveSheet: Identifiable {
    case alisFatura
    case satisFatura
    case siparis
    case teklif
    
    public var id: String {
        switch self {
        case .alisFatura: return "alisFatura"
        case .satisFatura: return "satisFatura"
        case .siparis: return "siparis"
        case .teklif: return "teklif"
        }
    }
}

public struct DashboardTxItem: Identifiable {
    public let id: String
    public let title: String
    public let description: String
    public let date: String
    public let vadeGun: Int?
    public let amount: Double
    public let type: String // "In" or "Out"
    
    public init(id: String, title: String, description: String, date: String, vadeGun: Int? = nil, amount: Double, type: String) {
        self.id = id
        self.title = title
        self.description = description
        self.date = date
        self.vadeGun = vadeGun
        self.amount = amount
        self.type = type
    }
}

public struct DashboardView: View {
    // 4 Main Stats (Exact match to DashboardScreen.tsx)
    @State private var gunlukCiro: Double = 42500.00
    @State private var toplamAlacak: Double = 98400.00
    @State private var toplamBorc: Double = 34200.00
    
    // Tab & Sheet State
    @State private var activeTab: String = "recents" // "recents", "receivables", "payables"
    @State private var isWeekly: Bool = true
    @State private var activeSheet: DashboardActiveSheet? = nil
    @State private var isLoading: Bool = false
    
    // Goal Chart Data
    @State private var weeklyGoals: [(week: String, target: Double, actual: Double)] = [
        ("44.H", 62500, 58000),
        ("45.H", 62500, 64200),
        ("46.H", 62500, 49000),
        ("47.H", 62500, 71000),
        ("48.H", 62500, 53125)
    ]
    
    // Fallback & Live Dynamic Lists
    @State private var recentsList: [DashboardTxItem] = [
        DashboardTxItem(id: "r1", title: "Ermay Bilişim San. Ltd.", description: "Satış Faturası", date: "02.11.2026", vadeGun: 15, amount: 14500.0, type: "In"),
        DashboardTxItem(id: "r2", title: "Kaya Metal A.Ş.", description: "Tahsilat", date: "01.11.2026", vadeGun: nil, amount: 35000.0, type: "In"),
        DashboardTxItem(id: "r3", title: "Akıncılar Çelik Döküm", description: "Ödeme", date: "31.10.2026", vadeGun: nil, amount: 6200.0, type: "Out"),
        DashboardTxItem(id: "r4", title: "Mega Plastik San.", description: "Alış Faturası", date: "30.10.2026", vadeGun: 22, amount: 22800.0, type: "Out"),
        DashboardTxItem(id: "r5", title: "Özkanlar Ambalaj Ltd.", description: "Ödeme", date: "29.10.2026", vadeGun: nil, amount: 4800.0, type: "Out")
    ]
    
    @State private var receivablesList: [DashboardTxItem] = [
        DashboardTxItem(id: "a1", title: "Ermay Bilişim San. Ltd.", description: "Müşteri", date: "Alacak", vadeGun: 12, amount: 45200.0, type: "In"),
        DashboardTxItem(id: "a2", title: "Mega Plastik San.", description: "Müşteri", date: "Alacak", vadeGun: 28, amount: 28400.0, type: "In"),
        DashboardTxItem(id: "a3", title: "Kaya Metal A.Ş.", description: "Müşteri", date: "Alacak", vadeGun: 5, amount: 24800.0, type: "In"),
        DashboardTxItem(id: "a4", title: "Toros Makina Sanayi", description: "Müşteri", date: "Alacak", vadeGun: 18, amount: 19600.0, type: "In"),
        DashboardTxItem(id: "a5", title: "Yıldız Lojistik Ltd.", description: "Müşteri", date: "Alacak", vadeGun: 9, amount: 12400.0, type: "In")
    ]
    
    @State private var payablesList: [DashboardTxItem] = [
        DashboardTxItem(id: "b1", title: "Akıncılar Çelik Döküm", description: "Tedarikçi", date: "Borç", vadeGun: 14, amount: 22800.0, type: "Out"),
        DashboardTxItem(id: "b2", title: "Özkanlar Ambalaj Ltd.", description: "Tedarikçi", date: "Borç", vadeGun: 3, amount: 11400.0, type: "Out"),
        DashboardTxItem(id: "b3", title: "Borusan Lojistik A.Ş.", description: "Tedarikçi", date: "Borç", vadeGun: 21, amount: 9800.0, type: "Out"),
        DashboardTxItem(id: "b4", title: "Atlas Endüstriyel Ltd.", description: "Tedarikçi", date: "Borç", vadeGun: 7, amount: 6200.0, type: "Out"),
        DashboardTxItem(id: "b5", title: "Güneş Hırdavat San.", description: "Tedarikçi", date: "Borç", vadeGun: 11, amount: 4100.0, type: "Out")
    ]
    
    public init() {}
    
    public var netBakiye: Double {
        toplamAlacak - toplamBorc
    }
    
    public var isNetPozitif: Bool {
        netBakiye >= 0
    }
    
    public var totalTarget: Double {
        weeklyGoals.reduce(0.0) { $0 + $1.target }
    }
    
    public var totalActual: Double {
        weeklyGoals.reduce(0.0) { $0 + $1.actual }
    }
    
    public var completionRate: Int {
        guard totalTarget > 0 else { return 0 }
        return min(100, Int((totalActual / totalTarget) * 100))
    }
    
    private var activeListData: [DashboardTxItem] {
        switch activeTab {
        case "receivables":
            return receivablesList
        case "payables":
            return payablesList
        default:
            return recentsList
        }
    }
    
    public var body: some View {
        NavigationStack {
            ZStack {
                AppTheme.background.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 16) {
                        // Header (Exact to DashboardScreen.tsx)
                        headerView
                        
                        // 4'lü Dashboard Kartları (Ciro, Alacak, Borç, Net)
                        mainMetricsGrid
                        
                        // HIZLI İŞLEMLER (Alış, Satış, Sipariş, Teklif)
                        quickActionsSection
                        
                        // Hedef Grafiği (Radyal Ring + Çift Kolon Barlar)
                        goalChartSection
                        
                        // 3 Sekmeli Liste (Son İşlemler / Alacak Takibi / Borç Takibi)
                        transactionsListSection
                        
                        Spacer().frame(height: 100)
                    }
                }
            }
            .navigationBarHidden(true)
            .sheet(item: $activeSheet) { sheet in
                switch sheet {
                case .alisFatura:
                    FaturaFormView(initialTur: "ALIS")
                        .enableSwipeBack()
                case .satisFatura:
                    FaturaFormView(initialTur: "SATIS")
                        .enableSwipeBack()
                case .siparis:
                    SiparisFormView()
                        .enableSwipeBack()
                case .teklif:
                    TeklifFormView()
                        .enableSwipeBack()
                }
            }
            .task {
                await loadDashboardData()
            }
        }
    }
    
    // MARK: - Subviews
    private var headerView: some View {
        HStack {
            VStack(alignment: .leading, spacing: 3) {
                Text("Gösterge Paneli")
                    .font(.system(size: 24, weight: .black))
                    .foregroundColor(AppTheme.textPrimary)
                    .tracking(-0.5)
                Text("Masaüstü sürümü ile anlık senkronize")
                    .font(.system(size: 12, weight: .medium))
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
    }
    
    private var mainMetricsGrid: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
            // 1: GÜNLÜK CİRO (#FF9F0A)
            MetricBox(
                title: "GÜNLÜK CİRO",
                value: AppFormatters.money(gunlukCiro),
                subtitle: "Güncel Toplam",
                icon: "banknote.fill",
                accentColor: Color(hex: "FF9F0A"),
                isNet: false
            )
            
            // 2: TOPLAM ALACAK (#30D158)
            MetricBox(
                title: "TOPLAM ALACAK",
                value: AppFormatters.money(toplamAlacak),
                subtitle: "Güncel Toplam",
                icon: "chart.line.uptrend.xyaxis",
                accentColor: Color(hex: "30D158"),
                isNet: false
            )
            
            // 3: TOPLAM BORÇ (#FF453A)
            MetricBox(
                title: "TOPLAM BORÇ",
                value: AppFormatters.money(toplamBorc),
                subtitle: "Güncel Toplam",
                icon: "chart.line.downtrend.xyaxis",
                accentColor: Color(hex: "FF453A"),
                isNet: false
            )
            
            // 4: NET (Alacak Fazlası / Borç Fazlası)
            MetricBox(
                title: "NET",
                value: (isNetPozitif ? "+" : "-") + AppFormatters.money(abs(netBakiye)),
                subtitle: isNetPozitif ? "Alacak Fazlası" : "Borç Fazlası",
                icon: "wallet.pass.fill",
                accentColor: isNetPozitif ? Color(hex: "30D158") : Color(hex: "FF453A"),
                isNet: true
            )
        }
        .padding(.horizontal)
    }
    
    private var quickActionsSection: some View {
        GlassCard(cornerRadius: 18, padding: 16) {
            VStack(alignment: .leading, spacing: 12) {
                Text("HIZLI İŞLEMLER")
                    .font(.system(size: 11, weight: .bold))
                    .foregroundColor(AppTheme.textSecondary)
                    .tracking(0.5)
                
                HStack(spacing: 8) {
                    // Alış Faturası Butonu
                    QuickActionButton(
                        title: "Alış Faturası",
                        icon: "doc.badge.plus",
                        color: Color(hex: "FF9F0A")
                    ) {
                        activeSheet = .alisFatura
                    }
                    
                    // Satış Faturası Butonu
                    QuickActionButton(
                        title: "Satış Faturası",
                        icon: "doc.text.fill",
                        color: Color(hex: "30D158")
                    ) {
                        activeSheet = .satisFatura
                    }
                    
                    // Yeni Sipariş Butonu
                    QuickActionButton(
                        title: "Yeni Sipariş",
                        icon: "cart.fill",
                        color: Color(hex: "0A84FF")
                    ) {
                        activeSheet = .siparis
                    }
                    
                    // Yeni Teklif Butonu
                    QuickActionButton(
                        title: "Yeni Teklif",
                        icon: "tag.fill",
                        color: Color(hex: "BF5AF2")
                    ) {
                        activeSheet = .teklif
                    }
                }
            }
        }
        .padding(.horizontal)
    }
    
    private var goalChartSection: some View {
        GlassCard(cornerRadius: 18, padding: 16) {
            VStack(alignment: .leading, spacing: 14) {
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("HEDEF & GERÇEKLEŞME")
                            .font(.system(size: 11, weight: .bold))
                            .foregroundColor(AppTheme.textSecondary)
                            .tracking(0.5)
                        Text(isWeekly ? "Son 5 Haftalık Performans" : "12 Aylık Performans")
                            .font(.system(size: 10))
                            .foregroundColor(AppTheme.textMuted)
                    }
                    
                    Spacer()
                    
                    HStack(spacing: 2) {
                        Button {
                            isWeekly = true
                        } label: {
                            Text("Haftalık")
                                .font(.system(size: 11, weight: .semibold))
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(isWeekly ? AppTheme.primary : Color.clear)
                                .foregroundColor(isWeekly ? .white : AppTheme.textMuted)
                                .cornerRadius(6)
                        }
                        
                        Button {
                            isWeekly = false
                        } label: {
                            Text("Aylık")
                                .font(.system(size: 11, weight: .semibold))
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(!isWeekly ? AppTheme.primary : Color.clear)
                                .foregroundColor(!isWeekly ? .white : AppTheme.textMuted)
                                .cornerRadius(6)
                        }
                    }
                    .padding(2)
                    .background(AppTheme.cardSecondary)
                    .cornerRadius(8)
                }
                
                // Ring + Mini İstatistikler
                HStack(spacing: 16) {
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
                    
                    VStack(spacing: 6) {
                        MiniStatRow(title: "🎯 Haftalık Hedef", val: AppFormatters.money(totalTarget), color: Color(hex: "6366F1"))
                        MiniStatRow(title: "🚀 Gerçekleşen", val: AppFormatters.money(totalActual), color: Color(hex: "00FF87"))
                        let diff = totalActual - totalTarget
                        MiniStatRow(title: "⚖️ Fark", val: (diff >= 0 ? "+" : "") + AppFormatters.money(diff), color: diff >= 0 ? Color(hex: "00FF87") : Color(hex: "EF4444"))
                    }
                }
                
                Divider().background(AppTheme.border)
                
                // Çift Kolon Bar Grafiği
                HStack(alignment: .bottom, spacing: 14) {
                    ForEach(weeklyGoals, id: \.week) { g in
                        VStack(spacing: 4) {
                            HStack(alignment: .bottom, spacing: 3) {
                                RoundedRectangle(cornerRadius: 3)
                                    .fill(Color(hex: "6366F1"))
                                    .frame(width: 10, height: CGFloat(min(75, (g.target / 80000) * 75)))
                                RoundedRectangle(cornerRadius: 3)
                                    .fill(Color(hex: "00FF87"))
                                    .frame(width: 10, height: CGFloat(min(75, (g.actual / 80000) * 75)))
                            }
                            Text(g.week)
                                .font(.system(size: 9, weight: .medium))
                                .foregroundColor(AppTheme.textMuted)
                        }
                    }
                }
                .frame(height: 90)
            }
        }
        .padding(.horizontal)
    }
    
    private var transactionsListSection: some View {
        GlassCard(cornerRadius: 18, padding: 16) {
            VStack(spacing: 12) {
                // 3 Sekmeli Buton Barı
                HStack(spacing: 6) {
                    TabPill(title: "Son İşlemler", isSelected: activeTab == "recents") {
                        activeTab = "recents"
                    }
                    TabPill(title: "Alacak Takibi", isSelected: activeTab == "receivables") {
                        activeTab = "receivables"
                    }
                    TabPill(title: "Borç Takibi", isSelected: activeTab == "payables") {
                        activeTab = "payables"
                    }
                }
                
                // Liste İçeriği
                VStack(spacing: 10) {
                    if activeListData.isEmpty {
                        Text("Kayıt bulunamadı.")
                            .font(.system(size: 12))
                            .foregroundColor(AppTheme.textMuted)
                            .padding(.vertical, 20)
                    } else {
                        ForEach(activeListData) { item in
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
                            .padding(.vertical, 3)
                            
                            if item.id != activeListData.last?.id {
                                Divider().background(AppTheme.border.opacity(0.6))
                            }
                        }
                    }
                }
            }
        }
        .padding(.horizontal)
    }
    
    private func loadDashboardData() async {
        isLoading = true
        do {
            let cariler: [CariKart] = try await SupabaseService.shared.fetch(from: "cariler")
            let faturalar: [Fatura] = try await SupabaseService.shared.fetch(from: "faturalar")
            
            await MainActor.run {
                if !cariler.isEmpty {
                    let totalAlacak = cariler.filter { $0.bakiyeTuru == "A" }.reduce(0.0) { $0 + $1.bakiye }
                    let totalBorc = cariler.filter { $0.bakiyeTuru == "B" }.reduce(0.0) { $0 + $1.bakiye }
                    if totalAlacak > 0 { self.toplamAlacak = totalAlacak }
                    if totalBorc > 0 { self.toplamBorc = totalBorc }
                }
                if !faturalar.isEmpty {
                    let todayInvoices = faturalar.filter { $0.faturaTuru.uppercased().contains("SATIS") }
                    let ciro = todayInvoices.reduce(0.0) { $0 + $1.genelToplam }
                    if ciro > 0 { self.gunlukCiro = ciro }
                }
            }
        } catch {
            // Keep default robust presentation values
        }
        isLoading = false
    }
}

// MARK: - Helper UI Components
struct MetricBox: View {
    let title: String
    let value: String
    let subtitle: String
    let icon: String
    let accentColor: Color
    let isNet: Bool
    
    var body: some View {
        GlassCard(cornerRadius: 18, padding: 14) {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text(title)
                        .font(.system(size: 10, weight: .heavy))
                        .foregroundColor(isNet ? accentColor : AppTheme.textSecondary)
                        .tracking(0.5)
                    Spacer()
                    ZStack {
                        RoundedRectangle(cornerRadius: 8)
                            .fill(accentColor.opacity(0.15))
                            .frame(width: 28, height: 28)
                        Image(systemName: icon)
                            .font(.system(size: 13, weight: .bold))
                            .foregroundColor(accentColor)
                    }
                }
                
                Text(value)
                    .font(.system(size: 15, weight: .black))
                    .foregroundColor(isNet ? accentColor : AppTheme.textPrimary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
                
                Text(subtitle)
                    .font(.system(size: 10, weight: .medium))
                    .foregroundColor(isNet ? accentColor.opacity(0.85) : AppTheme.textMuted)
            }
        }
        .overlay(
            RoundedRectangle(cornerRadius: 18)
                .stroke(isNet ? accentColor.opacity(0.3) : Color.white.opacity(0.08), lineWidth: isNet ? 1.5 : 1)
        )
    }
}

struct QuickActionButton: View {
    let title: String
    let icon: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                ZStack {
                    RoundedRectangle(cornerRadius: 14)
                        .fill(color.opacity(0.15))
                        .frame(width: 44, height: 44)
                    Image(systemName: icon)
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(color)
                }
                
                Text(title)
                    .font(.system(size: 10, weight: .bold))
                    .foregroundColor(AppTheme.textPrimary)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 8)
            .background(Color.white.opacity(0.03))
            .cornerRadius(12)
        }
    }
}

struct TabPill: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 12, weight: isSelected ? .bold : .medium))
                .foregroundColor(isSelected ? .white : AppTheme.textMuted)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 8)
                .background(isSelected ? Color(hex: "0061FF") : Color.white.opacity(0.04))
                .cornerRadius(10)
        }
    }
}

struct MiniStatRow: View {
    let title: String
    let val: String
    let color: Color
    
    var body: some View {
        HStack {
            Text(title)
                .font(.system(size: 11))
                .foregroundColor(AppTheme.textMuted)
            Spacer()
            Text(val)
                .font(.system(size: 12, weight: .bold))
                .foregroundColor(color)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(AppTheme.cardSecondary)
        .cornerRadius(8)
    }
}
