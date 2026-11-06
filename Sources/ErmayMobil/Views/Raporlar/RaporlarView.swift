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
            headers: ["Rapor Kalemi", "Tutar / Değer"],
            defaultRows: [
                ["Toplam Alacaklar", "₺485.250,00"],
                ["Toplam Borçlar", "₺192.400,00"],
                ["Kasa ve Banka Mevcudu", "₺215.300,00"],
                ["Toplam Stok Miktarı", "1.420 Adet"],
                ["Stok Maliyet Değeri", "₺380.000,00"],
                ["Net İşletme Sermayesi", "₺508.150,00"]
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
            headers: ["Ay/Yıl", "Nakit (Alınan)", "Nakit (Yönl.)", "K.Kartı (Alınan)", "K.Kartı (Yönl.)", "Havale (Alınan)", "Havale (Yönl.)", "Çek (Alınan)", "Çek (Yönl.)"],
            defaultRows: [
                ["11/2026", "₺45.000,00", "₺12.000,00", "₺82.500,00", "₺15.000,00", "₺120.000,00", "₺60.000,00", "₺35.000,00", "₺10.000,00"],
                ["10/2026", "₺52.000,00", "₺18.500,00", "₺76.000,00", "₺11.200,00", "₺98.000,00", "₺45.000,00", "₺50.000,00", "₺22.000,00"],
                ["09/2026", "₺38.500,00", "₺9.400,00", "₺69.000,00", "₺8.500,00", "₺105.000,00", "₺52.000,00", "₺40.000,00", "₺15.000,00"]
            ],
            isHeatmap: false,
            needsCari: false
        ),
        ReportItemInfo(
            title: "Kredi Kartı Detay Raporu",
            category: "Finans",
            description: "Kaydedilen ve yönlendirilen kredi kartı işlem detayları.",
            iconName: "creditcard.fill",
            headers: ["Tarih", "Kimden Alındı", "Banka/Kart", "Kime Yönlendirildi", "Tutar", "Durum"],
            defaultRows: [
                ["03.11.2026", "Akıncılar Çelik Ltd.", "Garanti POS", "Özdemir Sanayi", "₺14.500,00", "Yönlendirildi"],
                ["02.11.2026", "Özdemir Makine", "Yapı Kredi", "-", "₺8.200,00", "Portföyde"],
                ["01.11.2026", "Tekin Metal A.Ş.", "İş Bankası", "-", "₺22.000,00", "Tahsil Edildi"]
            ],
            isHeatmap: false,
            needsCari: false
        ),
        ReportItemInfo(
            title: "Nakit İşlem Detay Raporu",
            category: "Finans",
            description: "Tüm nakit kasa hareketlerinin detaylı dökümü.",
            iconName: "banknote.fill",
            headers: ["Tarih", "Cari Ünvan", "İşlem", "Açıklama", "Giren", "Çıkan"],
            defaultRows: [
                ["04.11.2026 14:30", "Merkez Kasa", "Nakit Tahsilat", "Elden Satış Tahsilatı", "₺5.000,00", "₺0,00"],
                ["03.11.2026 11:15", "Merkez Kasa", "Nakit Tediye", "Yemek & İkram Gideri", "₺0,00", "₺450,00"],
                ["02.11.2026 16:45", "Şube Kasası", "Nakit Tahsilat", "Cari Fatura Tahsilatı", "₺12.000,00", "₺0,00"]
            ],
            isHeatmap: false,
            needsCari: false
        ),
        ReportItemInfo(
            title: "Çek Detay Raporu",
            category: "Finans",
            description: "Portföydeki ve işlem görmüş çeklerin detayları.",
            iconName: "doc.plaintext.fill",
            headers: ["Vade", "Çek No", "Cari Ünvan", "Banka/Şube", "Tutar", "Durum"],
            defaultRows: [
                ["15.11.2026", "ÇK-10928", "Doruk İnşaat A.Ş.", "Garanti BBVA / Maslak", "₺35.000,00", "Portföyde"],
                ["28.11.2026", "ÇK-10929", "Kuzey Çelik San.", "Akbank / Dudullu", "₺50.000,00", "Portföyde"],
                ["05.12.2026", "ÇK-10930", "Yıldız Ticaret", "Yapı Kredi / İkitelli", "₺27.500,00", "Tahsile Verildi"]
            ],
            isHeatmap: false,
            needsCari: false
        ),
        ReportItemInfo(
            title: "Havale / EFT Detay Raporu",
            category: "Finans",
            description: "Banka havale ve EFT işlemlerinin detaylı listesi.",
            iconName: "building.columns.fill",
            headers: ["Tarih", "Müşteri", "Banka/Hesap", "Dekont No", "Tutar", "Durum"],
            defaultRows: [
                ["03.11.2026", "Demir Grup Sanayi", "İş Bankası Ticari", "DK-10023", "₺45.000,00", "Onaylandı"],
                ["02.11.2026", "Yılmazlar Nakliyat", "Garanti BBVA TL", "DK-10024", "₺6.800,00", "Onaylandı"],
                ["01.11.2026", "Birlik Makine A.Ş.", "Akbank Şirket", "DK-10025", "₺80.000,00", "Onaylandı"]
            ],
            isHeatmap: false,
            needsCari: false
        ),
        ReportItemInfo(
            title: "Gelir Tablosu",
            category: "Finans",
            description: "Dönemsel gelir ve gider özeti.",
            iconName: "chart.pie.fill",
            headers: ["Kalem", "Tutar"],
            defaultRows: [
                ["Brüt Satış Gelirleri", "₺1.850.000,00"],
                ["Satış İndirimleri ve İadeler (-)", "₺42.500,00"],
                ["Net Satışlar", "₺1.807.500,00"],
                ["Satılan Malın Maliyeti (SMM) (-)", "₺1.310.000,00"],
                ["BRÜT SATIŞ KÂRI", "₺497.500,00"],
                ["Faaliyet Giderleri (-)", "₺145.000,00"],
                ["FAALİYET KÂRI (EBIT)", "₺352.500,00"],
                ["DÖNEM NET KÂRI", "₺320.500,00"]
            ],
            isHeatmap: false,
            needsCari: false
        ),
        ReportItemInfo(
            title: "Nakit Akış Tablosu",
            category: "Finans",
            description: "Nakit giriş ve çıkışlarının takibi.",
            iconName: "arrow.triangle.swap",
            headers: ["Tarih", "Açıklama", "Giren", "Çıkan", "Bakiye"],
            defaultRows: [
                ["04.11.2026", "Akıncılar Fatura Tahsilatı", "₺48.500,00", "₺0,00", "₺215.300,00"],
                ["03.11.2026", "Tedarikçi Mal Alımı Ödemesi", "₺0,00", "₺32.000,00", "₺166.800,00"],
                ["02.11.2026", "Özdemir Makine Nakit Tahsilat", "₺15.000,00", "₺0,00", "₺198.800,00"]
            ],
            isHeatmap: false,
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
                ["Akıncılar Çelik Ltd.", "İstanbul", "₺0,00", "₺142.500,00", "₺142.500,00", "Alacaklı (+)"],
                ["Özdemir Makine San.", "Bursa", "₺35.200,00", "₺0,00", "₺35.200,00", "Borçlu (-)"],
                ["Doruk İnşaat A.Ş.", "Ankara", "₺0,00", "₺88.000,00", "₺88.000,00", "Alacaklı (+)"]
            ],
            isHeatmap: false,
            needsCari: false
        ),
        ReportItemInfo(
            title: "Cari Hareket Dökümü",
            category: "Cari Hesap",
            description: "Cari hesapların işlem detayları.",
            iconName: "clock.arrow.circlepath",
            headers: ["Tarih", "İşlem Türü", "Evrak No", "Açıklama", "Borç", "Alacak", "Bakiye"],
            defaultRows: [
                ["04.11.2026", "Satış Faturası", "MB-FTR-101", "Demir & Profil Satışı", "₺48.500,00", "₺0,00", "₺48.500,00"],
                ["02.11.2026", "Banka Tahsilat", "EFT-8812", "Cari Hesap Tahsilatı", "₺0,00", "₺25.000,00", "₺23.500,00"],
                ["28.10.2026", "Satış Faturası", "MB-FTR-098", "Kaynak Teli ve Sac", "₺32.000,00", "₺0,00", "₺55.500,00"]
            ],
            isHeatmap: false,
            needsCari: true
        ),
        ReportItemInfo(
            title: "Yaşlandırma Raporu",
            category: "Cari Hesap",
            description: "Borç/alacak yaşlandırma analizi.",
            iconName: "hourglass",
            headers: ["Ünvan", "0-30 Gün", "31-60 Gün", "61-90 Gün", "90+ Gün", "Toplam"],
            defaultRows: [
                ["Akıncılar Çelik Ltd.", "₺65.000,00", "₺45.000,00", "₺22.500,00", "₺10.000,00", "₺142.500,00"],
                ["Doruk İnşaat A.Ş.", "₺40.000,00", "₺28.000,00", "₺15.000,00", "₺5.000,00", "₺88.000,00"],
                ["Tekin Metal San.", "₺25.000,00", "₺18.000,00", "₺8.400,00", "₺0,00", "₺51.400,00"]
            ],
            isHeatmap: false,
            needsCari: false
        ),
        ReportItemInfo(
            title: "Hareketsiz Cariler",
            category: "Cari Hesap",
            description: "İşlem görmeyen cari hesaplar.",
            iconName: "person.fill.xmark",
            headers: ["Ünvan", "Grup", "Telefon", "Son İşlem", "Gün"],
            defaultRows: [
                ["Asil Otomotiv Sanayi", "Müşteri", "0212 555 12 34", "12.04.2026", "206 Gün"],
                ["Güneş Rulman Ltd.", "Müşteri", "0216 444 88 99", "24.05.2026", "164 Gün"],
                ["Erler Civata Dağıtım", "Müşteri", "0224 333 11 22", "08.06.2026", "149 Gün"]
            ],
            isHeatmap: false,
            needsCari: false
        ),
        ReportItemInfo(
            title: "Vadesi Geçmiş Alacaklar",
            category: "Cari Hesap",
            description: "Ödeme süresi geçmiş tahsilatlar.",
            iconName: "bell.badge.fill",
            headers: ["Müşteri", "Cari Bakiyesi", "Ort. Gecikme Günü", "Fatura / Evrak No", "Fatura Bakiyesi", "Gecikme (Gün)"],
            defaultRows: [
                ["Akıncılar Çelik Ltd.", "₺142.500,00", "28 Gün", "MB-FTR-082", "₺35.000,00", "32 Gün"],
                ["Doruk İnşaat A.Ş.", "₺88.000,00", "19 Gün", "MB-FTR-089", "₺28.000,00", "24 Gün"],
                ["Güneş Rulman Ltd.", "₺54.500,00", "45 Gün", "MB-FTR-074", "₺18.500,00", "52 Gün"]
            ],
            isHeatmap: false,
            needsCari: false
        ),
        
        // 4. Stok
        ReportItemInfo(
            title: "Stok Mevcudu",
            category: "Stok",
            description: "Güncel stok miktarları ve değerleri.",
            iconName: "cube.box.fill",
            headers: ["Stok Kodu", "Stok Adı", "Kategori", "Miktar", "Ort. Alış F.", "Ort. Satış F.", "Satış F."],
            defaultRows: [
                ["STK-001", "Paslanmaz Çelik Sac 2mm", "Sac Grubu", "450 Adet", "₺480,00", "₺620,00", "₺650,00"],
                ["STK-002", "Sanayi Profil Boru 40x40", "Profil", "820 Metre", "₺195,00", "₺260,00", "₺275,00"],
                ["STK-003", "Gazaltı Kaynak Teli 1.2mm", "Kaynak", "150 Makara", "₺95,00", "₺130,00", "₺140,00"]
            ],
            isHeatmap: false,
            needsCari: false
        ),
        ReportItemInfo(
            title: "Stok Hareketleri",
            category: "Stok",
            description: "Giriş-çıkış stok hareket dökümü.",
            iconName: "arrow.left.arrow.right",
            headers: ["Tarih", "Stok Adı", "İşlem", "Giren", "Çıkan", "Birim Fiyat", "Kalan"],
            defaultRows: [
                ["04.11.2026", "Paslanmaz Sac 2mm", "Satış Faturası", "0", "50", "₺650,00", "450"],
                ["03.11.2026", "Profil Boru 40x40", "Satış Faturası", "0", "120", "₺275,00", "820"],
                ["01.11.2026", "Kaynak Teli 1.2mm", "Alış Faturası", "100", "0", "₺95,00", "150"]
            ],
            isHeatmap: false,
            needsCari: false
        ),
        ReportItemInfo(
            title: "Kritik Stok Seviyesi",
            category: "Stok",
            description: "Minimum seviyenin altındaki ürünler.",
            iconName: "exclamationmark.triangle.fill",
            headers: ["Stok Kodu", "Stok Adı", "Mevcut", "Min. Seviye", "Durum", "Satış Fiyatı"],
            defaultRows: [
                ["STK-008", "Kare Profil 50x50x3", "8 Adet", "25 Adet", "KRİTİK (-17)", "₺420,00"],
                ["STK-014", "Elektrot 3.25mm Askaynak", "5 Paket", "20 Paket", "KRİTİK (-15)", "₺380,00"],
                ["STK-022", "Kesici Taş 180x3 Karbosan", "12 Adet", "50 Adet", "KRİTİK (-38)", "₺65,00"]
            ],
            isHeatmap: false,
            needsCari: false
        ),
        ReportItemInfo(
            title: "Ölü Stok Raporu",
            category: "Stok",
            description: "Çakışan veya hareketsiz stok kartları.",
            iconName: "archivebox.fill",
            headers: ["Stok Adı", "Barkod", "Stok Kodu", "Mevcut Miktar", "Çakışma Nedeni"],
            defaultRows: [
                ["Çelik Lama 30x5mm", "869000100234", "STK-112", "180 Metre", "6 Aydır Hareket Görmedi"],
                ["T-Demiri 40x40", "869000100567", "STK-145", "65 Adet", "8 Aydır Hareket Görmedi"]
            ],
            isHeatmap: false,
            needsCari: false
        ),
        ReportItemInfo(
            title: "Stok Devir Hızı",
            category: "Stok",
            description: "Stokların dönüşüm hızı analizi.",
            iconName: "chart.line.uptrend.xyaxis",
            headers: ["Stok Adı", "Mevcut Stok", "Toplam Satış (Çıkan)", "Stok Devir Hızı", "Kategori"],
            defaultRows: [
                ["Paslanmaz Sac 2mm", "450 Adet", "1.250 Adet", "2.78 / Yıl", "Sac Grubu"],
                ["Profil Boru 40x40", "820 Metre", "3.400 Metre", "4.15 / Yıl", "Profil"]
            ],
            isHeatmap: false,
            needsCari: false
        ),
        
        // 5. Satış
        ReportItemInfo(
            title: "Satış Faturası Dökümü",
            category: "Satış",
            description: "Kesilen satış faturalarının listesi.",
            iconName: "doc.text.fill",
            headers: ["Fatura No", "Tarih", "Müşteri", "Ara Toplam", "KDV", "Genel Toplam"],
            defaultRows: [
                ["MB-FTR-101", "04.11.2026", "Akıncılar Çelik Ltd.", "₺40.416,67", "₺8.083,33", "₺48.500,00"],
                ["MB-FTR-098", "28.10.2026", "Doruk İnşaat A.Ş.", "₺26.666,67", "₺5.333,33", "₺32.000,00"]
            ],
            isHeatmap: false,
            needsCari: false
        ),
        ReportItemInfo(
            title: "En Çok Satan Ürünler",
            category: "Satış",
            description: "Satış adedine göre top listeler.",
            iconName: "star.fill",
            headers: ["Sıra", "Ürün Adı", "Mevcut Stok", "Satış Fiyatı", "Kategori"],
            defaultRows: [
                ["1", "Sanayi Profil Boru 40x40", "820 Metre", "₺275,00", "Profil"],
                ["2", "Paslanmaz Çelik Sac 2mm", "450 Adet", "₺650,00", "Sac Grubu"],
                ["3", "Gazaltı Kaynak Teli 1.2mm", "150 Makara", "₺140,00", "Kaynak"]
            ],
            isHeatmap: false,
            needsCari: false
        ),
        
        // 6. Karlılık
        ReportItemInfo(
            title: "Ürün Karlılık Raporu",
            category: "Karlılık",
            description: "Ürün bazlı kar/zarar analizi.",
            iconName: "tag.fill",
            headers: ["Ürün Adı", "Alış Fiyatı", "Satış Fiyatı", "Kar", "Kar Marjı %"],
            defaultRows: [
                ["Paslanmaz Çelik Sac 2mm", "₺480,00", "₺650,00", "₺170,00", "%26.2"],
                ["Sanayi Profil Boru 40x40", "₺195,00", "₺275,00", "₺80,00", "%29.1"]
            ],
            isHeatmap: false,
            needsCari: false
        ),
        ReportItemInfo(
            title: "Müşteri Karlılık Analizi",
            category: "Karlılık",
            description: "Müşteri bazlı kar/zarar analizi.",
            iconName: "person.crop.circle.badge.checkmark",
            headers: ["Müşteri", "Toplam Satış", "Tahmini Maliyet", "Net Kar", "Kar Marjı (%)", "Fatura Sayısı"],
            defaultRows: [
                ["Akıncılar Çelik Ltd.", "₺840.000,00", "₺610.000,00", "₺230.000,00", "%27.4", "18 Fatura"],
                ["Özdemir Makine San.", "₺480.000,00", "₺345.000,00", "₺135.000,00", "%28.1", "12 Fatura"]
            ],
            isHeatmap: false,
            needsCari: false
        ),
        ReportItemInfo(
            title: "Detaylı Gelir ve Maliyet Analizi",
            category: "Karlılık",
            description: "Satır bazlı ürün maliyet ve kâr analizi.",
            iconName: "tablecells",
            headers: ["Tarih", "Ürün Adı", "Müşteri (Kime)", "Miktar", "Satış Fiyatı", "Tutar (Net/KDV)", "Tahsilat Yöntemi & Süresi", "En Son Tedarikçi", "Alış Fiyatı & Değişim", "Maliyet", "Net Kar & Durum", "Marj", "Ödeme Yöntemi & Süresi"],
            defaultRows: [
                ["04.11.2026", "Paslanmaz Sac 2mm", "Akıncılar Çelik Ltd.", "50 Adet", "₺650,00", "₺32.500 (+KDV)", "Nakit • 0 Gün", "Ereğli Demir Çelik", "₺480,00 (%0)", "₺24.000,00", "₺8.500 (Kâr)", "%26.2", "Vadeli • 30 Gün"],
                ["03.11.2026", "Profil Boru 40x40", "Özdemir Makine", "120 Metre", "₺275,00", "₺33.000 (+KDV)", "Kredi Kartı • 1 Gün", "Borusan Mannesmann", "₺195,00 (+%4)", "₺23.400,00", "₺9.600 (Kâr)", "%29.1", "Peşin • 0 Gün"]
            ],
            isHeatmap: false,
            needsCari: false
        ),
        
        // 7. Stratejik
        ReportItemInfo(
            title: "Müşteri ABC Analizi",
            category: "Stratejik",
            description: "Ciroya göre müşteri sınıflandırması.",
            iconName: "chart.bar.xaxis",
            headers: ["Müşteri", "Toplam Satış", "Yüzde", "Sınıf"],
            defaultRows: [
                ["Akıncılar Çelik Ltd.", "₺840.000,00", "%45.4", "A Sınıfı (Önemli)"],
                ["Özdemir Makine San.", "₺480.000,00", "%25.9", "A Sınıfı (Önemli)"],
                ["Doruk İnşaat A.Ş.", "₺320.000,00", "%17.3", "B Sınıfı (Orta)"]
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
            headers: ["Müşteri", "Son İşlem", "Geçen Gün", "Kayıp Riski"],
            defaultRows: [
                ["Asil Otomotiv Ltd.", "12.04.2026", "206 Gün", "YÜKSEK (Kayıp)"],
                ["Güneş Rulman San.", "24.05.2026", "164 Gün", "YÜKSEK (Kayıp)"],
                ["Erler Civata Dağıtım", "08.06.2026", "149 Gün", "ORTA (Riskli)"]
            ],
            isHeatmap: false,
            needsCari: false
        ),
        ReportItemInfo(
            title: "Fiyat Dalgalanma Raporu",
            category: "Stratejik",
            description: "Ürün fiyat değişim trendleri.",
            iconName: "waveform.path.ecg",
            headers: ["Ürün", "Min Fiyat", "Max Fiyat", "Ort Fiyat", "Fark %"],
            defaultRows: [
                ["Paslanmaz Sac 2mm", "₺540,00", "₺650,00", "₺595,00", "+%20.3"],
                ["Profil Boru 40x40", "₺220,00", "₺275,00", "₺247,50", "+%25.0"],
                ["Kaynak Teli 1.2mm", "₺110,00", "₺140,00", "₺125,00", "+%27.2"]
            ],
            isHeatmap: false,
            needsCari: false
        ),
        ReportItemInfo(
            title: "Müşteri Sadakat (LTV)",
            category: "Stratejik",
            description: "Müşteri yaşam boyu değer analizi.",
            iconName: "crown.fill",
            headers: ["Müşteri", "İlk Alışveriş", "Son Alışveriş", "Toplam Harcama", "Ortalama Sepet"],
            defaultRows: [
                ["Akıncılar Çelik Ltd.", "14.02.2024", "04.11.2026", "₺840.000,00", "₺46.666,67"],
                ["Özdemir Makine San.", "18.06.2024", "03.11.2026", "₺480.000,00", "₺40.000,00"],
                ["Doruk İnşaat A.Ş.", "10.09.2024", "28.10.2026", "₺320.000,00", "₺40.000,00"]
            ],
            isHeatmap: false,
            needsCari: false
        ),
        ReportItemInfo(
            title: "Finansal Isı Haritası",
            category: "Stratejik",
            description: "Günlük finansal aktivite yoğunluğu.",
            iconName: "square.grid.3x3.fill",
            headers: ["Tarih", "Satış", "Alış", "Kasa Giren", "Kasa Çıkan", "Net Akış"],
            defaultRows: [
                ["04.11.2026", "₺24.500,00", "₺12.000,00", "₺5.000,00", "₺2.500,00", "+₺15.000,00"],
                ["03.11.2026", "₺18.200,00", "₺15.000,00", "₺2.000,00", "₺1.800,00", "+₺3.400,00"],
                ["02.11.2026", "₺12.000,00", "₺22.000,00", "₺4.000,00", "₺3.000,00", "-₺9.000,00"]
            ],
            isHeatmap: true,
            needsCari: false
        ),
        ReportItemInfo(
            title: "Tahsilat Süresi (DSO)",
            category: "Stratejik",
            description: "Ortalama tahsilat hızı (gün).",
            iconName: "speedometer",
            headers: ["Müşteri", "Ortalama Tahsilat Süresi (Gün)", "Toplam Alacak", "Durum"],
            defaultRows: [
                ["Akıncılar Çelik Ltd.", "28 Gün", "₺142.500,00", "Normal (Vadesinde)"],
                ["Doruk İnşaat A.Ş.", "34 Gün", "₺88.000,00", "Kabul Edilebilir"],
                ["Güneş Rulman San.", "52 Gün", "₺54.500,00", "Gecikmeli (Riskli)"]
            ],
            isHeatmap: false,
            needsCari: false
        ),
        ReportItemInfo(
            title: "Bütçe / Hedef Takibi",
            category: "Stratejik",
            description: "Aylık hedeflere ulaşma durumu.",
            iconName: "target",
            headers: ["Dönem (Ay)", "Hedeflenen Ciro", "Gerçekleşen Satış", "Fark", "Başarı Oranı %"],
            defaultRows: [
                ["Kasım (Hedef)", "₺450.000,00", "₺95.000,00", "-₺355.000,00", "%21.1"],
                ["Ekim 2026", "₺400.000,00", "₺428.500,00", "+₺28.500,00", "%107.1"],
                ["Eylül 2026", "₺380.000,00", "₺395.000,00", "+₺15.000,00", "%103.9"]
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
    @State private var liveRows: [[String]] = []
    @State private var isLoadingData: Bool = false
    
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
    
    public var activeRows: [[String]] {
        liveRows
    }
    
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
                    
                    if isLoadingData {
                        ProgressView().tint(.white).padding(.trailing, 4)
                    }
                    
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
        .task {
            await loadLiveReportData()
        }
        .onReceive(NotificationCenter.default.publisher(for: .supabaseRealtimeDataChanged)) { _ in
            Task {
                await loadLiveReportData()
            }
        }
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
    
    // MARK: - Live Database Data Loader
    private func loadLiveReportData() async {
        isLoadingData = true
        defer { isLoadingData = false }
        
        let calculated = await ReportCalculationService.shared.calculateReport(
            report: report,
            dateFilter: dateFilter,
            cariName: cariName
        )
        
        await MainActor.run {
            self.liveRows = calculated.rows
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
                .font(.system(size: 13, weight: .bold))
                .foregroundColor(.white)
            
            // 5 columns x 6 rows Grid
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
                            Text(day.net >= 0 ? "+\(kVal)k" : "-\(kVal)k")
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
            
            // Selected Day Card
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
                Text("Dinamik Canlı Veri")
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundColor(Color(hex: "00FF87"))
            }
            
            ScrollView(.horizontal, showsIndicators: false) {
                VStack(alignment: .leading, spacing: 0) {
                    // Header Row
                    HStack(spacing: 0) {
                        ForEach(report.headers, id: \.self) { h in
                            Text(h)
                                .font(.system(size: 11, weight: .bold))
                                .foregroundColor(Color(hex: "8E8E93"))
                                .frame(width: 130, alignment: .leading)
                                .padding(.vertical, 8)
                                .padding(.horizontal, 6)
                        }
                    }
                    .background(Color.white.opacity(0.05))
                    .cornerRadius(6)
                    
                    Divider().background(Color.white.opacity(0.1))
                    
                    // Dynamic Rows
                    ForEach(Array(activeRows.enumerated()), id: \.offset) { rowIndex, row in
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
        Task { @MainActor in
            if let pdfData = await PDFService.shared.fetchOrGenerateReportPDF(
                title: report.title,
                category: report.category,
                headers: report.headers,
                rows: activeRows,
                dateFilter: dateFilter,
                cariName: cariName,
                isHeatmap: report.isHeatmap
            ) {
                self.generatedPDFData = pdfData
                self.showPDFModal = true
            }
        }
        #endif
    }
    
    private func shareReport() {
        #if canImport(UIKit)
        Task { @MainActor in
            if let pdfData = await PDFService.shared.fetchOrGenerateReportPDF(
                title: report.title,
                category: report.category,
                headers: report.headers,
                rows: activeRows,
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
        }
        #endif
    }
}
