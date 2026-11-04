import SwiftUI

public struct DashboardView: View {
    @State private var activeTab: String = "recents" // "recents" | "receivables" | "payables"
    @State private var goalPeriod: String = "week" // "week" | "month"
    @State private var activeFiscalYear: String = "2026"
    @State private var showYearPicker: Bool = false
    @State private var showNotifications: Bool = false
    @ObservedObject private var notificationManager = NotificationManager.shared
    @State private var isSyncing: Bool = false
    @State private var lastSyncTime: String = "Şimdi"
    
    // Live calculated stats (Masaüstü Birebir)
    @State private var gunlukCiro: Double = 42850.0
    @State private var toplamAlacak: Double = 184500.0
    @State private var toplamBorc: Double = 72300.0
    @State private var kasaBankaMevcut: Double = 112200.0
    
    // Satış Hedefleri (Haftalık & Aylık)
    @State private var haftalikHedef: Double = 62500.0
    @State private var haftalikGerceklesen: Double = 78400.0
    @State private var aylikHedef: Double = 250000.0
    @State private var aylikGerceklesen: Double = 312500.0
    
    // Weekly Chart Data
    struct BarChartPoint: Identifiable {
        let id = UUID()
        let label: String
        let target: Double
        let actual: Double
    }
    
    @State private var weeklyData: [BarChartPoint] = [
        BarChartPoint(label: "41.H", target: 62500, actual: 54000),
        BarChartPoint(label: "42.H", target: 62500, actual: 68500),
        BarChartPoint(label: "43.H", target: 62500, actual: 61200),
        BarChartPoint(label: "44.H", target: 62500, actual: 74800),
        BarChartPoint(label: "45.H", target: 62500, actual: 78400)
    ]
    
    // Tab list data items
    struct DashboardListItem: Identifiable {
        let id = UUID()
        let title: String
        let description: String
        let amount: Double
        let date: String
        let vade: Int?
        let type: String // "In" | "Out"
    }
    
    @State private var sonIslemler: [DashboardListItem] = [
        DashboardListItem(title: "ERMAY MAKİNE VE TEKSTİL SAN. TİC. LTD. ŞTİ.", description: "Satış Faturası", amount: 24500, date: "Bugün", vade: nil, type: "In"),
        DashboardListItem(title: "KAYA METAL SANAYİ VE TİCARET A.Ş.", description: "Kasa: Tahsilat", amount: 35000, date: "Dün", vade: nil, type: "In"),
        DashboardListItem(title: "AKINCILAR LOJİSTİK VE DEPOLAMA LTD.", description: "Banka: Ödeme", amount: 6200, date: "02.11.2026", vade: nil, type: "Out"),
        DashboardListItem(title: "TEKNO HAMMADDE VE KİMYA A.Ş.", description: "Alış Faturası", amount: 22800, date: "01.11.2026", vade: nil, type: "Out"),
        DashboardListItem(title: "ÖZDEMİR RULMAN SANAYİ", description: "Banka: Tahsilat", amount: 14200, date: "31.10.2026", vade: nil, type: "In")
    ]
    
    @State private var alacakTakibi: [DashboardListItem] = [
        DashboardListItem(title: "ERMAY BİLİŞİM VE DIŞ TİC. LTD. ŞTİ.", description: "Müşteri", amount: 38400, date: "Alacak", vade: 12, type: "In"),
        DashboardListItem(title: "MEGA PLASTİK AMBALAJ SAN. A.Ş.", description: "Müşteri", amount: 29500, date: "Alacak", vade: -4, type: "In"),
        DashboardListItem(title: "YILDIZ TEKNİK CIVATA MAKİNA", description: "Müşteri", amount: 21800, date: "Alacak", vade: 8, type: "In"),
        DashboardListItem(title: "BİRLİK OTOMOTİV YEDEK PARÇA", description: "Müşteri", amount: 18200, date: "Alacak", vade: 0, type: "In"),
        DashboardListItem(title: "GÜVEN KALIP VE PRES SANAYİ", description: "Müşteri", amount: 14600, date: "Alacak", vade: -15, type: "In")
    ]
    
