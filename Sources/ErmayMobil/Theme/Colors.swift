import SwiftUI

public struct AppTheme {
    // Brand Colors
    public static let primary = Color(hex: "0061FF")       // Ermay Electric Blue
    public static let primaryDark = Color(hex: "0040B0")
    public static let secondary = Color(hex: "60A5FA")
    
    // Backgrounds (Deep Dark / OLED)
    public static let background = Color(hex: "000000")
    public static let cardBackground = Color(hex: "121214")
    public static let cardSecondary = Color(hex: "1C1C1E")
    public static let surfaceElevated = Color(hex: "242426")
    public static let surfaceHighlight = Color(hex: "2C2C2E")
    
    // Accents & Financial Indicators
    public static let success = Color(hex: "10B981")       // Yeşil / Tahsilat / Kar
    public static let successMuted = Color(hex: "064E3B")
    public static let danger = Color(hex: "EF4444")        // Kırmızı / Ödeme / Borç
    public static let dangerMuted = Color(hex: "450A0A")
    public static let warning = Color(hex: "F59E0B")       // Amber / Bekleyen
    public static let info = Color(hex: "3B82F6")          // Mavi / Bilgi
    public static let purple = Color(hex: "8B5CF6")
    
    // Texts
    public static let textPrimary = Color(hex: "F8FAFC")
    public static let textSecondary = Color(hex: "94A3B8")
    public static let textMuted = Color(hex: "64748B")
    
    // Borders & Glass
    public static let border = Color.white.opacity(0.10)
    public static let borderLight = Color.white.opacity(0.18)
    public static let glassFill = Color(hex: "18181B").opacity(0.75)
}

extension Color {
    public init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

