import SwiftUI

public struct KanbanView: View {
    @State private var gorevler: [KanbanGorev] = []
    @State private var isLoading: Bool = false
    
    @State private var searchQuery: String = ""
    @State private var activeTab: String = "Yapılacak" // 'Yapılacak' | 'Yapılıyor' | 'Bitti'
    
    @State private var isFormOpen: Bool = false
    @State private var isDetailOpen: Bool = false
    @State private var selectedGorev: KanbanGorev? = nil
    
    public init() {}
    
    public var filteredGorevler: [KanbanGorev] {
        gorevler.filter { g in
            g.durum == activeTab &&
            (searchQuery.isEmpty ||
             g.baslik.localizedCaseInsensitiveContains(searchQuery) ||
             (g.aciklama?.localizedCaseInsensitiveContains(searchQuery) ?? false))
        }
    }
    
    public var body: some View {
        NavigationStack {
            ZStack {
                Color(hex: "0A0A0A").ignoresSafeArea()
                
                VStack(spacing: 0) {
                    headerView
                    
                    if filteredGorevler.isEmpty {
                        VStack(spacing: 12) {
                            Spacer()
                            Image(systemName: "tray.fill")
                                .font(.system(size: 40))
                                .foregroundColor(Color(hex: "64748B"))
                            Text("Bu sütunda görev bulunmuyor.")
                                .font(.system(size: 14))
                                .foregroundColor(Color(hex: "64748B"))
                            Spacer()
                        }
                    } else {
                        ScrollView(showsIndicators: false) {
                            LazyVStack(spacing: 12) {
                                ForEach(filteredGorevler) { gorev in
                                    taskCard(gorev)
                                }
                                Spacer().frame(height: 100)
                            }
                            .padding(.horizontal, 16)
                            .padding(.top, 16)
                        }
                    }
                }
            }
            .navigationBarHidden(true)
            .sheet(isPresented: $isFormOpen) {
                YeniGorevModalView { yeni in
                    gorevler.append(yeni)
                    Task {
                        _ = try? await SupabaseService.shared.insert(into: "gorevler", item: yeni)
                    }
                }
            }
            .sheet(isPresented: $isDetailOpen) {
                if let g = selectedGorev {
                    GorevDetayModalView(
                        gorev: g,
                        onStatusChange: { updatedStatus in
                            updateStatus(id: g.id, newStatus: updatedStatus)
                        },
                        onDelete: {
                            deleteGorev(id: g.id)
                        }
                    )
                }
            }
            .task {
                await loadGorevler()
            }
            .onReceive(NotificationCenter.default.publisher(for: .supabaseRealtimeDataChanged)) { _ in
                Task {
                    await loadGorevler()
                }
            }
        }
    }
    
