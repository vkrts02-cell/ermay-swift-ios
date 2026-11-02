import SwiftUI

public struct SiparisFormView: View {
    @Environment(\.dismiss) private var dismiss
    public var onSave: ((Siparis) -> Void)?
    
    @State private var siparisNo: String = "SIP-2026-\(Int.random(in: 100...999))"
    @State private var siparisTuru: String = "ALINAN"
    @State private var cariUnvan: String = ""
    @State private var teslimTarihi: Date = Calendar.current.date(byAdding: .day, value: 7, to: Date()) ?? Date()
    @State private var kalemler: [SiparisKalem] = []
    
    // Pickers
    @State private var showCariPicker: Bool = false
    @State private var showStokPicker: Bool = false
    @State private var showAddKalemSheet: Bool = false
    @State private var isSaving: Bool = false
    
    public init(onSave: ((Siparis) -> Void)? = nil) {
        self.onSave = onSave
    }
    
    public var araToplam: Double {
        kalemler.reduce(0.0) { $0 + ($1.miktar * $1.birimFiyat) }
    }
    
    public var kdvToplami: Double {
        kalemler.reduce(0.0) { $0 + ($1.miktar * $1.birimFiyat * ($1.kdvOrani / 100.0)) }
    }
    
    public var genelToplam: Double {
        araToplam + kdvToplami
    }
    
    public var body: some View {
        NavigationStack {
            ZStack {
                AppTheme.background.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 16) {
                        GlassCard(cornerRadius: 16, padding: 18) {
                            VStack(spacing: 14) {
                                FormField(label: "Sipariş No", text: $siparisNo, placeholder: "SIP-2026-001")
                                
                                Picker("Sipariş Türü", selection: $siparisTuru) {
                                    Text("Alınan Sipariş").tag("ALINAN")
                                    Text("Verilen Sipariş").tag("VERILEN")
                                }
                                .pickerStyle(.segmented)
                                
                                // Cari Seçici
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
                                            Text(cariUnvan.isEmpty ? "Cari Seçiniz..." : cariUnvan)
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
                                        .overlay(RoundedRectangle(cornerRadius: 10).stroke(AppTheme.border, lineWidth: 1))
                                    }
                                }
                                
                                HStack {
                                    Text("Teslim Tarihi")
                                        .font(.system(size: 12, weight: .semibold))
                                        .foregroundColor(AppTheme.textSecondary)
                                    Spacer()
                                    DatePicker("", selection: $teslimTarihi, displayedComponents: .date)
                                        .labelsHidden()
                                        .colorScheme(.dark)
                                }
                            }
                        }
                        
                        // Kalemler
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Text("Kalemler (\(kalemler.count))")
                                    .font(.system(size: 16, weight: .bold))
                                    .foregroundColor(AppTheme.textPrimary)
                                Spacer()
                                HStack(spacing: 8) {
                                    Button {
                                        showStokPicker = true
                                    } label: {
                                        Text("+ Stoktan Seç")
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
                                        Text("+ Manuel")
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
                                        Text("Henüz kalem eklenmedi.")
                                            .font(.system(size: 12))
                                            .foregroundColor(AppTheme.textMuted)
                                        Spacer()
                                    }
                                }
                            } else {
                                ForEach(kalemler.indices, id: \.self) { idx in
                                    let k = kalemler[idx]
                                    GlassCard(cornerRadius: 12, padding: 12) {
                                        HStack {
                                            VStack(alignment: .leading, spacing: 3) {
                                                Text(k.stokAdi)
                                                    .font(.system(size: 13, weight: .bold))
                                                    .foregroundColor(AppTheme.textPrimary)
                                                Text("\(String(format: "%.0f", k.miktar)) x \(AppFormatters.money(k.birimFiyat))")
                                                    .font(.system(size: 11))
                                                    .foregroundColor(AppTheme.textMuted)
                                            }
                                            Spacer()
                                            Text(AppFormatters.money(k.tutar))
                                                .font(.system(size: 14, weight: .bold))
                                                .foregroundColor(AppTheme.textPrimary)
                                            
                                            Button {
                                                kalemler.remove(at: idx)
                                            } label: {
                                                Image(systemName: "trash")
                                                    .foregroundColor(AppTheme.danger)
                                            }
                                            .padding(.leading, 8)
                                        }
                                    }
                                }
                            }
                        }
                        
                        // Toplam
                        GlassCard(cornerRadius: 16, padding: 16) {
                            VStack(spacing: 8) {
                                DetailSummaryRow(label: "Ara Toplam", value: AppFormatters.money(araToplam))
                                DetailSummaryRow(label: "KDV Toplamı", value: AppFormatters.money(kdvToplami))
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
                        
                        ActionButton(
                            title: isSaving ? "Kaydediliyor..." : "Siparişi Kaydet",
                            icon: "checkmark.circle.fill",
                            color: AppTheme.primary
                        ) {
                            saveSiparis()
                        }
                        .disabled(isSaving)
                        
                        Spacer().frame(height: 20)
                    }
                    .padding()
                }
            }
            .navigationTitle("Yeni Sipariş")
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
                }
            }
            .sheet(isPresented: $showStokPicker) {
                StokPickerSheet { selectedStok in
                    let k = SiparisKalem(
                        stokAdi: selectedStok.stokAdi,
                        miktar: 1.0,
                        birimFiyat: selectedStok.satisFiyati,
                        kdvOrani: selectedStok.kdvOrani
                    )
                    self.kalemler.append(k)
                }
            }
            .sheet(isPresented: $showAddKalemSheet) {
                AddSiparisKalemView { k in
                    self.kalemler.append(k)
                }
            }
        }
    }
    
    private func saveSiparis() {
        guard !cariUnvan.isEmpty else { return }
        isSaving = true
        
        let newS = Siparis(
            siparisNo: siparisNo,
            siparisTuru: siparisTuru,
            cariUnvan: cariUnvan,
            tarih: AppFormatters.isoDate.string(from: Date()),
            teslimTarihi: AppFormatters.isoDate.string(from: teslimTarihi),
            araToplam: araToplam,
            kdvToplami: kdvToplami,
            genelToplam: genelToplam,
            kalemler: kalemler
        )
        
        Task {
            do {
                try await SupabaseService.shared.insert(into: "siparisler", item: newS)
                await MainActor.run {
                    onSave?(newS)
                    dismiss()
                }
            } catch {
                await MainActor.run {
                    onSave?(newS)
                    dismiss()
                }
            }
        }
    }
}

