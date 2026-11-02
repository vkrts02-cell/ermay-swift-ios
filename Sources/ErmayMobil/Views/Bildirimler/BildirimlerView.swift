import SwiftUI

public struct BildirimItem: Identifiable, Sendable {
    public let id: String
    public let baslik: String
    public let mesaj: String
    public let zaman: String
    public let tur: String // "UYARI", "BILGI", "BASARI", "TEHLIKE"
    public var okunduMu: Bool
}

public struct BildirimlerView: View {
    @State private var bildirimler: [BildirimItem] = [
        BildirimItem(id: "1", baslik: "Kritik Stok Uyarısı", mesaj: "Endüstriyel Rulman 6204 stok seviyesi kritik eşiğin altına indi (Mevcut: 3 Adet).", zaman: "10 dk önce", tur: "TEHLIKE", okunduMu: false),
        BildirimItem(id: "2", baslik: "Vadesi Geçen Alacak", mesaj: "Ermay Bilişim Ltd. Şti. cari hesabının ₺45.200,00 tutarındaki faturasının vadesi 13 gün geçti.", zaman: "1 saat önce", tur: "UYARI", okunduMu: false),
        BildirimItem(id: "3", baslik: "Bulut Senkronizasyonu", mesaj: "Çevrimdışı yapılan 4 adet işlem başarıyla Supabase bulut veritabanına eşitlendi.", zaman: "Dün", tur: "BASARI", okunduMu: true),
        BildirimItem(id: "4", baslik: "Yeni Sipariş Alındı", mesaj: "Kaya Metal A.Ş. tarafından SIP-2026-089 nolu ₺28.500,00 tutarlı sipariş onaylandı.", zaman: "2 gün önce", tur: "BILGI", okunduMu: true)
    ]
    @Environment(\.dismiss) private var dismiss
    
    public init() {}
    
    public var body: some View {
        NavigationStack {
            ZStack {
                AppTheme.background.ignoresSafeArea()
                
                VStack(spacing: 14) {
                    HStack {
                        Text("Bildirim Merkezi")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(AppTheme.textPrimary)
                        Spacer()
                        Button {
                            for idx in bildirimler.indices {
                                bildirimler[idx].okunduMu = true
                            }
                        } label: {
                            Text("Tümünü Oku")
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundColor(AppTheme.primary)
                        }
                    }
                    .padding(.horizontal)
                    .padding(.top, 8)
                    
                    List {
                        ForEach(bildirimler) { b in
                            GlassCard(cornerRadius: 14, padding: 14) {
                                HStack(alignment: .top, spacing: 12) {
                                    ZStack {
                                        Circle()
                                            .fill(iconColor(b.tur).opacity(0.15))
                                            .frame(width: 38, height: 38)
                                        Image(systemName: iconName(b.tur))
                                            .font(.system(size: 16, weight: .bold))
                                            .foregroundColor(iconColor(b.tur))
                                    }
                                    
                                    VStack(alignment: .leading, spacing: 4) {
                                        HStack {
                                            Text(b.baslik)
                                                .font(.system(size: 13, weight: b.okunduMu ? .medium : .bold))
                                                .foregroundColor(AppTheme.textPrimary)
                                            Spacer()
                                            Text(b.zaman)
                                                .font(.system(size: 10))
                                                .foregroundColor(AppTheme.textMuted)
                                        }
                                        
                                        Text(b.mesaj)
                                            .font(.system(size: 12))
                                            .foregroundColor(AppTheme.textSecondary)
                                            .lineSpacing(2)
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
        }
    }
    
    private func iconName(_ tur: String) -> String {
        switch tur {
        case "TEHLIKE": return "exclamationmark.octagon.fill"
        case "UYARI": return "exclamationmark.triangle.fill"
        case "BASARI": return "checkmark.circle.fill"
        default: return "bell.fill"
        }
    }
    
    private func iconColor(_ tur: String) -> Color {
        switch tur {
        case "TEHLIKE": return AppTheme.danger
        case "UYARI": return AppTheme.warning
        case "BASARI": return AppTheme.success
        default: return AppTheme.primary
        }
    }
}