    // MARK: - Header
    private var headerView: some View {
        VStack(spacing: 14) {
            // Title & + Yeni button
            HStack {
                HStack(spacing: 8) {
                    Image(systemName: "square.grid.2x2.fill")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(Color(hex: "00FF87"))
                    Text("İş Takip Panosu")
                        .font(.system(size: 22, weight: .black))
                        .foregroundColor(.white)
                }
                
                Spacer()
                
                Button {
                    isFormOpen = true
                } label: {
                    HStack(spacing: 6) {
                        Image(systemName: "plus")
                            .font(.system(size: 14, weight: .bold))
                        Text("Yeni")
                            .font(.system(size: 14, weight: .bold))
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(Color(hex: "0061FF"))
                    .cornerRadius(12)
                }
            }
            .padding(.top, 10)
            
            // Segment Tabs ['Yapılacak', 'Yapılıyor', 'Bitti']
            HStack(spacing: 4) {
                ForEach(["Yapılacak", "Yapılıyor", "Bitti"], id: \.self) { tab in
                    let isSel = activeTab == tab
                    Button {
                        withAnimation(.easeInOut(duration: 0.15)) {
                            activeTab = tab
                        }
                    } label: {
                        Text(tab)
                            .font(.system(size: 13, weight: .bold))
                            .foregroundColor(isSel ? Color(hex: "60A5FA") : Color(hex: "64748B"))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 10)
                            .background(isSel ? Color(hex: "0061FF").opacity(0.18) : Color.clear)
                            .cornerRadius(8)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(isSel ? Color(hex: "0061FF").opacity(0.35) : Color.clear, lineWidth: 1)
                            )
                    }
                }
            }
            .padding(4)
            .background(Color(hex: "161616"))
            .cornerRadius(12)
            .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.white.opacity(0.08), lineWidth: 1))
            
            // Search Box
            HStack(spacing: 8) {
                Image(systemName: "magnifyingglass")
                    .font(.system(size: 16))
                    .foregroundColor(Color(hex: "64748B"))
                
                TextField("Görev veya açıklama ara...", text: $searchQuery)
                    .font(.system(size: 14))
                    .foregroundColor(.white)
                
                if !searchQuery.isEmpty {
                    Button { searchQuery = "" } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(Color(hex: "94A3B8"))
                    }
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
            .background(Color(hex: "2A2A2A"))
            .cornerRadius(12)
            .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color(hex: "444444"), lineWidth: 1))
        }
        .padding(.horizontal, 16)
        .padding(.bottom, 14)
        .background(Color(hex: "0A0A0A"))
        .overlay(Divider().background(Color.white.opacity(0.08)), alignment: .bottom)
    }
    
    // MARK: - Task Card
    private func taskCard(_ item: KanbanGorev) -> some View {
        Button {
            selectedGorev = item
            isDetailOpen = true
        } label: {
            VStack(alignment: .leading, spacing: 10) {
                // Header (Title + Priority badge)
                HStack(alignment: .top) {
                    Text(item.baslik)
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.leading)
                    
                    Spacer()
                    
                    priorityBadge(item.oncelik)
                }
                
                // Description
                if let desc = item.aciklama, !desc.isEmpty {
                    Text(desc)
                        .font(.system(size: 13))
                        .foregroundColor(Color(hex: "94A3B8"))
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)
                }
                
                // Footer
                HStack {
                    HStack(spacing: 5) {
                        Image(systemName: "person.fill")
                            .font(.system(size: 12))
                            .foregroundColor(Color(hex: "64748B"))
                        Text(item.atananPersonelAd ?? "Atanmamış")
                            .font(.system(size: 11))
                            .foregroundColor(Color(hex: "64748B"))
                    }
                    
                    Spacer()
                    
                    HStack(spacing: 5) {
                        Image(systemName: "calendar")
                            .font(.system(size: 12))
                            .foregroundColor(Color(hex: "64748B"))
                        Text(item.sonTarih)
                            .font(.system(size: 11))
                            .foregroundColor(Color(hex: "64748B"))
                    }
                }
                .padding(.top, 6)
                .overlay(Divider().background(Color.white.opacity(0.05)), alignment: .top)
            }
            .padding(16)
            .background(Color(hex: "0F0F0F"))
            .cornerRadius(16)
            .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.white.opacity(0.08), lineWidth: 1))
        }
        .buttonStyle(.plain)
    }
    
    private func priorityBadge(_ oncelik: String) -> some View {
        let (color, bg) = badgeColor(for: oncelik)
        return Text(oncelik)
            .font(.system(size: 10, weight: .bold))
            .foregroundColor(color)
            .padding(.horizontal, 8)
            .padding(.vertical, 3)
            .background(bg)
            .cornerRadius(6)
            .overlay(RoundedRectangle(cornerRadius: 6).stroke(color.opacity(0.3), lineWidth: 1))
    }
    
    private func badgeColor(for oncelik: String) -> (Color, Color) {
        switch oncelik {
        case "Acil":
            return (Color(hex: "EF4444"), Color(hex: "EF4444").opacity(0.15))
        case "Normal":
            return (Color(hex: "F59E0B"), Color(hex: "F59E0B").opacity(0.15))
        default: // Düşük
            return (Color(hex: "00FF87"), Color(hex: "00FF87").opacity(0.15))
        }
    }
    
    private func loadGorevler() async {
        isLoading = true
        do {
            let items: [KanbanGorev] = try await SupabaseService.shared.fetch(from: "gorevler")
            await MainActor.run {
                self.gorevler = items
            }
        } catch {
            print("Kanban gorevler fetch error: \(error)")
            await MainActor.run {
                self.gorevler = []
            }
        }
        isLoading = false
    }
    
    private func updateStatus(id: String, newStatus: String) {
        if let idx = gorevler.firstIndex(where: { $0.id == id }) {
            gorevler[idx].durum = newStatus
            if newStatus == "Bitti" && (gorevler[idx].bitisTarihi == nil || gorevler[idx].bitisTarihi?.isEmpty == true) {
                let formatter = DateFormatter()
                formatter.dateFormat = "yyyy-MM-dd"
                gorevler[idx].bitisTarihi = formatter.string(from: Date())
            }
            let updated = gorevler[idx]
            selectedGorev = updated
            Task {
                _ = try? await SupabaseService.shared.update(table: "gorevler", id: id, item: updated)
            }
        }
    }
    
    private func deleteGorev(id: String) {
        gorevler.removeAll { $0.id == id }
        isDetailOpen = false
        Task {
            _ = try? await SupabaseService.shared.delete(table: "gorevler", id: id)
        }
    }
}

