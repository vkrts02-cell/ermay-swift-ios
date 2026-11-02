import SwiftUI

public struct SiparisFormView: View {
    @Environment(\.dismiss) private var dismiss
    public var onSave: ((Siparis) -> Void)?
    
    @State private var siparisNo: String = "SIP-\(Int.random(in: 100000...999999))"
    @State private var durum: String = "Bekliyor" // "Bekliyor", "İptal"
    @State private var oncelik: String = "Orta" // "Düşük", "Orta", "Yüksek"
    @State private var odemeBilgisi: String = ""
    @State private var tarih: Date = Date()
    @State private var teslimatTarihi: Date = Calendar.current.date(byAdding: .day, value: 7, to: Date()) ?? Date()
    @State private var baglantiEvrakNo: String = ""
    @State private var pdfNotlar: String = ""
    @State private var cariUnvan: String = ""
    @State private var cariId: String? = nil
    
    // Items
    @State private var kalemler: [SiparisKalem] = []
    
    // Overlays & Sheets
    @State private var showCariPicker: Bool = false
    @State private var showStokPicker: Bool = false
    @State private var isSaving: Bool = false
    @State private var errorMessage: String? = nil
    
    private let birimler = ["Adet", "Kg", "Mt", "M2"]
    
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
                        // Header
                        HStack {
                            Text("Yeni Sipariş Oluştur")
                                .font(.system(size: 20, weight: .bold))
                                .foregroundColor(AppTheme.textPrimary)
                            Spacer()
                            Button {
                                dismiss()
                            } label: {
                                Image(systemName: "xmark.circle.fill")
                                    .font(.system(size: 24))
                                    .foregroundColor(AppTheme.textMuted)
                            }
                        }
                        .padding(.horizontal)
                        .padding(.top, 12)
                        
                        if let err = errorMessage {
                            Text(err)
                                .font(.system(size: 13, weight: .bold))
                                .foregroundColor(AppTheme.danger)
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(AppTheme.dangerMuted.opacity(0.4))
                                .cornerRadius(10)
                                .padding(.horizontal)
                        }
                        
