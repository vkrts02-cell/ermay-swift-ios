import SwiftUI
#if canImport(UIKit)
import UIKit
import PDFKit
#endif

public struct ReportItemInfo: Identifiable, Hashable {
    public let id: String
    public let title: String
    public let category: String
    public let icon: String
    public let desc: String
    public let colorHex: String
    public let requiresCari: Bool
    public let isHeatmap: Bool
    public let headers: [String]
    public let defaultRows: [[String]]
    
    public init(
        id: String,
        title: String,
        category: String,
        icon: String,
        desc: String,
        colorHex: String,
        requiresCari: Bool = false,
        isHeatmap: Bool = false,
        headers: [String],
        defaultRows: [[String]] = []
    ) {
        self.id = id
        self.title = title
        self.category = category
        self.icon = icon
        self.desc = desc
        self.colorHex = colorHex
        self.requiresCari = requiresCari
        self.isHeatmap = isHeatmap
        self.headers = headers
        self.defaultRows = defaultRows
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    public static func == (lhs: ReportItemInfo, rhs: ReportItemInfo) -> Bool {
        lhs.id == rhs.id
    }
}

public let allReports: [ReportItemInfo] = [
    // --- GENEL ---
    ReportItemInfo(
        id: "1",
        title: "Genel Özet",
        category: "Genel",
        icon: "chart.pie.fill",
        desc: "İşletmenin genel finansal özeti, alacak, borç, kasa ve stok durumu.",
        colorHex: "0061FF",
        headers: ["Rapor Kalemi", "Tutar"]
    ),
    
    // --- CARİ HESAP ---
    ReportItemInfo(
        id: "2",
        title: "Cari Bakiye Raporu",
        category: "Cari Hesap",
        icon: "person.2.fill",
        desc: "Müşteri ve tedarikçilerin güncel borç ve alacak bakiyeleri.",
        colorHex: "3B82F6",
        headers: ["Ünvan", "Şehir", "Borç", "Alacak", "Bakiye", "Durum"]
    ),
    ReportItemInfo(
        id: "3",
        title: "Cari Hareket Dökümü",
        category: "Cari Hesap",
        icon: "list.bullet.rectangle.portrait.fill",
        desc: "Seçilen cari hesabın detaylı hesap ekstresi ve işlem geçmişi.",
        colorHex: "60A5FA",
        requiresCari: true,
        headers: ["Tarih", "Ünvan", "İşlem", "Borç", "Alacak"]
    ),
    ReportItemInfo(
        id: "4",
        title: "Yaşlandırma Raporu",
        category: "Cari Hesap",
        icon: "clock.badge.exclamationmark.fill",
        desc: "Vadesi geçmiş alacakların 30-60-90+ gün bazında analizi.",
        colorHex: "F59E0B",
        headers: ["Ünvan", "0-30 Gün", "31-60 Gün", "61-90 Gün", "90+ Gün", "Toplam"]
    ),
    ReportItemInfo(
        id: "5",
        title: "Vadesi Geçmiş Alacaklar",
        category: "Cari Hesap",
        icon: "bell.badge.fill",
        desc: "Ödeme süresi geçmiş tahsilatların detaylı listesi.",
        colorHex: "EF4444",
        headers: ["Müşteri", "Cari Bakiyesi", "Ort. Gecikme Günü", "Fatura / Evrak No", "Fatura Bakiyesi", "Gecikme (Gün)"]
    ),
    ReportItemInfo(
        id: "6",
        title: "Hareketsiz Cariler",
        category: "Cari Hesap",
        icon: "person.crop.circle.badge.minus",
        desc: "Uzun süredir işlem yapılmayan pasif cari hesaplar.",
        colorHex: "8E8E93",
        headers: ["Ünvan", "Grup", "Telefon", "Son İşlem", "Gün"]
    ),
    
    // --- STOK ---
    ReportItemInfo(
        id: "7",
        title: "Stok Mevcudu",
        category: "Stok",
        icon: "shippingbox.fill",
        desc: "Depodaki ürünlerin güncel miktar ve değer listesi.",
        colorHex: "10B981",
        headers: ["Stok Kodu", "Stok Adı", "Kategori", "Miktar", "Ort. Alış F.", "Ort. Satış F.", "Satış F."]
    ),
    ReportItemInfo(
        id: "8",
        title: "Stok Hareketleri",
        category: "Stok",
        icon: "arrow.left.arrow.right.square.fill",
        desc: "Ürün giriş ve çıkışlarının tarihsel dökümü.",
        colorHex: "0D9488",
        headers: ["Tarih", "Stok Adı", "İşlem", "Giren", "Çıkan", "Birim Fiyat", "Kalan"]
    ),
    ReportItemInfo(
        id: "9",
        title: "Kritik Stok Seviyesi",
        category: "Stok",
        icon: "exclamationmark.triangle.fill",
        desc: "Azalan ve tükenen ürünlerin acil sipariş uyarı listesi.",
        colorHex: "EF4444",
        headers: ["Stok Kodu", "Stok Adı", "Mevcut", "Min. Seviye", "Durum", "Satış Fiyatı"]
    ),
    ReportItemInfo(
        id: "10",
        title: "Ölü Stok Raporu",
        category: "Stok",
        icon: "archivebox.fill",
        desc: "Aynı isim, barkod veya stok koduna sahip mükerrer stokların analizi.",
        colorHex: "6B7280",
        headers: ["Stok Adı", "Barkod", "Stok Kodu", "Mevcut Miktar", "Çakışma Nedeni"]
    ),
    ReportItemInfo(
        id: "11",
        title: "Stok Devir Hızı",
        category: "Stok",
        icon: "arrow.triangle.2.circlepath",
        desc: "Ürünlerin sirkülasyon ve satış hızı performansı.",
        colorHex: "8B5CF6",
        headers: ["Stok Adı", "Mevcut Stok", "Toplam Satış (Çıkan)", "Stok Devir Hızı", "Kategori"]
    ),
    
    // --- SATIŞ ---
    ReportItemInfo(
        id: "12",
        title: "Satış Faturası Dökümü",
        category: "Satış",
        icon: "doc.text.fill",
        desc: "Kesilen tüm satış faturalarının tarih bazlı listesi.",
        colorHex: "00FF87",
        headers: ["Fatura No", "Tarih", "Müşteri", "Ara Toplam", "KDV", "Genel Toplam"]
    ),
    ReportItemInfo(
        id: "13",
        title: "Bölge Bazlı Satış",
        category: "Satış",
        icon: "location.fill",
        desc: "Şehir ve bölge bazında satış dağılımı.",
        colorHex: "3B82F6",
        headers: ["Şehir", "Müşteri Sayısı", "Toplam Satış", "Ortalama Satış"]
    ),
    ReportItemInfo(
        id: "14",
        title: "Bölgesel Satış Analizi",
        category: "Satış",
        icon: "globe.europe.africa.fill",
        desc: "Coğrafi satış performansı ve bölgesel karşılaştırma.",
        colorHex: "0061FF",
        headers: ["Bölge", "Satış Tutarı", "Fatura Sayısı", "Ort. Fatura"]
    ),
    ReportItemInfo(
        id: "15",
        title: "En Çok Satan Ürünler",
        category: "Satış",
        icon: "star.fill",
        desc: "Miktar ve ciro bazında lider ürünlerin sıralaması.",
        colorHex: "F59E0B",
        headers: ["Sıra", "Ürün Adı", "Mevcut Stok", "Satış Fiyatı", "Kategori"]
    ),
    
    // --- KARLILIK ---
    ReportItemInfo(
        id: "16",
        title: "Gelir Tablosu",
        category: "Karlılık",
        icon: "chart.line.uptrend.xyaxis",
        desc: "Dönemsel gelir, gider ve net kâr özeti.",
        colorHex: "10B981",
        headers: ["Kalem", "Tutar"]
    ),
    ReportItemInfo(
        id: "17",
        title: "Ürün Karlılık Raporu",
        category: "Karlılık",
        icon: "chart.bar.fill",
        desc: "Ürün bazında alış-satış marjı ve net kâr analizi.",
        colorHex: "00FF87",
        headers: ["Ürün Adı", "Alış Fiyatı", "Satış Fiyatı", "Kar", "Kar Marjı %"]
    ),
    ReportItemInfo(
        id: "18",
        title: "Müşteri Karlılık Analizi",
        category: "Karlılık",
        icon: "person.badge.plus",
        desc: "Müşteri bazında sağlanan net kâr ve marj katkısı.",
        colorHex: "8B5CF6",
        headers: ["Müşteri", "Toplam Satış", "Tahmini Maliyet", "Net Kar", "Kar Marjı (%)", "Fatura Sayısı"]
    ),
    ReportItemInfo(
        id: "19",
        title: "Detaylı Gelir ve Maliyet Analizi",
        category: "Karlılık",
        icon: "tablecells.fill",
        desc: "Tarih bazlı ürün satışlarının kime yapıldığı ve satır bazlı kâr analizi.",
        colorHex: "0D9488",
        headers: [
            "Tarih", "Ürün Adı", "Müşteri (Kime)", "Miktar", "Satış Fiyatı",
            "Tutar (Net/KDV)", "Tahsilat Yöntemi & Süresi", "En Son Tedarikçi",
            "Alış Fiyatı & Değişim", "Maliyet", "Net Kar & Durum", "Marj", "Ödeme Yöntemi & Süresi"
        ]
    ),
    
    // --- FİNANS ---
    ReportItemInfo(
        id: "20",
        title: "Kasa Hareketleri",
        category: "Finans",
        icon: "banknote.fill",
        desc: "Nakit kasa giriş ve çıkışlarının detaylı dökümü.",
        colorHex: "10B981",
        headers: ["Tarih", "Kasa", "İşlem", "Giren", "Çıkan"]
    ),
    ReportItemInfo(
        id: "21",
        title: "Banka Hareketleri",
        category: "Finans",
        icon: "building.columns.fill",
        desc: "Banka hesaplarındaki güncel bakiyeler ve döviz durumu.",
        colorHex: "3B82F6",
        headers: ["Banka Adı", "Hesap No", "Güncel Bakiye", "Döviz"]
    ),
    ReportItemInfo(
        id: "22",
        title: "Nakit Akış Tablosu",
        category: "Finans",
        icon: "waveform.path.ecg",
        desc: "Nakit giriş ve çıkışlarının kümülatif bakiye takibi.",
        colorHex: "0061FF",
        headers: ["Tarih", "Açıklama", "Giren", "Çıkan", "Bakiye"]
    ),
    ReportItemInfo(
        id: "23",
        title: "Kapsamlı Gider Raporu",
        category: "Finans",
        icon: "arrow.down.right.circle.fill",
        desc: "İşletme giderlerinin ve alış faturalarının kategorik dağılımı.",
        colorHex: "EF4444",
        headers: ["Kategori", "Tutar", "Adet"]
    ),
    ReportItemInfo(
        id: "24",
        title: "Banka/Kasa Nakit Durumu",
        category: "Finans",
        icon: "creditcard.and.123",
        desc: "Tüm kasa ve banka hesaplarındaki anlık nakit varlıklar.",
        colorHex: "00FF87",
        headers: ["Hesap Adı", "Tür", "Bakiye", "Döviz"]
    ),
    ReportItemInfo(
        id: "25",
        title: "Aylık Tahsilat ve Ödeme Analizi",
        category: "Finans",
        icon: "calendar",
        desc: "Aylık bazda nakit, kredi kartı, EFT ve çek akışı.",
        colorHex: "8B5CF6",
        headers: ["Ay/Yıl", "Nakit (Alınan)", "Nakit (Yönl.)", "K.Kartı (Alınan)", "K.Kartı (Yönl.)", "Havale (Alınan)", "Havale (Yönl.)", "Çek (Alınan)", "Çek (Yönl.)"]
    ),
    ReportItemInfo(
        id: "26",
        title: "Kredi Kartı Detay Raporu",
        category: "Finans",
        icon: "creditcard.fill",
        desc: "Kredi kartı tahsilatları ve tedarikçilere yönlendirmeler.",
        colorHex: "F59E0B",
        headers: ["Tarih", "Kimden Alındı", "Banka/Kart", "Kime Yönlendirildi", "Tutar", "Durum"]
    ),
    ReportItemInfo(
        id: "27",
        title: "Nakit İşlem Detay Raporu",
        category: "Finans",
        icon: "dollarsign.circle.fill",
        desc: "Sadece nakit olarak gerçekleşen tahsilat ve ödemeler.",
        colorHex: "10B981",
        headers: ["Tarih", "Cari Ünvan", "İşlem", "Açıklama", "Giren", "Çıkan"]
    ),
    ReportItemInfo(
        id: "28",
        title: "Çek Detay Raporu",
        category: "Finans",
        icon: "doc.plaintext.fill",
        desc: "Portföydeki, tahsildeki ve ciro edilen çeklerin listesi.",
        colorHex: "60A5FA",
        headers: ["Vade", "Çek No", "Cari Ünvan", "Banka/Şube", "Tutar", "Durum"]
    ),
    ReportItemInfo(
        id: "29",
        title: "Havale / EFT Detay Raporu",
        category: "Finans",
        icon: "paperplane.fill",
        desc: "Gelen ve giden tüm banka transferlerinin dökümü.",
        colorHex: "3B82F6",
        headers: ["Tarih", "Müşteri", "Banka/Hesap", "Dekont No", "Tutar", "Durum"]
    ),
    
    // --- STRATEJİK ---
    ReportItemInfo(
        id: "30",
        title: "Müşteri ABC Analizi",
        category: "Stratejik",
        icon: "line.3.horizontal.decrease.circle.fill",
        desc: "Ciroya göre müşteri sınıflandırması (A: %80, B: %15, C: %5).",
        colorHex: "8B5CF6",
        headers: ["Müşteri", "Toplam Satış", "Yüzde", "Sınıf"]
    ),
    ReportItemInfo(
        id: "31",
        title: "Kar-Zarar Mukayesesi",
        category: "Stratejik",
        icon: "arrow.triangle.swap",
        desc: "Yıllık, aylık ve haftalık bazda performans analizi.",
        colorHex: "0061FF",
        headers: ["Dönem", "Satış Tutarı", "Alış Tutarı", "Net Kar/Zarar"]
    ),
    ReportItemInfo(
        id: "32",
        title: "Müşteri Kayıp (Churn)",
        category: "Stratejik",
        icon: "person.fill.xmark",
        desc: "Kayıp riski olan pasif müşterilerin tespiti.",
        colorHex: "EF4444",
        headers: ["Müşteri", "Son İşlem", "Geçen Gün", "Kayıp Riski"]
    ),
    ReportItemInfo(
        id: "33",
        title: "Fiyat Dalgalanma Raporu",
        category: "Stratejik",
        icon: "waveform.path.ecg.rectangle.fill",
        desc: "Ürün alış/satış fiyat değişim trendleri.",
        colorHex: "F59E0B",
        headers: ["Ürün", "Min Fiyat", "Max Fiyat", "Ort Fiyat", "Fark %"]
    ),
    ReportItemInfo(
        id: "34",
        title: "Müşteri Sadakat (LTV)",
        category: "Stratejik",
        icon: "heart.fill",
        desc: "Müşteri yaşam boyu değer ve sipariş sıklığı analizi.",
        colorHex: "FF416C",
        headers: ["Müşteri", "İlk Alışveriş", "Son Alışveriş", "Toplam Harcama", "Ortalama Sepet"]
    ),
    ReportItemInfo(
        id: "35",
        title: "Finansal Isı Haritası",
        category: "Stratejik",
        icon: "map.fill",
        desc: "Günlük finansal aktivite ve nakit akış yoğunluğu.",
        colorHex: "10B981",
        isHeatmap: true,
        headers: ["Tarih", "Satış", "Alış", "Kasa Giren", "Kasa Çıkan", "Net Akış"]
    ),
    ReportItemInfo(
        id: "36",
        title: "Tahsilat Süresi (DSO)",
        category: "Stratejik",
        icon: "speedometer",
        desc: "Ortalama tahsilat hızı (gün) ve vade sapması.",
        colorHex: "0D9488",
        headers: ["Müşteri", "Ortalama Tahsilat Süresi (Gün)", "Toplam Alacak", "Durum"]
    ),
    ReportItemInfo(
        id: "37",
        title: "Bütçe / Hedef Takibi",
        category: "Stratejik",
        icon: "target",
        desc: "Aylık ve yıllık satış hedeflerine ulaşma durumu.",
        colorHex: "00FF87",
        headers: ["Dönem", "Hedef", "Gerçekleşen", "Fark", "%"]
    )
]

private let categories = ["Tümü", "Genel", "Cari Hesap", "Stok", "Satış", "Karlılık", "Finans", "Stratejik"]

public struct RaporlarView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var searchText: String = ""
    @State private var selectedCategory: String = "Tümü"
    @State private var selectedPeriod: String = "All" // "Weekly", "Monthly", "Yearly", "All"
    
