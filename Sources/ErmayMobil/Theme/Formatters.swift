import Foundation

public struct AppFormatters {
    public static let currency: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencySymbol = "₺"
        formatter.locale = Locale(identifier: "tr_TR")
        formatter.maximumFractionDigits = 2
        formatter.minimumFractionDigits = 2
        return formatter
    }()
    
    public static func money(_ value: Double?) -> String {
        guard let val = value else { return "₺0,00" }
        return currency.string(from: NSNumber(value: val)) ?? String(format: "₺%.2f", val)
    }
    
    public static let shortDate: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "tr_TR")
        formatter.dateFormat = "dd.MM.yyyy"
        return formatter
    }()
    
    public static let isoDate: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()
    
    public static func formatDate(_ date: Date?) -> String {
        guard let d = date else { return "-" }
        return shortDate.string(from: d)
    }
    
    public static func parseDate(_ string: String?) -> Date? {
        guard let str = string, !str.isEmpty else { return nil }
        if let d = shortDate.date(from: str) { return d }
        if let d = isoDate.date(from: str) { return d }
        
        let isoFormatter = ISO8601DateFormatter()
        isoFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        if let d = isoFormatter.date(from: str) { return d }
        
        let standardIso = ISO8601DateFormatter()
        return standardIso.date(from: str)
    }
}

