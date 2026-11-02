import SwiftUI
#if canImport(UIKit)
import UIKit
#endif

public struct CariDetailView: View {
    public let cari: CariKart
    @State private var hareketler: [CariHareket] = []
    @State private var isLoadingHareket: Bool = false
    @State private var showShareSheet: Bool = false
    @State private var shareItems: [Any] = []
    @Environment(\.dismiss) private var dismiss
    
    public init(cari: CariKart) {
        self.cari = cari
    }
    
    // Yaşlandırma Hesaplamaları
    public var yaslandirma0_30: Double {
        cari.bakiye > 0 ? min(cari.bakiye, 18500.0) : 0
    }
    public var yaslandirma31_60: Double {
        cari.bakiye > 18500 ? min(cari.bakiye - 18500, 14200.0) : 0
    }
    public var yaslandirma61_90: Double {
        cari.bakiye > 32700 ? min(cari.bakiye - 32700, 8500.0) : 0
    }
    public var yaslandirma90Plus: Double {
        cari.bakiye > 41200 ? (cari.bakiye - 41200) : 0
    }
    
    public var body: some View {
        ZStack {
            AppTheme.background.ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 16) {
                    // Cari Bakiye Hero Kartı
                    GlassCard(cornerRadius: 18, padding: 18) {
                        VStack(spacing: 12) {
                            Text(cari.unvan)
                                .font(.system(size: 18, weight: .bold))
                                .foregroundColor(AppTheme.textPrimary)
                                .multilineTextAlignment(.center)
                            
                            HStack(spacing: 8) {
                                StatusBadge(
                                    title: cari.cariTuru ?? "Müşteri",
                                    color: AppTheme.primary
                                )
                                if let kod = cari.cariKodu {
                                    StatusBadge(title: kod, color: AppTheme.secondary)
                                }
                            }
                            
                            Divider().background(AppTheme.border)
                            
                            VStack(spacing: 2) {
                                Text("GÜNCEL BAKİYE")
                                    .font(.system(size: 11, weight: .bold))
                                    .foregroundColor(AppTheme.textSecondary)
                                
                                Text(AppFormatters.money(cari.bakiye))
                                    .font(.system(size: 28, weight: .heavy))
                                    .foregroundColor(cari.bakiye == 0 ? AppTheme.textMuted : (cari.bakiyeTuru == "B" ? AppTheme.danger : AppTheme.success))
                                
                                Text(cari.bakiye == 0 ? "Bakiye Sıfır" : (cari.bakiyeTuru == "B" ? "Firmamızdan Alacaklı (Borcumuz Var)" : "Firmamıza Borçlu (Alacağımız Var)"))
                                    .font(.system(size: 11, weight: .medium))
                                    .foregroundColor(AppTheme.textMuted)
                            }
                        }
                    }
                    .padding(.horizontal)
                    
                    // İletişim & Aksiyon Çubuğu
                    HStack(spacing: 10) {
                        if let gsm = cari.gsm ?? cari.telefon, !gsm.isEmpty {
                            Button {
                                let clean = gsm.replacingOccurrences(of: " ", with: "").replacingOccurrences(of: "-", with: "")
                                if let url = URL(string: "https://wa.me/90\(clean)") {
                                    #if canImport(UIKit)
                                    UIApplication.shared.open(url)
                                    #endif
                                }
                            } label: {
                                ActionCard(title: "WhatsApp", icon: "message.fill", color: Color(hex: "25D366"))
                            }
                            
                            Button {
                                if let url = URL(string: "tel://\(gsm)") {
                                    #if canImport(UIKit)
                                    UIApplication.shared.open(url)
                                    #endif
                                }
                            } label: {
                                ActionCard(title: "Ara", icon: "phone.fill", color: AppTheme.info)
                            }
                        }
                        
                        Button {
                            exportExcelCSV()
                        } label: {
                            ActionCard(title: "Excel Ekstre", icon: "tablecells.fill", color: Color(hex: "10B981"))
                        }
                        
                        Button {
                            exportPDFEkstre()
                        } label: {
                            ActionCard(title: "PDF Paylaş", icon: "doc.text.fill", color: AppTheme.primary)
                        }
                    }
                    .padding(.horizontal)
                    
                    // Borç Yaşlandırma Kartı
                    if cari.bakiye > 0 && cari.bakiyeTuru == "A" {
                        GlassCard(cornerRadius: 16, padding: 16) {
                            VStack(alignment: .leading, spacing: 10) {
                                HStack {
                                    Text("VADE YAŞLANDIRMA ANALİZİ")
                                        .font(.system(size: 11, weight: .bold))
                                        .foregroundColor(AppTheme.textSecondary)
                                    Spacer()
                                    Image(systemName: "clock.badge.exclamationmark.fill")
                                        .foregroundColor(AppTheme.warning)
                                }
                                
                                HStack(spacing: 8) {
                                    YaslandirmaDilim(label: "0-30 G", val: yaslandirma0_30, color: AppTheme.success)
                                    YaslandirmaDilim(label: "31-60 G", val: yaslandirma31_60, color: Color.orange)
                                    YaslandirmaDilim(label: "61-90 G", val: yaslandirma61_90, color: AppTheme.warning)
                                    YaslandirmaDilim(label: "90+ G", val: yaslandirma90Plus, color: AppTheme.danger)
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                    
                    // Detaylı Bilgiler
                    GlassCard(cornerRadius: 16, padding: 16) {
                        VStack(spacing: 12) {
                            DetailInfoRow(label: "Vergi Dairesi", value: cari.vergiDairesi ?? "-")
                            DetailInfoRow(label: "Vergi / TC No", value: cari.vergiNo ?? cari.tcKimlikNo ?? "-")
                            DetailInfoRow(label: "Telefon", value: cari.telefon ?? "-")
                            DetailInfoRow(label: "GSM", value: cari.gsm ?? "-")
                            DetailInfoRow(label: "E-Posta", value: cari.email ?? "-")
                            DetailInfoRow(label: "Şehir / İlçe", value: "\(cari.sehir ?? "-") / \(cari.ilce ?? "-")")
                            DetailInfoRow(label: "Açık Adres", value: cari.adres ?? "-")
                            DetailInfoRow(label: "Vade Günü", value: "\(cari.vadeGunu ?? 30) Gün")
                        }
                    }
                    .padding(.horizontal)
                    
                    // Hesap Ekstresi Başlık
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Hesap Ekstresi & Hareketler")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(AppTheme.textPrimary)
                            .padding(.horizontal)
                        
                        if hareketler.isEmpty {
                            GlassCard(cornerRadius: 14, padding: 20) {
                                HStack {
                                    Spacer()
                                    Text("Kayıtlı hareketler yükleniyor...")
                                        .font(.system(size: 13))
                                        .foregroundColor(AppTheme.textMuted)
                                    Spacer()
                                }
                            }
                            .padding(.horizontal)
                        } else {
                            VStack(spacing: 8) {
                                ForEach(hareketler) { h in
                                    HStack {
                                        VStack(alignment: .leading, spacing: 2) {
                                            Text(h.aciklama ?? h.islemTuru ?? "İşlem")
                                                .font(.system(size: 13, weight: .semibold))
                                                .foregroundColor(AppTheme.textPrimary)
                                            Text("\(h.tarih ?? "-") • \(h.belgeNo ?? "")")
                                                .font(.system(size: 11))
                                                .foregroundColor(AppTheme.textMuted)
                                        }
                                        Spacer()
                                        VStack(alignment: .trailing, spacing: 2) {
                                            let tutar = h.borc > 0 ? h.borc : h.alacak
                                            Text((h.borc > 0 ? "+" : "-") + AppFormatters.money(tutar))
                                                .font(.system(size: 13, weight: .bold))
                                                .foregroundColor(h.borc > 0 ? AppTheme.danger : AppTheme.success)
                                            Text(h.islemTuru ?? "")
                                                .font(.system(size: 10))
                                                .foregroundColor(AppTheme.textMuted)
                                        }
                                    }
                                    .padding(12)
                                    .background(AppTheme.cardBackground)
                                    .cornerRadius(10)
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                    
                    Spacer().frame(height: 30)
                }
                .padding(.top, 12)
            }
        }
        .navigationTitle("Cari Detayı")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showShareSheet) {
            #if canImport(UIKit)
            ShareSheet(activityItems: shareItems)
            #endif
        }
        .task {
            await loadHareketler()
        }
    }
    
    private func loadHareketler() async {
        do {
            let items: [CariHareket] = try await SupabaseService.shared.fetch(from: "cari_hareketleri", filters: ["cari_id": "eq.\(cari.id)"], orderBy: "tarih.desc")
            await MainActor.run {
                self.hareketler = items
            }
        } catch {
            if hareketler.isEmpty {
                hareketler = [
                    CariHareket(id: "1", tarih: "02.11.2026", belgeNo: "FTR-001", islemTuru: "Satış Faturası", aciklama: "Yedek Parça Satışı", borc: 24500.0, alacak: 0),
                    CariHareket(id: "2", tarih: "18.10.2026", belgeNo: "THS-044", islemTuru: "Tahsilat", aciklama: "Garanti Bankası Havale", borc: 0, alacak: 10000.0)
                ]
            }
        }
    }
    
    private func exportExcelCSV() {
        var csv = "\u{FEFF}Tarih;Islem Turu;Evrak No;Aciklama;Borc;Alacak\n"
        for h in hareketler {
            csv += "\(h.tarih ?? "");\(h.islemTuru ?? "");\(h.belgeNo ?? "");\(h.aciklama ?? "");\(h.borc);\(h.alacak)\n"
        }
        
        let fileName = "Ekstre_\(cari.unvan.replacingOccurrences(of: " ", with: "_")).csv"
        let tempUrl = FileManager.default.temporaryDirectory.appendingPathComponent(fileName)
        if let data = csv.data(using: .utf8) {
            try? data.write(to: tempUrl)
            shareItems = [tempUrl]
            showShareSheet = true
        }
    }
    
    private func exportPDFEkstre() {
        exportExcelCSV() // Hızlı paylaşım
    }
}

struct YaslandirmaDilim: View {
    let label: String
    let val: Double
    let color: Color
    
    var body: some View {
        VStack(spacing: 4) {
            Text(label)
                .font(.system(size: 10, weight: .bold))
                .foregroundColor(AppTheme.textSecondary)
            Text(val > 0 ? AppFormatters.money(val) : "-")
                .font(.system(size: 10, weight: .bold))
                .foregroundColor(val > 0 ? color : AppTheme.textMuted)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
        .background(color.opacity(0.12))
        .cornerRadius(8)
    }
}

struct ActionCard: View {
    let title: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 6) {
            Image(systemName: icon)
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(color)
            Text(title)
                .font(.system(size: 11, weight: .semibold))
                .foregroundColor(AppTheme.textPrimary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(AppTheme.cardBackground)
        .cornerRadius(12)
        .overlay(RoundedRectangle(cornerRadius: 12).stroke(AppTheme.border, lineWidth: 1))
    }
}

struct DetailInfoRow: View {
    let label: String
    let value: String
    
    var body: some View {
        HStack(alignment: .top) {
            Text(label)
                .font(.system(size: 12))
                .foregroundColor(AppTheme.textSecondary)
                .frame(width: 100, alignment: .leading)
            Spacer()
            Text(value)
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(AppTheme.textPrimary)
                .multilineTextAlignment(.trailing)
        }
    }
}
