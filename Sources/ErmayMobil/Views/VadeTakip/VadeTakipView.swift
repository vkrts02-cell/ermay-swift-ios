import SwiftUI

public struct VadeTakipView: View {
    @State private var vadeListesi: [VadeItem] = [
        VadeItem(cariUnvan: "Ermay Ltd. Şti.", faturaNo: "FTR-2026-0012", vadeTarihi: "25.10.2026", tutar: 24500, kalanTutar: 24500, tip: "ALACAK", gecikmeGun: 8),
        VadeItem(cariUnvan: "Akıncılar Çelik Döküm", faturaNo: "FTR-2026-0008", vadeTarihi: "28.10.2026", tutar: 18000, kalanTutar: 18000, tip: "BORC", gecikmeGun: 5),
        VadeItem(cariUnvan: "Mega Plastik San.", faturaNo: "FTR-2026-0015", vadeTarihi: "05.11.2026", tutar: 12000, kalanTutar: 12000, tip: "ALACAK", gecikmeGun: 0),
        VadeItem(cariUnvan: "Yıldız Lojistik", faturaNo: "FTR-2026-0019", vadeTarihi: "15.11.2026", tutar: 6500, kalanTutar: 6500, tip: "BORC", gecikmeGun: 0)
    ]
    @State private var selectedFilter: String = "Tümü"
    
    private let filters = ["Tümü", "Gecikenler", "Alacaklar", "Borçlar"]
    
    public init() {}
    
    public var filteredList: [VadeItem] {
        vadeListesi.filter { item in
            switch selectedFilter {
            case "Gecikenler":
                return item.gecikmeGun > 0
            case "Alacaklar":
                return item.tip == "ALACAK"
            case "Borçlar":
                return item.tip == "BORC"
            default:
                return true
            }
        }
    }
    
    public var body: some View {
        NavigationStack {
            ZStack {
                AppTheme.background.ignoresSafeArea()
                
                VStack(spacing: 14) {
                    // Filter Chips
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            ForEach(filters, id: \.self) { filter in
                                let isSelected = selectedFilter == filter
                                Button {
                                    selectedFilter = filter
                                } label: {
                                    Text(filter)
                                        .font(.system(size: 13, weight: isSelected ? .bold : .medium))
                                        .foregroundColor(isSelected ? .white : AppTheme.textSecondary)
                                        .padding(.horizontal, 14)
                                        .padding(.vertical, 8)
                                        .background(
                                            RoundedRectangle(cornerRadius: 10)
                                                .fill(isSelected ? AppTheme.primary : AppTheme.cardBackground)
                                                .overlay(
                                                    RoundedRectangle(cornerRadius: 10)
                                                        .stroke(isSelected ? AppTheme.primary : AppTheme.border, lineWidth: 1)
                                                )
                                        )
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                    .padding(.top, 8)
                    
                    List {
                        ForEach(filteredList) { item in
                            let isGecikmis = item.gecikmeGun > 0
                            let isAlacak = item.tip == "ALACAK"
                            
                            GlassCard(cornerRadius: 14, padding: 14) {
                                VStack(spacing: 8) {
                                    HStack {
                                        StatusBadge(
                                            title: isAlacak ? "TAHSİL EDİLECEK (ALACAK)" : "ÖDENECEK (BORÇ)",
                                            color: isAlacak ? AppTheme.success : AppTheme.danger
                                        )
                                        
                                        Spacer()
                                        
                                        if isGecikmis {
                                            StatusBadge(
                                                title: "\(item.gecikmeGun) GÜN GECİKTİ",
                                                color: AppTheme.danger
                                            )
                                        } else {
                                            StatusBadge(
                                                title: "VADESİ GELMEDİ",
                                                color: AppTheme.info
                                            )
                                        }
                                    }
                                    
                                    HStack(alignment: .bottom) {
                                        VStack(alignment: .leading, spacing: 3) {
                                            Text(item.cariUnvan)
                                                .font(.system(size: 14, weight: .bold))
                                                .foregroundColor(AppTheme.textPrimary)
                                            Text("Vade: \(item.vadeTarihi) • \(item.faturaNo ?? "")")
                                                .font(.system(size: 11))
                                                .foregroundColor(AppTheme.textMuted)
                                        }
                                        Spacer()
                                        Text(AppFormatters.money(item.kalanTutar))
                                            .font(.system(size: 16, weight: .heavy))
                                            .foregroundColor(isAlacak ? AppTheme.success : AppTheme.danger)
                                    }
                                }
                            }
                            .listRowBackground(Color.clear)
                            .listRowSeparator(.hidden)
                            .listRowInsets(EdgeInsets(top: 4, leading: 16, bottom: 4, trailing: 16))
                        }
                    }
                    .listStyle(.plain)
                    
                    Spacer().frame(height: 70)
                }
            }
            .navigationTitle("Vade & Tahsilat Takibi")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

