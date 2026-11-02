import SwiftUI

public struct TekliflerView: View {
    @State private var teklifler: [Teklif] = []
    @State private var searchText: String = ""
    @State private var showForm: Bool = false
    @State private var selectedTeklif: Teklif? = nil
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
                            .background(Color(hex: "0061FF"))
                            .cornerRadius(10)
                        }
                    }
                    .padding(.horizontal)
                    .padding(.top, 8)
                    
                    // Search Bar
                    HStack(spacing: 8) {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(Color(hex: "94A3B8"))
                        TextField("Cari veya teklif no ara...", text: $searchText)
                            .foregroundColor(.white)
                            .font(.system(size: 14))
                        if !searchText.isEmpty {
                            Button {
                                searchText = ""
                            } label: {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundColor(Color(hex: "94A3B8"))
                            }
                        }
                    }
                    .padding(12)
                    .background(Color(hex: "121216"))
                    .cornerRadius(12)
                    .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.white.opacity(0.08), lineWidth: 1))
                    .padding(.horizontal)
                    
                    if isLoading && teklifler.isEmpty {
                        Spacer()
                        ProgressView().tint(AppTheme.primary)
                        Spacer()
                    } else if filteredTeklifler.isEmpty {
                        Spacer()
                        VStack(spacing: 8) {
                            Image(systemName: "tag.slash.fill")
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
                                Button {
                                    selectedTeklif = teklif
                                } label: {
                                    ExactTeklifCard(teklif: teklif)
                                }
                                .buttonStyle(.plain)
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
                TeklifFormView { newTek in
                    teklifler.insert(newTek, at: 0)
                }
                .enableSwipeBack()
            }
            .sheet(item: $selectedTeklif) { tek in
                TeklifDetailView(teklif: tek)
                    .enableSwipeBack()
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
                    Teklif(teklifNo: "TKF-102948", cariId: "1", cariUnvan: "Ermay Bilişim Ltd. Şti.", tarih: "2026-11-02", gecerlilikTarihi: "2026-11-17", genelToplam: 64200.0, durum: "Bekliyor"),
                    Teklif(teklifNo: "TKF-849201", cariId: "2", cariUnvan: "Akıncılar Çelik Döküm", tarih: "2026-10-29", gecerlilikTarihi: "2026-11-13", genelToplam: 89000.0, durum: "Siparişleşti"),
                    Teklif(teklifNo: "TKF-391024", cariId: "3", cariUnvan: "Kaya Metal A.Ş.", tarih: "2026-10-22", gecerlilikTarihi: "2026-11-05", genelToplam: 21500.0, durum: "Reddedildi")
                ]
            }
        }
        isLoading = false
    }
}

// MARK: - ExactTeklifCard (Exact match to TekliflerScreen.tsx)
public struct ExactTeklifCard: View {
    public let teklif: Teklif
    
    public init(teklif: Teklif) {
        self.teklif = teklif
    }
    
    private var durumColor: Color {
        switch teklif.durum.uppercased() {
        case "SIPARISLESTI", "SİPARİŞLEŞTİ", "ONAYLANDI", "KABUL":
            return Color(hex: "10B981")
        case "RED", "REDDEDILDI", "REDDEDİLDİ", "IPTAL":
            return Color(hex: "EF4444")
        default:
            return Color(hex: "F59E0B")
        }
    }
    
    public var body: some View {
        HStack(alignment: .center, spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text(teklif.cariUnvan ?? "Cari Belirtilmedi")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.white)
                    .lineLimit(1)
                
                Text("Teklif No: \(teklif.teklifNo)")
                    .font(.system(size: 11))
                    .foregroundColor(Color(hex: "94A3B8"))
                
                Text("Tarih: \(teklif.tarih) • Geçerlilik: \(teklif.gecerlilikTarihi ?? "-")")
                    .font(.system(size: 11))
                    .foregroundColor(Color(hex: "64748B"))
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 4) {
                Text(AppFormatters.money(teklif.genelToplam))
                    .font(.system(size: 14, weight: .heavy))
                    .foregroundColor(.white)
                
                Text(teklif.durum)
                    .font(.system(size: 10, weight: .bold))
                    .foregroundColor(durumColor)
                    .textCase(.uppercase)
            }
        }
        .padding(16)
        .background(Color(hex: "0F0F0F"))
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.white.opacity(0.08), lineWidth: 1)
        )
    }
}
