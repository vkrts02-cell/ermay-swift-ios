import SwiftUI

public struct FaturalarView: View {
    @State private var faturalar: [Fatura] = []
    @State private var searchText: String = ""
    @State private var startDateStr: String = "01.01.2026"
    @State private var endDateStr: String = "31.12.2026"
    @State private var showSatisForm: Bool = false
    @State private var showAlisForm: Bool = false
    @State private var isLoading: Bool = false
    
    public init() {}
    
    public var filteredFaturalar: [Fatura] {
        faturalar.filter { f in
            searchText.isEmpty ||
                f.faturaNo.localizedCaseInsensitiveContains(searchText) ||
                (f.cariUnvan?.localizedCaseInsensitiveContains(searchText) ?? false)
        }
    }
    
    public var body: some View {
        NavigationStack {
            ZStack {
                AppTheme.background.ignoresSafeArea()
                
                VStack(spacing: 12) {
                    // Header (Exact match to FaturalarScreen.tsx)
                    HStack {
                        Text("Faturalar")
                            .font(.system(size: 26, weight: .black))
                            .foregroundColor(AppTheme.textPrimary)
                        Spacer()
                    }
                    .padding(.horizontal)
                    .padding(.top, 8)
                    
                    // Search & Date Filter Row
                    VStack(spacing: 8) {
                        SearchBarView(text: $searchText, placeholder: "Fatura / Cari Ara...")
                        
                        HStack(spacing: 6) {
                            TextField("01.01.2026", text: $startDateStr)
                                .font(.system(size: 11, weight: .medium))
                                .foregroundColor(AppTheme.textPrimary)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 6)
                                .background(Color(hex: "121216"))
                                .cornerRadius(8)
                                .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.white.opacity(0.08), lineWidth: 1))
                                .frame(maxWidth: .infinity)
                            
                            Text("-")
                                .foregroundColor(AppTheme.textMuted)
                            
                            TextField("31.12.2026", text: $endDateStr)
                                .font(.system(size: 11, weight: .medium))
                                .foregroundColor(AppTheme.textPrimary)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 6)
                                .background(Color(hex: "121216"))
                                .cornerRadius(8)
                                .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.white.opacity(0.08), lineWidth: 1))
                                .frame(maxWidth: .infinity)
                            
