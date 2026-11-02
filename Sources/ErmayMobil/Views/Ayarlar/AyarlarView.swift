import SwiftUI

public struct AyarlarView: View {
    @ObservedObject var authService = AuthService.shared
    @ObservedObject var lockService = BiometricLockService.shared
    
    @State private var firmaAdi: String = FirmaProfili.varsayilan.firmaAdi
    @State private var unvan: String = FirmaProfili.varsayilan.unvan
    @State private var vergiNo: String = FirmaProfili.varsayilan.vergiNo ?? ""
    @State private var telefon: String = FirmaProfili.varsayilan.telefon ?? ""
    
    @State private var newPin: String = ""
    @State private var showPinDialog: Bool = false
    @State private var isSyncing: Bool = false
    @State private var showLogoutConfirm: Bool = false
    
    public init() {}
    
    public var body: some View {
        NavigationStack {
            ZStack {
                AppTheme.background.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 20) {
                        HStack {
                            Text("Ayarlar")
                                .font(.system(size: 24, weight: .bold))
                                .foregroundColor(AppTheme.textPrimary)
                            Spacer()
                        }
                        .padding(.horizontal)
                        .padding(.top, 8)
                        
                        // Firma Profili
                        GlassCard(cornerRadius: 18, padding: 18) {
                            VStack(alignment: .leading, spacing: 14) {
                                Text("ŞİRKET PROFİLİ")
                                    .font(.system(size: 11, weight: .bold))
                                    .foregroundColor(AppTheme.textSecondary)
                                
                                FormField(label: "Firma Ticari Unvanı", text: $unvan, placeholder: "Firma Unvanı")
                                FormField(label: "Vergi Dairesi / No", text: $vergiNo, placeholder: "VD ve No")
                                FormField(label: "İletişim Telefonu", text: $telefon, placeholder: "Telefon")
                            }
                        }
                        .padding(.horizontal)
                        
                        // Bulut & Senkronizasyon Durumu
                        GlassCard(cornerRadius: 18, padding: 18) {
                            VStack(alignment: .leading, spacing: 14) {
                                Text("BULUT BAĞLANTISI (SUPABASE)")
                                    .font(.system(size: 11, weight: .bold))
                                    .foregroundColor(AppTheme.textSecondary)
                                
                                HStack {
                                    Circle()
                                        .fill(AppTheme.success)
                                        .frame(width: 10, height: 10)
                                    Text("Bulut Veritabanı Aktif")
                                        .font(.system(size: 13, weight: .semibold))
                                        .foregroundColor(AppTheme.textPrimary)
                                    Spacer()
                                    Text("PostgreSQL Online")
                                        .font(.system(size: 11))
                                        .foregroundColor(AppTheme.success)
                                }
                                
                                DetailInfoRow(label: "Tenant ID", value: SupabaseService.shared.tenantId)
                                
                                let queueCount = OfflineQueueService.shared.getQueue().count
                                HStack {
                                    Text("Çevrimdışı Kuyruk:")
                                        .font(.system(size: 12))
                                        .foregroundColor(AppTheme.textSecondary)
                                    Spacer()
                                    Text("\(queueCount) Bekleyen İşlem")
                                        .font(.system(size: 12, weight: .bold))
                                        .foregroundColor(queueCount > 0 ? AppTheme.warning : AppTheme.textMuted)
                                }
                                
                                Button {
                                    Task {
                                        isSyncing = true
                                        await OfflineQueueService.shared.processQueue()
                                        isSyncing = false
                                    }
                                } label: {
                                    HStack {
                                        Image(systemName: "arrow.triangle.2.circlepath")
                                        Text(isSyncing ? "Senkronize Ediliyor..." : "Şimdi Eşitle")
                                    }
                                    .font(.system(size: 13, weight: .bold))
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 10)
                                    .background(AppTheme.cardSecondary)
                                    .cornerRadius(10)
                                    .overlay(RoundedRectangle(cornerRadius: 10).stroke(AppTheme.border, lineWidth: 1))
                                }
                            }
                        }
                        .padding(.horizontal)
                        
                        // Güvenlik & Kilit
                        GlassCard(cornerRadius: 18, padding: 18) {
                            VStack(alignment: .leading, spacing: 14) {
                                Text("GÜVENLİK & KİLİT")
                                    .font(.system(size: 11, weight: .bold))
                                    .foregroundColor(AppTheme.textSecondary)
                                
                                Toggle("Face ID / Biyometrik Kilit", isOn: Binding(
                                    get: { lockService.isBiometricsEnabled },
                                    set: { lockService.setBiometricsEnabled($0) }
                                ))
                                .toggleStyle(SwitchToggleStyle(tint: AppTheme.primary))
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundColor(AppTheme.textPrimary)
                                
                                Divider().background(AppTheme.border)
                                
                                HStack {
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text("4 Haneli PIN Kodu")
                                            .font(.system(size: 13, weight: .semibold))
                                            .foregroundColor(AppTheme.textPrimary)
                                        Text(lockService.pinCode == nil ? "Tanımlı değil" : "Aktif")
                                            .font(.system(size: 11))
                                            .foregroundColor(lockService.pinCode == nil ? AppTheme.textMuted : AppTheme.success)
                                    }
                                    
                                    Spacer()
                                    
                                    Button(lockService.pinCode == nil ? "PIN Belirle" : "Değiştir / Kaldır") {
                                        showPinDialog = true
                                    }
                                    .font(.system(size: 12, weight: .bold))
                                    .foregroundColor(AppTheme.primary)
                                }
                            }
                        }
                        .padding(.horizontal)
                        
                        // Çıkış Yap Butonu
                        Button {
                            showLogoutConfirm = true
                        } label: {
                            HStack(spacing: 8) {
                                Image(systemName: "rectangle.portrait.and.arrow.right")
                                Text("Oturumu Kapat / Çıkış Yap")
                            }
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(AppTheme.danger)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(AppTheme.cardBackground)
                            .cornerRadius(12)
                            .overlay(RoundedRectangle(cornerRadius: 12).stroke(AppTheme.danger.opacity(0.3), lineWidth: 1))
                        }
                        .padding(.horizontal)
                        
                        Spacer().frame(height: 70)
                    }
                }
            }
            .navigationBarHidden(true)
            .alert("PIN Kodu Belirle", isPresented: $showPinDialog) {
                TextField("4 Haneli PIN (Kaldırmak için boş bırakın)", text: $newPin)
                Button("Kaydet") {
                    lockService.setPin(newPin.isEmpty ? nil : newPin)
                    newPin = ""
                }
                Button("İptal", role: .cancel) {}
            }
            .alert("Çıkış Yap", isPresented: $showLogoutConfirm) {
                Button("Çıkış Yap", role: .destructive) {
                    authService.logout()
                }
                Button("Vazgeç", role: .cancel) {}
            } message: {
                Text("Oturumunuz kapatılacaktır. Emin misiniz?")
            }
        }
    }
}

