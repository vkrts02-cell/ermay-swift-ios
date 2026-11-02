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
                        Text("Cari Hesaplar")
                            .font(.system(size: 24, weight: .bold))
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
                    
                    // Sıralama & Tablo Başlık Barı
                    HStack {
                        Text(sortByBakiye ? "Ünvan / Cari" : "Ünvan / Cari (A-Z)")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(AppTheme.textSecondary)
                        
                        Spacer()
                        
                        HStack(spacing: 6) {
                            Button {
                                if selectedFilter == "Müşteri" {
                                    selectedFilter = "Tedarikçi"
                                } else if selectedFilter == "Tedarikçi" {
                                    selectedFilter = "Tümü"
                                } else {
                                    selectedFilter = "Müşteri"
                                }
                            } label: {
                                Text(selectedFilter == "Tümü" ? "Grup ⇅" : selectedFilter)
                                    .font(.system(size: 11, weight: .semibold))
                                    .foregroundColor(selectedFilter != "Tümü" ? AppTheme.primary : AppTheme.textMuted)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(AppTheme.cardBackground)
                                    .cornerRadius(6)
                            }
                            
                            Button {
                                if sortByBakiye {
                                    bakiyeSortDesc.toggle()
                                } else {
                                    sortByBakiye = true
                                    bakiyeSortDesc = true
                                }
                            } label: {
                                HStack(spacing: 2) {
                                    Text("Bakiye")
                                    Image(systemName: sortByBakiye ? (bakiyeSortDesc ? "arrow.down" : "arrow.up") : "arrow.up.arrow.down")
                                }
                                .font(.system(size: 11, weight: .semibold))
                                .foregroundColor(sortByBakiye ? Color(hex: "00FF87") : AppTheme.textMuted)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(AppTheme.cardBackground)
                                .cornerRadius(6)
                            }
                        }
                    }
                    .padding(.horizontal)
                    
                    // Cariler Listesi
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
                            ForEach(filteredCariler) { cari in
                                NavigationLink(destination: CariDetailView(cari: cari)) {
                                    UtilitarianCariRowItem(
                                        cari: cari,
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
                ContactPickerBridge { result in
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
            print("Cari fetch error: \(error)")
            if cariler.isEmpty {
                cariler = [
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

struct UtilitarianCariRowItem: View {
    let cari: CariKart
    let onTahsilat: () -> Void
    let onOdeme: () -> Void
    
    var monogram: String {
        let words = cari.unvan.split(separator: " ")
        if words.count >= 2 {
            return "\(words[0].prefix(1))\(words[1].prefix(1))".uppercased()
        }
        return String(cari.unvan.prefix(2)).uppercased()
    }
    
    var body: some View {
        GlassCard(cornerRadius: 14, padding: 14) {
            HStack(spacing: 12) {
                // Monogram Yuvarlak Avatar
                ZStack {
                    Circle()
                        .fill(AppTheme.primary.opacity(0.15))
                        .frame(width: 42, height: 42)
                    
                    Text(monogram)
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(AppTheme.primary)
                }
                
                VStack(alignment: .leading, spacing: 3) {
                    Text(cari.unvan)
                        .font(.system(size: 13, weight: .bold))
                        .foregroundColor(AppTheme.textPrimary)
                        .lineLimit(1)
                    
                    HStack(spacing: 6) {
                        Text(cari.cariTuru ?? "Müşteri")
                            .font(.system(size: 9, weight: .bold))
                            .foregroundColor(AppTheme.textMuted)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(AppTheme.cardSecondary)
                            .cornerRadius(4)
                        
                        if let sehir = cari.sehir, !sehir.isEmpty {
                            Text("•  \(sehir)")
                                .font(.system(size: 10))
                                .foregroundColor(AppTheme.textSecondary)
                        }
                    }
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 2) {
                    Text(AppFormatters.money(cari.bakiye))
                        .font(.system(size: 13, weight: .heavy))
                        .foregroundColor(cari.bakiye == 0 ? AppTheme.textMuted : (cari.bakiyeTuru == "B" ? AppTheme.danger : AppTheme.success))
                    
                    Text(cari.bakiye == 0 ? "Bakiye Yok" : (cari.bakiyeTuru == "B" ? "Borçlu" : "Alacaklı"))
                        .font(.system(size: 9, weight: .bold))
                        .foregroundColor(cari.bakiye == 0 ? AppTheme.textMuted : (cari.bakiyeTuru == "B" ? AppTheme.danger : AppTheme.success))
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
