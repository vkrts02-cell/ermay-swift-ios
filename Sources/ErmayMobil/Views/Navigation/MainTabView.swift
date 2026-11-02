import SwiftUI

public struct MainTabView: View {
    @State private var selectedTab: MainTab = .dashboard
    
    public init() {}
    
    public var body: some View {
        ZStack(alignment: .bottom) {
            AppTheme.background.ignoresSafeArea()
            
            Group {
                switch selectedTab {
                case .dashboard:
                    DashboardView()
                case .cariler:
                    CarilerView()
                case .siparisler:
                    SiparislerView()
                case .teklifler:
                    TekliflerView()
                case .dahaFazla:
                    MoreStackView()
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            
            FloatingTabBar(selectedTab: $selectedTab)
        }
        .ignoresSafeArea(.keyboard)
    }
}

