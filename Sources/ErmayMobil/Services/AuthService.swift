import Foundation
import SwiftUI

@MainActor
public final class AuthService: ObservableObject {
    public static let shared = AuthService()
    
    @Published public var currentUser: User? = nil
    @Published public var isAuthenticated: Bool = false
    @Published public var isLoading: Bool = false
    @Published public var errorMessage: String? = nil
    
    private let userDefaultsKey = "ermay_saved_user"
    
    private init() {
        checkSavedSession()
    }
    
    public func checkSavedSession() {
        if let data = UserDefaults.standard.data(forKey: userDefaultsKey),
           let user = try? JSONDecoder().decode(User.self, from: data) {
            self.currentUser = user
            self.isAuthenticated = true
            SupabaseService.shared.tenantId = user.tenantId
        }
    }
    
    public func login(username: String, pass: String, tenantId: String) async -> Bool {
        isLoading = true
        errorMessage = nil
        
        // Simüle veya doğrudan Supabase tenant doğrulaması
        do {
            // Basit temizlik
            let cleanUsername = username.trimmingCharacters(in: .whitespacesAndNewlines)
            let cleanTenant = tenantId.trimmingCharacters(in: .whitespacesAndNewlines)
            
            guard !cleanUsername.isEmpty else {
                errorMessage = "Kullanıcı adı boş bırakılamaz"
                isLoading = false
                return false
            }
            
            let tenant = cleanTenant.isEmpty ? "tenant_vkrts1992_gmail_com" : cleanTenant
            SupabaseService.shared.tenantId = tenant
            
            let user = User(
                id: UUID().uuidString,
                email: "\(cleanUsername)@ermay.local",
                username: cleanUsername,
                fullName: cleanUsername.capitalized,
                role: "Admin",
                tenantId: tenant
            )
            
            if let encoded = try? JSONEncoder().encode(user) {
                UserDefaults.standard.set(encoded, forKey: userDefaultsKey)
            }
            
            self.currentUser = user
            self.isAuthenticated = true
            self.isLoading = false
            return true
        }
    }
    
    public func logout() {
        UserDefaults.standard.removeObject(forKey: userDefaultsKey)
        self.currentUser = nil
        self.isAuthenticated = false
    }
}

