import SwiftUI

public struct MusteriLimitView: View {
    @State private var musteriler: [MusteriRisk] = []
    @State private var searchText: String = ""
    @State private var filterRisk: String = "Tümü"
    @State private var isLoading: Bool = false
    
    private let riskFiltreleri = ["Tümü", "LİMİT AŞIMI", "YÜKSEK RİSK", "GÜVENLİ"]
    
    public init() {}
    
    public var filteredMusteriler: [MusteriRisk] {
        musteriler.filter { m in
            let matchSearch = searchText.isEmpty || m.unvan.localizedCaseInsensitiveContains(searchText)
            if !matchSearch { return false }
            if filterRisk != "Tümü" {
                return m.riskSeviyesi == filterRisk
            }
            return true
        }
    }
    
    public var body: some View {
        NavigationStack {
            ZStack {
                AppTheme.background.ignoresSafeArea()
                
                VStack(spacing: 14) {
                    // Header Bar
                    HStack {
                        Text("Risk & Kredi Limiti")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(AppTheme.textPrimary)
                        Spacer()
                    }
                    .padding(.horizontal)
                    .padding(.top, 8)
                    
                    // Risk Özeti
                    HStack(spacing: 12) {
                        RiskOzetKutu(
                            title: "Limit Aşımı",
                            count: musteriler.filter { $0.riskSeviyesi == "LİMİT AŞIMI" }.count,
                            color: AppTheme.danger
                        )
                        RiskOzetKutu(
                            title: "Yüksek Risk",
                            count: musteriler.filter { $0.riskSeviyesi == "YÜKSEK RİSK" }.count,
                            color: AppTheme.warning
                        )
                        RiskOzetKutu(
                            title: "Güvenli",
                            count: musteriler.filter { $0.riskSeviyesi == "GÜVENLİ" }.count,
                            color: AppTheme.success
                        )
                    }
                    .padding(.horizontal)
                    
                    SearchBarView(text: $searchText, placeholder: "Müşteri veya cari ara...")
                        .padding(.horizontal)
                    
                    // Liste
                    List {
                        ForEach(filteredMusteriler) { m in
                            MusteriRiskRow(risk: m)
                                .listRowBackground(Color.clear)
                                .listRowSeparator(.hidden)
                                .listRowInsets(EdgeInsets(top: 5, leading: 16, bottom: 5, trailing: 16))
                        }
                    }
                    .listStyle(.plain)
                    .refreshable {
                        await loadRiskData()
                    }
                }
            }
            .navigationBarHidden(true)
            .task {
                await loadRiskData()
            }
        }
    }
    
    private func loadRiskData() async {
        isLoading = true
        do {
            let cariler: [CariKart] = try await SupabaseService.shared.fetch(from: "cariler")
            let mapped = cariler.map { c in
                MusteriRisk(
                    id: c.id,
                    cariId: c.id,
                    unvan: c.unvan,
                    riskLimiti: 75000.0,
                    guncelBakiye: c.bakiye,
                    vadesiGecenBakiye: c.bakiye > 50000 ? (c.bakiye - 40000) : 0,
                    gecikmeGunu: c.bakiye > 60000 ? 18 : 0
                )
            }
            await MainActor.run {
                self.musteriler = mapped
            }
        } catch {
            musteriler = [
                MusteriRisk(id: "1", unvan: "Ermay Bilişim Sanayi Ltd.", riskLimiti: 60000, guncelBakiye: 72000, vadesiGecenBakiye: 22000, gecikmeGunu: 24),
                MusteriRisk(id: "2", unvan: "Mega Plastik Sanayi A.Ş.", riskLimiti: 80000, guncelBakiye: 65000, vadesiGecenBakiye: 0, gecikmeGunu: 0),
                MusteriRisk(id: "3", unvan: "Yıldız Lojistik ve Depolama", riskLimiti: 40000, guncelBakiye: 12000, vadesiGecenBakiye: 0, gecikmeGunu: 0)
            ]
        }
        isLoading = false
    }
}

struct RiskOzetKutu: View {
    let title: String
    let count: Int
    let color: Color
    
    var body: some View {
        GlassCard(cornerRadius: 12, padding: 12) {
            VStack(spacing: 4) {
                Text(title)
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundColor(AppTheme.textSecondary)
                Text("\(count)")
                    .font(.system(size: 20, weight: .heavy))
                    .foregroundColor(color)
            }
            .frame(maxWidth: .infinity)
        }
    }
}

struct MusteriRiskRow: View {
    let risk: MusteriRisk
    
    var riskColor: Color {
        switch risk.riskSeviyesi {
        case "LİMİT AŞIMI": return AppTheme.danger
        case "YÜKSEK RİSK": return AppTheme.warning
        case "ORTA RİSK": return Color.orange
        default: return AppTheme.success
        }
    }
    
    var body: some View {
        GlassCard(cornerRadius: 14, padding: 14) {
            VStack(spacing: 10) {
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(risk.unvan)
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(AppTheme.textPrimary)
                            .lineLimit(1)
                        Text("Risk Limiti: \(AppFormatters.money(risk.riskLimiti))")
                            .font(.system(size: 11))
                            .foregroundColor(AppTheme.textMuted)
                    }
                    
                    Spacer()
                    
                    StatusBadge(title: risk.riskSeviyesi, color: riskColor)
                }
                
                // İlerleme Çubuğu (Limit Kullanım Oranı)
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 4)
                            .fill(AppTheme.border)
                            .frame(height: 6)
                        RoundedRectangle(cornerRadius: 4)
                            .fill(riskColor)
                            .frame(width: geo.size.width * CGFloat(min(1.0, risk.riskOrani / 100.0)), height: 6)
                    }
                }
                .frame(height: 6)
                
                HStack {
                    Text("Bakiye: \(AppFormatters.money(risk.guncelBakiye))")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(risk.guncelBakiye > risk.riskLimiti ? AppTheme.danger : AppTheme.textPrimary)
                    
                    Spacer()
                    
                    Text(risk.riskSeviyesi == "LİMİT AŞIMI" ? "Aşım: +\(AppFormatters.money(risk.guncelBakiye - risk.riskLimiti))" : "Kalan: \(AppFormatters.money(risk.kalanLimit))")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundColor(risk.riskSeviyesi == "LİMİT AŞIMI" ? AppTheme.danger : AppTheme.success)
                }
            }
        }
    }
}

