import SwiftUI

public struct StoklarView: View {
    @State private var stoklar: [StokKart] = []
    @State private var searchText: String = ""
    @State private var onlyWithBalance: Bool = false
    @State private var showForm: Bool = false
    @State private var showSayim: Bool = false
    @State private var showGruplar: Bool = false
    @State private var showCameraSearch: Bool = false
    @State private var isLoading: Bool = false
    
    public init() {}
    
    public var filteredStoklar: [StokKart] {
        stoklar.filter { s in
            let matchSearch = searchText.isEmpty ||
                s.stokAdi.localizedCaseInsensitiveContains(searchText) ||
                (s.stokKodu?.localizedCaseInsensitiveContains(searchText) ?? false) ||
                (s.barkod?.localizedCaseInsensitiveContains(searchText) ?? false) ||
                (s.grupAdi?.localizedCaseInsensitiveContains(searchText) ?? false)
            
            if !matchSearch { return false }
            
            if onlyWithBalance {
                return s.mevcutMiktar > 0
            }
            return true
        }
    }
    
    public var body: some View {
        NavigationStack {
            ZStack {
                AppTheme.background.ignoresSafeArea()
                
                VStack(spacing: 12) {
                    // Header Bar (Match StoklarScreen.tsx: Stok Listesi + Toplam Badge)
                    HStack {
                        HStack(spacing: 8) {
                            Image(systemName: "shippingbox.fill")
                                .font(.system(size: 20))
                                .foregroundColor(Color(hex: "60A5FA"))
                            
                            Text("Stok Listesi")
                                .font(.system(size: 24, weight: .black))
                                .foregroundColor(AppTheme.textPrimary)
                        }
                        
                        Spacer()
                        
                        // Toplam Badge
                        HStack(spacing: 4) {
                            Text("Toplam:")
                                .font(.system(size: 11, weight: .medium))
                                .foregroundColor(Color(hex: "94A3B8"))
                            Text("\(filteredStoklar.count)")
                                .font(.system(size: 12, weight: .bold))
                                .foregroundColor(Color(hex: "60A5FA"))
                        }
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .background(Color(hex: "1E293B"))
                        .cornerRadius(8)
                        
                        // Yeni Ekle Menüsü
                        Menu {
                            Button {
                                showForm = true
                            } label: {
                                Label("Yeni Stok Ekle", systemImage: "plus")
                            }
                            
                            Button {
                                showSayim = true
                            } label: {
                                Label("Hızlı Stok Sayımı", systemImage: "checklist")
                            }
                            
                            Button {
                                showGruplar = true
                            } label: {
                                Label("Stok Grupları", systemImage: "folder")
                            }
                        } label: {
                            Image(systemName: "plus.circle.fill")
                                .font(.system(size: 26))
                                .foregroundColor(AppTheme.primary)
                        }
                    }
                    .padding(.horizontal)
                    .padding(.top, 8)
                    
                    // Toolbar: Arama ve Bakiye Göster Filtresi
                    HStack(spacing: 8) {
                        SearchBarView(text: $searchText, placeholder: "Stok Kodu / Adı / Barkodu...")
                        
                        Button {
                            onlyWithBalance.toggle()
                        } label: {
                            Text("Bakiye Göster")
                                .font(.system(size: 11, weight: onlyWithBalance ? .bold : .medium))
                                .foregroundColor(onlyWithBalance ? .white : Color(hex: "94A3B8"))
                                .padding(.horizontal, 10)
                                .padding(.vertical, 9)
                                .background(onlyWithBalance ? Color(hex: "007AFF") : Color(hex: "1E293B"))
                                .cornerRadius(8)
                        }
                        
                        Button {
                            showCameraSearch = true
                        } label: {
                            Image(systemName: "barcode.viewfinder")
                                .font(.system(size: 18))
                                .foregroundColor(AppTheme.primary)
                                .padding(9)
                                .background(Color(hex: "1E293B"))
                                .cornerRadius(8)
                        }
                    }
                    .padding(.horizontal)
                    
                    // Stok Listesi (AppleListRow Tasarımı)
                    if isLoading && stoklar.isEmpty {
                        Spacer()
                        ProgressView().tint(AppTheme.primary)
                        Spacer()
                    } else if filteredStoklar.isEmpty {
                        Spacer()
                        VStack(spacing: 8) {
                            Image(systemName: "shippingbox")
                                .font(.system(size: 40))
                                .foregroundColor(AppTheme.textMuted)
                            Text("Kayıtlı stok bulunamadı.")
                                .font(.system(size: 14))
                                .foregroundColor(AppTheme.textSecondary)
                        }
                        Spacer()
                    } else {
                        List {
                            ForEach(filteredStoklar) { stok in
                                NavigationLink(destination: StokDetailView(stok: stok)) {
                                    AppleStokRow(stok: stok)
                                }
                                .listRowBackground(Color.clear)
                                .listRowSeparator(.hidden)
                                .listRowInsets(EdgeInsets(top: 4, leading: 16, bottom: 4, trailing: 16))
                            }
                        }
                        .listStyle(.plain)
                        .refreshable {
                            await loadStoklar()
                        }
                    }
                    
                    Spacer().frame(height: 70)
                }
            }
            .navigationBarHidden(true)
            .sheet(isPresented: $showForm) {
                StokFormView { newStok in
                    stoklar.insert(newStok, at: 0)
                }
            }
            .sheet(isPresented: $showSayim) {
                StokSayimView()
            }
            .sheet(isPresented: $showGruplar) {
                StokGrupView()
            }
            .sheet(isPresented: $showCameraSearch) {
                BarcodeScannerView { code in
                    searchText = code
                    showCameraSearch = false
                }
            }
            .task {
                await loadStoklar()
            }
        }
    }
    
