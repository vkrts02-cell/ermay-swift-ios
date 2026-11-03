import SwiftUI

public struct StoklarView: View {
    @State private var stoklar: [StokKart] = []
    @State private var searchText: String = ""
    @State private var showKritikOnly: Bool = false
    @State private var selectedGroup: String = "Tümü"
    @State private var gruplar: [String] = ["Tümü", "Genel", "Rulman", "Sızdırmazlık", "Madeni Yağ", "Bağlantı"]
    @State private var isLoading: Bool = false
    
    // Modals
    @State private var showForm: Bool = false
    @State private var showSayim: Bool = false
    @State private var showGruplar: Bool = false
    @State private var showBarcodeScanner: Bool = false
    @State private var scannedCode: String = ""
    
    public init() {}
    
    public var filteredStoklar: [StokKart] {
        stoklar.filter { s in
            let matchSearch = searchText.isEmpty ||
                s.stokAdi.localizedCaseInsensitiveContains(searchText) ||
                (s.stokKodu?.localizedCaseInsensitiveContains(searchText) ?? false) ||
                (s.barkod?.localizedCaseInsensitiveContains(searchText) ?? false)
            
            if !matchSearch { return false }
            
            if selectedGroup != "Tümü" && s.grupAdi != selectedGroup {
                return false
            }
            
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
                
                VStack(spacing: 12) {
                    // Header Bar
                    HStack {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Stok & Envanter")
                                .font(.system(size: 22, weight: .bold))
                                .foregroundColor(AppTheme.textPrimary)
                            Text("\(filteredStoklar.count) Kalem Ürün")
                                .font(.system(size: 11))
                                .foregroundColor(AppTheme.textMuted)
                        }
                        
                        Spacer()
                        
                        // Barkod Butonu
                        Button {
                            showBarcodeScanner = true
                        } label: {
                            Image(systemName: "barcode.viewfinder")
                                .font(.system(size: 22))
                                .foregroundColor(AppTheme.primary)
                                .padding(6)
                                .background(Circle().fill(AppTheme.cardSecondary))
                        }
                        
                        // Menü Butonu
                        Menu {
                            Button { showForm = true } label: { Label("Yeni Stok Ekle", systemImage: "plus") }
                            Button { showSayim = true } label: { Label("Hızlı Sayım", systemImage: "checklist") }
                            Button { showGruplar = true } label: { Label("Stok Grupları", systemImage: "folder") }
                        } label: {
                            Image(systemName: "plus.circle.fill")
                                .font(.system(size: 28))
                                .foregroundColor(AppTheme.primary)
                        }
                    }
                    .padding(.horizontal)
                    .padding(.top, 6)
                    
                    // Search Bar
                    SearchBarView(text: $searchText, placeholder: "Ürün adı, stok kodu veya barkod ara...")
                        .padding(.horizontal)
                    
                    // Grup Filtreleri
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            // Kritik Stok Butonu
                            Button {
                                showKritikOnly.toggle()
                            } label: {
                                HStack(spacing: 4) {
                                    Image(systemName: showKritikOnly ? "checkmark.circle.fill" : "exclamationmark.triangle.fill")
                                    Text("Kritik (\(stoklar.filter { $0.mevcutMiktar <= ($0.kritikMiktar ?? 5.0) }.count))")
                                }
                                .font(.system(size: 12, weight: .bold))
                                .foregroundColor(showKritikOnly ? .white : AppTheme.warning)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 7)
                                .background(showKritikOnly ? AppTheme.warning : AppTheme.cardBackground)
                                .cornerRadius(8)
                                .overlay(RoundedRectangle(cornerRadius: 8).stroke(AppTheme.warning, lineWidth: 1))
                            }
                            
                            ForEach(gruplar, id: \.self) { g in
                                let isSelected = selectedGroup == g
                                Button {
                                    selectedGroup = g
                                } label: {
                                    Text(g)
                                        .font(.system(size: 13, weight: isSelected ? .bold : .medium))
                                        .foregroundColor(isSelected ? .white : AppTheme.textSecondary)
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 7)
                                        .background(isSelected ? AppTheme.primary : AppTheme.cardBackground)
                                        .cornerRadius(8)
                                        .overlay(RoundedRectangle(cornerRadius: 8).stroke(isSelected ? AppTheme.primary : AppTheme.border, lineWidth: 1))
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                    
                    // Stok Listesi (LazyVStack ile sayfalama)
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
                            Text("Aradığınız stok kaydı bulunamadı")
                                .font(.system(size: 14, weight: .semibold))
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
                
                // Barkod Tarama Modalı
                SwipeableModal(isPresented: $showBarcodeScanner, title: "Barkod Tara / Arama") {
                    VStack(spacing: 16) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 16)
                                .fill(AppTheme.cardSecondary)
                                .frame(height: 180)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 16)
                                        .stroke(AppTheme.primary, lineWidth: 2)
                                )
                            VStack(spacing: 8) {
                                Image(systemName: "barcode.viewfinder")
                                    .font(.system(size: 48))
                                    .foregroundColor(AppTheme.primary)
                                Text("Barkodu kameraya hizalayın veya numarayı girin")
                                    .font(.system(size: 12))
                                    .foregroundColor(AppTheme.textMuted)
                            }
                        }
                        
                        FormField(label: "Barkod Numarası", text: $scannedCode, placeholder: "8690001002001")
                        
                        ActionButton(title: "Bu Barkodu Filtrele", icon: "magnifyingglass", color: AppTheme.primary) {
                            searchText = scannedCode
                            showBarcodeScanner = false
                            HardwareService.shared.hapticSuccess()
                        }
                    }
                }
            }
            .navigationBarHidden(true)
            .sheet(isPresented: $showForm) {
                StokFormView { yeni in
                    stoklar.insert(yeni, at: 0)
                }
            }
            .sheet(isPresented: $showSayim) {
                StokSayimView(stoklar: stoklar)
            }
            .sheet(isPresented: $showGruplar) {
                StokGrupView()
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

public struct StokRowItem: View {
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
                    Text(stok.stokKodu ?? "STK")
                        .font(.system(size: 11))
                        .foregroundColor(Color(hex: "94A3B8"))
                    
                    if let grup = stok.grupAdi, !grup.isEmpty {
                        Text("•")
                            .font(.system(size: 11))
                            .foregroundColor(Color(hex: "64748B"))
                        Text(grup)
                            .font(.system(size: 10, weight: .medium))
                            .foregroundColor(Color(hex: "64748B"))
                    }
                }
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 3) {
                Text("\(String(format: "%.0f", stok.mevcutMiktar)) \(stok.birim ?? "Adet")")
                    .font(.system(size: 13, weight: .heavy))
                    .foregroundColor(stok.mevcutMiktar <= (stok.kritikMiktar ?? 5.0) ? Color(hex: "EF4444") : Color(hex: "00FF87"))
                
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