// MARK: - Yeni Görev Ekleme Modal
public struct YeniGorevModalView: View {
    @Environment(\.dismiss) private var dismiss
    public var onSave: (KanbanGorev) -> Void
    
    @State private var baslik: String = ""
    @State private var aciklama: String = ""
    @State private var oncelik: String = "Normal" // 'Düşük' | 'Normal' | 'Acil'
    @State private var sonTarih: String = "2026-11-15"
    @State private var bitisTarihi: String = ""
    @State private var personelAd: String = "Yönetici"
    @State private var personelId: Int = 1
    
    private let personeller = [
        (id: 1, ad: "Yönetici"),
        (id: 2, ad: "Ahmet Yılmaz"),
        (id: 3, ad: "Mehmet Kaya"),
        (id: 4, ad: "Ayşe Demir")
    ]
    
    public var body: some View {
        NavigationStack {
            ZStack {
                Color(hex: "0A0A0A").ignoresSafeArea()
                
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 18) {
                        // Title
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Görev Başlığı *")
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundColor(Color(hex: "94A3B8"))
                            
                            TextField("Görev adı...", text: $baslik)
                                .font(.system(size: 15))
                                .foregroundColor(.white)
                                .padding(14)
                                .background(Color(hex: "2A2A2A"))
                                .cornerRadius(12)
                                .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color(hex: "444444"), lineWidth: 1))
                        }
                        
                        // Description
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Görev Açıklaması")
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundColor(Color(hex: "94A3B8"))
                            
