import SwiftUI

public struct CekSenetListView: View {
    @State private var cekler: [Cek] = []
    @State private var senetler: [Senet] = []
    @State private var selectedTab: Int = 0 // 0: Çekler, 1: Senetler
    @State private var filterDurum: String = "Tümü"
    @State private var searchText: String = ""
    @State private var isLoading: Bool = false
    @State private var showAddSheet: Bool = false
    
    private let durumlar = ["Tümü", "PORTFOYDE", "BANKADA", "TAHSIL_EDILDI", "KARSILIKSIZ"]
    
    public init() {}
    
    public var filteredCekler: [Cek] {
        cekler.filter { c in
            let matchSearch = searchText.isEmpty ||
                (c.cekNo?.localizedCaseInsensitiveContains(searchText) ?? false) ||
                (c.cariUnvan?.localizedCaseInsensitiveContains(searchText) ?? false) ||
                (c.banka?.localizedCaseInsensitiveContains(searchText) ?? false)
            if !matchSearch { return false }
            if filterDurum != "Tümü" {
                return c.durum == filterDurum
            }
            return true
        }
    }

    public var filteredSenetler: [Senet] {
        senetler.filter { s in
            let matchSearch = searchText.isEmpty ||
                (s.senetNo?.localizedCaseInsensitiveContains(searchText) ?? false) ||
                (s.cariUnvan?.localizedCaseInsensitiveContains(searchText) ?? false)
            if !matchSearch { return false }
            if filterDurum != "Tümü" {
                return s.durum == filterDurum
            }
            return true
        }
    }
    
    public var toplamCekTutari: Double {
        if selectedTab == 0 {
            return cekler.filter { $0.durum != "TAHSIL_EDILDI" }.reduce(0.0) { $0 + $1.tutar }
        } else {
            return senetler.filter { $0.durum != "TAHSIL_EDILDI" }.reduce(0.0) { $0 + $1.tutar }
        }
    }
    
