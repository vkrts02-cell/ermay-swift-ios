import SwiftUI

public struct FaturaFormView: View {
    @Environment(\.dismiss) private var dismiss
    public var onSave: ((Fatura) -> Void)?
    
    @State private var faturaNo: String = "FTR-\(Int.random(in: 1000...9999))"
    @State private var faturaTuru: String = "SATIS"
    @State private var cariUnvan: String = ""
    @State private var cariId: String? = nil
    @State private var tarih: Date = Date()
    @State private var vadeTarihi: Date = Date().addingTimeInterval(86400 * 30)
    @State private var kalemler: [FaturaKalem] = []
    @State private var aciklama: String = ""
    @State private var isSaving: Bool = false
    @State private var errorMessage: String? = nil
    
    // Pickers
    @State private var showCariPicker: Bool = false
    @State private var showStokPicker: Bool = false
    @State private var showAddKalemSheet: Bool = false
    
    public init(onSave: ((Fatura) -> Void)? = nil) {
        self.onSave = onSave
    }
    
    public var araToplam: Double {
        kalemler.reduce(0.0) { $0 + ($1.miktar * $1.birimFiyat) }
    }
    
    public var iskontoToplami: Double {
        kalemler.reduce(0.0) { $0 + $1.iskontoTutari }
    }
    
    public var kdvToplami: Double {
        kalemler.reduce(0.0) { $0 + $1.kdvTutari }
    }
    
