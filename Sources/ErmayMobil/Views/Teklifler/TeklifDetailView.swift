import SwiftUI

public struct TeklifDetailView: View {
    @State public var teklif: Teklif
    @State private var showConvertAlert: Bool = false
    @State private var convertedNotice: String? = nil
    @State private var pdfData: Data? = nil
    @State private var showShareSheet: Bool = false
    
    public init(teklif: Teklif) {
        self._teklif = State(initialValue: teklif)
    }
    
    public var body: some View {
        ZStack {
            AppTheme.background.ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 16) {
                    if let notice = convertedNotice {
                        Text(notice)
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(AppTheme.success)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(AppTheme.success.opacity(0.15))
                            .cornerRadius(10)
                            .padding(.horizontal)
                    }
                    
                    GlassCard(cornerRadius: 18, padding: 18) {
                        VStack(spacing: 12) {
                            HStack {
                                Text(teklif.teklifNo)
                                    .font(.system(size: 18, weight: .bold))
                                    .foregroundColor(AppTheme.textPrimary)
                                Spacer()
                                StatusBadge(title: teklif.durum, color: teklif.durum == "ONAYLANDI" ? AppTheme.success : AppTheme.primary)
                            }
                            
                            Divider().background(AppTheme.border)
                            
                            VStack(alignment: .leading, spacing: 6) {
                                Text("MÜŞTERİ / MUHATAP")
                                    .font(.system(size: 10, weight: .bold))
                                    .foregroundColor(AppTheme.textSecondary)
                                Text(teklif.cariUnvan ?? "-")
                                    .font(.system(size: 15, weight: .semibold))
                                    .foregroundColor(AppTheme.textPrimary)
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            
                            DetailInfoRow(label: "Teklif Tarihi", value: teklif.tarih)
                            DetailInfoRow(label: "Son Geçerlilik", value: teklif.gecerlilikTarihi ?? "-")
                        }
                    }
                    .padding(.horizontal)
                    
                    // Kalemler
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Teklif Kalemleri")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(AppTheme.textPrimary)
                            .padding(.horizontal)
                        
                        if let kalemler = teklif.kalemler, !kalemler.isEmpty {
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
                            DetailSummaryRow(label: "Ara Toplam", value: AppFormatters.money(teklif.araToplam))
                            DetailSummaryRow(label: "KDV Toplamı", value: AppFormatters.money(teklif.kdvToplami))
                            Divider().background(AppTheme.border)
                            HStack {
                                Text("GENEL TOPLAM")
                                    .font(.system(size: 14, weight: .bold))
                                    .foregroundColor(AppTheme.textPrimary)
                                Spacer()
                                Text(AppFormatters.money(teklif.genelToplam))
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
                                self.pdfData = await PDFService.shared.fetchOrGenerateTeklifPDF(
                                    teklif: teklif,
                                    kalemler: teklif.kalemler ?? [],
                                    firma: .varsayilan
                                )
                                self.showShareSheet = true
                            }
                            #endif
                        }
                        
                        if teklif.durum != "ONAYLANDI" {
                            ActionButton(
                                title: "Teklifi Onayla",
                                icon: "checkmark.seal.fill",
                                color: AppTheme.success
                            ) {
                                updateDurum("ONAYLANDI")
                            }
                        }
                        
                        ActionButton(
                            title: "Siparişe Dönüştür",
                            icon: "cart.badge.plus.fill",
                            color: Color(hex: "00FF87")
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
        .navigationTitle("Teklif Detayı")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showShareSheet) {
            #if canImport(UIKit)
            if let data = pdfData {
                ShareSheet(activityItems: [data])
            }
            #endif
        }
        .alert("Siparişe Dönüştür", isPresented: $showConvertAlert) {
            Button("Evet, Sipariş Oluştur") {
                convertToSiparis()
            }
            Button("Vazgeç", role: .cancel) {}
        } message: {
            Text("Bu teklifin kalemleri otomatik olarak yeni bir siparişe aktarılacaktır. Onaylıyor musunuz?")
        }
    }
    
    private func updateDurum(_ yeniDurum: String) {
        Task {
            try? await SupabaseService.shared.update(table: "teklifler", id: teklif.id, item: ["durum": yeniDurum])
            await MainActor.run {
                teklif.durum = yeniDurum
            }
        }
    }
    
    private func convertToSiparis() {
        let siparisNo = "SIP-\(Int.random(in: 1000...9999))"
        let sKalemler: [SiparisKalem] = (teklif.kalemler ?? []).map { k in
            SiparisKalem(
                stokAdi: k.stokAdi,
                miktar: k.miktar,
                birim: k.birim,
                birimFiyat: k.birimFiyat,
                kdvOrani: k.kdvOrani,
                tutar: k.tutar
            )
        }
        
        let yeniSiparis = Siparis(
            siparisNo: siparisNo,
            siparisTuru: "ALINAN",
            cariUnvan: teklif.cariUnvan,
            tarih: AppFormatters.isoDate.string(from: Date()),
            araToplam: teklif.araToplam,
            kdvToplami: teklif.kdvToplami,
            genelToplam: teklif.genelToplam,
            kalemler: sKalemler
        )
        
        Task {
            try? await SupabaseService.shared.insert(into: "siparisler", item: yeniSiparis)
            try? await SupabaseService.shared.update(table: "teklifler", id: teklif.id, item: ["durum": "ONAYLANDI"])
            await MainActor.run {
                teklif.durum = "ONAYLANDI"
                convertedNotice = "Teklif başarıyla '\(siparisNo)' nolu siparişe dönüştürüldü."
            }
        }
    }
}
