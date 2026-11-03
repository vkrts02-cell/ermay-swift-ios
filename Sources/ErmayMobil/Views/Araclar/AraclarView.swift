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
    
    // 1. Döviz Kurları & Çevirici
    @State private var usdRate: Double = 34.25
    @State private var eurRate: Double = 37.10
    @State private var gbpRate: Double = 44.50
    @State private var kurKaynak: String = "USD"
    @State private var kurHedef: String = "TRY"
    @State private var kurMiktar: String = "100"
    
    // 2. Toplu Fiyat Güncelleme
    @State private var guncellemeYonu: String = "Artış"
    @State private var yuzdeOran: String = "10"
    @State private var topluFiyatSuccess: Bool = false
    
    // 3. Hedef Yönetimi / Bütçe
    @State private var yillikHedef: String = "3000000"
    @State private var aylikHedef: String = "250000"
    
    // 4. Cari Birleştirme
    @State private var kaynakCari: String = "Eski Müşteri Ltd."
    @State private var hedefCari: String = "Ermay Tekstil A.Ş."
    @State private var cariBirlestirSuccess: Bool = false
    
    // 5. Ürün Birleştirme
    @State private var kaynakStok: String = "Rulman 6204 (Eski Kod)"
    @State private var hedefStok: String = "Bilyalı Rulman 6204-2RS"
    @State private var urunBirlestirSuccess: Bool = false
    
    // 6. Sistem Sağlığı
    @State private var deviceModel: String = "Apple iPhone"
    @State private var osVersion: String = "iOS 17"
    @State private var memoryUsage: String = "3.2 GB / 6.0 GB"
    @State private var cacheCleared: Bool = false
    
    // 7. Gecikme Faizi
    @State private var anaPara: String = "50000"
    @State private var faizOrani: String = "48" // Yıllık %48
    @State private var gecikmeGunu: String = "30"
    @State private var faizSonuc: Double = 0.0
    
    // 8. Risk Puanlayıcı
    @State private var seciliCariRisk: String = "Ermay Tekstil Ltd."
    @State private var cariPuan: Int = 88
    
    // 9. Portföy CRM
    @State private var portfoyler: [String] = ["Ermay Proje Satışı (₺150.000)", "Akıncılar Yıllık Tedarik (₺320.000)", "Mega Plastik İhracat ($45.000)"]
    @State private var yeniFirsat: String = ""
    
    // 10. Belge Arşivi
    @State private var belgeler: [String] = ["İmza Sirküleri 2026.pdf", "Vergi Levhası 2026.pdf", "Ticaret Sicil Gazetesi.pdf"]
    @State private var yeniBelgeAdi: String = ""
    
    // 11. Limit Yönetimi
    @State private var riskLimitiCari: String = "500000"
    @State private var acikHesapKapat: Bool = false
    
    public init() {}
    
    // 11 Tools List (Exact to AraclarScreen.tsx toolsList)
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
                Color.black.ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Header Bar (Exact to AraclarScreen.tsx)
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
                    
                    ScrollView(showsIndicators: false) {
                        VStack(spacing: 16) {
                            if activeTab == nil {
                                // 11 Araç Grid Kartları (Exact 2-Col Grid)
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
                            } else {
                                // Geri Dön Butonu
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
                                    .padding(.vertical, 6)
                                }
                                
                                // Seçili Alt Araç Detayı
                                renderActiveToolContent()
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
    
    // MARK: - Sub Tool Renderers
    @ViewBuilder
    private func renderActiveToolContent() -> some View {
        switch activeTab {
        case "sistem":
            toolCard(title: "Sistem Sağlığı ve Cihaz Metrikleri") {
                infoRow("Cihaz Modeli", deviceModel)
                infoRow("İşletim Sistemi", osVersion)
                infoRow("Bellek Kullanımı", memoryUsage)
                infoRow("Veritabanı Durumu", "Aktif (Supabase Cloud)")
                
                Button {
                    cacheCleared = true
                } label: {
                    Text(cacheCleared ? "Önbellek Temizlendi ✓" : "Önbelleği ve Geçici Dosyaları Temizle")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(Color(hex: "10B981"))
                        .cornerRadius(10)
                }
                .padding(.top, 8)
            }
            
        case "belge":
            toolCard(title: "Dijital Belge Arşivi") {
                ForEach(belgeler, id: \.self) { b in
                    HStack {
                        Image(systemName: "doc.fill").foregroundColor(Color(hex: "8B5CF6"))
                        Text(b).font(.system(size: 13)).foregroundColor(.white)
                        Spacer()
                        Image(systemName: "checkmark.circle.fill").foregroundColor(Color(hex: "10B981"))
                    }
                    .padding(.vertical, 4)
                }
                
                HStack(spacing: 8) {
                    TextField("Yeni Belge Adı...", text: $yeniBelgeAdi)
                        .font(.system(size: 13)).foregroundColor(.white).padding(10).background(Color.white.opacity(0.05)).cornerRadius(8)
                    Button {
                        if !yeniBelgeAdi.isEmpty {
                            belgeler.append(yeniBelgeAdi)
                            yeniBelgeAdi = ""
                        }
                    } label: {
                        Text("Ekle").font(.system(size: 13, weight: .bold)).foregroundColor(.white).padding(.horizontal, 14).padding(.vertical, 10).background(Color(hex: "8B5CF6")).cornerRadius(8)
                    }
                }
                .padding(.top, 8)
            }
            
        case "kurlar":
            VStack(spacing: 14) {
                toolCard(title: "Canlı TCMB Döviz Kurları") {
                    HStack {
                        kurBox(title: "USD / TL", val: "\(usdRate) ₺", color: Color(hex: "30D158"))
                        kurBox(title: "EUR / TL", val: "\(eurRate) ₺", color: Color(hex: "0A84FF"))
                        kurBox(title: "GBP / TL", val: "\(gbpRate) ₺", color: Color(hex: "FF9F0A"))
                    }
                }
                
                toolCard(title: "Kur Çevirici") {
                    HStack(spacing: 8) {
                        TextField("Miktar", text: $kurMiktar).font(.system(size: 13)).foregroundColor(.white).padding(10).background(Color.white.opacity(0.05)).cornerRadius(8)
                        Picker("Kaynak", selection: $kurKaynak) {
                            Text("USD").tag("USD"); Text("EUR").tag("EUR"); Text("TRY").tag("TRY")
                        }.pickerStyle(.menu).padding(8).background(Color.white.opacity(0.05)).cornerRadius(8)
                        Text("➔").foregroundColor(.white)
                        Picker("Hedef", selection: $kurHedef) {
                            Text("TRY").tag("TRY"); Text("USD").tag("USD"); Text("EUR").tag("EUR")
                        }.pickerStyle(.menu).padding(8).background(Color.white.opacity(0.05)).cornerRadius(8)
                    }
                    let m = Double(kurMiktar) ?? 0
                    let rate = (kurKaynak == "USD" ? usdRate : (kurKaynak == "EUR" ? eurRate : 1.0))
                    Text("Sonuç: \(String(format: "%.2f", m * rate)) \(kurHedef)")
                        .font(.system(size: 16, weight: .heavy)).foregroundColor(Color(hex: "30D158"))
                        .padding(.top, 4)
                }
            }
            
        case "faiz":
            toolCard(title: "Gecikme Faizi Hesaplama") {
                calcInput(label: "Ana Para (₺)", text: $anaPara)
                calcInput(label: "Yıllık Faiz Oranı (%)", text: $faizOrani)
                calcInput(label: "Gecikme Günü", text: $gecikmeGunu)
                
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
                    Text("Hesaplanan Faiz Tutarı:")
                    Spacer()
                    Text(AppFormatters.money(faizSonuc))
                        .font(.system(size: 18, weight: .heavy)).foregroundColor(Color(hex: "EF4444"))
                }
                .padding(.top, 6)
            }
            
        case "fiyat":
            toolCard(title: "Toplu Fiyat Güncelleme") {
                Picker("Yön", selection: $guncellemeYonu) {
                    Text("Artış (Zam)").tag("Artış")
                    Text("Azalış (İndirim)").tag("Azalış")
                }.pickerStyle(.segmented)
                
                calcInput(label: "Oran (%)", text: $yuzdeOran)
                
                Button {
                    topluFiyatSuccess = true
                } label: {
                    Text(topluFiyatSuccess ? "Fiyatlar Güncellendi ✓" : "Tüm Ürünlerin Fiyatını Güncelle")
                        .font(.system(size: 14, weight: .bold)).foregroundColor(.white)
                        .frame(maxWidth: .infinity).padding(.vertical, 12).background(Color(hex: "10B981")).cornerRadius(10)
                }
                .padding(.top, 4)
            }
            
        case "hedef":
            toolCard(title: "Bütçe ve Satış Hedefleri") {
                calcInput(label: "Yıllık Hedef (₺)", text: $yillikHedef)
                calcInput(label: "Aylık Hedef (₺)", text: $aylikHedef)
                Text("Haftalık Hedef: \(AppFormatters.money((Double(aylikHedef) ?? 0) / 4.0))")
                    .font(.system(size: 13, weight: .bold)).foregroundColor(Color(hex: "60A5FA"))
            }
            
        case "cariBir":
            toolCard(title: "Mükerrer Cari Kartı Birleştirme") {
                calcInput(label: "Kaynak Cari (Silinecek)", text: $kaynakCari)
                calcInput(label: "Hedef Cari (Tüm hareketler aktarılacak)", text: $hedefCari)
                Button {
                    cariBirlestirSuccess = true
                } label: {
                    Text(cariBirlestirSuccess ? "Cariler Birleştirildi ✓" : "Carileri Birleştir")
                        .font(.system(size: 14, weight: .bold)).foregroundColor(.white)
                        .frame(maxWidth: .infinity).padding(.vertical, 12).background(Color(hex: "3B82F6")).cornerRadius(10)
                }
            }
            
        case "urunBir":
            toolCard(title: "Mükerrer Stok Kartı Birleştirme") {
                calcInput(label: "Kaynak Stok", text: $kaynakStok)
                calcInput(label: "Hedef Stok", text: $hedefStok)
                Button {
                    urunBirlestirSuccess = true
                } label: {
                    Text(urunBirlestirSuccess ? "Ürünler Birleştirildi ✓" : "Ürünleri Birleştir")
                        .font(.system(size: 14, weight: .bold)).foregroundColor(.white)
                        .frame(maxWidth: .infinity).padding(.vertical, 12).background(Color(hex: "EC4899")).cornerRadius(10)
                }
            }
            
        case "portfoy":
            toolCard(title: "Portföy Fırsatları (CRM)") {
                ForEach(portfoyler, id: \.self) { p in
                    Text("• \(p)").font(.system(size: 13)).foregroundColor(.white)
                }
                HStack(spacing: 8) {
                    TextField("Yeni Fırsat Ekle...", text: $yeniFirsat)
                        .font(.system(size: 13)).foregroundColor(.white).padding(10).background(Color.white.opacity(0.05)).cornerRadius(8)
                    Button {
                        if !yeniFirsat.isEmpty {
                            portfoyler.append(yeniFirsat)
                            yeniFirsat = ""
                        }
                    } label: {
                        Text("Ekle").font(.system(size: 13, weight: .bold)).foregroundColor(.white).padding(.horizontal, 14).padding(.vertical, 10).background(Color(hex: "8B5CF6")).cornerRadius(8)
                    }
                }
            }
            
        case "limit":
            toolCard(title: "Limit & Risk Yönetimi") {
                calcInput(label: "Varsayılan Cari Risk Limiti (₺)", text: $riskLimitiCari)
                Toggle("Vadesi Geçmiş Açık Faturada Satışı Engelle", isOn: $acikHesapKapat)
                    .font(.system(size: 13)).foregroundColor(.white)
            }
            
        case "risk":
            toolCard(title: "Cari Risk Puanlayıcı") {
                calcInput(label: "Cari Unvanı", text: $seciliCariRisk)
                HStack {
                    Text("Risk Skoru: \(cariPuan) / 100")
                        .font(.system(size: 16, weight: .bold)).foregroundColor(Color(hex: "10B981"))
                    Spacer()
                    Text("GÜVENİLİR MÜŞTERİ")
                        .font(.system(size: 11, weight: .heavy)).foregroundColor(Color(hex: "10B981"))
                }
            }
            
        default:
            EmptyView()
        }
    }
    
    private func toolCard<Content: View>(title: String, @ViewBuilder content: () -> Content) -> some View {
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
    
    private func calcInput(label: String, text: Binding<String>) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(label).font(.system(size: 11, weight: .semibold)).foregroundColor(Color(hex: "8E8E93"))
            TextField("", text: text)
                .font(.system(size: 13)).foregroundColor(.white).padding(10).background(Color.white.opacity(0.05)).cornerRadius(8)
        }
    }
    
    private func kurBox(title: String, val: String, color: Color) -> some View {
        VStack(spacing: 3) {
            Text(title).font(.system(size: 10, weight: .bold)).foregroundColor(Color(hex: "8E8E93"))
            Text(val).font(.system(size: 14, weight: .heavy)).foregroundColor(color)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 10)
        .background(Color.white.opacity(0.03))
        .cornerRadius(8)
    }
}