    public var genelToplam: Double {
        araToplam - iskontoToplami + kdvToplami
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
                        
                        // Fatura Bilgileri Kartı
                        GlassCard(cornerRadius: 16, padding: 18) {
                            VStack(spacing: 14) {
                                FormField(label: "Fatura No *", text: $faturaNo, placeholder: "FTR-2026-0001")
                                
                                VStack(alignment: .leading, spacing: 6) {
                                    Text("Fatura Türü")
                                        .font(.system(size: 12, weight: .semibold))
                                        .foregroundColor(AppTheme.textSecondary)
                                    
                                    Picker("Fatura Türü", selection: $faturaTuru) {
                                        Text("Satış Faturası").tag("SATIS")
                                        Text("Alış Faturası").tag("ALIS")
                                    }
                                    .pickerStyle(.segmented)
                                }
                                
                                // Cari Seçici Kutusu (Dokunarak Seç)
                                VStack(alignment: .leading, spacing: 6) {
                                    Text("Cari / Müşteri *")
                                        .font(.system(size: 12, weight: .semibold))
                                        .foregroundColor(AppTheme.textSecondary)
                                    
                                    Button {
                                        showCariPicker = true
                                    } label: {
                                        HStack {
                                            Image(systemName: "person.crop.circle")
                                                .foregroundColor(AppTheme.primary)
                                            Text(cariUnvan.isEmpty ? "Cari Kart Seçin..." : cariUnvan)
                                                .font(.system(size: 13, weight: cariUnvan.isEmpty ? .regular : .bold))
                                                .foregroundColor(cariUnvan.isEmpty ? AppTheme.textMuted : AppTheme.textPrimary)
                                            Spacer()
                                            Image(systemName: "chevron.down")
                                                .font(.system(size: 12))
                                                .foregroundColor(AppTheme.textMuted)
                                        }
                                        .padding(.horizontal, 14)
                                        .padding(.vertical, 12)
                                        .background(AppTheme.cardBackground)
                                        .cornerRadius(10)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 10)
                                                .stroke(AppTheme.border, lineWidth: 1)
                                        )
                                    }
                                }
                                
                                HStack(spacing: 12) {
                                    VStack(alignment: .leading, spacing: 6) {
                                        Text("Tarih")
                                            .font(.system(size: 12, weight: .semibold))
                                            .foregroundColor(AppTheme.textSecondary)
                                        DatePicker("", selection: $tarih, displayedComponents: .date)
                                            .labelsHidden()
                                    }
                                    Spacer()
                                    VStack(alignment: .trailing, spacing: 6) {
                                        Text("Vade Tarihi")
                                            .font(.system(size: 12, weight: .semibold))
                                            .foregroundColor(AppTheme.textSecondary)
                                        DatePicker("", selection: $vadeTarihi, displayedComponents: .date)
                                            .labelsHidden()
                                    }
                                }
                            }
                        }
                        
                        // Kalemler Kartı
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Text("Fatura Kalemleri (\(kalemler.count))")
                                    .font(.system(size: 16, weight: .bold))
                                    .foregroundColor(AppTheme.textPrimary)
                                
                                Spacer()
                                
                                HStack(spacing: 8) {
                                    Button {
                                        showStokPicker = true
                                    } label: {
                                        HStack(spacing: 4) {
                                            Image(systemName: "shippingbox.fill")
                                            Text("Stoktan Seç")
                                        }
                                        .font(.system(size: 12, weight: .bold))
                                        .foregroundColor(Color(hex: "00FF87"))
                                        .padding(.horizontal, 10)
                                        .padding(.vertical, 6)
                                        .background(Color(hex: "00FF87").opacity(0.12))
                                        .cornerRadius(8)
                                    }
                                    
                                    Button {
                                        showAddKalemSheet = true
                                    } label: {
                                        HStack(spacing: 4) {
                                            Image(systemName: "plus.circle.fill")
                                            Text("Manuel Ekle")
                                        }
                                        .font(.system(size: 12, weight: .semibold))
                                        .foregroundColor(AppTheme.primary)
                                        .padding(.horizontal, 8)
                                        .padding(.vertical, 6)
                                        .background(AppTheme.primary.opacity(0.12))
                                        .cornerRadius(8)
                                    }
                                }
                            }
                            
                            if kalemler.isEmpty {
                                GlassCard(cornerRadius: 14, padding: 18) {
                                    HStack {
                                        Spacer()
                                        Text("Henüz kalem eklenmedi. 'Stoktan Seç' veya 'Manuel Ekle' ile başlayın.")
                                            .font(.system(size: 12))
                                            .foregroundColor(AppTheme.textMuted)
                                        Spacer()
                                    }
                                }
                            } else {
                                VStack(spacing: 8) {
                                    ForEach(kalemler.indices, id: \.self) { idx in
                                        let k = kalemler[idx]
                                        GlassCard(cornerRadius: 12, padding: 12) {
                                            VStack(spacing: 8) {
                                                HStack {
                                                    VStack(alignment: .leading, spacing: 3) {
                                                        Text(k.stokAdi)
                                                            .font(.system(size: 13, weight: .bold))
                                                            .foregroundColor(AppTheme.textPrimary)
                                                        Text("\(String(format: "%.0f", k.miktar)) x \(AppFormatters.money(k.birimFiyat)) (KDV %\(Int(k.kdvOrani)))")
                                                            .font(.system(size: 11))
                                                            .foregroundColor(AppTheme.textMuted)
                                                    }
                                                    Spacer()
                                                    Text(AppFormatters.money(k.netTutar))
                                                        .font(.system(size: 14, weight: .heavy))
                                                        .foregroundColor(AppTheme.textPrimary)
                                                    
                                                    Button {
                                                        kalemler.remove(at: idx)
                                                    } label: {
                                                        Image(systemName: "trash")
                                                            .font(.system(size: 14))
                                                            .foregroundColor(AppTheme.danger)
                                                    }
                                                    .padding(.leading, 8)
                                                }
                                                
                                                // Miktar Artır/Azalt Kontrolü
                                                HStack {
                                                    Button {
                                                        if kalemler[idx].miktar > 1 {
                                                            kalemler[idx].miktar -= 1
                                                        }
                                                    } label: {
                                                        Image(systemName: "minus.circle.fill")
                                                            .foregroundColor(AppTheme.textSecondary)
                                                    }
                                                    Text("\(String(format: "%.0f", kalemler[idx].miktar))")
                                                        .font(.system(size: 12, weight: .bold))
                                                        .foregroundColor(AppTheme.textPrimary)
                                                        .frame(minWidth: 24)
                                                    Button {
                                                        kalemler[idx].miktar += 1
                                                    } label: {
                                                        Image(systemName: "plus.circle.fill")
                                                            .foregroundColor(AppTheme.primary)
                                                    }
                                                    Spacer()
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                        
                        // Özet Kartı
                        GlassCard(cornerRadius: 16, padding: 18) {
                            VStack(spacing: 10) {
                                DetailSummaryRow(label: "Ara Toplam", value: AppFormatters.money(araToplam))
                                DetailSummaryRow(label: "İskonto Toplamı", value: "-" + AppFormatters.money(iskontoToplami))
                                DetailSummaryRow(label: "KDV Toplamı", value: "+" + AppFormatters.money(kdvToplami))
                                
                                Divider().background(AppTheme.border)
                                
                                HStack {
                                    Text("GENEL TOPLAM")
                                        .font(.system(size: 14, weight: .bold))
                                        .foregroundColor(AppTheme.textPrimary)
                                    Spacer()
                                    Text(AppFormatters.money(genelToplam))
                                        .font(.system(size: 20, weight: .heavy))
                                        .foregroundColor(AppTheme.primary)
                                }
                            }
                        }
                        
                        FormField(label: "Fatura Açıklaması / Dipnot", text: $aciklama, placeholder: "Fatura ile ilgili notlar...")
                        
                        ActionButton(
                            title: isSaving ? "Kaydediliyor..." : "Faturayı Kaydet",
                            icon: "checkmark.circle.fill",
                            color: AppTheme.success
                        ) {
                            saveFatura()
                        }
                        .disabled(isSaving)
                        
                        Spacer().frame(height: 20)
                    }
                    .padding()
                }
            }
            .navigationTitle("Fatura Düzenle")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("İptal") { dismiss() }
                        .foregroundColor(AppTheme.textSecondary)
                }
            }
            .sheet(isPresented: $showCariPicker) {
                CariPickerSheet { selected in
                    self.cariUnvan = selected.unvan
                    self.cariId = selected.id
                    if let vg = selected.vadeGunu, vg > 0 {
                        self.vadeTarihi = Date().addingTimeInterval(TimeInterval(vg * 86400))
                    }
                }
            }
            .sheet(isPresented: $showStokPicker) {
                StokPickerSheet { selectedStok in
                    let kalem = FaturaKalem(
                        stokAdi: selectedStok.stokAdi,
                        miktar: 1.0,
                        birimFiyat: selectedStok.satisFiyati,
                        kdvOrani: selectedStok.kdvOrani,
                        iskontoOrani: 0.0,
                        birim: selectedStok.birim
                    )
                    self.kalemler.append(kalem)
                }
            }
            .sheet(isPresented: $showAddKalemSheet) {
                AddKalemView { newKalem in
                    self.kalemler.append(newKalem)
                }
            }
        }
    }
    
    private func saveFatura() {
        guard !kalemler.isEmpty else {
            errorMessage = "Lütfen en az bir kalem ekleyiniz."
            return
        }
        guard !cariUnvan.trimmingCharacters(in: .whitespaces).isEmpty else {
            errorMessage = "Cari unvanı boş olamaz."
            return
        }
        
        isSaving = true
        errorMessage = nil
        
        let newFatura = Fatura(
            id: UUID().uuidString,
            faturaNo: faturaNo,
            faturaTuru: faturaTuru,
            cariUnvan: cariUnvan,
            tarih: AppFormatters.isoDate.string(from: tarih),
            vadeTarihi: AppFormatters.isoDate.string(from: vadeTarihi),
            araToplam: araToplam,
            kdvToplami: kdvToplami,
            iskontoToplami: iskontoToplami,
            genelToplam: genelToplam,
            odemeDurumu: "BEKLIYOR",
            aciklama: aciklama.isEmpty ? nil : aciklama,
            kalemler: kalemler
        )
        
        Task {
            do {
                let saved: Fatura = try await SupabaseService.shared.insert(into: "faturalar", item: newFatura)
                await MainActor.run {
                    onSave?(saved)
                    dismiss()
                }
            } catch {
                await MainActor.run {
                    OfflineQueueService.shared.enqueue(action: "INSERT", table: "faturalar", recordId: newFatura.id, payload: try? JSONEncoder().encode(newFatura))
                    onSave?(newFatura)
                    dismiss()
                }
            }
        }
    }
}

struct AddKalemView: View {
    @Environment(\.dismiss) private var dismiss
    public var onAdd: (FaturaKalem) -> Void
    
    @State private var stokAdi: String = ""
    @State private var miktar: String = "1"
    @State private var birimFiyat: String = "0"
    @State private var kdvOrani: Double = 20.0
    @State private var iskontoOrani: String = "0"
    
    var body: some View {
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
