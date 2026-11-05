import SwiftUI
#if canImport(UIKit)
import UIKit
#endif

public struct CariDetailView: View {
    @Environment(\.presentationMode) var presentationMode
    
    @State public var currentCari: CariKart
    public var onUpdate: ((CariKart) -> Void)?
    public var onDelete: ((CariKart) -> Void)?
    
    // Quick Modals
    @State private var showSatisForm: Bool = false
    @State private var showAlisForm: Bool = false
    @State private var showTransactionModal: Bool = false
    @State private var activeTransactionType: String = "Tahsilat"
    
    @State private var showYaslandirma: Bool = false
    @State private var showEditForm: Bool = false
    @State private var showDeleteConfirm: Bool = false
    @State private var deleteErrorMessage: String? = nil
    
    // PDF Modal
    @State private var showPDFModal: Bool = false
    @State private var generatedPDFData: Data? = nil
    @State private var pdfTitle: String = ""
    @State private var isGeneratingPDF: Bool = false
    
    // Canlı Cari Hareketler
    @State private var hareketler: [CariHareket] = []
    @State private var isLoadingHareketler: Bool = false
    
    public init(cari: CariKart, onUpdate: ((CariKart) -> Void)? = nil, onDelete: ((CariKart) -> Void)? = nil) {
        _currentCari = State(initialValue: cari)
        self.onUpdate = onUpdate
        self.onDelete = onDelete
    }
    
    public var body: some View {
        ZStack {
            Color(hex: "080A0C").ignoresSafeArea()
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 16) {
                    renderHeaderBar()
                    renderMainCard()
                    renderActionGrid()
                    renderHareketler()
                    renderIletisim()
                    renderFinansal()
                    renderRiskDurum()
                    renderFooterButtons()
                    Spacer().frame(height: 50)
                }
                .padding(.horizontal, 16)
            }
            .refreshable {
                await loadLiveHareketler()
            }
            
