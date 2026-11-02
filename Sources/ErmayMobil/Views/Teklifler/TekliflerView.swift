import SwiftUI

public struct TekliflerView: View {
    @State private var teklifler: [Teklif] = []
    @State private var searchText: String = ""
    @State private var showForm: Bool = false
    @State private var isLoading: Bool = false
    
    public init() {}
    
    public var filteredTeklifler: [Teklif] {
        teklifler.filter { t in
            searchText.isEmpty ||
                t.teklifNo.localizedCaseInsensitiveContains(searchText) ||
                (t.cariUnvan?.localizedCaseInsensitiveContains(searchText) ?? false)
        }
    }
    
    public var body: some View {
        NavigationStack {
            ZStack {
                AppTheme.background.ignoresSafeArea()
                
                VStack(spacing: 14) {
                    // Header Bar (Exact match to TekliflerScreen.tsx)
                    HStack {
                        Text("Fiyat Teklifleri")
                            .font(.system(size: 24, weight: .black))
                            .foregroundColor(AppTheme.textPrimary)
                        
                        Spacer()
                        
                        Button {
                            showForm = true
                        } label: {
                            HStack(spacing: 6) {
                                Image(systemName: "plus")
                                Text("Yeni Teklif")
                            }
                            .font(.system(size: 13, weight: .bold))
                            .foregroundColor(.white)
                            .padding(.horizontal, 14)
                            .padding(.vertical, 8)
                            .background(Color(hex: "BF5AF2"))
                            .cornerRadius(10)
                        }
                    }
                    .padding(.horizontal)
                    .padding(.top, 8)
                    
                    // Search Bar
                    SearchBarView(text: $searchText, placeholder: "Cari veya teklif no ara...")
                        .padding(.horizontal)
                    
                    if isLoading && teklifler.isEmpty {
                        Spacer()
                        ProgressView().tint(AppTheme.primary)
                        Spacer()
                    } else if filteredTeklifler.isEmpty {
                        Spacer()
                        VStack(spacing: 8) {
                            Image(systemName: "doc.badge.arrow.up")
                                .font(.system(size: 40))
                                .foregroundColor(AppTheme.textMuted)
                            Text("Fiyat teklifi bulunamadı")
                                .font(.system(size: 15, weight: .semibold))
                                .foregroundColor(AppTheme.textSecondary)
                        }
                        Spacer()
                    } else {
                        List {
                            ForEach(filteredTeklifler) { teklif in
                                NavigationLink(destination: TeklifDetailView(teklif: teklif)) {
                                    ExactTeklifCard(teklif: teklif)
                                }
                                .listRowBackground(Color.clear)
                                .listRowSeparator(.hidden)
                                .listRowInsets(EdgeInsets(top: 4, leading: 16, bottom: 4, trailing: 16))
                            }
                        }
                        .listStyle(.plain)
                        .refreshable {
                            await loadTeklifler()
                        }
                    }
                    
                    Spacer().frame(height: 70)
                }
            }
            .navigationBarHidden(true)
            .sheet(isPresented: $showForm) {
                TeklifFormView { newTeklif in
                    teklifler.insert(newTeklif, at: 0)
                }
            }
            .task {
                await loadTeklifler()
            }
        }
    }
    
    private func loadTeklifler() async {
        isLoading = true
        do {
            let items: [Teklif] = try await SupabaseService.shared.fetch(from: "teklifler")
            await MainActor.run {
                self.teklifler = items
            }
        } catch {
            await MainActor.run {
                self.teklifler = [
                    Teklif(teklifNo: "TKF-391048", cariId: "1", cariUnvan: "Ermay Bilişim Ltd. Şti.", tarih: "2026-11-01", gecerlilikTarihi: "2026-11-15", durum: "Bekliyor", genelToplam: 62000.0),
                    Teklif(teklifNo: "TKF-810294", cariId: "2", cariUnvan: "Kaya Metal A.Ş.", tarih: "2026-10-29", gecerlilikTarihi: "2026-11-12", durum: "Siparişleşti", genelToplam: 84500.0),
                    Teklif(teklifNo: "TKF-492019", cariId: "3", cariUnvan: "Yıldız Lojistik", tarih: "2026-10-20", gecerlilikTarihi: "2026-11-03", durum: "Reddedildi", genelToplam: 19800.0)
                ]
            }
        }
        isLoading = false
    }
}

struct ExactTeklifCard: View {
    let teklif: Teklif
    
    var durumColor: Color {
        switch teklif.durum {
        case "Siparişleşti":
            return Color(hex: "10B981")
        case "Reddedildi":
            return Color(hex: "EF4444")
        default:
            return Color(hex: "F59E0B")
        }
    }
    
    var body: some View {
        GlassCard(cornerRadius: 14, padding: 14) {
            HStack(alignment: .center) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(teklif.cariUnvan ?? "İsimsiz Cari")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(AppTheme.textPrimary)
                        .lineLimit(1)
                    
                    Text("Teklif No: \(teklif.teklifNo)")
                        .font(.system(size: 12))
                        .foregroundColor(AppTheme.textSecondary)
                    
                    Text("Tarih: \(teklif.tarih) • Geçerlilik: \(teklif.gecerlilikTarihi)")
                        .font(.system(size: 11))
                        .foregroundColor(AppTheme.textMuted)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text(AppFormatters.money(teklif.genelToplam))
                        .font(.system(size: 14, weight: .heavy))
                        .foregroundColor(AppTheme.textPrimary)
                    
                    Text(teklif.durum)
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(durumColor)
                }
            }
        }
    }
}
