import SwiftUI

public struct CariPickerSheet: View {
    @Environment(\.dismiss) private var dismiss
    @State private var cariler: [CariKart] = []
    @State private var searchText: String = ""
    @State private var isLoading: Bool = false
    public let onSelect: (CariKart) -> Void
    
    public init(onSelect: @escaping (CariKart) -> Void) {
        self.onSelect = onSelect
    }
    
    public var filteredCariler: [CariKart] {
        if searchText.isEmpty { return cariler }
        return cariler.filter {
            $0.unvan.localizedCaseInsensitiveContains(searchText) ||
            ($0.cariKodu?.localizedCaseInsensitiveContains(searchText) ?? false) ||
            ($0.sehir?.localizedCaseInsensitiveContains(searchText) ?? false)
        }
    }
    
    public var body: some View {
        NavigationStack {
            ZStack {
                AppTheme.background.ignoresSafeArea()
                
                VStack(spacing: 12) {
                    SearchBarView(text: $searchText, placeholder: "Cari unvanı, kod veya şehir ara...")
                        .padding(.horizontal)
                        .padding(.top, 8)
                    
                    if isLoading && cariler.isEmpty {
                        Spacer()
                        ProgressView().tint(AppTheme.primary)
                        Spacer()
                    } else if filteredCariler.isEmpty {
                        Spacer()
                        Text("Eşleşen cari bulunamadı")
                            .font(.system(size: 13))
                            .foregroundColor(AppTheme.textMuted)
                        Spacer()
                    } else {
                        List {
                            ForEach(filteredCariler) { cari in
                                Button {
                                    onSelect(cari)
                                    dismiss()
                                } label: {
                                    HStack(spacing: 12) {
                                        ZStack {
                                            Circle()
                                                .fill(AppTheme.primary.opacity(0.15))
                                                .frame(width: 38, height: 38)
                                            Text(String(cari.unvan.prefix(1)).uppercased())
                                                .font(.system(size: 14, weight: .bold))
                                                .foregroundColor(AppTheme.primary)
                                        }
                                        
                                        VStack(alignment: .leading, spacing: 2) {
                                            Text(cari.unvan)
                                                .font(.system(size: 13, weight: .bold))
                                                .foregroundColor(AppTheme.textPrimary)
                                                .lineLimit(1)
                                            Text(cari.cariTuru ?? "Müşteri")
                                                .font(.system(size: 10))
                                                .foregroundColor(AppTheme.textMuted)
                                        }
                                        
                                        Spacer()
                                        
                                        Text(AppFormatters.money(cari.bakiye))
                                            .font(.system(size: 12, weight: .bold))
                                            .foregroundColor(cari.bakiye == 0 ? AppTheme.textMuted : (cari.bakiyeTuru == "B" ? AppTheme.danger : AppTheme.success))
                                    }
                                }
                                .listRowBackground(Color.clear)
                                .listRowSeparator(.hidden)
                                .listRowInsets(EdgeInsets(top: 4, leading: 16, bottom: 4, trailing: 16))
                            }
                        }
                        .listStyle(.plain)
                    }
                }
            }
            .navigationTitle("Cari Kart Seçin")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Kapat") { dismiss() }
                        .foregroundColor(AppTheme.textSecondary)
                }
            }
            .task {
                await loadCariler()
            }
            .onChange(of: searchText) { newQuery in
                Task {
                    await performSearch(query: newQuery)
                }
            }
        }
    }
    
    private func performSearch(query: String) async {
        let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmed.isEmpty {
            if !DataStore.shared.cariler.isEmpty {
                await MainActor.run { self.cariler = DataStore.shared.cariler }
            } else if let cached = try? await LocalDatabaseService.shared.fetchCariler(), !cached.isEmpty {
                await MainActor.run { self.cariler = cached }
            }
            return
        }
        if let dbResults = try? await LocalDatabaseService.shared.searchCariler(query: trimmed, limit: 50), !dbResults.isEmpty {
            await MainActor.run { self.cariler = dbResults }
        }
    }
    
    private func loadCariler() async {
        // 1. Önce yerel SQLite veya DataStore önbelleğinden anında yükle (Offline destekli)
        if !DataStore.shared.cariler.isEmpty {
            await MainActor.run { self.cariler = DataStore.shared.cariler }
        } else if let cached = try? await LocalDatabaseService.shared.fetchCariler(), !cached.isEmpty {
            await MainActor.run { self.cariler = cached }
        } else {
            await MainActor.run { isLoading = true }
        }
        
        // 2. Arka planda buluttan güncel veriyi çek ve yerel önbelleği besle
        do {
            let items: [CariKart] = try await SupabaseService.shared.fetchCariler()
            try? await LocalDatabaseService.shared.upsertCariler(items)
            await MainActor.run {
                if searchText.isEmpty {
                    self.cariler = items
                }
            }
        } catch {
            print("[CariPickerSheet] Çevrimdışı mod — yerel önbellek kullanılıyor: \(error.localizedDescription)")
        }
        await MainActor.run { isLoading = false }
    }
}

