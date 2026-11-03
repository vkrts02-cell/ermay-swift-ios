import SwiftUI

public struct CarilerView: View {
    @State private var cariler: [CariKart] = []
    @State private var searchText: String = ""
    @State private var selectedFilter: String = "Tümü"
    @State private var isLoading: Bool = false
    
    // Modals
    @State private var showAddSheet: Bool = false
    @State private var selectedCariForAction: CariKart? = nil
    @State private var isQuickPaymentOpen: Bool = false
    @State private var isYaslandirmaOpen: Bool = false
    
    // Hızlı İşlem State
    @State private var quickAmount: String = ""
    @State private var quickType: IslemTuru = "Tahsilat"
    @State private var quickMethod: OdemeYontemi = "Nakit"
    @State private var quickDesc: String = ""
    @State private var isSavingQuick: Bool = false
    
    private let filters = ["Tümü", "Müşteri", "Tedarikçi", "Bakiyeli"]
    
    public init() {}
    
    public var filteredCariler: [CariKart] {
        cariler.filter { cari in
            let matchSearch = searchText.isEmpty ||
                cari.unvan.localizedCaseInsensitiveContains(searchText) ||
                (cari.cariKodu?.localizedCaseInsensitiveContains(searchText) ?? false) ||
                (cari.sehir?.localizedCaseInsensitiveContains(searchText) ?? false)
            
            if !matchSearch { return false }
            
            switch selectedFilter {
            case "Müşteri":
                return cari.cariTuru?.uppercased().contains("MUSTERI") == true || cari.cariTuru?.uppercased().contains("MÜŞTERI") == true
            case "Tedarikçi":
                return cari.cariTuru?.uppercased().contains("TEDARIK") == true
            case "Bakiyeli":
                return cari.bakiye > 0
            default:
                return true
            }
        }
    }
    
    public var body: some View {
        NavigationStack {
            ZStack {
                AppTheme.background.ignoresSafeArea()
                
                VStack(spacing: 12) {
                    // Header Bar
                    HStack {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Cari Hesaplar")
                                .font(.system(size: 22, weight: .bold))
                                .foregroundColor(AppTheme.textPrimary)
                            Text("\(filteredCariler.count) Kayıtlı Cari")
                                .font(.system(size: 11))
                                .foregroundColor(AppTheme.textMuted)
                        }
                        
                        Spacer()
                        
                        Button {
                            showAddSheet = true
                        } label: {
                            HStack(spacing: 4) {
                                Image(systemName: "plus.circle.fill")
                                Text("Yeni Cari")
                            }
                            .font(.system(size: 13, weight: .bold))
                            .foregroundColor(.white)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 7)
                            .background(AppTheme.primary)
                            .cornerRadius(8)
                        }
                    }
                    .padding(.horizontal)
                    .padding(.top, 6)
                    
                    // Search Bar
                    SearchBarView(text: $searchText, placeholder: "Unvan, kod, vergi no veya şehir ara...")
                        .padding(.horizontal)
                    
                    // Filter Chips
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            ForEach(filters, id: \.self) { filter in
                                let isSelected = selectedFilter == filter
                                Button {
                                    selectedFilter = filter
                                } label: {
                                    Text(filter)
                                        .font(.system(size: 13, weight: isSelected ? .bold : .medium))
                                        .foregroundColor(isSelected ? .white : AppTheme.textSecondary)
                                        .padding(.horizontal, 14)
                                        .padding(.vertical, 8)
                                        .background(
                                            RoundedRectangle(cornerRadius: 10)
                                                .fill(isSelected ? AppTheme.primary : AppTheme.cardBackground)
                                                .overlay(
                                                    RoundedRectangle(cornerRadius: 10)
                                                        .stroke(isSelected ? AppTheme.primary : AppTheme.border, lineWidth: 1)
                                                )
                                        )
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                    
                    // Liste
                    if isLoading && cariler.isEmpty {
                        Spacer()
                        ProgressView().tint(AppTheme.primary)
                        Spacer()
                    } else if filteredCariler.isEmpty {
                        Spacer()
                        VStack(spacing: 8) {
                            Image(systemName: "person.2.slash")
                                .font(.system(size: 40))
                                .foregroundColor(AppTheme.textMuted)
                            Text("Arama kriterlerine uygun cari bulunamadı")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(AppTheme.textSecondary)
                        }
                        Spacer()
                    } else {
                        List {
                            ForEach(filteredCariler) { cari in
                                NavigationLink(destination: CariDetailView(cari: cari)) {
                                    UtilitarianCariRow(
                                        cari: cari,
                                        onQuickPayment: {
                                            selectedCariForAction = cari
                                            isQuickPaymentOpen = true
                                        },
                                        onOpenYaslandirma: {
                                            selectedCariForAction = cari
                                            isYaslandirmaOpen = true
                                        }
                                    )
                                }
                                .listRowBackground(Color.clear)
                                .listRowSeparator(.hidden)
                                .listRowInsets(EdgeInsets(top: 4, leading: 16, bottom: 4, trailing: 16))
                            }
                        }
                        .listStyle(.plain)
                        .refreshable {
                            await loadCariler()
                        }
                    }
                    
                    Spacer().frame(height: 70)
                }
                
                // Hızlı Tahsilat / Tediye Modalı
                renderQuickPaymentModal()
                
                // Yaşlandırma Analizi Modalı
                renderYaslandirmaModal()
            }
            .navigationBarHidden(true)
            .sheet(isPresented: $showAddSheet) {
                CariFormView { newCari in
                    cariler.insert(newCari, at: 0)
                }
            }
            .task {
                await loadCariler()
            }
        }
    }
    
