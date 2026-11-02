import SwiftUI

public struct CarilerView: View {
    @State private var cariler: [CariKart] = []
    @State private var searchText: String = ""
    @State private var selectedFilter: String = "Tümü" // "Tümü", "Müşteri", "Tedarikçi", "Bakiyeli"
    @State private var sortByBakiye: Bool = false
    @State private var bakiyeSortDesc: Bool = true
    @State private var isLoading: Bool = false
    
    // Sheets
    @State private var showAddSheet: Bool = false
    @State private var selectedCariForDetail: CariKart? = nil
    
    private let iconColors: [Color] = [
        Color(hex: "FF9500"),
        Color(hex: "AF52DE"),
        Color(hex: "007AFF"),
        Color(hex: "34C759"),
        Color(hex: "FF2D55")
    ]
    
    public init() {}
    
    public var filteredCariler: [CariKart] {
        var result = cariler.filter { cari in
            let matchSearch = searchText.isEmpty ||
                cari.unvan.localizedCaseInsensitiveContains(searchText) ||
                (cari.cariKodu?.localizedCaseInsensitiveContains(searchText) ?? false) ||
                (cari.yetkili?.localizedCaseInsensitiveContains(searchText) ?? false) ||
                (cari.sehir?.localizedCaseInsensitiveContains(searchText) ?? false)
            
            if !matchSearch { return false }
            
            switch selectedFilter {
            case "Müşteri":
                return cari.cariTuru?.uppercased().contains("MUSTERI") == true || cari.cariTuru?.uppercased().contains("MÜŞTERI") == true || cari.grup?.uppercased().contains("MÜŞTERI") == true
            case "Tedarikçi":
                return cari.cariTuru?.uppercased().contains("TEDARIK") == true || cari.grup?.uppercased().contains("TEDARIK") == true
            case "Bakiyeli":
                return cari.bakiye > 0
            default:
                return true
            }
        }
        
        if sortByBakiye {
            result.sort { bakiyeSortDesc ? $0.bakiye > $1.bakiye : $0.bakiye < $1.bakiye }
        } else {
            result.sort { $0.unvan.localizedCaseInsensitiveCompare($1.unvan) == .orderedAscending }
        }
        return result
    }
    