    public var body: some View {
        NavigationStack {
            ZStack {
                AppTheme.background.ignoresSafeArea()
                
                VStack(spacing: 14) {
                    // Header Bar
                    HStack {
                        Text("Çek & Senet Takibi")
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
                    
                    // Özet Portföy Kartı
                    GlassCard(cornerRadius: 16, padding: 16) {
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("PORTFÖYDEKİ TOPLAM")
                                    .font(.system(size: 11, weight: .bold))
                                    .foregroundColor(AppTheme.textSecondary)
                                Text(AppFormatters.money(toplamCekTutari))
                                    .font(.system(size: 24, weight: .heavy))
                                    .foregroundColor(AppTheme.textPrimary)
                            }
                            Spacer()
                            Image(systemName: "banknote.fill")
                                .font(.system(size: 28))
                                .foregroundColor(AppTheme.warning)
                        }
                    }
                    .padding(.horizontal)
                    
                    // Segment Kontrolü: Çekler / Senetler
                    Picker("", selection: $selectedTab) {
                        Text("Çekler").tag(0)
                        Text("Senetler").tag(1)
                    }
                    .pickerStyle(.segmented)
                    .padding(.horizontal)
                    
                    // Arama Çubuğu
                    SearchBarView(text: $searchText, placeholder: "Çek no, borçlu veya banka ara...")
                        .padding(.horizontal)
                    
                    // Durum Filtresi
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            ForEach(durumlar, id: \.self) { d in
                                let isSelected = filterDurum == d
                                Button {
                                    filterDurum = d
                                } label: {
                                    Text(d.replacingOccurrences(of: "_", with: " "))
                                        .font(.system(size: 12, weight: isSelected ? .bold : .medium))
                                        .foregroundColor(isSelected ? .white : AppTheme.textSecondary)
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 6)
                                        .background(
                                            RoundedRectangle(cornerRadius: 8)
                                                .fill(isSelected ? AppTheme.primary : AppTheme.cardBackground)
                                        )
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                    
                    // Liste
                    let isEmptyList = (selectedTab == 0 ? filteredCekler.isEmpty : filteredSenetler.isEmpty)
                    if isLoading && (cekler.isEmpty && senetler.isEmpty) {
                        Spacer()
                        ProgressView().tint(AppTheme.primary)
                        Spacer()
                    } else if isEmptyList {
                        Spacer()
                        VStack(spacing: 8) {
                            Image(systemName: "tray")
                                .font(.system(size: 36))
                                .foregroundColor(AppTheme.textMuted)
                            Text(selectedTab == 0 ? "Kayıtlı çek bulunamadı" : "Kayıtlı senet bulunamadı")
                                .font(.system(size: 13))
                                .foregroundColor(AppTheme.textSecondary)
                        }
                        Spacer()
                    } else {
                        List {
                            if selectedTab == 0 {
                                ForEach(filteredCekler) { c in
                                    CekRowItem(cek: c) { newDurum in
                                        updateDurum(cekId: c.id, durum: newDurum)
                                    }
                                    .listRowBackground(Color.clear)
                                    .listRowSeparator(.hidden)
                                    .listRowInsets(EdgeInsets(top: 4, leading: 16, bottom: 4, trailing: 16))
                                }
                            } else {
                                ForEach(filteredSenetler) { s in
                                    SenetRowItem(senet: s)
                                        .listRowBackground(Color.clear)
                                        .listRowSeparator(.hidden)
                                        .listRowInsets(EdgeInsets(top: 4, leading: 16, bottom: 4, trailing: 16))
                                }
                            }
                        }
                        .listStyle(.plain)
                        .refreshable {
                            await loadData()
                        }
                    }
                }
            }
            .navigationBarHidden(true)
            .sheet(isPresented: $showAddSheet) {
                YeniCekFormView { newCek in
                    cekler.insert(newCek, at: 0)
                }
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
    
    private func loadData() async {
        isLoading = true
        do {
            let cItems: [Cek] = try await SupabaseService.shared.fetch(from: "cekler", orderBy: "vade_tarihi.asc")
            let sItems: [Senet] = try await SupabaseService.shared.fetch(from: "senetler", orderBy: "vade_tarihi.asc")
            await MainActor.run {
                self.cekler = cItems
                self.senetler = sItems
            }
        } catch {
            print("Cek/Senet fetch error: \(error)")
        }
        isLoading = false
    }
    
    private func updateDurum(cekId: String, durum: String) {
        if let idx = cekler.firstIndex(where: { $0.id == cekId }) {
            cekler[idx].durum = durum
            Task {
                try? await SupabaseService.shared.update(table: "cekler", id: cekId, item: ["durum": durum])
            }
        }
    }
}

struct CekRowItem: View {
    let cek: Cek
    let onDurumChange: (String) -> Void
    
    var durumColor: Color {
        switch cek.durum {
        case "PORTFOYDE": return AppTheme.warning
        case "BANKADA": return AppTheme.primary
        case "TAHSIL_EDILDI": return AppTheme.success
        case "KARSILIKSIZ": return AppTheme.danger
        default: return AppTheme.textMuted
        }
    }
    
    var body: some View {
        GlassCard(cornerRadius: 14, padding: 14) {
            VStack(spacing: 10) {
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(cek.cekNo ?? "ÇEK")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(AppTheme.textPrimary)
                        Text(cek.cariUnvan ?? "-")
                            .font(.system(size: 12))
                            .foregroundColor(AppTheme.textSecondary)
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .trailing, spacing: 2) {
                        Text(AppFormatters.money(cek.tutar))
                            .font(.system(size: 15, weight: .heavy))
                            .foregroundColor(AppTheme.textPrimary)
                        Text("Vade: \(cek.vadeTarihi)")
                            .font(.system(size: 10, weight: .medium))
                            .foregroundColor(AppTheme.textMuted)
                    }
                }
                
                Divider().background(AppTheme.border)
                
                HStack {
                    HStack(spacing: 4) {
                        Image(systemName: "building.columns")
                            .font(.system(size: 11))
                            .foregroundColor(AppTheme.textMuted)
                        Text(cek.banka ?? "Banka Belirtilmedi")
                            .font(.system(size: 11))
                            .foregroundColor(AppTheme.textSecondary)
                    }
                    
                    Spacer()
                    
                    Menu {
                        Button("Portföyde") { onDurumChange("PORTFOYDE") }
                        Button("Bankaya Verildi") { onDurumChange("BANKADA") }
                        Button("Tahsil Edildi") { onDurumChange("TAHSIL_EDILDI") }
                        Button("Karşılıksız") { onDurumChange("KARSILIKSIZ") }
                    } label: {
                        Text(cek.durum.replacingOccurrences(of: "_", with: " "))
                            .font(.system(size: 10, weight: .bold))
                            .foregroundColor(durumColor)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(durumColor.opacity(0.15))
                            .cornerRadius(6)
                    }
                }
            }
        }
    }
}

struct SenetRowItem: View {
    let senet: Senet
    
