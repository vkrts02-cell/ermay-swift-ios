import SwiftUI

public struct MusteriTakipView: View {
    @State private var klasorler: [MusteriTakipKlasor] = []
    @State private var detaylar: [MusteriTakipDetay] = []
    @State private var isLoading: Bool = false
    
    @State private var searchString: String = ""
    @State private var selectedEtiket: String = "Tümü"
    private let etiketler = ["Tümü", "Sıcak Müşteri", "Teklif Aşamasında", "Önemli", "Yeni İletişim", "Takipte"]
    
    // Modal to create new folder
    @State private var showNewFolderModal: Bool = false
    @State private var newCariUnvan: String = ""
    @State private var newYetkili: String = ""
    @State private var newTelefon: String = ""
    @State private var newEtiket: String = "Yeni İletişim"
    @State private var newRenk: String = "#0A84FF"
    
    public init() {}
    
    public var filteredKlasorler: [MusteriTakipKlasor] {
        klasorler.filter { k in
            let matchSearch = searchString.isEmpty ||
                k.cariUnvan.localizedCaseInsensitiveContains(searchString) ||
                (k.yetkili ?? "").localizedCaseInsensitiveContains(searchString) ||
                (k.etiket ?? "").localizedCaseInsensitiveContains(searchString) ||
                (k.cariKod ?? "").localizedCaseInsensitiveContains(searchString)
            if !matchSearch { return false }
            if selectedEtiket != "Tümü" && k.etiket != selectedEtiket { return false }
            return true
        }
    }
    
    private func getCounts(for klasorId: Int) -> (gorusme: Int, fiyat: Int, evrak: Int, not: Int) {
        let items = detaylar.filter { $0.klasorId == klasorId }
        let g = items.filter { $0.tip == "Gorusme" }.count
        let f = items.filter { $0.tip == "Fiyat" }.count
        let e = items.filter { $0.tip == "Gorsel" }.count
        let n = items.filter { $0.tip == "Not" }.count
        return (g, f, e, n)
    }
    
