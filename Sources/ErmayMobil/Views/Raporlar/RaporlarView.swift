import SwiftUI

public struct ReportItemInfo: Identifiable, Hashable {
    public let id = UUID()
    public let title: String
    public let category: String
    public let description: String
    public let iconName: String
    public let headers: [String]
    public let defaultRows: [[String]]
    public let isHeatmap: Bool
    public let needsCari: Bool
}

public struct RaporlarView: View {
    @State private var searchQuery: String = ""
    @State private var selectedFilter: String = "All" // "All" | "Weekly" | "Monthly" | "Yearly"
    @State private var selectedReport: ReportItemInfo? = nil
    
    // Cari Selection Overlay for 'Cari Hareket Dökümü'
    @State private var isCariOverlayOpen: Bool = false
    @State private var cariSearch: String = ""
    @State private var selectedCariName: String = "Tüm Cariler"
    
    // Full 31 Reports Catalog (100% exact to RaporlarScreen.tsx)
    private let allReports: [ReportItemInfo] = [
        // 1. Genel Durum
        ReportItemInfo(
            title: "Genel Özet",
            category: "Genel Durum",
            description: "İşletmenin genel mali özetini gösterir.",
            iconName: "chart.bar.doc.horizontal.fill",
            headers: ["Rapor Kalemi", "Detay"],
            defaultRows: [
                ["Toplam Alacaklar", "₺485.250,00"],
                ["Toplam Borçlar", "₺192.400,00"],
                ["Kasa / Banka Mevcudu", "₺215.300,00"],
                ["Toplam Stok Miktarı", "1.420 Adet"],
                ["Stok Maliyet Değeri", "₺380.000,00"]
            ],
            isHeatmap: false,
            needsCari: false
        ),
        
        // 2. Finans
        ReportItemInfo(
            title: "Aylık Tahsilat ve Ödeme Analizi",
            category: "Finans",
            description: "Ay bazlı ödeme türlerine göre tahsilat ve yönlendirme özeti.",
            iconName: "calendar.badge.clock",
            headers: ["Ay", "Nakit Tahsilat", "Kredi Kartı", "Havale / EFT", "Toplam Tahsilat", "Ödemeler"],
            defaultRows: [
                ["Kasım 2026", "₺45.000,00", "₺82.500,00", "₺120.000,00", "₺247.500,00", "₺110.000,00"],
                ["Ekim 2026", "₺52.000,00", "₺76.000,00", "₺98.000,00", "₺226.000,00", "₺95.400,00"],
                ["Eylül 2026", "₺38.500,00", "₺69.000,00", "₺105.000,00", "₺212.500,00", "₺88.000,00"]
            ],
            isHeatmap: false,
            needsCari: false
        ),
        ReportItemInfo(
            title: "Kredi Kartı Detay Raporu",
            category: "Finans",
            description: "Kaydedilen ve yönlendirilen kredi kartı işlem detayları.",
            iconName: "creditcard.fill",
            headers: ["Tarih", "Cari Ünvan", "Banka / POS", "Tutar", "Komisyon", "Net"],
            defaultRows: [
                ["03.11.2026", "Akıncılar Ltd.", "Garanti POS", "₺14.500,00", "₺290,00", "₺14.210,00"],
                ["02.11.2026", "Özdemir A.Ş.", "Yapı Kredi", "₺8.200,00", "₺164,00", "₺8.036,00"],
                ["01.11.2026", "Tekin Metal", "İş Bankası", "₺22.000,00", "₺440,00", "₺21.560,00"]
            ],
            isHeatmap: false,
            needsCari: false
        ),
        ReportItemInfo(
            title: "Nakit İşlem Detay Raporu",
            category: "Finans",
            description: "Tüm nakit kasa hareketlerinin detaylı dökümü.",
            iconName: "banknote.fill",
            headers: ["Tarih", "Kasa", "İşlem Türü", "Açıklama", "Tutar", "Bakiye"],
            defaultRows: [
                ["04.11.2026", "Merkez TL Kasası", "Tahsilat", "Elden Satış Tahsilatı", "₺5.000,00", "₺42.500,00"],
                ["03.11.2026", "Merkez TL Kasası", "Tediye", "Yemek & İkram Gideri", "₺450,00", "₺37.500,00"],
                ["02.11.2026", "Şube Kasası", "Tahsilat", "Nakit Cari Tahsilat", "₺12.000,00", "₺37.950,00"]
            ],
            isHeatmap: false,
            needsCari: false
        ),
        ReportItemInfo(
            title: "Çek Detay Raporu",
            category: "Finans",
            description: "Portföydeki ve işlem görmüş çeklerin detayları.",
            iconName: "doc.plaintext.fill",
            headers: ["Vade", "Çek No", "Keşideci", "Banka", "Tutar", "Durum"],
            defaultRows: [
                ["15.11.2026", "ÇK-10928", "Doruk İnşaat", "Garanti BBVA", "₺35.000,00", "Portföyde"],
                ["28.11.2026", "ÇK-10929", "Kuzey Çelik", "Akbank", "₺50.000,00", "Portföyde"],
                ["05.12.2026", "ÇK-10930", "Yıldız Ticaret", "Yapı Kredi", "₺27.500,00", "Tahsile Verildi"]
            ],
            isHeatmap: false,
            needsCari: false
        ),
        ReportItemInfo(
            title: "Havale / EFT Detay Raporu",
            category: "Finans",
            description: "Banka havale ve EFT işlemlerinin detaylı listesi.",
            iconName: "building.columns.fill",
            headers: ["Tarih", "Banka Hesabı", "Gönderen/Alıcı", "Açıklama", "Tutar"],
            defaultRows: [
                ["03.11.2026", "İş Bankası Ticari", "Demir Grup Sanayi", "Fatura No: FAT-2026-09", "₺45.000,00"],
                ["02.11.2026", "Garanti BBVA TL", "Yılmazlar Nakliyat", "Navlun Bedeli", "₺6.800,00"],
                ["01.11.2026", "Akbank Şirket", "Birlik Makine", "Sipariş Peşinatı", "₺80.000,00"]
            ],
            isHeatmap: false,
            needsCari: false
        ),
        ReportItemInfo(
            title: "Gelir Tablosu",
            category: "Finans",
            description: "Dönemsel gelir ve gider özeti.",
            iconName: "chart.pie.fill",
            headers: ["Hesap / Kalem", "Dönem Tutarı", "Yıllık Toplam"],
            defaultRows: [
                ["Brüt Satış Gelirleri", "₺428.500,00", "₺3.850.000,00"],
                ["Satış İndirimleri (-)", "₺8.200,00", "₺72.000,00"],
                ["Net Satışlar", "₺420.300,00", "₺3.778.000,00"],
                ["Satışların Maliyeti (-)", "₺215.300,00", "₺1.940.000,00"],
                ["Brüt Faaliyet Kârı", "₺205.000,00", "₺1.838.000,00"],
                ["Faaliyet Giderleri (-)", "₺42.000,00", "₺380.000,00"],
                ["Net Dönem Kârı", "₺163.000,00", "₺1.458.000,00"]
            ],
            isHeatmap: false,
            needsCari: false
        ),
        ReportItemInfo(
            title: "Nakit Akış Tablosu",
            category: "Finans",
            description: "Nakit giriş ve çıkışlarının takibi.",
            iconName: "flame.fill",
            headers: ["Tarih", "Satış", "Alış", "Kasa Giriş", "Kasa Çıkış", "Net Akış"],
            defaultRows: [
                ["04.11.2026", "₺24.500", "₺12.000", "₺5.000", "₺2.500", "+₺15.000"],
                ["03.11.2026", "₺18.200", "₺15.000", "₺2.000", "₺1.800", "+₺3.400"],
                ["02.11.2026", "₺12.000", "₺22.000", "₺4.000", "₺3.000", "-₺9.000"],
                ["01.11.2026", "₺35.000", "₺8.000", "₺6.000", "₺1.000", "+₺32.000"]
            ],
            isHeatmap: true,
            needsCari: false
        ),
        
        // 3. Cari Hesap
        ReportItemInfo(
            title: "Cari Bakiye Raporu",
            category: "Cari Hesap",
            description: "Müşteri ve tedarikçi bakiyeleri.",
            iconName: "person.2.fill",
            headers: ["Ünvan", "Şehir", "Borç", "Alacak", "Bakiye", "Durum"],
            defaultRows: [
                ["Akıncılar Çelik Ltd.", "İstanbul", "₺95.000,00", "₺12.000,00", "₺83.000,00", "Borçlu"],
                ["Özdemir Makine San.", "Bursa", "₺34.200,00", "₺0,00", "₺34.200,00", "Borçlu"],
                ["Tekin Metal Sanayi", "Ankara", "₺0,00", "₺45.000,00", "-₺45.000,00", "Alacaklı"],
                ["Kuzey Yapı Market", "İzmir", "₺18.500,00", "₺18.500,00", "₺0,00", "Dengede"]
            ],
            isHeatmap: false,
            needsCari: false
        ),
        ReportItemInfo(
            title: "Cari Hareket Dökümü",
            category: "Cari Hesap",
            description: "Cari hesapların işlem detayları.",
            iconName: "list.bullet.rectangle.portrait.fill",
            headers: ["Tarih", "İşlem", "Evrak No", "Borç", "Alacak"],
            defaultRows: [
                ["02.11.2026", "Satış Faturası", "FAT-2026-0042", "₺28.500,00", "₺0,00"],
                ["28.10.2026", "Havale / EFT", "EFT-88392", "₺0,00", "₺20.000,00"],
                ["15.10.2026", "Satış Faturası", "FAT-2026-0038", "₺45.000,00", "₺0,00"]
            ],
            isHeatmap: false,
            needsCari: true
        ),
        ReportItemInfo(
            title: "Yaşlandırma Raporu",
            category: "Cari Hesap",
            description: "Borç/alacak yaşlandırma analizi.",
            iconName: "hourglass",
            headers: ["Cari Ünvan", "0-30 Gün", "31-60 Gün", "61-90 Gün", "90+ Gün", "Toplam"],
            defaultRows: [
                ["Akıncılar Çelik", "₺35.000,00", "₺28.000,00", "₺20.000,00", "₺0,00", "₺83.000,00"],
                ["Özdemir Makine", "₺14.200,00", "₺20.000,00", "₺0,00", "₺0,00", "₺34.200,00"],
                ["Birlik Hırdavat", "₺0,00", "₺5.000,00", "₺12.000,00", "₺8.400,00", "₺25.400,00"]
            ],
            isHeatmap: false,
            needsCari: false
        ),
        ReportItemInfo(
            title: "Hareketsiz Cariler",
            category: "Cari Hesap",
            description: "İşlem görmeyen cari hesaplar.",
            iconName: "person.crop.circle.badge.minus",
            headers: ["Cari Ünvan", "Son İşlem Tarihi", "Bakiye", "Telefon", "Yetkili"],
            defaultRows: [
                ["Asil Otomotiv Ltd.", "12.04.2026", "₺0,00", "0532 111 2233", "Kenan Bey"],
                ["Güneş Rulman San.", "24.05.2026", "₺1.200,00", "0544 555 6677", "Selin Hanım"],
                ["Erler Civata Dağıtım", "08.06.2026", "-₺450,00", "0555 999 8811", "Murat Bey"]
            ],
            isHeatmap: false,
            needsCari: false
        ),
        ReportItemInfo(
            title: "Vadesi Geçmiş Alacaklar",
            category: "Cari Hesap",
            description: "Ödeme süresi geçmiş tahsilatlar.",
            iconName: "clock.badge.exclamationmark.fill",
            headers: ["Cari Ünvan", "Evrak No", "Vade Tarihi", "Gecikme (Gün)", "Tutar"],
            defaultRows: [
                ["Akıncılar Çelik", "FAT-2026-0021", "15.10.2026", "20 Gün", "₺28.000,00"],
                ["Birlik Hırdavat", "FAT-2026-0019", "01.10.2026", "34 Gün", "₺12.000,00"],
                ["Özdemir Makine", "FAT-2026-0030", "25.10.2026", "10 Gün", "₺20.000,00"]
            ],
            isHeatmap: false,
            needsCari: false
        ),
        
        // 4. Stok
        ReportItemInfo(
            title: "Stok Mevcudu",
            category: "Stok",
            description: "Güncel stok miktarları ve değerleri.",
            iconName: "shippingbox.fill",
            headers: ["Stok Kodu", "Stok Adı", "Kategori", "Miktar", "Ort. Alış F.", "Ort. Satış F.", "Satış F."],
            defaultRows: [
                ["STK-001", "Paslanmaz Sac 2mm", "Sac Grubu", "120.00", "₺450,00", "₺620,00", "₺650,00"],
                ["STK-002", "Profil Boru 40x40", "Profil", "85.00", "₺180,00", "₺260,00", "₺275,00"],
                ["STK-003", "Kaynak Teli 1.2mm", "Sarf Malzeme", "40.00", "₺85,00", "₺130,00", "₺140,00"]
            ],
            isHeatmap: false,
            needsCari: false
        ),
        ReportItemInfo(
            title: "Stok Hareketleri",
            category: "Stok",
            description: "Giriş-çıkış stok hareket dökümü.",
            iconName: "arrow.triangle.swap",
            headers: ["Tarih", "Stok Adı", "İşlem", "Giren", "Çıkan", "Birim Fiyat", "Kalan"],
            defaultRows: [
                ["03.11.2026", "Paslanmaz Sac 2mm", "Satış", "0", "15", "₺650,00", "120"],
                ["01.11.2026", "Paslanmaz Sac 2mm", "Alış", "50", "0", "₺450,00", "135"],
                ["30.10.2026", "Profil Boru 40x40", "Satış", "0", "20", "₺275,00", "85"]
            ],
            isHeatmap: false,
            needsCari: false
        ),
        ReportItemInfo(
            title: "Kritik Stok Seviyesi",
            category: "Stok",
            description: "Minimum seviyenin altındaki ürünler.",
            iconName: "exclamationmark.triangle.fill",
            headers: ["Stok Kodu", "Stok Adı", "Mevcut", "Kritik Seviye", "Fark", "Durum"],
            defaultRows: [
                ["STK-003", "Kaynak Teli 1.2mm", "8 Adet", "20 Adet", "-12 Adet", "Kritik Sipariş!"],
                ["STK-012", "Kesme Taşı 180mm", "4 Adet", "15 Adet", "-11 Adet", "Kritik Sipariş!"],
                ["STK-019", "Cıvata M10x50", "25 Adet", "50 Adet", "-25 Adet", "Azalıyor"]
            ],
            isHeatmap: false,
            needsCari: false
        ),
        ReportItemInfo(
            title: "Ölü Stok Raporu",
            category: "Stok",
            description: "Çakışan stok kartlarının listesi (Birleştirilmesi Gerekenler).",
            iconName: "archivebox.fill",
            headers: ["Stok Adı", "Kategori", "Adet", "Grup", "Öneri"],
            defaultRows: [
                ["Paslanmaz Çelik Sac 2mm", "Sac Grubu", "2 Benzer Kart", "Sac-2", "Birleştirme Önerilir"],
                ["Profil Boru 40*40", "Profil", "2 Benzer Kart", "Boru-40", "Birleştirme Önerilir"]
            ],
            isHeatmap: false,
            needsCari: false
        ),
        ReportItemInfo(
            title: "Stok Devir Hızı",
            category: "Stok",
            description: "Stokların dönüşüm hızı analizi.",
            iconName: "repeat",
            headers: ["Stok Adı", "Satılan Adet", "Ortalama Stok", "Devir Hızı", "Devir Süresi"],
            defaultRows: [
                ["Paslanmaz Sac 2mm", "240 Adet", "100 Adet", "2.40x", "152 Gün"],
                ["Profil Boru 40x40", "310 Adet", "70 Adet", "4.42x", "82 Gün"],
                ["Kaynak Teli 1.2mm", "180 Adet", "30 Adet", "6.00x", "60 Gün"]
            ],
            isHeatmap: false,
            needsCari: false
        ),
        
        // 5. Satış & Karlılık
        ReportItemInfo(
            title: "Satış Faturası Dökümü",
            category: "Satış",
            description: "Kesilen satış faturalarının listesi.",
            iconName: "cart.fill",
            headers: ["Fatura No", "Tarih", "Müşteri Ünvanı", "KDV Hariç", "KDV", "Genel Toplam"],
            defaultRows: [
                ["FAT-2026-0045", "03.11.2026", "Akıncılar Çelik", "₺35.000,00", "₺7.000,00", "₺42.000,00"],
                ["FAT-2026-0044", "02.11.2026", "Özdemir Makine", "₺18.500,00", "₺3.700,00", "₺22.200,00"],
                ["FAT-2026-0043", "01.11.2026", "Birlik Hırdavat", "₺8.400,00", "₺1.680,00", "₺10.080,00"]
            ],
            isHeatmap: false,
            needsCari: false
        ),
        ReportItemInfo(
            title: "En Çok Satan Ürünler",
            category: "Satış",
            description: "Satış adedine göre top listeler.",
            iconName: "flame.circle.fill",
            headers: ["Sıra", "Ürün Adı", "Satış Adedi", "Toplam Tutar", "Ciro Payı"],
            defaultRows: [
                ["1", "Paslanmaz Sac 2mm", "240 Adet", "₺156.000,00", "%36.4"],
                ["2", "Profil Boru 40x40", "310 Adet", "₺85.250,00", "%19.8"],
                ["3", "Kaynak Teli 1.2mm", "180 Adet", "₺25.200,00", "%5.8"]
            ],
            isHeatmap: false,
            needsCari: false
        ),
        ReportItemInfo(
            title: "Ürün Karlılık Raporu",
            category: "Karlılık",
            description: "Ürün bazlı kar/zarar analizi.",
            iconName: "chart.line.uptrend.xyaxis",
            headers: ["Ürün Adı", "Satış Geliri", "Alış Maliyeti", "Net Kâr", "Kâr Marjı"],
            defaultRows: [
                ["Paslanmaz Sac 2mm", "₺156.000,00", "₺108.000,00", "₺48.000,00", "%30.7"],
                ["Profil Boru 40x40", "₺85.250,00", "₺55.800,00", "₺29.450,00", "%34.5"],
                ["Kaynak Teli 1.2mm", "₺25.200,00", "₺15.300,00", "₺9.900,00", "%39.2"]
            ],
            isHeatmap: false,
            needsCari: false
        ),
        ReportItemInfo(
            title: "Müşteri Karlılık Analizi",
            category: "Karlılık",
            description: "Müşteri bazlı kar/zarar analizi.",
            iconName: "person.crop.rectangle.stack.fill",
            headers: ["Müşteri Ünvanı", "Toplam Ciro", "Ürün Maliyeti", "Sağlanan Kâr", "Kâr Oranı"],
            defaultRows: [
                ["Akıncılar Çelik Ltd.", "₺185.000,00", "₺122.000,00", "₺63.000,00", "%34.0"],
                ["Özdemir Makine San.", "₺94.500,00", "₺61.000,00", "₺33.500,00", "%35.4"],
                ["Birlik Hırdavat", "₺42.000,00", "₺26.800,00", "₺15.200,00", "%36.1"]
            ],
            isHeatmap: false,
            needsCari: false
        ),
        ReportItemInfo(
            title: "Detaylı Gelir ve Maliyet Analizi",
            category: "Karlılık",
            description: "Tarih bazlı ürün satışlarının kime yapıldığı, en son kimden ne kadara alındığı ve satır bazlı kâr analizi.",
            iconName: "list.clipboard.fill",
            headers: ["Tarih", "Ürün", "Müşteri", "Satış F.", "Son Alış Tedarikçi", "Son Alış F.", "Fark Kâr"],
            defaultRows: [
                ["03.11.2026", "Paslanmaz Sac", "Akıncılar Çelik", "₺650,00", "Ereğli Demir Çelik", "₺450,00", "+₺200,00 (%30.7)"],
                ["02.11.2026", "Profil Boru", "Özdemir Makine", "₺275,00", "Borusan Mannesmann", "₺180,00", "+₺95,00 (%34.5)"],
                ["01.11.2026", "Kaynak Teli", "Birlik Hırdavat", "₺140,00", "Magmaweld Sanayi", "₺85,00", "+₺55,00 (%39.2)"]
            ],
            isHeatmap: false,
            needsCari: false
        ),
        
        // 6. Stratejik Analiz
        ReportItemInfo(
            title: "Müşteri ABC Analizi",
            category: "Stratejik",
            description: "Ciroya göre müşteri sınıflandırması. A Sınıfı: En yüksek %80, B Sınıfı: Sonraki %15, C Sınıfı: Kalan %5",
            iconName: "a.square.fill",
            headers: ["Sınıf", "Müşteri Ünvanı", "Ciro", "Ciro Payı", "Kümülatif Pay"],
            defaultRows: [
                ["A Sınıfı", "Akıncılar Çelik Ltd.", "₺185.000,00", "%43.1", "%43.1"],
                ["A Sınıfı", "Özdemir Makine San.", "₺94.500,00", "%22.0", "%65.1"],
                ["A Sınıfı", "Doruk İnşaat A.Ş.", "₺65.000,00", "%15.1", "%80.2"],
                ["B Sınıfı", "Birlik Hırdavat", "₺42.000,00", "%9.8", "%90.0"],
                ["C Sınıfı", "Diğer 12 Cari", "₺42.000,00", "%10.0", "%100.0"]
            ],
            isHeatmap: false,
            needsCari: false
        ),
        ReportItemInfo(
            title: "Kar-Zarar Mukayesesi",
            category: "Stratejik",
            description: "Yıllık, aylık ve haftalık bazda performans analizi.",
            iconName: "arrow.left.arrow.right",
            headers: ["Dönem", "Bu Yıl Ciro", "Geçen Yıl Ciro", "Değişim Tutarı", "Büyüme %"],
            defaultRows: [
                ["Ekim", "₺428.500,00", "₺320.000,00", "+₺108.500,00", "+%33.9"],
                ["Eylül", "₺395.000,00", "₺290.000,00", "+₺105.000,00", "+%36.2"],
                ["Ağustos", "₺360.000,00", "₺310.000,00", "+₺50.000,00", "+%16.1"]
            ],
            isHeatmap: false,
            needsCari: false
        ),
        ReportItemInfo(
            title: "Müşteri Kayıp (Churn)",
            category: "Stratejik",
            description: "Kayıp riski olan pasif müşteriler.",
            iconName: "person.crop.circle.badge.exclamationmark",
            headers: ["Müşteri Ünvanı", "Son Sipariş", "Boşta Kalan Gün", "Eski Aylık Hacim", "Risk Seviyesi"],
            defaultRows: [
                ["Asil Otomotiv Ltd.", "12.04.2026", "206 Gün", "₺45.000,00", "YÜKSEK (Kayıp)"],
                ["Güneş Rulman San.", "24.05.2026", "164 Gün", "₺28.000,00", "YÜKSEK (Kayıp)"],
                ["Erler Civata Dağıtım", "08.06.2026", "149 Gün", "₺18.500,00", "ORTA (Riskli)"]
            ],
            isHeatmap: false,
            needsCari: false
        ),
        ReportItemInfo(
            title: "Fiyat Dalgalanma Raporu",
            category: "Stratejik",
            description: "Ürün fiyat değişim trendleri.",
            iconName: "waveform.path.ecg",
            headers: ["Ürün Adı", "3 Ay Önce", "Geçen Ay", "Güncel Fiyat", "Değişim"],
            defaultRows: [
                ["Paslanmaz Sac 2mm", "₺540,00", "₺610,00", "₺650,00", "+%20.3"],
                ["Profil Boru 40x40", "₺220,00", "₺250,00", "₺275,00", "+%25.0"],
                ["Kaynak Teli 1.2mm", "₺110,00", "₺125,00", "₺140,00", "+%27.2"]
            ],
            isHeatmap: false,
            needsCari: false
        ),
        ReportItemInfo(
            title: "Müşteri Sadakat (LTV)",
            category: "Stratejik",
            description: "Müşteri yaşam boyu değer analizi.",
            iconName: "crown.fill",
            headers: ["Müşteri Ünvanı", "Toplam Sipariş", "Toplam Hacim", "Kâr Katkısı", "LTV Skoru"],
            defaultRows: [
                ["Akıncılar Çelik Ltd.", "48 Sipariş", "₺840.000,00", "₺285.000,00", "98/100 (VIP)"],
                ["Özdemir Makine San.", "32 Sipariş", "₺480.000,00", "₺168.000,00", "89/100 (Sadık)"],
                ["Doruk İnşaat A.Ş.", "19 Sipariş", "₺320.000,00", "₺112.000,00", "78/100 (İyi)"]
            ],
            isHeatmap: false,
            needsCari: false
        ),
        ReportItemInfo(
            title: "Finansal Isı Haritası",
            category: "Stratejik",
            description: "Günlük finansal aktivite yoğunluğu.",
            iconName: "square.grid.3x3.fill",
            headers: ["Tarih", "Satış", "Alış", "Kasa Giriş", "Kasa Çıkış", "Net Akış"],
            defaultRows: [
                ["04.11.2026", "₺24.500", "₺12.000", "₺5.000", "₺2.500", "+₺15.000"],
                ["03.11.2026", "₺18.200", "₺15.000", "₺2.000", "₺1.800", "+₺3.400"],
                ["02.11.2026", "₺12.000", "₺22.000", "₺4.000", "₺3.000", "-₺9.000"],
                ["01.11.2026", "₺35.000", "₺8.000", "₺6.000", "₺1.000", "+₺32.000"]
            ],
            isHeatmap: true,
            needsCari: false
        ),
        ReportItemInfo(
            title: "Tahsilat Süresi (DSO)",
            category: "Stratejik",
            description: "Ortalama tahsilat hızı (gün).",
            iconName: "timer",
            headers: ["Müşteri Grubu", "Ortalama Vade", "Fiili Tahsilat", "DSO (Gün)", "Hedef Vade"],
            defaultRows: [
                ["Toptan Müşteriler", "45 Gün", "52 Gün", "52 Gün", "45 Gün"],
                ["Perakende Satışlar", "Peşin / KK", "2 Gün", "2 Gün", "Peşin"],
                ["İnşaat / Proje Grubu", "60 Gün", "78 Gün", "78 Gün (Risk)", "60 Gün"]
            ],
            isHeatmap: false,
            needsCari: false
        ),
        ReportItemInfo(
            title: "Bütçe / Hedef Takibi",
            category: "Stratejik",
            description: "Aylık hedeflere ulaşma durumu.",
            iconName: "target",
            headers: ["Hedef Kalemi", "Aylık Hedef", "Gerçekleşen", "Kalan", "Başarı %"],
            defaultRows: [
                ["Aylık Toplam Ciro", "₺500.000,00", "₺428.500,00", "₺71.500,00", "%85.7"],
                ["Nakit Tahsilat", "₺250.000,00", "₺247.500,00", "₺2.500,00", "%99.0"],
                ["Yeni Müşteri Kazanımı", "10 Firma", "8 Firma", "2 Firma", "%80.0"]
            ],
            isHeatmap: false,
            needsCari: false
        )
    ]
    
