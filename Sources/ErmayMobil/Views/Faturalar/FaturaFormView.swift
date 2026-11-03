import SwiftUI

public struct FaturaFormView: View {
    @Environment(\.dismiss) private var dismiss
    public var onSave: ((Fatura) -> Void)?
    
    // Fatura Başlık Bilgileri
    @State private var faturaNo: String = "FTR-2026-\(Int.random(in: 1000...9999))"
    @State private var tur: String = "Satış"
    @State private var durum: String = "Açık"
    @State private var odemeSekli: String = "Açık Hesap"
    @State private var tarih: Date = Date()
    @State private var vadeTarihi: Date = Calendar.current.date(byAdding: .day, value: 30, to: Date()) ?? Date()
    @State private var dovizTuru: String = "TL"
    @State private var dovizKuru: String = "1.00"
    @State private var baglantiEvrakNo: String = ""
    @State private var aciklama: String = ""
    
    // Cari & Hesap Seçimleri
    @State private var selectedCari: CariKart? = nil
    @State private var showCariPicker: Bool = false
    @State private var availableCariler: [CariKart] = [
        CariKart(cariKodu: "CR-001", unvan: "Ermay Bilişim Ltd. Şti.", cariTuru: "Müşteri", bakiye: 45200),
        CariKart(cariKodu: "CR-002", unvan: "Akıncılar Çelik Döküm A.Ş.", cariTuru: "Tedarikçi", bakiye: 18500),
        CariKart(cariKodu: "CR-003", unvan: "Mega Plastik İth. İhr.", cariTuru: "Müşteri", bakiye: 8900)
    ]
    @State private var kasaId: String = "1"
    @State private var bankaId: String = "3"
    
    // Kalemler & Tevkifat
    @State private var items: [FaturaKalem] = []
    @State private var showAddKalemSheet: Bool = false
    @State private var tevkifatOrani: Double = 0.0 // 0, 0.2, 0.3, 0.5, 0.7, 0.9
    
    // Form İşlem Durumu
    @State private var isSaving: Bool = false
    @State private var errorMessage: String? = nil
    
    public init(initialTur: String = "SATIS", onSave: ((Fatura) -> Void)? = nil) {
        self._tur = State(initialValue: initialTur.uppercased().contains("ALIS") ? "Alış" : "Satış")
        self.onSave = onSave
    }
    
    public var araToplam: Double {
        items.reduce(0.0) { $0 + ($1.miktar * $1.birimFiyat) }
    }
    
    public var iskontoToplami: Double {
        items.reduce(0.0) { $0 + $1.iskontoTutari }
    }
    
    public var kdvToplami: Double {
        items.reduce(0.0) { $0 + $1.kdvTutari }
    }
    
    public var tevkifatTutari: Double {
        kdvToplami * tevkifatOrani
    }
    
    public var genelToplam: Double {
        araToplam - iskontoToplami + (kdvToplami - tevkifatTutari)
    }
    