                            TextEditor(text: $aciklama)
                                .scrollContentBackground(.hidden)
                                .font(.system(size: 14))
                                .foregroundColor(.white)
                                .frame(height: 80)
                                .padding(10)
                                .background(Color(hex: "2A2A2A"))
                                .cornerRadius(12)
                                .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color(hex: "444444"), lineWidth: 1))
                        }
                        
                        // Priority & Due Date Row
                        HStack(spacing: 12) {
                            // Priority
                            VStack(alignment: .leading, spacing: 6) {
                                Text("Öncelik")
                                    .font(.system(size: 13, weight: .semibold))
                                    .foregroundColor(Color(hex: "94A3B8"))
                                
                                HStack(spacing: 4) {
                                    ForEach(["Düşük", "Normal", "Acil"], id: \.self) { p in
                                        let isSel = oncelik == p
                                        Button {
                                            oncelik = p
                                        } label: {
                                            Text(p)
                                                .font(.system(size: 11, weight: .bold))
                                                .foregroundColor(isSel ? .white : Color(hex: "94A3B8"))
                                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                                                .background(isSel ? (p == "Acil" ? Color(hex: "EF4444") : Color(hex: "0061FF")) : Color.clear)
                                                .cornerRadius(8)
                                        }
                                    }
                                }
                                .padding(3)
                                .frame(height: 48)
                                .background(Color(hex: "2A2A2A"))
                                .cornerRadius(12)
                                .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color(hex: "444444"), lineWidth: 1))
                            }
                            .frame(maxWidth: .infinity)
                            
                            // Due Date
                            VStack(alignment: .leading, spacing: 6) {
                                Text("Son Tarih")
                                    .font(.system(size: 13, weight: .semibold))
                                    .foregroundColor(Color(hex: "94A3B8"))
                                
                                TextField("YYYY-MM-DD", text: $sonTarih)
                                    .font(.system(size: 14))
                                    .foregroundColor(.white)
                                    .padding(13)
                                    .frame(height: 48)
                                    .background(Color(hex: "2A2A2A"))
                                    .cornerRadius(12)
                                    .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color(hex: "444444"), lineWidth: 1))
                            }
                            .frame(maxWidth: .infinity)
                        }
                        
                        // Personnel Input & Quick Select Chips
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Sorumlu Personel")
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundColor(Color(hex: "94A3B8"))
                            
                            TextField("İsim soyisim...", text: $personelAd)
                                .font(.system(size: 14))
                                .foregroundColor(.white)
                                .padding(14)
                                .background(Color(hex: "2A2A2A"))
                                .cornerRadius(12)
                                .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color(hex: "444444"), lineWidth: 1))
                            
                            // Chips
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 8) {
                                    ForEach(personeller, id: \.id) { p in
                                        let isSel = personelAd == p.ad
                                        Button {
                                            personelId = p.id
                                            personelAd = p.ad
                                        } label: {
                                            Text(p.ad)
                                                .font(.system(size: 12, weight: isSel ? .bold : .medium))
                                                .foregroundColor(isSel ? Color(hex: "0061FF") : Color(hex: "94A3B8"))
                                                .padding(.horizontal, 12)
                                                .padding(.vertical, 6)
                                                .background(isSel ? Color(hex: "0061FF").opacity(0.18) : Color(hex: "161616"))
                                                .cornerRadius(20)
                                                .overlay(
                                                    RoundedRectangle(cornerRadius: 20)
                                                        .stroke(isSel ? Color(hex: "0061FF") : Color.white.opacity(0.08), lineWidth: 1)
                                                )
                                        }
                                    }
                                }
                            }
                        }
                        
                        // Bitiş Tarihi
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Bitiş Tarihi")
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundColor(Color(hex: "94A3B8"))
                            
                            TextField("YYYY-MM-DD (bitince otomatik dolar)", text: $bitisTarihi)
                                .font(.system(size: 14))
                                .foregroundColor(.white)
                                .padding(14)
                                .background(Color(hex: "2A2A2A"))
                                .cornerRadius(12)
                                .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color(hex: "444444"), lineWidth: 1))
                        }
                        
                        // Save Button
                        Button {
                            guard !baslik.trimmingCharacters(in: .whitespaces).isEmpty else { return }
                            let y = KanbanGorev(
                                id: UUID().uuidString,
                                baslik: baslik.trimmingCharacters(in: .whitespaces),
                                aciklama: aciklama.trimmingCharacters(in: .whitespaces),
                                atananPersonelId: personelId,
                                atananPersonelAd: personelAd,
                                durum: "Yapılacak",
                                oncelik: oncelik,
                                sonTarih: sonTarih,
                                bitisTarihi: bitisTarihi.isEmpty ? nil : bitisTarihi,
                                olusturmaTarihi: "2026-11-04"
                            )
                            onSave(y)
                            dismiss()
                        } label: {
                            HStack(spacing: 8) {
                                Image(systemName: "square.and.arrow.down.fill")
                                Text("Görevi Kaydet")
                            }
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(16)
                            .background(Color(hex: "10B981"))
                            .cornerRadius(12)
                        }
                        .padding(.top, 10)
                    }
                    .padding(20)
                }
            }
            .navigationTitle("Yeni Görev Oluştur")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .foregroundColor(.white)
                    }
                }
            }
        }
    }
}

// MARK: - Görev Detay Modalı
public struct GorevDetayModalView: View {
    @Environment(\.dismiss) private var dismiss
    public let gorev: KanbanGorev
    public var onStatusChange: (String) -> Void
    public var onDelete: () -> Void
    
