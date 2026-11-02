import SwiftUI

public struct KanbanView: View {
    @State private var gorevler: [KanbanGorev] = [
        KanbanGorev(id: "1", baslik: "Ekim Ayı KDV Beyannamesi", aciklama: "Muhasebeci ile kontrol edilip onaylanacak.", durum: .todo, oncelik: "ACIL"),
        KanbanGorev(id: "2", baslik: "Akıncılar Çelik Sevkiyatı", aciklama: "İrsaliye kesilip depodan çıkışı sağlanacak.", durum: .inProgress, oncelik: "YUKSEK"),
        KanbanGorev(id: "3", baslik: "Haftalık Kasa Mutabakatı", aciklama: "Banka ekstreleri ile kasa bakiyeleri eşitlendi.", durum: .done, oncelik: "ORTA")
    ]
    @State private var selectedDurum: GorevDurumu = .todo
    @State private var showAddGorev: Bool = false
    
    public init() {}
    
    public var body: some View {
        NavigationStack {
            ZStack {
                AppTheme.background.ignoresSafeArea()
                
                VStack(spacing: 14) {
                    HStack {
                        Text("Görev Panosu (Kanban)")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(AppTheme.textPrimary)
                        Spacer()
                        Button {
                            showAddGorev = true
                        } label: {
                            Image(systemName: "plus.circle.fill")
                                .font(.system(size: 28))
                                .foregroundColor(AppTheme.primary)
                        }
                    }
                    .padding(.horizontal)
                    .padding(.top, 8)
                    
                    Picker("Durum", selection: $selectedDurum) {
                        ForEach(GorevDurumu.allCases, id: \.self) { d in
                            Text(d.title).tag(d)
                        }
                    }
                    .pickerStyle(.segmented)
                    .padding(.horizontal)
                    
                    List {
                        ForEach(gorevler.filter { $0.durum == selectedDurum }) { gorev in
                            GlassCard(cornerRadius: 14, padding: 14) {
                                VStack(alignment: .leading, spacing: 8) {
                                    HStack {
                                        Text(gorev.baslik)
                                            .font(.system(size: 15, weight: .bold))
                                            .foregroundColor(AppTheme.textPrimary)
                                        Spacer()
                                        StatusBadge(
                                            title: gorev.oncelik,
                                            color: gorev.oncelik == "ACIL" ? AppTheme.danger : (gorev.oncelik == "YUKSEK" ? AppTheme.warning : AppTheme.info)
                                        )
                                    }
                                    
                                    if let aciklama = gorev.aciklama {
                                        Text(aciklama)
                                            .font(.system(size: 13))
                                            .foregroundColor(AppTheme.textSecondary)
                                    }
                                    
                                    HStack {
                                        Spacer()
                                        
                                        if selectedDurum != .done {
                                            Button {
                                                moveGorev(gorev)
                                            } label: {
                                                HStack(spacing: 4) {
                                                    Text(selectedDurum == .todo ? "Başla (Devam Eden)" : "Tamamla")
                                                    Image(systemName: "arrow.right.circle.fill")
                                                }
                                                .font(.system(size: 11, weight: .bold))
                                                .foregroundColor(AppTheme.primary)
                                            }
                                        }
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
            .sheet(isPresented: $showAddGorev) {
                GorevEkleFormView { yeni in
                    gorevler.append(yeni)
                }
            }
        }
    }
    
    private func moveGorev(_ gorev: KanbanGorev) {
        if let idx = gorevler.firstIndex(where: { $0.id == gorev.id }) {
            if gorevler[idx].durum == .todo {
                gorevler[idx].durum = .inProgress
            } else if gorevler[idx].durum == .inProgress {
                gorevler[idx].durum = .done
            }
        }
    }
}

struct GorevEkleFormView: View {
    @Environment(\.dismiss) private var dismiss
    public var onAdd: (KanbanGorev) -> Void
    
    @State private var baslik: String = ""
    @State private var aciklama: String = ""
    @State private var oncelik: String = "ORTA"
    
    var body: some View {
        NavigationStack {
            ZStack {
                AppTheme.background.ignoresSafeArea()
                
                VStack(spacing: 16) {
                    GlassCard(cornerRadius: 16, padding: 18) {
                        VStack(spacing: 14) {
                            FormField(label: "Görev Başlığı *", text: $baslik, placeholder: "Örn: KDV Ödemesi")
                            FormField(label: "Açıklama", text: $aciklama, placeholder: "Görev detayları...")
                            
                            Picker("Öncelik", selection: $oncelik) {
                                Text("Düşük").tag("DUSUK")
                                Text("Orta").tag("ORTA")
                                Text("Yüksek").tag("YUKSEK")
                                Text("Acil").tag("ACIL")
                            }
                            .pickerStyle(.segmented)
                        }
                    }
                    
                    ActionButton(title: "Görevi Ekle", icon: "plus.circle.fill", color: AppTheme.primary) {
                        guard !baslik.isEmpty else { return }
                        let g = KanbanGorev(baslik: baslik, aciklama: aciklama, durum: .todo, oncelik: oncelik)
                        onAdd(g)
                        dismiss()
                    }
                    
                    Spacer()
                }
                .padding()
            }
            .navigationTitle("Yeni Görev")
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

