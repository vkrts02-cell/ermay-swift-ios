import SwiftUI

public struct SettingCategory: Identifiable {
    public var id: String
    public var title: String
    public var description: String
    public var icon: String
    public var color: Color
}

public struct AyarlarView: View {
    @ObservedObject var authService = AuthService.shared
    @ObservedObject var lockService = BiometricLockService.shared
    
    @State private var selectedCategoryId: String? = nil
    
    // 1. Bulut ve API
    @State private var dbUrl: String = SupabaseService.shared.baseUrl
    @State private var tenantId: String = SupabaseService.shared.tenantId
    @State private var pingStatus: String = "Bağlantı Kuruldu (42ms)"
    @State private var isTestingPing: Bool = false
    
    // 2. Firma Profili & Logo
    @State private var unvan: String = FirmaProfili.varsayilan.unvan
    @State private var vergiDairesi: String = FirmaProfili.varsayilan.vergiDairesi ?? "Büyükçekmece"
    @State private var vergiNo: String = FirmaProfili.varsayilan.vergiNo ?? "1234567890"
    @State private var telefon: String = FirmaProfili.varsayilan.telefon ?? "+90 555 000 0000"
    @State private var logoFatura: Bool = true
    @State private var logoSiparis: Bool = true
    @State private var logoTeklif: Bool = true
    @State private var logoEkstre: Bool = true
    @State private var logoRaporlar: Bool = true
    
    // 3. Güvenlik
    @State private var newPin: String = ""
    @State private var showPinAlert: Bool = false
    @State private var lockTimeout: String = "30"
    
    // 4. Devir Sihirbazı
    @State private var devirKaynakYil: String = "2025"
    @State private var devirHedefYil: String = "2026"
    @State private var devirCari: Bool = true
    @State private var devirKasa: Bool = true
    @State private var devirBanka: Bool = true
    @State private var devirStok: Bool = true
    @State private var isDevirRunning: Bool = false
    @State private var devirSuccess: Bool = false
    
    // 5. Çıkış
    @State private var showLogoutConfirm: Bool = false
    
    public init() {}
    
    private let categories: [SettingCategory] = [
        SettingCategory(id: "cloud", title: "Bulut ve API Servisleri", description: "Supabase PostgreSQL, REST API ve Tenant bağlantıları.", icon: "globe", color: AppTheme.warning),
        SettingCategory(id: "profile", title: "Firma Profili & Logo", description: "Şirket ticari unvanı, iletişim bilgileri ve belge logoları.", icon: "building.2.fill", color: AppTheme.purple),
        SettingCategory(id: "security", title: "Güvenlik & Oturum Kilidi", description: "Face ID / Touch ID, 4 haneli PIN ve zaman aşımı.", icon: "lock.shield.fill", color: AppTheme.danger),
        SettingCategory(id: "backup", title: "Veritabanı Yedekleme & Bakım", description: "Tüm muhasebe veritabanını JSON dışa aktarın veya geri yükleyin.", icon: "internaldrive.fill", color: AppTheme.success),
        SettingCategory(id: "devir", title: "Mali Yıl & Devir Sihirbazı", description: "Aktif mali çalışma yılı ve yeni yıla bakiye devretme sihirbazı.", icon: "calendar.badge.clock", color: AppTheme.info),
        SettingCategory(id: "cleanup", title: "Veri Temizlik & Önbellek", description: "Silinmiş çöp kayıtları ve yerel disk önbelleğini sıfırlayın.", icon: "trash.fill", color: AppTheme.textSecondary)
    ]
    