            // PDF Hazırlanıyor HUD
            if isGeneratingPDF {
                Color.black.opacity(0.4).ignoresSafeArea()
                VStack(spacing: 14) {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .scaleEffect(1.2)
                    Text("QuestPDF Ekstresi Hazırlanıyor...")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(.white)
                }
                .padding(.horizontal, 24)
                .padding(.vertical, 20)
                .background(Color(hex: "1E293B"))
                .cornerRadius(16)
                .shadow(color: .black.opacity(0.5), radius: 15, x: 0, y: 8)
            }
        }
        .navigationBarHidden(true)
        .onAppear {
            Task {
                await loadLiveHareketler()
            }
        }
        .sheet(isPresented: $showSatisForm) {
            FaturaFormView(initialTur: "Satış")
        }
        .sheet(isPresented: $showAlisForm) {
            FaturaFormView(initialTur: "Alış")
        }
        // Masaüstü Birebir: Tahsilat, Ödeme, Alacak Dekontu, Borç Dekontu Formu
        .sheet(isPresented: $showTransactionModal) {
            CariTransactionDialogView(
                initialCari: currentCari,
                transactionType: activeTransactionType
            ) { yeniHareket, guncelCari in
                hareketler.insert(yeniHareket, at: 0)
                currentCari = guncelCari
                onUpdate?(guncelCari)
            }
        }
        // Yaşlandırma Analizi Sayfası
        .sheet(isPresented: $showYaslandirma) {
            CariYaslandirmaModalView(cari: currentCari)
        }
        // Düzenle Formu (onSave bağlı)
        .sheet(isPresented: $showEditForm) {
            CariFormView(cariToEdit: currentCari) { updated in
                currentCari = updated
                onUpdate?(updated)
            }
        }
        // PDF Ekstre Önizleme Modalı
        .sheet(isPresented: $showPDFModal) {
            if let data = generatedPDFData {
                PDFViewerModal(
                    title: pdfTitle,
                    pdfData: data,
                    fileName: "Ekstre_\(currentCari.cariKodu ?? "Cari")_\(ISO8601DateFormatter().string(from: Date()).prefix(10)).pdf"
                )
            }
        }
        // Silme Onay Uyarısı
        .alert("Cari Kartı Sil", isPresented: $showDeleteConfirm) {
            Button("Sil", role: .destructive) {
                performDelete()
            }
            Button("Vazgeç", role: .cancel) {}
        } message: {
            Text("\(currentCari.unvan) adlı cari kartı silmek istediğinize emin misiniz?")
        }
        .alert("Silme Engellendi", isPresented: Binding<Bool>(
            get: { deleteErrorMessage != nil },
            set: { if !$0 { deleteErrorMessage = nil } }
        )) {
            Button("Tamam", role: .cancel) { deleteErrorMessage = nil }
        } message: {
            Text(deleteErrorMessage ?? "")
        }
    }
    
    // MARK: - Subviews
    @ViewBuilder
    private func renderHeaderBar() -> some View {
        HStack {
            Button {
                presentationMode.wrappedValue.dismiss()
            } label: {
                Image(systemName: "chevron.left")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.white)
                    .padding(8)
            }
            
            Text("Cari Detayı")
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(.white)
            
            Spacer()
            
            // Hızlı Ekstre PDF Butonu
            Button {
                exportEkstre(detayli: false)
            } label: {
                HStack(spacing: 4) {
                    Image(systemName: "printer.fill")
                    Text("Ekstre")
                }
                .font(.system(size: 12, weight: .bold))
                .foregroundColor(.white)
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background(Color.white.opacity(0.1))
                .cornerRadius(8)
            }
        }
        .padding(.top, 6)
    }
    
    @ViewBuilder
    private func renderMainCard() -> some View {
        VStack(spacing: 12) {
            Image(systemName: "person.crop.circle.fill")
                .font(.system(size: 64))
                .foregroundColor(Color(hex: "0061FF"))
                .padding(.top, 4)
            
            Text(currentCari.unvan)
                .font(.system(size: 18, weight: .heavy))
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
            
            Text("\(currentCari.cariTuru ?? "Alıcı") • \(currentCari.grupAdi ?? "Müşteri") • \(currentCari.cariKodu ?? "CARI-000")")
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(Color(hex: "8E8E93"))
            
            // Bakiye Box (Borç / Alacak)
            HStack {
                VStack(spacing: 2) {
                    Text("Toplam Borç")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(Color(hex: "8E8E93"))
                    Text(AppFormatters.money(currentCari.bakiyeTuru == "B" ? currentCari.bakiye : 0))
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(Color(hex: "EF4444"))
                }
                .frame(maxWidth: .infinity)
                
                Rectangle()
                    .fill(Color.white.opacity(0.1))
                    .frame(width: 1, height: 36)
                
                VStack(spacing: 2) {
                    Text("Toplam Alacak")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(Color(hex: "8E8E93"))
                    Text(AppFormatters.money(currentCari.bakiyeTuru == "A" ? currentCari.bakiye : 0))
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(Color(hex: "10B981"))
                }
                .frame(maxWidth: .infinity)
            }
            .padding(.vertical, 10)
            .background(Color.white.opacity(0.04))
            .cornerRadius(12)
        }
        .padding(16)
        .background(Color(hex: "121216"))
        .cornerRadius(20)
        .overlay(RoundedRectangle(cornerRadius: 20).stroke(Color.white.opacity(0.08), lineWidth: 1))
    }
    
    @ViewBuilder
    private func renderActionGrid() -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("HIZLI İŞLEMLER")
                .font(.system(size: 12, weight: .bold))
                .foregroundColor(Color(hex: "8E8E93"))
            
            LazyVGrid(columns: [GridItem(.flexible(), spacing: 8), GridItem(.flexible(), spacing: 8)], spacing: 8) {
                // SATIŞ
                actionGridBtn(title: "SATIŞ", iconName: "arrow.up.right", color: Color(hex: "2563EB")) {
                    showSatisForm = true
                }
                // ALIŞ
                actionGridBtn(title: "ALIŞ", iconName: "arrow.down.right", color: Color(hex: "D97706")) {
                    showAlisForm = true
                }
                // TAHSİLAT (Masaüstü Birebir Form)
                actionGridBtn(title: "TAHSİLAT", iconName: "arrow.down.left", color: Color(hex: "10B981")) {
                    activeTransactionType = "Tahsilat"
                    showTransactionModal = true
                }
                // ÖDEME (Masaüstü Birebir Form)
                actionGridBtn(title: "ÖDEME", iconName: "arrow.up.right", color: Color(hex: "EF4444")) {
                    activeTransactionType = "Ödeme"
                    showTransactionModal = true
                }
                // ALACAK DEKONTU (Masaüstü Birebir Form)
                actionGridBtn(title: "ALACAK", iconName: "plus.circle.fill", color: Color(hex: "8B5CF6")) {
                    activeTransactionType = "Alacak Dekontu"
                    showTransactionModal = true
                }
                // BORÇ DEKONTU (Masaüstü Birebir Form)
                actionGridBtn(title: "BORÇ", iconName: "minus.circle.fill", color: Color(hex: "EC4899")) {
                    activeTransactionType = "Borç Dekontu"
                    showTransactionModal = true
                }
                // Ekstre (PDF - QuestPDF)
                actionGridBtn(title: "Ekstre (PDF)", iconName: "doc.text.fill", color: Color(hex: "1E293B")) {
                    exportEkstre(detayli: false)
                }
                // Det. Ekstre (PDF - QuestPDF)
                actionGridBtn(title: "Det. Ekstre", iconName: "doc.text.magnifyingglass", color: Color(hex: "1E293B")) {
                    exportEkstre(detayli: true)
                }
                // Excel (CSV)
                actionGridBtn(title: "Excel (CSV)", iconName: "tablecells.fill", color: Color(hex: "1E293B")) {
                    exportExcel()
                }
                // Yaşlandırma
                actionGridBtn(title: "Yaşlandırma", iconName: "chart.bar.xaxis", color: Color(hex: "1E293B")) {
                    showYaslandirma = true
                }
            }
        }
        .padding(16)
        .background(Color(hex: "121216"))
        .cornerRadius(20)
        .overlay(RoundedRectangle(cornerRadius: 20).stroke(Color.white.opacity(0.08), lineWidth: 1))
    }
    
    @ViewBuilder
    private func renderHareketler() -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("Cari Hareketler (Son İşlemler)")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundColor(.white)
                Spacer()
                if isLoadingHareketler {
                    ProgressView().tint(.white).scaleEffect(0.8)
                } else {
                    Text("\(hareketler.count) Kayıt")
                        .font(.system(size: 11))
                        .foregroundColor(Color(hex: "8E8E93"))
                }
            }
            
            VStack(spacing: 0) {
                if hareketler.isEmpty && !isLoadingHareketler {
                    Text("Henüz hareket kaydı bulunmuyor.")
                        .font(.system(size: 12))
                        .foregroundColor(Color(hex: "64748B"))
                        .padding(.vertical, 16)
                        .frame(maxWidth: .infinity, alignment: .center)
                } else {
                    ForEach(Array(hareketler.enumerated()), id: \.element.id) { idx, h in
                        HStack {
                            VStack(alignment: .leading, spacing: 2) {
                                Text("\(h.islemTuru ?? "İşlem") • \(h.aciklama ?? "")")
                                    .font(.system(size: 12, weight: .semibold))
                                    .foregroundColor(.white)
                                    .lineLimit(1)
                                Text("\(String((h.tarih ?? "-").prefix(10))) • \(h.belgeNo ?? "")")
                                    .font(.system(size: 10))
                                    .foregroundColor(Color(hex: "8E8E93"))
                            }
                            
                            Spacer()
                            
                            let isBorc = h.borc > 0
                            let val = isBorc ? h.borc : h.alacak
                            Text("\(isBorc ? "-" : "+")\(AppFormatters.money(val))")
                                .font(.system(size: 13, weight: .bold))
                                .foregroundColor(isBorc ? Color(hex: "EF4444") : Color(hex: "10B981"))
                        }
                        .padding(.vertical, 10)
                        
                        if idx < hareketler.count - 1 {
                            Divider().background(Color.white.opacity(0.06))
                        }
                    }
                }
            }
        }
        .padding(16)
        .background(Color(hex: "121216"))
        .cornerRadius(20)
        .overlay(RoundedRectangle(cornerRadius: 20).stroke(Color.white.opacity(0.08), lineWidth: 1))
    }
    
    @ViewBuilder
    private func renderIletisim() -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("İletişim Bilgileri")
                .font(.system(size: 13, weight: .bold))
                .foregroundColor(.white)
            
            detailRow(icon: "person.circle", text: "Yetkili: \(currentCari.yetkili ?? "-")")
            detailRow(icon: "phone.fill", text: "Telefon: \(currentCari.telefon ?? "-")")
            detailRow(icon: "phone.fill", text: "Cep Telefonu: \(currentCari.gsm ?? "-")")
            detailRow(icon: "envelope.fill", text: "E-Posta: \(currentCari.email ?? "-")")
            detailRow(icon: "mappin.and.ellipse", text: "Adres: \(currentCari.adres ?? "-") \(currentCari.ilce ?? "") / \(currentCari.sehir ?? "")")
            detailRow(icon: "shippingbox.fill", text: "Sevk Adresi: \(currentCari.sevkAdresi ?? "-")")
        }
        .padding(16)
        .background(Color(hex: "121216"))
        .cornerRadius(20)
        .overlay(RoundedRectangle(cornerRadius: 20).stroke(Color.white.opacity(0.08), lineWidth: 1))
    }
    
    @ViewBuilder
    private func renderFinansal() -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Finansal & Vergi Bilgileri")
                .font(.system(size: 13, weight: .bold))
                .foregroundColor(.white)
            
            infoRow(label: "Vergi Dairesi", val: currentCari.vergiDairesi ?? "-")
            infoRow(label: "Vergi No", val: currentCari.vergiNo ?? "-")
            infoRow(label: "TC Kimlik No", val: currentCari.tcKimlikNo ?? "-")
            infoRow(label: "Vade Günü", val: "\(currentCari.vadeGunu ?? 30) Gün")
            infoRow(label: "Ödeme Planı", val: currentCari.odemePlani ?? "Peşin")
            infoRow(label: "Ticaret Sicil No", val: currentCari.ticaretSicilNo ?? "-")
            if let iban = currentCari.iban, !iban.isEmpty {
                infoRow(label: "IBAN", val: iban)
            }
        }
        .padding(16)
        .background(Color(hex: "121216"))
        .cornerRadius(20)
        .overlay(RoundedRectangle(cornerRadius: 20).stroke(Color.white.opacity(0.08), lineWidth: 1))
    }
    
    @ViewBuilder
    private func renderRiskDurum() -> some View {
        let bakiyeVal = currentCari.bakiye
        let limit = currentCari.riskLimiti ?? 50000.0
        let pct = limit > 0 ? min(bakiyeVal / limit, 1.0) : 0.0
        let isCritical = pct > 0.85
        
        VStack(alignment: .leading, spacing: 12) {
            Text("Risk ve Limit Durumu")
                .font(.system(size: 13, weight: .bold))
                .foregroundColor(.white)
            
            HStack {
                Text("Kullanılan Limit")
                    .font(.system(size: 12))
                    .foregroundColor(Color(hex: "8E8E93"))
                Spacer()
                Text("\(AppFormatters.money(bakiyeVal)) / \(AppFormatters.money(limit))")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(.white)
            }
            
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 6)
                        .fill(Color.white.opacity(0.08))
                        .frame(height: 8)
                    RoundedRectangle(cornerRadius: 6)
                        .fill(isCritical ? Color(hex: "EF4444") : Color(hex: "10B981"))
                        .frame(width: max(geo.size.width * CGFloat(pct), 6), height: 8)
                }
            }
            .frame(height: 8)
            
            HStack {
                Text("Doluluk: %\(Int(pct * 100))")
                    .font(.system(size: 11, weight: .bold))
                    .foregroundColor(isCritical ? Color(hex: "EF4444") : Color(hex: "10B981"))
                Spacer()
                Text("Kalan: \(AppFormatters.money(max(0, limit - bakiyeVal)))")
                    .font(.system(size: 11))
                    .foregroundColor(Color(hex: "8E8E93"))
            }
        }
        .padding(16)
        .background(Color(hex: "121216"))
        .cornerRadius(20)
        .overlay(RoundedRectangle(cornerRadius: 20).stroke(Color.white.opacity(0.08), lineWidth: 1))
    }
    
    @ViewBuilder
    private func renderFooterButtons() -> some View {
        HStack(spacing: 12) {
            // Düzenle Butonu
            Button {
                showEditForm = true
            } label: {
                HStack(spacing: 6) {
                    Image(systemName: "square.and.pencil")
                    Text("Düzenle")
                }
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(Color(hex: "2563EB"))
                .cornerRadius(12)
            }
            
            // Sil Butonu
            Button {
                showDeleteConfirm = true
            } label: {
                HStack(spacing: 6) {
                    Image(systemName: "trash.fill")
                    Text("Sil")
                }
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(Color(hex: "EF4444"))
                .cornerRadius(12)
            }
        }
        .padding(.top, 4)
    }
    
    private func actionGridBtn(title: String, iconName: String, color: Color, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Image(systemName: iconName)
                    .font(.system(size: 11, weight: .bold))
                Text(title)
                    .font(.system(size: 11, weight: .bold))
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 10)
            .background(color)
            .cornerRadius(8)
        }
    }
    
    private func detailRow(icon: String, text: String) -> some View {
        HStack(spacing: 10) {
            Image(systemName: icon)
                .font(.system(size: 14))
                .foregroundColor(Color(hex: "64748B"))
                .frame(width: 18)
            Text(text)
                .font(.system(size: 12))
                .foregroundColor(Color(hex: "E2E8F0"))
            Spacer()
        }
    }
    
    private func infoRow(label: String, val: String, valColor: Color = .white) -> some View {
        HStack {
            Text(label)
                .font(.system(size: 12))
                .foregroundColor(Color(hex: "8E8E93"))
            Spacer()
            Text(val)
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(valColor)
        }
    }
    
    // MARK: - Live Supabase Hareketler Çekimi
    private func loadLiveHareketler() async {
        isLoadingHareketler = true
        do {
            let fetched = try await SupabaseService.shared.fetchCariHareketler(cariId: currentCari.id)
            await MainActor.run {
                if !fetched.isEmpty {
                    self.hareketler = fetched
                } else if self.hareketler.isEmpty {
                    // Canlıda henüz kayıt yoksa temiz gösterim
                    self.hareketler = []
                }
                self.isLoadingHareketler = false
            }
        } catch {
            print("[CariDetail] Hareketler çekilemedi: \(error)")
            await MainActor.run {
                self.isLoadingHareketler = false
            }
        }
    }
    
    // MARK: - PDF Ekstre Üretimi & Önizleme (QuestPDF Destekli)
    private func exportEkstre(detayli: Bool) {
        #if canImport(UIKit)
        Task { @MainActor in
            self.isGeneratingPDF = true
            let title = "\(currentCari.unvan) (\(detayli ? "Detaylı Ekstre" : "Hesap Ekstresi"))"
            let pdfData = await PDFService.shared.fetchOrGenerateCariEkstrePDF(
                cari: currentCari,
                hareketler: hareketler,
                detayli: detayli
            )
            self.isGeneratingPDF = false
            if let data = pdfData {
                self.pdfTitle = title
                self.generatedPDFData = data
                self.showPDFModal = true
            }
        }
        #endif
    }
    
    // MARK: - Excel (CSV) Dosya Olarak Dışa Aktarma (Masaüstü Birebir & UTF-8 BOM Destekli)
    private func exportExcel() {
        #if canImport(UIKit)
        // UTF-8 BOM ekleyerek Excel'de Türkçe karakterlerin düzgün açılmasını sağlıyoruz
        let bom = "\u{FEFF}"
        let header = "Tarih;Belge No;İşlem Türü;Açıklama;Borç;Alacak\n"
        let rows = hareketler.map { h in
            "\(h.tarih ?? "");\(h.belgeNo ?? "");\(h.islemTuru ?? "");\(h.aciklama ?? "");\(String(format: "%.2f", h.borc));\(String(format: "%.2f", h.alacak))"
        }.joined(separator: "\n")
        
        let csvContent = bom + header + rows
        
        let safeKod = (currentCari.cariKodu ?? "Cari").replacingOccurrences(of: "/", with: "_")
        let fileName = "Ekstre_\(safeKod)_\(ISO8601DateFormatter().string(from: Date()).prefix(10)).csv"
        let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent(fileName)
        
        do {
            try csvContent.write(to: tempURL, atomically: true, encoding: .utf8)
            let av = UIActivityViewController(activityItems: [tempURL], applicationActivities: nil)
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let rootVC = windowScene.windows.first?.rootViewController {
                if let popover = av.popoverPresentationController {
                    popover.sourceView = rootVC.view
                    popover.sourceRect = CGRect(x: rootVC.view.bounds.midX, y: rootVC.view.bounds.midY, width: 0, height: 0)
                    popover.permittedArrowDirections = []
                }
                rootVC.present(av, animated: true)
            }
        } catch {
            print("CSV dışa aktarım hatası: \(error)")
        }
        #endif
    }
    
    // MARK: - Silme İşlemi (Canlı Supabase & UI)
    private func performDelete() {
        Task {
            do {
                try await SupabaseService.shared.delete(table: "cariler", id: currentCari.id)
            } catch {
                print("[CariDetail] Silme hatası: \(error)")
            }
            await MainActor.run {
                onDelete?(currentCari)
                presentationMode.wrappedValue.dismiss()
            }
        }
    }
}
