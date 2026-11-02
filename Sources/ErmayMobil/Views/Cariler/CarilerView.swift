import SwiftUI

public struct CarilerView: View {
    @State private var cariler: [CariKart] = []
    @State private var searchText: String = ""
    @State private var selectedFilter: String = "Tümü"
    @State private var sortByBakiye: Bool = false
    @State private var bakiyeSortDesc: Bool = true
    @State private var isLoading: Bool = false
    @State private var showAddSheet: Bool = false
    @State private var showContactPicker: Bool = false
    
    // Quick Transaction Sheet
    @State private var selectedCariForTrans: CariKart? = nil
    @State private var isTransTahsilat: Bool = true
    @State private var showTransSheet: Bool = false
    
    private let filters = ["Tümü", "Müşteri", "Tedarikçi", "Bakiyeli"]
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
                (cari.sehir?.localizedCaseInsensitiveContains(searchText) ?? false)
            
            if !matchSearch { return false }
            
            switch selectedFilter {
            case "Müşteri":
                return cari.cariTuru?.uppercased().contains("MUSTERI") == true || cari.cariTuru?.uppercased().contains("MÜŞTERI") == true
            case "Tedarikçi":
                return cari.cariTuru?.uppercased().contains("TEDARIK") == true
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
                    // Header Bar
                    HStack {
                        Text("Cariler")
                            .font(.system(size: 26, weight: .black))
                            .foregroundColor(AppTheme.textPrimary)
                        
                        Spacer()
                        
                        Button {
                            showAddSheet = true
                        } label: {
                            Image(systemName: "plus.circle.fill")
                                .font(.system(size: 28))
                                .foregroundColor(AppTheme.primary)
                        }
                    }
                    .padding(.horizontal)
                    .padding(.top, 8)
                    
                    // Donanım Butonları (Rehberden Aktar & GPS)
                    HStack(spacing: 10) {
                        Button {
                            showContactPicker = true
                        } label: {
                            HStack(spacing: 6) {
                                Image(systemName: "person.crop.circle.badge.plus")
                                Text("Rehberden Aktar")
                            }
                            .font(.system(size: 11, weight: .bold))
                            .foregroundColor(Color(hex: "00FF87"))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 8)
                            .background(Color(hex: "00FF87").opacity(0.12))
                            .cornerRadius(8)
                        }
                        
                        Button {
                            showAddSheet = true
                        } label: {
                            HStack(spacing: 6) {
                                Image(systemName: "location.fill")
                                Text("GPS Konumu Al")
                            }
                            .font(.system(size: 11, weight: .bold))
                            .foregroundColor(Color(hex: "0A84FF"))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 8)
                            .background(Color(hex: "0A84FF").opacity(0.12))
                            .cornerRadius(8)
                        }
                    }
                    .padding(.horizontal)
                    
                    // Arama Çubuğu
                    SearchBarView(text: $searchText, placeholder: "Ünvan, kod veya vergi no ara...")
                        .padding(.horizontal)
                    
                    // Filtreleme ve Sıralama Barı
                    HStack {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 8) {
                                ForEach(filters, id: \.self) { f in
                                    Button {
                                        selectedFilter = f
                                    } label: {
                                        Text(f)
                                            .font(.system(size: 11, weight: selectedFilter == f ? .bold : .medium))
                                            .foregroundColor(selectedFilter == f ? .white : AppTheme.textSecondary)
                                            .padding(.horizontal, 10)
                                            .padding(.vertical, 5)
                                            .background(selectedFilter == f ? AppTheme.primary : AppTheme.cardSecondary)
                                            .cornerRadius(6)
                                    }
                                }
                            }
                        }
                        
                        Button {
                            if sortByBakiye {
                                bakiyeSortDesc.toggle()
                            } else {
                                sortByBakiye = true
                                bakiyeSortDesc = true
                            }
                        } label: {
                            HStack(spacing: 3) {
                                Text("Bakiye")
                                Image(systemName: sortByBakiye ? (bakiyeSortDesc ? "arrow.down" : "arrow.up") : "arrow.up.arrow.down")
                            }
                            .font(.system(size: 11, weight: .semibold))
                            .foregroundColor(sortByBakiye ? Color(hex: "00FF87") : AppTheme.textMuted)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 5)
                            .background(AppTheme.cardSecondary)
                            .cornerRadius(6)
                        }
                    }
                    .padding(.horizontal)
                    
                    // Cariler Listesi (AppleListRow Tasarımı)
                    if isLoading && cariler.isEmpty {
                        Spacer()
                        ProgressView().tint(AppTheme.primary)
                        Spacer()
                    } else if filteredCariler.isEmpty {
                        Spacer()
                        VStack(spacing: 8) {
                            Image(systemName: "person.2.slash")
                                .font(.system(size: 36))
                                .foregroundColor(AppTheme.textMuted)
                            Text("Cari hesap bulunamadı.")
                                .font(.system(size: 13))
                                .foregroundColor(AppTheme.textSecondary)
                        }
                        Spacer()
                    } else {
                        List {
                            ForEach(Array(filteredCariler.enumerated()), id: \.element.id) { index, cari in
                                NavigationLink(destination: CariDetailView(cari: cari)) {
                                    AppleCariRow(
                                        cari: cari,
                                        iconColor: iconColors[index % iconColors.count],
                                        onTahsilat: {
                                            selectedCariForTrans = cari
                                            isTransTahsilat = true
                                            showTransSheet = true
                                        },
                                        onOdeme: {
                                            selectedCariForTrans = cari
                                            isTransTahsilat = false
                                            showTransSheet = true
                                        }
                                    )
                                }
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
            }
            .sheet(isPresented: $showTransSheet) {
                if let c = selectedCariForTrans {
                    TahsilatFormView(isTahsilat: isTransTahsilat) { h in
                        if let idx = cariler.firstIndex(where: { $0.id == c.id }) {
                            if isTransTahsilat {
                                cariler[idx].bakiye -= h.tutar
                            } else {
                                cariler[idx].bakiye += h.tutar
                            }
                        }
                    }
                }
            }
            .sheet(isPresented: $showContactPicker) {
                #if canImport(UIKit) && canImport(ContactsUI)
                ContactPickerBridge { _ in
                    showAddSheet = true
                }
                #endif
            }
            .task {
                await loadCariler()
            }
        }
    }
    
    private func loadCariler() async {
        isLoading = true
        do {
            let items: [CariKart] = try await SupabaseService.shared.fetch(from: "cariler", orderBy: "unvan.asc")
            await MainActor.run {
                self.cariler = items
            }
        } catch {
            await MainActor.run {
                self.cariler = [
                    CariKart(cariKodu: "CR-001", unvan: "Ermay Bilişim Sanayi Ticaret Ltd. Şti.", cariTuru: "Müşteri", telefon: "05321112233", sehir: "İstanbul", bakiye: 45200.0, bakiyeTuru: "A"),
                    CariKart(cariKodu: "CR-002", unvan: "Akıncılar Çelik & Alüminyum Döküm A.Ş.", cariTuru: "Tedarikçi", telefon: "05423334455", sehir: "Kocaeli", bakiye: 18500.0, bakiyeTuru: "B"),
                    CariKart(cariKodu: "CR-003", unvan: "Mega Plastik İthalat İhracat Ltd.", cariTuru: "Müşteri", telefon: "05556667788", sehir: "Bursa", bakiye: 8900.0, bakiyeTuru: "A"),
                    CariKart(cariKodu: "CR-004", unvan: "Yıldız Lojistik ve Antrepo Hizmetleri", cariTuru: "Tedarikçi", telefon: "05339998877", sehir: "İzmir", bakiye: 0.0, bakiyeTuru: "A")
                ]
            }
        }
        isLoading = false
    }
}

