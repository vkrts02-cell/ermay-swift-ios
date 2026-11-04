import SwiftUI

public struct CariYaslandirmaModalView: View {
    @Environment(\.dismiss) private var dismiss
    public let cari: CariKart
    
    // Sample Vade Dilimleri
    struct AgingBucket: Identifiable {
        let id = UUID()
        let label: String
        let rangeDays: String
        let amount: Double
        let color: Color
        let invoiceCount: Int
    }
    
    private var buckets: [AgingBucket] {
        let base = cari.bakiye > 0 ? cari.bakiye : 35000.0
        return [
            AgingBucket(label: "0 - 30 Gün", rangeDays: "Yeni Vadeler", amount: base * 0.45, color: Color(hex: "10B981"), invoiceCount: 3),
            AgingBucket(label: "31 - 60 Gün", rangeDays: "Hafif Geciken", amount: base * 0.25, color: Color(hex: "3B82F6"), invoiceCount: 2),
            AgingBucket(label: "61 - 90 Gün", rangeDays: "Riskli Bölge", amount: base * 0.18, color: Color(hex: "F59E0B"), invoiceCount: 1),
            AgingBucket(label: "90+ Gün", rangeDays: "Kritik Takip", amount: base * 0.12, color: Color(hex: "EF4444"), invoiceCount: 2)
        ]
    }
    
    public init(cari: CariKart) {
        self.cari = cari
    }
    
    public var body: some View {
        NavigationStack {
            ZStack {
                Color(hex: "080A0C").ignoresSafeArea()
                
                VStack(spacing: 0) {
                    renderHeader()
                    
                    ScrollView(showsIndicators: false) {
                        VStack(spacing: 16) {
                            renderCariSummary()
                            renderAgingChart()
                            renderBucketList()
                            renderOverdueInvoices()
                            Spacer().frame(height: 30)
                        }
                        .padding(16)
                    }
                }
            }
            .navigationBarHidden(true)
        }
    }
    
    @ViewBuilder
    private func renderHeader() -> some View {
        HStack {
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color(hex: "F59E0B").opacity(0.15))
                    .frame(width: 38, height: 38)
                Image(systemName: "chart.bar.xaxis")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(Color(hex: "F59E0B"))
            }
            
            VStack(alignment: .leading, spacing: 2) {
                Text("Vade Yaşlandırma Analizi")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.white)
                Text(cari.unvan)
                    .font(.system(size: 12))
                    .foregroundColor(Color(hex: "8E8E93"))
                    .lineLimit(1)
            }
            
            Spacer()
            
            Button {
                dismiss()
            } label: {
                Image(systemName: "xmark.circle.fill")
                    .font(.system(size: 24))
                    .foregroundColor(Color(hex: "8E8E93"))
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(Color(hex: "121216"))
        .overlay(Rectangle().frame(height: 1).foregroundColor(Color.white.opacity(0.08)), alignment: .bottom)
    }
    
    @ViewBuilder
    private func renderCariSummary() -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 3) {
                Text("Toplam Yaşlandırılan Bakiye")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundColor(Color(hex: "8E8E93"))
                Text(AppFormatters.money(cari.bakiye))
                    .font(.system(size: 24, weight: .heavy))
                    .foregroundColor(cari.bakiyeTuru == "B" ? Color(hex: "EF4444") : Color(hex: "10B981"))
            }
            Spacer()
            VStack(alignment: .trailing, spacing: 3) {
                Text("Ödeme Planı")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundColor(Color(hex: "8E8E93"))
                Text("\(cari.odemePlani ?? "Peşin") (\(cari.vadeGunu ?? 0) Gün)")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundColor(.white)
            }
        }
        .padding(14)
        .background(Color(hex: "121216"))
        .cornerRadius(14)
        .overlay(RoundedRectangle(cornerRadius: 14).stroke(Color.white.opacity(0.08), lineWidth: 1))
    }
    
    @ViewBuilder
    private func renderAgingChart() -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("VADE DAĞILIM ÇUBUĞU")
                .font(.system(size: 11, weight: .bold))
                .foregroundColor(Color(hex: "8E8E93"))
            
            // Stacked Distribution Bar
            GeometryReader { geo in
                HStack(spacing: 2) {
                    let total = buckets.reduce(0) { $0 + $1.amount }
                    ForEach(buckets) { b in
                        let w = total > 0 ? (CGFloat(b.amount / total) * (geo.size.width - 6)) : 0
                        Rectangle()
                            .fill(b.color)
                            .frame(width: max(w, 4))
                    }
                }
                .cornerRadius(6)
            }
            .frame(height: 18)
            
            // Legend
            HStack(spacing: 12) {
                ForEach(buckets) { b in
                    HStack(spacing: 4) {
                        Circle().fill(b.color).frame(width: 8, height: 8)
                        Text(b.label)
                            .font(.system(size: 10, weight: .semibold))
                            .foregroundColor(Color(hex: "8E8E93"))
                    }
                }
            }
            .padding(.top, 4)
        }
        .padding(14)
        .background(Color(hex: "121216"))
        .cornerRadius(14)
    }
    
    @ViewBuilder
    private func renderBucketList() -> some View {
        VStack(spacing: 8) {
            ForEach(buckets) { b in
                HStack {
                    Circle().fill(b.color).frame(width: 10, height: 10)
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text(b.label)
                            .font(.system(size: 13, weight: .bold))
                            .foregroundColor(.white)
                        Text("\(b.rangeDays) • \(b.invoiceCount) Belge")
                            .font(.system(size: 11))
                            .foregroundColor(Color(hex: "8E8E93"))
                    }
                    
                    Spacer()
                    
                    Text(AppFormatters.money(b.amount))
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(b.color)
                }
                .padding(12)
                .background(Color.white.opacity(0.03))
                .cornerRadius(10)
            }
        }
        .padding(14)
        .background(Color(hex: "121216"))
        .cornerRadius(14)
    }
    
    @ViewBuilder
    private func renderOverdueInvoices() -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("VADESİ GEÇEN VE BEKLEYEN FATURALAR")
                .font(.system(size: 11, weight: .bold))
                .foregroundColor(Color(hex: "8E8E93"))
            
            let sampleInvoices = [
                ("FTR-2026-0042", "15.09.2026", 18500.0, "50 Gün Gecikti", Color(hex: "EF4444")),
                ("FTR-2026-0051", "05.10.2026", 12300.0, "30 Gün Gecikti", Color(hex: "F59E0B")),
                ("FTR-2026-0060", "28.10.2026", 14400.0, "7 Gün Gecikti", Color(hex: "3B82F6"))
            ]
            
            ForEach(sampleInvoices, id: \.0) { inv in
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(inv.0)
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(.white)
                        Text("Vade: \(inv.1)")
                            .font(.system(size: 10))
                            .foregroundColor(Color(hex: "8E8E93"))
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .trailing, spacing: 2) {
                        Text(AppFormatters.money(inv.2))
                            .font(.system(size: 13, weight: .bold))
                            .foregroundColor(.white)
                        Text(inv.3)
                            .font(.system(size: 10, weight: .bold))
                            .foregroundColor(inv.4)
                    }
                }
                .padding(10)
                .background(Color.white.opacity(0.02))
                .cornerRadius(8)
            }
        }
        .padding(14)
        .background(Color(hex: "121216"))
        .cornerRadius(14)
    }
}

