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
    @ObservedObject private var manager = NotificationManager.shared
    @Environment(\.dismiss) private var dismiss
    @State private var showDeleteConfirm: Bool = false
    
    public init() {}
    
    public var body: some View {
        NavigationStack {
            ZStack {
                AppTheme.background.ignoresSafeArea()
                
                VStack(spacing: 14) {
                    // Header Bar
                    HStack(spacing: 12) {
                        Button {
                            dismiss()
                        } label: {
                            Image(systemName: "xmark.circle.fill")
                                .font(.system(size: 20))
                                .foregroundColor(Color(hex: "8E8E93"))
                        }
                        
                        Text("Bildirim Merkezi")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(AppTheme.textPrimary)
                        
                        Spacer()
                        
                        if !manager.bildirimler.isEmpty {
                            Button {
                                manager.markAllAsRead()
                            } label: {
                                Text("Tümünü Oku")
                                    .font(.system(size: 11, weight: .semibold))
                                    .foregroundColor(AppTheme.primary)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 5)
                                    .background(AppTheme.primary.opacity(0.12))
                                    .cornerRadius(6)
                            }
                            
                            Button {
                                showDeleteConfirm = true
                            } label: {
                                Image(systemName: "trash.fill")
                                    .font(.system(size: 14))
                                    .foregroundColor(AppTheme.danger)
                                    .padding(6)
                                    .background(AppTheme.danger.opacity(0.12))
                                    .clipShape(Circle())
                            }
                        }
                    }
                    .padding(.horizontal)
                    .padding(.top, 14)
                    
                    if manager.bildirimler.isEmpty {
                        Spacer()
                        VStack(spacing: 12) {
                            Image(systemName: "bell.slash.fill")
                                .font(.system(size: 40))
                                .foregroundColor(Color(hex: "64748B"))
                            Text("Henüz bildiriminiz bulunmuyor.")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(Color(hex: "8E8E93"))
                        }
                        Spacer()
                    } else {
                        List {
                            ForEach(manager.bildirimler) { b in
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
                                .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                    Button(role: .destructive) {
                                        manager.delete(id: b.id)
                                    } label: {
                                        Label("Sil", systemImage: "trash")
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
            .navigationBarHidden(true)
            .alert("Tüm Bildirimleri Sil", isPresented: $showDeleteConfirm) {
                Button("Tümünü Sil", role: .destructive) {
                    manager.deleteAll()
                }
                Button("Vazgeç", role: .cancel) {}
            } message: {
                Text("Tüm bildirim geçmişini silmek istediğinize emin misiniz?")
            }
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