    // Cari Selection Overlay for "Cari Hareket Dökümü"
    @State private var isCariOverlayOpen: Bool = false
    @State private var pendingReport: ReportItemInfo? = nil
    @State private var cariSearch: String = ""
    @State private var cariList: [CariKart] = []
    @State private var selectedCariForNav: CariKart? = nil
    @State private var navigateToCariReport: Bool = false
    
    public init() {}
    
    private var filteredReports: [ReportItemInfo] {
        allReports.filter { r in
            let matchCat = selectedCategory == "Tümü" || r.category == selectedCategory
            let matchSearch = searchText.isEmpty ||
                r.title.localizedCaseInsensitiveContains(searchText) ||
                r.desc.localizedCaseInsensitiveContains(searchText)
            return matchCat && matchSearch
        }
    }
    
    public var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header
                HStack {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.white)
                            .padding(8)
                            .background(Color.white.opacity(0.08))
                            .clipShape(Circle())
                    }
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Raporlar & Analiz")
                            .font(.system(size: 22, weight: .bold))
                            .foregroundColor(.white)
                        Text("Kurumsal İş Zekası (\(allReports.count) Rapor)")
                            .font(.system(size: 11))
                            .foregroundColor(Color(hex: "8E8E93"))
                    }
                    Spacer()
                    Image(systemName: "chart.bar.doc.horizontal.fill")
                        .font(.system(size: 22))
                        .foregroundColor(Color(hex: "0061FF"))
                }
                .padding(.horizontal, 16)
                .padding(.top, 12)
                .padding(.bottom, 10)
                
                // Date Period Filter Bar
                HStack(spacing: 8) {
                    periodBtn(id: "Weekly", label: "Bu Hafta")
                    periodBtn(id: "Monthly", label: "Bu Ay")
                    periodBtn(id: "Yearly", label: "Bu Yıl")
                    periodBtn(id: "All", label: "Tümü")
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 10)
                
                // Search Bar
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(Color(hex: "8E8E93"))
                    TextField("Rapor adı veya açıklama ara...", text: $searchText)
                        .foregroundColor(.white)
                        .font(.system(size: 13))
                    if !searchText.isEmpty {
                        Button { searchText = "" } label: {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(Color(hex: "8E8E93"))
                        }
                    }
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 9)
                .background(Color(hex: "121216"))
                .cornerRadius(12)
                .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.white.opacity(0.08), lineWidth: 1))
                .padding(.horizontal, 16)
                .padding(.bottom, 10)
                
                // Category Chips
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(categories, id: \.self) { cat in
                            let isSel = selectedCategory == cat
                            Button {
                                selectedCategory = cat
                                HardwareService.shared.hapticSelection()
                            } label: {
                                Text(cat)
                                    .font(.system(size: 12, weight: isSel ? .bold : .medium))
                                    .foregroundColor(isSel ? .white : Color(hex: "8E8E93"))
                                    .padding(.horizontal, 14)
                                    .padding(.vertical, 7)
                                    .background(isSel ? Color(hex: "0061FF") : Color(hex: "121216"))
                                    .cornerRadius(20)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 20)
                                            .stroke(isSel ? Color(hex: "0061FF") : Color.white.opacity(0.08), lineWidth: 1)
                                    )
                            }
                        }
                    }
                    .padding(.horizontal, 16)
                }
                .padding(.bottom, 12)
                
                // Reports Grid / List
                ScrollView(showsIndicators: false) {
                    LazyVStack(spacing: 10) {
                        ForEach(filteredReports) { rep in
                            if rep.requiresCari {
                                Button {
                                    pendingReport = rep
                                    Task { await loadCarilerForSelection() }
                                    isCariOverlayOpen = true
                                } label: {
                                    reportRowContent(rep: rep)
                                }
                            } else {
                                NavigationLink(
                                    destination: RaporDetayInteractiveView(
                                        report: rep,
                                        dateFilter: selectedPeriod,
                                        cariName: nil,
                                        selectedCari: nil
                                    ).enableSwipeBack()
                                ) {
                                    reportRowContent(rep: rep)
                                }
                            }
                        }
                        Spacer().frame(height: 100)
                    }
                    .padding(.horizontal, 16)
                }
                
                // Hidden programmatic link for Cari Hareket Dökümü after selection
                NavigationLink(
                    destination: Group {
                        if let rep = pendingReport {
                            RaporDetayInteractiveView(
                                report: rep,
                                dateFilter: selectedPeriod,
                                cariName: selectedCariForNav?.unvan,
                                selectedCari: selectedCariForNav
                            ).enableSwipeBack()
                        }
                    },
                    isActive: $navigateToCariReport
                ) {
                    EmptyView()
                }
                .hidden()
            }
        }
        .navigationBarHidden(true)
        .sheet(isPresented: $isCariOverlayOpen) {
            renderCariSelectionSheet()
        }
    }
    
    private func loadCarilerForSelection() async {
        let fetched: [CariKart] = (try? await SupabaseService.shared.fetch(from: "cariler")) ?? DataStore.shared.cariler
        await MainActor.run {
            self.cariList = fetched.filter { !$0.isDeleted }
        }
    }
    
    private func periodBtn(id: String, label: String) -> some View {
        let isSel = selectedPeriod == id
        return Button {
            selectedPeriod = id
            HardwareService.shared.hapticSelection()
        } label: {
            Text(label)
                .font(.system(size: 11, weight: isSel ? .bold : .medium))
                .foregroundColor(isSel ? .white : Color(hex: "8E8E93"))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 8)
                .background(isSel ? Color(hex: "2563EB") : Color(hex: "121216"))
                .cornerRadius(8)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(isSel ? Color(hex: "3B82F6") : Color.white.opacity(0.06), lineWidth: 1)
                )
        }
    }
    
    private func reportRowContent(rep: ReportItemInfo) -> some View {
        HStack(spacing: 14) {
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(hex: rep.colorHex).opacity(0.15))
                    .frame(width: 44, height: 44)
                Image(systemName: rep.icon)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(Color(hex: rep.colorHex))
            }
            
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(rep.title)
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.white)
                    Spacer()
                    Text(rep.category)
                        .font(.system(size: 9, weight: .bold))
                        .foregroundColor(Color(hex: rep.colorHex))
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(Color(hex: rep.colorHex).opacity(0.15))
                        .cornerRadius(4)
                }
                Text(rep.desc)
                    .font(.system(size: 11))
                    .foregroundColor(Color(hex: "8E8E93"))
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)
            }
            
            Image(systemName: "chevron.right")
                .font(.system(size: 12, weight: .bold))
                .foregroundColor(Color(hex: "64748B"))
        }
        .padding(14)
        .background(Color(hex: "121216"))
        .cornerRadius(16)
        .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.white.opacity(0.08), lineWidth: 1))
    }
    
    @ViewBuilder
    private func renderCariSelectionSheet() -> some View {
        let filteredCariler = cariList.filter {
            cariSearch.isEmpty ||
            $0.unvan.localizedCaseInsensitiveContains(cariSearch) ||
            ($0.cariKodu ?? "").localizedCaseInsensitiveContains(cariSearch)
        }
        
        NavigationStack {
            ZStack {
                Color(hex: "09090B").ignoresSafeArea()
                VStack(spacing: 12) {
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(Color(hex: "8E8E93"))
                        TextField("Cari hesap ara...", text: $cariSearch)
                            .foregroundColor(.white)
                    }
                    .padding(10)
                    .background(Color(hex: "121216"))
                    .cornerRadius(10)
                    .padding(.horizontal)
                    .padding(.top, 10)
                    
                    List {
                        Button {
                            selectedCariForNav = nil
                            isCariOverlayOpen = false
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                                navigateToCariReport = true
                            }
                        } label: {
                            HStack {
                                Image(systemName: "person.3.fill")
                                    .foregroundColor(Color(hex: "10B981"))
                                Text("Tüm Cari Hesaplar")
                                    .foregroundColor(.white)
                                    .font(.system(size: 14, weight: .bold))
                                Spacer()
                                Image(systemName: "arrow.right.circle.fill")
                                    .foregroundColor(Color(hex: "10B981"))
                            }
                            .padding(.vertical, 4)
                        }
                        .listRowBackground(Color(hex: "121216"))
                        
                        ForEach(filteredCariler) { c in
                            Button {
                                selectedCariForNav = c
                                isCariOverlayOpen = false
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                                    navigateToCariReport = true
                                }
                            } label: {
                                HStack {
                                    Image(systemName: "building.2.fill")
                                        .foregroundColor(Color(hex: "3B82F6"))
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text(c.unvan)
                                            .foregroundColor(.white)
                                            .font(.system(size: 14, weight: .semibold))
                                        Text(AppFormatters.money(c.bakiye))
                                            .foregroundColor(Color(hex: "8E8E93"))
                                            .font(.system(size: 11))
                                    }
                                    Spacer()
                                    Image(systemName: "arrow.right.circle.fill")
                                        .foregroundColor(Color(hex: "60A5FA"))
                                }
                                .padding(.vertical, 4)
                            }
                            .listRowBackground(Color(hex: "121216"))
                        }
                    }
                    .listStyle(.plain)
                    .scrollContentBackground(.hidden)
                }
            }
            .navigationTitle("Cari Hesap Seçiniz")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Kapat") { isCariOverlayOpen = false }
                        .foregroundColor(Color(hex: "60A5FA"))
                }
            }
        }
    }
}

