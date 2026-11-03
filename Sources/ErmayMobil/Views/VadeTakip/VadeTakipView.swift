import SwiftUI

public struct VadeTakipView: View {
    @State private var selectedDate: Date = Date()
    @State private var selectedTimeFilter: String = "Tümü"
    
    // Veriler
    @State private var vadeListesi: [VadeItem] = [
        VadeItem(cariUnvan: "Ermay Ltd. Şti.", faturaNo: "FTR-2026-0012", vadeTarihi: "25.10.2026", tutar: 24500, kalanTutar: 24500, tip: "ALACAK", gecikmeGun: 9),
        VadeItem(cariUnvan: "Akıncılar Çelik Döküm", faturaNo: "FTR-2026-0008", vadeTarihi: "28.10.2026", tutar: 18000, kalanTutar: 18000, tip: "BORC", gecikmeGun: 6),
        VadeItem(cariUnvan: "Mega Plastik San.", faturaNo: "FTR-2026-0015", vadeTarihi: "05.11.2026", tutar: 12000, kalanTutar: 12000, tip: "ALACAK", gecikmeGun: 0),
        VadeItem(cariUnvan: "Yıldız Lojistik", faturaNo: "FTR-2026-0019", vadeTarihi: "15.11.2026", tutar: 6500, kalanTutar: 6500, tip: "BORC", gecikmeGun: 0),
        VadeItem(cariUnvan: "Kaya Metal A.Ş.", faturaNo: "FTR-2026-0022", vadeTarihi: "20.11.2026", tutar: 34000, kalanTutar: 34000, tip: "ALACAK", gecikmeGun: 0)
    ]
    
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