    @State private var showDeleteConfirm: Bool = false
    
    public var body: some View {
        NavigationStack {
            ZStack {
                Color(hex: "0A0A0A").ignoresSafeArea()
                
                VStack(spacing: 0) {
                    ScrollView(showsIndicators: false) {
                        VStack(alignment: .leading, spacing: 18) {
                            // Title & Description
                            VStack(alignment: .leading, spacing: 8) {
                                Text(gorev.baslik)
                                    .font(.system(size: 20, weight: .bold))
                                    .foregroundColor(.white)
                                
                                Text(gorev.aciklama ?? "Açıklama belirtilmemiş.")
                                    .font(.system(size: 14))
                                    .foregroundColor(Color(hex: "94A3B8"))
                                    .lineSpacing(4)
                            }
                            .padding(16)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(Color(hex: "161616"))
                            .cornerRadius(16)
                            .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.white.opacity(0.08), lineWidth: 1))
                            
                            // Meta Grid
                            VStack(spacing: 10) {
                                metaRow(label: "Personel:", value: gorev.atananPersonelAd ?? "-")
                                metaRow(label: "Tarih:", value: gorev.sonTarih)
                                if let bitis = gorev.bitisTarihi, !bitis.isEmpty {
                                    metaRow(label: "Bitiş:", value: bitis, valColor: Color(hex: "00FF87"))
                                }
                                metaRow(label: "Öncelik:", value: gorev.oncelik, isBold: true)
                            }
                            .padding(16)
                            .background(Color(hex: "161616"))
                            .cornerRadius(16)
                            .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.white.opacity(0.08), lineWidth: 1))
                            
                            // Status Update (3 Buttons)
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Durumu Güncelle")
                                    .font(.system(size: 13, weight: .semibold))
                                    .foregroundColor(Color(hex: "94A3B8"))
                                
                                HStack(spacing: 8) {
                                    ForEach(["Yapılacak", "Yapılıyor", "Bitti"], id: \.self) { st in
                                        let isSel = gorev.durum == st
                                        Button {
                                            onStatusChange(st)
                                        } label: {
                                            Text(st)
                                                .font(.system(size: 12, weight: .bold))
                                                .foregroundColor(isSel ? Color(hex: "60A5FA") : Color(hex: "64748B"))
                                                .frame(maxWidth: .infinity)
                                                .padding(.vertical, 12)
                                                .background(isSel ? Color(hex: "0061FF").opacity(0.2) : Color(hex: "161616"))
                                                .cornerRadius(8)
                                                .overlay(
                                                    RoundedRectangle(cornerRadius: 8)
                                                        .stroke(isSel ? Color(hex: "0061FF") : Color.white.opacity(0.08), lineWidth: 1)
                                                )
                                        }
                                    }
                                }
                            }
                            
                            // Delete Button
                            Button {
                                showDeleteConfirm = true
                            } label: {
                                HStack(spacing: 6) {
                                    Image(systemName: "trash.fill")
                                    Text("Görevi Sil")
                                }
                                .font(.system(size: 14, weight: .bold))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 14)
                                .background(Color(hex: "EF4444"))
                                .cornerRadius(10)
                            }
                            .padding(.top, 10)
                        }
                        .padding(20)
                    }
                }
            }
            .navigationTitle("Görev Detayı")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .foregroundColor(.white)
                    }
                }
            }
            .alert("Görevi Sil", isPresented: $showDeleteConfirm) {
                Button("İptal", role: .cancel) {}
                Button("Evet, Sil", role: .destructive) {
                    onDelete()
                    dismiss()
                }
            } message: {
                Text("Bu görevi silmek istediğinize emin misiniz?")
            }
        }
    }
    
    private func metaRow(label: String, value: String, isBold: Bool = false, valColor: Color = .white) -> some View {
        HStack {
            Text(label)
                .font(.system(size: 13))
                .foregroundColor(Color(hex: "64748B"))
            Spacer()
            Text(value)
                .font(.system(size: 13, weight: isBold ? .bold : .regular))
                .foregroundColor(valColor)
        }
    }
}
