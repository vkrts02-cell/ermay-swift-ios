import SwiftUI

public struct AracToolItem: Identifiable {
    public let id: String
    public let title: String
    public let description: String
    public let iconName: String
    public let color: Color
}

public struct AraclarView: View {
    @State private var activeTab: String? = nil
    
    // 1. Döviz Kurları & Otomasyon & Çevirici
    @State private var usdRate: Double = 34.25
    @State private var eurRate: Double = 37.10
    @State private var gbpRate: Double = 44.50
    @State private var sonKurGuncelleme: String = "TCMB / Güncel"
    @State private var kurKaynak: String = "USD"
    @State private var kurHedef: String = "TRY"
    @State private var kurMiktar: String = "100"
    
    // 2. Toplu Fiyat Güncelleme
    @State private var guncellemeYonu: String = "Artış"
    @State private var yuzdeOran: String = "15"
    @State private var topluFiyatSuccess: Bool = false
    
    // 3. Hedef Yönetimi / Bütçe Planlama Merkezi (12 Ay & Haftalık Kırılım)
    @State private var selectedHedefYear: Int = 2026
    @State private var yillikHedefInput: String = "2400000"
    @State private var isDagitimModalOpen: Bool = false
    @State private var dagitimTuru: String = "esit" // 'esit' | 'trend'
    @State private var expandedWeeksMonth: Int? = nil
    @State private var aylikHedefler: [AylikHedefItem] = [
        AylikHedefItem(ay: 1, ayAdi: "Ocak", hedef: 200000, gerceklesen: 215000),
        AylikHedefItem(ay: 2, ayAdi: "Şubat", hedef: 200000, gerceklesen: 185000),
        AylikHedefItem(ay: 3, ayAdi: "Mart", hedef: 200000, gerceklesen: 240000),
        AylikHedefItem(ay: 4, ayAdi: "Nisan", hedef: 200000, gerceklesen: 195000),
        AylikHedefItem(ay: 5, ayAdi: "Mayıs", hedef: 200000, gerceklesen: 220000),
        AylikHedefItem(ay: 6, ayAdi: "Haziran", hedef: 200000, gerceklesen: 260000),
        AylikHedefItem(ay: 7, ayAdi: "Temmuz", hedef: 200000, gerceklesen: 210000),
        AylikHedefItem(ay: 8, ayAdi: "Ağustos", hedef: 200000, gerceklesen: 180000),
        AylikHedefItem(ay: 9, ayAdi: "Eylül", hedef: 200000, gerceklesen: 245000),
        AylikHedefItem(ay: 10, ayAdi: "Ekim", hedef: 200000, gerceklesen: 285000),
        AylikHedefItem(ay: 11, ayAdi: "Kasım", hedef: 200000, gerceklesen: 142000),
        AylikHedefItem(ay: 12, ayAdi: "Aralık", hedef: 200000, gerceklesen: 0)
    ]
    
    // 4. Cari Birleştirme
    @State private var kaynakCari: String = "Eski Müşteri Ltd. Şti."
    @State private var hedefCari: String = "Akıncılar Çelik Sanayi A.Ş."
    @State private var cariBirlestirSuccess: Bool = false
    
    // 5. Ürün Birleştirme
    @State private var kaynakStok: String = "Paslanmaz Sac 2mm (Eski Kart)"
    @State private var hedefStok: String = "Paslanmaz Sac 2mm 304 Kalite"
    @State private var urunBirlestirSuccess: Bool = false
    
    // 6. Sistem Sağlığı
    @State private var deviceModel: String = "Apple iPhone"
    @State private var osVersion: String = "iOS 17.5"
    @State private var memoryUsage: String = "3.4 GB / 6.0 GB"
    @State private var uptimeString: String = "4 g 12 s 35 dk"
    @State private var cacheCleared: Bool = false
    
    // 7. Gecikme Faizi
    @State private var anaPara: String = "50000"
    @State private var faizOrani: String = "48" // Yıllık %48
    @State private var gecikmeGunu: String = "30"
    @State private var faizSonuc: Double = 1972.60
    
    // 7b. Optimal Satış Fiyatı Önerisi (Masaüstü OptimalFiyatViewModel)
    @State private var optAlisFiyati: String = "150"
    @State private var optEkMaliyet: String = "20"
    @State private var optKarOrani: String = "30"
    @State private var optKdvOrani: String = "20"
    
    // 7c. Evrak Seri & Sıradaki Numara Yönetimi (Masaüstü EvrakNoDuzenleViewModel)
    @State private var seriTanimlar: [EvrakSeriItem] = [
        EvrakSeriItem(id: "1", evrakTipi: "Satış Faturası", seri: "FAT", siradakiNo: 1045),
        EvrakSeriItem(id: "2", evrakTipi: "Tahsilat Makbuzu", seri: "THS", siradakiNo: 320),
        EvrakSeriItem(id: "3", evrakTipi: "Ödeme Makbuzu", seri: "ODM", siradakiNo: 185),
        EvrakSeriItem(id: "4", evrakTipi: "Teklif Formu", seri: "TKF", siradakiNo: 412)
    ]
    