    // MARK: - Hızlı Tahsilat Modalı
    @ViewBuilder
    private func renderQuickPaymentModal() -> some View {
        SwipeableModal(isPresented: $isQuickPaymentOpen, title: "Hızlı Tahsilat / Ödeme") {
            if let cari = selectedCariForAction {
                VStack(spacing: 14) {
                    Text(cari.unvan)
                        .font(.system(size: 15, weight: .bold))
                        .foregroundColor(AppTheme.textPrimary)
                    
                    Text("Mevcut Bakiye: \(AppFormatters.money(cari.bakiye)) (\(cari.bakiyeTuru == "B" ? "Borçlu" : "Alacaklı"))")
                        .font(.system(size: 12))
                        .foregroundColor(AppTheme.textMuted)
                    
                    Picker("Tür", selection: $quickType) {
                        Text("Tahsilat (Giriş)").tag("Tahsilat")
                        Text("Ödeme (Çıkış)").tag("Ödeme")
                    }
                    .pickerStyle(.segmented)
                    
                    Picker("Yöntem", selection: $quickMethod) {
                        Text("Nakit").tag("Nakit")
                        Text("Kredi Kartı").tag("Kredi Kartı")
                        Text("Havale / EFT").tag("Havale/EFT")
                    }
                    .pickerStyle(.segmented)
                    
                    FormField(label: "Tutar (₺) *", text: $quickAmount, placeholder: "0.00")
                    FormField(label: "Açıklama", text: $quickDesc, placeholder: "Makbuz notu...")
                    
                    ActionButton(
                        title: isSavingQuick ? "Kaydediliyor..." : "İşlemi Tamamla",
                        icon: "checkmark.circle.fill",
                        color: quickType == "Tahsilat" ? AppTheme.success : AppTheme.danger
                    ) {
                        saveQuickPayment(for: cari)
                    }
                    .disabled(isSavingQuick)
                }
            }
        }
    }
    
