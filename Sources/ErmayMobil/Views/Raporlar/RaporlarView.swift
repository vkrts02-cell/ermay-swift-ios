import SwiftUI

public struct ReportItemInfo: Identifiable, Hashable {
    public let id = UUID()
    public let title: String
    public let category: String
    public let description: String
    public let iconName: String
}

public struct RaporlarView: View {
    @State private var searchQuery: String = ""
    @State private var selectedFilter: String = "All" // "All" | "Weekly" | "Monthly" | "Yearly"
    @State private var selectedReport: ReportItemInfo? = nil
    
    // 24 Standard Reports (Exact to RaporlarScreen.tsx)
    private let allReports: [ReportItemInfo] = [
        // 1. Genel Durum
        ReportItemInfo(title: "Genel Özet", category: "Genel Durum", description: "İşletmenin genel mali özetini ve net pozisyonunu gösterir.", iconName: "chart.bar.doc.horizontal.fill"),
        
        // 2. Finans
        ReportItemInfo(title: "Aylık Tahsilat ve Ödeme Analizi", category: "Finans", description: "Ay bazlı ödeme türlerine göre tahsilat ve yönlendirme özeti.", iconName: "calendar.badge.clock"),
        ReportItemInfo(title: "Kredi Kartı Detay Raporu", category: "Finans", description: "Kaydedilen ve yönlendirilen kredi kartı işlem detayları.", iconName: "creditcard.fill"),
        ReportItemInfo(title: "Nakit İşlem Detay Raporu", category: "Finans", description: "Tüm nakit kasa hareketlerinin detaylı dökümü.", iconName: "banknote.fill"),
        ReportItemInfo(title: "Çek Detay Raporu", category: "Finans", description: "Portföydeki ve işlem görmüş çeklerin detayları.", iconName: "doc.plaintext.fill"),
        ReportItemInfo(title: "Havale / EFT Detay Raporu", category: "Finans", description: "Banka havale ve EFT işlemlerinin detaylı listesi.", iconName: "building.columns.fill"),
        
        // 3. Cari Hesap
        ReportItemInfo(title: "Cari Bakiye Raporu", category: "Cari Hesap", description: "Müşteri ve tedarikçi bakiyeleri ve durumları.", iconName: "person.2.fill"),
        ReportItemInfo(title: "Cari Hareket Dökümü", category: "Cari Hesap", description: "Cari hesapların fatura ve tahsilat işlem detayları.", iconName: "list.bullet.rectangle.portrait.fill"),
        ReportItemInfo(title: "Yaşlandırma Raporu", category: "Cari Hesap", description: "Vadesi geçen ve yaklaşan borç/alacak yaşlandırma analizi.", iconName: "hourglass"),
        ReportItemInfo(title: "Hareketsiz Cariler", category: "Cari Hesap", description: "Belirli süredir işlem görmeyen cari hesaplar.", iconName: "person.crop.circle.badge.minus"),
        
        // 4. Stok
        ReportItemInfo(title: "Stok Mevcudu", category: "Stok", description: "Depodaki güncel stok miktarları ve envanter değerleri.", iconName: "shippingbox.fill"),
        ReportItemInfo(title: "Stok Hareket Raporu", category: "Stok", description: "Giriş ve çıkış stok hareketlerinin kronolojik listesi.", iconName: "arrow.triangle.swap"),
        ReportItemInfo(title: "Kritik Stok Raporu", category: "Stok", description: "Kritik seviyenin altına inen sipariş verilmesi gereken ürünler.", iconName: "exclamationmark.triangle.fill"),
        
        // 5. Fatura & Satış
        ReportItemInfo(title: "Satış Raporu", category: "Fatura & Satış", description: "Dönem içi kesilen tüm satış faturaları ve toplam ciro.", iconName: "cart.fill"),
        ReportItemInfo(title: "Alış Raporu", category: "Fatura & Satış", description: "Tedarikçilerden alınan alış faturaları ve maliyetler.", iconName: "bag.fill"),
        ReportItemInfo(title: "KDV Raporu", category: "Fatura & Satış", description: "Hesaplanan ve indirilecek KDV matrah analizi.", iconName: "percent"),
        ReportItemInfo(title: "Fatura Tasarım Raporu", category: "Fatura & Satış", description: "Özel şablonlu fatura dökümleri ve e-belgeler.", iconName: "doc.richtext.fill"),
        
        // 6. Finans & Analiz
        ReportItemInfo(title: "Kârlılık Analizi", category: "Finans & Analiz", description: "Brüt ve net dönem kârlılık oranları ve marjları.", iconName: "chart.line.uptrend.xyaxis"),
        ReportItemInfo(title: "Hedef & Gerçekleşme", category: "Finans & Analiz", description: "Yıllık ve aylık satış hedeflerine ulaşma performansı.", iconName: "target"),
        ReportItemInfo(title: "Bilanço Özeti", category: "Finans & Analiz", description: "Varlıklar, yükümlülükler ve özkaynak dengesi.", iconName: "scale.3d"),
        ReportItemInfo(title: "Nakit Akış Tablosu", category: "Finans & Analiz", description: "İnteraktif 30 günlük ısı haritası ve nakit akış dökümü.", iconName: "flame.fill"),
        ReportItemInfo(title: "Fatura Bazlı Kârlılık", category: "Finans & Analiz", description: "Fatura başına maliyet ve net kâr marjı hesaplaması.", iconName: "chart.pie.fill"),
        
        // 7. İleri Seviye
        ReportItemInfo(title: "FIFO Stok Değerleme", category: "İleri Seviye", description: "İlk giren ilk çıkar yöntemiyle envanter değerlemesi.", iconName: "cube.transparent.fill"),
        ReportItemInfo(title: "Çek/Senet Risk Analizi", category: "İleri Seviye", description: "Keşideci güvenilirlik ve portföy risk skorlaması.", iconName: "shield.lefthalf.filled"),
        ReportItemInfo(title: "Müşteri Yaşam Boyu Değeri (LTV)", category: "İleri Seviye", description: "Müşteri kârlılık ve sadakat skorları matrisi.", iconName: "crown.fill")
    ]
    
