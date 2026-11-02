import SwiftUI

public struct TeklifFormView: View {
    @Environment(\.dismiss) private var dismiss
    public var onSave: ((Teklif) -> Void)?
    
    @State private var teklifNo: String = "TKF-\(Int.random(in: 100000...999999))"
    @State private var durum: String = "Bekliyor" // "Bekliyor", "Reddedildi"
    @State private var odemeBilgisi: String = ""
    @State private var tarihStr: String = ""
    @State private var gecerlilikTarihiStr: String = ""
    @State private var aciklama: String = ""
    
    // Cari
    @State private var cariUnvan: String = ""
    @State private var cariId: String? = nil
    
    // Items
    @State private var kalemler: [TeklifKalem] = []
    
    // Pickers
    @State private var showCariPicker: Bool = false
    @State private var showStokPicker: Bool = false
    @State private var isSaving: Bool = false
    @State private var errorMessage: String? = nil
    
    private let birimler = ["Adet", "Kg", "Mt", "M2"]
    
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
                Color.black.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 16) {
                        // Header
                        HStack {
                            Text("Yeni Teklif Oluştur")
                                .font(.system(size: 20, weight: .bold))
                                .foregroundColor(.white)
                            Spacer()
                            Button {
                                dismiss()
                            } label: {
                                Image(systemName: "xmark")
                                    .font(.system(size: 18, weight: .semibold))
                                    .foregroundColor(.white)
                                    .padding(8)
                            }
                        }
                        .padding(.horizontal)
                        .padding(.top, 12)
                        
                        if let err = errorMessage {
                            Text(err)
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundColor(.red)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(10)
                                .background(Color.red.opacity(0.15))
                                .cornerRadius(8)
                                .padding(.horizontal)
                        }
                        
                        // Cari Kart Seçin Card
                        Button {
                            showCariPicker = true
                        } label: {
                            HStack(spacing: 12) {
                                Image(systemName: "person.circle.fill")
                                    .font(.system(size: 22))
                                    .foregroundColor(Color(hex: "0061FF"))
                                Text(cariUnvan.isEmpty ? "Cari Kart Seçin *" : cariUnvan)
                                    .font(.system(size: 14, weight: .bold))
                                    .foregroundColor(.white)
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .font(.system(size: 14))
                                    .foregroundColor(Color(hex: "64748B"))
                            }
                            .padding(14)
                            .background(Color(hex: "121216"))
                            .cornerRadius(12)
                            .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.white.opacity(0.08), lineWidth: 1))
                        }
                        .padding(.horizontal)
                        
                        // 2 Kolon: Teklif No & Durum
                        HStack(spacing: 12) {
                            VStack(alignment: .leading, spacing: 6) {
                                Text("TEKLİF NO")
                                    .font(.system(size: 11, weight: .bold))
                                    .foregroundColor(Color(hex: "94A3B8"))
                                TextField("Teklif No", text: $teklifNo)
                                    .padding(12)
                                    .background(Color(hex: "121216"))
                                    .cornerRadius(10)
                                    .foregroundColor(.white)
                                    .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.white.opacity(0.08), lineWidth: 1))
                            }
                            .frame(maxWidth: .infinity)
                            
                            VStack(alignment: .leading, spacing: 6) {
                                Text("DURUM")
                                    .font(.system(size: 11, weight: .bold))
                                    .foregroundColor(Color(hex: "94A3B8"))
                                HStack(spacing: 4) {
                                    ForEach(["Bekliyor", "Reddedildi"], id: \.self) { st in
                                        Button {
                                            durum = st
                                        } label: {
                                            Text(st)
                                                .font(.system(size: 11, weight: .bold))
                                                .foregroundColor(durum == st ? .white : Color(hex: "94A3B8"))
                                                .frame(maxWidth: .infinity)
                                                .frame(height: 42)
                                                .background(durum == st ? Color(hex: "0061FF") : Color.white.opacity(0.04))
                                                .cornerRadius(8)
                                        }
                                    }
                                }
                            }
                            .frame(maxWidth: .infinity)
                        }
                        .padding(.horizontal)
                        
                        // 2 Kolon: Tarihler
                        HStack(spacing: 12) {
                            VStack(alignment: .leading, spacing: 6) {
                                Text("TEKLİF TARİHİ")
                                    .font(.system(size: 11, weight: .bold))
                                    .foregroundColor(Color(hex: "94A3B8"))
                                TextField("YYYY-MM-DD", text: $tarihStr)
                                    .padding(12)
                                    .background(Color(hex: "121216"))
                                    .cornerRadius(10)
                                    .foregroundColor(.white)
                                    .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.white.opacity(0.08), lineWidth: 1))
                            }
                            .frame(maxWidth: .infinity)
                            
                            VStack(alignment: .leading, spacing: 6) {
                                Text("GEÇERLİLİK TARİHİ")
                                    .font(.system(size: 11, weight: .bold))
                                    .foregroundColor(Color(hex: "94A3B8"))
                                TextField("YYYY-MM-DD", text: $gecerlilikTarihiStr)
                                    .padding(12)
                                    .background(Color(hex: "121216"))
                                    .cornerRadius(10)
                                    .foregroundColor(.white)
                                    .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.white.opacity(0.08), lineWidth: 1))
                            }
                            .frame(maxWidth: .infinity)
                        }
                        .padding(.horizontal)
                        
                        // Ödeme Bilgisi (Tam Satır)
                        VStack(alignment: .leading, spacing: 6) {
                            Text("ÖDEME BİLGİSİ")
                                .font(.system(size: 11, weight: .bold))
                                .foregroundColor(Color(hex: "94A3B8"))
                            TextField("örn. 30 Gün Vade veya Peşin Ödeme...", text: $odemeBilgisi)
                                .padding(12)
                                .background(Color(hex: "121216"))
                                .cornerRadius(10)
                                .foregroundColor(.white)
                                .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.white.opacity(0.08), lineWidth: 1))
                        }
                        .padding(.horizontal)
                        
                        // Teklif Kalemleri
                        VStack(spacing: 10) {
                            HStack {
                                Text("Teklif Kalemleri")
                                    .font(.system(size: 14, weight: .bold))
                                    .foregroundColor(.white)
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
                                }
                            }
                            
                            if kalemler.isEmpty {
                                Text("Henüz kalem eklenmedi.")
                                    .font(.system(size: 12))
                                    .foregroundColor(Color(hex: "64748B"))
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 16)
                            } else {
                                ForEach(Array(kalemler.enumerated()), id: \.offset) { index, item in
                                    VStack(alignment: .leading, spacing: 8) {
                                        HStack {
                                            Text(item.stokAdi)
                                                .font(.system(size: 13, weight: .bold))
                                                .foregroundColor(.white)
                                            Spacer()
                                            Button {
                                                kalemler.remove(at: index)
                                            } label: {
                                                Image(systemName: "trash.fill")
                                                    .font(.system(size: 14))
                                                    .foregroundColor(Color(hex: "EF4444"))
                                            }
                                        }
                                        
                                        HStack(spacing: 8) {
                                            // Miktar & Birim
                                            HStack(spacing: 2) {
                                                TextField("0", value: Binding(
                                                    get: { kalemler[index].miktar },
                                                    set: { kalemler[index].miktar = $0 }
                                                ), formatter: NumberFormatter())
                                                .keyboardType(.decimalPad)
                                                .padding(8)
                                                .background(Color(hex: "2A2A2A"))
                                                .cornerRadius(6)
                                                .foregroundColor(.white)
                                                .frame(width: 60)
                                                
                                                Menu {
                                                    ForEach(birimler, id: \.self) { b in
                                                        Button(b) {
                                                            kalemler[index].birim = b
                                                        }
                                                    }
                                                } label: {
                                                    HStack(spacing: 2) {
                                                        Text(kalemler[index].birim ?? "Adet")
                                                            .font(.system(size: 11, weight: .semibold))
                                                            .foregroundColor(.white)
                                                        Image(systemName: "chevron.down")
                                                            .font(.system(size: 8))
                                                            .foregroundColor(Color(hex: "94A3B8"))
                                                    }
                                                    .padding(.horizontal, 6)
                                                    .padding(.vertical, 8)
                                                    .background(Color(hex: "2A2A2A"))
                                                    .cornerRadius(6)
                                                }
                                            }
                                            
                                            // Fiyat
                                            TextField("0.00", value: Binding(
                                                get: { kalemler[index].birimFiyat },
                                                set: { kalemler[index].birimFiyat = $0 }
                                            ), formatter: NumberFormatter())
                                            .keyboardType(.decimalPad)
                                            .padding(8)
                                            .background(Color(hex: "2A2A2A"))
                                            .cornerRadius(6)
                                            .foregroundColor(.white)
                                            
                                            // KDV
                                            Text("%\(Int(kalemler[index].kdvOrani))")
                                                .font(.system(size: 11, weight: .bold))
                                                .foregroundColor(Color(hex: "10B981"))
                                                .padding(.horizontal, 8)
                                                .padding(.vertical, 8)
                                                .background(Color.white.opacity(0.06))
                                                .cornerRadius(6)
                                        }
                                        
                                        // Kalem Açıklaması
                                        TextField("Kalem notu...", text: Binding(
                                            get: { kalemler[index].aciklama ?? "" },
                                            set: { kalemler[index].aciklama = $0 }
                                        ))
                                        .font(.system(size: 12))
                                        .padding(8)
                                        .background(Color(hex: "2A2A2A"))
                                        .cornerRadius(6)
                                        .foregroundColor(.white)
                                    }
                                    .padding(12)
                                    .background(Color(hex: "121216"))
                                    .cornerRadius(12)
                                    .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.white.opacity(0.08), lineWidth: 1))
                                }
                            }
                        }
                        .padding(.horizontal)
                        
                        // Açıklama
                        VStack(alignment: .leading, spacing: 6) {
                            Text("AÇIKLAMA")
                                .font(.system(size: 11, weight: .bold))
                                .foregroundColor(Color(hex: "94A3B8"))
                            TextField("Teklif hakkında not...", text: $aciklama, axis: .vertical)
                                .lineLimit(3...5)
                                .padding(12)
                                .background(Color(hex: "121216"))
                                .cornerRadius(10)
                                .foregroundColor(.white)
                                .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.white.opacity(0.08), lineWidth: 1))
                        }
                        .padding(.horizontal)
                        
                        // Toplam Bilgi Kartı
                        VStack(spacing: 8) {
                            HStack {
                                Text("Ara Toplam:")
                                    .font(.system(size: 13))
                                    .foregroundColor(Color(hex: "94A3B8"))
                                Spacer()
                                Text(AppFormatters.money(araToplam))
                                    .font(.system(size: 13, weight: .bold))
                                    .foregroundColor(.white)
                            }
                            HStack {
                                Text("KDV Toplamı:")
                                    .font(.system(size: 13))
                                    .foregroundColor(Color(hex: "94A3B8"))
                                Spacer()
                                Text(AppFormatters.money(kdvToplami))
                                    .font(.system(size: 13, weight: .bold))
                                    .foregroundColor(.white)
                            }
                            Divider().background(Color.white.opacity(0.1))
                            HStack {
                                Text("Genel Toplam:")
                                    .font(.system(size: 15, weight: .bold))
                                    .foregroundColor(.white)
                                Spacer()
                                Text(AppFormatters.money(genelToplam))
                                    .font(.system(size: 18, weight: .heavy))
                                    .foregroundColor(Color(hex: "00FF87"))
                            }
                        }
                        .padding(16)
                        .background(Color(hex: "121216"))
                        .cornerRadius(16)
                        .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.white.opacity(0.08), lineWidth: 1))
                        .padding(.horizontal)
                        
                        // Kaydet Butonu
                        Button {
                            handleSave()
                        } label: {
                            HStack(spacing: 8) {
                                if isSaving {
                                    ProgressView().tint(.white)
                                } else {
                                    Image(systemName: "square.and.arrow.down.fill")
                                    Text("Teklifi Kaydet")
                                }
                            }
                            .font(.system(size: 15, weight: .bold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .background(Color(hex: "0061FF"))
                            .cornerRadius(12)
                        }
                        .disabled(isSaving)
                        .padding(.horizontal)
                        .padding(.bottom, 30)
                    }
                }
            }
            .navigationBarHidden(true)
            .enableSwipeBack()
            .onAppear {
                let formatter = DateFormatter()
                formatter.dateFormat = "yyyy-MM-dd"
                tarihStr = formatter.string(from: Date())
                let expiryDate = Calendar.current.date(byAdding: .day, value: 15, to: Date()) ?? Date()
                gecerlilikTarihiStr = formatter.string(from: expiryDate)
            }
            .sheet(isPresented: $showCariPicker) {
                CariPickerSheet { c in
                    self.cariId = c.id
                    self.cariUnvan = c.unvan
                }
                .enableSwipeBack()
            }
            .sheet(isPresented: $showStokPicker) {
                StokPickerSheet { s in
                    let newKalem = TeklifKalem(
                        stokId: s.id,
                        stokAdi: s.stokAdi,
                        miktar: 1.0,
                        birim: s.birim,
                        birimFiyat: s.satisFiyati,
                        kdvOrani: s.kdvOrani
                    )
                    kalemler.append(newKalem)
                }
                .enableSwipeBack()
            }
        }
    }
    
    private func handleSave() {
        if cariUnvan.isEmpty {
            errorMessage = "Lütfen bir cari kart seçiniz."
            return
        }
        if kalemler.isEmpty {
            errorMessage = "Lütfen en az bir kalem ekleyiniz."
            return
        }
        
        isSaving = true
        let newTeklif = Teklif(
            teklifNo: teklifNo,
            cariId: cariId ?? "1",
            cariUnvan: cariUnvan,
            tarih: tarihStr,
            gecerlilikTarihi: gecerlilikTarihiStr,
            genelToplam: genelToplam,
            durum: durum,
            aciklama: aciklama,
            kalemler: kalemler
        )
        
        Task {
            _ = try? await SupabaseService.shared.insert(newTeklif, into: "teklifler")
            await MainActor.run {
                onSave?(newTeklif)
                isSaving = false
                dismiss()
            }
        }
    }
}