    public var body: some View {
        NavigationStack {
            ZStack {
                AppTheme.background.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 16) {
                        if let err = errorMessage {
                            Text(err)
                                .font(.system(size: 13, weight: .bold))
                                .foregroundColor(AppTheme.danger)
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(AppTheme.dangerMuted.opacity(0.4))
                                .cornerRadius(10)
                        }
                        
                        // Fatura Türü & Temel Başlık Bilgileri
                        GlassCard(cornerRadius: 16, padding: 16) {
                            VStack(spacing: 14) {
                                HStack {
                                    Text("FATURA BİLGİLERİ")
                                        .font(.system(size: 11, weight: .bold))
                                        .foregroundColor(AppTheme.textSecondary)
                                    Spacer()
                                    Picker("Fatura Türü", selection: $tur) {
                                        Text("Satış Faturası").tag("Satış")
                                        Text("Alış Faturası").tag("Alış")
                                    }
                                    .pickerStyle(.segmented)
                                    .frame(width: 200)
                                }
                                
                                FormField(label: "Fatura No *", text: $faturaNo, placeholder: "FTR-2026-0001")
                                
                                // Cari Seçim Alanı
                                VStack(alignment: .leading, spacing: 6) {
                                    Text("Cari / Müşteri *")
                                        .font(.system(size: 12, weight: .semibold))
                                        .foregroundColor(AppTheme.textSecondary)
                                    
                                    Button {
                                        showCariPicker = true
                                    } label: {
                                        HStack {
                                            Text(selectedCari?.unvan ?? "Cari Seçiniz...")
                                                .font(.system(size: 14, weight: selectedCari == nil ? .regular : .bold))
                                                .foregroundColor(selectedCari == nil ? AppTheme.textMuted : AppTheme.textPrimary)
                                            Spacer()
                                            Image(systemName: "chevron.down")
                                                .font(.system(size: 12))
                                                .foregroundColor(AppTheme.textMuted)
                                        }
                                        .padding(12)
                                        .background(AppTheme.cardSecondary)
                                        .cornerRadius(10)
                                    }
                                }
                                
                                // Tarih ve Vade Tarihi
                                HStack(spacing: 12) {
                                    VStack(alignment: .leading, spacing: 6) {
                                        Text("Fatura Tarihi")
                                            .font(.system(size: 12, weight: .semibold))
                                            .foregroundColor(AppTheme.textSecondary)
                                        DatePicker("", selection: $tarih, displayedComponents: .date)
                                            .labelsHidden()
                                            .colorScheme(.dark)
                                    }
                                    Spacer()
                                    VStack(alignment: .trailing, spacing: 6) {
                                        Text("Vade Tarihi")
                                            .font(.system(size: 12, weight: .semibold))
                                            .foregroundColor(AppTheme.textSecondary)
                                        DatePicker("", selection: $vadeTarihi, displayedComponents: .date)
                                            .labelsHidden()
                                            .colorScheme(.dark)
                                    }
                                }
                            }
                        }
                        
                        // Ödeme ve Kasa/Banka Entegrasyonu (Açık vs Kapalı Fatura)
                        GlassCard(cornerRadius: 16, padding: 16) {
                            VStack(spacing: 14) {
                                Text("ÖDEME VE TAHSİLAT KOŞULLARI")
                                    .font(.system(size: 11, weight: .bold))
                                    .foregroundColor(AppTheme.textSecondary)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                
                                VStack(alignment: .leading, spacing: 6) {
                                    Text("Ödeme Şekli")
                                        .font(.system(size: 12, weight: .semibold))
                                        .foregroundColor(AppTheme.textSecondary)
                                    Picker("Ödeme Şekli", selection: $odemeSekli) {
                                        Text("Açık Hesap (Vadeli)").tag("Açık Hesap")
                                        Text("Nakit (Peşin)").tag("Nakit")
                                        Text("Kredi Kartı / POS").tag("Kredi Kartı")
                                    }
                                    .pickerStyle(.segmented)
                                }
                                
                                if odemeSekli == "Nakit" {
                                    HStack {
                                        Text("İşlem Yapılacak Kasa:")
                                            .font(.system(size: 12))
                                            .foregroundColor(AppTheme.textSecondary)
                                        Spacer()
                                        Text("Merkez TL Kasası")
                                            .font(.system(size: 12, weight: .bold))
                                            .foregroundColor(AppTheme.success)
                                    }
                                } else if odemeSekli == "Kredi Kartı" {
                                    HStack {
                                        Text("İşlem Yapılacak POS/Banka:")
                                            .font(.system(size: 12))
                                            .foregroundColor(AppTheme.textSecondary)
                                        Spacer()
                                        Text("Garanti BBVA POS")
                                            .font(.system(size: 12, weight: .bold))
                                            .foregroundColor(AppTheme.purple)
                                    }
                                }
                                
                                // Döviz Seçimi
                                HStack(spacing: 12) {
                                    VStack(alignment: .leading, spacing: 6) {
                                        Text("Para Birimi")
                                            .font(.system(size: 12, weight: .semibold))
                                            .foregroundColor(AppTheme.textSecondary)
                                        Picker("Döviz", selection: $dovizTuru) {
                                            Text("TL (₺)").tag("TL")
                                            Text("USD ($)").tag("USD")
                                            Text("EUR (€)").tag("EUR")
                                        }
                                        .pickerStyle(.segmented)
                                    }
                                    
                                    if dovizTuru != "TL" {
                                        FormField(label: "Döviz Kuru", text: $dovizKuru, placeholder: "1.00")
                                            .frame(width: 120)
                                    }
                                }
                                
                                FormField(label: "Bağlantılı İrsaliye / Sipariş No", text: $baglantiEvrakNo, placeholder: "İRS-2026-0041")
                            }
                        }
                        
                        // Kalemler Tablosu
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Text("Fatura Kalemleri (\(items.count))")
                                    .font(.system(size: 16, weight: .bold))
                                    .foregroundColor(AppTheme.textPrimary)
                                Spacer()
                                Button {
                                    showAddKalemSheet = true
                                } label: {
                                    HStack(spacing: 4) {
                                        Image(systemName: "plus.circle.fill")
                                        Text("Kalem Ekle")
                                    }
                                    .font(.system(size: 13, weight: .bold))
                                    .foregroundColor(AppTheme.primary)
                                }
                            }
                            
                            if items.isEmpty {
                                GlassCard(cornerRadius: 14, padding: 20) {
                                    HStack {
                                        Spacer()
                                        Text("Faturaya ait henüz bir ürün veya hizmet kalemi eklenmedi.")
                                            .font(.system(size: 12))
                                            .foregroundColor(AppTheme.textMuted)
                                        Spacer()
                                    }
                                }
                            } else {
                                VStack(spacing: 8) {
                                    ForEach(items.indices, id: \.self) { idx in
                                        let k = items[idx]
                                        GlassCard(cornerRadius: 12, padding: 12) {
                                            HStack {
                                                VStack(alignment: .leading, spacing: 3) {
                                                    Text(k.stokAdi)
                                                        .font(.system(size: 13, weight: .bold))
                                                        .foregroundColor(AppTheme.textPrimary)
                                                    Text("\(String(format: "%.2f", k.miktar)) x \(AppFormatters.money(k.birimFiyat)) (KDV %\(Int(k.kdvOrani))) \(k.iskontoOrani > 0 ? "İsk: %\(Int(k.iskontoOrani))" : "")")
                                                        .font(.system(size: 11))
                                                        .foregroundColor(AppTheme.textMuted)
                                                }
                                                Spacer()
                                                Text(AppFormatters.money(k.netTutar))
                                                    .font(.system(size: 13, weight: .bold))
                                                    .foregroundColor(AppTheme.textPrimary)
                                                
                                                Button {
                                                    items.remove(at: idx)
                                                } label: {
                                                    Image(systemName: "trash")
                                                        .font(.system(size: 14))
                                                        .foregroundColor(AppTheme.danger)
                                                }
                                                .padding(.leading, 8)
                                            }
                                        }
                                    }
                                }
                            }
                        }
                        
                        // Tevkifat Seçimi
                        GlassCard(cornerRadius: 14, padding: 14) {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("KDV Tevkifat Uygulaması")
                                    .font(.system(size: 12, weight: .semibold))
                                    .foregroundColor(AppTheme.textSecondary)
                                
                                Picker("Tevkifat", selection: $tevkifatOrani) {
                                    Text("Tevkifatsız (Yok)").tag(0.0)
                                    Text("2/10").tag(0.2)
                                    Text("3/10").tag(0.3)
                                    Text("5/10").tag(0.5)
                                    Text("7/10").tag(0.7)
                                    Text("9/10").tag(0.9)
                                }
                                .pickerStyle(.segmented)
                            }
                        }
                        
