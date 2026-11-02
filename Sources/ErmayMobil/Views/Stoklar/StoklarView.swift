import SwiftUI

public struct StoklarView: View {
    @State private var stoklar: [StokKart] = []
    @State private var searchText: String = ""
    @State private var showKritikOnly: Bool = false
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
            
            if showKritikOnly {
                let kritik = s.kritikMiktar ?? 5.0
                return s.mevcutMiktar <= kritik
            }
            return true
        }
    }
    
    public var body: some View {
        NavigationStack {
            ZStack {
                AppTheme.background.ignoresSafeArea()
                
                VStack(spacing: 14) {
                    // Header Bar
                    HStack {
                        Text("Stok Kartları")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(AppTheme.textPrimary)
                        
                        Spacer()
                        
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
                                .font(.system(size: 28))
                                .foregroundColor(AppTheme.primary)
                        }
                    }
                    .padding(.horizontal)
                    .padding(.top, 8)
                    
                    // Search Bar & Barcode Scanner
                    HStack(spacing: 8) {
                        SearchBarView(text: $searchText, placeholder: "Ürün adı, stok kodu veya barkod...")
                        
                        Button {
                            showCameraSearch = true
                        } label: {
                            Image(systemName: "barcode.viewfinder")
                                .font(.system(size: 20))
                                .foregroundColor(AppTheme.primary)
                                .padding(10)
                                .background(AppTheme.cardBackground)
                                .cornerRadius(10)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(AppTheme.border, lineWidth: 1)
                                )
                        }
                    }
                    .padding(.horizontal)
                    
                    // Kritik Stok Filtre Butonu
                    HStack {
                        Button {
                            showKritikOnly.toggle()
                        } label: {
                            HStack(spacing: 6) {
                                Image(systemName: showKritikOnly ? "checkmark.circle.fill" : "exclamationmark.triangle")
                                Text("Kritik Stoklar (\(stoklar.filter { $0.mevcutMiktar <= ($0.kritikMiktar ?? 5.0) }.count))")
                            }
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundColor(showKritikOnly ? .white : AppTheme.warning)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(showKritikOnly ? AppTheme.warning : AppTheme.cardBackground)
                            .cornerRadius(8)
                            .overlay(RoundedRectangle(cornerRadius: 8).stroke(AppTheme.warning, lineWidth: 1))
                        }
                        
                        Spacer()
                        
                        Text("\(filteredStoklar.count) Ürün")
                            .font(.system(size: 12))
                            .foregroundColor(AppTheme.textMuted)
                    }
                    .padding(.horizontal)
                    
                    // Liste
                    if isLoading && stoklar.isEmpty {
                        Spacer()
                        ProgressView().tint(AppTheme.primary)
                        Spacer()
                    } else if filteredStoklar.isEmpty {
                        Spacer()
                        VStack(spacing: 8) {
                            Image(systemName: "cube.box")
                                .font(.system(size: 40))
                                .foregroundColor(AppTheme.textMuted)
                            Text("Stok kartı bulunamadı")
                                .font(.system(size: 15, weight: .semibold))
                                .foregroundColor(AppTheme.textSecondary)
                        }
                        Spacer()
                    } else {
                        List {
                            ForEach(filteredStoklar) { stok in
                                NavigationLink(destination: StokDetailView(stok: stok)) {
                                    StokRowItem(stok: stok)
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
                StokFormView { yeniStok in
                    stoklar.insert(yeniStok, at: 0)
                }
            }
            .sheet(isPresented: $showSayim) {
                StokSayimView(stoklar: stoklar)
            }
            .sheet(isPresented: $showGruplar) {
                StokGrupView()
            }
            .sheet(isPresented: $showCameraSearch) {
                BarcodeScannerView { scannedCode in
                    self.searchText = scannedCode
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
            print("Stok fetch error: \(error)")
            if stoklar.isEmpty {
                stoklar = [
                    StokKart(stokKodu: "STK-101", stokAdi: "Endüstriyel Bilyalı Rulman 6204", barkod: "8690001002001", grupAdi: "Rulman", birim: "Adet", alisFiyati: 140.0, satisFiyati: 220.0, kdvOrani: 20, mevcutMiktar: 145, kritikMiktar: 20),
                    StokKart(stokKodu: "STK-102", stokAdi: "Hidrolik Keçe 35x50x10", barkod: "8690001002002", grupAdi: "Sızdırmazlık", birim: "Adet", alisFiyati: 45.0, satisFiyati: 85.0, kdvOrani: 20, mevcutMiktar: 4, kritikMiktar: 15),
                    StokKart(stokKodu: "STK-103", stokAdi: "Sentetik Motor Yağı 5W-30 (4L)", barkod: "8690001002003", grupAdi: "Madeni Yağ", birim: "Teneke", alisFiyati: 480.0, satisFiyati: 750.0, kdvOrani: 20, mevcutMiktar: 2, kritikMiktar: 5),
                    StokKart(stokKodu: "STK-104", stokAdi: "Paslanmaz Civata M8x30", barkod: "8690001002004", grupAdi: "Bağlantı", birim: "Paket", alisFiyati: 60.0, satisFiyati: 110.0, kdvOrani: 20, mevcutMiktar: 85, kritikMiktar: 10)
                ]
            }
        }
        isLoading = false
    }
}

struct StokRowItem: View {
    let stok: StokKart
    
    var isKritik: Bool {
        stok.mevcutMiktar <= (stok.kritikMiktar ?? 5.0)
    }
    
    var body: some View {
        GlassCard(cornerRadius: 14, padding: 14) {
            HStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill((isKritik ? AppTheme.warning : AppTheme.primary).opacity(0.15))
                        .frame(width: 42, height: 42)
                    
                    Image(systemName: isKritik ? "exclamationmark.triangle.fill" : "shippingbox.fill")
                        .font(.system(size: 18))
                        .foregroundColor(isKritik ? AppTheme.warning : AppTheme.primary)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(stok.stokAdi)
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(AppTheme.textPrimary)
                        .lineLimit(1)
                    
                    HStack(spacing: 6) {
                        if let grup = stok.grupAdi {
                            Text(grup)
                                .font(.system(size: 10, weight: .semibold))
                                .foregroundColor(AppTheme.textMuted)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(AppTheme.cardSecondary)
                                .cornerRadius(4)
                        }
                        
                        Text("Satış: \(AppFormatters.money(stok.satisFiyati))")
                            .font(.system(size: 11))
                            .foregroundColor(AppTheme.textSecondary)
                    }
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 2) {
                    Text("\(String(format: "%.0f", stok.mevcutMiktar)) \(stok.birim ?? "Adet")")
                        .font(.system(size: 15, weight: .heavy))
                        .foregroundColor(isKritik ? AppTheme.danger : AppTheme.textPrimary)
                    
                    Text(isKritik ? "Kritik Seviye" : "Stokta Var")
                        .font(.system(size: 10, weight: .semibold))
                        .foregroundColor(isKritik ? AppTheme.danger : AppTheme.success)
                }
            }
        }
    }
}

