import SwiftUI

public struct CariYaslandirmaDilim: Identifiable {
    public let id = UUID()
    public let title: String
    public let rangeText: String
    public let amount: Double
    public let ratio: Double
    public let color: Color
    public let invoiceCount: Int
}

public struct CariYaslandirmaModalView: View {
    public let cari: CariKart
    @Environment(\.dismiss) private var dismiss
    @State private var dilimler: [CariYaslandirmaDilim] = []
    @State private var isLoading: Bool = true
    
    public init(cari: CariKart) {
        self.cari = cari
    }
    
    private var totalRisk: Double {
        dilimler.reduce(0.0) { $0 + $1.amount }
    }
    
    public var body: some View {
        NavigationStack {
            ZStack {
                AppTheme.background.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 16) {
                        GlassCard(cornerRadius: 18, padding: 18) {
                            VStack(spacing: 8) {
                                Text(cari.unvan)
                                    .font(.system(size: 16, weight: .bold))
                                    .foregroundColor(AppTheme.textPrimary)
                                    .multilineTextAlignment(.center)
                                
                                Text("TOPLAM RİSK / AÇIK BAKİYE")
                                    .font(.system(size: 10, weight: .bold))
                                    .foregroundColor(AppTheme.textMuted)
                                
                                Text(AppFormatters.money(max(0, cari.bakiye > 0 ? cari.bakiye : totalRisk)))
                                    .font(.system(size: 26, weight: .heavy))
                                    .foregroundColor(AppTheme.danger)
                            }
                            .frame(maxWidth: .infinity)
                        }
                        .padding(.horizontal)
                        
                        // Stacked Bar Chart
                        GlassCard(cornerRadius: 16, padding: 16) {
                            VStack(alignment: .leading, spacing: 12) {
                                Text("Vade Yaşlandırma Dağılımı")
                                    .font(.system(size: 14, weight: .bold))
                                    .foregroundColor(AppTheme.textPrimary)
                                
                                GeometryReader { geo in
                                    HStack(spacing: 3) {
                                        ForEach(dilimler) { d in
                                            RoundedRectangle(cornerRadius: 4)
                                                .fill(d.color)
                                                .frame(width: max(8, (geo.size.width - 9) * CGFloat(max(0.05, d.ratio))), height: 18)
                                        }
                                    }
                                }
                                .frame(height: 18)
                                
                                HStack(spacing: 12) {
                                    ForEach(dilimler) { d in
                                        HStack(spacing: 4) {
                                            Circle()
                                                .fill(d.color)
                                                .frame(width: 8, height: 8)
                                            Text(d.rangeText)
                                                .font(.system(size: 10))
                                                .foregroundColor(AppTheme.textSecondary)
                                        }
                                    }
                                }
                            }
                        }
                        .padding(.horizontal)
                        
                        // Dilim Detay Kartları
                        VStack(spacing: 10) {
                            ForEach(dilimler) { d in
                                GlassCard(cornerRadius: 14, padding: 14) {
                                    HStack {
                                        VStack(alignment: .leading, spacing: 4) {
                                            HStack(spacing: 6) {
                                                Circle()
                                                    .fill(d.color)
                                                    .frame(width: 10, height: 10)
                                                Text(d.title)
                                                    .font(.system(size: 14, weight: .bold))
                                                    .foregroundColor(AppTheme.textPrimary)
                                            }
                                            Text("\(d.rangeText) • \(d.invoiceCount) Evrak/Hareket")
                                                .font(.system(size: 11))
                                                .foregroundColor(AppTheme.textMuted)
                                        }
                                        
                                        Spacer()
                                        
                                        VStack(alignment: .trailing, spacing: 2) {
                                            Text(AppFormatters.money(d.amount))
                                                .font(.system(size: 15, weight: .heavy))
                                                .foregroundColor(d.color)
                                            Text("%\(Int(d.ratio * 100))")
                                                .font(.system(size: 11, weight: .bold))
                                                .foregroundColor(AppTheme.textSecondary)
                                        }
                                    }
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                    .padding(.vertical, 12)
                }
            }
            .navigationTitle("Cari Yaşlandırma Analizi")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Kapat") { dismiss() }
                        .foregroundColor(AppTheme.textSecondary)
                }
            }
            .task {
                await calculateLiveAging()
            }
        }
    }
    
    private func calculateLiveAging() async {
        let tumHareketler: [CariHareket] = (try? await SupabaseService.shared.fetch(from: "cari_hareketler")) ?? []
        let cariH = tumHareketler.filter { $0.cariId == cari.id || $0.cariUnvan == cari.unvan }
        let today = Calendar.current.startOfDay(for: Date())
        
        var b0 = 0.0, b31 = 0.0, b61 = 0.0, b90 = 0.0
        var c0 = 0, c31 = 0, c61 = 0, c90 = 0
        
        for h in cariH where (h.borc - h.alacak) > 0 {
            let net = h.borc - h.alacak
            if let dStr = h.tarih, let d = AppFormatters.parseDate(String(dStr.prefix(10))) ?? AppFormatters.parseDate(dStr) {
                let days = max(0, Calendar.current.dateComponents([.day], from: Calendar.current.startOfDay(for: d), to: today).day ?? 0)
                if days <= 30 { b0 += net; c0 += 1 }
                else if days <= 60 { b31 += net; c31 += 1 }
                else if days <= 90 { b61 += net; c61 += 1 }
                else { b90 += net; c90 += 1 }
            } else {
                b0 += net; c0 += 1
            }
        }
        
        if (b0 + b31 + b61 + b90) == 0 && cari.bakiye > 0 {
            b0 = cari.bakiye
            c0 = 1
        }
        
        let tot = max(1.0, b0 + b31 + b61 + b90)
        let computed: [CariYaslandirmaDilim] = [
            CariYaslandirmaDilim(title: "Vadesi Gelmemiş / Güncel", rangeText: "0 - 30 Gün", amount: b0, ratio: b0 / tot, color: AppTheme.success, invoiceCount: c0),
            CariYaslandirmaDilim(title: "Erken Gecikme", rangeText: "31 - 60 Gün", amount: b31, ratio: b31 / tot, color: AppTheme.warning, invoiceCount: c31),
            CariYaslandirmaDilim(title: "Orta Vadeli Gecikme", rangeText: "61 - 90 Gün", amount: b61, ratio: b61 / tot, color: Color(hex: "F97316"), invoiceCount: c61),
            CariYaslandirmaDilim(title: "Kritik Gecikme (Tahsilat Riski)", rangeText: "90+ Gün", amount: b90, ratio: b90 / tot, color: AppTheme.danger, invoiceCount: c90)
        ]
        
        await MainActor.run {
            self.dilimler = computed
            self.isLoading = false
        }
    }
}