                        // Cari Kart Seçici
                        Button {
                            showCariPicker = true
                        } label: {
                            HStack(spacing: 12) {
                                Image(systemName: "person.crop.circle.fill")
                                    .font(.system(size: 20))
                                    .foregroundColor(Color(hex: "0061FF"))
                                Text(cariUnvan.isEmpty ? "Cari Kart Seçin *" : cariUnvan)
                                    .font(.system(size: 14, weight: cariUnvan.isEmpty ? .regular : .bold))
                                    .foregroundColor(cariUnvan.isEmpty ? AppTheme.textMuted : AppTheme.textPrimary)
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .font(.system(size: 12))
                                    .foregroundColor(AppTheme.textMuted)
                            }
                            .padding(.horizontal, 14)
                            .padding(.vertical, 14)
                            .background(Color(hex: "121216"))
                            .cornerRadius(12)
                            .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.white.opacity(0.08), lineWidth: 1))
                        }
                        .padding(.horizontal)
                        
                        // Sipariş No & Durum
                        HStack(spacing: 12) {
                            VStack(alignment: .leading, spacing: 6) {
                                Text("Sipariş No")
                                    .font(.system(size: 11, weight: .semibold))
                                    .foregroundColor(AppTheme.textSecondary)
                                TextField("SIP-000", text: $siparisNo)
                                    .font(.system(size: 13, weight: .medium))
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 10)
                                    .background(Color(hex: "121216"))
                                    .cornerRadius(8)
                                    .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.white.opacity(0.08), lineWidth: 1))
                                    .foregroundColor(AppTheme.textPrimary)
                            }
                            .frame(maxWidth: .infinity)
                            
                            VStack(alignment: .leading, spacing: 6) {
                                Text("Durum")
                                    .font(.system(size: 11, weight: .semibold))
                                    .foregroundColor(AppTheme.textSecondary)
                                HStack(spacing: 4) {
                                    ForEach(["Bekliyor", "İptal"], id: \.self) { st in
                                        Button {
                                            durum = st
                                        } label: {
                                            Text(st)
                                                .font(.system(size: 11, weight: durum == st ? .bold : .medium))
                                                .foregroundColor(durum == st ? .white : AppTheme.textSecondary)
                                                .frame(maxWidth: .infinity)
                                                .padding(.vertical, 9)
                                                .background(durum == st ? (st == "Bekliyor" ? Color(hex: "F59E0B") : Color(hex: "EF4444")) : Color(hex: "121216"))
                                                .cornerRadius(8)
                                        }
                                    }
                                }
                            }
                            .frame(maxWidth: .infinity)
                        }
                        .padding(.horizontal)
                        
                        // Öncelik & Ödeme Bilgisi
                        HStack(spacing: 12) {
                            VStack(alignment: .leading, spacing: 6) {
                                Text("Öncelik")
                                    .font(.system(size: 11, weight: .semibold))
                                    .foregroundColor(AppTheme.textSecondary)
                                HStack(spacing: 2) {
                                    ForEach(["Düşük", "Orta", "Yüksek"], id: \.self) { p in
                                        Button {
                                            oncelik = p
                                        } label: {
                                            Text(p)
                                                .font(.system(size: 10, weight: oncelik == p ? .bold : .medium))
                                                .foregroundColor(oncelik == p ? .white : AppTheme.textSecondary)
                                                .frame(maxWidth: .infinity)
                                                .padding(.vertical, 9)
                                                .background(oncelik == p ? Color(hex: "0A84FF") : Color(hex: "121216"))
                                                .cornerRadius(8)
                                        }
                                    }
                                }
                            }
                            .frame(maxWidth: .infinity)
                            
                            VStack(alignment: .leading, spacing: 6) {
                                Text("Ödeme Bilgisi")
                                    .font(.system(size: 11, weight: .semibold))
                                    .foregroundColor(AppTheme.textSecondary)
                                TextField("Peşin, Vade vb.", text: $odemeBilgisi)
                                    .font(.system(size: 13, weight: .medium))
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 10)
                                    .background(Color(hex: "121216"))
                                    .cornerRadius(8)
                                    .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.white.opacity(0.08), lineWidth: 1))
                                    .foregroundColor(AppTheme.textPrimary)
                            }
                            .frame(maxWidth: .infinity)
                        }
                        .padding(.horizontal)
                        
                        // Sipariş Tarihi & Teslimat Tarihi
                        HStack(spacing: 12) {
                            VStack(alignment: .leading, spacing: 6) {
                                Text("Sipariş Tarihi")
                                    .font(.system(size: 11, weight: .semibold))
                                    .foregroundColor(AppTheme.textSecondary)
                                DatePicker("", selection: $tarih, displayedComponents: .date)
                                    .labelsHidden()
                                    .colorScheme(.dark)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .padding(6)
                                    .background(Color(hex: "121216"))
                                    .cornerRadius(8)
                            }
                            .frame(maxWidth: .infinity)
                            
                            VStack(alignment: .leading, spacing: 6) {
                                Text("Teslimat Tarihi")
                                    .font(.system(size: 11, weight: .semibold))
                                    .foregroundColor(AppTheme.textSecondary)
                                DatePicker("", selection: $teslimatTarihi, displayedComponents: .date)
                                    .labelsHidden()
                                    .colorScheme(.dark)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .padding(6)
                                    .background(Color(hex: "121216"))
                                    .cornerRadius(8)
                            }
                            .frame(maxWidth: .infinity)
                        }
                        .padding(.horizontal)
                        
                        // Bağlantı Evrak No & PDF Notlar
                        HStack(spacing: 12) {
                            VStack(alignment: .leading, spacing: 6) {
                                Text("Bağlantı Evrak No")
                                    .font(.system(size: 11, weight: .semibold))
                                    .foregroundColor(AppTheme.textSecondary)
                                TextField("Teklif No vb.", text: $baglantiEvrakNo)
                                    .font(.system(size: 13, weight: .medium))
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 10)
                                    .background(Color(hex: "121216"))
                                    .cornerRadius(8)
                                    .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.white.opacity(0.08), lineWidth: 1))
                                    .foregroundColor(AppTheme.textPrimary)
                            }
                            .frame(maxWidth: .infinity)
                            
                            VStack(alignment: .leading, spacing: 6) {
                                Text("PDF Özel Notlar")
                                    .font(.system(size: 11, weight: .semibold))
                                    .foregroundColor(AppTheme.textSecondary)
                                TextField("Belgede çıkacak not...", text: $pdfNotlar)
                                    .font(.system(size: 13, weight: .medium))
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 10)
                                    .background(Color(hex: "121216"))
                                    .cornerRadius(8)
                                    .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.white.opacity(0.08), lineWidth: 1))
                                    .foregroundColor(AppTheme.textPrimary)
                            }
                            .frame(maxWidth: .infinity)
                        }
                        .padding(.horizontal)
                        
                        // Sipariş Kalemleri
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Text("Sipariş Kalemleri (\(kalemler.count))")
                                    .font(.system(size: 14, weight: .bold))
                                    .foregroundColor(AppTheme.textPrimary)
                                Spacer()
                                Button {
                                    showStokPicker = true
                                } label: {
                                    HStack(spacing: 4) {
                                        Image(systemName: "plus")
                                        Text("Kalem Ekle")
                                    }
                                    .font(.system(size: 12, weight: .bold))
                                    .foregroundColor(Color(hex: "00FF87"))
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 6)
                                    .background(Color(hex: "00FF87").opacity(0.12))
                                    .cornerRadius(8)
                                }
                            }
                            
                            if kalemler.isEmpty {
                                Text("Henüz kalem eklenmedi.")
                                    .font(.system(size: 12))
                                    .foregroundColor(AppTheme.textMuted)
                                    .frame(maxWidth: .infinity, alignment: .center)
                                    .padding(.vertical, 20)
                            } else {
                                ForEach(kalemler.indices, id: \.self) { idx in
                                    VStack(alignment: .leading, spacing: 10) {
                                        HStack {
                                            Text(kalemler[idx].stokAdi)
                                                .font(.system(size: 13, weight: .bold))
                                                .foregroundColor(AppTheme.textPrimary)
                                            Spacer()
                                            Button {
                                                kalemler.remove(at: idx)
                                            } label: {
                                                Image(systemName: "trash.fill")
                                                    .font(.system(size: 13))
                                                    .foregroundColor(AppTheme.danger)
                                            }
                                        }
                                        
                                        // Miktar & Birim & Fiyat
                                        HStack(spacing: 10) {
                                            VStack(alignment: .leading, spacing: 4) {
                                                Text("Miktar")
                                                    .font(.system(size: 10))
                                                    .foregroundColor(AppTheme.textSecondary)
                                                HStack(spacing: 4) {
                                                    TextField("0", value: $kalemler[idx].miktar, format: .number)
                                                        .keyboardType(.decimalPad)
                                                        .font(.system(size: 12, weight: .bold))
                                                        .padding(6)
                                                        .background(Color.white.opacity(0.06))
                                                        .cornerRadius(6)
                                                    
                                                    Menu {
                                                        ForEach(birimler, id: \.self) { b in
                                                            Button(b) {
                                                                kalemler[idx].birim = b
                                                            }
                                                        }
                                                    } label: {
                                                        Text(kalemler[idx].birim)
                                                            .font(.system(size: 11, weight: .semibold))
                                                            .foregroundColor(AppTheme.textPrimary)
                                                            .padding(.horizontal, 6)
                                                            .padding(.vertical, 6)
                                                            .background(Color.white.opacity(0.08))
                                                            .cornerRadius(6)
                                                    }
                                                }
                                            }
                                            .frame(maxWidth: .infinity)
                                            
                                            VStack(alignment: .leading, spacing: 4) {
                                                Text("Birim Fiyat (₺)")
                                                    .font(.system(size: 10))
                                                    .foregroundColor(AppTheme.textSecondary)
                                                TextField("0.00", value: $kalemler[idx].birimFiyat, format: .number)
                                                    .keyboardType(.decimalPad)
                                                    .font(.system(size: 12, weight: .bold))
                                                    .padding(6)
                                                    .background(Color.white.opacity(0.06))
                                                    .cornerRadius(6)
                                            }
                                            .frame(maxWidth: .infinity)
                                            
                                            VStack(alignment: .leading, spacing: 4) {
                                                Text("KDV")
                                                    .font(.system(size: 10))
                                                    .foregroundColor(AppTheme.textSecondary)
                                                Text("%\(Int(kalemler[idx].kdvOrani))")
                                                    .font(.system(size: 12, weight: .bold))
                                                    .foregroundColor(Color(hex: "10B981"))
                                                    .frame(maxWidth: .infinity)
                                                    .padding(6)
                                                    .background(Color.white.opacity(0.06))
                                                    .cornerRadius(6)
                                            }
                                            .frame(width: 50)
                                        }
                                    }
                                    .padding(12)
                                    .background(Color(hex: "121216"))
                                    .cornerRadius(12)
                                    .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.white.opacity(0.06), lineWidth: 1))
                                }
                            }
                        }
                        .padding(.horizontal)
                        
                        // Özet Kartı
                        GlassCard(cornerRadius: 14, padding: 14) {
                            VStack(spacing: 8) {
                                HStack {
                                    Text("Ara Toplam")
                                        .font(.system(size: 12))
                                        .foregroundColor(AppTheme.textSecondary)
                                    Spacer()
                                    Text(AppFormatters.money(araToplam))
                                        .font(.system(size: 12, weight: .medium))
                                        .foregroundColor(AppTheme.textPrimary)
                                }
                                HStack {
                                    Text("KDV Toplam")
                                        .font(.system(size: 12))
                                        .foregroundColor(AppTheme.textSecondary)
                                    Spacer()
                                    Text(AppFormatters.money(kdvToplami))
                                        .font(.system(size: 12, weight: .medium))
                                        .foregroundColor(AppTheme.textPrimary)
                                }
                                Divider().background(AppTheme.border)
                                HStack {
                                    Text("Genel Toplam")
                                        .font(.system(size: 14, weight: .bold))
                                        .foregroundColor(AppTheme.textPrimary)
                                    Spacer()
                                    Text(AppFormatters.money(genelToplam))
                                        .font(.system(size: 16, weight: .heavy))
                                        .foregroundColor(Color(hex: "00FF87"))
                                }
                            }
                        }
                        .padding(.horizontal)
                        
                        // Kaydet Butonu
                        Button {
                            saveSiparis()
                        } label: {
                            HStack {
                                if isSaving {
                                    ProgressView().tint(.white)
                                } else {
                                    Image(systemName: "checkmark.circle.fill")
                                    Text("Siparişi Kaydet")
                                }
                            }
                            .font(.system(size: 15, weight: .bold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(Color(hex: "0A84FF"))
                            .cornerRadius(12)
                        }
                        .disabled(isSaving)
                        .padding(.horizontal)
                        .padding(.bottom, 40)
                    }
                }
            }
            .navigationBarHidden(true)
            .sheet(isPresented: $showCariPicker) {
                CariPickerSheet { c in
                    self.cariId = c.id
                    self.cariUnvan = c.unvan
                }
            }
            .sheet(isPresented: $showStokPicker) {
                StokPickerSheet { s in
                    let newKalem = SiparisKalem(
                        stokId: s.id,
                        stokAdi: s.stokAdi,
                        birim: s.birim,
                        miktar: 1.0,
                        birimFiyat: s.satisFiyati,
                        kdvOrani: s.kdvOrani
                    )
                    kalemler.append(newKalem)
                }
            }
        }
    }
    
    private func saveSiparis() {
        guard !cariUnvan.isEmpty else {
            errorMessage = "Lütfen bir cari kart seçiniz."
            return
        }
        guard !kalemler.isEmpty else {
            errorMessage = "Lütfen en az bir kalem ekleyiniz."
            return
        }
        isSaving = true
        
        let newSiparis = Siparis(
            id: UUID().uuidString,
            siparisNo: siparisNo,
            siparisTuru: "ALINAN",
            cariId: cariId ?? UUID().uuidString,
            cariUnvan: cariUnvan,
            tarih: ISO8601DateFormatter().string(from: tarih),
            teslimTarihi: ISO8601DateFormatter().string(from: teslimatTarihi),
            durum: durum,
            araToplam: araToplam,
            kdvToplami: kdvToplami,
            genelToplam: genelToplam,
            kalemler: kalemler
        )
        
        Task {
            do {
                try await SupabaseService.shared.insert(newSiparis, into: "siparisler")
            } catch {
                print("Siparis insert notice: \(error.localizedDescription)")
            }
            await MainActor.run {
                isSaving = false
                onSave?(newSiparis)
                dismiss()
            }
        }
    }
}
