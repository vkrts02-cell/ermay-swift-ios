import SwiftUI

public struct StokDetailView: View {
    public let stok: StokKart
    @State private var hareketler: [StokHareket] = [
        StokHareket(id: "1", tarih: "02.11.2026", islemTuru: "Satış Faturası", belgeNo: "FTR-2026-0012", miktar: 5, birimFiyat: 220, toplamTutar: 1100, aciklama: "Ermay Ltd. Şti. Satışı"),
        StokHareket(id: "2", tarih: "25.10.2026", islemTuru: "Alış Faturası", belgeNo: "FTR-2026-0004", miktar: 50, birimFiyat: 140, toplamTutar: 7000, aciklama: "Akıncılar Çelik Alımı")
    ]
    
    public init(stok: StokKart) {
        self.stok = stok
    }
    
    public var isKritik: Bool {
        stok.mevcutMiktar <= (stok.kritikMiktar ?? 5.0)
    }
    
    public var body: some View {
        ZStack {
            AppTheme.background.ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 16) {
                    // Hero Card
                    GlassCard(cornerRadius: 18, padding: 18) {
                        VStack(spacing: 12) {
                            Text(stok.stokAdi)
                                .font(.system(size: 18, weight: .bold))
                                .foregroundColor(AppTheme.textPrimary)
                                .multilineTextAlignment(.center)
                            
                            HStack(spacing: 8) {
                                if let kod = stok.stokKodu {
                                    StatusBadge(title: kod, color: AppTheme.primary)
                                }
                                if let grup = stok.grupAdi {
                                    StatusBadge(title: grup, color: AppTheme.secondary)
                                }
                            }
                            
                            Divider().background(AppTheme.border)
                            
                            VStack(spacing: 2) {
                                Text("MEVCUT ENVANTER")
                                    .font(.system(size: 10, weight: .bold))
                                    .foregroundColor(AppTheme.textSecondary)
                                
                                Text("\(String(format: "%.2f", stok.mevcutMiktar)) \(stok.birim ?? "Adet")")
                                    .font(.system(size: 28, weight: .heavy))
                                    .foregroundColor(isKritik ? AppTheme.danger : AppTheme.success)
                                
                                Text(isKritik ? "DİKKAT: Kritik stok eşiğinin altında!" : "Stok durumu yeterli")
                                    .font(.system(size: 11, weight: .medium))
                                    .foregroundColor(isKritik ? AppTheme.danger : AppTheme.textMuted)
                            }
                        }
                    }
                    .padding(.horizontal)
                    
                    // Fiyat ve Kar Marjı Kartı
                    GlassCard(cornerRadius: 16, padding: 16) {
                        VStack(spacing: 12) {
                            DetailInfoRow(label: "Alış Fiyatı", value: AppFormatters.money(stok.alisFiyati))
                            DetailInfoRow(label: "Satış Fiyatı", value: AppFormatters.money(stok.satisFiyati))
                            
                            let kar = stok.satisFiyati - stok.alisFiyati
                            let marj = stok.alisFiyati > 0 ? (kar / stok.alisFiyati) * 100 : 0
                            DetailInfoRow(label: "Birim Kar / Marj", value: "\(AppFormatters.money(kar)) (% \(String(format: "%.1f", marj)))")
                            
                            DetailInfoRow(label: "KDV Oranı", value: "%\(Int(stok.kdvOrani))")
                            DetailInfoRow(label: "Barkod No", value: stok.barkod ?? "-")
                            DetailInfoRow(label: "Kritik Eşik", value: "\(String(format: "%.0f", stok.kritikMiktar ?? 5.0)) \(stok.birim ?? "")")
                        }
                    }
                    .padding(.horizontal)
                    
                    // Stok Hareketleri Geçmişi
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Stok Giriş / Çıkış Hareketleri")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(AppTheme.textPrimary)
                            .padding(.horizontal)
                        
                        VStack(spacing: 8) {
                            ForEach(hareketler) { h in
                                GlassCard(cornerRadius: 12, padding: 12) {
                                    HStack {
                                        VStack(alignment: .leading, spacing: 2) {
                                            Text(h.islemTuru ?? "Hareket")
                                                .font(.system(size: 13, weight: .bold))
                                                .foregroundColor(AppTheme.textPrimary)
                                            Text("\(h.tarih ?? "-") • \(h.belgeNo ?? "")")
                                                .font(.system(size: 11))
                                                .foregroundColor(AppTheme.textMuted)
                                        }
                                        Spacer()
                                        VStack(alignment: .trailing, spacing: 2) {
                                            Text("\(String(format: "%.0f", h.miktar)) \(stok.birim ?? "Adet")")
                                                .font(.system(size: 13, weight: .bold))
                                                .foregroundColor(h.islemTuru?.contains("Satış") == true ? AppTheme.danger : AppTheme.success)
                                            Text(AppFormatters.money(h.toplamTutar))
                                                .font(.system(size: 10))
                                                .foregroundColor(AppTheme.textMuted)
                                        }
                                    }
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                    
                    Spacer().frame(height: 20)
                }
                .padding(.top, 12)
            }
        }
        .navigationTitle("Stok Kart Detayı")
        .navigationBarTitleDisplayMode(.inline)
    }
}