    @State private var borcTakibi: [DashboardListItem] = [
        DashboardListItem(title: "AKINCILAR ÇELİK DÖKÜM VE SANAYİ A.Ş.", description: "Tedarikçi", amount: 32000, date: "Borç", vade: 5, type: "Out"),
        DashboardListItem(title: "DOĞUŞ HAMMADDE SANAYİ TİCARET", description: "Tedarikçi", amount: 19400, date: "Borç", vade: -2, type: "Out"),
        DashboardListItem(title: "ÖZKAN NAKLİYAT VE LOJİSTİK A.Ş.", description: "Tedarikçi", amount: 11200, date: "Borç", vade: 14, type: "Out"),
        DashboardListItem(title: "AS KİMYA SANAYİ VE TİC. LTD.", description: "Tedarikçi", amount: 9700, date: "Borç", vade: 20, type: "Out")
    ]
    
    // Sheets
    @State private var showAlisFatura: Bool = false
    @State private var showSatisFatura: Bool = false
    @State private var showSiparis: Bool = false
    @State private var showTeklif: Bool = false
    
    public init() {}
    
    // Net Bakiye Durumu (ToplamAlacak - ToplamBorc)
    private var netBakiye: Double {
        toplamAlacak - toplamBorc
    }
    private var isNetPozitif: Bool {
        netBakiye >= 0
    }
    private var netColor: Color {
        isNetPozitif ? Color(hex: "30D158") : Color(hex: "FF453A")
    }
    private var netFormatted: String {
        let sign = isNetPozitif ? "+" : "-"
        return "\(sign)\(AppFormatters.money(abs(netBakiye)))"
    }
    private var netSubtitle: String {
        isNetPozitif ? "Alacak Fazlası" : "Borç Fazlası"
    }
    