    public var body: some View {
        NavigationStack {
            ZStack {
                Color.black.ignoresSafeArea()
                
                VStack(spacing: 12) {
                    // Header Bar (Exact to MusteriTakipScreen.tsx)
                    HStack {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Müşteri Takip")
                                .font(.system(size: 24, weight: .heavy))
                                .foregroundColor(.white)
                                .tracking(-0.5)
                            Text("Müşteri bazlı görüşme, fiyat ve evrak arşivi")
                                .font(.system(size: 13, weight: .medium))
                                .foregroundColor(Color(hex: "94A3B8"))
                        }
                        
                        Spacer()
                        
                        Button {
                            showNewFolderModal = true
                        } label: {
                            HStack(spacing: 6) {
                                Image(systemName: "folder.badge.plus")
                                    .font(.system(size: 13, weight: .bold))
                                Text("Yeni Klasör")
                                    .font(.system(size: 13, weight: .bold))
                            }
                            .foregroundColor(.white)
                            .padding(.horizontal, 14)
                            .padding(.vertical, 8)
                            .background(Color(hex: "2563EB"))
                            .cornerRadius(10)
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 6)
                    
                    // Search Bar
                    HStack(spacing: 8) {
                        Image(systemName: "magnifyingglass")
                            .font(.system(size: 16))
                            .foregroundColor(Color(hex: "94A3B8"))
                        
                        TextField("Müşteri unvanı, yetkili veya etiket ara...", text: $searchString)
                            .font(.system(size: 14))
                            .foregroundColor(.white)
                        
                        if !searchString.isEmpty {
                            Button {
                                searchString = ""
                            } label: {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundColor(Color(hex: "94A3B8"))
                            }
                        }
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 10)
                    .background(Color(hex: "121216"))
                    .cornerRadius(12)
                    .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.white.opacity(0.08), lineWidth: 1))
                    .padding(.horizontal, 16)
                    
                    // Filter Chips (Tümü, Sıcak Müşteri, ...)
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            ForEach(etiketler, id: \.self) { etiket in
                                let isSelected = selectedEtiket == etiket
                                Button {
                                    selectedEtiket = etiket
                                } label: {
                                    Text(etiket)
                                        .font(.system(size: 12, weight: isSelected ? .bold : .medium))
                                        .foregroundColor(isSelected ? .white : Color(hex: "8E8E93"))
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 7)
                                        .background(isSelected ? Color(hex: "2563EB") : Color.white.opacity(0.05))
                                        .cornerRadius(8)
                                }
                            }
                        }
                        .padding(.horizontal, 16)
                    }
                    
                    // Folder List
                    ScrollView(showsIndicators: false) {
                        LazyVStack(spacing: 10) {
                            if filteredKlasorler.isEmpty {
                                Text("Aramanıza uygun müşteri klasörü bulunamadı.")
                                    .font(.system(size: 14))
                                    .foregroundColor(Color(hex: "64748B"))
                                    .padding(.top, 40)
                            } else {
                                ForEach(filteredKlasorler) { item in
                                    NavigationLink(destination: MusteriTakipDetayView(klasor: item)) {
                                        renderFolderCard(item: item)
                                    }
                                }
                            }
                            
                            Spacer().frame(height: 110)
                        }
                        .padding(.horizontal, 16)
                    }
                }
            }
            .navigationBarHidden(true)
            .sheet(isPresented: $showNewFolderModal) {
                newFolderSheet()
            }
            .task {
                await loadData()
            }
            .onReceive(NotificationCenter.default.publisher(for: .supabaseRealtimeDataChanged)) { _ in
                Task {
                    await loadData()
                }
            }
        }
    }
    
    // MARK: - Folder Card Component (Exact to MusteriTakipScreen.tsx)
    private func renderFolderCard(item: MusteriTakipKlasor) -> some View {
        let counts = getCounts(for: item.id)
        let folderColor = Color(hex: item.renk ?? "0A84FF")
        
        return VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .top, spacing: 12) {
                // Colored Folder Icon Box
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(folderColor.opacity(0.15))
                        .frame(width: 44, height: 44)
                    Image(systemName: "folder.fill")
                        .font(.system(size: 20))
                        .foregroundColor(folderColor)
                }
                
                VStack(alignment: .leading, spacing: 3) {
                    Text(item.cariUnvan)
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.white)
                        .lineLimit(1)
                    
                    Text("\(item.yetkili ?? "Yetkili Yok") • \(item.telefon ?? "-")")
                        .font(.system(size: 11))
                        .foregroundColor(Color(hex: "8E8E93"))
                        .lineLimit(1)
                }
                
                Spacer()
                
                // Etiket Badge
                Text(item.etiket ?? "Takipte")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundColor(folderColor)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .background(folderColor.opacity(0.12))
                    .cornerRadius(6)
            }
            
            Divider().background(Color.white.opacity(0.06))
            
            // 4 Mini Count Badges: Görüşme, Fiyat, Evrak, Not
            HStack(spacing: 8) {
                countBadge(title: "Görüşme", count: counts.gorusme, color: Color(hex: "0A84FF"))
                countBadge(title: "Fiyat", count: counts.fiyat, color: Color(hex: "30D158"))
                countBadge(title: "Evrak", count: counts.evrak, color: Color(hex: "BF5AF2"))
                countBadge(title: "Not", count: counts.not, color: Color(hex: "FF9F0A"))
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(Color(hex: "64748B"))
            }
        }
        .padding(14)
        .background(Color(hex: "121216"))
        .cornerRadius(16)
        .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.white.opacity(0.08), lineWidth: 1))
    }
    
    private func countBadge(title: String, count: Int, color: Color) -> some View {
        HStack(spacing: 4) {
            Text(title)
                .font(.system(size: 10, weight: .medium))
                .foregroundColor(Color(hex: "94A3B8"))
            Text("(\(count))")
                .font(.system(size: 10, weight: .bold))
                .foregroundColor(color)
        }
        .padding(.horizontal, 6)
        .padding(.vertical, 3)
        .background(Color.white.opacity(0.03))
        .cornerRadius(6)
    }
    
    // MARK: - New Folder Sheet
    private func newFolderSheet() -> some View {
        VStack(spacing: 16) {
            Text("Yeni Müşteri Klasörü")
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(.white)
                .padding(.top, 20)
            
            VStack(spacing: 12) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Müşteri / Cari Unvanı *").font(.system(size: 11, weight: .semibold)).foregroundColor(Color(hex: "8E8E93"))
                    TextField("Örn: Ermay Tekstil A.Ş.", text: $newCariUnvan)
                        .font(.system(size: 13))
                        .foregroundColor(.white)
                        .padding(10)
                        .background(Color.white.opacity(0.05))
                        .cornerRadius(8)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Yetkili Kişi").font(.system(size: 11, weight: .semibold)).foregroundColor(Color(hex: "8E8E93"))
                    TextField("Örn: Ahmet Bey", text: $newYetkili)
                        .font(.system(size: 13))
                        .foregroundColor(.white)
                        .padding(10)
                        .background(Color.white.opacity(0.05))
                        .cornerRadius(8)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Telefon").font(.system(size: 11, weight: .semibold)).foregroundColor(Color(hex: "8E8E93"))
                    TextField("Örn: 0532 000 0000", text: $newTelefon)
                        .font(.system(size: 13))
                        .foregroundColor(.white)
                        .padding(10)
                        .background(Color.white.opacity(0.05))
                        .cornerRadius(8)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Etiket").font(.system(size: 11, weight: .semibold)).foregroundColor(Color(hex: "8E8E93"))
                    Picker("Etiket", selection: $newEtiket) {
                        ForEach(etiketler.filter { $0 != "Tümü" }, id: \.self) { e in Text(e).tag(e) }
                    }
                    .pickerStyle(.menu)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(8)
                    .background(Color.white.opacity(0.05))
                    .cornerRadius(8)
                }
            }
            .padding(.horizontal, 20)
            
            Button {
                guard !newCariUnvan.isEmpty else { return }
                let newFolder = MusteriTakipKlasor(
                    id: Int.random(in: 1000...9999),
                    cariId: Int.random(in: 10...99),
                    cariUnvan: newCariUnvan,
                    cariKod: "CARI-\(Int.random(in: 100...999))",
                    telefon: newTelefon,
                    yetkili: newYetkili,
                    etiket: newEtiket,
                    renk: newRenk
                )
                klasorler.insert(newFolder, at: 0)
                Task {
                    _ = try? await SupabaseService.shared.insert(into: "musteri_takip_klasorler", item: newFolder)
                }
                newCariUnvan = ""
                newYetkili = ""
                newTelefon = ""
                showNewFolderModal = false
            } label: {
                Text("Klasörü Oluştur")
                    .font(.system(size: 15, weight: .bold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(Color(hex: "2563EB"))
                    .cornerRadius(12)
            }
            .padding(.horizontal, 20)
            .padding(.top, 10)
            
            Spacer()
        }
        .presentationDetents([.medium])
    }
    
    private func loadData() async {
        isLoading = true
        do {
            let kList: [MusteriTakipKlasor] = try await SupabaseService.shared.fetch(from: "musteri_takip_klasorler")
            let dList: [MusteriTakipDetay] = try await SupabaseService.shared.fetch(from: "musteri_takip_detaylar")
            await MainActor.run {
                self.klasorler = kList
                self.detaylar = dList
            }
        } catch {
            print("MusteriTakip fetch error: \(error)")
        }
        isLoading = false
    }
}
