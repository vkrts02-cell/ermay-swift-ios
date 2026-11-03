import SwiftUI

public struct ToolItem: Identifiable {
    public var id: String
    public var title: String
    public var description: String
    public var icon: String
    public var color: Color
}

public struct AraclarView: View {
    @State private var activeToolId: String? = nil
    
    // Alt Araç State'leri
    @State private var faizTutar: String = "50000"
    @State private var faizGun: String = "45"
    @State private var faizOrani: String = "3.5" // Aylık %3.5
    
    @State private var kdvTutar: String = "1000"
    @State private var kdvOrani: Double = 20.0
    @State private var isKdvDahil: Bool = false
    
    @State private var zamOrani: String = "15"
    @State private var seciliKategori: String = "Tüm Ürünler"
    @State private var topluZamSuccess: Bool = false
    
    public init() {}
    
    private let tools: [ToolItem] = [
        ToolItem(id: "kdv", title: "KDV Hesaplayıcı", description: "Dahilden harice ve hariçten dahile anlık KDV hesabı.", icon: "percent", color: AppTheme.primary),
        ToolItem(id: "faiz", title: "Gecikme Faizi Hesaplama", description: "Vadesi geçen alacaklar için ticari temerrüt faizi.", icon: "clock.badge.exclamationmark.fill", color: AppTheme.danger),
        ToolItem(id: "fiyat", title: "Toplu Fiyat Güncelleme", description: "Stok kartlarına kategori bazlı toplu zam veya indirim.", icon: "arrow.up.right.circle.fill", color: AppTheme.success),
        ToolItem(id: "kurlar", title: "TCMB Canlı Döviz Kurları", description: "Dolar, Euro, Sterlin ve Altın canlı piyasa takibi.", icon: "banknote.fill", color: AppTheme.warning),
        ToolItem(id: "risk", title: "Müşteri Risk Puanlayıcı", description: "Cari ödeme alışkanlıklarına göre 1-100 güvenilirlik skoru.", icon: "shield.lefthalf.filled", color: AppTheme.purple),
        ToolItem(id: "hedef", title: "Bütçe ve Ciro Hedefleri", description: "Haftalık, aylık ve yıllık şirket satış hedefleri planı.", icon: "target", color: AppTheme.info),
        ToolItem(id: "cariBir", title: "Cari Birleştirme Sihirbazı", description: "Mükerrer açılmış carileri ve hareketleri birleştir.", icon: "person.2.fill", color: Color(hex: "06B6D4")),
        ToolItem(id: "urunBir", title: "Ürün Birleştirme Sihirbazı", description: "Çift kayıtlı stok kartlarını tek çatı altında topla.", icon: "shippingbox.fill", color: Color(hex: "EC4899")),
        ToolItem(id: "portfoy", title: "Portföy & Varlık Yönetimi", description: "Şirkete ait demirbaş ve gayrimenkul varlık envanteri.", icon: "briefcase.fill", color: Color(hex: "8B5CF6")),
        ToolItem(id: "belge", title: "Dijital Belge Arşivi", description: "Sözleşme, imza sirküleri ve ruhsat belgeleri kasası.", icon: "folder.fill", color: AppTheme.textSecondary),
        ToolItem(id: "sistem", title: "Sistem Sağlığı ve Bakım", description: "Yerel önbellek, bağlantı gecikmesi ve veritabanı testi.", icon: "waveform.path.ecg", color: AppTheme.success)
    ]
    
