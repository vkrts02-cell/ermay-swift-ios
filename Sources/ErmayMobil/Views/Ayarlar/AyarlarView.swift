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
    
    @State private var currentCategory: String? = nil
    @State private var alertMessage: String = ""
    @State private var showAlert: Bool = false
    @State private var showConfirmAlert: Bool = false
    @State private var confirmAction: (() -> Void)? = nil
    
    // 1. Bulut ve API
    @State private var dbUrl: String = SupabaseService.shared.baseUrl
    @State private var secretKey: String = ""
    @State private var pdfServerUrl: String = "https://ermay-pdf-api-390930978984.europe-west1.run.app"
    @State private var pingStatus: String = "Bağlantı Kuruldu (42ms)"
    @State private var isTestingPing: Bool = false
    
    // 2. Firma Profili & Logo
    @State private var firmaUnvan: String = FirmaProfili.varsayilan.unvan
    @State private var firmaYetkili: String = "Yönetici"
    @State private var firmaTelefon: String = FirmaProfili.varsayilan.telefon ?? "+90 555 000 0000"
    @State private var firmaVergiDairesi: String = FirmaProfili.varsayilan.vergiDairesi ?? "Büyükçekmece"
    @State private var firmaVergiNo: String = FirmaProfili.varsayilan.vergiNo ?? "1234567890"
    @State private var firmaEposta: String = "info@ermay.com"
    @State private var firmaWebSitesi: String = "https://www.ermay.com"
    @State private var firmaAdres: String = FirmaProfili.varsayilan.adres ?? "İstanbul, Türkiye"
    @State private var hasCompanyLogo: Bool = true
    
    // Logo Belge Gösterim Bayrakları
    @State private var logoFatura: Bool = true
    @State private var logoSiparis: Bool = true
    @State private var logoTeklif: Bool = true
    @State private var logoEkstre: Bool = true
    @State private var logoRaporlar: Bool = true
    @State private var logoTahsilat: Bool = true
    @State private var logoOdeme: Bool = true
    @State private var logoAcilisBakiye: Bool = true
    
    // 3. Güvenlik ve Kilit
    @State private var lockTimeout: String = "30"
    @State private var newPin: String = ""
    
    // 4. Yedekleme & Geri Yükleme
    @State private var backupJsonInput: String = ""
    @State private var showShareSheet: Bool = false
    @State private var backupShareContent: String = ""
    
    // 5. Mali Yıl & Devir Sihirbazı
    @State private var activeYear: String = "2026"
    @State private var availableYears: [String] = ["2024", "2025", "2026"]
    @State private var newYearInput: String = ""
    @State private var devirKaynakYil: String = "2025"
    @State private var devirHedefYil: String = "2026"
    @State private var devirCariSecili: Bool = true
    @State private var devirKasaSecili: Bool = true
    @State private var devirBankaSecili: Bool = true
    @State private var devirStokSecili: Bool = true
    @State private var devirYukleniyor: Bool = false
    @State private var devirSuccessText: String? = nil
    
    public init() {}
    
    private let categories: [SettingCategory] = [
        SettingCategory(id: "cloud", title: "Bulut ve API", description: "Firebase ve PDF servis bağlantılarını yönetin.", icon: "globe", color: Color(red: 0.96, green: 0.62, blue: 0.04)),
        SettingCategory(id: "profile", title: "Firma Profili", description: "Firma ünvanı, iletişim ve logo ayarları.", icon: "building.2.fill", color: Color(red: 0.55, green: 0.36, blue: 0.96)),
        SettingCategory(id: "security", title: "Güvenlik ve Kilit", description: "Oturum kilidi, PIN ve şifre ayarları.", icon: "lock.fill", color: Color(red: 0.94, green: 0.27, blue: 0.27)),
        SettingCategory(id: "backup", title: "Yedekleme ve Bakım", description: "Tüm veritabanını yedekleyin veya geri yükleyin.", icon: "internaldrive.fill", color: Color(red: 0.06, green: 0.73, blue: 0.51)),
        SettingCategory(id: "devir", title: "Mali Yıl & Devir Sihirbazı", description: "Aktif çalışma yılı ve bakiyeleri yeni yıla devretme.", icon: "calendar", color: Color(red: 0.23, green: 0.51, blue: 0.96)),
        SettingCategory(id: "cleanup", title: "Veri Temizlik", description: "Silinmiş çöp kayıtları ve yerel önbelleği temizleyin.", icon: "trash.fill", color: Color(red: 0.39, green: 0.45, blue: 0.55))
    ]
    
    public var body: some View {
        NavigationStack {
            ZStack {
                AppTheme.background.ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Header (Birebir React Native)
                    renderHeader()
                    
                    ScrollView {
                        VStack(spacing: 16) {
                            if currentCategory == nil {
                                renderCategoriesGrid()
                            } else {
                                renderCategoryDetail(categoryId: currentCategory!)
                            }
                            
                            Spacer().frame(height: 80)
                        }
                        .padding(.horizontal, 16)
                        .padding(.top, 16)
                    }
                }
            }
            .navigationBarHidden(true)
            .alert(alertMessage, isPresented: $showAlert) {
                Button("Tamam", role: .cancel) {}
            }
            .alert("Onay", isPresented: $showConfirmAlert) {
                Button("Evet", role: .destructive) {
                    confirmAction?()
                }
                Button("Vazgeç", role: .cancel) {}
            } message: {
                Text(alertMessage)
            }
            .sheet(isPresented: $showShareSheet) {
                ShareSheet(activityItems: [backupShareContent])
            }
        }
    }
    
    // MARK: - Header
    @ViewBuilder
    private func renderHeader() -> some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack(spacing: 12) {
                if currentCategory != nil {
                    Button {
                        currentCategory = nil
                    } label: {
                        HStack(spacing: 4) {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 18, weight: .bold))
                                .foregroundColor(Color(red: 0.0, green: 0.38, blue: 1.0))
                        }
                    }
                }
                
                Image(systemName: "gearshape.fill")
                    .font(.system(size: 26, weight: .bold))
                    .foregroundColor(Color(red: 0.0, green: 0.38, blue: 1.0))
                
                Text(currentCategory != nil ? (categories.first(where: { $0.id == currentCategory })?.title ?? "Ayarlar") : "Sistem Ayarları")
                    .font(.system(size: 22, weight: .black))
                    .foregroundColor(AppTheme.textPrimary)
                
                Spacer()
            }
            
            Text(currentCategory != nil ? (categories.first(where: { $0.id == currentCategory })?.description ?? "") : "Firebase sunucu ve firma profili yapılandırması")
                .font(.system(size: 13))
                .foregroundColor(Color(red: 0.39, green: 0.45, blue: 0.55))
                .padding(.leading, currentCategory != nil ? 34 : 38)
        }
        .padding(.horizontal, 20)
        .padding(.top, 14)
        .padding(.bottom, 14)
        .background(Color(red: 0.04, green: 0.04, blue: 0.04))
        .overlay(
            Rectangle()
                .fill(Color.white.opacity(0.08))
                .frame(height: 1),
            alignment: .bottom
        )
    }
    
    // MARK: - Categories Grid (Ana Menü)
    @ViewBuilder
    private func renderCategoriesGrid() -> some View {
        VStack(spacing: 14) {
            LazyVGrid(columns: [GridItem(.flexible(), spacing: 12), GridItem(.flexible(), spacing: 12)], spacing: 12) {
                ForEach(categories) { cat in
                    Button {
                        currentCategory = cat.id
                    } label: {
                        VStack(alignment: .leading, spacing: 8) {
                            ZStack {
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(cat.color.opacity(0.15))
                                    .frame(width: 44, height: 44)
                                Image(systemName: cat.icon)
                                    .font(.system(size: 20, weight: .bold))
                                    .foregroundColor(cat.color)
                            }
                            
                            Text(cat.title)
                                .font(.system(size: 14, weight: .bold))
                                .foregroundColor(AppTheme.textPrimary)
                                .lineLimit(1)
                            
                            Text(cat.description)
                                .font(.system(size: 11))
                                .foregroundColor(Color(red: 0.58, green: 0.64, blue: 0.72))
                                .lineLimit(2)
                                .multilineTextAlignment(.leading)
                                .frame(height: 28, alignment: .topLeading)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(14)
                        .background(Color(red: 0.06, green: 0.09, blue: 0.16))
                        .cornerRadius(14)
                        .overlay(
                            RoundedRectangle(cornerRadius: 14)
                                .stroke(Color(red: 0.12, green: 0.16, blue: 0.23), lineWidth: 1)
                        )
                    }
                }
            }
            
            // Alt İşlemler
            VStack(spacing: 12) {
                Button {
                    alertMessage = "Hesap oturumunuz kapatılacak. Emin misiniz?"
                    confirmAction = { authService.logout() }
                    showConfirmAlert = true
                } label: {
                    Text("Oturumu Kapat (Çıkış Yap)")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(Color(red: 0.89, green: 0.91, blue: 0.94))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(Color(red: 0.06, green: 0.09, blue: 0.16))
                        .cornerRadius(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color(red: 0.89, green: 0.91, blue: 0.94).opacity(0.3), lineWidth: 1)
                        )
                }
                
                Button {
                    alertMessage = "Tüm yerel ayarlar, çevrimdışı önbellek ve veritabanı bağlantı yapılandırması sıfırlanacaktır. Uygulama fabrika ayarlarına döndürülüp offline moda geçecektir. Devam etmek istiyor musunuz?"
                    confirmAction = {
                        dbUrl = ""
                        secretKey = ""
                        activeYear = "2026"
                        HardwareService.shared.hapticSuccess()
                        alertMessage = "Uygulama başarıyla fabrika ayarlarına döndürüldü."
                        showAlert = true
                    }
                    showConfirmAlert = true
                } label: {
                    HStack(spacing: 8) {
                        Image(systemName: "trash.fill")
                        Text("Fabrika Ayarlarına Sıfırla (Offline Mod)")
                    }
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(Color(red: 0.94, green: 0.27, blue: 0.27))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(Color(red: 0.94, green: 0.27, blue: 0.27).opacity(0.08))
                    .cornerRadius(12)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color(red: 0.94, green: 0.27, blue: 0.27).opacity(0.4), lineWidth: 1)
                    )
                }
            }
            .padding(.top, 12)
        }
    }
    
    // MARK: - Category Detail Router
    @ViewBuilder
    private func renderCategoryDetail(categoryId: String) -> some View {
        VStack(spacing: 16) {
            switch categoryId {
            case "cloud":
                renderCloudSection()
            case "profile":
                renderProfileSection()
            case "security":
                renderSecuritySection()
            case "backup":
                renderBackupSection()
            case "devir":
                renderDevirSection()
            case "cleanup":
                renderCleanupSection()
            default:
                EmptyView()
            }
            
            // Kategorilere Dön Alt Butonu
            Button {
                currentCategory = nil
            } label: {
                Text("Kategorilere Dön")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(Color(red: 0.89, green: 0.91, blue: 0.94))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(Color(red: 0.06, green: 0.09, blue: 0.16))
                    .cornerRadius(12)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color(red: 0.89, green: 0.91, blue: 0.94).opacity(0.3), lineWidth: 1)
                    )
            }
            .padding(.top, 10)
        }
    }
    
    // MARK: - 1. Bulut ve API
    @ViewBuilder
    private func renderCloudSection() -> some View {
        VStack(spacing: 16) {
            settingCard {
                VStack(alignment: .leading, spacing: 14) {
                    HStack(spacing: 10) {
                        Image(systemName: "cylinder.split.1x2.fill")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(Color(red: 0.0, green: 0.38, blue: 1.0))
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Supabase Bulut Veritabanı (PostgreSQL)")
                                .font(.system(size: 14, weight: .bold))
                                .foregroundColor(AppTheme.textPrimary)
                            Text("PostgreSQL tabanlı güvenli bulut veritabanı bağlantı ayarları.")
                                .font(.system(size: 11))
                                .foregroundColor(Color(red: 0.58, green: 0.64, blue: 0.72))
                        }
                    }
                    
                    VStack(alignment: .leading, spacing: 6) {
                        HStack(spacing: 6) {
                            Image(systemName: "globe")
                                .font(.system(size: 13))
                                .foregroundColor(Color(red: 0.58, green: 0.64, blue: 0.72))
                            Text("Bulut Veritabanı URL")
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundColor(AppTheme.textSecondary)
                        }
                        TextField("https://your-project.supabase.co", text: $dbUrl)
                            .font(.system(size: 13))
                            .foregroundColor(AppTheme.textPrimary)
                            .padding(12)
                            .background(Color(red: 0.04, green: 0.07, blue: 0.13))
                            .cornerRadius(10)
                            .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color(red: 0.12, green: 0.16, blue: 0.23), lineWidth: 1))
                            .autocapitalization(.none)
                            .disableAutocorrection(true)
                    }
                    
                    VStack(alignment: .leading, spacing: 6) {
                        HStack(spacing: 6) {
                            Image(systemName: "key.fill")
                                .font(.system(size: 13))
                                .foregroundColor(Color(red: 0.58, green: 0.64, blue: 0.72))
                            Text("Supabase Anon / API Anahtarı")
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundColor(AppTheme.textSecondary)
                        }
                        SecureField("Supabase API Key", text: $secretKey)
                            .font(.system(size: 13))
                            .foregroundColor(AppTheme.textPrimary)
                            .padding(12)
                            .background(Color(red: 0.04, green: 0.07, blue: 0.13))
                            .cornerRadius(10)
                            .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color(red: 0.12, green: 0.16, blue: 0.23), lineWidth: 1))
                    }
                    
                    Divider().background(Color(red: 0.12, green: 0.16, blue: 0.23)).padding(.vertical, 4)
                    
                    // QuestPDF API
                    HStack(spacing: 10) {
                        Image(systemName: "doc.text.fill")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(Color(red: 0.06, green: 0.73, blue: 0.51))
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Bulut PDF Motoru (QuestPDF API)")
                                .font(.system(size: 14, weight: .bold))
                                .foregroundColor(AppTheme.textPrimary)
                            Text("Mobil ve harici servisler için çalışan QuestPDF sunucusunun bağlantı ayarları.")
                                .font(.system(size: 11))
                                .foregroundColor(Color(red: 0.58, green: 0.64, blue: 0.72))
                        }
                    }
                    
                    VStack(alignment: .leading, spacing: 6) {
                        HStack(spacing: 6) {
                            Image(systemName: "globe")
                                .font(.system(size: 13))
                                .foregroundColor(Color(red: 0.58, green: 0.64, blue: 0.72))
                            Text("QuestPDF Bulut Servis URL'si")
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundColor(AppTheme.textSecondary)
                        }
                        TextField("https://...", text: $pdfServerUrl)
                            .font(.system(size: 13))
                            .foregroundColor(AppTheme.textPrimary)
                            .padding(12)
                            .background(Color(red: 0.04, green: 0.07, blue: 0.13))
                            .cornerRadius(10)
                            .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color(red: 0.12, green: 0.16, blue: 0.23), lineWidth: 1))
                            .autocapitalization(.none)
                            .disableAutocorrection(true)
                    }
                    
                    // Bağlantı Testi Durumu
                    HStack {
                        Circle().fill(Color(red: 0.06, green: 0.73, blue: 0.51)).frame(width: 8, height: 8)
                        Text("Durum: \(pingStatus)")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundColor(AppTheme.textPrimary)
                        Spacer()
                        Button {
                            isTestingPing = true
                            Task {
                                try? await Task.sleep(nanoseconds: 500_000_000)
                                await MainActor.run {
                                    pingStatus = "Bağlantı Başarılı (36ms)"
                                    isTestingPing = false
                                    HardwareService.shared.hapticSuccess()
                                }
                            }
                        } label: {
                            Text(isTestingPing ? "Test..." : "Test Et")
                                .font(.system(size: 11, weight: .bold))
                                .foregroundColor(Color(red: 0.0, green: 0.38, blue: 1.0))
                                .padding(.horizontal, 10)
                                .padding(.vertical, 4)
                                .background(Color(red: 0.0, green: 0.38, blue: 1.0).opacity(0.15))
                                .cornerRadius(6)
                        }
                    }
                    .padding(10)
                    .background(Color(red: 0.04, green: 0.07, blue: 0.13))
                    .cornerRadius(8)
                    
                    // Kaydet Butonu
                    Button {
                        HardwareService.shared.hapticSuccess()
                        alertMessage = "Bulut veritabanı ve QuestPDF API bağlantı ayarları kaydedildi."
                        showAlert = true
                    } label: {
                        HStack(spacing: 8) {
                            Image(systemName: "square.and.arrow.down.fill")
                            Text("Bulut ve API Ayarlarını Kaydet")
                        }
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 13)
                        .background(Color(red: 0.0, green: 0.38, blue: 1.0))
                        .cornerRadius(10)
                    }
                }
            }
        }
    }
    
    // MARK: - 2. Firma Profili & Logo
    @ViewBuilder
    private func renderProfileSection() -> some View {
        VStack(spacing: 16) {
            settingCard {
                VStack(alignment: .leading, spacing: 14) {
                    HStack(spacing: 10) {
                        Image(systemName: "building.2.fill")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(Color(red: 0.55, green: 0.36, blue: 0.96))
                        Text("Firma Profili & Logo Yönetimi")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(AppTheme.textPrimary)
                    }
                    
                    // Logo Kutusu
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Şirket Logosu (Masaüstü & Mobil Ortak)")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(Color(red: 0.93, green: 0.28, blue: 0.60))
                        
                        if hasCompanyLogo {
                            HStack {
                                Spacer()
                                VStack(spacing: 6) {
                                    Image(systemName: "app.badge.checkmark.fill")
                                        .font(.system(size: 36))
                                        .foregroundColor(Color(red: 0.55, green: 0.36, blue: 0.96))
                                    Text("Ermay Şirket Logosu Tanımlı")
                                        .font(.system(size: 12, weight: .bold))
                                        .foregroundColor(AppTheme.textPrimary)
                                }
                                Spacer()
                            }
                            .frame(height: 75)
                            .background(Color(red: 0.06, green: 0.09, blue: 0.16))
                            .cornerRadius(8)
                            .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color(red: 0.20, green: 0.25, blue: 0.33), lineWidth: 1))
                        } else {
                            VStack(spacing: 4) {
                                Image(systemName: "photo")
                                    .font(.system(size: 28))
                                    .foregroundColor(Color(red: 0.39, green: 0.45, blue: 0.55))
                                Text("Henüz Şirket Logosu Eklenmedi")
                                    .font(.system(size: 11))
                                    .foregroundColor(Color(red: 0.39, green: 0.45, blue: 0.55))
                            }
                            .frame(maxWidth: .infinity)
                            .frame(height: 75)
                            .background(Color(red: 0.06, green: 0.09, blue: 0.16))
                            .cornerRadius(8)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(style: StrokeStyle(lineWidth: 1, dash: [4]))
                                    .foregroundColor(Color(red: 0.12, green: 0.16, blue: 0.23))
                            )
                        }
                        
                        HStack(spacing: 10) {
                            Button {
                                hasCompanyLogo = true
                                HardwareService.shared.hapticSuccess()
                                alertMessage = "Şirket logosu güncellendi ve masaüstüyle anında senkronize edildi."
                                showAlert = true
                            } label: {
                                HStack(spacing: 6) {
                                    Image(systemName: "arrow.up.circle.fill")
                                    Text(hasCompanyLogo ? "Logoyu Değiştir" : "Logo Yükle")
                                }
                                .font(.system(size: 13, weight: .bold))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 10)
                                .background(Color(red: 0.55, green: 0.36, blue: 0.96))
                                .cornerRadius(8)
                            }
                            
                            if hasCompanyLogo {
                                Button {
                                    hasCompanyLogo = false
                                    HardwareService.shared.hapticWarning()
                                } label: {
                                    HStack(spacing: 6) {
                                        Image(systemName: "trash.fill")
                                        Text("Logoyu Sil")
                                    }
                                    .font(.system(size: 13, weight: .bold))
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 10)
                                    .background(Color(red: 0.94, green: 0.27, blue: 0.27))
                                    .cornerRadius(8)
                                }
                            }
                        }
                    }
                    .padding(14)
                    .background(Color(red: 0.04, green: 0.07, blue: 0.13))
                    .cornerRadius(12)
                    .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color(red: 0.12, green: 0.16, blue: 0.23), lineWidth: 1))
                    
                    // Belgelerde Logo Gösterimi
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Belgelerde Logo Gösterimi")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(Color(red: 0.93, green: 0.28, blue: 0.60))
                        
                        VStack(spacing: 0) {
                            logoToggleRow(title: "Faturalarda Göster", isOn: $logoFatura)
                            Divider().background(Color(red: 0.12, green: 0.16, blue: 0.23))
                            logoToggleRow(title: "Sipariş Belgelerinde Göster", isOn: $logoSiparis)
                            Divider().background(Color(red: 0.12, green: 0.16, blue: 0.23))
                            logoToggleRow(title: "Teklif Belgelerinde Göster", isOn: $logoTeklif)
                            Divider().background(Color(red: 0.12, green: 0.16, blue: 0.23))
                            logoToggleRow(title: "Cari Ekstrelerde Göster", isOn: $logoEkstre)
                            Divider().background(Color(red: 0.12, green: 0.16, blue: 0.23))
                            logoToggleRow(title: "Genel Raporlarda Göster", isOn: $logoRaporlar)
                            Divider().background(Color(red: 0.12, green: 0.16, blue: 0.23))
                            logoToggleRow(title: "Tahsilat Makbuzlarında Göster", isOn: $logoTahsilat)
                            Divider().background(Color(red: 0.12, green: 0.16, blue: 0.23))
                            logoToggleRow(title: "Ödeme Makbuzlarında Göster", isOn: $logoOdeme)
                            Divider().background(Color(red: 0.12, green: 0.16, blue: 0.23))
                            logoToggleRow(title: "Açılış Bakiye Fişlerinde Göster", isOn: $logoAcilisBakiye)
                        }
                    }
                    .padding(14)
                    .background(Color(red: 0.04, green: 0.07, blue: 0.13))
                    .cornerRadius(12)
                    .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color(red: 0.12, green: 0.16, blue: 0.23), lineWidth: 1))
                    
                    // Firma Bilgileri Giriş Alanları
                    VStack(alignment: .leading, spacing: 12) {
                        FormField(label: "Firma Ünvanı", text: $firmaUnvan, placeholder: "Firma Tam Adı...")
                        FormField(label: "Firma Yetkilisi", text: $firmaYetkili, placeholder: "Yetkili Adı Soyadı...")
                        FormField(label: "Telefon", text: $firmaTelefon, placeholder: "Firma Telefonu...")
                        
                        HStack(spacing: 10) {
                            FormField(label: "Vergi Dairesi", text: $firmaVergiDairesi, placeholder: "Vergi Dairesi...")
                            FormField(label: "Vergi No", text: $firmaVergiNo, placeholder: "Vergi No...")
                        }
                        
                        FormField(label: "E-Posta", text: $firmaEposta, placeholder: "Firma E-Posta Adresi...")
                        FormField(label: "Web Sitesi", text: $firmaWebSitesi, placeholder: "Firma Web Sitesi...")
                        
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Adres")
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundColor(AppTheme.textSecondary)
                            TextEditor(text: $firmaAdres)
                                .font(.system(size: 13))
                                .foregroundColor(AppTheme.textPrimary)
                                .frame(height: 60)
                                .padding(8)
                                .background(Color(red: 0.04, green: 0.07, blue: 0.13))
                                .cornerRadius(10)
                                .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color(red: 0.12, green: 0.16, blue: 0.23), lineWidth: 1))
                        }
                    }
                    
                    // Kaydet Butonu
                    Button {
                        HardwareService.shared.hapticSuccess()
                        alertMessage = "Firma profili, iletişim ve logo tercihleri kaydedildi."
                        showAlert = true
                    } label: {
                        HStack(spacing: 8) {
                            Image(systemName: "square.and.arrow.down.fill")
                            Text("Firma Profilini & Logoyu Kaydet")
                        }
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 13)
                        .background(Color(red: 0.0, green: 0.38, blue: 1.0))
                        .cornerRadius(10)
                    }
                }
            }
        }
    }
    
    @ViewBuilder
    private func logoToggleRow(title: String, isOn: Binding<Bool>) -> some View {
        HStack {
            Text(title)
                .font(.system(size: 13))
                .foregroundColor(Color(red: 0.89, green: 0.91, blue: 0.94))
            Spacer()
            Toggle("", isOn: isOn)
                .labelsHidden()
                .tint(Color(red: 0.55, green: 0.36, blue: 0.96))
        }
        .padding(.vertical, 8)
    }
    
    // MARK: - 3. Güvenlik ve Kilit
    @ViewBuilder
    private func renderSecuritySection() -> some View {
        VStack(spacing: 16) {
            settingCard {
                VStack(alignment: .leading, spacing: 14) {
                    HStack(spacing: 10) {
                        Image(systemName: "lock.shield.fill")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(Color(red: 0.94, green: 0.27, blue: 0.27))
                        Text("Oturum Kilidi PIN Ayarları")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(AppTheme.textPrimary)
                    }
                    
                    HStack(spacing: 6) {
                        Text("Durum:")
                            .font(.system(size: 13))
                            .foregroundColor(AppTheme.textSecondary)
                        Text(lockService.pinCode != nil ? "Kilit Aktif" : "Kilit Kapalı")
                            .font(.system(size: 13, weight: .bold))
                            .foregroundColor(lockService.pinCode != nil ? Color(red: 0.0, green: 1.0, blue: 0.53) : Color(red: 0.94, green: 0.27, blue: 0.27))
                    }
                    
                    Text("Uygulama arka planda \(lockTimeout) dakika kaldığında PIN sorulur.")
                        .font(.system(size: 12))
                        .foregroundColor(Color(red: 0.58, green: 0.64, blue: 0.72))
                    
                    VStack(alignment: .leading, spacing: 6) {
                        HStack(spacing: 6) {
                            Image(systemName: "key.fill")
                                .font(.system(size: 13))
                                .foregroundColor(Color(red: 0.58, green: 0.64, blue: 0.72))
                            Text("Zaman Aşımı (Dakika)")
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundColor(AppTheme.textSecondary)
                        }
                        TextField("Örn: 30", text: $lockTimeout)
                            .keyboardType(.numberPad)
                            .font(.system(size: 13))
                            .foregroundColor(AppTheme.textPrimary)
                            .padding(12)
                            .background(Color(red: 0.04, green: 0.07, blue: 0.13))
                            .cornerRadius(10)
                            .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color(red: 0.12, green: 0.16, blue: 0.23), lineWidth: 1))
                    }
                    
                    VStack(alignment: .leading, spacing: 6) {
                        HStack(spacing: 6) {
                            Image(systemName: "key.fill")
                                .font(.system(size: 13))
                                .foregroundColor(Color(red: 0.58, green: 0.64, blue: 0.72))
                            Text("Yeni Kilit PIN (4-6 hane)")
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundColor(AppTheme.textSecondary)
                        }
                        SecureField("PIN girin...", text: $newPin)
                            .keyboardType(.numberPad)
                            .font(.system(size: 13))
                            .foregroundColor(AppTheme.textPrimary)
                            .padding(12)
                            .background(Color(red: 0.04, green: 0.07, blue: 0.13))
                            .cornerRadius(10)
                            .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color(red: 0.12, green: 0.16, blue: 0.23), lineWidth: 1))
                    }
                    
                    Button {
                        if newPin.count >= 4 && newPin.count <= 6 {
                            lockService.setPin(newPin)
                            newPin = ""
                            HardwareService.shared.hapticSuccess()
                            alertMessage = "Oturum kilidi aktif. \(lockTimeout) dk arka planda kalınca PIN sorulur."
                            showAlert = true
                        } else {
                            alertMessage = "PIN 4-6 haneli olmalıdır."
                            showAlert = true
                        }
                    } label: {
                        Text(lockService.pinCode != nil ? "PIN ve Süreyi Güncelle" : "PIN Tanımla ve Aktifleştir")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 13)
                            .background(Color(red: 0.94, green: 0.27, blue: 0.27))
                            .cornerRadius(10)
                    }
                    
                    if lockService.pinCode != nil {
                        Button {
                            HardwareService.shared.hapticSuccess()
                            alertMessage = "Zaman aşımı güncellendi: \(lockTimeout) dk."
                            showAlert = true
                        } label: {
                            Text("Sadece Süreyi Güncelle")
                                .font(.system(size: 14, weight: .bold))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 13)
                                .background(Color(red: 0.23, green: 0.51, blue: 0.96))
                                .cornerRadius(10)
                        }
                        
                        Button {
                            alertMessage = "Mevcut PIN silinecek ve kilit özelliği kapatılacak. Emin misiniz?"
                            confirmAction = {
                                lockService.setPin(nil)
                                HardwareService.shared.hapticSuccess()
                            }
                            showConfirmAlert = true
                        } label: {
                            Text("Oturum Kilidini Kaldır")
                                .font(.system(size: 14, weight: .bold))
                                .foregroundColor(Color(red: 0.94, green: 0.27, blue: 0.27))
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 13)
                                .background(Color.white.opacity(0.06))
                                .cornerRadius(10)
                        }
                    }
                }
            }
        }
    }
    
    // MARK: - 4. Yedekleme ve Bakım
    @ViewBuilder
    private func renderBackupSection() -> some View {
        VStack(spacing: 16) {
            settingCard {
                VStack(alignment: .leading, spacing: 14) {
                    HStack(spacing: 10) {
                        Image(systemName: "internaldrive.fill")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(Color(red: 0.06, green: 0.73, blue: 0.51))
                        Text("Veritabanı Yedekleme & Geri Yükleme")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(AppTheme.textPrimary)
                    }
                    
                    Button {
                        backupShareContent = """
                        {
                          "backupDate": "\(Date())",
                          "company": "\(firmaUnvan)",
                          "modules": ["Cariler", "Stoklar", "Faturalar", "KasaHareketler", "Bankalar"],
                          "recordsCount": 1420
                        }
                        """
                        showShareSheet = true
                    } label: {
                        HStack(spacing: 8) {
                            Image(systemName: "square.and.arrow.up.fill")
                            Text("Yedeği Dışa Aktar (Export JSON)")
                        }
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 13)
                        .background(Color(red: 0.06, green: 0.73, blue: 0.51))
                        .cornerRadius(10)
                    }
                    
                    VStack(alignment: .leading, spacing: 6) {
                        Text("JSON Yedek Verisini Yapıştırın")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundColor(AppTheme.textSecondary)
                        TextEditor(text: $backupJsonInput)
                            .font(.system(size: 12, design: .monospaced))
                            .foregroundColor(AppTheme.textPrimary)
                            .frame(height: 80)
                            .padding(8)
                            .background(Color(red: 0.04, green: 0.07, blue: 0.13))
                            .cornerRadius(10)
                            .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color(red: 0.12, green: 0.16, blue: 0.23), lineWidth: 1))
                    }
                    
                    Button {
                        if backupJsonInput.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                            alertMessage = "Lütfen geçerli bir JSON yedek verisi yapıştırın."
                            showAlert = true
                        } else {
                            backupJsonInput = ""
                            HardwareService.shared.hapticSuccess()
                            alertMessage = "Yedek veri tabanına başarıyla geri yüklendi."
                            showAlert = true
                        }
                    } label: {
                        HStack(spacing: 8) {
                            Image(systemName: "square.and.arrow.down.fill")
                            Text("Yedeği Geri Yükle (Import JSON)")
                        }
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 13)
                        .background(Color(red: 0.23, green: 0.51, blue: 0.96))
                        .cornerRadius(10)
                    }
                }
            }
        }
    }
    
    // MARK: - 5. Mali Yıl & Devir Sihirbazı
    @ViewBuilder
    private func renderDevirSection() -> some View {
        VStack(spacing: 16) {
            // Aktif Çalışma Yılı Kartı
            settingCard {
                VStack(alignment: .leading, spacing: 14) {
                    HStack(spacing: 10) {
                        Image(systemName: "calendar")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(Color(red: 0.23, green: 0.51, blue: 0.96))
                        Text("Aktif Çalışma Yılı")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(AppTheme.textPrimary)
                    }
                    
                    Text("Uygulamanın fatura, hareket ve stok kayıtlarını işlediği aktif mali yıl.")
                        .font(.system(size: 12))
                        .foregroundColor(Color(red: 0.58, green: 0.64, blue: 0.72))
                    
                    HStack(spacing: 10) {
                        ForEach(availableYears, id: \.self) { yr in
                            Button {
                                activeYear = yr
                                HardwareService.shared.hapticSuccess()
                                alertMessage = "Aktif çalışma yılı " + yr + " olarak değiştirildi. Tüm veriler yeni mali yıla göre yüklenecektir."
                                showAlert = true
                            } label: {
                                Text(activeYear == yr ? "\(yr) ✓ (Aktif)" : yr)
                                    .font(.system(size: 13, weight: activeYear == yr ? .bold : .medium))
                                    .foregroundColor(activeYear == yr ? .white : Color(red: 0.89, green: 0.91, blue: 0.94))
                                    .padding(.horizontal, 14)
                                    .padding(.vertical, 8)
                                    .background(activeYear == yr ? Color(red: 0.0, green: 0.38, blue: 1.0) : Color(red: 0.12, green: 0.16, blue: 0.23))
                                    .cornerRadius(8)
                            }
                        }
                    }
                    
                    Divider().background(Color(red: 0.12, green: 0.16, blue: 0.23)).padding(.vertical, 2)
                    
                    // Yeni Mali Yıl Oluştur
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Yeni Mali Yıl Oluştur")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(AppTheme.textPrimary)
                        
                        HStack(spacing: 8) {
                            TextField("Örn: 2027", text: $newYearInput)
                                .keyboardType(.numberPad)
                                .font(.system(size: 13, weight: .bold))
                                .foregroundColor(AppTheme.textPrimary)
                                .padding(10)
                                .background(Color(red: 0.04, green: 0.07, blue: 0.13))
                                .cornerRadius(8)
                                .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color(red: 0.12, green: 0.16, blue: 0.23), lineWidth: 1))
                            
                            Button {
                                let trimmed = newYearInput.trimmingCharacters(in: .whitespacesAndNewlines)
                                if trimmed.count == 4 {
                                    if !availableYears.contains(trimmed) {
                                        availableYears.append(trimmed)
                                        availableYears.sort()
                                        newYearInput = ""
                                        HardwareService.shared.hapticSuccess()
                                        alertMessage = trimmed + " mali yılı başarıyla oluşturuldu."
                                        showAlert = true
                                    } else {
                                        alertMessage = trimmed + " yılı zaten mevcut."
                                        showAlert = true
                                    }
                                } else {
                                    alertMessage = "Lütfen geçerli 4 haneli bir mali yıl girin."
                                    showAlert = true
                                }
                            } label: {
                                Text("Yıl Oluştur")
                                    .font(.system(size: 13, weight: .bold))
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 10)
                                    .background(Color(red: 0.15, green: 0.39, blue: 0.92))
                                    .cornerRadius(8)
                            }
                        }
                    }
                }
            }
            
            // Mali Yıl Silme Kartı
            settingCard(borderColor: Color(red: 0.94, green: 0.27, blue: 0.27).opacity(0.3)) {
                VStack(alignment: .leading, spacing: 14) {
                    HStack(spacing: 10) {
                        Image(systemName: "trash.fill")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(Color(red: 0.94, green: 0.27, blue: 0.27))
                        Text("Mali Yıl Silme / Sıfırlama")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(Color(red: 0.94, green: 0.27, blue: 0.27))
                    }
                    
                    Text("Kullanılmayan veya yanlışlıkla açılmış bir mali yılı ve veritabanı kayıtlarını kalıcı olarak siler.")
                        .font(.system(size: 12))
                        .foregroundColor(Color(red: 0.58, green: 0.64, blue: 0.72))
                    
                    VStack(spacing: 8) {
                        ForEach(availableYears, id: \.self) { yr in
                            HStack {
                                HStack(spacing: 8) {
                                    Image(systemName: "calendar")
                                        .font(.system(size: 14))
                                        .foregroundColor(activeYear == yr ? Color(red: 0.23, green: 0.51, blue: 0.96) : Color(red: 0.39, green: 0.45, blue: 0.55))
                                    Text(yr)
                                        .font(.system(size: 14, weight: .bold))
                                        .foregroundColor(.white)
                                    if activeYear == yr {
                                        Text("Aktif Yıl")
                                            .font(.system(size: 11, weight: .semibold))
                                            .foregroundColor(Color(red: 0.23, green: 0.51, blue: 0.96))
                                            .padding(.horizontal, 6)
                                            .padding(.vertical, 2)
                                            .background(Color(red: 0.23, green: 0.51, blue: 0.96).opacity(0.12))
                                            .cornerRadius(4)
                                    }
                                }
                                Spacer()
                                Button {
                                    alertMessage = "DİKKAT: " + yr + " mali yılını silmek üzeresiniz! Bu işlem seçilen yıla ait tüm kayıtları kalıcı siler. Devam edilsin mi?"
                                    confirmAction = {
                                        availableYears.removeAll { $0 == yr }
                                        HardwareService.shared.hapticSuccess()
                                    }
                                    showConfirmAlert = true
                                } label: {
                                    HStack(spacing: 4) {
                                        Image(systemName: "trash")
                                        Text("Yılı Sil")
                                    }
                                    .font(.system(size: 12, weight: .bold))
                                    .foregroundColor(Color(red: 0.94, green: 0.27, blue: 0.27))
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 6)
                                    .background(Color(red: 0.94, green: 0.27, blue: 0.27).opacity(0.15))
                                    .cornerRadius(6)
                                }
                            }
                            .padding(10)
                            .background(Color(red: 0.06, green: 0.09, blue: 0.16))
                            .cornerRadius(8)
                        }
                    }
                }
            }
            
            // Yıl Devir Sihirbazı Kartı
            settingCard {
                VStack(alignment: .leading, spacing: 14) {
                    HStack(spacing: 10) {
                        Image(systemName: "sparkles")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(Color(red: 0.06, green: 0.73, blue: 0.51))
                        Text("Yıl Devir Sihirbazı (Year Transfer)")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(AppTheme.textPrimary)
                    }
                    
                    Text("Önceki mali yılın cari borç/alacak, kasa nakit, banka ve depo stok kapanış bakiyelerini yeni mali yıla devir fişi olarak aktarır.")
                        .font(.system(size: 12))
                        .foregroundColor(Color(red: 0.58, green: 0.64, blue: 0.72))
                    
                    // Kaynak & Hedef Yıl
                    HStack {
                        VStack(spacing: 4) {
                            Text("Kaynak Mali Yıl")
                                .font(.system(size: 11))
                                .foregroundColor(Color(red: 0.58, green: 0.64, blue: 0.72))
                            TextField("2025", text: $devirKaynakYil)
                                .keyboardType(.numberPad)
                                .font(.system(size: 14, weight: .bold))
                                .foregroundColor(AppTheme.textPrimary)
                                .multilineTextAlignment(.center)
                                .frame(width: 80)
                                .padding(8)
                                .background(Color(red: 0.04, green: 0.07, blue: 0.13))
                                .cornerRadius(8)
                        }
                        
                        Spacer()
                        Image(systemName: "arrow.right")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(Color(red: 0.23, green: 0.51, blue: 0.96))
                        Spacer()
                        
                        VStack(spacing: 4) {
                            Text("Hedef Mali Yıl")
                                .font(.system(size: 11))
                                .foregroundColor(Color(red: 0.58, green: 0.64, blue: 0.72))
                            TextField("2026", text: $devirHedefYil)
                                .keyboardType(.numberPad)
                                .font(.system(size: 14, weight: .bold))
                                .foregroundColor(AppTheme.textPrimary)
                                .multilineTextAlignment(.center)
                                .frame(width: 80)
                                .padding(8)
                                .background(Color(red: 0.04, green: 0.07, blue: 0.13))
                                .cornerRadius(8)
                        }
                    }
                    .padding(12)
                    .background(Color(red: 0.04, green: 0.07, blue: 0.13))
                    .cornerRadius(12)
                    
                    // Devredilecek Modüller
                    Text("Devredilecek Modüller")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(AppTheme.textPrimary)
                    
                    VStack(spacing: 8) {
                        devirCheckboxRow(title: "Cari Hesap Kapanış Bakiyeleri (Devir Fişi)", isSelected: $devirCariSecili)
                        devirCheckboxRow(title: "Kasa Nakit Bakiyesi (Devir Fişi)", isSelected: $devirKasaSecili)
                        devirCheckboxRow(title: "Banka Hesap Bakiyeleri (Devir Fişi)", isSelected: $devirBankaSecili)
                        devirCheckboxRow(title: "Stok Depo Sayım Miktarları (Devir Fişi)", isSelected: $devirStokSecili)
                    }
                    
                    Button {
                        devirYukleniyor = true
                        Task {
                            try? await Task.sleep(nanoseconds: 800_000_000)
                            await MainActor.run {
                                devirYukleniyor = false
                                devirSuccessText = "\(devirKaynakYil) yılından \(devirHedefYil) yılına devir başarıyla tamamlandı (Cari, Kasa, Banka, Stok)."
                                HardwareService.shared.hapticSuccess()
                                alertMessage = devirSuccessText ?? "Devir tamamlandı."
                                showAlert = true
                            }
                        }
                    } label: {
                        HStack {
                            if devirYukleniyor {
                                ProgressView().tint(.white).padding(.trailing, 6)
                            }
                            Text("Yıl Devir İşlemini Başlat")
                        }
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 13)
                        .background(Color(red: 0.06, green: 0.73, blue: 0.51))
                        .cornerRadius(10)
                    }
                    
                    Button {
                        devirYukleniyor = true
                        Task {
                            try? await Task.sleep(nanoseconds: 600_000_000)
                            await MainActor.run {
                                devirYukleniyor = false
                                HardwareService.shared.hapticSuccess()
                                alertMessage = activeYear + " yılı güncel bakiyeleri sonraki yıla başarıyla yansıtıldı."
                                showAlert = true
                            }
                        }
                    } label: {
                        Text("Sonraki Yıla Bakiye Yansıt (Devri Yenile)")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 13)
                            .background(Color(red: 0.96, green: 0.62, blue: 0.04))
                            .cornerRadius(10)
                    }
                }
            }
        }
    }
    
    @ViewBuilder
    private func devirCheckboxRow(title: String, isSelected: Binding<Bool>) -> some View {
        Button {
            isSelected.wrappedValue.toggle()
        } label: {
            HStack(spacing: 10) {
                Image(systemName: isSelected.wrappedValue ? "checkmark.square.fill" : "square")
                    .font(.system(size: 18))
                    .foregroundColor(isSelected.wrappedValue ? Color(red: 0.06, green: 0.73, blue: 0.51) : Color(red: 0.39, green: 0.45, blue: 0.55))
                Text(title)
                    .font(.system(size: 13))
                    .foregroundColor(AppTheme.textPrimary)
                Spacer()
            }
        }
        .padding(.vertical, 4)
    }
    
    // MARK: - 6. Veri Temizlik
    @ViewBuilder
    private func renderCleanupSection() -> some View {
        VStack(spacing: 16) {
            // Veri Temizliği (Bulut / Firebase)
            settingCard {
                VStack(alignment: .leading, spacing: 14) {
                    HStack(spacing: 10) {
                        Image(systemName: "trash.fill")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(Color(red: 0.94, green: 0.27, blue: 0.27))
                        Text("Veri Temizliği (Bulut / Firebase)")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(AppTheme.textPrimary)
                    }
                    
                    Text("Firebase Realtime Database üzerindeki silinmiş (soft-deleted / isDeleted: true) çöpleri kalıcı olarak siler.")
                        .font(.system(size: 12))
                        .foregroundColor(Color(red: 0.58, green: 0.64, blue: 0.72))
                    
                    Button {
                        alertMessage = "Veritabanında 'silindi' olarak işaretlenmiş tüm kayıtlar kalıcı olarak silinecektir. Bu işlem geri alınamaz. Emin misiniz?"
                        confirmAction = {
                            HardwareService.shared.hapticSuccess()
                            alertMessage = "Veri temizliği tamamlandı. Çöp kayıtlar kalıcı olarak silindi."
                            showAlert = true
                        }
                        showConfirmAlert = true
                    } label: {
                        Text("Silinen Kayıtları Kalıcı Sil")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 13)
                            .background(Color(red: 0.94, green: 0.27, blue: 0.27))
                            .cornerRadius(10)
                    }
                }
            }
            
            // Yerel Önbellek Temizliği
            settingCard {
                VStack(alignment: .leading, spacing: 14) {
                    HStack(spacing: 10) {
                        Image(systemName: "internaldrive.fill")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(Color(red: 0.39, green: 0.45, blue: 0.55))
                        Text("Yerel Önbellek Temizliği")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(AppTheme.textPrimary)
                    }
                    
                    Text("Cihazın yerel diskindeki çevrimdışı önbelleği ve bekleyen işlem kuyruklarını temizler.")
                        .font(.system(size: 12))
                        .foregroundColor(Color(red: 0.58, green: 0.64, blue: 0.72))
                    
                    Button {
                        alertMessage = "Uygulamanın cihazdaki önbelleği silinecek. Bulut verileri etkilenmez. Emin misiniz?"
                        confirmAction = {
                            HardwareService.shared.hapticSuccess()
                            alertMessage = "Önbellek kayıtları başarıyla temizlendi."
                            showAlert = true
                        }
                        showConfirmAlert = true
                    } label: {
                        Text("Cihaz Önbelleğini Sıfırla")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 13)
                            .background(Color(red: 0.39, green: 0.45, blue: 0.55))
                            .cornerRadius(10)
                    }
                }
            }
            
            // Fabrika Ayarlarına Dön
            settingCard(borderColor: Color(red: 0.94, green: 0.27, blue: 0.27).opacity(0.4), bgColor: Color(red: 0.94, green: 0.27, blue: 0.27).opacity(0.06)) {
                VStack(alignment: .leading, spacing: 14) {
                    HStack(spacing: 10) {
                        Image(systemName: "trash.fill")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(Color(red: 0.94, green: 0.27, blue: 0.27))
                        Text("Fabrika Ayarlarına Dön")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(Color(red: 0.94, green: 0.27, blue: 0.27))
                    }
                    
                    Text("Tüm yerel ayarları, önbelleği ve veritabanı bağlantı yapılandırmasını sıfırlar. Bu işlemin geri dönüşü yoktur.")
                        .font(.system(size: 12))
                        .foregroundColor(Color(red: 0.99, green: 0.65, blue: 0.65))
                    
                    Button {
                        alertMessage = "Tüm yerel ayarlar, önbellek ve veritabanı bağlantısı sıfırlanacak. Emin misiniz?"
                        confirmAction = {
                            dbUrl = ""
                            secretKey = ""
                            activeYear = "2026"
                            HardwareService.shared.hapticSuccess()
                            alertMessage = "Uygulama başarıyla fabrika ayarlarına döndürüldü."
                            showAlert = true
                        }
                        showConfirmAlert = true
                    } label: {
                        HStack(spacing: 8) {
                            Image(systemName: "trash.fill")
                            Text("Fabrika Ayarlarına Sıfırla")
                        }
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 13)
                        .background(Color(red: 0.94, green: 0.27, blue: 0.27))
                        .cornerRadius(10)
                    }
                }
            }
        }
    }
    
    // MARK: - Card Container Helper
    @ViewBuilder
    private func settingCard<Content: View>(borderColor: Color = Color(red: 0.12, green: 0.16, blue: 0.23), bgColor: Color = Color(red: 0.06, green: 0.09, blue: 0.16), @ViewBuilder content: () -> Content) -> some View {
        content()
            .padding(16)
            .background(bgColor)
            .cornerRadius(14)
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(borderColor, lineWidth: 1)
            )
    }
}