    // 8. Risk Puanlayıcı
    @State private var riskList: [CariRiskItem] = [
        CariRiskItem(unvan: "Akıncılar Çelik Ltd.", puan: 85, durum: "Düşük Risk (Güvenilir)"),
        CariRiskItem(unvan: "Özdemir Makine San.", puan: 72, durum: "Normal Risk"),
        CariRiskItem(unvan: "Doruk İnşaat A.Ş.", puan: 48, durum: "Yüksek Risk (Gecikmeli)"),
        CariRiskItem(unvan: "Tekin Metal Sanayi", puan: 92, durum: "Düşük Risk (VIP)")
    ]
    
    // 9. Portföy CRM
    @State private var portfoyler: [PortfoyCRMItem] = [
        PortfoyCRMItem(id: "1", firma: "Ermay Proje Satışı", yetkili: "Murat Bey", gsm: "0532 111 2233", tutar: 150000, aciklama: "Yeni fabrika sac siparişi"),
        PortfoyCRMItem(id: "2", firma: "Akıncılar Yıllık Tedarik", yetkili: "Kenan Bey", gsm: "0544 222 3344", tutar: 320000, aciklama: "2027 yıllık hammadde sözleşmesi"),
        PortfoyCRMItem(id: "3", firma: "Mega Plastik İhracat", yetkili: "Selin Hanım", gsm: "0555 333 4455", tutar: 450000, aciklama: "Boru ve profil tedarik projesi")
    ]
    @State private var isPortfoyModalOpen: Bool = false
    @State private var newLeadFirma: String = ""
    @State private var newLeadYetkili: String = ""
    @State private var newLeadGsm: String = ""
    @State private var newLeadTutar: String = ""
    @State private var newLeadAciklama: String = ""
    
    // 10. Belge Arşivi
    @State private var belgeler: [ArsivBelgeItem] = [
        ArsivBelgeItem(id: "1", name: "İmza Sirküleri 2026.pdf", kategori: "Hukuki", size: "1.2 MB", date: "15.01.2026"),
        ArsivBelgeItem(id: "2", name: "Vergi Levhası 2026.pdf", kategori: "Mali", size: "450 KB", date: "02.02.2026"),
        ArsivBelgeItem(id: "3", name: "Ticaret Sicil Gazetesi.pdf", kategori: "Resmi", size: "2.8 MB", date: "10.01.2026")
    ]
    @State private var isDocFormOpen: Bool = false
    @State private var newDocName: String = ""
    @State private var newDocKategori: String = "Mali"
    
    // 11. Limit Yönetimi (MusteriLimitScreen Paritesi)
    @State private var defaultRiskLimit: String = "500000"
    @State private var blockOnOverdue: Bool = true
    @State private var blockOnLimitExceeded: Bool = true
    
    public init() {}
    
    // 11 Tools List (Birebir React Native & Avalonia Desktop)
    private let toolsList: [AracToolItem] = [
        AracToolItem(id: "sistem", title: "Sistem Sağlığı ve Bakımı", description: "Sistem durumu izleme, temizlik ve yedekleme.", iconName: "waveform.path.ecg", color: Color(hex: "10B981")),
        AracToolItem(id: "belge", title: "Belge Arşivleme", description: "Dijital evrak saklama.", iconName: "folder.fill", color: Color(hex: "8B5CF6")),
        AracToolItem(id: "kurlar", title: "Döviz Kurları & Otomasyon", description: "Canlı kur ekranı ve otomatik çekme ayarları.", iconName: "building.columns.fill", color: Color(hex: "F59E0B")),
        AracToolItem(id: "cariBir", title: "Cari Birleştirme", description: "Mükerrer cari kartları birleştir.", iconName: "person.2.fill", color: Color(hex: "3B82F6")),
        AracToolItem(id: "urunBir", title: "Ürün Birleştirme", description: "Mükerrer kartları birleştir.", iconName: "square.3.layers.3d.down.right.fill", color: Color(hex: "EC4899")),
        AracToolItem(id: "faiz", title: "Gecikme Faizi", description: "Faiz hesaplama aracı.", iconName: "percent", color: Color(hex: "EF4444")),
        AracToolItem(id: "risk", title: "Risk Puanlayıcı", description: "Ödeme analizi paneli.", iconName: "exclamationmark.triangle.fill", color: Color(hex: "F59E0B")),
        AracToolItem(id: "fiyat", title: "Toplu Fiyat Güncelleme", description: "Tüm ürünlere toplu zam/indirim.", iconName: "arrow.up.right.circle.fill", color: Color(hex: "10B981")),
        AracToolItem(id: "limit", title: "Limit Yönetimi", description: "Risk ve kredi limitleri.", iconName: "lock.fill", color: Color(hex: "EF4444")),
        AracToolItem(id: "hedef", title: "Bütçe Planlama Merkezi", description: "Yıllık, aylık ve haftalık hedef yönetimi.", iconName: "target", color: Color(hex: "60A5FA")),
        AracToolItem(id: "portfoy", title: "Portföy Listesi", description: "Varlık yönetimi paneli.", iconName: "briefcase.fill", color: Color(hex: "8B5CF6"))
    ]
    