                        // Hesaplanan Toplamlar Özeti
                        GlassCard(cornerRadius: 16, padding: 16) {
                            VStack(spacing: 8) {
                                DetailSummaryRow(label: "Brüt Ara Toplam:", value: AppFormatters.money(araToplam))
                                DetailSummaryRow(label: "Toplam İskonto:", value: "-\(AppFormatters.money(iskontoToplami))")
                                DetailSummaryRow(label: "Hesaplanan KDV:", value: AppFormatters.money(kdvToplami))
                                
                                if tevkifatTutari > 0 {
                                    DetailSummaryRow(label: "Tevkif Edilen KDV:", value: "-\(AppFormatters.money(tevkifatTutari))")
                                }
                                
                                Divider().background(AppTheme.border)
                                
                                HStack {
                                    Text("ÖDENECEK GENEL TOPLAM:")
                                        .font(.system(size: 13, weight: .bold))
                                        .foregroundColor(AppTheme.textPrimary)
                                    Spacer()
                                    Text(AppFormatters.money(genelToplam))
                                        .font(.system(size: 20, weight: .heavy))
                                        .foregroundColor(AppTheme.primary)
                                }
                            }
                        }
                        
                        // Kaydet Butonu
                        ActionButton(
                            title: isSaving ? "Fatura İşleniyor (Çift Taraflı Kayıt)..." : "Faturayı Onayla & Kaydet",
                            icon: "checkmark.circle.fill",
                            color: AppTheme.primary
                        ) {
                            saveFaturaWithTransaction()
                        }
                        .disabled(isSaving)
                        