    private let categories = ["Genel Durum", "Finans", "Cari Hesap", "Stok", "Fatura & Satış", "Finans & Analiz", "İleri Seviye"]
    
    public init() {}
    
    public var filteredReports: [ReportItemInfo] {
        allReports.filter { r in
            searchQuery.isEmpty ||
                r.title.localizedCaseInsensitiveContains(searchQuery) ||
                r.description.localizedCaseInsensitiveContains(searchQuery) ||
                r.category.localizedCaseInsensitiveContains(searchQuery)
        }
    }
    
    public var body: some View {
        NavigationStack {
            ZStack {
                Color.black.ignoresSafeArea()
                
                VStack(spacing: 12) {
                    // Header Bar (Exact to RaporlarScreen.tsx)
                    HStack {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Raporlar & Analiz")
                                .font(.system(size: 24, weight: .heavy))
                                .foregroundColor(.white)
                                .tracking(-0.5)
                            Text("Gelişmiş işletme analitiği ve PDF raporlama")
                                .font(.system(size: 13, weight: .medium))
                                .foregroundColor(Color(hex: "94A3B8"))
                        }
                        Spacer()
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 6)
                    
                    // Date Filter Buttons [Tümü | Haftalık | Aylık | Yıllık]
                    HStack(spacing: 8) {
                        filterBtn(title: "Tümü", key: "All")
                        filterBtn(title: "Haftalık", key: "Weekly")
                        filterBtn(title: "Aylık", key: "Monthly")
                        filterBtn(title: "Yıllık", key: "Yearly")
                    }
                    .padding(.horizontal, 16)
                    
                    // Search Bar
                    HStack(spacing: 8) {
                        Image(systemName: "magnifyingglass")
                            .font(.system(size: 16))
                            .foregroundColor(Color(hex: "94A3B8"))
                        
                        TextField("Rapor adı veya açıklama ara...", text: $searchQuery)
                            .font(.system(size: 14))
                            .foregroundColor(.white)
                        
                        if !searchQuery.isEmpty {
                            Button { searchQuery = "" } label: {
                                Image(systemName: "xmark.circle.fill").foregroundColor(Color(hex: "94A3B8"))
                            }
                        }
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 10)
                    .background(Color(hex: "121216"))
                    .cornerRadius(12)
                    .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.white.opacity(0.08), lineWidth: 1))
                    .padding(.horizontal, 16)
                    
                    // Reports List Grouped by Categories
                    ScrollView(showsIndicators: false) {
                        VStack(spacing: 20) {
                            ForEach(categories, id: \.self) { cat in
                                let catReports = filteredReports.filter { $0.category == cat }
                                if !catReports.isEmpty {
                                    VStack(alignment: .leading, spacing: 10) {
                                        Text(cat)
                                            .font(.system(size: 14, weight: .bold))
                                            .foregroundColor(Color(hex: "60A5FA"))
                                            .padding(.horizontal, 4)
                                        
                                        VStack(spacing: 8) {
                                            ForEach(catReports) { r in
                                                NavigationLink(destination: RaporDetayInteractiveView(report: r, dateFilter: selectedFilter)) {
                                                    reportRow(r: r)
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                            
                            Spacer().frame(height: 110)
                        }
                        .padding(.horizontal, 16)
                    }
                }
            }
            .navigationBarHidden(true)
        }
    }
    
    private func filterBtn(title: String, key: String) -> some View {
        let isSel = selectedFilter == key
        return Button {
            withAnimation(.easeInOut(duration: 0.15)) { selectedFilter = key }
        } label: {
            Text(title)
                .font(.system(size: 12, weight: isSel ? .bold : .medium))
                .foregroundColor(isSel ? .white : Color(hex: "8E8E93"))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 8)
                .background(isSel ? Color(hex: "2563EB") : Color(hex: "121216"))
                .cornerRadius(8)
                .overlay(RoundedRectangle(cornerRadius: 8).stroke(isSel ? Color(hex: "2563EB") : Color.white.opacity(0.06), lineWidth: 1))
        }
    }
    
    private func reportRow(r: ReportItemInfo) -> some View {
        HStack(spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(hex: "0061FF").opacity(0.15))
                    .frame(width: 40, height: 40)
                Image(systemName: r.iconName)
                    .font(.system(size: 18))
                    .foregroundColor(Color(hex: "60A5FA"))
            }
            
            VStack(alignment: .leading, spacing: 3) {
                Text(r.title)
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.white)
                    .lineLimit(1)
                
                Text(r.description)
                    .font(.system(size: 11))
                    .foregroundColor(Color(hex: "8E8E93"))
                    .lineLimit(2)
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.system(size: 12, weight: .bold))
                .foregroundColor(Color(hex: "64748B"))
        }
        .padding(14)
        .background(Color(hex: "121216"))
        .cornerRadius(16)
        .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.white.opacity(0.08), lineWidth: 1))
    }
}