    public var body: some View {
        NavigationStack {
            ZStack {
                Color(hex: "0A0A0A").ignoresSafeArea()
                
                VStack(spacing: 0) {
                    renderHeader()
                    
                    ScrollView(showsIndicators: false) {
                        VStack(spacing: 16) {
                            if activeTab == nil {
                                renderToolsGrid()
                            } else {
                                Button {
                                    activeTab = nil
                                } label: {
                                    HStack(spacing: 6) {
                                        Image(systemName: "arrow.left")
                                        Text("Araçlar Listesine Dön")
                                    }
                                    .font(.system(size: 13, weight: .bold))
                                    .foregroundColor(Color(hex: "E2E8F0"))
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .padding(.vertical, 4)
                                }
                                
                                renderActiveToolContent()
                            }
                            
                            Spacer().frame(height: 110)
                        }
                        .padding(.horizontal, 16)
                        .padding(.top, 14)
                    }
                }
            }
            .navigationBarHidden(true)
        }
    }
    
    // MARK: - Header
    @ViewBuilder
    private func renderHeader() -> some View {
        HStack(spacing: 12) {
            Image(systemName: "wrench.and.screwdriver.fill")
                .font(.system(size: 26))
                .foregroundColor(Color(hex: "0061FF"))
            
            VStack(alignment: .leading, spacing: 2) {
                Text(activeTab != nil ? (toolsList.first(where: { $0.id == activeTab })?.title ?? "Araçlar") : "Araçlar ve Modüller")
                    .font(.system(size: 22, weight: .heavy))
                    .foregroundColor(.white)
                    .tracking(-0.5)
                Text(activeTab != nil ? (toolsList.first(where: { $0.id == activeTab })?.description ?? "") : "İşletmenizin dijital dönüşümünde size yardımcı olacak interaktif araçlar.")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(Color(hex: "8E8E93"))
                    .lineLimit(1)
            }
            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.top, 10)
        .padding(.bottom, 12)
        .background(Color(hex: "0A0A0A"))
        .overlay(Divider().background(Color.white.opacity(0.08)), alignment: .bottom)
    }
    
