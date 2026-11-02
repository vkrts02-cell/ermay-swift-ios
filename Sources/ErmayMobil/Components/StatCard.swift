import SwiftUI

public struct StatCard: View {
    public let title: String
    public let value: String
    public let subtitle: String?
    public let icon: String
    public let accentColor: Color
    public let isIncrease: Bool?
    
    public init(
        title: String,
        value: String,
        subtitle: String? = nil,
        icon: String,
        accentColor: Color = AppTheme.primary,
        isIncrease: Bool? = nil
    ) {
        self.title = title
        self.value = value
        self.subtitle = subtitle
        self.icon = icon
        self.accentColor = accentColor
        self.isIncrease = isIncrease
    }
    
    public var body: some View {
        GlassCard(padding: 14) {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    ZStack {
                        Circle()
                            .fill(accentColor.opacity(0.15))
                            .frame(width: 34, height: 34)
                        Image(systemName: icon)
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(accentColor)
                    }
                    
                    Spacer()
                    
                    if let inc = isIncrease {
                        HStack(spacing: 2) {
                            Image(systemName: inc ? "arrow.up.right" : "arrow.down.right")
                            Text(inc ? "+%" : "-%")
                        }
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(inc ? AppTheme.success : AppTheme.danger)
                    }
                }
                
                Text(title)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(AppTheme.textSecondary)
                
                Text(value)
                    .font(.system(size: 17, weight: .bold))
                    .foregroundColor(AppTheme.textPrimary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
                
                if let sub = subtitle {
                    Text(sub)
                        .font(.system(size: 10, weight: .regular))
                        .foregroundColor(AppTheme.textMuted)
                }
            }
        }
    }
}