public struct StokPickerSheet: View {
    @Environment(\.dismiss) private var dismiss
    @State private var stoklar: [StokKart] = []
    @State private var searchText: String = ""
    @State private var isLoading: Bool = false
    public let onSelect: (StokKart) -> Void
    
    public init(onSelect: @escaping (StokKart) -> Void) {
        self.onSelect = onSelect
    }
    
    public var filteredStoklar: [StokKart] {
        if searchText.isEmpty { return stoklar }
        return stoklar.filter {
            $0.stokAdi.localizedCaseInsensitiveContains(searchText) ||
            ($0.stokKodu?.localizedCaseInsensitiveContains(searchText) ?? false) ||
            ($0.barkod?.localizedCaseInsensitiveContains(searchText) ?? false)
        }
    }
    
    public var body: some View {
        NavigationStack {
            ZStack {
                AppTheme.background.ignoresSafeArea()
                
                VStack(spacing: 12) {
                    SearchBarView(text: $searchText, placeholder: "Ürün adı, barkod veya kod ara...")
                        .padding(.horizontal)
                        .padding(.top, 8)
                    
                    if isLoading && stoklar.isEmpty {
                        Spacer()
                        ProgressView().tint(AppTheme.primary)
                        Spacer()
                    } else if filteredStoklar.isEmpty {
                        Spacer()
                        Text("Eşleşen stok kartı bulunamadı")
                            .font(.system(size: 13))
                            .foregroundColor(AppTheme.textMuted)
                        Spacer()
                    } else {
                        List {
                            ForEach(filteredStoklar) { stok in
                                Button {
                                    onSelect(stok)
                                    dismiss()
                                } label: {
                                    HStack(spacing: 12) {
                                        ZStack {
                                            Circle()
                                                .fill(AppTheme.purple.opacity(0.15))
                                                .frame(width: 38, height: 38)
                                            Image(systemName: "shippingbox.fill")
                                                .font(.system(size: 14))
                                                .foregroundColor(AppTheme.purple)
                                        }
                                        
                                        VStack(alignment: .leading, spacing: 2) {
                                            Text(stok.stokAdi)
                                                .font(.system(size: 13, weight: .bold))
                                                .foregroundColor(AppTheme.textPrimary)
                                                .lineLimit(1)
                                            Text("Stok: \(String(format: "%.0f", stok.mevcutMiktar)) \(stok.birim ?? "Adet")")
                                                .font(.system(size: 10))
                                                .foregroundColor(AppTheme.textMuted)
                                        }
                                        
                                        Spacer()
                                        
                                        VStack(alignment: .trailing, spacing: 2) {
                                            Text(AppFormatters.money(stok.satisFiyati))
                                                .font(.system(size: 12, weight: .bold))
                                                .foregroundColor(AppTheme.textPrimary)
                                            Text("KDV: %\(Int(stok.kdvOrani))")
                                                .font(.system(size: 10))
                                                .foregroundColor(AppTheme.textSecondary)
                                        }
                                    }
                                }
                                .listRowBackground(Color.clear)
                                .listRowSeparator(.hidden)
                                .listRowInsets(EdgeInsets(top: 4, leading: 16, bottom: 4, trailing: 16))
                            }
                        }
                        .listStyle(.plain)
                    }
                }
            }
            .navigationTitle("Ürün / Stok Kalemi Seçin")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Kapat") { dismiss() }
                        .foregroundColor(AppTheme.textSecondary)
                }
            }
            .task {
                await loadStoklar()
            }
            .onChange(of: searchText) { newQuery in
                Task {
                    await performSearch(query: newQuery)
                }
            }
        }
    }
    
    private func performSearch(query: String) async {
        let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmed.isEmpty {
            if !DataStore.shared.stoklar.isEmpty {
                await MainActor.run { self.stoklar = DataStore.shared.stoklar }
            } else if let cached = try? await LocalDatabaseService.shared.fetchStoklar(), !cached.isEmpty {
                await MainActor.run { self.stoklar = cached }
            }
            return
        }
        if let dbResults = try? await LocalDatabaseService.shared.searchStoklar(query: trimmed, limit: 50), !dbResults.isEmpty {
            await MainActor.run { self.stoklar = dbResults }
        }
    }
    
    @MainActor
    private func loadStoklar() async {
        // 1. Önce yerel SQLite veya DataStore önbelleğinden anında yükle (Offline destekli)
        if !DataStore.shared.stoklar.isEmpty {
            self.stoklar = DataStore.shared.stoklar
        } else if let cached = try? await LocalDatabaseService.shared.fetchStoklar(), !cached.isEmpty {
            self.stoklar = cached
        } else {
            isLoading = true
        }
        
        // 2. Arka planda buluttan güncel veriyi çek ve yerel önbelleği besle
        do {
            let items: [StokKart] = try await SupabaseService.shared.fetchStoklar()
            try? await LocalDatabaseService.shared.upsertStoklar(items)
            if searchText.isEmpty {
                self.stoklar = items
            }
        } catch {
            print("[StokPickerSheet] Çevrimdışı mod — yerel önbellek kullanılıyor: \(error.localizedDescription)")
        }
        isLoading = false
    }
}