    var durumColor: Color {
        switch senet.durum {
        case "PORTFOYDE": return AppTheme.warning
        case "TAHSIL_EDILDI": return AppTheme.success
        case "PROTESTOLU": return AppTheme.danger
        default: return AppTheme.textMuted
        }
    }
    
    var body: some View {
        GlassCard(cornerRadius: 14, padding: 14) {
            VStack(spacing: 10) {
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(senet.senetNo ?? "SENET")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(AppTheme.textPrimary)
                        Text(senet.cariUnvan ?? "-")
                            .font(.system(size: 12))
                            .foregroundColor(AppTheme.textSecondary)
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .trailing, spacing: 2) {
                        Text(AppFormatters.money(senet.tutar))
                            .font(.system(size: 15, weight: .heavy))
                            .foregroundColor(AppTheme.textPrimary)
                        Text("Vade: \(senet.vadeTarihi)")
                            .font(.system(size: 10, weight: .medium))
                            .foregroundColor(AppTheme.textMuted)
                    }
                }
                
                Divider().background(AppTheme.border)
                
                HStack {
                    HStack(spacing: 4) {
                        Image(systemName: "person.text.rectangle")
                            .font(.system(size: 11))
                            .foregroundColor(AppTheme.textMuted)
                        Text(senet.borclu ?? "Borçlu Belirtilmedi")
                            .font(.system(size: 11))
                            .foregroundColor(AppTheme.textSecondary)
                    }
                    
                    Spacer()
                    
                    Text(senet.durum.replacingOccurrences(of: "_", with: " "))
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(durumColor)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(durumColor.opacity(0.15))
                        .cornerRadius(6)
                }
            }
        }
    }
}

struct YeniCekFormView: View {
    @Environment(\.dismiss) private var dismiss
    public let onSave: (Cek) -> Void
    
    @State private var cekNo: String = "CK-\(Int.random(in: 10000...99999))"
    @State private var cariUnvan: String = ""
    @State private var tutar: String = ""
    @State private var banka: String = ""
    @State private var vadeTarihi: Date = Date().addingTimeInterval(86400 * 30)
    @State private var borclu: String = ""
    @State private var aciklama: String = ""
    
    var body: some View {
        NavigationStack {
            ZStack {
                AppTheme.background.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 16) {
                        GlassCard(cornerRadius: 16, padding: 18) {
                            VStack(spacing: 14) {
                                FormField(label: "Çek Numarası *", text: $cekNo, placeholder: "CK-12345")
                                FormField(label: "Cari / Müşteri Ünvanı *", text: $cariUnvan, placeholder: "Firma adı...")
                                FormField(label: "Tutar (₺) *", text: $tutar, placeholder: "0.00")
                                FormField(label: "Banka Adı", text: $banka, placeholder: "Örn: Garanti BBVA")
                                FormField(label: "Asıl Borçlu / Keşideci", text: $borclu, placeholder: "Ad Soyad...")
                                
                                DatePicker("Vade Tarihi", selection: $vadeTarihi, displayedComponents: .date)
                                    .foregroundColor(AppTheme.textPrimary)
                                    .padding(.vertical, 4)
                                
                                FormField(label: "Açıklama", text: $aciklama, placeholder: "Not...")
                            }
                        }
                        
                        ActionButton(
                            title: "Çeki Portföye Kaydet",
                            icon: "checkmark.circle.fill",
                            color: AppTheme.success
                        ) {
                            let tutarNum = Double(tutar) ?? 0.0
                            let df = DateFormatter()
                            df.dateFormat = "dd.MM.yyyy"
                            let c = Cek(
                                id: UUID().uuidString,
                                cekNo: cekNo,
                                cariUnvan: cariUnvan,
                                vadeTarihi: df.string(from: vadeTarihi),
                                tutar: tutarNum,
                                borclu: borclu,
                                banka: banka,
                                durum: "PORTFOYDE",
                                aciklama: aciklama
                            )
                            onSave(c)
                            Task {
                                try? await SupabaseService.shared.insertRaw(into: "cekler", data: (try? JSONEncoder().encode(c)) ?? Data())
                            }
                            dismiss()
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("Yeni Çek Girişi")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("İptal") { dismiss() }
                        .foregroundColor(AppTheme.textSecondary)
                }
            }
        }
    }
}