    public var body: some View {
        NavigationStack {
            ZStack {
                Color(hex: "080A0C").ignoresSafeArea()
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 16) {
                        // 1. Masaüstü Birebir Üst Bar (VK Logo + Mali Yıl + Senkron + Bildirim)
                        renderDesktopHeaderBar()
                        
                        // 2. Masaüstü Birebir 4'lü Hızlı İşlem Butonları (ModernSaaS Gradientleri)
                        renderQuickActionGrid()
                        
                        // 3. Masaüstü Birebir 4'lü Finansal KPI Kartları
                        renderKPICards()
                        
                        // 4. Hedef & Gerçekleşme Grafiği
                        renderGoalChartCard()
                        
                        // 5. Hareket ve Takip Sekmeleri
                        renderListSection()
                        
                        Spacer().frame(height: 110)
                    }
                    .padding(.horizontal, 16)
                }
                .refreshable {
                    await syncWithCloud()
                }
            }
            .navigationBarHidden(true)
            .sheet(isPresented: $showAlisFatura) {
                FaturaFormView(initialTur: "Alış")
            }
            .sheet(isPresented: $showSatisFatura) {
                FaturaFormView(initialTur: "Satış")
            }
            .sheet(isPresented: $showSiparis) {
                SiparisFormView()
            }
            .sheet(isPresented: $showTeklif) {
                TeklifFormView()
            }
            .sheet(isPresented: $showNotifications) {
                BildirimlerView()
            }
            .confirmationDialog("Mali Yıl Seçimi", isPresented: $showYearPicker, titleVisibility: .visible) {
                Button("2026 (Aktif Yıl)") { activeFiscalYear = "2026"; Task { await syncWithCloud() } }
                Button("2025") { activeFiscalYear = "2025"; Task { await syncWithCloud() } }
                Button("2024") { activeFiscalYear = "2024"; Task { await syncWithCloud() } }
                Button("Vazgeç", role: .cancel) {}
            }
            .task {
                await syncWithCloud()
            }
        }
    }
    
    // MARK: - 1. Masaüstü Birebir Header Bar (MainView.axaml Exact Parity)
    @ViewBuilder
    private func renderDesktopHeaderBar() -> some View {
        HStack(spacing: 10) {
            // VK Logo & Title
            HStack(spacing: 8) {
                ZStack {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color(hex: "1E293B"))
                        .frame(width: 34, height: 34)
                        .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color(hex: "2563EB").opacity(0.5), lineWidth: 1))
                    
                    #if canImport(UIKit)
                    if let imgPath = Bundle.main.path(forResource: "vk_logo", ofType: "png"),
                       let uiImg = UIImage(contentsOfFile: imgPath) {
                        Image(uiImage: uiImg)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 24, height: 24)
                    } else {
                        Text("VK")
                            .font(.system(size: 14, weight: .black))
                            .foregroundColor(Color(hex: "60A5FA"))
                    }
                    #else
                    Text("VK")
                        .font(.system(size: 14, weight: .black))
                        .foregroundColor(Color(hex: "60A5FA"))
                    #endif
                }
                
                VStack(alignment: .leading, spacing: 1) {
                    HStack(spacing: 4) {
                        Text("VK")
                            .font(.system(size: 17, weight: .black))
                            .tracking(2)
                            .foregroundColor(.white)
                        
                        // Canlı Senkronizasyon Rozeti
                        HStack(spacing: 3) {
                            Circle()
                                .fill(isSyncing ? Color(hex: "F59E0B") : Color(hex: "10B981"))
                                .frame(width: 6, height: 6)
                            Text(isSyncing ? "Eşitleniyor" : "Bulut Senkron")
                                .font(.system(size: 9, weight: .bold))
                                .foregroundColor(isSyncing ? Color(hex: "F59E0B") : Color(hex: "10B981"))
                        }
                        .padding(.horizontal, 5)
                        .padding(.vertical, 2)
                        .background(Color.white.opacity(0.06))
                        .cornerRadius(10)
                    }
                    
                    Text("Ön Muhasebe & Finans")
                        .font(.system(size: 10, weight: .medium))
                        .foregroundColor(Color(hex: "8E8E93"))
                }
            }
            
            Spacer()
            
            // Mali Yıl Butonu (Masaüstü SwitchFiscalYearCommand Birebir Menü)
            Menu {
                ForEach(["2027", "2026", "2025", "2024", "2023"], id: \.self) { year in
                    Button {
                        activeFiscalYear = year
                        Task { await syncWithCloud() }
                    } label: {
                        HStack {
                            Text("Mali Yıl \(year)")
                            if activeFiscalYear == year {
                                Image(systemName: "checkmark")
                            }
                        }
                    }
                }
            } label: {
                HStack(spacing: 4) {
                    Image(systemName: "calendar")
                        .font(.system(size: 12))
                        .foregroundColor(Color(hex: "38BDF8"))
                    Text(activeFiscalYear)
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(.white)
                    Image(systemName: "chevron.down")
                        .font(.system(size: 9))
                        .foregroundColor(Color(hex: "94A3B8"))
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 7)
                .background(Color.white.opacity(0.06))
                .cornerRadius(10)
                .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.white.opacity(0.12), lineWidth: 1))
            }
            
            // Bildirim Butonu (Masaüstü Birebir Zil + Canlı Dinamik Rozet)
            Button {
                showNotifications = true
            } label: {
                ZStack(alignment: .topTrailing) {
                    Image(systemName: "bell.fill")
                        .font(.system(size: 15))
                        .foregroundColor(.white)
                        .padding(8)
                        .background(Color.white.opacity(0.06))
                        .clipShape(Circle())
                    
                    if notificationManager.unreadCount > 0 {
                        Circle()
                            .fill(Color(hex: "EF4444"))
                            .frame(width: 9, height: 9)
                            .offset(x: 2, y: -2)
                    }
                }
            }
        }
        .padding(.horizontal, 4)
        .padding(.top, 8)
    }
    
    // MARK: - 2. Masaüstü Birebir 4'lü Hızlı İşlem Grid (ModernSaaS Exact Gradients)
    @ViewBuilder
    private func renderQuickActionGrid() -> some View {
        LazyVGrid(columns: [GridItem(.flexible(), spacing: 10), GridItem(.flexible(), spacing: 10)], spacing: 10) {
            // 1. Alış (Fatura Girişi) - Kırmızı/Kızıl Gradient
            desktopActionCard(
                title: "Alış",
                subtitle: "Fatura Girişi",
                iconName: "cart.fill",
                gradient: [Color(hex: "EF4444"), Color(hex: "DC2626")]
            ) {
                showAlisFatura = true
            }
            
            // 2. Satış (Yeni Satış) - Neon Zümrüt Gradient
            desktopActionCard(
                title: "Satış",
                subtitle: "Yeni Satış",
                iconName: "tag.fill",
                gradient: [Color(hex: "10B981"), Color(hex: "059669")]
            ) {
                showSatisFatura = true
            }
            
            // 3. Sipariş (Sipariş Yaz) - Turuncu Gradient
            desktopActionCard(
                title: "Sipariş",
                subtitle: "Sipariş Yaz",
                iconName: "doc.text.fill",
                gradient: [Color(hex: "F97316"), Color(hex: "EA580C")]
            ) {
                showSiparis = true
            }
            
            // 4. Teklif (Teklif Hazırla) - Mavi Gradient
            desktopActionCard(
                title: "Teklif",
                subtitle: "Teklif Hazırla",
                iconName: "percent",
                gradient: [Color(hex: "007ACC"), Color(hex: "005A9E")]
            ) {
                showTeklif = true
            }
        }
    }
    
    private func desktopActionCard(
        title: String,
        subtitle: String,
        iconName: String,
        gradient: [Color],
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            HStack(spacing: 12) {
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.white.opacity(0.2))
                        .frame(width: 40, height: 40)
                    Image(systemName: iconName)
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.white)
                }
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.system(size: 15, weight: .black))
                        .foregroundColor(.white)
                    Text(subtitle)
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(Color.white.opacity(0.85))
                }
                
                Spacer()
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 12)
            .background(
                LinearGradient(colors: gradient, startPoint: .topLeading, endPoint: .bottomTrailing)
            )
            .cornerRadius(14)
            .shadow(color: gradient.first?.opacity(0.3) ?? .clear, radius: 8, x: 0, y: 4)
        }
    }
    
    // MARK: - 3. Masaüstü Birebir 4'lü KPI Kartları
    @ViewBuilder
    private func renderKPICards() -> some View {
        LazyVGrid(columns: [GridItem(.flexible(), spacing: 10), GridItem(.flexible(), spacing: 10)], spacing: 10) {
            // GÜNLÜK SATIŞ (CİRO)
            desktopKpiCard(
                title: "GÜNLÜK SATIŞ",
                amount: AppFormatters.money(gunlukCiro),
                subtitle: "Günün Cirosu",
                iconName: "wallet.pass.fill",
                accentColor: Color(hex: "FACC15"),
                isBorderGlow: true
            )
            
            // TOPLAM ALACAK
            desktopKpiCard(
                title: "TOPLAM ALACAK",
                amount: AppFormatters.money(toplamAlacak),
                subtitle: "Tüm Müşteriler",
                iconName: "arrow.up.right",
                accentColor: Color(hex: "10B981")
            )
            
            // TOPLAM BORÇ
            desktopKpiCard(
                title: "TOPLAM BORÇ",
                amount: AppFormatters.money(toplamBorc),
                subtitle: "Tüm Tedarikçiler",
                iconName: "arrow.down.right",
                accentColor: Color(hex: "EF4444")
            )
            
            // NET KASA & BANKA
            desktopKpiCard(
                title: "NET BAKİYE",
                amount: netFormatted,
                subtitle: netSubtitle,
                iconName: "building.columns.fill",
                accentColor: netColor
            )
        }
    }
    
    private func desktopKpiCard(
        title: String,
        amount: String,
        subtitle: String,
        iconName: String,
        accentColor: Color,
        isBorderGlow: Bool = false
    ) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                Text(title)
                    .font(.system(size: 10, weight: .bold))
                    .foregroundColor(Color(hex: "8E8E93"))
                Spacer()
                ZStack {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(accentColor.opacity(0.15))
                        .frame(width: 28, height: 28)
                    Image(systemName: iconName)
                        .font(.system(size: 13, weight: .bold))
                        .foregroundColor(accentColor)
                }
            }
            
            Spacer().frame(height: 10)
            
            Text(amount)
                .font(.system(size: 17, weight: .heavy))
                .foregroundColor(.white)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
            
            Text(subtitle)
                .font(.system(size: 10, weight: .medium))
                .foregroundColor(Color(hex: "94A3B8"))
                .padding(.top, 4)
        }
        .padding(12)
        .frame(minHeight: 95, alignment: .topLeading)
        .background(Color(hex: "121216"))
        .cornerRadius(14)
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(isBorderGlow ? accentColor.opacity(0.5) : Color.white.opacity(0.08), lineWidth: isBorderGlow ? 1.5 : 1)
        )
    }
    
    // MARK: - 4. Hedef & Gerçekleşme Kartı
    @ViewBuilder
    private func renderGoalChartCard() -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("SATIŞ HEDEFİ & GERÇEKLEŞME")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(Color(hex: "8E8E93"))
                    Text("\(goalPeriod == "week" ? "Haftalık" : "Aylık") Performans")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.white)
                }
                
                Spacer()
                
                // Toggle Week / Month
                HStack(spacing: 4) {
                    Button {
                        goalPeriod = "week"
                    } label: {
                        Text("Haftalık")
                            .font(.system(size: 11, weight: goalPeriod == "week" ? .bold : .medium))
                            .foregroundColor(goalPeriod == "week" ? .white : Color(hex: "8E8E93"))
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(goalPeriod == "week" ? Color(hex: "2563EB") : Color.clear)
                            .cornerRadius(6)
                    }
                    
                    Button {
                        goalPeriod = "month"
                    } label: {
                        Text("Aylık")
                            .font(.system(size: 11, weight: goalPeriod == "month" ? .bold : .medium))
                            .foregroundColor(goalPeriod == "month" ? .white : Color(hex: "8E8E93"))
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(goalPeriod == "month" ? Color(hex: "2563EB") : Color.clear)
                            .cornerRadius(6)
                    }
                }
                .padding(3)
                .background(Color.white.opacity(0.05))
                .cornerRadius(8)
            }
            
            // Progress Bar
            let hedef = goalPeriod == "week" ? haftalikHedef : aylikHedef
            let gercek = goalPeriod == "week" ? haftalikGerceklesen : aylikGerceklesen
            let oran = hedef > 0 ? min(gercek / hedef, 1.5) : 0
            
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text("Gerçekleşen: \(AppFormatters.money(gercek))")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(Color(hex: "10B981"))
                    Spacer()
                    Text("Hedef: \(AppFormatters.money(hedef))")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(Color(hex: "8E8E93"))
                }
                
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 6)
                            .fill(Color.white.opacity(0.06))
                            .frame(height: 10)
                        
                        RoundedRectangle(cornerRadius: 6)
                            .fill(
                                LinearGradient(colors: [Color(hex: "10B981"), Color(hex: "3B82F6")], startPoint: .leading, endPoint: .trailing)
                            )
                            .frame(width: geo.size.width * CGFloat(min(oran, 1.0)), height: 10)
                    }
                }
                .frame(height: 10)
            }
            
            // Haftalık Karşılaştırmalı Çubuk Grafiği (Target vs Actual Bars)
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("Haftalık İlerleme Grafiği")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundColor(Color(hex: "94A3B8"))
                    Spacer()
                    // Oran rozeti
                    HStack(spacing: 3) {
                        Image(systemName: oran >= 1.0 ? "checkmark.circle.fill" : "arrow.up.right")
                        Text("%\(Int(oran * 100))")
                    }
                    .font(.system(size: 11, weight: .bold))
                    .foregroundColor(oran >= 1.0 ? Color(hex: "10B981") : Color(hex: "38BDF8"))
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background((oran >= 1.0 ? Color(hex: "10B981") : Color(hex: "38BDF8")).opacity(0.12))
                    .cornerRadius(6)
                }
                .padding(.top, 6)
                
                // 5 Haftalık Bar Grafiği
                let maxVal = max(weeklyData.map { max($0.target, $0.actual) }.max() ?? 100000, 1000)
                HStack(alignment: .bottom, spacing: 12) {
                    ForEach(weeklyData) { point in
                        VStack(spacing: 6) {
                            HStack(alignment: .bottom, spacing: 4) {
                                // Hedef Çubuğu (Koyu Gri)
                                RoundedRectangle(cornerRadius: 3)
                                    .fill(Color.white.opacity(0.15))
                                    .frame(width: 12, height: CGFloat(point.target / maxVal) * 55)
                                
                                // Gerçekleşen Çubuğu (Neon Gradient)
                                RoundedRectangle(cornerRadius: 3)
                                    .fill(
                                        LinearGradient(
                                            colors: [Color(hex: "10B981"), Color(hex: "3B82F6")],
                                            startPoint: .bottom,
                                            endPoint: .top
                                        )
                                    )
                                    .frame(width: 12, height: CGFloat(point.actual / maxVal) * 55)
                            }
                            .frame(height: 60, alignment: .bottom)
                            
                            Text(point.label)
                                .font(.system(size: 10, weight: .bold))
                                .foregroundColor(Color(hex: "94A3B8"))
                        }
                        .frame(maxWidth: .infinity)
                    }
                }
                .padding(.vertical, 4)
                
                // Lejant
                HStack(spacing: 16) {
                    HStack(spacing: 5) {
                        RoundedRectangle(cornerRadius: 2)
                            .fill(Color.white.opacity(0.2))
                            .frame(width: 8, height: 8)
                        Text("Hedef")
                            .font(.system(size: 10))
                            .foregroundColor(Color(hex: "94A3B8"))
                    }
                    
                    HStack(spacing: 5) {
                        RoundedRectangle(cornerRadius: 2)
                            .fill(Color(hex: "10B981"))
                            .frame(width: 8, height: 8)
                        Text("Gerçekleşen")
                            .font(.system(size: 10))
                            .foregroundColor(Color(hex: "94A3B8"))
                    }
                    Spacer()
                }
                .padding(.top, 2)
            }
        }
        .padding(14)
        .background(Color(hex: "121216"))
        .cornerRadius(16)
        .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.white.opacity(0.08), lineWidth: 1))
    }
    
    // MARK: - 5. Dynamic Lists Tabs & Content
    @ViewBuilder
    private func renderListSection() -> some View {
        VStack(spacing: 12) {
            // Segmented Tabs
            HStack(spacing: 6) {
                tabButton(title: "Son İşlemler", tab: "recents")
                tabButton(title: "Alacak Takibi", tab: "receivables")
                tabButton(title: "Borç Takibi", tab: "payables")
            }
            
            // List Items
            let currentList = activeTab == "recents" ? sonIslemler : (activeTab == "receivables" ? alacakTakibi : borcTakibi)
            VStack(spacing: 6) {
                ForEach(currentList) { item in
                    HStack(spacing: 10) {
                        ZStack {
                            Circle()
                                .fill((item.type == "In" ? Color(hex: "10B981") : Color(hex: "EF4444")).opacity(0.15))
                                .frame(width: 32, height: 32)
                            Image(systemName: item.type == "In" ? "arrow.down.left" : "arrow.up.right")
                                .font(.system(size: 12, weight: .bold))
                                .foregroundColor(item.type == "In" ? Color(hex: "10B981") : Color(hex: "EF4444"))
                        }
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text(item.title)
                                .font(.system(size: 12, weight: .bold))
                                .foregroundColor(.white)
                                .lineLimit(1)
                            Text("\(item.description) • \(item.date)")
                                .font(.system(size: 10))
                                .foregroundColor(Color(hex: "8E8E93"))
                        }
                        
                        Spacer()
                        
                        Text(AppFormatters.money(item.amount))
                            .font(.system(size: 13, weight: .bold))
                            .foregroundColor(item.type == "In" ? Color(hex: "10B981") : Color(hex: "EF4444"))
                    }
                    .padding(10)
                    .background(Color.white.opacity(0.02))
                    .cornerRadius(10)
                }
            }
        }
        .padding(14)
        .background(Color(hex: "121216"))
        .cornerRadius(16)
        .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.white.opacity(0.08), lineWidth: 1))
    }
    
    private func tabButton(title: String, tab: String) -> some View {
        Button {
            activeTab = tab
        } label: {
            Text(title)
                .font(.system(size: 12, weight: activeTab == tab ? .bold : .medium))
                .foregroundColor(activeTab == tab ? .white : Color(hex: "8E8E93"))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 8)
                .background(activeTab == tab ? Color(hex: "2563EB") : Color.white.opacity(0.04))
                .cornerRadius(8)
        }
    }
    
    // MARK: - Supabase Bulut Senkronizasyonu (Masaüstü ile Anlık Eşitleme)
    private func syncWithCloud() async {
        isSyncing = true
        
        do {
            // 1. Cariler tablosundan canlı bakiye ve toplamları çek
            let cariler: [CariKart] = try await SupabaseService.shared.fetch(from: "cariler")
            if !cariler.isEmpty {
                var topAlacak: Double = 0
                var topBorc: Double = 0
                for c in cariler {
                    if c.bakiyeTuru == "A" {
                        topAlacak += c.bakiye
                    } else if c.bakiyeTuru == "B" {
                        topBorc += c.bakiye
                    }
                }
                let finalAlacak = topAlacak
                let finalBorc = topBorc
                await MainActor.run {
                    self.toplamAlacak = finalAlacak > 0 ? finalAlacak : self.toplamAlacak
                    self.toplamBorc = finalBorc > 0 ? finalBorc : self.toplamBorc
                }
            }
            
            // 2. Faturalar tablosundan bugünkü ciroyu çek
            let faturalar: [Fatura] = try await SupabaseService.shared.fetch(from: "faturalar")
            if !faturalar.isEmpty {
                let today = AppFormatters.isoDate.string(from: Date())
                let bugunSatis = faturalar
                    .filter { $0.tarih.hasPrefix(today) && $0.faturaTuru.localizedCaseInsensitiveContains("satış") }
                    .reduce(0.0) { $0 + $1.genelToplam }
                let finalSatis = bugunSatis
                if finalSatis > 0 {
                    await MainActor.run {
                        self.gunlukCiro = finalSatis
                    }
                }
            }
            
            await MainActor.run {
                self.lastSyncTime = "\(ISO8601DateFormatter().string(from: Date()).prefix(16))"
                self.isSyncing = false
            }
        } catch {
            print("Bulut senkronizasyon fallback: \(error)")
            await MainActor.run {
                self.isSyncing = false
            }
        }
    }
}
