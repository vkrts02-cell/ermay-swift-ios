import SwiftUI

public enum MainTab: Int, CaseIterable {
    case dashboard = 0
    case cariler = 1
    case siparisler = 2
    case teklifler = 3
    case dahaFazla = 4
    
    public var title: String {
        switch self {
        case .dashboard: return "Ana Sayfa"
        case .cariler: return "Cariler"
        case .siparisler: return "Siparişler"
        case .teklifler: return "Teklifler"
        case .dahaFazla: return "Daha Fazla"
        }
    }
    
    public var icon: String {
        switch self {
        case .dashboard: return "square.grid.2x2.fill"
        case .cariler: return "person.2.fill"
        case .siparisler: return "bag.fill"
        case .teklifler: return "doc.text.fill"
        case .dahaFazla: return "ellipsis.circle.fill"
        }
    }
}

public struct FloatingTabBar: View {
    @Binding public var selectedTab: MainTab
    
    public init(selectedTab: Binding<MainTab>) {
        self._selectedTab = selectedTab
    }
    
    public var body: some View {
        HStack(spacing: 0) {
            ForEach(MainTab.allCases, id: \.self) { tab in
                let isSelected = selectedTab == tab
                Button {
                    #if canImport(UIKit)
                    UIImpactFeedbackGenerator(style: .light).impactOccurred()
                    #endif
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        selectedTab = tab
                    }
                } label: {
                    VStack(spacing: 4) {
                        Image(systemName: tab.icon)
                            .font(.system(size: isSelected ? 20 : 18, weight: isSelected ? .bold : .regular))
                            .foregroundColor(isSelected ? AppTheme.primary : AppTheme.textMuted)
                        
                        Text(tab.title)
                            .font(.system(size: 10, weight: isSelected ? .semibold : .medium))
                            .foregroundColor(isSelected ? AppTheme.textPrimary : AppTheme.textMuted)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
                }
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 4)
        .background(
            Capsule()
                .fill(Color(hex: "18181B").opacity(0.92))
                .overlay(
                    Capsule()
                        .stroke(AppTheme.borderLight, lineWidth: 1)
                )
                .shadow(color: Color.black.opacity(0.4), radius: 12, x: 0, y: 6)
        )
        .padding(.horizontal, 16)
        .padding(.bottom, 8)
    }
}