// MARK: - Interactive Report Detail View (Masaüstü RaporListViewModel & QuestPDF Birebir Eşleşme)
public struct RaporDetayInteractiveView: View {
    @Environment(\.dismiss) private var dismiss
    public let report: ReportItemInfo
    public let dateFilter: String
    public let cariName: String?
    public let selectedCari: CariKart?
    
    @State private var currentFilter: String
    @State private var pdfPreviewItem: PDFPreviewItem? = nil
    @State private var activeHeaders: [String]
    @State private var liveRows: [[String]] = []
    @State private var isLoadingData: Bool = false
    @State private var isGeneratingPDF: Bool = false
    
    // Heatmap data structure
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
    
    @State private var days: [DailyFlow] = []
    @State private var selectedDay: DailyFlow? = nil
    
    public init(report: ReportItemInfo, dateFilter: String, cariName: String?, selectedCari: CariKart? = nil) {
        self.report = report
        self.dateFilter = dateFilter
        self.cariName = cariName
        self.selectedCari = selectedCari
        _currentFilter = State(initialValue: dateFilter)
        _activeHeaders = State(initialValue: report.headers)
    }
    
    public var activeRows: [[String]] {
        liveRows
    }
    
    private var filterDisplayLabel: String {
        switch currentFilter {
        case "Weekly": return "Bu Hafta"
        case "Monthly": return "Bu Ay"
        case "Yearly": return "Bu Yıl"
        default: return "Tüm Zamanlar"
        }
    }
    