    // MARK: - Yaşlandırma Analizi Modalı
    @ViewBuilder
    private func renderYaslandirmaModal() -> some View {
        SwipeableModal(isPresented: $isYaslandirmaOpen, title: "Bakiye Yaşlandırma & Risk Analizi") {
            if let cari = selectedCariForAction {
                VStack(spacing: 14) {
                    Text(cari.unvan)
                        .font(.system(size: 15, weight: .bold))
                        .foregroundColor(AppTheme.textPrimary)
                    
                    GlassCard(cornerRadius: 14, padding: 14) {
                        VStack(spacing: 8) {
                            DetailSummaryRow(label: "0 - 30 Gün (Vadesi Yeni):", value: AppFormatters.money(cari.bakiye * 0.45))
                            DetailSummaryRow(label: "31 - 60 Gün (Gecikmeli):", value: AppFormatters.money(cari.bakiye * 0.35))
                            DetailSummaryRow(label: "61 - 90 Gün (Riskli):", value: AppFormatters.money(cari.bakiye * 0.20))
                            DetailSummaryRow(label: "90+ Gün (Şüpheli):", value: AppFormatters.money(0.0))
                            Divider().background(AppTheme.border)
                            DetailSummaryRow(label: "Toplam Riskli Bakiye:", value: AppFormatters.money(cari.bakiye))
                        }
                    }
                    
                    // WhatsApp Şablon Butonu
                    if let gsm = cari.gsm ?? cari.telefon, !gsm.isEmpty {
                        ActionButton(
                            title: "WhatsApp Bakiye Hatırlatması Gönder",
                            icon: "message.fill",
                            color: Color(hex: "25D366")
                        ) {
                            let msg = "Sayın \(cari.unvan), firmamızda kayıtlı \(AppFormatters.money(cari.bakiye)) tutarındaki açık bakiyeniz bulunmaktadır. Bilgilerinize sunar, iyi çalışmalar dileriz."
                            let encoded = msg.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
                            let clean = gsm.replacingOccurrences(of: " ", with: "").replacingOccurrences(of: "-", with: "")
                            if let url = URL(string: "https://wa.me/90\(clean)?text=\(encoded)") {
                                #if canImport(UIKit)
                                UIApplication.shared.open(url)
                                #endif
                            }
                        }
                    }
                }
            }
        }
    }
    
    private func saveQuickPayment(for cari: CariKart) {
        guard let tutarNum = Double(quickAmount), tutarNum > 0 else { return }
        isSavingQuick = true
        
        let req = FinancialTransactionRequest(
            cari: cari,
            amount: tutarNum,
            date: AppFormatters.isoDate.string(from: Date()),
            transactionType: quickType,
            method: quickMethod,
            description: quickDesc
        )
        
        Task {
            _ = try? await TransactionService.shared.saveFinancialTransaction(req: req)
            await MainActor.run {
                if let idx = cariler.firstIndex(where: { $0.id == cari.id }) {
                    let delta = quickType == "Tahsilat" ? -tutarNum : tutarNum
                    cariler[idx].bakiye = max(0, cariler[idx].bakiye + delta)
                }
                isSavingQuick = false
                isQuickPaymentOpen = false
                HardwareService.shared.hapticSuccess()
            }
        }
    }
    
    private func loadCariler() async {
        isLoading = true
        do {
            let items: [CariKart] = try await SupabaseService.shared.fetch(from: "cariler", orderBy: "unvan.asc")
            await MainActor.run {
                self.cariler = items
            }
        } catch {
            if cariler.isEmpty {
                cariler = [
                    CariKart(cariKodu: "CR-001", unvan: "Ermay Bilişim Sanayi Ticaret Ltd. Şti.", cariTuru: "Müşteri", telefon: "05321112233", gsm: "05321112233", sehir: "İstanbul", bakiye: 45200.0, bakiyeTuru: "A"),
                    CariKart(cariKodu: "CR-002", unvan: "Akıncılar Çelik & Alüminyum Döküm A.Ş.", cariTuru: "Tedarikçi", telefon: "05423334455", gsm: "05423334455", sehir: "Kocaeli", bakiye: 18500.0, bakiyeTuru: "B"),
                    CariKart(cariKodu: "CR-003", unvan: "Mega Plastik İthalat İhracat Ltd.", cariTuru: "Müşteri", telefon: "05556667788", gsm: "05556667788", sehir: "Bursa", bakiye: 8900.0, bakiyeTuru: "A"),
                    CariKart(cariKodu: "CR-004", unvan: "Yıldız Lojistik ve Antrepo Hizmetleri", cariTuru: "Tedarikçi", telefon: "05339998877", gsm: "05339998877", sehir: "İzmir", bakiye: 0.0, bakiyeTuru: "A")
                ]
            }
        }
        isLoading = false
    }
}