    private func loadStoklar() async {
        isLoading = true
        do {
            let items: [StokKart] = try await SupabaseService.shared.fetch(from: "stoklar", orderBy: "stok_adi.asc")
            await MainActor.run {
                self.stoklar = items
            }
        } catch {
            await MainActor.run {
                self.stoklar = [
                    StokKart(stokKodu: "STK-001", barkod: "869012345678", stokAdi: "Galvaniz Sac Levha 2mm", grupAdi: "Hammadde", birim: "Kg", alisFiyati: 42.50, satisFiyati: 58.00, kdvOrani: 20.0, mevcutMiktar: 1420.0),
                    StokKart(stokKodu: "STK-002", barkod: "869012345679", stokAdi: "Alüminyum Profil 40x40", grupAdi: "Profil", birim: "Mt", alisFiyati: 110.00, satisFiyati: 145.00, kdvOrani: 20.0, mevcutMiktar: 85.0),
                    StokKart(stokKodu: "STK-003", barkod: "869012345680", stokAdi: "Çelik Civata M8x30 (100'lü)", grupAdi: "Bağlantı", birim: "Adet", alisFiyati: 65.00, satisFiyati: 90.00, kdvOrani: 20.0, mevcutMiktar: 4.0, kritikMiktar: 10.0),
                    StokKart(stokKodu: "STK-004", barkod: "869012345681", stokAdi: "Endüstriyel Epoksi Boya", grupAdi: "Kimyasal", birim: "Kg", alisFiyati: 240.00, satisFiyati: 310.00, kdvOrani: 20.0, mevcutMiktar: 0.0)
                ]
            }
        }
        isLoading = false
    }
}

struct AppleStokRow: View {
    let stok: StokKart
    
    var body: some View {
        GlassCard(cornerRadius: 14, padding: 12) {
            HStack(spacing: 12) {
                // Box Icon Box
                ZStack {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color(hex: "007AFF").opacity(0.15))
                        .frame(width: 40, height: 40)
                    Image(systemName: "shippingbox.fill")
                        .font(.system(size: 20))
                        .foregroundColor(Color(hex: "007AFF"))
                }
                
                VStack(alignment: .leading, spacing: 3) {
                    Text(stok.stokAdi)
                        .font(.system(size: 13, weight: .bold))
                        .foregroundColor(AppTheme.textPrimary)
                        .lineLimit(1)
                    
                    HStack(spacing: 6) {
                        Text("\(stok.stokKodu ?? "KODSUZ") • \(stok.grupAdi ?? "Genel")")
                            .font(.system(size: 11))
                            .foregroundColor(AppTheme.textMuted)
                        
                        Text("\(String(format: "%.1f", stok.mevcutMiktar)) \(stok.birim)")
                            .font(.system(size: 9, weight: .bold))
                            .foregroundColor(stok.mevcutMiktar <= 0 ? AppTheme.danger : AppTheme.success)
                            .padding(.horizontal, 5)
                            .padding(.vertical, 1.5)
                            .background((stok.mevcutMiktar <= 0 ? AppTheme.danger : AppTheme.success).opacity(0.15))
                            .cornerRadius(4)
                    }
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 2) {
                    Text(AppFormatters.money(stok.satisFiyati))
                        .font(.system(size: 13, weight: .heavy))
                        .foregroundColor(AppTheme.textPrimary)
                    
                    Text("Satış")
                        .font(.system(size: 10, weight: .medium))
                        .foregroundColor(AppTheme.textMuted)
                }
            }
        }
    }
}
