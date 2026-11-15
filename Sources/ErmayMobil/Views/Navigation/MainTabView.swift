import SwiftUI

public struct MainTabView: View {
    @State private var selectedTab: MainTab = .dashboard
    @State private var visitedTabs: Set<MainTab> = [.dashboard]
    
    public init() {}
    
    public var body: some View {
        ZStack(alignment: .bottom) {
            AppTheme.background.ignoresSafeArea()
            
            ZStack {
                if visitedTabs.contains(.dashboard) {
                    DashboardView()
                        .opacity(selectedTab == .dashboard ? 1 : 0)
                        .allowsHitTesting(selectedTab == .dashboard)
                }
                if visitedTabs.contains(.cariler) {
                    CarilerView()
                        .opacity(selectedTab == .cariler ? 1 : 0)
                        .allowsHitTesting(selectedTab == .cariler)
                }
                if visitedTabs.contains(.siparisler) {
                    SiparislerView()
                        .opacity(selectedTab == .siparisler ? 1 : 0)
                        .allowsHitTesting(selectedTab == .siparisler)
                }
                if visitedTabs.contains(.teklifler) {
                    TekliflerView()
                        .opacity(selectedTab == .teklifler ? 1 : 0)
                        .allowsHitTesting(selectedTab == .teklifler)
                }
                if visitedTabs.contains(.dahaFazla) {
                    MoreStackView()
                        .opacity(selectedTab == .dahaFazla ? 1 : 0)
                        .allowsHitTesting(selectedTab == .dahaFazla)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            
            FloatingTabBar(selectedTab: $selectedTab)
        }
        .onChange(of: selectedTab) { newTab in
            visitedTabs.insert(newTab)
        }
        .ignoresSafeArea(.keyboard)
    }
}

