import SwiftUI

public struct LockView: View {
    @ObservedObject var lockService = BiometricLockService.shared
    @State private var pinInput: String = ""
    @State private var errorText: String? = nil
    
    public init() {}
    
    public var body: some View {
        ZStack {
            AppTheme.background.ignoresSafeArea()
            
            VStack(spacing: 32) {
                Spacer()
                
                // Icon
                ZStack {
                    Circle()
                        .fill(AppTheme.primary.opacity(0.15))
                        .frame(width: 84, height: 84)
                    
                    Image(systemName: "lock.shield.fill")
                        .font(.system(size: 40))
                        .foregroundColor(AppTheme.primary)
                }
                
                VStack(spacing: 8) {
                    Text("Uygulama Kilitli")
                        .font(.system(size: 22, weight: .bold))
                        .foregroundColor(AppTheme.textPrimary)
                    
                    Text("Devam etmek için PIN kodunuzu girin")
                        .font(.system(size: 13))
                        .foregroundColor(AppTheme.textSecondary)
                }
                
                // PIN Noktaları (Dots)
                HStack(spacing: 16) {
                    ForEach(0..<4, id: \.self) { index in
                        Circle()
                            .fill(index < pinInput.count ? AppTheme.primary : AppTheme.cardSecondary)
                            .overlay(Circle().stroke(AppTheme.border, lineWidth: 1))
                            .frame(width: 18, height: 18)
                    }
                }
                .padding(.vertical, 8)
                
                if let err = errorText {
                    Text(err)
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(AppTheme.danger)
                }
                
                // Numpad
                VStack(spacing: 16) {
                    let rows = [
                        ["1", "2", "3"],
                        ["4", "5", "6"],
                        ["7", "8", "9"],
                        ["faceid", "0", "delete"]
                    ]
                    
                    ForEach(rows, id: \.self) { row in
                        HStack(spacing: 24) {
                            ForEach(row, id: \.self) { key in
                                Button {
                                    handleKey(key)
                                } label: {
                                    ZStack {
                                        Circle()
                                            .fill(AppTheme.cardBackground)
                                            .overlay(Circle().stroke(AppTheme.border, lineWidth: 1))
                                            .frame(width: 70, height: 70)
                                        
                                        if key == "delete" {
                                            Image(systemName: "delete.left.fill")
                                                .font(.system(size: 20))
                                                .foregroundColor(AppTheme.textPrimary)
                                        } else if key == "faceid" {
                                            Image(systemName: "faceid")
                                                .font(.system(size: 24))
                                                .foregroundColor(AppTheme.primary)
                                        } else {
                                            Text(key)
                                                .font(.system(size: 24, weight: .semibold))
                                                .foregroundColor(AppTheme.textPrimary)
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
                
                Spacer()
            }
            .padding()
        }
        .onAppear {
            if lockService.isBiometricsEnabled {
                Task {
                    _ = await lockService.authenticateBiometrics()
                }
            }
        }
    }
    
    private func handleKey(_ key: String) {
        if key == "delete" {
            if !pinInput.isEmpty {
                pinInput.removeLast()
                errorText = nil
            }
        } else if key == "faceid" {
            Task {
                _ = await lockService.authenticateBiometrics()
            }
        } else {
            if pinInput.count < 4 {
                pinInput.append(key)
                if pinInput.count == 4 {
                    if lockService.verifyPin(pinInput) {
                        // Kilit açıldı
                    } else {
                        errorText = "Hatalı PIN kodu!"
                        pinInput = ""
                    }
                }
            }
        }
    }
}

