import SwiftUI

public struct SiparisDetailView: View {
    @State public var siparis: Siparis
    @State private var showConvertAlert: Bool = false
    @State private var convertedSuccess: Bool = false
    @State private var pdfData: Data? = nil
    @State private var showShareSheet: Bool = false
    
    public init(siparis: Siparis) {
        self._siparis = State(initialValue: siparis)
    }
    
    public var body: some View {
        ZStack {
            AppTheme.background.ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 16) {
                    GlassCard(cornerRadius: 18, padding: 18) {
                        VStack(spacing: 12) {
                            HStack {
                                Text(siparis.siparisNo)
                                    .font(.system(size: 18, weight: .bold))
                                    .foregroundColor(AppTheme.textPrimary)
                                Spacer()
                                StatusBadge(title: siparis.durum, color: AppTheme.primary)
                            }
                            
                            Divider().background(AppTheme.border)
                            
                            VStack(alignment: .leading, spacing: 6) {
                                Text("MÜŞTERİ / TEDARİKÇİ")
                                    .font(.system(size: 10, weight: .bold))
                                    .foregroundColor(AppTheme.textSecondary)
                                Text(siparis.cariUnvan ?? "-")
                                    .font(.system(size: 15, weight: .semibold))
                                    .foregroundColor(AppTheme.textPrimary)
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            
                            DetailInfoRow(label: "Sipariş Tarihi", value: siparis.tarih)
                            DetailInfoRow(label: "Teslim Tarihi", value: siparis.teslimTarihi ?? "-")
                        }
                    }
                    .padding(.horizontal)
                    
                    // Kalemler
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Sipariş Kalemleri")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(AppTheme.textPrimary)
                            .padding(.horizontal)
                        
                        if let kalemler = siparis.kalemler, !kalemler.isEmpty {
                            VStack(spacing: 8) {
                                ForEach(kalemler) { k in
                                    GlassCard(cornerRadius: 12, padding: 12) {
                                        HStack {
                                            VStack(alignment: .leading, spacing: 3) {
                                                Text(k.stokAdi)
                                                    .font(.system(size: 13, weight: .bold))
                                                    .foregroundColor(AppTheme.textPrimary)
                                                Text("\(String(format: "%.2f", k.miktar)) x \(AppFormatters.money(k.birimFiyat))")
                                                    .font(.system(size: 11))
                                                    .foregroundColor(AppTheme.textMuted)
                                            }
                                            Spacer()
                                            Text(AppFormatters.money(k.tutar))
                                                .font(.system(size: 14, weight: .bold))
                                                .foregroundColor(AppTheme.textPrimary)
                                        }
                                    }
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                    
                    // Toplamlar
                    GlassCard(cornerRadius: 16, padding: 16) {
                        VStack(spacing: 8) {
                            DetailSummaryRow(label: "Ara Toplam", value: AppFormatters.money(siparis.araToplam))
                            DetailSummaryRow(label: "KDV Toplamı", value: AppFormatters.money(siparis.kdvToplami))
                            Divider().background(AppTheme.border)
                            HStack {
                                Text("GENEL TOPLAM")
                                    .font(.system(size: 14, weight: .bold))
                                    .foregroundColor(AppTheme.textPrimary)
                                Spacer()
                                Text(AppFormatters.money(siparis.genelToplam))
                                    .font(.system(size: 20, weight: .heavy))
                                    .foregroundColor(AppTheme.primary)
                            }
                        }
                    }
                    .padding(.horizontal)
                    
                    // Aksiyon Butonları
                    VStack(spacing: 10) {
                        ActionButton(
                            title: "PDF Görüntüle & Paylaş",
                            icon: "square.and.arrow.up.fill",
                            color: AppTheme.primary
                        ) {
                            #if canImport(UIKit)
                            Task { @MainActor in
                                self.pdfData = await PDFService.shared.fetchOrGenerateSiparisPDF(
                                    siparis: siparis,
                                    kalemler: siparis.kalemler ?? [],
                                    firma: .varsayilan
                                )
                                self.showShareSheet = true
                            }
                            #endif
                        }
                        
                        // Faturaya Dönüştür Butonu
                        ActionButton(
                            title: "Faturaya Dönüştür",
                            icon: "doc.badge.arrow.up.fill",
                            color: AppTheme.success
                        ) {
                            showConvertAlert = true
                        }
                    }
                    .padding(.horizontal)
                    
                    Spacer().frame(height: 20)
                }
                .padding(.top, 12)
            }
        }
        .navigationTitle("Sipariş Detayı")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showShareSheet) {
            #if canImport(UIKit)
            if let data = pdfData {
                ShareSheet(activityItems: [data])
            }
            #endif
        }
        .alert("Faturaya Dönüştür", isPresented: $showConvertAlert) {
            Button("Evet, Fatura Oluştur") {
                convertToFatura()
            }
            Button("Vazgeç", role: .cancel) {}
        } message: {
            Text("Bu sipariş kalemleri satış faturasına aktarılacak ve sipariş 'TAMAMLANDI' durumuna getirilecektir. Onaylıyor musunuz?")
        }
    }
    
    private func convertToFatura() {
        let faturaNo = "FTR-SIP-\(Int.random(in: 1000...9999))"
        let faturaKalemler: [FaturaKalem] = (siparis.kalemler ?? []).map { k in
            FaturaKalem(
                stokAdi: k.stokAdi,
                birim: k.birim,
                miktar: k.miktar,
                birimFiyat: k.birimFiyat,
                kdvOrani: k.kdvOrani
            )
        }
        
        let yeniFatura = Fatura(
            faturaNo: faturaNo,
            faturaTuru: siparis.siparisTuru == "ALINAN" ? "SATIS" : "ALIS",
            cariUnvan: siparis.cariUnvan,
            tarih: AppFormatters.isoDate.string(from: Date()),
            araToplam: siparis.araToplam,
            kdvToplami: siparis.kdvToplami,
            genelToplam: siparis.genelToplam,
            kalemler: faturaKalemler
        )
        
        Task {
            try? await SupabaseService.shared.insert(into: "faturalar", item: yeniFatura)
            try? await SupabaseService.shared.update(table: "siparisler", id: siparis.id, item: ["durum": "TAMAMLANDI"])
            await MainActor.run {
                siparis.durum = "TAMAMLANDI"
                convertedSuccess = true
            }
        }
    }
}