    public var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Top Navigation Bar
                HStack {
                    Button {
                        dismiss()
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
                        HStack(spacing: 4) {
                            Text("Dönem: \(filterDisplayLabel)")
                            if let c = cariName {
                                Text("• \(c)")
                            }
                        }
                        .font(.system(size: 11))
                        .foregroundColor(Color(hex: "8E8E93"))
                        .lineLimit(1)
                    }
                    
                    Spacer()
                    
                    if isLoadingData || isGeneratingPDF {
                        ProgressView().tint(.white).padding(.trailing, 4)
                    }
                    
                    // PDF Aç Butonu (QuestPDF Önizleme)
                    Button {
                        openPDF()
                    } label: {
                        HStack(spacing: 4) {
                            Image(systemName: "doc.text.fill")
                            Text("PDF")
                        }
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(Color(hex: "0061FF"))
                        .cornerRadius(8)
                    }
                    .disabled(isGeneratingPDF)
                    
                    // Share / PDF Button (QuestPDF Paylaşım)
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
                    .disabled(isGeneratingPDF)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                
                // Dönem Seçici (Rapor İçinden de Değiştirilebilir)
                HStack(spacing: 6) {
                    detailPeriodChip(id: "Weekly", label: "Bu Hafta")
                    detailPeriodChip(id: "Monthly", label: "Bu Ay")
                    detailPeriodChip(id: "Yearly", label: "Bu Yıl")
                    detailPeriodChip(id: "All", label: "Tümü")
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 8)
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 16) {
                        if report.isHeatmap {
                            renderHeatmapSection()
                        }
                        
                        renderTableSection()
                        
                        Spacer().frame(height: 50)
                    }
                    .padding(16)
                }
            }
        }
        .navigationBarHidden(true)
        .task {
            await loadLiveReportData()
        }
        .onReceive(NotificationCenter.default.publisher(for: .supabaseRealtimeDataChanged)) { _ in
            Task {
                await loadLiveReportData()
            }
        }
        .sheet(item: $pdfPreviewItem) { item in
            PDFViewerModal(
                title: item.title,
                pdfData: item.data,
                fileName: item.fileName
            )
        }
    }
    
    private func detailPeriodChip(id: String, label: String) -> some View {
        let isSel = currentFilter == id
        return Button {
            currentFilter = id
            Task { await loadLiveReportData() }
        } label: {
            Text(label)
                .font(.system(size: 11, weight: isSel ? .bold : .medium))
                .foregroundColor(isSel ? .white : Color(hex: "8E8E93"))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 6)
                .background(isSel ? Color(hex: "2563EB") : Color(hex: "121216"))
                .cornerRadius(8)
        }
    }
    
    // MARK: - Live Database Data Loader
    private func loadLiveReportData() async {
        await MainActor.run { isLoadingData = true }
        let res = await ReportCalculationService.shared.calculateReportData(
            for: report.title,
            filter: currentFilter,
            selectedCari: selectedCari
        )
        
        var computedDays: [DailyFlow] = []
        if report.isHeatmap {
            let faturalar: [Fatura] = (try? await SupabaseService.shared.fetch(from: "faturalar")) ?? DataStore.shared.faturalar
            let kasaHar: [KasaHareket] = (try? await SupabaseService.shared.fetch(from: "kasa_hareketler")) ?? []
            let cal = Calendar.current
            let today = cal.startOfDay(for: Date())
            for i in (0..<30).reversed() {
                if let d = cal.date(byAdding: .day, value: -i, to: today) {
                    let isoP = AppFormatters.isoDate.string(from: d)
                    let trP = AppFormatters.shortDate.string(from: d)
                    let dayNum = "\(cal.component(.day, from: d))"
                    let s = faturalar.filter { ($0.faturaTuru.localizedCaseInsensitiveContains("satış") || $0.faturaTuru.localizedCaseInsensitiveContains("satis")) && ($0.tarih.hasPrefix(isoP) || $0.tarih.hasPrefix(trP)) }.reduce(0.0) { $0 + $1.genelToplam }
                    let a = faturalar.filter { ($0.faturaTuru.localizedCaseInsensitiveContains("alış") || $0.faturaTuru.localizedCaseInsensitiveContains("alis")) && ($0.tarih.hasPrefix(isoP) || $0.tarih.hasPrefix(trP)) }.reduce(0.0) { $0 + $1.genelToplam }
                    let ki = kasaHar.filter { $0.tarih.hasPrefix(isoP) || $0.tarih.hasPrefix(trP) }.reduce(0.0) { $0 + $1.giren }
                    let ko = kasaHar.filter { $0.tarih.hasPrefix(isoP) || $0.tarih.hasPrefix(trP) }.reduce(0.0) { $0 + $1.cikan }
                    computedDays.append(DailyFlow(day: dayNum, date: trP, satis: s, alis: a, kasaIn: ki, kasaOut: ko))
                }
            }
        }
        
        await MainActor.run {
            if !res.headers.isEmpty {
                self.activeHeaders = res.headers
            }
            self.liveRows = res.rows
            if report.isHeatmap {
                self.days = computedDays
            }
            self.isLoadingData = false
        }
    }
    
    // MARK: - Heatmap Section (100% Live Data)
    @ViewBuilder
    private func renderHeatmapSection() -> some View {
        let posCount = days.filter { $0.net > 0 }.count
        let negCount = days.filter { $0.net < 0 }.count
        let totalNet = days.reduce(0.0) { $0 + $1.net }
        
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 8) {
                kpi(title: "Pozitif Günler", val: "\(posCount) Gün", color: Color(hex: "10B981"))
                kpi(title: "Negatif Günler", val: "\(negCount) Gün", color: Color(hex: "EF4444"))
                kpi(title: "Net Nakit Akışı", val: AppFormatters.money(totalNet), color: Color(hex: "3B82F6"))
            }
            
            Text("Son 30 Günlük Yoğunluk Hücreleri")
                .font(.system(size: 13, weight: .bold))
                .foregroundColor(.white)
            
            let columns = Array(repeating: GridItem(.flexible(), spacing: 6), count: 6)
            LazyVGrid(columns: columns, spacing: 6) {
                ForEach(days) { day in
                    Button {
                        selectedDay = day
                        HardwareService.shared.hapticImpact()
                    } label: {
                        VStack(spacing: 2) {
                            Text(day.day)
                                .font(.system(size: 11, weight: .bold))
                                .foregroundColor(.white)
                            let kVal = Int(abs(day.net) / 1000)
                            Text(day.net == 0 ? "0" : (day.net > 0 ? "+\(kVal)k" : "-\(kVal)k"))
                                .font(.system(size: 8))
                                .foregroundColor(day.net >= 0 ? Color(hex: "10B981") : Color(hex: "EF4444"))
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 44)
                        .background(heatmapCellBg(day: day))
                        .cornerRadius(8)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(selectedDay?.id == day.id ? Color.white : Color.clear, lineWidth: 2)
                        )
                    }
                }
            }
            
            if let sel = selectedDay {
                VStack(alignment: .leading, spacing: 6) {
                    HStack {
                        Text("Tarih: \(sel.date)")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(.white)
                        Spacer()
                        Text("Net: \(AppFormatters.money(sel.net))")
                            .font(.system(size: 12, weight: .heavy))
                            .foregroundColor(sel.net >= 0 ? Color(hex: "10B981") : Color(hex: "EF4444"))
                    }
                    Divider().background(Color.white.opacity(0.1))
                    HStack {
                        Text("Satış: \(AppFormatters.money(sel.satis)) • Alış: \(AppFormatters.money(sel.alis))")
                            .font(.system(size: 10))
                            .foregroundColor(Color(hex: "8E8E93"))
                        Spacer()
                        Text("Kasa: \(AppFormatters.money(sel.kasaIn - sel.kasaOut))")
                            .font(.system(size: 10))
                            .foregroundColor(Color(hex: "8E8E93"))
                    }
                }
                .padding(10)
                .background(Color.white.opacity(0.05))
                .cornerRadius(10)
            }
        }
        .padding(14)
        .background(Color(hex: "121216"))
        .cornerRadius(16)
        .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.white.opacity(0.08), lineWidth: 1))
    }
    
    private func heatmapCellBg(day: DailyFlow) -> Color {
        if day.net == 0 { return Color.white.opacity(0.04) }
        let ratio = min(abs(day.net) / 30000.0, 1.0)
        let opacity = 0.2 + (ratio * 0.6)
        let baseColor = day.net >= 0 ? Color(hex: "10B981") : Color(hex: "EF4444")
        return baseColor.opacity(opacity)
    }

    // MARK: - Table Section (Headers + Dynamic Live Rows)
    @ViewBuilder
    private func renderTableSection() -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("Detaylı Rapor Tablosu (\(activeRows.count) Kayıt)")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundColor(.white)
                Spacer()
                Text("QuestPDF & Canlı Veri")
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundColor(Color(hex: "00FF87"))
            }
            
            ScrollView(.horizontal, showsIndicators: false) {
                VStack(alignment: .leading, spacing: 0) {
                    // Header Row
                    HStack(spacing: 0) {
                        ForEach(activeHeaders, id: \.self) { h in
                            Text(h)
                                .font(.system(size: 11, weight: .bold))
                                .foregroundColor(Color(hex: "8E8E93"))
                                .frame(width: 135, alignment: .leading)
                                .padding(.vertical, 8)
                                .padding(.horizontal, 6)
                        }
                    }
                    .background(Color.white.opacity(0.05))
                    .cornerRadius(6)
                    
                    Divider().background(Color.white.opacity(0.1))
                    
                    if activeRows.isEmpty {
                        Text(isLoadingData ? "Veriler yükleniyor..." : "Seçili dönemde kayıt bulunamadı.")
                            .font(.system(size: 12))
                            .foregroundColor(Color(hex: "8E8E93"))
                            .padding(.vertical, 20)
                            .padding(.horizontal, 8)
                    } else {
                        ForEach(Array(activeRows.enumerated()), id: \.offset) { rowIndex, row in
                            HStack(spacing: 0) {
                                ForEach(Array(row.enumerated()), id: \.offset) { colIndex, cell in
                                    Text(cell)
                                        .font(.system(size: 12, weight: colIndex == 0 ? .semibold : .regular))
                                        .foregroundColor(cellColor(cell: cell, colIndex: colIndex))
                                        .frame(width: 135, alignment: .leading)
                                        .padding(.vertical, 8)
                                        .padding(.horizontal, 6)
                                }
                            }
                            .background(rowIndex % 2 == 0 ? Color.clear : Color.white.opacity(0.02))
                            
                            Divider().background(Color.white.opacity(0.04))
                        }
                    }
                }
            }
        }
        .padding(16)
        .background(Color(hex: "121216"))
        .cornerRadius(18)
        .overlay(RoundedRectangle(cornerRadius: 18).stroke(Color.white.opacity(0.08), lineWidth: 1))
    }
    
    private func cellColor(cell: String, colIndex: Int) -> Color {
        if cell.contains("+") || cell.contains("Borçlu") || cell.contains("Kâr") || cell.contains("Yuksek Kar") {
            return Color(hex: "10B981")
        } else if cell.contains("-") || cell.contains("Alacaklı") || cell.contains("ZARAR") || cell.contains("Kritik") || cell.contains("Risk") {
            return Color(hex: "EF4444")
        }
        return .white
    }
    
    private func kpi(title: String, val: String, color: Color) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title).font(.system(size: 9, weight: .semibold)).foregroundColor(Color(hex: "8E8E93"))
            Text(val).font(.system(size: 13, weight: .heavy)).foregroundColor(color).lineLimit(1).minimumScaleFactor(0.7)
        }
        .padding(10)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.white.opacity(0.03))
        .cornerRadius(8)
        .overlay(RoundedRectangle(cornerRadius: 8).stroke(color.opacity(0.4), lineWidth: 1))
    }
    
    private func openPDF() {
        #if canImport(UIKit)
        Task { @MainActor in
            isGeneratingPDF = true
            let pdfData = await ReportCalculationService.shared.generateDesktopReportPDF(
                for: report.title,
                filter: currentFilter,
                selectedCari: selectedCari
            )
            isGeneratingPDF = false
            self.pdfPreviewItem = PDFPreviewItem(
                title: report.title,
                data: pdfData,
                fileName: "\(report.title)_\(currentFilter).pdf"
            )
        }
        #endif
    }
    
    private func shareReport() {
        #if canImport(UIKit)
        Task { @MainActor in
            isGeneratingPDF = true
            let pdfData = await ReportCalculationService.shared.generateDesktopReportPDF(
                for: report.title,
                filter: currentFilter,
                selectedCari: selectedCari
            )
            isGeneratingPDF = false
            PDFService.shared.sharePDF(
                data: pdfData,
                fileName: "\(report.title)_\(currentFilter).pdf"
            )
        }
        #endif
    }
}