struct AppleCariRow: View {
    let cari: CariKart
    let iconColor: Color
    let onTahsilat: () -> Void
    let onOdeme: () -> Void
    
    var isPositive: Bool { cari.bakiyeTuru == "A" && cari.bakiye > 0 }
    var isNegative: Bool { cari.bakiyeTuru == "B" && cari.bakiye > 0 }
    
    var body: some View {
        GlassCard(cornerRadius: 14, padding: 12) {
            HStack(spacing: 12) {
                // Canlı Apple İkon Kutusu
                ZStack {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(iconColor)
                        .frame(width: 40, height: 40)
                    Image(systemName: "person.crop.circle.fill")
                        .font(.system(size: 22))
                        .foregroundColor(.white)
                }
                
                VStack(alignment: .leading, spacing: 3) {
                    Text(cari.unvan)
                        .font(.system(size: 13, weight: .bold))
                        .foregroundColor(AppTheme.textPrimary)
                        .lineLimit(1)
                    
                    HStack(spacing: 6) {
                        Text("\(cari.cariKodu ?? "CR-00") • \(cari.sehir ?? "Yetkili Yok")")
                            .font(.system(size: 11))
                            .foregroundColor(AppTheme.textMuted)
                        
                        Text(cari.cariTuru ?? "Müşteri")
                            .font(.system(size: 9, weight: .bold))
                            .foregroundColor(cari.cariTuru == "Tedarikçi" ? Color(hex: "FF9500") : Color(hex: "007AFF"))
                            .padding(.horizontal, 5)
                            .padding(.vertical, 1.5)
                            .background((cari.cariTuru == "Tedarikçi" ? Color(hex: "FF9500") : Color(hex: "007AFF")).opacity(0.15))
                            .cornerRadius(4)
                    }
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 2) {
                    Text(AppFormatters.money(cari.bakiye))
                        .font(.system(size: 13, weight: .heavy))
                        .foregroundColor(isPositive ? Color(hex: "00FF87") : (isNegative ? Color(hex: "FF453A") : AppTheme.textMuted))
                    
                    Text(isPositive ? "Alacak" : (isNegative ? "Borç" : "Sıfır"))
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(isPositive ? Color(hex: "00FF87") : (isNegative ? Color(hex: "FF453A") : AppTheme.textMuted))
                }
            }
        }
        .swipeActions(edge: .trailing, allowsFullSwipe: false) {
            Button {
                onTahsilat()
            } label: {
                Label("Tahsilat", systemImage: "arrow.down.left")
            }
            .tint(AppTheme.success)
            
            Button {
                onOdeme()
            } label: {
                Label("Ödeme", systemImage: "arrow.up.right")
            }
            .tint(AppTheme.danger)
        }
    }
}