                        Spacer().frame(height: 20)
                    }
                    .padding()
                }
                
                // Cari Seçici Overlay Modalı
                SwipeableModal(isPresented: $showCariPicker, title: "Cari Seçiniz") {
                    VStack(spacing: 8) {
                        ForEach(availableCariler) { cari in
                            Button {
                                selectedCari = cari
                                showCariPicker = false
                                HardwareService.shared.hapticSuccess()
                            } label: {
                                GlassCard(cornerRadius: 12, padding: 12) {
                                    HStack {
                                        VStack(alignment: .leading, spacing: 2) {
                                            Text(cari.unvan)
                                                .font(.system(size: 14, weight: .bold))
                                                .foregroundColor(AppTheme.textPrimary)
                                            Text(cari.cariTuru ?? "Müşteri")
                                                .font(.system(size: 11))
                                                .foregroundColor(AppTheme.textMuted)
                                        }
                                        Spacer()
                                        Text(AppFormatters.money(cari.bakiye))
                                            .font(.system(size: 13, weight: .bold))
                                            .foregroundColor(cari.bakiyeTuru == "B" ? AppTheme.danger : AppTheme.success)
                                    }
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle("Yeni Fatura Girişi")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("İptal") { dismiss() }
                        .foregroundColor(AppTheme.textSecondary)
                }
            }
            .sheet(isPresented: $showAddKalemSheet) {
                AddKalemView { k in
                    items.append(k)
                }
            }
        }
    }
    
    private func saveFaturaWithTransaction() {
        guard let cari = selectedCari else {
            errorMessage = "Lütfen işlem yapılacak cariyi seçiniz."
            return
        }
        guard !items.isEmpty else {
            errorMessage = "Lütfen en az bir adet ürün veya hizmet kalemi ekleyiniz."
            return
        }
        
        isSaving = true
        errorMessage = nil
        
        let req = InvoiceTransactionRequest(
            faturaNo: faturaNo,
            tarih: AppFormatters.isoDate.string(from: tarih),
            vadeTarihi: AppFormatters.isoDate.string(from: vadeTarihi),
            cari: cari,
            tur: tur,
            durum: odemeSekli == "Açık Hesap" ? "Açık" : "Kapalı",
            odemeSekli: odemeSekli,
            kasaId: odemeSekli == "Nakit" ? kasaId : nil,
            bankaId: odemeSekli == "Kredi Kartı" ? bankaId : nil,
            dovizTuru: dovizTuru,
            dovizKuru: Double(dovizKuru) ?? 1.0,
            baglantiEvrakNo: baglantiEvrakNo,
            aciklama: aciklama,
            items: items
        )
        
        Task {
            do {
                let saved = try await TransactionService.shared.saveInvoiceTransaction(req: req)
                await MainActor.run {
                    HardwareService.shared.hapticSuccess()
                    onSave?(saved)
                    dismiss()
                }
            } catch {
                await MainActor.run {
                    errorMessage = "Fatura kaydedilirken hata: \(error.localizedDescription)"
                    isSaving = false
                }
            }
        }
    }
}

public struct AddKalemView: View {
    @Environment(\.dismiss) private var dismiss
    public var onAdd: (FaturaKalem) -> Void
    
    @State private var stokAdi: String = ""
    @State private var miktar: String = "1"
    @State private var birimFiyat: String = "0"
    @State private var kdvOrani: Double = 20.0
    @State private var iskontoOrani: String = "0"
    
    public init(onAdd: @escaping (FaturaKalem) -> Void) {
        self.onAdd = onAdd
    }
    
    public var body: some View {
        NavigationStack {
            ZStack {
                AppTheme.background.ignoresSafeArea()
                
                VStack(spacing: 16) {
                    GlassCard(cornerRadius: 16, padding: 18) {
                        VStack(spacing: 14) {
                            FormField(label: "Ürün / Hizmet Adı *", text: $stokAdi, placeholder: "Örn: Endüstriyel Rulman")
                            FormField(label: "Miktar", text: $miktar, placeholder: "1")
                            FormField(label: "Birim Fiyat (₺)", text: $birimFiyat, placeholder: "0.00")
                            
                            VStack(alignment: .leading, spacing: 6) {
                                Text("KDV Oranı: %\(Int(kdvOrani))")
                                    .font(.system(size: 12, weight: .semibold))
                                    .foregroundColor(AppTheme.textSecondary)
                                
                                Picker("KDV", selection: $kdvOrani) {
                                    Text("%0").tag(0.0)
                                    Text("%1").tag(1.0)
                                    Text("%10").tag(10.0)
                                    Text("%20").tag(20.0)
                                }
                                .pickerStyle(.segmented)
                            }
                            
                            FormField(label: "İskonto Oranı (%)", text: $iskontoOrani, placeholder: "0")
                        }
                    }
                    
                    ActionButton(title: "Kalemi Ekle", icon: "plus.circle.fill", color: AppTheme.primary) {
                        let m = Double(miktar) ?? 1.0
                        let bf = Double(birimFiyat) ?? 0.0
                        let isk = Double(iskontoOrani) ?? 0.0
                        
                        let kalem = FaturaKalem(
                            stokAdi: stokAdi.isEmpty ? "Ürün" : stokAdi,
                            miktar: m,
                            birimFiyat: bf,
                            kdvOrani: kdvOrani,
                            iskontoOrani: isk
                        )
                        onAdd(kalem)
                        dismiss()
                    }
                    
                    Spacer()
                }
                .padding()
            }
            .navigationTitle("Kalem Ekle")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Kapat") { dismiss() }
                        .foregroundColor(AppTheme.textSecondary)
                }
            }
        }
    }
}
