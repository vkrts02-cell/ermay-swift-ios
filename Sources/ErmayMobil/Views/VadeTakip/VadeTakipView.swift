import SwiftUI

public struct VadeTakipView: View {
    @State private var selectedDate: Date = Date()
    @State private var selectedTimeFilter: String = "Tümü"
    
    // Veriler
    @State private var vadeListesi: [VadeItem] = []
    
    // Modals & Actions
    @State private var selectedItemForAction: VadeItem? = nil
    @State private var showStatusModal: Bool = false
    @State private var showPostponeModal: Bool = false
    @State private var newPostponeDate: Date = Calendar.current.date(byAdding: .day, value: 15, to: Date()) ?? Date()
    
    private let timeFilters = ["Tümü", "Bugün", "Bu Hafta", "Bu Ay", "Gecikenler"]
    
    public init() {}
    
    public var filteredList: [VadeItem] {
        vadeListesi.filter { item in
            switch selectedTimeFilter {
            case "Gecikenler":
                return item.gecikmeGun > 0
            case "Bugün":
                return item.vadeTarihi == AppFormatters.shortDate.string(from: Date())
            default:
                return true
            }
        }
    }
    
    private var markedVadeDates: Set<String> {
        Set(vadeListesi.compactMap {
            if let d = AppFormatters.parseDate($0.vadeTarihi) {
                return AppFormatters.isoDate.string(from: d)
            }
            return nil
        })
    }
    