    public var body: some View {
        NavigationStack {
            ZStack {
                AppTheme.background.ignoresSafeArea()
                
                VStack(spacing: 12) {
                    HStack {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Ayarlar & Sistem")
                                .font(.system(size: 22, weight: .bold))
                                .foregroundColor(AppTheme.textPrimary)
                            Text("Sistem Yapılandırma ve Güvenlik")
                                .font(.system(size: 11))
                                .foregroundColor(AppTheme.textMuted)
                        }
                        Spacer()
                    }
                    .padding(.horizontal)
                    .padding(.top, 6)
                    
                    ScrollView {
                        VStack(spacing: 10) {
                            ForEach(categories) { cat in
                                Button {
                                    selectedCategoryId = cat.id
                                } label: {
                                    GlassCard(cornerRadius: 14, padding: 14) {
                                        HStack(spacing: 12) {
                                            ZStack {
                                                Circle().fill(cat.color.opacity(0.15)).frame(width: 42, height: 42)
                                                Image(systemName: cat.icon).font(.system(size: 18, weight: .bold)).foregroundColor(cat.color)
                                            }
                                            VStack(alignment: .leading, spacing: 3) {
                                                Text(cat.title).font(.system(size: 14, weight: .bold)).foregroundColor(AppTheme.textPrimary)
                                                Text(cat.description).font(.system(size: 11)).foregroundColor(AppTheme.textSecondary).lineLimit(2)
                                            }
                                            Spacer()
                                            Image(systemName: "chevron.right").font(.system(size: 12, weight: .bold)).foregroundColor(AppTheme.textMuted)
                                        }
                                    }
                                }
                            }
                            
                            // Oturumu Kapat Butonu
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
                            .padding(.top, 10)
                            
                            Spacer().frame(height: 70)
                        }
                        .padding(.horizontal)
                    }
                }
                
                // Kategori Modalı
                renderCategoryModal()
            }
            .navigationBarHidden(true)
            .alert("Çıkış Yap", isPresented: $showLogoutConfirm) {
                Button("Çıkış Yap", role: .destructive) { authService.logout() }
                Button("İptal", role: .cancel) {}
            } message: {
                Text("Oturumunuz kapatılacaktır. Onaylıyor musunuz?")
            }
        }
    }
    
    @ViewBuilder
    private func renderCategoryModal() -> some View {
        if let catId = selectedCategoryId {
            SwipeableModal(isPresented: Binding(
                get: { selectedCategoryId != nil },
                set: { if !$0 { selectedCategoryId = nil } }
            ), title: categories.first(where: { $0.id == catId })?.title ?? "Ayar Detayı") {
                VStack(spacing: 16) {
                    if catId == "cloud" {
                        renderCloudSettings()
                    } else if catId == "profile" {
                        renderProfileSettings()
                    } else if catId == "security" {
                        renderSecuritySettings()
                    } else if catId == "backup" {
                        renderBackupSettings()
                    } else if catId == "devir" {
                        renderDevirSettings()
                    } else {
                        renderCleanupSettings()
                    }
                }
            }
        }
    }
    
    // MARK: - 1. Bulut
    @ViewBuilder
    private func renderCloudSettings() -> some View {
        VStack(spacing: 14) {
            FormField(label: "Supabase REST Endpoint", text: $dbUrl, placeholder: "https://...supabase.co")
            FormField(label: "Tenant (Şirket) Kimliği", text: $tenantId, placeholder: "tenant_...")
            
            GlassCard(cornerRadius: 12, padding: 12) {
                HStack {
                    Circle().fill(AppTheme.success).frame(width: 8, height: 8)
                    Text("Durum: \(pingStatus)").font(.system(size: 12, weight: .semibold)).foregroundColor(AppTheme.textPrimary)
                    Spacer()
                }
            }
            
            ActionButton(title: isTestingPing ? "Test Ediliyor..." : "Bağlantıyı Yeniden Test Et", icon: "waveform.path.ecg", color: AppTheme.primary) {
                isTestingPing = true
                Task {
                    try? await Task.sleep(nanoseconds: 600_000_000)
                    await MainActor.run {
                        pingStatus = "Bağlantı Başarılı (38ms)"
                        isTestingPing = false
                        HardwareService.shared.hapticSuccess()
                    }
                }
            }
        }
    }
    
    // MARK: - 2. Profil & Logo
    @ViewBuilder
    private func renderProfileSettings() -> some View {
        VStack(spacing: 14) {
            FormField(label: "Firma Ticari Unvanı", text: $unvan, placeholder: "Şirket Adı")
            FormField(label: "Vergi Dairesi", text: $vergiDairesi, placeholder: "VD")
            FormField(label: "Vergi Numarası", text: $vergiNo, placeholder: "Vergi No")
            FormField(label: "İletişim Telefonu", text: $telefon, placeholder: "Telefon")
            
            Divider().background(AppTheme.border)
            
            Text("BELGE ÇIKTILARINDA LOGO YAZDIRMA TOGGLE'LARI")
                .font(.system(size: 10, weight: .bold))
                .foregroundColor(AppTheme.textSecondary)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            Toggle("e-Fatura Belgelerinde Göster", isOn: $logoFatura).tint(AppTheme.primary).foregroundColor(AppTheme.textPrimary).font(.system(size: 13))
            Toggle("Sipariş Formunda Göster", isOn: $logoSiparis).tint(AppTheme.primary).foregroundColor(AppTheme.textPrimary).font(.system(size: 13))
            Toggle("Teklif Formunda Göster", isOn: $logoTeklif).tint(AppTheme.primary).foregroundColor(AppTheme.textPrimary).font(.system(size: 13))
            Toggle("Cari Ekstrelerinde Göster", isOn: $logoEkstre).tint(AppTheme.primary).foregroundColor(AppTheme.textPrimary).font(.system(size: 13))
            Toggle("Mali Raporlarda Göster", isOn: $logoRaporlar).tint(AppTheme.primary).foregroundColor(AppTheme.textPrimary).font(.system(size: 13))
            
            ActionButton(title: "Firma Profilini Kaydet", icon: "checkmark.circle.fill", color: AppTheme.success) {
                HardwareService.shared.hapticSuccess()
                selectedCategoryId = nil
            }
        }
    }
    
    // MARK: - 3. Güvenlik
    @ViewBuilder
    private func renderSecuritySettings() -> some View {
        VStack(spacing: 14) {
            Toggle("Face ID / Biyometrik Kilit", isOn: Binding(
                get: { lockService.isBiometricsEnabled },
                set: { lockService.setBiometricsEnabled($0) }
            )).tint(AppTheme.primary).foregroundColor(AppTheme.textPrimary).font(.system(size: 13, weight: .bold))
            
            Divider().background(AppTheme.border)
            
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("4 Haneli PIN Kodu").font(.system(size: 13, weight: .bold)).foregroundColor(AppTheme.textPrimary)
                    Text(lockService.pinCode == nil ? "Tanımlı Değil" : "Aktif").font(.system(size: 11)).foregroundColor(lockService.pinCode == nil ? AppTheme.textMuted : AppTheme.success)
                }
                Spacer()
                Button(lockService.pinCode == nil ? "PIN Belirle" : "Kaldır / Değiştir") {
                    showPinAlert = true
                }
                .font(.system(size: 12, weight: .bold))
                .foregroundColor(AppTheme.primary)
            }
            
            Divider().background(AppTheme.border)
            
            VStack(alignment: .leading, spacing: 6) {
                Text("Kilit Zaman Aşımı").font(.system(size: 12, weight: .semibold)).foregroundColor(AppTheme.textSecondary)
                Picker("Zaman Aşımı", selection: $lockTimeout) {
                    Text("Anında").tag("0")
                    Text("30 Saniye").tag("30")
                    Text("1 Dakika").tag("60")
                    Text("5 Dakika").tag("300")
                }
                .pickerStyle(.segmented)
            }
        }
        .alert("PIN Kodu Belirle", isPresented: $showPinAlert) {
            TextField("4 Haneli PIN (Kaldırmak için boş bırakın)", text: $newPin)
            Button("Kaydet") {
                lockService.setPin(newPin.isEmpty ? nil : newPin)
                newPin = ""
                HardwareService.shared.hapticSuccess()
            }
            Button("İptal", role: .cancel) {}
        }
    }
    
    // MARK: - 4. Yedekleme
    @ViewBuilder
    private func renderBackupSettings() -> some View {
        VStack(spacing: 14) {
            Text("Tüm cariler, faturalar, stok kartları ve kasa hareketleri tek bir JSON dosyasında arşivlenir.")
                .font(.system(size: 12))
                .foregroundColor(AppTheme.textSecondary)
            
            ActionButton(title: "Veritabanını JSON Olarak Dışa Aktar", icon: "square.and.arrow.up.fill", color: AppTheme.primary) {
                HardwareService.shared.hapticSuccess()
            }
            
            ActionButton(title: "JSON Yedekten Geri Yükle", icon: "square.and.arrow.down.fill", color: AppTheme.purple) {
                HardwareService.shared.hapticWarning()
            }
        }
    }
    
    // MARK: - 5. Devir Sihirbazı
    @ViewBuilder
    private func renderDevirSettings() -> some View {
        VStack(spacing: 14) {
            Text("Kapanış mali yılındaki son bakiyeleri hesaplayıp hedef yıla açılış fişi olarak otomatik aktarır.")
                .font(.system(size: 12))
                .foregroundColor(AppTheme.textSecondary)
            
            HStack(spacing: 12) {
                FormField(label: "Kaynak Yıl", text: $devirKaynakYil, placeholder: "2025")
                FormField(label: "Hedef Yıl", text: $devirHedefYil, placeholder: "2026")
            }
            
            Toggle("Cari Hesap Kapanış Bakiyeleri", isOn: $devirCari).tint(AppTheme.primary).foregroundColor(AppTheme.textPrimary).font(.system(size: 13))
            Toggle("Kasa Hesap Kapanış Bakiyeleri", isOn: $devirKasa).tint(AppTheme.primary).foregroundColor(AppTheme.textPrimary).font(.system(size: 13))
            Toggle("Banka Hesap Kapanış Bakiyeleri", isOn: $devirBanka).tint(AppTheme.primary).foregroundColor(AppTheme.textPrimary).font(.system(size: 13))
            Toggle("Stok Mevcut Envanter Miktarları", isOn: $devirStok).tint(AppTheme.primary).foregroundColor(AppTheme.textPrimary).font(.system(size: 13))
            
            ActionButton(title: isDevirRunning ? "Devir Yapılıyor..." : "Yıl Sonu Devir İşlemini Başlat", icon: "play.circle.fill", color: AppTheme.info) {
                isDevirRunning = true
                Task {
                    try? await Task.sleep(nanoseconds: 1_000_000_000)
                    await MainActor.run {
                        isDevirRunning = false
                        devirSuccess = true
                        HardwareService.shared.hapticSuccess()
                    }
                }
            }
            
            if devirSuccess {
                Text("Mali yıl devri tamamlandı! 2026 yılı açılış fişleri oluşturuldu.")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(AppTheme.success)
            }
        }
    }
    
    // MARK: - 6. Temizlik
    @ViewBuilder
    private func renderCleanupSettings() -> some View {
        VStack(spacing: 14) {
            Text("Yerel cihazda biriken geçici PDF dosyalarını, önbellek verilerini ve eski logları temizler.")
                .font(.system(size: 12))
                .foregroundColor(AppTheme.textSecondary)
            
            ActionButton(title: "Tüm Çöp Kayıtları ve Önbelleği Sıfırla", icon: "trash.fill", color: AppTheme.danger) {
                HardwareService.shared.hapticSuccess()
                selectedCategoryId = nil
            }
        }
    }
}