    public var body: some View {
        NavigationStack {
            ZStack {
                AppTheme.background.ignoresSafeArea()
                
                VStack(spacing: 12) {
                    // Header Bar (Exact match to CarilerScreen.tsx)
                    HStack {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Cariler")
                                .font(.system(size: 24, weight: .black))
                                .foregroundColor(AppTheme.textPrimary)
                            Text("Müşteri ve Tedarikçi Listesi")
                                .font(.system(size: 13, weight: .medium))
                                .foregroundColor(Color(hex: "94A3B8"))
                        }
                        
                        Spacer()
                        
                        Button {
                            showAddSheet = true
                        } label: {
                            HStack(spacing: 6) {
                                Image(systemName: "plus")
                                Text("Yeni Cari")
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
                    
                    // Search Bar (Exact to CarilerScreen.tsx)
                    HStack(spacing: 8) {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(Color(hex: "94A3B8"))
                        TextField("Cari unvanı, kodu veya yetkili ara...", text: $searchText)
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
                    
                    // Kolon Başlıkları & Grup / Bakiye Sıralama Butonları
                    HStack {
                        Text("Ünvan / Cari")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(Color(hex: "94A3B8"))
                        if !sortByBakiye && selectedFilter == "Tümü" {
                            Text("(A-Z)")
                                .font(.system(size: 11))
                                .foregroundColor(Color(hex: "64748B"))
                        }
                        
                        Spacer()
                        
                        // Grup Filtre Butonu
                        Menu {
                            Button("Tümü") { selectedFilter = "Tümü" }
                            Button("Müşteri") { selectedFilter = "Müşteri" }
                            Button("Tedarikçi") { selectedFilter = "Tedarikçi" }
                            Button("Bakiyeli") { selectedFilter = "Bakiyeli" }
                        } label: {
                            HStack(spacing: 4) {
                                Text(selectedFilter == "Tümü" ? "Grup" : selectedFilter)
                                    .font(.system(size: 11, weight: .bold))
                                Image(systemName: "chevron.up.chevron.down")
                                    .font(.system(size: 9))
                            }
                            .foregroundColor(selectedFilter != "Tümü" ? Color(hex: "0061FF") : Color(hex: "94A3B8"))
                            .padding(.horizontal, 10)
                            .padding(.vertical, 6)
                            .background(selectedFilter != "Tümü" ? Color(hex: "0061FF").opacity(0.15) : Color.white.opacity(0.04))
                            .cornerRadius(8)
                        }
                        
                        // Bakiye Sıralama Butonu
                        Button {
                            if sortByBakiye {
                                bakiyeSortDesc.toggle()
                            } else {
                                sortByBakiye = true
                                bakiyeSortDesc = true
                            }
                        } label: {
                            HStack(spacing: 4) {
                                Text("Bakiye")
                                    .font(.system(size: 11, weight: .bold))
                                if sortByBakiye {
                                    Image(systemName: bakiyeSortDesc ? "arrow.down" : "arrow.up")
                                        .font(.system(size: 10, weight: .bold))
                                }
                            }
                            .foregroundColor(sortByBakiye ? Color(hex: "00FF87") : Color(hex: "94A3B8"))
                            .padding(.horizontal, 10)
                            .padding(.vertical, 6)
                            .background(sortByBakiye ? Color(hex: "00FF87").opacity(0.15) : Color.white.opacity(0.04))
                            .cornerRadius(8)
                        }
                    }
                    .padding(.horizontal)
                    .padding(.top, 2)
                    
                    // Cari Listesi
                    if isLoading && cariler.isEmpty {
                        Spacer()
                        ProgressView().tint(AppTheme.primary)
                        Spacer()
                    } else if filteredCariler.isEmpty {
                        Spacer()
                        VStack(spacing: 8) {
                            Image(systemName: "person.crop.circle.badge.questionmark")
                                .font(.system(size: 40))
                                .foregroundColor(AppTheme.textMuted)
                            Text("Cari kart bulunamadı")
                                .font(.system(size: 15, weight: .semibold))
                                .foregroundColor(AppTheme.textSecondary)
                        }
                        Spacer()
                    } else {
                        List {
                            ForEach(Array(filteredCariler.enumerated()), id: \.element.id) { index, cari in
                                Button {
                                    selectedCariForDetail = cari
                                } label: {
                                    AppleCariRow(
                                        cari: cari,
                                        iconColor: iconColors[index % iconColors.count]
                                    )
                                }
                                .buttonStyle(.plain)
                                .listRowBackground(Color.clear)
                                .listRowSeparator(.hidden)
                                .listRowInsets(EdgeInsets(top: 4, leading: 16, bottom: 4, trailing: 16))
                            }
                        }
                        .listStyle(.plain)
                        .refreshable {
                            await loadCariler()
                        }
                    }
                    
                    Spacer().frame(height: 70)
                }
            }
            .navigationBarHidden(true)
            .sheet(isPresented: $showAddSheet) {
                CariFormView { newCari in
                    cariler.insert(newCari, at: 0)
                }
                .enableSwipeBack()
            }
            .sheet(item: $selectedCariForDetail) { cari in
                CariDetailView(cari: cari)
                    .enableSwipeBack()
            }
            .task {
                await loadCariler()
            }
        }
    }
    
    private func loadCariler() async {
        isLoading = true
        do {
            let items: [CariKart] = try await SupabaseService.shared.fetch(from: "cariler")
            await MainActor.run {
                self.cariler = items
            }
        } catch {
            await MainActor.run {
                self.cariler = [
                    CariKart(id: "1", unvan: "Ermay Bilişim Sanayi Ltd. Şti.", cariKodu: "CARI-001", yetkili: "Ahmet Erdem", telefon: "0532 111 2233", sehir: "İstanbul", bakiye: 45200.0, bakiyeTuru: "A", cariTuru: "Müşteri", grup: "Müşteri"),
                    CariKart(id: "2", unvan: "Mega Plastik Ambalaj Sanayi A.Ş.", cariKodu: "CARI-002", yetkili: "Mehmet Kaya", telefon: "0542 333 4455", sehir: "Kocaeli", bakiye: 28400.0, bakiyeTuru: "A", cariTuru: "Müşteri", grup: "Müşteri"),
                    CariKart(id: "3", unvan: "Akıncılar Çelik Döküm A.Ş.", cariKodu: "CARI-003", yetkili: "Hakan Akıncı", telefon: "0505 555 6677", sehir: "Bursa", bakiye: 22800.0, bakiyeTuru: "B", cariTuru: "Tedarikçi", grup: "Tedarikçi"),
                    CariKart(id: "4", unvan: "Kaya Metal Kalıp Ltd. Şti.", cariKodu: "CARI-004", yetkili: "Selim Kaya", telefon: "0533 777 8899", sehir: "İzmir", bakiye: 24800.0, bakiyeTuru: "A", cariTuru: "Müşteri", grup: "Müşteri"),
                    CariKart(id: "5", unvan: "Özkanlar Ambalaj ve Koli Sanayi", cariKodu: "CARI-005", yetkili: "Murat Özkan", telefon: "0555 999 0011", sehir: "Ankara", bakiye: 11400.0, bakiyeTuru: "B", cariTuru: "Tedarikçi", grup: "Tedarikçi")
                ]
            }
        }
        isLoading = false
    }
}

// MARK: - AppleCariRow (Exact React Native Parity)
struct AppleCariRow: View {
    let cari: CariKart
    let iconColor: Color
    
    var isAlacak: Bool {
        cari.bakiyeTuru == "A"
    }
    
    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(iconColor)
                    .frame(width: 44, height: 44)
                Image(systemName: "person.circle.fill")
                    .font(.system(size: 24))
                    .foregroundColor(.white)
            }
            
            VStack(alignment: .leading, spacing: 3) {
                Text(cari.unvan)
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(AppTheme.textPrimary)
                    .lineLimit(1)
                
                HStack(spacing: 6) {
                    Text("\(cari.cariKodu ?? "CARI") • \(cari.yetkili ?? "Yetkili Yok")")
                        .font(.system(size: 11))
                        .foregroundColor(Color(hex: "94A3B8"))
                        .lineLimit(1)
                    
                    Text(cari.grup ?? cari.cariTuru ?? "Müşteri")
                        .font(.system(size: 9, weight: .bold))
                        .foregroundColor(cari.grup == "Tedarikçi" ? Color(hex: "FF9F0A") : Color(hex: "0061FF"))
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background((cari.grup == "Tedarikçi" ? Color(hex: "FF9F0A") : Color(hex: "0061FF")).opacity(0.15))
                        .cornerRadius(6)
                }
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 3) {
                Text(AppFormatters.money(cari.bakiye))
                    .font(.system(size: 13, weight: .heavy))
                    .foregroundColor(cari.bakiye == 0 ? Color(hex: "94A3B8") : (isAlacak ? Color(hex: "30D158") : Color(hex: "FF453A")))
                
                Text(cari.bakiye == 0 ? "Sıfır" : (isAlacak ? "Alacak" : "Borç"))
                    .font(.system(size: 10, weight: .bold))
                    .foregroundColor(cari.bakiye == 0 ? Color(hex: "64748B") : (isAlacak ? Color(hex: "30D158") : Color(hex: "FF453A")))
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