    public var body: some View {
        NavigationStack {
            ZStack {
                AppTheme.background.ignoresSafeArea()
                
                VStack(spacing: 12) {
                    // Header Bar
                    HStack {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Vade & Tahsilat Takvimi")
                                .font(.system(size: 22, weight: .bold))
                                .foregroundColor(AppTheme.textPrimary)
                            Text("Fatura, Çek ve Senet Vadeleri")
                                .font(.system(size: 11))
                                .foregroundColor(AppTheme.textMuted)
                        }
                        Spacer()
                    }
                    .padding(.horizontal)
                    .padding(.top, 6)
                    
                    ScrollView {
                        VStack(spacing: 14) {
                            // İnteraktif Apple Cam Takvim
                            IOSGlassCalendar(
                                selectedDate: $selectedDate,
                                markedDates: markedVadeDates
                            )
                            .padding(.horizontal)
                            
                            // Zaman Filtreleri
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 8) {
                                    ForEach(timeFilters, id: \.self) { filter in
                                        let isSelected = selectedTimeFilter == filter
                                        Button {
                                            selectedTimeFilter = filter
                                        } label: {
                                            Text(filter)
                                                .font(.system(size: 12, weight: isSelected ? .bold : .medium))
                                                .foregroundColor(isSelected ? .white : AppTheme.textSecondary)
                                                .padding(.horizontal, 14)
                                                .padding(.vertical, 7)
                                                .background(
                                                    RoundedRectangle(cornerRadius: 10)
                                                        .fill(isSelected ? AppTheme.primary : AppTheme.cardBackground)
                                                        .overlay(
                                                            RoundedRectangle(cornerRadius: 10)
                                                                .stroke(isSelected ? AppTheme.primary : AppTheme.border, lineWidth: 1)
                                                        )
                                                )
                                        }
                                    }
                                }
                                .padding(.horizontal)
                            }
                            
                            // Vade Kartları Listesi
                            VStack(spacing: 10) {
                                ForEach(filteredList) { item in
                                    let isGecikmis = item.gecikmeGun > 0
                                    let isAlacak = item.tip == "ALACAK"
                                    
                                    GlassCard(cornerRadius: 14, padding: 14) {
                                        VStack(spacing: 10) {
                                            HStack {
                                                StatusBadge(
                                                    title: isAlacak ? "ALACAK" : "BORÇ",
                                                    color: isAlacak ? AppTheme.success : AppTheme.danger
                                                )
                                                
                                                Spacer()
                                                
                                                if isGecikmis {
                                                    StatusBadge(
                                                        title: "\(item.gecikmeGun) GÜN GECİKTİ",
                                                        color: AppTheme.danger
                                                    )
                                                } else {
                                                    StatusBadge(
                                                        title: "VADESİ GELMEDİ",
                                                        color: AppTheme.info
                                                    )
                                                }
                                            }
                                            
                                            HStack(alignment: .bottom) {
                                                VStack(alignment: .leading, spacing: 3) {
                                                    Text(item.cariUnvan)
                                                        .font(.system(size: 14, weight: .bold))
                                                        .foregroundColor(AppTheme.textPrimary)
                                                    Text("Vade: \(item.vadeTarihi) • \(item.faturaNo ?? "")")
                                                        .font(.system(size: 11))
                                                        .foregroundColor(AppTheme.textMuted)
                                                }
                                                Spacer()
                                                Text(AppFormatters.money(item.kalanTutar))
                                                    .font(.system(size: 16, weight: .heavy))
                                                    .foregroundColor(isAlacak ? AppTheme.success : AppTheme.danger)
                                            }
                                            
                                            Divider().background(AppTheme.border)
                                            
                                            // Aksiyonlar
                                            HStack(spacing: 8) {
                                                Button {
                                                    selectedItemForAction = item
                                                    showPostponeModal = true
                                                } label: {
                                                    HStack(spacing: 4) {
                                                        Image(systemName: "calendar.badge.clock")
                                                        Text("Vadeyi Ertele")
                                                    }
                                                    .font(.system(size: 11, weight: .semibold))
                                                    .foregroundColor(AppTheme.warning)
                                                }
                                                
                                                Spacer()
                                                
                                                // WhatsApp Hatırlatıcı
                                                Button {
                                                    sendWhatsAppReminder(for: item)
                                                } label: {
                                                    HStack(spacing: 4) {
                                                        Image(systemName: "message.fill")
                                                        Text("WhatsApp Hatırlat")
                                                    }
                                                    .font(.system(size: 11, weight: .bold))
                                                    .foregroundColor(Color(hex: "25D366"))
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                            .padding(.horizontal)
                            
                            Spacer().frame(height: 70)
                        }
                    }
                }
                
                // Vade Erteleme Modalı
                renderPostponeModal()
            }
            .navigationBarHidden(true)
            .task {
                await loadVadeData()
            }
            .onReceive(NotificationCenter.default.publisher(for: .supabaseRealtimeDataChanged)) { _ in
                Task {
                    await loadVadeData()
                }
            }
        }
    }
    
    private func loadVadeData() async {
        do {
            let faturalar: [Fatura] = (try? await SupabaseService.shared.fetchFaturalar()) ?? []
            let cekler: [Cek] = (try? await SupabaseService.shared.fetch(from: "cekler")) ?? []
            let senetler: [Senet] = (try? await SupabaseService.shared.fetch(from: "senetler")) ?? []
            
            var items: [VadeItem] = []
            let now = Date()
            
            // Faturalardan vadeler
            for f in faturalar {
                let vStr = f.vadeTarihi ?? f.tarih
                let isSatis = f.faturaTuru.localizedCaseInsensitiveContains("satış")
                var gecikme = 0
                if let d = AppFormatters.parseDate(vStr) {
                    let diff = Calendar.current.dateComponents([.day], from: d, to: now).day ?? 0
                    if diff > 0 { gecikme = diff }
                }
                items.append(VadeItem(
                    id: f.id,
                    cariId: f.cariId,
                    cariUnvan: f.cariUnvan ?? "Cari",
                    faturaId: f.id,
                    faturaNo: f.faturaNo,
                    vadeTarihi: String(vStr.prefix(10)),
                    tutar: f.genelToplam,
                    kalanTutar: f.genelToplam,
                    tip: isSatis ? "ALACAK" : "BORC",
                    gecikmeGun: gecikme
                ))
            }
            
            // Çeklerden vadeler
            for c in cekler where c.durum != "TAHSIL_EDILDI" {
                var gecikme = 0
                if let d = AppFormatters.parseDate(c.vadeTarihi) {
                    let diff = Calendar.current.dateComponents([.day], from: d, to: now).day ?? 0
                    if diff > 0 { gecikme = diff }
                }
                items.append(VadeItem(
                    id: c.id,
                    cariId: c.cariId != nil ? String(c.cariId!) : nil,
                    cariUnvan: c.cariUnvan ?? (c.borclu ?? "Çek"),
                    faturaNo: c.cekNo,
                    vadeTarihi: String(c.vadeTarihi.prefix(10)),
                    tutar: c.tutar,
                    kalanTutar: c.tutar,
                    tip: (c.cekTuru ?? "ALINAN") == "ALINAN" ? "ALACAK" : "BORC",
                    gecikmeGun: gecikme
                ))
            }
            
            // Senetlerden vadeler
            for s in senetler where s.durum != "TAHSIL_EDILDI" {
                var gecikme = 0
                if let d = AppFormatters.parseDate(s.vadeTarihi) {
                    let diff = Calendar.current.dateComponents([.day], from: d, to: now).day ?? 0
                    if diff > 0 { gecikme = diff }
                }
                items.append(VadeItem(
                    id: s.id,
                    cariId: s.cariId != nil ? String(s.cariId!) : nil,
                    cariUnvan: s.cariUnvan ?? (s.borclu ?? "Senet"),
                    faturaNo: s.senetNo,
                    vadeTarihi: String(s.vadeTarihi.prefix(10)),
                    tutar: s.tutar,
                    kalanTutar: s.tutar,
                    tip: "ALACAK",
                    gecikmeGun: gecikme
                ))
            }
            
            await MainActor.run {
                self.vadeListesi = items
            }
        }
    }
    
    @ViewBuilder
    private func renderPostponeModal() -> some View {
        SwipeableModal(isPresented: $showPostponeModal, title: "Vade Tarihi Ertele") {
            if let item = selectedItemForAction {
                VStack(spacing: 14) {
                    Text("\(item.cariUnvan) - \(item.faturaNo ?? "")")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(AppTheme.textPrimary)
                    
                    HStack {
                        Text("Yeni Vade Tarihi")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundColor(AppTheme.textSecondary)
                        Spacer()
                        DatePicker("", selection: $newPostponeDate, displayedComponents: .date)
                            .labelsHidden()
                            .colorScheme(.dark)
                    }
                    
                    ActionButton(title: "Yeni Vadeyi Kaydet", icon: "checkmark.circle.fill", color: AppTheme.primary) {
                        if let idx = vadeListesi.firstIndex(where: { $0.id == item.id }) {
                            vadeListesi[idx].vadeTarihi = AppFormatters.shortDate.string(from: newPostponeDate)
                            vadeListesi[idx].gecikmeGun = 0
                        }
                        showPostponeModal = false
                        HardwareService.shared.hapticSuccess()
                    }
                }
            }
        }
    }
    
    private func sendWhatsAppReminder(for item: VadeItem) {
        let msg = "Sayın \(item.cariUnvan), \(item.faturaNo ?? "faturanıza") ait \(AppFormatters.money(item.kalanTutar)) tutarındaki ödemenizin vadesi \(item.vadeTarihi) tarihindedir. Bilgilerinize sunar, hayırlı işler dileriz."
        let encoded = msg.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        if let url = URL(string: "https://wa.me/?text=\(encoded)") {
            #if canImport(UIKit)
            UIApplication.shared.open(url)
            #endif
        }
    }
}
