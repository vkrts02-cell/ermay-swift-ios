import SwiftUI

public struct SiparislerView: View {
    @State private var siparisler: [Siparis] = []
    @State private var searchText: String = ""
    @State private var selectedTab: String = "Tümü"
    @State private var showForm: Bool = false
    @State private var isLoading: Bool = false
    
    private let tabs = ["Tümü", "Alınan", "Verilen"]
    
    public init() {}
    
    public var filteredSiparisler: [Siparis] {
        siparisler.filter { s in
            let matchSearch = searchText.isEmpty ||
                s.siparisNo.localizedCaseInsensitiveContains(searchText) ||
                (s.cariUnvan?.localizedCaseInsensitiveContains(searchText) ?? false)
            
            if !matchSearch { return false }
            
            if selectedTab == "Alınan" {
                return s.siparisTuru.uppercased().contains("ALINAN")
            } else if selectedTab == "Verilen" {
                return s.siparisTuru.uppercased().contains("VERILEN")
            }
            return true
        }
    }
    
    public var body: some View {
        NavigationStack {
            ZStack {
                AppTheme.background.ignoresSafeArea()
                
                VStack(spacing: 14) {
                    HStack {
                        Text("Siparişler")
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
                    
                    SearchBarView(text: $searchText, placeholder: "Sipariş No veya cari ara...")
                        .padding(.horizontal)
                    
                    Picker("Tür", selection: $selectedTab) {
                        ForEach(tabs, id: \.self) { tab in
                            Text(tab).tag(tab)
                        }
                    }
                    .pickerStyle(.segmented)
                    .padding(.horizontal)
                    
                    if isLoading && siparisler.isEmpty {
                        Spacer()
                        ProgressView().tint(AppTheme.primary)
                        Spacer()
                    } else if filteredSiparisler.isEmpty {
                        Spacer()
                        VStack(spacing: 8) {
                            Image(systemName: "bag.badge.questionmark")
                                .font(.system(size: 40))
                                .foregroundColor(AppTheme.textMuted)
                            Text("Sipariş bulunamadı")
                                .font(.system(size: 15, weight: .semibold))
                                .foregroundColor(AppTheme.textSecondary)
                        }
                        Spacer()
                    } else {
                        List {
                            ForEach(filteredSiparisler) { siparis in
                                NavigationLink(destination: SiparisDetailView(siparis: siparis)) {
                                    SiparisRowItem(siparis: siparis)
                                }
                                .listRowBackground(Color.clear)
                                .listRowSeparator(.hidden)
                                .listRowInsets(EdgeInsets(top: 4, leading: 16, bottom: 4, trailing: 16))
                            }
                        }
                        .listStyle(.plain)
                        .refreshable {
                            await loadSiparisler()
                        }
                    }
                    
                    Spacer().frame(height: 70)
                }
            }
            .navigationBarHidden(true)
            .sheet(isPresented: $showForm) {
                SiparisFormView { yeniSiparis in
                    siparisler.insert(yeniSiparis, at: 0)
                }
            }
            .task {
                await loadSiparisler()
            }
        }
    }
    
    private func loadSiparisler() async {
        isLoading = true
        do {
            let items: [Siparis] = try await SupabaseService.shared.fetch(from: "siparisler", orderBy: "tarih.desc")
            await MainActor.run {
                self.siparisler = items
            }
        } catch {
            print("Siparis fetch error: \(error)")
            if siparisler.isEmpty {
                siparisler = [
                    Siparis(id: "1", siparisNo: "SIP-2026-088", siparisTuru: "ALINAN", cariUnvan: "Ermay Ltd. Şti.", tarih: "02.11.2026", teslimTarihi: "05.11.2026", araToplam: 18000, kdvToplami: 3600, iskontoToplami: 0, genelToplam: 21600, durum: "HAZIRLANIYOR"),
                    Siparis(id: "2", siparisNo: "SIP-2026-087", siparisTuru: "VERILEN", cariUnvan: "Akıncılar Çelik Döküm", tarih: "01.11.2026", teslimTarihi: "10.11.2026", araToplam: 32000, kdvToplami: 6400, iskontoToplami: 0, genelToplam: 38400, durum: "BEKLIYOR")
                ]
            }
        }
        isLoading = false
    }
}

struct SiparisRowItem: View {
    let siparis: Siparis
    
    var durumColor: Color {
        switch siparis.durum {
        case "TAMAMLANDI": return AppTheme.success
        case "HAZIRLANIYOR": return AppTheme.primary
        case "SEVK_EDILDI": return AppTheme.purple
        case "IPTAL": return AppTheme.danger
        default: return AppTheme.warning
        }
    }
    
    var body: some View {
        GlassCard(cornerRadius: 14, padding: 14) {
            VStack(spacing: 8) {
                HStack {
                    StatusBadge(
                        title: siparis.siparisTuru == "ALINAN" ? "ALINAN SİPARİŞ" : "VERİLEN SİPARİŞ",
                        color: siparis.siparisTuru == "ALINAN" ? AppTheme.primary : AppTheme.purple
                    )
                    
                    Text(siparis.siparisNo)
                        .font(.system(size: 13, weight: .bold))
                        .foregroundColor(AppTheme.textPrimary)
                    
                    Spacer()
                    
                    StatusBadge(title: siparis.durum, color: durumColor)
                }
                
                HStack(alignment: .bottom) {
                    VStack(alignment: .leading, spacing: 3) {
                        Text(siparis.cariUnvan ?? "Cari Belirtilmemiş")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(AppTheme.textPrimary)
                            .lineLimit(1)
                        
                        Text("Teslim: \(siparis.teslimTarihi ?? "-")")
                            .font(.system(size: 11))
                            .foregroundColor(AppTheme.textMuted)
                    }
                    
                    Spacer()
                    
                    Text(AppFormatters.money(siparis.genelToplam))
                        .font(.system(size: 16, weight: .heavy))
                        .foregroundColor(AppTheme.textPrimary)
                }
            }
        }
    }
}

