import SwiftUI

public struct LoginView: View {
    @ObservedObject var authService = AuthService.shared
    @State private var username: String = "admin"
    @State private var pass: String = "admin"
    @State private var tenantId: String = "tenant_ermay_master"
    @State private var showTenantField: Bool = false
    
    public init() {}
    
    public var body: some View {
        ZStack {
            AppTheme.background.ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 28) {
                    Spacer().frame(height: 40)
                    
                    // Logo & App Name
                    VStack(spacing: 12) {
                        ZStack {
                            Circle()
                                .fill(LinearGradient(
                                    colors: [AppTheme.primary, AppTheme.primaryDark],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ))
                                .frame(width: 80, height: 80)
                                .shadow(color: AppTheme.primary.opacity(0.4), radius: 16, x: 0, y: 8)
                            
                            Image(systemName: "chart.line.uptrend.xyaxis")
                                .font(.system(size: 36, weight: .bold))
                                .foregroundColor(.white)
                        }
                        
                        Text("ERMAY MUHASEBE")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(AppTheme.textPrimary)
                        
                        Text("Bulut Tabanlı Mobil ERP & Muhasebe")
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(AppTheme.textSecondary)
                    }
                    
                    // Form Card
                    GlassCard(cornerRadius: 20, padding: 24) {
                        VStack(spacing: 18) {
                            Text("Giriş Yap")
                                .font(.system(size: 18, weight: .bold))
                                .foregroundColor(AppTheme.textPrimary)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            
                            if let error = authService.errorMessage {
                                Text(error)
                                    .font(.system(size: 12, weight: .semibold))
                                    .foregroundColor(AppTheme.danger)
                                    .padding(10)
                                    .frame(maxWidth: .infinity)
                                    .background(AppTheme.dangerMuted.opacity(0.4))
                                    .cornerRadius(8)
                            }
                            
                            // Kullanıcı Adı
                            VStack(alignment: .leading, spacing: 6) {
                                Text("Kullanıcı Adı")
                                    .font(.system(size: 12, weight: .semibold))
                                    .foregroundColor(AppTheme.textSecondary)
                                
                                HStack {
                                    Image(systemName: "person.fill")
                                        .foregroundColor(AppTheme.textMuted)
                                    TextField("Kullanıcı Adı", text: $username)
                                        .font(.system(size: 14))
                                        .foregroundColor(AppTheme.textPrimary)
                                        .autocapitalization(.none)
                                }
                                .padding(12)
                                .background(AppTheme.cardSecondary)
                                .cornerRadius(10)
                            }
                            
                            // Şifre
                            VStack(alignment: .leading, spacing: 6) {
                                Text("Şifre")
                                    .font(.system(size: 12, weight: .semibold))
                                    .foregroundColor(AppTheme.textSecondary)
                                
                                HStack {
                                    Image(systemName: "lock.fill")
                                        .foregroundColor(AppTheme.textMuted)
                                    SecureField("Şifre", text: $pass)
                                        .font(.system(size: 14))
                                        .foregroundColor(AppTheme.textPrimary)
                                }
                                .padding(12)
                                .background(AppTheme.cardSecondary)
                                .cornerRadius(10)
                            }
                            
                            // Şirket Kodu (Tenant) Toggle
                            Button {
                                withAnimation {
                                    showTenantField.toggle()
                                }
                            } label: {
                                HStack {
                                    Text(showTenantField ? "Şirket Kodunu Gizle" : "Gelişmiş: Şirket Kodu Belirt")
                                        .font(.system(size: 12, weight: .medium))
                                        .foregroundColor(AppTheme.secondary)
                                    Image(systemName: showTenantField ? "chevron.up" : "chevron.down")
                                        .font(.system(size: 10))
                                        .foregroundColor(AppTheme.secondary)
                                }
                            }
                            
                            if showTenantField {
                                VStack(alignment: .leading, spacing: 6) {
                                    Text("Şirket / Tenant ID")
                                        .font(.system(size: 12, weight: .semibold))
                                        .foregroundColor(AppTheme.textSecondary)
                                    
                                    HStack {
                                        Image(systemName: "building.2.fill")
                                            .foregroundColor(AppTheme.textMuted)
                                        TextField("tenant_...", text: $tenantId)
                                            .font(.system(size: 14))
                                            .foregroundColor(AppTheme.textPrimary)
                                            .autocapitalization(.none)
                                    }
                                    .padding(12)
                                    .background(AppTheme.cardSecondary)
                                    .cornerRadius(10)
                                }
                            }
                            
                            // Giriş Butonu
                            ActionButton(
                                title: authService.isLoading ? "Giriş Yapılıyor..." : "Giriş Yap",
                                icon: "arrow.right.circle.fill",
                                color: AppTheme.primary
                            ) {
                                Task {
                                    _ = await authService.login(username: username, pass: pass, tenantId: tenantId)
                                }
                            }
                            .disabled(authService.isLoading)
                        }
                    }
                    .padding(.horizontal, 20)
                    
                    Spacer()
                }
            }
        }
    }
}