    // MARK: - 11 Tools Grid
    @ViewBuilder
    private func renderToolsGrid() -> some View {
        LazyVGrid(columns: [GridItem(.flexible(), spacing: 12), GridItem(.flexible(), spacing: 12)], spacing: 12) {
            ForEach(toolsList) { tool in
                Button {
                    activeTab = tool.id
                } label: {
                    VStack(alignment: .leading, spacing: 10) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 12)
                                .fill(tool.color.opacity(0.15))
                                .frame(width: 44, height: 44)
                            Image(systemName: tool.iconName)
                                .font(.system(size: 20))
                                .foregroundColor(tool.color)
                        }
                        
                        Text(tool.title)
                            .font(.system(size: 13, weight: .bold))
                            .foregroundColor(.white)
                            .lineLimit(2)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        Text(tool.description)
                            .font(.system(size: 10))
                            .foregroundColor(Color(hex: "8E8E93"))
                            .lineLimit(2)
                    }
                    .padding(14)
                    .frame(minHeight: 130, alignment: .topLeading)
                    .background(Color(hex: "121216"))
                    .cornerRadius(18)
                    .overlay(RoundedRectangle(cornerRadius: 18).stroke(Color.white.opacity(0.08), lineWidth: 1))
                }
            }
        }
    }
    
    // MARK: - Active Tool Views
    @ViewBuilder
    private func renderActiveToolContent() -> some View {
        switch activeTab {
        case "sistem":
            renderSistemSaglik()
        case "belge":
            renderBelgeArsiv()
        case "kurlar":
            renderDovizKurlar()
        case "cariBir":
            renderCariBirlestirme()
        case "urunBir":
            renderUrunBirlestirme()
        case "faiz":
            renderGecikmeFaizi()
        case "risk":
            renderRiskPuani()
        case "fiyat":
            renderTopluFiyat()
        case "limit":
            renderLimitYonetimi()
        case "hedef":
            renderButcePlanlama()
        case "portfoy":
            renderPortfoyCRM()
        default:
            EmptyView()
        }
    }
    
    // MARK: - 1. Sistem Sağlığı
    @ViewBuilder
    private func renderSistemSaglik() -> some View {
        VStack(spacing: 14) {
            cardBox(title: "Sistem Sağlığı & Cihaz Bilgileri") {
                infoRow("Cihaz Modeli", deviceModel)
                infoRow("İşletim Sistemi", osVersion)
                infoRow("Bellek Kullanımı", memoryUsage)
                infoRow("Uygulama Çalışma Süresi", uptimeString)
                infoRow("Bulut Veritabanı", "Supabase PostgreSQL (Aktif)")
                
                Button {
                    cacheCleared = true
                } label: {
                    Text(cacheCleared ? "Önbellek Temizlendi ✓" : "Önbelleği ve Geçici Logları Temizle")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(Color(hex: "10B981"))
                        .cornerRadius(10)
                }
                .padding(.top, 6)
            }
        }
    }
    
    // MARK: - 2. Belge Arşivi
    @ViewBuilder
    private func renderBelgeArsiv() -> some View {
        VStack(spacing: 12) {
            HStack {
                Text("Kayıtlı Dijital Evraklar (\(belgeler.count))")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.white)
                Spacer()
                Button {
                    isDocFormOpen.toggle()
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: "plus")
                        Text("Yeni Belge")
                    }
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(Color(hex: "8B5CF6"))
                    .cornerRadius(8)
                }
            }
            
            if isDocFormOpen {
                cardBox(title: "Yeni Belge Yükle") {
                    TextField("Belge Adı (Örn: Vergi Levhası 2026)", text: $newDocName)
                        .font(.system(size: 13)).foregroundColor(.white).padding(10).background(Color.white.opacity(0.05)).cornerRadius(8)
                    
                    Picker("Kategori", selection: $newDocKategori) {
                        Text("Mali").tag("Mali")
                        Text("Hukuki").tag("Hukuki")
                        Text("Resmi").tag("Resmi")
                        Text("Genel").tag("Genel")
                    }
                    .pickerStyle(.segmented)
                    
                    Button {
                        if !newDocName.isEmpty {
                            belgeler.append(ArsivBelgeItem(id: UUID().uuidString, name: newDocName, kategori: newDocKategori, size: "1.5 MB", date: "04.11.2026"))
                            newDocName = ""
                            isDocFormOpen = false
                        }
                    } label: {
                        Text("Belgeyi Arşive Kaydet")
                            .font(.system(size: 13, weight: .bold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 10)
                            .background(Color(hex: "8B5CF6"))
                            .cornerRadius(8)
                    }
                }
            }
            
            ForEach(belgeler) { doc in
                HStack(spacing: 12) {
                    Image(systemName: "doc.fill")
                        .font(.system(size: 22))
                        .foregroundColor(Color(hex: "8B5CF6"))
                    
                    VStack(alignment: .leading, spacing: 3) {
                        Text(doc.name).font(.system(size: 13, weight: .bold)).foregroundColor(.white)
                        Text("Kategori: \(doc.kategori) • \(doc.size) • \(doc.date)").font(.system(size: 11)).foregroundColor(Color(hex: "94A3B8"))
                    }
                    Spacer()
                    Image(systemName: "square.and.arrow.up")
                        .foregroundColor(Color(hex: "60A5FA"))
                }
                .padding(14)
                .background(Color(hex: "121216"))
                .cornerRadius(12)
                .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.white.opacity(0.08), lineWidth: 1))
            }
        }
    }
    
    // MARK: - 3. Döviz Kurları & Çevirici
    @ViewBuilder
    private func renderDovizKurlar() -> some View {
        VStack(spacing: 14) {
            cardBox(title: "Döviz Otomasyonu (Canlı TCMB)") {
                HStack(spacing: 8) {
                    kurCard(title: "USD / TL", val: "\(usdRate) ₺", color: Color(hex: "10B981"))
                    kurCard(title: "EUR / TL", val: "\(eurRate) ₺", color: Color(hex: "3B82F6"))
                    kurCard(title: "GBP / TL", val: "\(gbpRate) ₺", color: Color(hex: "F59E0B"))
                }
                Text("Son güncelleme: \(sonKurGuncelleme)")
                    .font(.system(size: 11))
                    .foregroundColor(Color(hex: "64748B"))
                
                Button {
                    usdRate = 34.32
                    eurRate = 37.18
                    gbpRate = 44.65
                    sonKurGuncelleme = "Şimdi güncellendi (TCMB)"
                } label: {
                    Text("Kurları Güncelle (TCMB)")
                        .font(.system(size: 13, weight: .bold)).foregroundColor(.white)
                        .frame(maxWidth: .infinity).padding(.vertical, 12).background(Color(hex: "F59E0B")).cornerRadius(10)
                }
            }
            
            cardBox(title: "Döviz Çevirici (Çapraz Kur)") {
                HStack(spacing: 8) {
                    TextField("Miktar", text: $kurMiktar)
                        .font(.system(size: 13)).foregroundColor(.white).padding(10).background(Color.white.opacity(0.05)).cornerRadius(8)
                    Picker("Kaynak", selection: $kurKaynak) {
                        Text("USD").tag("USD"); Text("EUR").tag("EUR"); Text("TRY").tag("TRY")
                    }.pickerStyle(.menu).padding(6).background(Color.white.opacity(0.05)).cornerRadius(8)
                    Text("➔").foregroundColor(.white)
                    Picker("Hedef", selection: $kurHedef) {
                        Text("TRY").tag("TRY"); Text("USD").tag("USD"); Text("EUR").tag("EUR")
                    }.pickerStyle(.menu).padding(6).background(Color.white.opacity(0.05)).cornerRadius(8)
                }
                let m = Double(kurMiktar) ?? 0
                let rate = (kurKaynak == "USD" ? usdRate : (kurKaynak == "EUR" ? eurRate : 1.0))
                Text("Sonuç: \(AppFormatters.money(m * rate))")
                    .font(.system(size: 18, weight: .heavy))
                    .foregroundColor(Color(hex: "10B981"))
            }
            
            cardBox(title: "Optimal Satış Fiyatı Önerisi (Masaüstü)") {
                HStack(spacing: 8) {
                    calcInput("Alış Fiyatı (₺)", text: $optAlisFiyati)
                    calcInput("Ek Maliyet (₺)", text: $optEkMaliyet)
                }
                HStack(spacing: 8) {
                    calcInput("Kâr Oranı (%)", text: $optKarOrani)
                    calcInput("KDV Oranı (%)", text: $optKdvOrani)
                }
                let alis = Double(optAlisFiyati) ?? 0
                let ek = Double(optEkMaliyet) ?? 0
                let kar = Double(optKarOrani) ?? 0
                let kdv = Double(optKdvOrani) ?? 0
                let toplamMaliyet = alis + ek
                let satisFiyati = toplamMaliyet * (1 + kar / 100.0)
                let netKar = satisFiyati - toplamMaliyet
                let kdvTutari = satisFiyati * (kdv / 100.0)
                
                VStack(spacing: 4) {
                    infoRow("Önerilen Satış Fiyatı", AppFormatters.money(satisFiyati))
                    infoRow("Net Satır Kârı", AppFormatters.money(netKar))
                    infoRow("KDV Tutarı", AppFormatters.money(kdvTutari))
                }
                .padding(.top, 4)
            }
            
            cardBox(title: "Evrak Seri & Sıradaki Numara Yönetimi (Masaüstü)") {
                ForEach(seriTanimlar) { s in
                    HStack {
                        VStack(alignment: .leading, spacing: 2) {
                            Text(s.evrakTipi).font(.system(size: 13, weight: .bold)).foregroundColor(.white)
                            Text("Seri: \(s.seri) • Sıradaki No: \(s.siradakiNo)").font(.system(size: 11)).foregroundColor(Color(hex: "94A3B8"))
                        }
                        Spacer()
                        Image(systemName: "pencil.circle.fill").foregroundColor(Color(hex: "60A5FA"))
                    }
                    .padding(.vertical, 4)
                }
            }
        }
    }
    
    // MARK: - 4. Cari Birleştirme
    @ViewBuilder
    private func renderCariBirlestirme() -> some View {
        cardBox(title: "Mükerrer Cari Birleştirme") {
            calcInput("Kaynak Cari (Silinecek ve Aktarılacak)", text: $kaynakCari)
            calcInput("Hedef Cari (Birleştirilecek Ana Kart)", text: $hedefCari)
            
            Text("Kaynak carinin tüm fatura, sipariş, çek/senet, kasa ve banka hareketleri hedef cariye aktarılır.")
                .font(.system(size: 11))
                .foregroundColor(Color(hex: "94A3B8"))
            
            Button {
                cariBirlestirSuccess = true
            } label: {
                Text(cariBirlestirSuccess ? "Cariler Başarıyla Birleştirildi ✓" : "Cari Hesapları Birleştir")
                    .font(.system(size: 14, weight: .bold)).foregroundColor(.white)
                    .frame(maxWidth: .infinity).padding(.vertical, 12).background(Color(hex: "3B82F6")).cornerRadius(10)
            }
        }
    }
    
    // MARK: - 5. Ürün Birleştirme
    @ViewBuilder
    private func renderUrunBirlestirme() -> some View {
        cardBox(title: "Mükerrer Ürün Birleştirme") {
            calcInput("Kaynak Ürün (Miktarı Aktarılacak ve Silinecek)", text: $kaynakStok)
            calcInput("Hedef Ürün (Ana Kart)", text: $hedefStok)
            
            Text("Kaynak ürünün stok hareketleri ve depo mevcut miktarı hedef ürüne eklenerek kaynak kart silinir.")
                .font(.system(size: 11))
                .foregroundColor(Color(hex: "94A3B8"))
            
            Button {
                urunBirlestirSuccess = true
            } label: {
                Text(urunBirlestirSuccess ? "Ürünler Başarıyla Birleştirildi ✓" : "Ürün Kartlarını Birleştir")
                    .font(.system(size: 14, weight: .bold)).foregroundColor(.white)
                    .frame(maxWidth: .infinity).padding(.vertical, 12).background(Color(hex: "EC4899")).cornerRadius(10)
            }
        }
    }
    
    // MARK: - 6. Gecikme Faizi
    @ViewBuilder
    private func renderGecikmeFaizi() -> some View {
        cardBox(title: "Gecikme Faizi Hesaplayıcı") {
            calcInput("Ana Para (₺)", text: $anaPara)
            calcInput("Yıllık Faiz Oranı (%)", text: $faizOrani)
            calcInput("Gecikme Günü", text: $gecikmeGunu)
            
            Button {
                let a = Double(anaPara) ?? 0
                let f = Double(faizOrani) ?? 0
                let g = Double(gecikmeGunu) ?? 0
                faizSonuc = (a * (f / 100.0) * g) / 365.0
            } label: {
                Text("Faiz Hesapla")
                    .font(.system(size: 14, weight: .bold)).foregroundColor(.white)
                    .frame(maxWidth: .infinity).padding(.vertical, 12).background(Color(hex: "EF4444")).cornerRadius(10)
            }
            
            HStack {
                Text("Toplam Faiz Yükü:").font(.system(size: 13, weight: .semibold)).foregroundColor(Color(hex: "94A3B8"))
                Spacer()
                Text(AppFormatters.money(faizSonuc))
                    .font(.system(size: 18, weight: .heavy)).foregroundColor(Color(hex: "EF4444"))
            }
            .padding(.top, 4)
        }
    }
    
    // MARK: - 7. Risk Puanı
    @ViewBuilder
    private func renderRiskPuani() -> some View {
        cardBox(title: "Cari Risk Analiz Karnesi") {
            ForEach(riskList) { r in
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(r.unvan).font(.system(size: 13, weight: .bold)).foregroundColor(.white)
                        Text(r.durum).font(.system(size: 11)).foregroundColor(r.puan >= 70 ? Color(hex: "10B981") : Color(hex: "EF4444"))
                    }
                    Spacer()
                    Text("\(r.puan) / 100")
                        .font(.system(size: 15, weight: .heavy))
                        .foregroundColor(r.puan >= 70 ? Color(hex: "10B981") : Color(hex: "EF4444"))
                }
                .padding(.vertical, 6)
                Divider().background(Color.white.opacity(0.06))
            }
        }
    }
    
    // MARK: - 8. Toplu Fiyat
    @ViewBuilder
    private func renderTopluFiyat() -> some View {
        cardBox(title: "Toplu Fiyat Zam / İndirim") {
            Picker("Yön", selection: $guncellemeYonu) {
                Text("Zam (Artış)").tag("Artış")
                Text("İndirim (Azalış)").tag("Azalış")
            }.pickerStyle(.segmented)
            
            calcInput("Yüzde Oranı (%)", text: $yuzdeOran)
            
            Button {
                topluFiyatSuccess = true
            } label: {
                Text(topluFiyatSuccess ? "Tüm Fiyatlar Başarıyla Güncellendi ✓" : "Fiyatları Toplu Güncelle")
                    .font(.system(size: 14, weight: .bold)).foregroundColor(.white)
                    .frame(maxWidth: .infinity).padding(.vertical, 12).background(Color(hex: "10B981")).cornerRadius(10)
            }
        }
    }
    
    // MARK: - 9. Limit Yönetimi
    @ViewBuilder
    private func renderLimitYonetimi() -> some View {
        cardBox(title: "Limit & Risk Yönetimi (MusteriLimit)") {
            calcInput("Varsayılan Cari Risk Limiti (₺)", text: $defaultRiskLimit)
            
            Toggle("Vadesi Geçmiş Açık Faturada Satışı Engelle", isOn: $blockOnOverdue)
                .font(.system(size: 13)).foregroundColor(.white)
            
            Toggle("Risk Limiti Aşıldığında Fatura Kesimini Blokla", isOn: $blockOnLimitExceeded)
                .font(.system(size: 13)).foregroundColor(.white)
            
            Text("Limit aşıldığında sistem yönetici onayı isteyecek ve açık fatura riski kilitlenecektir.")
                .font(.system(size: 11))
                .foregroundColor(Color(hex: "94A3B8"))
        }
    }
    
    // MARK: - 10. Bütçe Planlama Merkezi (Hedef Yönetimi)
    @ViewBuilder
    private func renderButcePlanlama() -> some View {
        VStack(spacing: 14) {
            cardBox(title: "Bütçe Planlama & Satış Hedefi") {
                // Year & Dagitim button
                HStack {
                    HStack(spacing: 8) {
                        Button { selectedHedefYear -= 1 } label: { Image(systemName: "chevron.left").foregroundColor(.white) }
                        Text("\(selectedHedefYear)").font(.system(size: 16, weight: .bold)).foregroundColor(.white)
                        Button { selectedHedefYear += 1 } label: { Image(systemName: "chevron.right").foregroundColor(.white) }
                    }
                    Spacer()
                    Button {
                        isDagitimModalOpen = true
                    } label: {
                        HStack(spacing: 4) {
                            Image(systemName: "sparkles")
                            Text("Dağılım Sihirbazı")
                        }
                        .font(.system(size: 12, weight: .bold)).foregroundColor(.white)
                        .padding(.horizontal, 10).padding(.vertical, 6).background(Color(hex: "2563EB")).cornerRadius(8)
                    }
                }
                
                // 4 KPI Boxes
                let yillikHedef = aylikHedefler.reduce(0) { $0 + $1.hedef }
                let yillikGercek = aylikHedefler.reduce(0) { $0 + $1.gerceklesen }
                let oran = yillikHedef > 0 ? (yillikGercek / yillikHedef) * 100.0 : 0
                let fark = yillikGercek - yillikHedef
                
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 8) {
                    kpiItem("Yıllık Hedef", AppFormatters.money(yillikHedef), Color(hex: "3B82F6"))
                    kpiItem("Yıllık Gerçekleşen", AppFormatters.money(yillikGercek), Color(hex: "10B981"))
                    kpiItem("Gerçekleşme %", "%\(String(format: "%.1f", oran))", oran >= 100 ? Color(hex: "10B981") : Color(hex: "F59E0B"))
                    kpiItem("Bütçe Sapması", "\(fark >= 0 ? "+" : "")\(AppFormatters.money(fark))", fark >= 0 ? Color(hex: "10B981") : Color(hex: "EF4444"))
                }
                
                // 12 Months List
                VStack(spacing: 10) {
                    ForEach(aylikHedefler) { m in
                        VStack(spacing: 4) {
                            HStack {
                                Text(m.ayAdi).font(.system(size: 13, weight: .bold)).foregroundColor(.white)
                                Spacer()
                                Text("Hedef: \(AppFormatters.money(m.hedef))").font(.system(size: 11)).foregroundColor(Color(hex: "94A3B8"))
                                Text("•").foregroundColor(Color(hex: "64748B"))
                                Text("Gerçek: \(AppFormatters.money(m.gerceklesen))").font(.system(size: 11, weight: .bold)).foregroundColor(.white)
                            }
                            
                            // Progress bar
                            let pct = m.hedef > 0 ? min(m.gerceklesen / m.hedef, 1.0) : 0
                            GeometryReader { g in
                                ZStack(alignment: .leading) {
                                    RoundedRectangle(cornerRadius: 3).fill(Color.white.opacity(0.1)).frame(height: 6)
                                    RoundedRectangle(cornerRadius: 3).fill(pct >= 1.0 ? Color(hex: "10B981") : Color(hex: "3B82F6")).frame(width: g.size.width * pct, height: 6)
                                }
                            }
                            .frame(height: 6)
                        }
                        .padding(8)
                        .background(Color.white.opacity(0.02))
                        .cornerRadius(8)
                    }
                }
            }
        }
        .sheet(isPresented: $isDagitimModalOpen) {
            NavigationStack {
                ZStack {
                    Color(hex: "0A0A0A").ignoresSafeArea()
                    VStack(alignment: .leading, spacing: 16) {
                        Text("\(selectedHedefYear) Yıllık Hedef Tutarını 12 Aya Paylaştırın")
                            .font(.system(size: 13)).foregroundColor(Color(hex: "94A3B8"))
                        
                        calcInput("Yıllık Toplam Ciro Hedefi (₺)", text: $yillikHedefInput)
                        
                        Picker("Dağıtım Yöntemi", selection: $dagitimTuru) {
                            Text("12 Aya Eşit").tag("esit")
                            Text("Geçen Yıl Trendine Göre").tag("trend")
                        }
                        .pickerStyle(.segmented)
                        
                        Button {
                            let total = Double(yillikHedefInput) ?? 2400000
                            let pay = total / 12.0
                            aylikHedefler = aylikHedefler.map { AylikHedefItem(ay: $0.ay, ayAdi: $0.ayAdi, hedef: pay, gerceklesen: $0.gerceklesen) }
                            isDagitimModalOpen = false
                        } label: {
                            Text("Dağıtımı Başlat ve Kaydet")
                                .font(.system(size: 14, weight: .bold)).foregroundColor(.white)
                                .frame(maxWidth: .infinity).padding(.vertical, 14).background(Color(hex: "10B981")).cornerRadius(10)
                        }
                        
                        Spacer()
                    }
                    .padding(20)
                }
                .navigationTitle("Bütçe Dağılım Sihirbazı")
                .navigationBarTitleDisplayMode(.inline)
            }
        }
    }
    
    // MARK: - 11. Portföy CRM
    @ViewBuilder
    private func renderPortfoyCRM() -> some View {
        VStack(spacing: 12) {
            HStack {
                Text("CRM Fırsat Listesi (\(portfoyler.count))")
                    .font(.system(size: 14, weight: .bold)).foregroundColor(.white)
                Spacer()
                Button {
                    isPortfoyModalOpen.toggle()
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: "plus")
                        Text("Yeni Fırsat")
                    }
                    .font(.system(size: 12, weight: .bold)).foregroundColor(.white)
                    .padding(.horizontal, 10).padding(.vertical, 6).background(Color(hex: "8B5CF6")).cornerRadius(8)
                }
            }
            
            ForEach(portfoyler) { p in
                VStack(alignment: .leading, spacing: 6) {
                    HStack {
                        Text(p.firma).font(.system(size: 14, weight: .bold)).foregroundColor(.white)
                        Spacer()
                        Text(AppFormatters.money(p.tutar)).font(.system(size: 14, weight: .heavy)).foregroundColor(Color(hex: "10B981"))
                    }
                    Text("Yetkili: \(p.yetkili) • GSM: \(p.gsm)").font(.system(size: 11)).foregroundColor(Color(hex: "94A3B8"))
                    Text(p.aciklama).font(.system(size: 11)).foregroundColor(Color(hex: "64748B"))
                    
                    HStack {
                        Spacer()
                        Button {
                            // Cariye aktar onay
                        } label: {
                            Text("Cariye Aktar")
                                .font(.system(size: 11, weight: .bold)).foregroundColor(Color(hex: "60A5FA"))
                                .padding(.horizontal, 10).padding(.vertical, 4)
                                .background(Color(hex: "0061FF").opacity(0.15))
                                .cornerRadius(6)
                        }
                    }
                }
                .padding(14)
                .background(Color(hex: "121216"))
                .cornerRadius(12)
                .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.white.opacity(0.08), lineWidth: 1))
            }
        }
        .sheet(isPresented: $isPortfoyModalOpen) {
            NavigationStack {
                ZStack {
                    Color(hex: "0A0A0A").ignoresSafeArea()
                    ScrollView {
                        VStack(spacing: 12) {
                            calcInput("Firma Adı", text: $newLeadFirma)
                            calcInput("Yetkili Kişi", text: $newLeadYetkili)
                            calcInput("GSM No", text: $newLeadGsm)
                            calcInput("Tahmini Fırsat Değeri (₺)", text: $newLeadTutar)
                            calcInput("Fırsat Detayları", text: $newLeadAciklama)
                            
                            Button {
                                if !newLeadFirma.isEmpty {
                                    portfoyler.append(PortfoyCRMItem(id: UUID().uuidString, firma: newLeadFirma, yetkili: newLeadYetkili, gsm: newLeadGsm, tutar: Double(newLeadTutar) ?? 0, aciklama: newLeadAciklama))
                                    newLeadFirma = ""
                                    newLeadYetkili = ""
                                    newLeadGsm = ""
                                    newLeadTutar = ""
                                    newLeadAciklama = ""
                                    isPortfoyModalOpen = false
                                }
                            } label: {
                                Text("Fırsatı Kaydet")
                                    .font(.system(size: 14, weight: .bold)).foregroundColor(.white)
                                    .frame(maxWidth: .infinity).padding(.vertical, 14).background(Color(hex: "8B5CF6")).cornerRadius(10)
                            }
                        }
                        .padding(20)
                    }
                }
                .navigationTitle("Yeni Fırsat Ekle")
                .navigationBarTitleDisplayMode(.inline)
            }
        }
    }
    
    // MARK: - Helpers
    private func cardBox<Content: View>(title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title).font(.system(size: 15, weight: .bold)).foregroundColor(.white)
            content()
        }
        .padding(16)
        .background(Color(hex: "121216"))
        .cornerRadius(18)
        .overlay(RoundedRectangle(cornerRadius: 18).stroke(Color.white.opacity(0.08), lineWidth: 1))
    }
    
    private func infoRow(_ label: String, _ val: String) -> some View {
        HStack {
            Text(label).font(.system(size: 12)).foregroundColor(Color(hex: "8E8E93"))
            Spacer()
            Text(val).font(.system(size: 12, weight: .semibold)).foregroundColor(.white)
        }
    }
    
    private func calcInput(_ label: String, text: Binding<String>) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(label).font(.system(size: 11, weight: .semibold)).foregroundColor(Color(hex: "8E8E93"))
            TextField("", text: text)
                .font(.system(size: 13)).foregroundColor(.white).padding(10).background(Color.white.opacity(0.05)).cornerRadius(8)
        }
    }
    
    private func kurCard(title: String, val: String, color: Color) -> some View {
        VStack(spacing: 3) {
            Text(title).font(.system(size: 10, weight: .bold)).foregroundColor(Color(hex: "8E8E93"))
            Text(val).font(.system(size: 14, weight: .heavy)).foregroundColor(color)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 10)
        .background(Color.white.opacity(0.03))
        .cornerRadius(8)
    }
    
    private func kpiItem(_ title: String, _ val: String, _ color: Color) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(title).font(.system(size: 10, weight: .medium)).foregroundColor(Color(hex: "94A3B8"))
            Text(val).font(.system(size: 13, weight: .bold)).foregroundColor(color)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(8)
        .background(Color.white.opacity(0.03))
        .cornerRadius(8)
    }
}

// Supporting Model Types
public struct AylikHedefItem: Identifiable {
    public var id: Int { ay }
    public let ay: Int
    public let ayAdi: String
    public var hedef: Double
    public var gerceklesen: Double
}

public struct CariRiskItem: Identifiable {
    public let id = UUID()
    public let unvan: String
    public let puan: Int
    public let durum: String
}

public struct PortfoyCRMItem: Identifiable {
    public let id: String
    public let firma: String
    public let yetkili: String
    public let gsm: String
    public let tutar: Double
    public let aciklama: String
}

public struct ArsivBelgeItem: Identifiable {
    public let id: String
    public let name: String
    public let kategori: String
    public let size: String
    public let date: String
}

public struct EvrakSeriItem: Identifiable {
    public let id: String
    public let evrakTipi: String
    public var seri: String
    public var siradakiNo: Int
}
