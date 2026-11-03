import SwiftUI

public struct UtilitarianCariRow: View {
    public let cari: CariKart
    public var onQuickPayment: (() -> Void)?
    public var onOpenYaslandirma: (() -> Void)?
    
    public init(
        cari: CariKart,
        onQuickPayment: (() -> Void)? = nil,
        onOpenYaslandirma: (() -> Void)? = nil
    ) {
        self.cari = cari
        self.onQuickPayment = onQuickPayment
        self.onOpenYaslandirma = onOpenYaslandirma
    }
    
    private var isBorclu: Bool {
        cari.bakiyeTuru == "B"
    }
    
    public var body: some View {
        GlassCard(cornerRadius: 14, padding: 12) {
            VStack(spacing: 10) {
                // Üst Satır: Unvan ve Bakiye
                HStack(alignment: .top, spacing: 10) {
                    ZStack {
                        Circle()
                            .fill((isBorclu ? AppTheme.danger : AppTheme.success).opacity(0.15))
                            .frame(width: 38, height: 38)
                        Text(String(cari.unvan.prefix(1)).uppercased())
                            .font(.system(size: 15, weight: .bold))
                            .foregroundColor(isBorclu ? AppTheme.danger : AppTheme.success)
                    }
                    
                    VStack(alignment: .leading, spacing: 3) {
                        Text(cari.unvan)
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(AppTheme.textPrimary)
                            .lineLimit(1)
                        
                        HStack(spacing: 6) {
                            Text(cari.cariTuru ?? "Müşteri")
                                .font(.system(size: 10, weight: .semibold))
                                .foregroundColor(AppTheme.textMuted)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(AppTheme.cardSecondary)
                                .cornerRadius(4)
                            
                            if let sehir = cari.sehir, !sehir.isEmpty {
                                Text(sehir)
                                    .font(.system(size: 11))
                                    .foregroundColor(AppTheme.textSecondary)
                            }
                        }
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .trailing, spacing: 2) {
                        Text(AppFormatters.money(cari.bakiye))
                            .font(.system(size: 15, weight: .heavy))
                            .foregroundColor(cari.bakiye == 0 ? AppTheme.textMuted : (isBorclu ? AppTheme.danger : AppTheme.success))
                        
                        Text(cari.bakiye == 0 ? "Bakiye Yok" : (isBorclu ? "Borçlu" : "Alacaklı"))
                            .font(.system(size: 10, weight: .bold))
                            .foregroundColor(cari.bakiye == 0 ? AppTheme.textMuted : (isBorclu ? AppTheme.danger : AppTheme.success))
                    }
                }
                
                Divider().background(AppTheme.border)
                
                // Alt Satır: Hızlı Aksiyon Araç Çubuğu
                HStack(spacing: 8) {
                    // WhatsApp
                    if let gsm = cari.gsm ?? cari.telefon, !gsm.isEmpty {
                        Button {
                            let clean = gsm.replacingOccurrences(of: " ", with: "").replacingOccurrences(of: "-", with: "")
                            if let url = URL(string: "https://wa.me/90\(clean)") {
                                #if canImport(UIKit)
                                UIApplication.shared.open(url)
                                #endif
                            }
                        } label: {
                            HStack(spacing: 4) {
                                Image(systemName: "message.fill")
                                Text("WhatsApp")
                            }
                            .font(.system(size: 11, weight: .semibold))
                            .foregroundColor(Color(hex: "25D366"))
                            .padding(.horizontal, 8)
                            .padding(.vertical, 5)
                            .background(Color(hex: "25D366").opacity(0.12))
                            .cornerRadius(6)
                        }
                    }
                    
                    // Yaşlandırma Analizi Butonu
                    Button {
                        onOpenYaslandirma?()
                    } label: {
                        HStack(spacing: 4) {
                            Image(systemName: "clock.arrow.circlepath")
                            Text("Yaşlandırma")
                        }
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundColor(AppTheme.info)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 5)
                        .background(AppTheme.info.opacity(0.12))
                        .cornerRadius(6)
                    }
                    
                    Spacer()
                    
                    // Hızlı Tahsilat / Tediye Butonu
                    Button {
                        onQuickPayment?()
                    } label: {
                        HStack(spacing: 4) {
                            Image(systemName: "plus.circle.fill")
                            Text("Hızlı İşlem")
                        }
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                        .background(AppTheme.primary)
                        .cornerRadius(6)
                    }
                }
            }
        }
    }
}

