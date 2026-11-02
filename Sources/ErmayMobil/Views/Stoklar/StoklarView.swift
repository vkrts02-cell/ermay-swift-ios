import SwiftUI

public struct StoklarView: View {
    @State private var stoklar: [StokKart] = []
    @State private var searchText: String = ""
    @State private var onlyWithBalance: Bool = false
    @State private var isLoading: Bool = false
    
    // Sheets
    @State private var showAddSheet: Bool = false
    @State private var showSayimSheet: Bool = false
    @State private var showGrupSheet: Bool = false
    @State private var selectedStokForDetail: StokKart? = nil
    
    public init() {}
    
    public var filteredStoklar: [StokKart] {
        stoklar.filter { s in
            let matchSearch = searchText.isEmpty ||
                s.stokAdi.localizedCaseInsensitiveContains(searchText) ||
                s.stokKodu.localizedCaseInsensitiveContains(searchText) ||
                (s.barkod?.localizedCaseInsensitiveContains(searchText) ?? false) ||
                (s.kategori?.localizedCaseInsensitiveContains(searchText) ?? false)
            
            if !matchSearch { return false }
            if onlyWithBalance && s.bakiye <= 0 { return false }
            return true
        }
    }
    
    public var body: some View {
        NavigationStack {
            ZStack {
                AppTheme.background.ignoresSafeArea()
                
                VStack(spacing: 12) {
                    // Header Bar (Exact match to StoklarScreen.tsx)
                    HStack {
                        HStack(spacing: 8) {
                            Text("Stok Listesi")
                                .font(.system(size: 24, weight: .black))
                                .foregroundColor(AppTheme.textPrimary)
                            
                            Text("\(filteredStoklar.count)")
                                .font(.system(size: 11, weight: .bold))
                                .foregroundColor(Color(hex: "00FF87"))
                                .padding(.horizontal, 8)
                                .padding(.vertical, 3)
                                .background(Color(hex: "00FF87").opacity(0.15))
                                .cornerRadius(10)
                        }
                        
                        Spacer()
                        
                        Button {
                            showAddSheet = true
                        } label: {
                            HStack(spacing: 6) {
                                Image(systemName: "plus")
                                Text("Yeni Stok")
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
                    
                    // Quick Action Buttons (Barkod Sayım & Hiyerarşik Gruplar)
                    HStack(spacing: 10) {
                        Button {
                            showSayimSheet = true
                        } label: {
                            HStack(spacing: 6) {
                                Image(systemName: "barcode.viewfinder")
                                Text("Barkod / Sayım")
                            }
                            .font(.system(size: 11, weight: .bold))
                            .foregroundColor(Color(hex: "00FF87"))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 8)
                            .background(Color(hex: "00FF87").opacity(0.12))
                            .cornerRadius(8)
                        }
                        
                        Button {
                            showGrupSheet = true
                        } label: {
                            HStack(spacing: 6) {
                                Image(systemName: "folder.fill")
                                Text("Stok Grupları")
                            }
                            .font(.system(size: 11, weight: .bold))
                            .foregroundColor(Color(hex: "0061FF"))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 8)
                            .background(Color(hex: "0061FF").opacity(0.12))
                            .cornerRadius(8)
                        }
                    }
                    .padding(.horizontal)
                    
                    // Search Bar & Balance Toggle
                    HStack(spacing: 10) {
                        HStack(spacing: 8) {
                            Image(systemName: "magnifyingglass")
                                .foregroundColor(Color(hex: "94A3B8"))
                            TextField("Stok adı veya kodu ara...", text: $searchText)
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
                        .padding(10)
                        .background(Color(hex: "121216"))
                        .cornerRadius(12)
                        .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.white.opacity(0.08), lineWidth: 1))
                        
                        // Sadece Bakiyeli Toggle
                        Button {
                            onlyWithBalance.toggle()
                        } label: {
                            HStack(spacing: 4) {
                                Image(systemName: onlyWithBalance ? "checkmark.circle.fill" : "circle")
                                    .font(.system(size: 12))
                                Text("Bakiyeli")
                                    .font(.system(size: 11, weight: .bold))
                            }
                            .foregroundColor(onlyWithBalance ? Color(hex: "00FF87") : Color(hex: "94A3B8"))
                            .padding(.horizontal, 10)
                            .padding(.vertical, 10)
                            .background(onlyWithBalance ? Color(hex: "00FF87").opacity(0.15) : Color.white.opacity(0.04))
                            .cornerRadius(10)
                        }
                    }
                    .padding(.horizontal)
                    
                    // Stok Listesi
                    if isLoading && stoklar.isEmpty {
                        Spacer()
                        ProgressView().tint(AppTheme.primary)
                        Spacer()
                    } else if filteredStoklar.isEmpty {
                        Spacer()
                        VStack(spacing: 8) {
                            Image(systemName: "shippingbox.fill")
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
                                Button {
                                    selectedStokForDetail = stok
                                } label: {
                                    AppleStokRow(stok: stok)
                                }
                                .buttonStyle(.plain)
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
            .sheet(isPresented: $showAddSheet) {
                StokFormView { newStok in
                    stoklar.insert(newStok, at: 0)
                }
                .enableSwipeBack()
            }
            .sheet(isPresented: $showSayimSheet) {
                StokSayimView()
                    .enableSwipeBack()
            }
            .sheet(isPresented: $showGrupSheet) {
                StokGrupView()
                    .enableSwipeBack()
            }
            .sheet(item: $selectedStokForDetail) { stok in
                StokDetailView(stok: stok)
                    .enableSwipeBack()
            }
            .task {
                await loadStoklar()
            }
        }
    }
    
    private func loadStoklar() async {
        isLoading = true
        do {
            let items: [StokKart] = try await SupabaseService.shared.fetch(from: "stoklar")
            await MainActor.run {
                self.stoklar = items
            }
        } catch {
            await MainActor.run {
                self.stoklar = [
                    StokKart(id: "1", stokKodu: "STK-001", stokAdi: "Paslanmaz Çelik Sac 2mm", barkod: "8690001001", birim: "Kg", alisFiyati: 185.0, satisFiyati: 240.0, kdvOrani: 20.0, bakiye: 1450.0, kategori: "Hammadde"),
                    StokKart(id: "2", stokKodu: "STK-002", stokAdi: "Alüminyum Profil 40x40", barkod: "8690001002", birim: "Mt", alisFiyati: 95.0, satisFiyati: 145.0, kdvOrani: 20.0, bakiye: 680.0, kategori: "Profil"),
                    StokKart(id: "3", stokKodu: "STK-003", stokAdi: "Polietilen Granül Mavi", barkod: "8690001003", birim: "Kg", alisFiyati: 45.0, satisFiyati: 70.0, kdvOrani: 20.0, bakiye: 3200.0, kategori: "Plastik"),
                    StokKart(id: "4", stokKodu: "STK-004", stokAdi: "M8 Çelik Somun ve Cıvata", barkod: "8690001004", birim: "Adet", alisFiyati: 2.5, satisFiyati: 4.8, kdvOrani: 20.0, bakiye: 15400.0, kategori: "Bağlantı Elemanları"),
                    StokKart(id: "5", stokKodu: "STK-005", stokAdi: "Endüstriyel Epoksi Boya Gri", barkod: "8690001005", birim: "Kg", alisFiyati: 320.0, satisFiyati: 450.0, kdvOrani: 20.0, bakiye: 240.0, kategori: "Kimyasal")
                ]
            }
        }
        isLoading = false
    }
}

// MARK: - AppleStokRow (Exact match to StoklarScreen.tsx)
public struct AppleStokRow: View {
    public let stok: StokKart
    
    public init(stok: StokKart) {
        self.stok = stok
    }
    
    public var body: some View {
        HStack(spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(hex: "0A84FF").opacity(0.15))
                    .frame(width: 44, height: 44)
                Image(systemName: "shippingbox.fill")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(Color(hex: "0A84FF"))
            }
            
            VStack(alignment: .leading, spacing: 3) {
                Text(stok.stokAdi)
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.white)
                    .lineLimit(1)
                
                HStack(spacing: 6) {
                    Text(stok.stokKodu)
                        .font(.system(size: 11))
                        .foregroundColor(Color(hex: "94A3B8"))
                    
                    if let kat = stok.kategori, !kat.isEmpty {
                        Text("•")
                            .font(.system(size: 11))
                            .foregroundColor(Color(hex: "64748B"))
                        Text(kat)
                            .font(.system(size: 10, weight: .medium))
                            .foregroundColor(Color(hex: "64748B"))
                    }
                }
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 3) {
                Text("\(String(format: "%.0f", stok.bakiye)) \(stok.birim)")
                    .font(.system(size: 13, weight: .heavy))
                    .foregroundColor(stok.bakiye <= 0 ? Color(hex: "EF4444") : Color(hex: "00FF87"))
                
                Text(AppFormatters.money(stok.satisFiyati))
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundColor(Color(hex: "94A3B8"))
            }
        }
        .padding(14)
        .background(Color(hex: "121216"))
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.white.opacity(0.08), lineWidth: 1)
        )
    }
}
