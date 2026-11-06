import SwiftUI

public struct SiparislerView: View {
    @State private var siparisler: [Siparis] = []
    @State private var searchText: String = ""
    @State private var showForm: Bool = false
    @State private var selectedSiparis: Siparis? = nil
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
                    HStack(spacing: 8) {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(Color(hex: "94A3B8"))
                        TextField("Cari veya sipariş no ara...", text: $searchText)
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
                                Button {
                                    selectedSiparis = siparis
                                } label: {
                                    ExactSiparisCard(siparis: siparis)
                                }
                                .buttonStyle(.plain)
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
                .enableSwipeBack()
            }
            .sheet(item: $selectedSiparis) { sip in
                SiparisDetailView(siparis: sip)
                    .enableSwipeBack()
            }
            .task {
                await loadSiparisler()
            }
            .onReceive(NotificationCenter.default.publisher(for: .supabaseRealtimeDataChanged)) { _ in
                Task {
                    await loadSiparisler()
                }
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
                self.siparisler = []
            }
        }
        isLoading = false
    }
}

// MARK: - ExactSiparisCard (Exact match to SiparislerScreen.tsx)
public struct ExactSiparisCard: View {
    public let siparis: Siparis
    
    public init(siparis: Siparis) {
        self.siparis = siparis
    }
    
    private var durumColor: Color {
        switch siparis.durum.uppercased() {
        case "FATURALANDI", "FATURALANDIRILDI", "TAMAMLANDI":
            return Color(hex: "10B981")
        case "IPTAL", "İPTAL", "REDDEDILDI":
            return Color(hex: "EF4444")
        default:
            return Color(hex: "F59E0B")
        }
    }
    
    public var body: some View {
        HStack(alignment: .center, spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text(siparis.cariUnvan ?? "Cari Belirtilmedi")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.white)
                    .lineLimit(1)
                
                Text("Sipariş No: \(siparis.siparisNo)")
                    .font(.system(size: 11))
                    .foregroundColor(Color(hex: "94A3B8"))
                
                Text("Tarih: \(siparis.tarih) • Teslimat: \(siparis.teslimTarihi ?? "-")")
                    .font(.system(size: 11))
                    .foregroundColor(Color(hex: "64748B"))
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 4) {
                Text(AppFormatters.money(siparis.genelToplam))
                    .font(.system(size: 14, weight: .heavy))
                    .foregroundColor(.white)
                
                Text(siparis.durum)
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
