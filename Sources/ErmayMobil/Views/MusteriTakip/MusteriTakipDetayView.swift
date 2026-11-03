import SwiftUI

public enum CRMDetailTab: String, CaseIterable {
    case gorusmeler = "Görüşmeler"
    case fiyatlar = "Özel Fiyatlar"
    case gorseller = "Görseller & Fotoğraf"
    case notlar = "Özel Notlar"
}

public struct GorusmeKaydi: Identifiable {
    public var id = UUID()
    public var baslik: String
    public var icerik: String
    public var tarih: String
}

public struct OzelFiyatKaydi: Identifiable {
    public var id = UUID()
    public var baslik: String
    public var tutar: Double
    public var paraBirimi: String
    public var aciklama: String
    public var tarih: String
}

public struct GorselKaydi: Identifiable {
    public var id = UUID()
    public var baslik: String
    public var systemImageName: String
    public var tarih: String
}

public struct MusteriTakipDetayView: View {
    public let kayit: MusteriTakipKayit
    @State private var activeTab: CRMDetailTab = .gorusmeler
    
    // Veriler
    @State private var gorusmeler: [GorusmeKaydi] = [
        GorusmeKaydi(baslik: "Yıllık Bakım & Rulman Sözleşmesi", icerik: "Yıllık 500 adet rulman ve 200 adet keçe alımı için özel iskonto talep edildi.", tarih: "03.11.2026"),
        GorusmeKaydi(baslik: "İlk Tanışma & Fabrika Ziyareti", icerik: "Tuzla fabrikasındaki yetkili mühendis ile numune testleri incelendi.", tarih: "20.10.2026")
    ]
    @State private var fiyatlar: [OzelFiyatKaydi] = [
        OzelFiyatKaydi(baslik: "Bilyalı Rulman 6204", tutar: 195.0, paraBirimi: "₺", aciklama: "Net peşin özel fiyat", tarih: "03.11.2026"),
        OzelFiyatKaydi(baslik: "Hidrolik Keçe 35x50", tutar: 72.0, paraBirimi: "₺", aciklama: "100 adet üzeri siparişte geçerli", tarih: "20.10.2026")
    ]
    @State private var gorseller: [GorselKaydi] = [
        GorselKaydi(baslik: "Müşteri Kartviziti", systemImageName: "person.crop.rectangle.fill", tarih: "03.11.2026"),
        GorselKaydi(baslik: "Fabrika Girişi & Numune", systemImageName: "building.2.crop.circle.fill", tarih: "20.10.2026")
    ]
    @State private var ozelNotlar: String = "Yetkili kişi Ahmet Bey her Çarşamba toplantıda oluyor. Teklifler doğrudan satın alma müdürü Mehmet Bey'e cc yapılmalı."
    
    // Modals
    @State private var showAddModal: Bool = false
    @State private var newItemTitle: String = ""
    @State private var newItemContent: String = ""
    @State private var newItemAmount: String = ""
    @State private var showShareSheet: Bool = false
    
    public init(kayit: MusteriTakipKayit) {
        self.kayit = kayit
    }
    
