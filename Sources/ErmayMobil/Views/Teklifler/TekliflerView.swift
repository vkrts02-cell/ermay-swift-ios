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
                    HStack {
                        Text("Teklifler")
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
                    
                    SearchBarView(text: $searchText, placeholder: "Teklif No veya cari ara...")
                        .padding(.horizontal)
                    
                    if isLoading && teklifler.isEmpty {
                        Spacer()
                        ProgressView().tint(AppTheme.primary)
                        Spacer()
                    } else if filteredTeklifler.isEmpty {
                        Spacer()
                        VStack(spacing: 8) {
                            Image(systemName: "doc.text.fill")
                                .font(.system(size: 40))
                                .foregroundColor(AppTheme.textMuted)
                            Text("Teklif bulunamadı")
                                .font(.system(size: 15, weight: .semibold))
                                .foregroundColor(AppTheme.textSecondary)
                        }
                        Spacer()
                    } else {
                        List {
                            ForEach(filteredTeklifler) { teklif in
                                NavigationLink(destination: TeklifDetailView(teklif: teklif)) {
                                    TeklifRowItem(teklif: teklif)
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
                TeklifFormView { yeniTeklif in
                    teklifler.insert(yeniTeklif, at: 0)
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
            let items: [Teklif] = try await SupabaseService.shared.fetch(from: "teklifler", orderBy: "tarih.desc")
            await MainActor.run {
                self.teklifler = items
            }
        } catch {
            print("Teklif fetch error: \(error)")
            if teklifler.isEmpty {
                teklifler = [
                    Teklif(id: "1", teklifNo: "TKL-2026-042", cariUnvan: "Yıldız Lojistik Antrepo", tarih: "02.11.2026", gecerlilikTarihi: "16.11.2026", araToplam: 65000, kdvToplami: 13000, genelToplam: 78000, durum: "GONDERILDI"),
                    Teklif(id: "2", teklifNo: "TKL-2026-041", cariUnvan: "Kaya Metal Döküm", tarih: "29.10.2026", gecerlilikTarihi: "12.11.2026", araToplam: 120000, kdvToplami: 24000, genelToplam: 144000, durum: "ONAYLANDI")
                ]
            }
        }
        isLoading = false
    }
}

struct TeklifRowItem: View {
    let teklif: Teklif
    
    var durumColor: Color {
        switch teklif.durum {
        case "ONAYLANDI": return AppTheme.success
        case "GONDERILDI": return AppTheme.primary
        case "REDDEDILDI": return AppTheme.danger
        default: return AppTheme.warning
        }
    }
    
    var body: some View {
        GlassCard(cornerRadius: 14, padding: 14) {
            VStack(spacing: 8) {
                HStack {
                    Text(teklif.teklifNo)
                        .font(.system(size: 13, weight: .bold))
                        .foregroundColor(AppTheme.textPrimary)
                    Spacer()
                    StatusBadge(title: teklif.durum, color: durumColor)
                }
                
                HStack(alignment: .bottom) {
                    VStack(alignment: .leading, spacing: 3) {
                        Text(teklif.cariUnvan ?? "Cari Belirtilmemiş")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(AppTheme.textPrimary)
                        Text("Geçerlilik: \(teklif.gecerlilikTarihi ?? "-")")
                            .font(.system(size: 11))
                            .foregroundColor(AppTheme.textMuted)
                    }
                    Spacer()
                    Text(AppFormatters.money(teklif.genelToplam))
                        .font(.system(size: 16, weight: .heavy))
                        .foregroundColor(AppTheme.textPrimary)
                }
            }
        }
    }
}