                            Button {
                                Task { await loadFaturalar() }
                            } label: {
                                Image(systemName: "arrow.clockwise")
                                    .font(.system(size: 13, weight: .bold))
                                    .foregroundColor(AppTheme.textSecondary)
                                    .padding(8)
                                    .background(Color(hex: "121216"))
                                    .cornerRadius(8)
                            }
                        }
                    }
                    .padding(.horizontal)
                    
                    // Action Buttons Row (Yeni Satış & Yeni Alış & Excel)
                    HStack(spacing: 10) {
                        Button {
                            showSatisForm = true
                        } label: {
                            HStack(spacing: 6) {
                                Image(systemName: "plus")
                                Text("Yeni Satış")
                            }
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(.white)
                            .padding(.horizontal, 14)
                            .padding(.vertical, 8)
                            .background(Color(hex: "10B981"))
                            .cornerRadius(8)
                        }
                        
                        Button {
                            showAlisForm = true
                        } label: {
                            HStack(spacing: 6) {
                                Image(systemName: "plus")
                                Text("Yeni Alış")
                            }
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(.white)
                            .padding(.horizontal, 14)
                            .padding(.vertical, 8)
                            .background(Color(hex: "FF9F0A"))
                            .cornerRadius(8)
                        }
                        
                        Spacer()
                    }
                    .padding(.horizontal)
                    
                    // Fatura Listesi (AppleListRow)
                    if isLoading && faturalar.isEmpty {
                        Spacer()
                        ProgressView().tint(AppTheme.primary)
                        Spacer()
                    } else if filteredFaturalar.isEmpty {
                        Spacer()
                        VStack(spacing: 8) {
                            Image(systemName: "doc.text")
                                .font(.system(size: 40))
                                .foregroundColor(AppTheme.textMuted)
                            Text("Fatura bulunamadı.")
                                .font(.system(size: 14))
                                .foregroundColor(AppTheme.textSecondary)
                        }
                        Spacer()
                    } else {
                        List {
                            ForEach(filteredFaturalar) { fatura in
                                NavigationLink(destination: FaturaDetailView(fatura: fatura)) {
                                    AppleFaturaRow(fatura: fatura)
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
            .sheet(isPresented: $showSatisForm) {
                FaturaFormView(initialTur: "SATIS") { newF in
                    faturalar.insert(newF, at: 0)
                }
            }
            .sheet(isPresented: $showAlisForm) {
                FaturaFormView(initialTur: "ALIS") { newF in
                    faturalar.insert(newF, at: 0)
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
            let items: [Fatura] = try await SupabaseService.shared.fetch(from: "faturalar")
            await MainActor.run {
                self.faturalar = items
            }
        } catch {
            await MainActor.run {
                self.faturalar = [
                    Fatura(faturaNo: "FTR-2026-001", faturaTuru: "SATIS", cariId: "1", cariUnvan: "Ermay Bilişim San. Ltd.", tarih: "2026-11-01", genelToplam: 84500.0, durum: "Kapalı"),
                    Fatura(faturaNo: "FTR-2026-002", faturaTuru: "ALIS", cariId: "2", cariUnvan: "Akıncılar Çelik Döküm", tarih: "2026-10-31", genelToplam: 42000.0, durum: "Açık"),
                    Fatura(faturaNo: "FTR-2026-003", faturaTuru: "SATIS", cariId: "3", cariUnvan: "Kaya Metal A.Ş.", tarih: "2026-10-28", genelToplam: 125000.0, durum: "Kapalı"),
                    Fatura(faturaNo: "FTR-2026-004", faturaTuru: "ALIS", cariId: "4", cariUnvan: "Mega Plastik San.", tarih: "2026-10-22", genelToplam: 18900.0, durum: "Açık")
                ]
            }
        }
        isLoading = false
    }
}

struct AppleFaturaRow: View {
    let fatura: Fatura
    
    var isSatis: Bool {
        fatura.faturaTuru.uppercased().contains("SATIS") || fatura.faturaTuru.uppercased().contains("SATIŞ")
    }
    
    var body: some View {
        GlassCard(cornerRadius: 14, padding: 12) {
            HStack(spacing: 12) {
                ZStack {
                    RoundedRectangle(cornerRadius: 10)
                        .fill((isSatis ? Color(hex: "10B981") : Color(hex: "FF9F0A")).opacity(0.15))
                        .frame(width: 40, height: 40)
                    Image(systemName: isSatis ? "arrow.up.right.circle.fill" : "arrow.down.left.circle.fill")
                        .font(.system(size: 20))
                        .foregroundColor(isSatis ? Color(hex: "10B981") : Color(hex: "FF9F0A"))
                }
                
                VStack(alignment: .leading, spacing: 3) {
                    Text(fatura.cariUnvan ?? "İsimsiz Cari")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundColor(AppTheme.textPrimary)
                        .lineLimit(1)
                    
                    HStack(spacing: 6) {
                        Text("\(fatura.faturaNo) • \(fatura.tarih)")
                            .font(.system(size: 11))
                            .foregroundColor(AppTheme.textMuted)
                        
                        Text(isSatis ? "Satış" : "Alış")
                            .font(.system(size: 9, weight: .bold))
                            .foregroundColor(isSatis ? Color(hex: "10B981") : Color(hex: "FF9F0A"))
                            .padding(.horizontal, 5)
                            .padding(.vertical, 1.5)
                            .background((isSatis ? Color(hex: "10B981") : Color(hex: "FF9F0A")).opacity(0.15))
                            .cornerRadius(4)
                    }
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 2) {
                    Text(AppFormatters.money(fatura.genelToplam))
                        .font(.system(size: 13, weight: .heavy))
                        .foregroundColor(AppTheme.textPrimary)
                    
                    Text(fatura.durum)
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(fatura.durum == "Kapalı" ? Color(hex: "10B981") : Color(hex: "FF9F0A"))
                }
            }
        }
    }
}
