import SwiftUI

public final class NotificationManager: ObservableObject {
    public static let shared = NotificationManager()
    
    @Published public var bildirimler: [BildirimItem] = [
        BildirimItem(id: "1", baslik: "Kritik Stok Uyarısı", mesaj: "Endüstriyel Rulman 6204 stok seviyesi kritik eşiğin altına indi (Mevcut: 3 Adet).", zaman: "10 dk önce", tur: "TEHLIKE", okunduMu: false),
        BildirimItem(id: "2", baslik: "Vadesi Geçen Alacak", mesaj: "Ermay Bilişim Ltd. Şti. cari hesabının ₺45.200,00 tutarındaki faturasının vadesi 13 gün geçti.", zaman: "1 saat önce", tur: "UYARI", okunduMu: false),
        BildirimItem(id: "3", baslik: "Bulut Senkronizasyonu", mesaj: "Çevrimdışı yapılan 4 adet işlem başarıyla Supabase bulut veritabanına eşitlendi.", zaman: "Dün", tur: "BASARI", okunduMu: true),
        BildirimItem(id: "4", baslik: "Yeni Sipariş Alındı", mesaj: "Kaya Metal A.Ş. tarafından SIP-2026-089 nolu ₺28.500,00 tutarlı sipariş onaylandı.", zaman: "2 gün önce", tur: "BILGI", okunduMu: true)
    ]
    
    public var unreadCount: Int {
        bildirimler.filter { !$0.okunduMu }.count
    }
    
    public func markAllAsRead() {
        for idx in bildirimler.indices {
            bildirimler[idx].okunduMu = true
        }
    }
    
    public func deleteAll() {
        bildirimler.removeAll()
    }
    
    public func delete(id: String) {
        bildirimler.removeAll { $0.id == id }
    }
}
