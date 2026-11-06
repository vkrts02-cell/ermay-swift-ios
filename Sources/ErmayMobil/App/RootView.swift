import SwiftUI

public struct RootView: View {
    @ObservedObject var authService = AuthService.shared
    @ObservedObject var lockService = BiometricLockService.shared
    
    public init() {}
    
    public var body: some View {
        Group {
            if !authService.isAuthenticated {
                LoginView()
            } else if lockService.isLocked {
                LockView()
            } else {
                MainTabView()
            }
        }
        .preferredColorScheme(.dark)
        .onAppear {
            SupabaseService.shared.startRealtimeListener()
        }
    }
}

