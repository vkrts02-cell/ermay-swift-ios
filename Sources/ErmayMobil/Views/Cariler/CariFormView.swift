import SwiftUI

public struct CariFormView: View {
    @Environment(\.dismiss) private var dismiss
    public var onSave: ((CariKart) -> Void)?
    
    @State private var unvan: String = ""
    @State private var cariKodu: String = ""
    @State private var cariTuru: String = "Müşteri"
    @State private var vergiDairesi: String = ""
    @State private var vergiNo: String = ""
    @State private var telefon: String = ""
    @State private var gsm: String = ""
    @State private var email: String = ""
    @State private var sehir: String = "İstanbul"
    @State private var adres: String = ""
    @State private var vadeGunu: String = "30"
    @State private var isSaving: Bool = false
    @State private var errorMessage: String? = nil
    @State private var showContactPicker: Bool = false
    @State private var isFetchingLocation: Bool = false
    
    private let turler = ["Müşteri", "Tedarikçi", "Diğer"]
    
    public init(onSave: ((CariKart) -> Void)? = nil) {
        self.onSave = onSave
    }
    
    public var body: some View {
        NavigationStack {
            ZStack {
                AppTheme.background.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 16) {
                        // Donanım Kısayolları (Rehberden Aktar & GPS Konum)
                        HStack(spacing: 10) {
                            Button {
                                showContactPicker = true
                            } label: {
                                HStack(spacing: 6) {
                                    Image(systemName: "person.crop.circle.badge.plus")
                                    Text("Rehberden Aktar")
                                }
                                .font(.system(size: 12, weight: .bold))
                                .foregroundColor(Color(hex: "00FF87"))
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 10)
                                .background(Color(hex: "00FF87").opacity(0.12))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(Color(hex: "00FF87").opacity(0.3), lineWidth: 1)
                                )
                                .cornerRadius(10)
                            }
                            
                            Button {
                                fetchGPSLocation()
                            } label: {
                                HStack(spacing: 6) {
                                    Image(systemName: isFetchingLocation ? "arrow.triangle.2.circlepath" : "location.fill")
                                    Text(isFetchingLocation ? "Alınıyor..." : "GPS Konumu Al")
                                }
                                .font(.system(size: 12, weight: .bold))
                                .foregroundColor(Color(hex: "0A84FF"))
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 10)
                                .background(Color(hex: "0A84FF").opacity(0.12))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(Color(hex: "0A84FF").opacity(0.3), lineWidth: 1)
                                )
                                .cornerRadius(10)
                            }
                        }
                        
                        if let err = errorMessage {
                            Text(err)
                                .font(.system(size: 13, weight: .bold))
                                .foregroundColor(AppTheme.danger)
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(AppTheme.dangerMuted.opacity(0.4))
                                .cornerRadius(10)
                        }
                        
                        GlassCard(cornerRadius: 16, padding: 18) {
                            VStack(spacing: 14) {
                                FormField(label: "Cari Unvanı *", text: $unvan, placeholder: "Örn: Ermay Tekstil Ltd. Şti.")
                                FormField(label: "Cari Kodu", text: $cariKodu, placeholder: "Örn: CR-005")
                                
                                VStack(alignment: .leading, spacing: 6) {
                                    Text("Cari Türü")
                                        .font(.system(size: 12, weight: .semibold))
                                        .foregroundColor(AppTheme.textSecondary)
                                    
                                    Picker("Cari Türü", selection: $cariTuru) {
                                        ForEach(turler, id: \.self) { tur in
                                            Text(tur).tag(tur)
                                        }
                                    }
                                    .pickerStyle(.segmented)
                                }
                            }
                        }
                        
                        GlassCard(cornerRadius: 16, padding: 18) {
                            VStack(spacing: 14) {
                                FormField(label: "Vergi Dairesi", text: $vergiDairesi, placeholder: "İkitelli VD")
                                FormField(label: "Vergi / TC No", text: $vergiNo, placeholder: "10 veya 11 haneli numara")
                                FormField(label: "GSM / WhatsApp", text: $gsm, placeholder: "05XX XXX XX XX")
                                FormField(label: "Telefon", text: $telefon, placeholder: "0212 XXX XX XX")
                                FormField(label: "E-Posta", text: $email, placeholder: "ornek@sirket.com")
                            }
                        }
                        
                        GlassCard(cornerRadius: 16, padding: 18) {
                            VStack(spacing: 14) {
                                FormField(label: "Şehir", text: $sehir, placeholder: "İl adı")
                                FormField(label: "Açık Adres", text: $adres, placeholder: "Mahalle, cadde, sokak no...")
                                FormField(label: "Varsayılan Vade (Gün)", text: $vadeGunu, placeholder: "30")
                            }
                        }
                        
                        ActionButton(
                            title: isSaving ? "Kaydediliyor..." : "Cariyi Kaydet",
                            icon: "checkmark.circle.fill",
                            color: AppTheme.primary
                        ) {
                            saveCari()
                        }
                        .disabled(isSaving)
                        
                        Spacer().frame(height: 20)
                    }
                    .padding()
                }
            }
            .navigationTitle("Yeni Cari Kartı")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("İptal") { dismiss() }
                        .foregroundColor(AppTheme.textSecondary)
                }
            }
            .sheet(isPresented: $showContactPicker) {
                #if canImport(UIKit) && canImport(ContactsUI)
                ContactPickerBridge { result in
                    self.unvan = result.unvan
                    if let tel = result.telefon { self.gsm = tel }
                    if let em = result.email { self.email = em }
                    if let ad = result.adres { self.adres = ad }
                }
                #endif
            }
        }
    }
    
    private func fetchGPSLocation() {
        isFetchingLocation = true
        Task {
            if let loc = await LocationHelper.shared.getCurrentCityAndAddress() {
                await MainActor.run {
                    self.sehir = loc.sehir
                    if self.adres.isEmpty {
                        self.adres = loc.adres
                    }
                    self.isFetchingLocation = false
                }
            } else {
                await MainActor.run {
                    self.isFetchingLocation = false
                }
            }
        }
    }
    
    private func saveCari() {
        guard !unvan.trimmingCharacters(in: .whitespaces).isEmpty else {
            errorMessage = "Lütfen cari unvanını giriniz."
            return
        }
        
        isSaving = true
        errorMessage = nil
        
        let newCari = CariKart(
            cariKodu: cariKodu.isEmpty ? "CR-\(Int.random(in: 100...999))" : cariKodu,
            unvan: unvan,
            cariTuru: cariTuru,
            vergiDairesi: vergiDairesi,
            vergiNo: vergiNo,
            telefon: gsm.isEmpty ? telefon : gsm,
            email: email,
            adres: adres,
            sehir: sehir,
            bakiye: 0.0,
            bakiyeTuru: "A",
            vadeGunu: Int(vadeGunu) ?? 30
        )
        
        Task {
            do {
                try await SupabaseService.shared.insert(into: "cariler", item: newCari)
                await MainActor.run {
                    onSave?(newCari)
                    isSaving = false
                    dismiss()
                }
            } catch {
                if let payload = try? JSONEncoder().encode(newCari) {
                    OfflineQueueService.shared.enqueue(action: "INSERT", table: "cariler", recordId: newCari.id, payload: payload)
                }
                await MainActor.run {
                    onSave?(newCari)
                    isSaving = false
                    dismiss()
                }
            }
        }
    }
}
