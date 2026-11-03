import SwiftUI

public struct SearchBarView: View {
    @Binding public var text: String
    public var placeholder: String
    
    public init(text: Binding<String>, placeholder: String = "Ara...") {
        self._text = text
        self.placeholder = placeholder
    }
    
    public var body: some View {
        HStack(spacing: 8) {
            Image(systemName: "magnifyingglass")
                .foregroundColor(AppTheme.textMuted)
            
            TextField(placeholder, text: $text)
                .font(.system(size: 14))
                .foregroundColor(AppTheme.textPrimary)
                .autocapitalization(.none)
                .disableAutocorrection(true)
            
            if !text.isEmpty {
                Button {
                    text = ""
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(AppTheme.textMuted)
                }
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(AppTheme.cardSecondary)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(AppTheme.border, lineWidth: 1)
                )
        )
    }
}

public struct FormField: View {
    public let label: String
    @Binding public var text: String
    public var placeholder: String
    
    public init(label: String, text: Binding<String>, placeholder: String = "") {
        self.label = label
        self._text = text
        self.placeholder = placeholder
    }
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(label)
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(AppTheme.textSecondary)
            
            TextField(placeholder, text: $text)
                .font(.system(size: 14))
                .foregroundColor(AppTheme.textPrimary)
                .padding(.horizontal, 14)
                .padding(.vertical, 12)
                .background(AppTheme.cardBackground)
                .cornerRadius(10)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(AppTheme.border, lineWidth: 1)
                )
        }
    }
}

public struct StatusBadge: View {
    public let title: String
    public let color: Color
    
    public init(title: String, color: Color) {
        self.title = title
        self.color = color
    }
    
    public var body: some View {
        Text(title)
            .font(.system(size: 11, weight: .semibold))
            .foregroundColor(color)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(color.opacity(0.15))
            .cornerRadius(6)
    }
}

public struct DetailInfoRow: View {
    public let label: String
    public let value: String
    
    public init(label: String, value: String) {
        self.label = label
        self.value = value
    }
    
    public var body: some View {
        HStack {
            Text(label)
                .font(.system(size: 13))
                .foregroundColor(AppTheme.textMuted)
            Spacer()
            Text(value)
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(AppTheme.textPrimary)
        }
        .padding(.vertical, 4)
    }
}

public struct ActionButton: View {
    public let title: String
    public let icon: String?
    public let color: Color
    public let action: @MainActor () -> Void
    
    public init(title: String, icon: String? = nil, color: Color = AppTheme.primary, action: @escaping @MainActor () -> Void) {
        self.title = title
        self.icon = icon
        self.color = color
        self.action = action
    }
    
    public var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                if let icon = icon {
                    Image(systemName: icon)
                        .font(.system(size: 14, weight: .bold))
                }
                Text(title)
                    .font(.system(size: 14, weight: .bold))
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(color)
            )
        }
    }
}