    private let categories = ["Genel Durum", "Finans", "Cari Hesap", "Stok", "Satış", "Karlılık", "Stratejik"]
    
    // Sample cariler for the overlay picker
    private let sampleCariler = [
        "Akıncılar Çelik Ltd. Şti.",
        "Özdemir Makine Sanayi",
        "Tekin Metal A.Ş.",
        "Kuzey Yapı Market",
        "Birlik Hırdavat",
        "Doruk İnşaat A.Ş.",
        "Demir Grup Sanayi"
    ]
    
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
                    headerView
                    dateFilterView
                    searchBarView
                    reportsListView
                }
            }
            .navigationBarHidden(true)
            .sheet(isPresented: $isCariOverlayOpen) {
                cariSelectionSheet
            }
        }
    }
    
    // MARK: - Header
    private var headerView: some View {
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
    }
    
    // MARK: - Date Filter Buttons [Tümü | Haftalık | Aylık | Yıllık]
    private var dateFilterView: some View {
        HStack(spacing: 8) {
            filterBtn(title: "Tümü", key: "All")
            filterBtn(title: "Haftalık", key: "Weekly")
            filterBtn(title: "Aylık", key: "Monthly")
            filterBtn(title: "Yıllık", key: "Yearly")
        }
        .padding(.horizontal, 16)
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
    
    // MARK: - Search Bar
    private var searchBarView: some View {
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
    }
    
    // MARK: - Reports List Grouped by Categories
    private var reportsListView: some View {
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
                                    if r.needsCari {
                                        Button {
                                            selectedReport = r
                                            isCariOverlayOpen = true
                                        } label: {
                                            reportRow(r: r)
                                        }
                                        .buttonStyle(.plain)
                                    } else {
                                        NavigationLink(destination: RaporDetayInteractiveView(report: r, dateFilter: selectedFilter, cariName: nil)) {
                                            reportRow(r: r)
                                        }
                                        .buttonStyle(.plain)
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
    
    // MARK: - Cari Selection Sheet for Cari Hareket Dökümü
    private var cariSelectionSheet: some View {
        NavigationStack {
            ZStack {
                Color(hex: "0A0A0A").ignoresSafeArea()
                
                VStack(spacing: 12) {
                    // Search bar
                    HStack(spacing: 8) {
                        Image(systemName: "magnifyingglass").foregroundColor(Color(hex: "64748B"))
                        TextField("Cari ara...", text: $cariSearch)
                            .foregroundColor(.white)
                    }
                    .padding(12)
                    .background(Color(hex: "161616"))
                    .cornerRadius(12)
                    .padding(.horizontal, 16)
                    
                    List {
                        ForEach(sampleCariler.filter { cariSearch.isEmpty || $0.localizedCaseInsensitiveContains(cariSearch) }, id: \.self) { c in
                            Button {
                                selectedCariName = c
                                isCariOverlayOpen = false
                            } label: {
                                HStack {
                                    Text(c)
                                        .font(.system(size: 14, weight: .semibold))
                                        .foregroundColor(.white)
                                    Spacer()
                                    Image(systemName: "chevron.right")
                                        .font(.system(size: 12))
                                        .foregroundColor(Color(hex: "64748B"))
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

// MARK: - Interactive Report Detail View (100% exact to RaporDetayScreen.tsx)
public struct RaporDetayInteractiveView: View {
    @Environment(\.presentationMode) var presentationMode
    public let report: ReportItemInfo
    public let dateFilter: String
    public let cariName: String?
    
    @State private var showPDFModal: Bool = false
    @State private var generatedPDFData: Data? = nil
    
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
    
    @State private var days: [DailyFlow] = (1...30).map { i in
        DailyFlow(
            day: "\(i)",
            date: "\(String(format: "%02d", i)).10.2026",
            satis: Double(15000 + (i * 1234) % 30000),
            alis: Double(8000 + (i * 987) % 25000),
            kasaIn: Double(3000 + (i * 456) % 10000),
            kasaOut: Double(2000 + (i * 321) % 8000)
        )
    }
    
    @State private var selectedDay: DailyFlow? = nil
    
    public var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Top Navigation Bar
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
                        HStack(spacing: 4) {
                            Text("Dönem: \(dateFilter == "All" ? "Tüm Zamanlar" : dateFilter)")
                            if let c = cariName {
                                Text("• \(c)")
                            }
                        }
                        .font(.system(size: 11))
                        .foregroundColor(Color(hex: "8E8E93"))
                        .lineLimit(1)
                    }
                    
                    Spacer()
                    
                    // PDF Aç Butonu
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
                    
                    // Share / PDF Button
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
                        // If Heatmap Report: Show 3 KPI Cards + 30 Cells Grid + Day Detail Card
                        if report.isHeatmap {
                            renderHeatmapSection()
                        }
                        
                        // Full Dynamic Table (headers + rows)
                        renderTableSection()
                        
                        Spacer().frame(height: 50)
                    }
                    .padding(16)
                }
            }
        }
        .navigationBarHidden(true)
        .sheet(isPresented: $showPDFModal) {
            if let data = generatedPDFData {
                PDFViewerModal(
                    title: report.title,
                    pdfData: data,
                    fileName: "\(report.title.replacingOccurrences(of: " ", with: "_"))_\(dateFilter).pdf"
                )
            }
        }
    }
    
    // MARK: - Heatmap Section
    @ViewBuilder
    private func renderHeatmapSection() -> some View {
        VStack(alignment: .leading, spacing: 12) {
            // 3 KPI Cards
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
    
    // MARK: - Dynamic Table Section (Matching RaporDetayScreen.tsx)
    @ViewBuilder
    private func renderTableSection() -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Tablo Rapor Dökümü")
                .font(.system(size: 13, weight: .bold))
                .foregroundColor(.white)
            
            // Horizontal Table Scroll
            ScrollView(.horizontal, showsIndicators: false) {
                VStack(alignment: .leading, spacing: 0) {
                    // Header Row
                    HStack(spacing: 0) {
                        ForEach(Array(report.headers.enumerated()), id: \.offset) { _, header in
                            Text(header)
                                .font(.system(size: 12, weight: .bold))
                                .foregroundColor(Color(hex: "60A5FA"))
                                .frame(width: 130, alignment: .leading)
                                .padding(.vertical, 8)
                                .padding(.horizontal, 6)
                        }
                    }
                    .background(Color.white.opacity(0.05))
                    .cornerRadius(6)
                    
                    Divider().background(Color.white.opacity(0.1))
                    
                    // Rows
                    ForEach(Array(report.defaultRows.enumerated()), id: \.offset) { rowIndex, row in
                        HStack(spacing: 0) {
                            ForEach(Array(row.enumerated()), id: \.offset) { colIndex, cell in
                                Text(cell)
                                    .font(.system(size: 12, weight: colIndex == 0 ? .semibold : .regular))
                                    .foregroundColor(cellColor(cell: cell, colIndex: colIndex))
                                    .frame(width: 130, alignment: .leading)
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
        .padding(16)
        .background(Color(hex: "121216"))
        .cornerRadius(18)
        .overlay(RoundedRectangle(cornerRadius: 18).stroke(Color.white.opacity(0.08), lineWidth: 1))
    }
    
    private func cellColor(cell: String, colIndex: Int) -> Color {
        if cell.contains("+") || cell.contains("Borçlu") || cell.contains("Kâr") {
            return Color(hex: "10B981")
        } else if cell.contains("-") || cell.contains("Alacaklı") || cell.contains("Zarar") || cell.contains("Kritik") || cell.contains("Risk") {
            return Color(hex: "EF4444")
        }
        return .white
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
    
    private func openPDF() {
        #if canImport(UIKit)
        if let pdfData = PDFService.shared.generateReportPDF(
            title: report.title,
            category: report.category,
            headers: report.headers,
            rows: report.defaultRows,
            dateFilter: dateFilter,
            cariName: cariName,
            isHeatmap: report.isHeatmap
        ) {
            self.generatedPDFData = pdfData
            self.showPDFModal = true
        }
        #endif
    }
    
    private func shareReport() {
        #if canImport(UIKit)
        if let pdfData = PDFService.shared.generateReportPDF(
            title: report.title,
            category: report.category,
            headers: report.headers,
            rows: report.defaultRows,
            dateFilter: dateFilter,
            cariName: cariName,
            isHeatmap: report.isHeatmap
        ) {
            let safeName = report.title.replacingOccurrences(of: " ", with: "_")
            let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent("\(safeName)_\(dateFilter).pdf")
            do {
                try pdfData.write(to: tempURL)
                let av = UIActivityViewController(activityItems: [tempURL], applicationActivities: nil)
                if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                   let rootVC = windowScene.windows.first?.rootViewController {
                    if let popover = av.popoverPresentationController {
                        popover.sourceView = rootVC.view
                        popover.sourceRect = CGRect(x: rootVC.view.bounds.midX, y: rootVC.view.bounds.midY, width: 0, height: 0)
                        popover.permittedArrowDirections = []
                    }
                    rootVC.present(av, animated: true)
                }
            } catch {
                print("PDF paylaşım hatası: \(error)")
            }
        }
        #endif
    }
}
