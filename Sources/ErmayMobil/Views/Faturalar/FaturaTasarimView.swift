import SwiftUI

public struct FaturaTasarimView: View {
    @State private var firmaBasligi: String = "ERMAY BİLİŞİM SANAYİ TİCARET LTD. ŞTİ."
    @State private var altDipnot: String = "İşbu fatura muhteviyatına 8 gün içerisinde itiraz edilmediği takdirde kabul edilmiş sayılır."
    @State private var bankaBilgisi: String = "Garanti BBVA - TR12 0006 2000 1234 5678 9012 34"
    @State private var vergiDairesi: String = "İkitelli Vergi Dairesi / 3810294821"
    @State private var showSavedNotice: Bool = false
    
    public init() {}
    
    public var body: some View {
        NavigationStack {
            ZStack {
                AppTheme.background.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 16) {
                        HStack {
                            Text("Fatura & PDF Tasarımı")
                                .font(.system(size: 24, weight: .bold))
                                .foregroundColor(AppTheme.textPrimary)
                            Spacer()
                        }
                        .padding(.horizontal)
                        .padding(.top, 8)
                        
                        if showSavedNotice {
                            Text("Fatura şablon ayarları başarıyla kaydedildi.")
                                .font(.system(size: 11, weight: .bold))
                                .foregroundColor(AppTheme.success)
                                .padding(.horizontal, 14)
                                .padding(.vertical, 6)
                                .background(AppTheme.success.opacity(0.15))
                                .cornerRadius(8)
                        }
                        
                        // Şablon Ayarları
                        GlassCard(cornerRadius: 16, padding: 18) {
                            VStack(spacing: 14) {
                                FormField(label: "Firma Fatura Başlığı", text: $firmaBasligi, placeholder: "Şirket resmi unvanı")
                                FormField(label: "Vergi Dairesi & No", text: $vergiDairesi, placeholder: "VD / Vergi No")
                                FormField(label: "Faturada Görünecek Banka/IBAN", text: $bankaBilgisi, placeholder: "Banka ve IBAN")
                                FormField(label: "Fatura Altı Standart Dipnot", text: $altDipnot, placeholder: "Yasal uyarı ve notlar...")
                            }
                        }
                        .padding(.horizontal)
                        
                        // Canlı PDF Önizleme Kartı
                        GlassCard(cornerRadius: 16, padding: 16) {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("A4 e-Fatura Başlık Önizlemesi")
                                    .font(.system(size: 11, weight: .bold))
                                    .foregroundColor(AppTheme.textSecondary)
                                
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(firmaBasligi)
                                        .font(.system(size: 12, weight: .bold))
                                        .foregroundColor(AppTheme.textPrimary)
                                    Text(vergiDairesi)
                                        .font(.system(size: 10))
                                        .foregroundColor(AppTheme.textMuted)
                                    Text("Banka: \(bankaBilgisi)")
                                        .font(.system(size: 10))
                                        .foregroundColor(AppTheme.textMuted)
                                    Divider().background(AppTheme.border)
                                    Text(altDipnot)
                                        .font(.system(size: 9))
                                        .foregroundColor(AppTheme.textSecondary)
                                        .italic()
                                }
                                .padding(12)
                                .background(Color.white.opacity(0.04))
                                .cornerRadius(8)
                            }
                        }
                        .padding(.horizontal)
                        
                        ActionButton(
                            title: "Tasarım Şablonunu Kaydet",
                            icon: "checkmark.circle.fill",
                            color: AppTheme.primary
                        ) {
                            UserDefaults.standard.set(firmaBasligi, forKey: "ermay_fatura_baslik")
                            UserDefaults.standard.set(altDipnot, forKey: "ermay_fatura_dipnot")
                            UserDefaults.standard.set(bankaBilgisi, forKey: "ermay_fatura_banka")
                            showSavedNotice = true
                            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                showSavedNotice = false
                            }
                        }
                        .padding(.horizontal)
                        
                        Spacer().frame(height: 70)
                    }
                }
            }
            .navigationBarHidden(true)
        }
    }
}