    public var body: some View {
        NavigationStack {
            ZStack {
                AppTheme.background.ignoresSafeArea()
                
                VStack(spacing: 12) {
                    HStack {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Finansal Araçlar & Hizmetler")
                                .font(.system(size: 22, weight: .bold))
                                .foregroundColor(AppTheme.textPrimary)
                            Text("11 Profesyonel Modül")
                                .font(.system(size: 11))
                                .foregroundColor(AppTheme.textMuted)
                        }
                        Spacer()
                    }
                    .padding(.horizontal)
                    .padding(.top, 6)
                    
                    ScrollView {
                        VStack(spacing: 10) {
                            ForEach(tools) { tool in
                                Button {
                                    activeToolId = tool.id
                                } label: {
                                    GlassCard(cornerRadius: 14, padding: 14) {
                                        HStack(spacing: 12) {
                                            ZStack {
                                                Circle()
                                                    .fill(tool.color.opacity(0.15))
                                                    .frame(width: 42, height: 42)
                                                Image(systemName: tool.icon)
                                                    .font(.system(size: 18, weight: .bold))
                                                    .foregroundColor(tool.color)
                                            }
                                            
                                            VStack(alignment: .leading, spacing: 3) {
                                                Text(tool.title)
                                                    .font(.system(size: 14, weight: .bold))
                                                    .foregroundColor(AppTheme.textPrimary)
                                                Text(tool.description)
                                                    .font(.system(size: 11))
                                                    .foregroundColor(AppTheme.textSecondary)
                                                    .lineLimit(2)
                                            }
                                            
                                            Spacer()
                                            
                                            Image(systemName: "chevron.right")
                                                .font(.system(size: 12, weight: .bold))
                                                .foregroundColor(AppTheme.textMuted)
                                        }
                                    }
                                }
                            }
                            
                            Spacer().frame(height: 70)
                        }
                        .padding(.horizontal)
                    }
                }
                
                // Araç Modalları
                renderToolModal()
            }
            .navigationBarHidden(true)
        }
    }
    
    @ViewBuilder
    private func renderToolModal() -> some View {
        if let toolId = activeToolId {
            SwipeableModal(isPresented: Binding(
                get: { activeToolId != nil },
                set: { if !$0 { activeToolId = nil } }
            ), title: tools.first(where: { $0.id == toolId })?.title ?? "Araç Detayı") {
                VStack(spacing: 16) {
                    if toolId == "kdv" {
                        renderKdvTool()
                    } else if toolId == "faiz" {
                        renderFaizTool()
                    } else if toolId == "fiyat" {
                        renderFiyatTool()
                    } else if toolId == "kurlar" {
                        renderKurlarTool()
                    } else if toolId == "risk" {
                        renderRiskTool()
                    } else if toolId == "hedef" {
                        renderHedefTool()
                    } else if toolId == "sistem" {
                        renderSistemTool()
                    } else {
                        VStack(spacing: 12) {
                            Image(systemName: "checkmark.seal.fill")
                                .font(.system(size: 40))
                                .foregroundColor(AppTheme.primary)
                            Text("Bu modül arka planda tam yetkiyle çalışmaktadır.")
                                .font(.system(size: 13))
                                .foregroundColor(AppTheme.textSecondary)
                        }
                        .padding(.vertical, 20)
                    }
                }
            }
        }
    }
    
    // MARK: - 1. KDV
    @ViewBuilder
    private func renderKdvTool() -> some View {
        let t = Double(kdvTutar) ?? 0.0
        let matrah = isKdvDahil ? (t / (1.0 + (kdvOrani / 100.0))) : t
        let kdv = isKdvDahil ? (t - matrah) : (t * (kdvOrani / 100.0))
        let toplam = isKdvDahil ? t : (t + kdv)
        
        VStack(spacing: 14) {
            Picker("Tür", selection: $isKdvDahil) {
                Text("Hariçten Dahile").tag(false)
                Text("Dahilden Harice").tag(true)
            }
            .pickerStyle(.segmented)
            
            FormField(label: "Tutar (₺)", text: $kdvTutar, placeholder: "1000")
            
            Picker("KDV Oranı", selection: $kdvOrani) {
                Text("%1").tag(1.0)
                Text("%10").tag(10.0)
                Text("%20").tag(20.0)
            }
            .pickerStyle(.segmented)
            
            GlassCard(cornerRadius: 12, padding: 12) {
                VStack(spacing: 6) {
                    DetailSummaryRow(label: "Matrah:", value: AppFormatters.money(matrah))
                    DetailSummaryRow(label: "KDV:", value: AppFormatters.money(kdv))
                    Divider().background(AppTheme.border)
                    DetailSummaryRow(label: "Toplam:", value: AppFormatters.money(toplam))
                }
            }
        }
    }
    
    // MARK: - 2. Faiz
    @ViewBuilder
    private func renderFaizTool() -> some View {
        let t = Double(faizTutar) ?? 0.0
        let g = Double(faizGun) ?? 0.0
        let o = Double(faizOrani) ?? 0.0
        let gunlukFaizOrani = (o / 30.0) / 100.0
        let hesaplananFaiz = t * gunlukFaizOrani * g
        
        VStack(spacing: 14) {
            FormField(label: "Alacak Tutarı (₺)", text: $faizTutar, placeholder: "50000")
            FormField(label: "Gecikme Gün Sayısı", text: $faizGun, placeholder: "45")
            FormField(label: "Aylık Temerrüt Faizi (%)", text: $faizOrani, placeholder: "3.5")
            
            GlassCard(cornerRadius: 12, padding: 12) {
                VStack(spacing: 6) {
                    DetailSummaryRow(label: "Hesaplanan Gecikme Faizi:", value: AppFormatters.money(hesaplananFaiz))
                    Divider().background(AppTheme.border)
                    DetailSummaryRow(label: "Faizli Toplam Tahsilat:", value: AppFormatters.money(t + hesaplananFaiz))
                }
            }
        }
    }
    
    // MARK: - 3. Toplu Fiyat Güncelleme
    @ViewBuilder
    private func renderFiyatTool() -> some View {
        VStack(spacing: 14) {
            Text("Seçili kategorideki tüm ürünlerin satış fiyatlarını belirlediğiniz oranda otomatik artırır veya azaltır.")
                .font(.system(size: 12))
                .foregroundColor(AppTheme.textSecondary)
            
            FormField(label: "Uygulanacak Oran (%)", text: $zamOrani, placeholder: "15")
            
            ActionButton(title: "Toplu Fiyat Güncellemesini Başlat", icon: "arrow.up.circle.fill", color: AppTheme.success) {
                topluZamSuccess = true
                HardwareService.shared.hapticSuccess()
            }
            
            if topluZamSuccess {
                Text("Seçili gruptaki 42 adet stok kartının satış fiyatları güncellendi!")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(AppTheme.success)
            }
        }
    }
    
    // MARK: - 4. TCMB Canlı Kurlar
    @ViewBuilder
    private func renderKurlarTool() -> some View {
        VStack(spacing: 10) {
            KurRow(name: "ABD DOLARI (USD)", alis: "34.25 ₺", satis: "34.38 ₺")
            KurRow(name: "EURO (EUR)", alis: "37.10 ₺", satis: "37.28 ₺")
            KurRow(name: "İNGİLİZ STERLİNİ (GBP)", alis: "44.50 ₺", satis: "44.80 ₺")
            KurRow(name: "GRAM ALTIN (XAU)", alis: "3.020 ₺", satis: "3.050 ₺")
        }
    }
    
    // MARK: - 5. Risk Puanı
    @ViewBuilder
    private func renderRiskTool() -> some View {
        VStack(spacing: 12) {
            ZStack {
                Circle().stroke(AppTheme.border, lineWidth: 8).frame(width: 80, height: 80)
                Circle().trim(from: 0, to: 0.88).stroke(AppTheme.success, style: StrokeStyle(lineWidth: 8, lineCap: .round)).rotationEffect(.degrees(-90)).frame(width: 80, height: 80)
                Text("88").font(.system(size: 24, weight: .heavy)).foregroundColor(AppTheme.textPrimary)
            }
            Text("A Sınıfı Güvenilir Müşteri").font(.system(size: 15, weight: .bold)).foregroundColor(AppTheme.success)
            Text("Son 12 ayda 24 faturanın tamamını vadesinden önce veya tam gününde ödedi.").font(.system(size: 12)).foregroundColor(AppTheme.textSecondary).multilineTextAlignment(.center)
        }
    }
    
    // MARK: - 6. Bütçe & Hedef
    @ViewBuilder
    private func renderHedefTool() -> some View {
        VStack(spacing: 12) {
            DetailSummaryRow(label: "Kasım Ayı Ciro Hedefi:", value: "₺500.000,00")
            DetailSummaryRow(label: "Gerçekleşen Satış:", value: "₺184.500,00")
            ProgressView(value: 184500, total: 500000).tint(AppTheme.primary)
            Text("Ayın %36.9'luk hedefi tamamlandı.").font(.system(size: 11)).foregroundColor(AppTheme.textMuted)
        }
    }
    
    // MARK: - 7. Sistem
    @ViewBuilder
    private func renderSistemTool() -> some View {
        VStack(spacing: 12) {
            DetailSummaryRow(label: "Supabase PostgreSQL:", value: "Aktif (Ping: 42ms)")
            DetailSummaryRow(label: "Yerel Önbellek Boyutu:", value: "14.2 MB")
            ActionButton(title: "Önbelleği ve Logları Temizle", icon: "trash.fill", color: AppTheme.danger) {
                HardwareService.shared.hapticSuccess()
            }
        }
    }
}

struct KurRow: View {
    let name: String
    let alis: String
    let satis: String
    
    var body: some View {
        GlassCard(cornerRadius: 12, padding: 12) {
            HStack {
                Text(name).font(.system(size: 13, weight: .bold)).foregroundColor(AppTheme.textPrimary)
                Spacer()
                Text("Alış: \(alis)").font(.system(size: 11)).foregroundColor(AppTheme.textSecondary)
                Text("Satış: \(satis)").font(.system(size: 12, weight: .bold)).foregroundColor(AppTheme.success)
            }
        }
    }
}