    public var body: some View {
        ZStack {
            AppTheme.background.ignoresSafeArea()
            
            VStack(spacing: 12) {
                // Müşteri Başlık Kartı
                GlassCard(cornerRadius: 18, padding: 16) {
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text(kayit.cariUnvan)
                                .font(.system(size: 18, weight: .bold))
                                .foregroundColor(AppTheme.textPrimary)
                            Spacer()
                            StatusBadge(title: kayit.durum, color: AppTheme.success)
                        }
                        
                        Text("Konu: \(kayit.konu)")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundColor(AppTheme.primary)
                        
                        if let eylem = kayit.sonrakiEylem {
                            HStack(spacing: 4) {
                                Image(systemName: "arrow.turn.down.right")
                                    .font(.system(size: 10))
                                    .foregroundColor(AppTheme.info)
                                Text("Sonraki Eylem: \(eylem) (\(kayit.sonrakiEylemTarihi ?? "-"))")
                                    .font(.system(size: 11, weight: .semibold))
                                    .foregroundColor(AppTheme.info)
                            }
                        }
                    }
                }
                .padding(.horizontal)
                .padding(.top, 4)
                
                // 4'lü Sekme Çubuğu
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(CRMDetailTab.allCases, id: \.self) { tab in
                            let isSelected = activeTab == tab
                            Button {
                                withAnimation(.spring(response: 0.25, dampingFraction: 0.8)) {
                                    activeTab = tab
                                }
                            } label: {
                                Text(tab.rawValue)
                                    .font(.system(size: 13, weight: isSelected ? .bold : .medium))
                                    .foregroundColor(isSelected ? .white : AppTheme.textSecondary)
                                    .padding(.horizontal, 14)
                                    .padding(.vertical, 8)
                                    .background(
                                        RoundedRectangle(cornerRadius: 10)
                                            .fill(isSelected ? AppTheme.primary : AppTheme.cardBackground)
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 10)
                                                    .stroke(isSelected ? AppTheme.primary : AppTheme.border, lineWidth: 1)
                                            )
                                    )
                            }
                        }
                    }
                    .padding(.horizontal)
                }
                
                // Sekme İçerikleri
                ScrollView {
                    VStack(spacing: 12) {
                        switch activeTab {
                        case .gorusmeler:
                            renderGorusmelerTab()
                        case .fiyatlar:
                            renderFiyatlarTab()
                        case .gorseller:
                            renderGorsellerTab()
                        case .notlar:
                            renderNotlarTab()
                        }
                        
                        // PDF Rapor Oluştur Butonu
                        ActionButton(
                            title: "Müşteri CRM Raporu Oluştur & Paylaş",
                            icon: "doc.text.fill",
                            color: AppTheme.primary
                        ) {
                            showShareSheet = true
                        }
                        .padding(.top, 10)
                        
                        Spacer().frame(height: 30)
                    }
                    .padding(.horizontal)
                }
            }
            
            // Yeni Öğe Ekleme Modalı
            SwipeableModal(isPresented: $showAddModal, title: "Yeni \(activeTab.rawValue) Kaydı") {
                VStack(spacing: 14) {
                    FormField(label: "Başlık *", text: $newItemTitle, placeholder: "Örn: Görüşme veya Ürün adı")
                    if activeTab == .fiyatlar {
                        FormField(label: "Özel Fiyat (₺) *", text: $newItemAmount, placeholder: "0.00")
                    }
                    FormField(label: "Açıklama / Detay", text: $newItemContent, placeholder: "Detaylı not...")
                    
                    ActionButton(title: "Kaydet", icon: "checkmark.circle.fill", color: AppTheme.primary) {
                        saveNewItem()
                    }
                }
            }
        }
        .navigationTitle("Müşteri Takip Kartı")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button {
                    newItemTitle = ""
                    newItemContent = ""
                    newItemAmount = ""
                    showAddModal = true
                } label: {
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 20))
                        .foregroundColor(AppTheme.primary)
                }
            }
        }
    }
    
    // MARK: - 1. Görüşmeler
    @ViewBuilder
    private func renderGorusmelerTab() -> some View {
        VStack(spacing: 10) {
            ForEach(gorusmeler) { g in
                GlassCard(cornerRadius: 14, padding: 14) {
                    VStack(alignment: .leading, spacing: 6) {
                        HStack {
                            Text(g.baslik)
                                .font(.system(size: 14, weight: .bold))
                                .foregroundColor(AppTheme.textPrimary)
                            Spacer()
                            Text(g.tarih)
                                .font(.system(size: 11))
                                .foregroundColor(AppTheme.textMuted)
                        }
                        Text(g.icerik)
                            .font(.system(size: 12))
                            .foregroundColor(AppTheme.textSecondary)
                    }
                }
            }
        }
    }
    
    // MARK: - 2. Özel Fiyatlar
    @ViewBuilder
    private func renderFiyatlarTab() -> some View {
        VStack(spacing: 10) {
            ForEach(fiyatlar) { f in
                GlassCard(cornerRadius: 14, padding: 14) {
                    HStack {
                        VStack(alignment: .leading, spacing: 3) {
                            Text(f.baslik)
                                .font(.system(size: 14, weight: .bold))
                                .foregroundColor(AppTheme.textPrimary)
                            Text("\(f.aciklama) • \(f.tarih)")
                                .font(.system(size: 11))
                                .foregroundColor(AppTheme.textMuted)
                        }
                        Spacer()
                        Text("\(AppFormatters.money(f.tutar))")
                            .font(.system(size: 15, weight: .heavy))
                            .foregroundColor(AppTheme.success)
                    }
                }
            }
        }
    }
    
    // MARK: - 3. Görseller & Fotoğraf
    @ViewBuilder
    private func renderGorsellerTab() -> some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
            ForEach(gorseller) { img in
                GlassCard(cornerRadius: 14, padding: 14) {
                    VStack(spacing: 10) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 10)
                                .fill(AppTheme.cardSecondary)
                                .frame(height: 90)
                            Image(systemName: img.systemImageName)
                                .font(.system(size: 36))
                                .foregroundColor(AppTheme.primary)
                        }
                        Text(img.baslik)
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(AppTheme.textPrimary)
                            .lineLimit(1)
                        Text(img.tarih)
                            .font(.system(size: 10))
                            .foregroundColor(AppTheme.textMuted)
                    }
                }
            }
        }
    }
    
    // MARK: - 4. Özel Notlar
    @ViewBuilder
    private func renderNotlarTab() -> some View {
        GlassCard(cornerRadius: 16, padding: 16) {
            VStack(alignment: .leading, spacing: 10) {
                Text("Müşteri Özel Not Defteri")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundColor(AppTheme.textSecondary)
                
                Text(ozelNotlar)
                    .font(.system(size: 13))
                    .foregroundColor(AppTheme.textPrimary)
                    .lineSpacing(4)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
    
    private func saveNewItem() {
        guard !newItemTitle.isEmpty else { return }
        let now = AppFormatters.isoDate.string(from: Date())
        
        switch activeTab {
        case .gorusmeler:
            gorusmeler.insert(GorusmeKaydi(baslik: newItemTitle, icerik: newItemContent, tarih: now), at: 0)
        case .fiyatlar:
            let tutar = Double(newItemAmount) ?? 0.0
            fiyatlar.insert(OzelFiyatKaydi(baslik: newItemTitle, tutar: tutar, paraBirimi: "₺", aciklama: newItemContent, tarih: now), at: 0)
        case .gorseller:
            gorseller.insert(GorselKaydi(baslik: newItemTitle, systemImageName: "photo.fill", tarih: now), at: 0)
        case .notlar:
            ozelNotlar = "\(ozelNotlar)\n\n[\(now)] \(newItemTitle): \(newItemContent)"
        }
        
        showAddModal = false
        HardwareService.shared.hapticSuccess()
    }
}

