import SwiftUI

public struct FaturalarView: View {
    @State private var faturalar: [Fatura] = []
    @State private var searchText: String = ""
    @State private var selectedTab: String = "Tümü"
    @State private var showForm: Bool = false
    @State private var isLoading: Bool = false
    
    private let tabs = ["Tümü", "Satış", "Alış"]
    
    public init() {}
    
    public var filteredFaturalar: [Fatura] {
        faturalar.filter { f in
            let matchSearch = searchText.isEmpty ||
                f.faturaNo.localizedCaseInsensitiveContains(searchText) ||
                (f.cariUnvan?.localizedCaseInsensitiveContains(searchText) ?? false)
            
            if !matchSearch { return false }
            
            if selectedTab == "Satış" {
                return f.faturaTuru.uppercased().contains("SATIS")
            } else if selectedTab == "Alış" {
                return f.faturaTuru.uppercased().contains("ALIS")
            }
            return true
        }
    }
    
    public var toplamCiro: Double {
        filteredFaturalar.reduce(0.0) { $0 + $1.genelToplam }
    }
    
    public var body: some View {
        NavigationStack {
            ZStack {
                AppTheme.background.ignoresSafeArea()
                
                VStack(spacing: 14) {
                    // Header Bar
                    HStack {
                        Text("Faturalar")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(AppTheme.textPrimary)
                        
                        Spacer()
                        
                        Button {
                            showForm = true
                        } label: {
                            Image(systemName: "plus.circle.fill")
                                .font(.system(size: 28))
                                .foregroundColor(AppTheme.primary)
                        }
                    }
                    .padding(.horizontal)
                    .padding(.top, 8)
                    
                    // Search Bar
                    SearchBarView(text: $searchText, placeholder: "Fatura No veya cari unvan ara...")
                        .padding(.horizontal)
                    
                    // Segmented Tabs & Summary
                    HStack {
                        Picker("Tür", selection: $selectedTab) {
                            ForEach(tabs, id: \.self) { tab in
                                Text(tab).tag(tab)
                            }
                        }
                        .pickerStyle(.segmented)
                        
                        Spacer()
                        
                        VStack(alignment: .trailing, spacing: 2) {
                            Text("Toplam Hacim")
                                .font(.system(size: 10, weight: .medium))
                                .foregroundColor(AppTheme.textMuted)
                            Text(AppFormatters.money(toplamCiro))
                                .font(.system(size: 13, weight: .bold))
                                .foregroundColor(AppTheme.textPrimary)
                        }
                    }
                    .padding(.horizontal)
                    
                    // Fatura Listesi
                    if isLoading && faturalar.isEmpty {
                        Spacer()
                        ProgressView().tint(AppTheme.primary)
                        Spacer()
                    } else if filteredFaturalar.isEmpty {
                        Spacer()
                        VStack(spacing: 8) {
                            Image(systemName: "doc.text.magnifyingglass")
                                .font(.system(size: 40))
                                .foregroundColor(AppTheme.textMuted)
                            Text("Fatura bulunamadı")
                                .font(.system(size: 15, weight: .semibold))
                                .foregroundColor(AppTheme.textSecondary)
                        }
                        Spacer()
                    } else {
                        List {
                            ForEach(filteredFaturalar) { fatura in
                                NavigationLink(destination: FaturaDetailView(fatura: fatura)) {
                                    FaturaRowItem(fatura: fatura)
                                }
                                .listRowBackground(Color.clear)
                                .listRowSeparator(.hidden)
                                .listRowInsets(EdgeInsets(top: 4, leading: 16, bottom: 4, trailing: 16))
                            }
                        }
                        .listStyle(.plain)
                        .refreshable {
                            await loadFaturalar()
                        }
                    }
                    
                    Spacer().frame(height: 70)
                }
            }
            .navigationBarHidden(true)
            .sheet(isPresented: $showForm) {
                FaturaFormView { yeniFatura in
                    faturalar.insert(yeniFatura, at: 0)
                }
            }
            .task {
                await loadFaturalar()
            }
        }
    }
    
    private func loadFaturalar() async {
        isLoading = true
        do {
            let items: [Fatura] = try await SupabaseService.shared.fetch(from: "faturalar", orderBy: "tarih.desc")
            await MainActor.run {
                self.faturalar = items
            }
        } catch {
            print("Fatura fetch error: \(error)")
            if faturalar.isEmpty {
                faturalar = [
                    Fatura(faturaNo: "FTR-2026-0012", faturaTuru: "SATIS", cariUnvan: "Ermay Bilişim San. Ltd.", tarih: "02.11.2026", vadeTarihi: "02.12.2026", araToplam: 25000, kdvToplami: 5000, genelToplam: 30000, odemeDurumu: "BEKLIYOR"),
                    Fatura(faturaNo: "FTR-2026-0011", faturaTuru: "ALIS", cariUnvan: "Akıncılar Çelik Döküm A.Ş.", tarih: "01.11.2026", vadeTarihi: "15.11.2026", araToplam: 40000, kdvToplami: 8000, genelToplam: 48000, odemeDurumu: "ODENDI"),
                    Fatura(faturaNo: "FTR-2026-0010", faturaTuru: "SATIS", cariUnvan: "Mega Plastik İth. İhr.", tarih: "28.10.2026", vadeTarihi: "28.11.2026", araToplam: 12500, kdvToplami: 2500, genelToplam: 15000, odemeDurumu: "ODENDI")
                ]
            }
        }
        isLoading = false
    }
}

struct FaturaRowItem: View {
    let fatura: Fatura
    
    var isSatis: Bool {
        fatura.faturaTuru.uppercased().contains("SATIS")
    }
    
    var body: some View {
        GlassCard(cornerRadius: 14, padding: 14) {
            VStack(spacing: 10) {
                HStack {
                    StatusBadge(
                        title: isSatis ? "SATIŞ" : "ALIŞ",
                        color: isSatis ? AppTheme.primary : AppTheme.purple
                    )
                    
                    Text(fatura.faturaNo)
                        .font(.system(size: 13, weight: .bold))
                        .foregroundColor(AppTheme.textPrimary)
                    
                    Spacer()
                    
                    StatusBadge(
                        title: fatura.odemeDurumu == "ODENDI" ? "ÖDENDİ" : "BEKLİYOR",
                        color: fatura.odemeDurumu == "ODENDI" ? AppTheme.success : AppTheme.warning
                    )
                }
                
                HStack(alignment: .bottom) {
                    VStack(alignment: .leading, spacing: 3) {
                        Text(fatura.cariUnvan ?? "Cari Belirtilmemiş")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(AppTheme.textPrimary)
                            .lineLimit(1)
                        
                        Text("Tarih: \(fatura.tarih)  •  Vade: \(fatura.vadeTarihi ?? "-")")
                            .font(.system(size: 11))
                            .foregroundColor(AppTheme.textMuted)
                    }
                    
                    Spacer()
                    
                    Text(AppFormatters.money(fatura.genelToplam))
                        .font(.system(size: 16, weight: .heavy))
                        .foregroundColor(AppTheme.textPrimary)
                }
            }
        }
    }
}

