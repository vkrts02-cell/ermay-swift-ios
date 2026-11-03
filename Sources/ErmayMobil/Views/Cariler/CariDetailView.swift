import SwiftUI

public struct CariDetailView: View {
    public let cari: CariKart
    @State private var hareketler: [CariHareket] = []
    @State private var isLoadingHareket: Bool = false
    @State private var contactSavedSuccess: Bool = false
    @State private var showContactAlert: Bool = false
    @Environment(\.dismiss) private var dismiss
    
    public init(cari: CariKart) {
        self.cari = cari
    }
    
    public var body: some View {
        ZStack {
            AppTheme.background.ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 16) {
                    // Cari Bakiye Hero Kartı
                    GlassCard(cornerRadius: 18, padding: 18) {
                        VStack(spacing: 12) {
                            Text(cari.unvan)
                                .font(.system(size: 18, weight: .bold))
                                .foregroundColor(AppTheme.textPrimary)
                                .multilineTextAlignment(.center)
                            
                            HStack(spacing: 8) {
                                StatusBadge(title: cari.cariTuru ?? "Müşteri", color: AppTheme.primary)
                                if let kod = cari.cariKodu {
                                    StatusBadge(title: kod, color: AppTheme.secondary)
                                }
                            }
                            
                            Divider().background(AppTheme.border)
                            
                            VStack(spacing: 2) {
                                Text("GÜNCEL BAKİYE")
                                    .font(.system(size: 10, weight: .bold))
                                    .foregroundColor(AppTheme.textSecondary)
                                
                                Text(AppFormatters.money(cari.bakiye))
                                    .font(.system(size: 28, weight: .heavy))
                                    .foregroundColor(cari.bakiye == 0 ? AppTheme.textMuted : (cari.bakiyeTuru == "B" ? AppTheme.danger : AppTheme.success))
                                
                                Text(cari.bakiye == 0 ? "Bakiye Sıfır" : (cari.bakiyeTuru == "B" ? "Firmamızdan Alacaklı (Borcumuz Var)" : "Firmamıza Borçlu (Alacağımız Var)"))
                                    .font(.system(size: 11, weight: .medium))
                                    .foregroundColor(AppTheme.textMuted)
                            }
                        }
                    }
                    .padding(.horizontal)
                    
                    // İletişim & Aksiyon Grid (WhatsApp, Ara, Rehbere Ekle, Harita)
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                        if let gsm = cari.gsm ?? cari.telefon, !gsm.isEmpty {
                            // WhatsApp
                            Button {
                                let clean = gsm.replacingOccurrences(of: " ", with: "").replacingOccurrences(of: "-", with: "")
                                if let url = URL(string: "https://wa.me/90\(clean)") {
                                    #if canImport(UIKit)
                                    UIApplication.shared.open(url)
                                    #endif
                                }
                            } label: {
                                ActionCard(title: "WhatsApp", icon: "message.fill", color: Color(hex: "25D366"))
                            }
                            
                            // Arama
                            Button {
                                if let url = URL(string: "tel://\(gsm)") {
                                    #if canImport(UIKit)
                                    UIApplication.shared.open(url)
                                    #endif
                                }
                            } label: {
                                ActionCard(title: "Ara", icon: "phone.fill", color: AppTheme.info)
                            }
                        }
                        
                        // Rehbere Ekle
                        Button {
                            Task {
                                let ok = await HardwareService.shared.addCariToContacts(cari: cari)
                                await MainActor.run {
                                    contactSavedSuccess = ok
                                    showContactAlert = true
                                }
                            }
                        } label: {
                            ActionCard(title: "Rehbere", icon: "person.crop.circle.badge.plus", color: AppTheme.purple)
                        }
                        
                        // Harita
                        if let adres = cari.adres, !adres.isEmpty {
                            Button {
                                let encoded = adres.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
                                if let url = URL(string: "http://maps.apple.com/?q=\(encoded)") {
                                    #if canImport(UIKit)
                                    UIApplication.shared.open(url)
                                    #endif
                                }
                            } label: {
                                ActionCard(title: "Harita", icon: "map.fill", color: AppTheme.warning)
                            }
                        }
                    }
                    .padding(.horizontal)
                    
                    // Detaylı Bilgiler
                    GlassCard(cornerRadius: 16, padding: 16) {
                        VStack(spacing: 12) {
                            DetailInfoRow(label: "Vergi Dairesi", value: cari.vergiDairesi ?? "-")
                            DetailInfoRow(label: "Vergi / TC No", value: cari.vergiNo ?? cari.tcKimlikNo ?? "-")
                            DetailInfoRow(label: "Telefon / GSM", value: cari.gsm ?? cari.telefon ?? "-")
                            DetailInfoRow(label: "E-Posta", value: cari.email ?? "-")
                            DetailInfoRow(label: "Şehir / İlçe", value: "\(cari.sehir ?? "-") / \(cari.ilce ?? "-")")
                            DetailInfoRow(label: "Açık Adres", value: cari.adres ?? "-")
                            DetailInfoRow(label: "Risk Limiti", value: AppFormatters.money(cari.riskLimiti ?? 0))
                            DetailInfoRow(label: "Vade Günü", value: "\(cari.vadeGunu ?? 30) Gün")
                        }
                    }
                    .padding(.horizontal)
                    
                    // Hesap Ekstresi Başlık
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Hesap Ekstresi & Hareketler")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(AppTheme.textPrimary)
                            .padding(.horizontal)
                        
                        if hareketler.isEmpty {
                            GlassCard(cornerRadius: 14, padding: 20) {
                                HStack {
                                    Spacer()
                                    Text("Bu cariye ait henüz bir hareket kaydı bulunmuyor.")
                                        .font(.system(size: 12))
                                        .foregroundColor(AppTheme.textMuted)
                                    Spacer()
                                }
                            }
                            .padding(.horizontal)
                        } else {
                            VStack(spacing: 8) {
                                ForEach(hareketler) { h in
                                    HStack {
                                        VStack(alignment: .leading, spacing: 2) {
                                            Text(h.aciklama ?? h.islemTuru ?? "İşlem")
                                                .font(.system(size: 13, weight: .semibold))
                                                .foregroundColor(AppTheme.textPrimary)
                                            Text("\(h.tarih ?? "-") • \(h.belgeNo ?? "")")
                                                .font(.system(size: 11))
                                                .foregroundColor(AppTheme.textMuted)
                                        }
                                        Spacer()
                                        VStack(alignment: .trailing, spacing: 2) {
                                            let tutar = h.borc > 0 ? h.borc : h.alacak
                                            Text(AppFormatters.money(tutar))
                                                .font(.system(size: 13, weight: .bold))
                                                .foregroundColor(h.borc > 0 ? AppTheme.danger : AppTheme.success)
                                            Text(h.islemTuru ?? "")
                                                .font(.system(size: 10))
                                                .foregroundColor(AppTheme.textMuted)
                                        }
                                    }
                                    .padding(12)
                                    .background(AppTheme.cardBackground)
                                    .cornerRadius(10)
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                    
                    Spacer().frame(height: 30)
                }
                .padding(.top, 12)
            }
        }
        .navigationTitle("Cari Detayı")
        .navigationBarTitleDisplayMode(.inline)
        .alert("Rehbere Kaydet", isPresented: $showContactAlert) {
            Button("Tamam", role: .cancel) {}
        } message: {
            Text(contactSavedSuccess ? "\(cari.unvan) başarıyla telefon rehberinize kaydedildi." : "Rehbere kaydetme izni verilmedi veya bir hata oluştu.")
        }
    }
}
