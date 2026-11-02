import SwiftUI

public struct SiparislerView: View {
    @State private var siparisler: [Siparis] = []
    @State private var searchText: String = ""
    @State private var showForm: Bool = false
    @State private var isLoading: Bool = false
    
    public init() {}
    
    public var filteredSiparisler: [Siparis] {
        siparisler.filter { s in
            searchText.isEmpty ||
                s.siparisNo.localizedCaseInsensitiveContains(searchText) ||
                (s.cariUnvan?.localizedCaseInsensitiveContains(searchText) ?? false)
        }
    }
    
    public var body: some View {
        NavigationStack {
            ZStack {
                AppTheme.background.ignoresSafeArea()
                
                VStack(spacing: 14) {
                    // Header Bar (Exact match to SiparislerScreen.tsx)
                    HStack {
                        Text("Sipariş Yönetimi")
                            .font(.system(size: 24, weight: .black))
                            .foregroundColor(AppTheme.textPrimary)
                        
                        Spacer()
                        
                        Button {
                            showForm = true
                        } label: {
                            HStack(spacing: 6) {
                                Image(systemName: "plus")
                                Text("Yeni Sipariş")
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
                    SearchBarView(text: $searchText, placeholder: "Cari veya sipariş no ara...")
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
                                    ExactSiparisCard(siparis: siparis)
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
                SiparisFormView { newSip in
                    siparisler.insert(newSip, at: 0)
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
            let items: [Siparis] = try await SupabaseService.shared.fetch(from: "siparisler")
            await MainActor.run {
                self.siparisler = items
            }
        } catch {
            await MainActor.run {
                self.siparisler = [
                    Siparis(siparisNo: "SIP-842910", siparisTuru: "ALINAN", cariId: "1", cariUnvan: "Ermay Bilişim Ltd. Şti.", tarih: "2026-11-01", teslimTarihi: "2026-11-08", genelToplam: 48500.0, durum: "Bekliyor"),
                    Siparis(siparisNo: "SIP-529104", siparisTuru: "ALINAN", cariId: "2", cariUnvan: "Akıncılar Çelik Döküm", tarih: "2026-10-28", teslimTarihi: "2026-11-04", genelToplam: 112000.0, durum: "Faturalandı"),
                    Siparis(siparisNo: "SIP-194025", siparisTuru: "VERILEN", cariId: "3", cariUnvan: "Mega Plastik San.", tarih: "2026-10-25", teslimTarihi: "2026-10-30", genelToplam: 16400.0, durum: "İptal")
                ]
            }
        }
        isLoading = false
    }
}

struct ExactSiparisCard: View {
    let siparis: Siparis
    
    var durumColor: Color {
        switch siparis.durum {
        case "Faturalandı":
            return Color(hex: "10B981")
        case "İptal":
            return Color(hex: "EF4444")
        default:
            return Color(hex: "F59E0B")
        }
    }
    
    var body: some View {
        GlassCard(cornerRadius: 14, padding: 14) {
            HStack(alignment: .center) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(siparis.cariUnvan ?? "İsimsiz Cari")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(AppTheme.textPrimary)
                        .lineLimit(1)
                    
                    Text("Sipariş No: \(siparis.siparisNo)")
                        .font(.system(size: 12))
                        .foregroundColor(AppTheme.textSecondary)
                    
                    Text("Tarih: \(siparis.tarih) • Teslimat: \(siparis.teslimTarihi)")
                        .font(.system(size: 11))
                        .foregroundColor(AppTheme.textMuted)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text(AppFormatters.money(siparis.genelToplam))
                        .font(.system(size: 14, weight: .heavy))
                        .foregroundColor(AppTheme.textPrimary)
                    
                    Text(siparis.durum)
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(durumColor)
                }
            }
        }
    }
}
