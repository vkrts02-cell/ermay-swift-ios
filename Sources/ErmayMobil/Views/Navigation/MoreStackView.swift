import SwiftUI

struct MoreModuleItem: Identifiable {
    let id = UUID()
    let title: String
    let icon: String
    let color: Color
    let destination: AnyView
}

public struct MoreStackView: View {
    public init() {}
    
    private var menuItems: [MoreModuleItem] {
        [
            MoreModuleItem(title: "Faturalar", icon: "doc.text.fill", color: Color(hex: "30D158"), destination: AnyView(FaturalarView().enableSwipeBack())),
            MoreModuleItem(title: "Stoklar", icon: "shippingbox.fill", color: Color(hex: "0A84FF"), destination: AnyView(StoklarView().enableSwipeBack())),
            MoreModuleItem(title: "Müşteri Takip", icon: "folder.fill", color: Color(hex: "3B82F6"), destination: AnyView(MusteriTakipView().enableSwipeBack())),
            MoreModuleItem(title: "Finans", icon: "creditcard.fill", color: Color(hex: "FF416C"), destination: AnyView(FinansView().enableSwipeBack())),
            MoreModuleItem(title: "Vade Takibi", icon: "calendar", color: Color(hex: "8B5CF6"), destination: AnyView(VadeTakipView().enableSwipeBack())),
            MoreModuleItem(title: "Raporlar", icon: "chart.pie.fill", color: Color(hex: "0061FF"), destination: AnyView(RaporlarView().enableSwipeBack())),
            MoreModuleItem(title: "Görev Panosu", icon: "square.grid.2x2.fill", color: Color(hex: "00FF87"), destination: AnyView(KanbanView().enableSwipeBack())),
            MoreModuleItem(title: "Hesap Makinası", icon: "plus.forwardslash.minus", color: Color(hex: "0D9488"), destination: AnyView(MaliyetHesaplamaView().enableSwipeBack())),
            MoreModuleItem(title: "Araçlar", icon: "wrench.and.screwdriver.fill", color: Color(hex: "F59E0B"), destination: AnyView(AraclarView().enableSwipeBack())),
            MoreModuleItem(title: "Ayarlar", icon: "gearshape.fill", color: Color(hex: "94A3B8"), destination: AnyView(AyarlarView().enableSwipeBack()))
        ]
    }
    
    public var body: some View {
        NavigationStack {
            ZStack {
                AppTheme.background.ignoresSafeArea()
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        // Header
                        Text("Diğer Modüller")
                            .font(.system(size: 24, weight: .heavy))
                            .foregroundColor(AppTheme.textPrimary)
                            .padding(.horizontal, 20)
                            .padding(.top, 16)
                        
                        // Menü Kartı (Exact 10 Items from DahaFazlaScreen.tsx)
                        VStack(spacing: 0) {
                            ForEach(Array(menuItems.enumerated()), id: \.element.id) { index, item in
                                NavigationLink(destination: item.destination) {
                                    HStack(spacing: 14) {
                                        ZStack {
                                            RoundedRectangle(cornerRadius: 12)
                                                .fill(item.color.opacity(0.15))
                                                .frame(width: 38, height: 38)
                                            Image(systemName: item.icon)
                                                .font(.system(size: 18, weight: .semibold))
                                                .foregroundColor(item.color)
                                        }
                                        
                                        Text(item.title)
                                            .font(.system(size: 15, weight: .semibold))
                                            .foregroundColor(Color(hex: "E2E8F0"))
                                        
                                        Spacer()
                                        
                                        Image(systemName: "chevron.right")
                                            .font(.system(size: 14, weight: .semibold))
                                            .foregroundColor(Color(hex: "64748B"))
                                    }
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 13)
                                }
                                
                                if index < menuItems.count - 1 {
                                    Divider()
                                        .background(Color.white.opacity(0.06))
                                        .padding(.leading, 68)
                                }
                            }
                        }
                        .background(Color(hex: "121216"))
                        .cornerRadius(20)
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(Color.white.opacity(0.08), lineWidth: 1)
                        )
                        .padding(.horizontal, 16)
                        
                        Spacer().frame(height: 100)
                    }
                }
            }
            .navigationBarHidden(true)
        }
    }
}
