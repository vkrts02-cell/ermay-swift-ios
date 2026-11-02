import SwiftUI

public struct TeklifFormView: View {
    @Environment(\.dismiss) private var dismiss
    public var onSave: ((Teklif) -> Void)?
    
    @State private var teklifNo: String = "TKL-2026-\(Int.random(in: 100...999))"
    @State private var cariUnvan: String = ""
    @State private var gecerlilikTarihi: Date = Calendar.current.date(byAdding: .day, value: 15, to: Date()) ?? Date()
    @State private var kalemler: [TeklifKalem] = []
    
    @State private var showCariPicker: Bool = false
    @State private var showStokPicker: Bool = false
    @State private var showAddKalemSheet: Bool = false
    @State private var isSaving: Bool = false
    @State private var errorMessage: String? = nil
    
    public init(onSave: ((Teklif) -> Void)? = nil) {
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
                        if let err = errorMessage {
                            Text(err)
                                .font(.system(size: 13, weight: .bold))
                                .foregroundColor(AppTheme.danger)
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(AppTheme.dangerMuted.opacity(0.4))
                                .cornerRadius(10)
                        }
                        
                        // Teklif Bilgileri Kartı
                        GlassCard(cornerRadius: 16, padding: 18) {
                            VStack(spacing: 14) {
                                FormField(label: "Teklif No *", text: $teklifNo, placeholder: "TKL-2026-001")
                                
                                // Cari Seçici Kutusu
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
                                
                                HStack {
                                    Text("Geçerlilik Tarihi")
                                        .font(.system(size: 12, weight: .semibold))
                                        .foregroundColor(AppTheme.textSecondary)
                                    Spacer()
                                    DatePicker("", selection: $gecerlilikTarihi, displayedComponents: .date)
                                        .labelsHidden()
                                        .colorScheme(.dark)
                                }
                            }
                        }
                        
                        // Kalemler Kartı
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Text("Teklif Kalemleri (\(kalemler.count))")
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
                                            Text("Manuel")
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
                                        Text("Henüz teklif kalemi eklenmedi. 'Stoktan Seç' veya 'Manuel' ile başlayın.")
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
                                                Text("\(String(format: "%.2f", k.miktar)) x \(AppFormatters.money(k.birimFiyat)) • KDV %\(Int(k.kdvOrani))")
                                                    .font(.system(size: 11))
                                                    .foregroundColor(AppTheme.textMuted)
                                            }
                                            
                                            Spacer()
                                            
                                            Text(AppFormatters.money(k.tutar))
                                                .font(.system(size: 13, weight: .bold))
                                                .foregroundColor(AppTheme.textPrimary)
                                            
                                            Button {
                                                kalemler.remove(at: idx)
                                            } label: {
                                                Image(systemName: "trash")
                                                    .font(.system(size: 13))
                                                    .foregroundColor(AppTheme.danger.opacity(0.8))
                                                    .padding(6)
                                            }
                                        }
                                    }
                                }
                            }
                        }
                        
                        // Özet Kartı
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
                                        .font(.system(size: 18, weight: .heavy))
                                        .foregroundColor(AppTheme.primary)
                                }
                            }
                        }
                        
                        ActionButton(title: isSaving ? "Kaydediliyor..." : "Teklifi Kaydet", icon: "checkmark.circle.fill", color: AppTheme.primary) {
                            saveTeklif()
                        }
                        .disabled(isSaving)
                        
                        Spacer().frame(height: 30)
                    }
                    .padding()
                }
            }
            .navigationTitle("Yeni Teklif")
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
                    let miktar = 1.0
                    let birimFiyat = selectedStok.satisFiyati
                    let kdvOrani = selectedStok.kdvOrani
                    let tutar = miktar * birimFiyat * (1.0 + kdvOrani / 100.0)
                    
                    let newKalem = TeklifKalem(
                        id: UUID().uuidString,
                        stokAdi: selectedStok.ad,
                        miktar: miktar,
                        birim: selectedStok.birim,
                        birimFiyat: birimFiyat,
                        kdvOrani: kdvOrani,
                        tutar: tutar
                    )
                    kalemler.append(newKalem)
                }
            }
            .sheet(isPresented: $showAddKalemSheet) {
                AddKalemView { k in
                    kalemler.append(TeklifKalem(
                        id: UUID().uuidString,
                        stokAdi: k.stokAdi,
                        miktar: k.miktar,
                        birim: k.birim,
                        birimFiyat: k.birimFiyat,
                        kdvOrani: k.kdvOrani,
                        tutar: k.netTutar + k.kdvTutari
                    ))
                }
            }
        }
    }
    
    private func saveTeklif() {
        guard !cariUnvan.isEmpty else {
            errorMessage = "Lütfen cari / müşteri unvanı seçin veya girin."
            return
        }
        guard !kalemler.isEmpty else {
            errorMessage = "Lütfen en az bir teklif kalemi ekleyin."
            return
        }
        
        isSaving = true
        errorMessage = nil
        let newTeklif = Teklif(
            id: UUID().uuidString,
            teklifNo: teklifNo,
            cariUnvan: cariUnvan,
            tarih: AppFormatters.isoDate.string(from: Date()),
            gecerlilikTarihi: AppFormatters.isoDate.string(from: gecerlilikTarihi),
            araToplam: araToplam,
            kdvToplami: kdvToplami,
            genelToplam: genelToplam,
            durum: "TASLAK",
            kalemler: kalemler
        )
        Task {
            _ = try? await SupabaseService.shared.insert(into: "teklifler", item: newTeklif)
            await MainActor.run {
                onSave?(newTeklif)
                dismiss()
            }
        }
    }
}