struct AddSiparisKalemView: View {
    @Environment(\.dismiss) private var dismiss
    public var onAdd: (SiparisKalem) -> Void
    
    @State private var stokAdi: String = ""
    @State private var miktar: String = "1"
    @State private var birimFiyat: String = "0"
    @State private var kdvOrani: Double = 20.0
    
    var body: some View {
        NavigationStack {
            ZStack {
                AppTheme.background.ignoresSafeArea()
                VStack(spacing: 16) {
                    GlassCard(cornerRadius: 16, padding: 18) {
                        VStack(spacing: 14) {
                            FormField(label: "Ürün Adı", text: $stokAdi, placeholder: "Örn: Flanş")
                            FormField(label: "Miktar", text: $miktar, placeholder: "1")
                            FormField(label: "Birim Fiyat", text: $birimFiyat, placeholder: "0.00")
                        }
                    }
                    ActionButton(title: "Ekle", icon: "plus.circle.fill", color: AppTheme.primary) {
                        let k = SiparisKalem(
                            stokAdi: stokAdi,
                            miktar: Double(miktar) ?? 1.0,
                            birimFiyat: Double(birimFiyat) ?? 0.0,
                            kdvOrani: kdvOrani
                        )
                        onAdd(k)
                        dismiss()
                    }
                    Spacer()
                }
                .padding()
            }
            .navigationTitle("Kalem Ekle")
        }
    }
}