// MARK: - Interactive Report Detail View (Exact to RaporDetayScreen.tsx)
public struct RaporDetayInteractiveView: View {
    @Environment(\.presentationMode) var presentationMode
    public let report: ReportItemInfo
    public let dateFilter: String
    
    // Sample Heatmap / Table Data
    struct DailyFlow: Identifiable {
        let id = UUID()
        let day: String
        let date: String
        let satis: Double
        let alis: Double
        let kasaIn: Double
        let kasaOut: Double
        var net: Double { (satis + kasaIn) - (alis + kasaOut) }
    }
    
    @State private var days: [DailyFlow] = (1...30).map { i in
        DailyFlow(
            day: "\(i)",
            date: "\(String(format: "%02d", i)).10.2026",
            satis: Double.random(in: 10000...45000),
            alis: Double.random(in: 5000...35000),
            kasaIn: Double.random(in: 2000...15000),
            kasaOut: Double.random(in: 1000...12000)
        )
    }
    
    @State private var selectedDay: DailyFlow? = nil
    
    public var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header
                HStack {
                    Button {
                        presentationMode.wrappedValue.dismiss()
                    } label: {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.white)
                            .padding(6)
                    }
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text(report.title)
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.white)
                            .lineLimit(1)
                        Text("Dönem: \(dateFilter == "All" ? "Tüm Zamanlar" : dateFilter)")
                            .font(.system(size: 11))
                            .foregroundColor(Color(hex: "8E8E93"))
                    }
                    
                    Spacer()
                    
                    // Share / PDF Buttons
                    Button {
                        shareReport()
                    } label: {
                        HStack(spacing: 4) {
                            Image(systemName: "square.and.arrow.up")
                            Text("Paylaş")
                        }
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(Color(hex: "2563EB"))
                        .cornerRadius(8)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 16) {
                        // Isı Haritası (Nakit Akış veya Finans için)
                        if report.title.contains("Nakit") || report.title.contains("Akış") || report.title.contains("Özet") {
                            VStack(alignment: .leading, spacing: 12) {
                                // 3 KPI Kartı
                                HStack(spacing: 8) {
                                    kpi(title: "Pozitif Günler", val: "19 Gün", color: Color(hex: "10B981"))
                                    kpi(title: "Negatif Günler", val: "11 Gün", color: Color(hex: "EF4444"))
                                    kpi(title: "Net Nakit Akışı", val: "+₺184.200", color: Color(hex: "3B82F6"))
                                }
                                
                                Text("Son 30 Günlük Yoğunluk Hücreleri")
                                    .font(.system(size: 12, weight: .bold))
                                    .foregroundColor(Color(hex: "94A3B8"))
                                
                                // Heatmap 30 Cells Grid (6x5)
                                LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 6), count: 6), spacing: 6) {
                                    ForEach(days) { d in
                                        Button {
                                            selectedDay = d
                                        } label: {
                                            Text(d.day)
                                                .font(.system(size: 11, weight: .bold))
                                                .foregroundColor(.white)
                                                .frame(maxWidth: .infinity, minHeight: 38)
                                                .background(
                                                    d.net >= 0 ? Color(hex: "10B981").opacity(selectedDay?.id == d.id ? 1.0 : 0.4) : Color(hex: "EF4444").opacity(selectedDay?.id == d.id ? 1.0 : 0.4)
                                                )
                                                .cornerRadius(6)
                                                .overlay(
                                                    RoundedRectangle(cornerRadius: 6)
                                                        .stroke(selectedDay?.id == d.id ? Color.white : Color.clear, lineWidth: 2)
                                                )
                                        }
                                    }
                                }
                                
                                // Selected Day Detail Box
                                if let sd = selectedDay {
                                    VStack(alignment: .leading, spacing: 8) {
                                        Text("📅 \(sd.date) Günlük Akış Detayı")
                                            .font(.system(size: 13, weight: .bold))
                                            .foregroundColor(.white)
                                        HStack {
                                            Text("Satış: \(AppFormatters.money(sd.satis))").font(.system(size: 11)).foregroundColor(.white)
                                            Spacer()
                                            Text("Alış: \(AppFormatters.money(sd.alis))").font(.system(size: 11)).foregroundColor(.white)
                                        }
                                        HStack {
                                            Text("Kasa Giriş: +\(AppFormatters.money(sd.kasaIn))").font(.system(size: 11)).foregroundColor(Color(hex: "10B981"))
                                            Spacer()
                                            Text("Kasa Çıkış: -\(AppFormatters.money(sd.kasaOut))").font(.system(size: 11)).foregroundColor(Color(hex: "EF4444"))
                                        }
                                        Divider().background(Color.white.opacity(0.1))
                                        HStack {
                                            Text("Net Akış:").font(.system(size: 12, weight: .bold)).foregroundColor(Color(hex: "94A3B8"))
                                            Spacer()
                                            Text("\(sd.net >= 0 ? "+" : "")\(AppFormatters.money(sd.net))")
                                                .font(.system(size: 13, weight: .heavy))
                                                .foregroundColor(sd.net >= 0 ? Color(hex: "10B981") : Color(hex: "EF4444"))
                                        }
                                    }
                                    .padding(12)
                                    .background(Color.white.opacity(0.04))
                                    .cornerRadius(10)
                                }
                            }
                            .padding(16)
                            .background(Color(hex: "121216"))
                            .cornerRadius(18)
                        }
                        
                        // Generic Summary Table
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Dönemsel Özet Kalemleri").font(.system(size: 13, weight: .bold)).foregroundColor(.white)
                            
                            summaryRow(label: "Toplam Satış Tutarı", value: "₺428.500,00", color: Color(hex: "30D158"))
                            summaryRow(label: "Toplam Alış ve Maliyet", value: "₺215.300,00", color: Color(hex: "FF9F0A"))
                            summaryRow(label: "Brüt Faaliyet Kârı", value: "₺213.200,00", color: Color(hex: "0A84FF"))
                            summaryRow(label: "Kâr Marjı", value: "% 49.75", color: Color(hex: "BF5AF2"))
                            summaryRow(label: "Tahsil Edilen Alacaklar", value: "₺184.500,00", color: Color(hex: "10B981"))
                            summaryRow(label: "Ödenen Borçlar", value: "₺72.300,00", color: Color(hex: "EF4444"))
                        }
                        .padding(16)
                        .background(Color(hex: "121216"))
                        .cornerRadius(18)
                        
                        Spacer().frame(height: 50)
                    }
                    .padding(16)
                }
            }
        }
        .navigationBarHidden(true)
    }
    
    private func kpi(title: String, val: String, color: Color) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title).font(.system(size: 9, weight: .semibold)).foregroundColor(Color(hex: "8E8E93"))
            Text(val).font(.system(size: 13, weight: .heavy)).foregroundColor(color)
        }
        .padding(10)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.white.opacity(0.03))
        .cornerRadius(8)
        .overlay(RoundedRectangle(cornerRadius: 8).stroke(color.opacity(0.4), lineWidth: 1))
    }
    
    private func summaryRow(label: String, value: String, color: Color) -> some View {
        HStack {
            Text(label).font(.system(size: 12)).foregroundColor(Color(hex: "E2E8F0"))
            Spacer()
            Text(value).font(.system(size: 13, weight: .bold)).foregroundColor(color)
        }
        .padding(.vertical, 6)
        .overlay(Divider().background(Color.white.opacity(0.04)), alignment: .bottom)
    }
    
    private func shareReport() {
        #if canImport(UIKit)
        let content = """
        \(report.title.uppercased())
        ---------------------------
        Firma: Ermay Muhasebe
        Tarih: \(ISO8601DateFormatter().string(from: Date()))
        Kategori: \(report.category)
        Açıklama: \(report.description)
        
        ÖZET:
        Toplam Satış: ₺428.500,00
        Toplam Maliyet: ₺215.300,00
        Net Kâr: ₺213.200,00 (%49.75)
        """
        let av = UIActivityViewController(activityItems: [content], applicationActivities: nil)
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let rootVC = windowScene.windows.first?.rootViewController {
            rootVC.present(av, animated: true)
        }
        #endif
    }
}
