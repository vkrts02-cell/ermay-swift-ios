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
            if cariler.isEmpty {
                cariler = [
                    CariKart(cariKodu: "CR-001", unvan: "Ermay Bilişim San. Tic. Ltd. Şti.", cariTuru: "Müşteri", bakiye: 45200.0, bakiyeTuru: "A"),
                    CariKart(cariKodu: "CR-002", unvan: "Akıncılar Çelik & Alüminyum Döküm A.Ş.", cariTuru: "Tedarikçi", bakiye: 18500.0, bakiyeTuru: "B"),
                    CariKart(cariKodu: "CR-003", unvan: "Mega Plastik İthalat İhracat Ltd.", cariTuru: "Müşteri", bakiye: 8900.0, bakiyeTuru: "A")
                ]
            }
        }
        isLoading = false
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
                    StokKart(stokKodu: "STK-001", stokAdi: "Endüstriyel Rulman 6204-2RS", birim: "Adet", alisFiyati: 280.0, satisFiyati: 450.0, kdvOrani: 20, mevcutMiktar: 120.0),
                    StokKart(stokKodu: "STK-002", stokAdi: "Paslanmaz Çelik Civata M8x30", birim: "Adet", alisFiyati: 12.0, satisFiyati: 24.0, kdvOrani: 20, mevcutMiktar: 450.0),
                    StokKart(stokKodu: "STK-003", stokAdi: "Yüksek Basınç Hidrolik Yağı 20L", birim: "Teneke", alisFiyati: 1400.0, satisFiyati: 2100.0, kdvOrani: 20, mevcutMiktar: 15.0)
                ]
            }
        }
        isLoading = false
    }
}

