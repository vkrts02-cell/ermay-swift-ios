import SwiftUI

public struct StokDetailView: View {
    public let stok: StokKart
    @State private var hareketler: [StokHareket] = []
    @State private var isLoading: Bool = true
    @State private var pdfPreviewItem: PDFPreviewItem? = nil
    @State private var isGeneratingPDF: Bool = false
    
    public init(stok: StokKart) {
        self.stok = stok
    }
    
    public var body: some View {
        ZStack {
            AppTheme.background.ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 16) {
                    GlassCard(cornerRadius: 18, padding: 18) {
                        VStack(spacing: 12) {
                            HStack(alignment: .top) {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(stok.stokKodu ?? "KODSUZ")
                                        .font(.system(size: 11, weight: .bold))
                                        .foregroundColor(AppTheme.primary)
                                    Text(stok.stokAdi)
                                        .font(.system(size: 18, weight: .bold))
                                        .foregroundColor(AppTheme.textPrimary)
                                }
                                Spacer()
                                StatusBadge(
                                    title: "\(String(format: "%.2f", stok.mevcutMiktar)) \(stok.birim ?? "Adet")",
                                    color: stok.mevcutMiktar <= (stok.kritikMiktar ?? 0) ? AppTheme.danger : AppTheme.success
                                )
                            }
                            
                            Divider().background(AppTheme.border)
                            
                            HStack(spacing: 20) {
                                VStack(alignment: .leading, spacing: 2) {
                                    Text("Alış Fiyatı")
                                        .font(.system(size: 11))
                                        .foregroundColor(AppTheme.textSecondary)
                                    Text(AppFormatters.money(stok.alisFiyati))
                                        .font(.system(size: 15, weight: .bold))
                                        .foregroundColor(AppTheme.textPrimary)
                                }
                                Spacer()
                                VStack(alignment: .trailing, spacing: 2) {
                                    Text("Satış Fiyatı")
                                        .font(.system(size: 11))
                                        .foregroundColor(AppTheme.textSecondary)
                                    Text(AppFormatters.money(stok.satisFiyati))
                                        .font(.system(size: 15, weight: .bold))
                                        .foregroundColor(AppTheme.primary)
                                }
                            }
                        }
                    }
                    .padding(.horizontal)
                    
                    ActionButton(
                        title: isGeneratingPDF ? "PDF Hazırlanıyor..." : "QuestPDF Stok Hareket Raporu Aç",
                        icon: "doc.text.fill",
                        color: AppTheme.primary
                    ) {
                        #if canImport(UIKit)
                        Task { @MainActor in
                            isGeneratingPDF = true
                            let data = await PDFService.shared.fetchOrGenerateStokHareketPDF(stok: stok, hareketler: hareketler)
                            isGeneratingPDF = false
                            pdfPreviewItem = PDFPreviewItem(
                                title: "\(stok.stokAdi) - Hareket Raporu",
                                data: data,
                                fileName: "Stok_Hareket_\(stok.stokKodu ?? "Stok").pdf"
                            )
                        }
                        #endif
                    }
                    .padding(.horizontal)
                    .disabled(isGeneratingPDF)
                    
                    // Stok Hareketleri
                    VStack(alignment: .leading, spacing: 10) {
                        HStack {
                            Text("Stok Hareket Geçmişi (\(hareketler.count))")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(AppTheme.textPrimary)
                            Spacer()
                            if isLoading {
                                ProgressView().tint(AppTheme.primary)
                            }
                        }
                        .padding(.horizontal)
                        
                        if hareketler.isEmpty && !isLoading {
                            GlassCard(cornerRadius: 12, padding: 14) {
                                Text("Bu stok kartına ait kayıtlı hareket bulunmuyor.")
                                    .font(.system(size: 12))
                                    .foregroundColor(AppTheme.textMuted)
                            }
                            .padding(.horizontal)
                        } else {
                            VStack(spacing: 8) {
                                ForEach(hareketler) { h in
                                    let isGiris = h.giren > 0 || (h.cikan == 0 && !(h.islemTuru ?? "").localizedCaseInsensitiveContains("çıkış") && !(h.islemTuru ?? "").localizedCaseInsensitiveContains("satış"))
                                    GlassCard(cornerRadius: 12, padding: 12) {
                                        HStack {
                                            Image(systemName: isGiris ? "arrow.down.left.circle.fill" : "arrow.up.right.circle.fill")
                                                .font(.system(size: 20))
                                                .foregroundColor(isGiris ? AppTheme.success : AppTheme.danger)
                                            
                                            VStack(alignment: .leading, spacing: 2) {
                                                Text(h.aciklama ?? h.cariUnvan ?? h.islemTuru ?? "Hareket")
                                                    .font(.system(size: 13, weight: .semibold))
                                                    .foregroundColor(AppTheme.textPrimary)
                                                Text(String((h.tarih ?? "-").prefix(10)))
                                                    .font(.system(size: 11))
                                                    .foregroundColor(AppTheme.textMuted)
                                            }
                                            
                                            Spacer()
                                            
                                            VStack(alignment: .trailing, spacing: 2) {
                                                Text("\(isGiris ? "+" : "-")\(String(format: "%.2f", max(h.miktar, max(h.giren, h.cikan))))")
                                                    .font(.system(size: 14, weight: .bold))
                                                    .foregroundColor(isGiris ? AppTheme.success : AppTheme.danger)
                                                Text(AppFormatters.money(h.birimFiyat))
                                                    .font(.system(size: 11))
                                                    .foregroundColor(AppTheme.textSecondary)
                                            }
                                        }
                                    }
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                }
                .padding(.top, 12)
            }
        }
        .navigationTitle("Stok Detayı")
        .navigationBarTitleDisplayMode(.inline)
        .enableSwipeBack()
        .task {
            await loadHareketler()
        }
        .sheet(item: $pdfPreviewItem) { item in
            #if canImport(UIKit)
            PDFViewerModal(title: item.title, pdfData: item.data, fileName: item.fileName)
            #endif
        }
    }
    
    private func loadHareketler() async {
        isLoading = true
        let all: [StokHareket] = (try? await SupabaseService.shared.fetch(from: "stok_hareketler")) ?? []
        let filtered = all.filter { $0.stokId == stok.id || $0.stokAdi == stok.stokAdi || ($0.stokKodu != nil && $0.stokKodu == stok.stokKodu) }
            .sorted { ($0.tarih ?? "") > ($1.tarih ?? "") }
        await MainActor.run {
            self.hareketler = filtered
            self.isLoading = false
        }
    }
}
