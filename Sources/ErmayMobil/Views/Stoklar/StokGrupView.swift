import SwiftUI

public struct StokGrupView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var gruplar: [StokGrup] = [
        StokGrup(grupAdi: "Genel", aciklama: "Varsayılan grup"),
        StokGrup(grupAdi: "Rulman & Yatak", aciklama: "Bilyalı, makaralı rulmanlar"),
        StokGrup(grupAdi: "Sızdırmazlık", aciklama: "Keçeler, o-ringler"),
        StokGrup(grupAdi: "Madeni Yağ", aciklama: "Motor ve hidrolik yağları"),
        StokGrup(grupAdi: "Bağlantı Elemanları", aciklama: "Civata, somun, pul")
    ]
    @State private var yeniGrupAdi: String = ""
    @State private var showAddAlert: Bool = false
    
    public init() {}
    
    public var body: some View {
        NavigationStack {
            ZStack {
                AppTheme.background.ignoresSafeArea()
                
                VStack(spacing: 16) {
                    List {
                        ForEach(gruplar) { g in
                            GlassCard(cornerRadius: 12, padding: 12) {
                                HStack {
                                    Image(systemName: "folder.fill")
                                        .foregroundColor(AppTheme.primary)
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text(g.grupAdi)
                                            .font(.system(size: 14, weight: .bold))
                                            .foregroundColor(AppTheme.textPrimary)
                                        if let aciklama = g.aciklama {
                                            Text(aciklama)
                                                .font(.system(size: 11))
                                                .foregroundColor(AppTheme.textMuted)
                                        }
                                    }
                                    Spacer()
                                }
                            }
                            .listRowBackground(Color.clear)
                            .listRowSeparator(.hidden)
                            .listRowInsets(EdgeInsets(top: 4, leading: 16, bottom: 4, trailing: 16))
                        }
                    }
                    .listStyle(.plain)
                    
                    ActionButton(title: "Yeni Grup Ekle", icon: "plus.circle.fill", color: AppTheme.primary) {
                        showAddAlert = true
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 8)
                }
            }
            .navigationTitle("Stok Grupları")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Kapat") { dismiss() }
                        .foregroundColor(AppTheme.textSecondary)
                }
            }
            .alert("Yeni Stok Grubu", isPresented: $showAddAlert) {
                TextField("Grup Adı", text: $yeniGrupAdi)
                Button("Ekle") {
                    if !yeniGrupAdi.isEmpty {
                        gruplar.append(StokGrup(grupAdi: yeniGrupAdi))
                        yeniGrupAdi = ""
                    }
                }
                Button("İptal", role: .cancel) {}
            }
        }
    }
}

