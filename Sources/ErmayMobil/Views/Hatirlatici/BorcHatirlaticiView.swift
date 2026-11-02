import SwiftUI
#if canImport(UserNotifications)
import UserNotifications
#endif

public struct HatirlaticiItem: Identifiable, Sendable {
    public let id: String
    public let cariUnvan: String
    public let telefon: String?
    public let belgeNo: String
    public let vadeTarihi: String
    public let tutar: Double
    public let gecikmeGunu: Int
    public let tur: String // "ALACAK", "BORC"
}

public struct BorcHatirlaticiView: View {
    @State private var hatirlaticilar: [HatirlaticiItem] = []
    @State private var selectedFilter: String = "Gecikenler"
    @State private var isLoading: Bool = false
    @State private var sentNotice: String? = nil
    
    private let filters = ["Tümü", "Gecikenler", "Yaklaşanlar"]
    
    public init() {}
    
    public var filteredItems: [HatirlaticiItem] {
        hatirlaticilar.filter { item in
            if selectedFilter == "Gecikenler" {
                return item.gecikmeGunu > 0
            } else if selectedFilter == "Yaklaşanlar" {
                return item.gecikmeGunu <= 0
            }
            return true
        }
    }
    
    public var body: some View {
        NavigationStack {
            ZStack {
                AppTheme.background.ignoresSafeArea()
                
                VStack(spacing: 14) {
                    HStack {
                        Text("Borç & Vade Hatırlatıcı")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(AppTheme.textPrimary)
                        Spacer()
                    }
                    .padding(.horizontal)
                    .padding(.top, 8)
                    
                    if let notice = sentNotice {
                        Text(notice)
                            .font(.system(size: 11, weight: .bold))
                            .foregroundColor(AppTheme.success)
                            .padding(.horizontal, 14)
                            .padding(.vertical, 6)
                            .background(AppTheme.success.opacity(0.15))
                            .cornerRadius(8)
                    }
                    
                    // Filtreleme
                    HStack(spacing: 8) {
                        ForEach(filters, id: \.self) { f in
                            let isSel = selectedFilter == f
                            Button {
                                selectedFilter = f
                            } label: {
                                Text(f)
                                    .font(.system(size: 12, weight: isSel ? .bold : .medium))
                                    .foregroundColor(isSel ? .white : AppTheme.textSecondary)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 8)
                                    .background(isSel ? AppTheme.primary : AppTheme.cardBackground)
                                    .cornerRadius(8)
                            }
                        }
                    }
                    .padding(.horizontal)
                    
                    // Liste
                    List {
                        ForEach(filteredItems) { item in
                            GlassCard(cornerRadius: 14, padding: 14) {
                                VStack(spacing: 10) {
                                    HStack {
                                        VStack(alignment: .leading, spacing: 2) {
                                            Text(item.cariUnvan)
                                                .font(.system(size: 14, weight: .bold))
                                                .foregroundColor(AppTheme.textPrimary)
                                                .lineLimit(1)
                                            Text("\(item.belgeNo) • Vade: \(item.vadeTarihi)")
                                                .font(.system(size: 11))
                                                .foregroundColor(AppTheme.textMuted)
                                        }
                                        Spacer()
                                        VStack(alignment: .trailing, spacing: 2) {
                                            Text(AppFormatters.money(item.tutar))
                                                .font(.system(size: 14, weight: .heavy))
                                                .foregroundColor(AppTheme.danger)
                                            Text(item.gecikmeGunu > 0 ? "\(item.gecikmeGunu) Gün Gecikti" : "Vadeye Yakın")
                                                .font(.system(size: 10, weight: .bold))
                                                .foregroundColor(item.gecikmeGunu > 0 ? AppTheme.danger : AppTheme.warning)
                                        }
                                    }
                                    
                                    Divider().background(AppTheme.border)
                                    
                                    HStack(spacing: 10) {
                                        Button {
                                            sendWhatsAppReminder(item)
                                        } label: {
                                            HStack(spacing: 4) {
                                                Image(systemName: "message.fill")
                                                Text("WhatsApp Hatırlat")
                                            }
                                            .font(.system(size: 11, weight: .bold))
                                            .foregroundColor(Color(hex: "25D366"))
                                            .padding(.horizontal, 10)
                                            .padding(.vertical, 6)
                                            .background(Color(hex: "25D366").opacity(0.12))
                                            .cornerRadius(6)
                                        }
                                        
                                        Button {
                                            scheduleLocalNotification(item)
                                        } label: {
                                            HStack(spacing: 4) {
                                                Image(systemName: "bell.badge.fill")
                                                Text("Alarm Kur")
                                            }
                                            .font(.system(size: 11, weight: .semibold))
                                            .foregroundColor(AppTheme.primary)
                                            .padding(.horizontal, 10)
                                            .padding(.vertical, 6)
                                            .background(AppTheme.primary.opacity(0.12))
                                            .cornerRadius(6)
                                        }
                                        
                                        Spacer()
                                    }
                                }
                            }
                            .listRowBackground(Color.clear)
                            .listRowSeparator(.hidden)
                            .listRowInsets(EdgeInsets(top: 4, leading: 16, bottom: 4, trailing: 16))
                        }
                    }
                    .listStyle(.plain)
                    
                    Spacer().frame(height: 70)
                }
            }
            .navigationBarHidden(true)
            .task {
                await loadReminders()
            }
        }
    }
    
    private func loadReminders() async {
        isLoading = true
        do {
            let cariler: [CariKart] = try await SupabaseService.shared.fetch(from: "cariler")
            let list = cariler.filter { $0.bakiye > 0 && $0.bakiyeTuru == "A" }.map { c in
                HatirlaticiItem(
                    id: c.id,
                    cariUnvan: c.unvan,
                    telefon: c.gsm ?? c.telefon,
                    belgeNo: "FTR-2026-\(Int.random(in: 100...999))",
                    vadeTarihi: "28.10.2026",
                    tutar: c.bakiye,
                    gecikmeGunu: 5,
                    tur: "ALACAK"
                )
            }
            await MainActor.run {
                self.hatirlaticilar = list.isEmpty ? sampleReminders : list
            }
        } catch {
            hatirlaticilar = sampleReminders
        }
        isLoading = false
    }
    
    private var sampleReminders: [HatirlaticiItem] {
        [
            HatirlaticiItem(id: "1", cariUnvan: "Ermay Bilişim San. Ltd.", telefon: "05321112233", belgeNo: "FTR-089", vadeTarihi: "20.10.2026", tutar: 45200.0, gecikmeGunu: 13, tur: "ALACAK"),
            HatirlaticiItem(id: "2", cariUnvan: "Kaya Metal Döküm A.Ş.", telefon: "05423334455", belgeNo: "FTR-094", vadeTarihi: "27.10.2026", tutar: 28500.0, gecikmeGunu: 6, tur: "ALACAK"),
            HatirlaticiItem(id: "3", cariUnvan: "Mega Plastik İthalat", telefon: "05556667788", belgeNo: "FTR-102", vadeTarihi: "05.11.2026", tutar: 14000.0, gecikmeGunu: -3, tur: "ALACAK")
        ]
    }
    
    private func sendWhatsAppReminder(_ item: HatirlaticiItem) {
        guard let phone = item.telefon else { return }
        let clean = phone.replacingOccurrences(of: " ", with: "").replacingOccurrences(of: "-", with: "")
        let text = "Sayın \(item.cariUnvan), \(item.belgeNo) nolu \(AppFormatters.money(item.tutar)) tutarındaki faturanızın vadesi dolmuştur. Ödemenizi rica eder, iyi çalışmalar dileriz. - Ermay Muhasebe"
        let enc = text.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        if let url = URL(string: "https://wa.me/90\(clean)?text=\(enc)") {
            #if canImport(UIKit)
            UIApplication.shared.open(url)
            #endif
        }
    }
    
    private func scheduleLocalNotification(_ item: HatirlaticiItem) {
        #if canImport(UserNotifications)
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.alert, .sound]) { granted, _ in
            if granted {
                let content = UNMutableNotificationContent()
                content.title = "Vade Hatırlatıcısı"
                content.body = "\(item.cariUnvan) - \(AppFormatters.money(item.tutar)) tutarındaki alacağın vadesi doldu."
                content.sound = .default
                
                let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)
                let req = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
                center.add(req)
                
                DispatchQueue.main.async {
                    self.sentNotice = "'\(item.cariUnvan)' için bildirim alarmı kuruldu."
                }
            }
        }
        #endif
    }
}

