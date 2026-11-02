import SwiftUI

public struct FinansView: View {
    @State private var hesaplar: [KasaBanka] = [
        KasaBanka(id: "1", hesapAdi: "Merkez TL Kasası", hesapTuru: "KASA", bakiye: 45850.50),
        KasaBanka(id: "2", hesapAdi: "Garanti BBVA Ticari TL", hesapTuru: "BANKA", bankaAdi: "Garanti BBVA", iban: "TR12 0006 2000 1234 5678 9012 34", bakiye: 154000.00),
        KasaBanka(id: "3", hesapAdi: "İş Bankası Şirket Hesabı", hesapTuru: "BANKA", bankaAdi: "Türkiye İş Bankası", iban: "TR64 0006 4000 0012 3456 7890 12", bakiye: 46000.00)
    ]
    @State private var hareketler: [KasaHareket] = []
    @State private var showTahsilatForm: Bool = false
    @State private var isTahsilat: Bool = true
    @State private var isLoading: Bool = false
    
    public init() {}
    
    public var toplamBakiye: Double {
        hesaplar.reduce(0.0) { $0 + $1.bakiye }
    }
    
    public var body: some View {
        NavigationStack {
            ZStack {
                AppTheme.background.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 20) {
                        // Toplam Likidite Kartı
                        GlassCard(cornerRadius: 18, padding: 18) {
                            VStack(spacing: 12) {
                                Text("TOPLAM FİNANSAL MEVCUT")
                                    .font(.system(size: 11, weight: .bold))
                                    .foregroundColor(AppTheme.textSecondary)
                                Text(AppFormatters.money(toplamBakiye))
                                    .font(.system(size: 30, weight: .heavy))
                                    .foregroundColor(AppTheme.textPrimary)
                                
                                HStack(spacing: 12) {
                                    Button {
                                        isTahsilat = true
                                        showTahsilatForm = true
                                    } label: {
                                        HStack {
                                            Image(systemName: "arrow.down.left")
                                            Text("Tahsilat Ekle")
                                        }
                                        .font(.system(size: 13, weight: .bold))
                                        .foregroundColor(.white)
                                        .frame(maxWidth: .infinity)
                                        .padding(.vertical, 10)
                                        .background(AppTheme.success)
                                        .cornerRadius(10)
                                    }
                                    
                                    Button {
                                        isTahsilat = false
                                        showTahsilatForm = true
                                    } label: {
                                        HStack {
                                            Image(systemName: "arrow.up.right")
                                            Text("Tediye / Ödeme")
                                        }
                                        .font(.system(size: 13, weight: .bold))
                                        .foregroundColor(.white)
                                        .frame(maxWidth: .infinity)
                                        .padding(.vertical, 10)
                                        .background(AppTheme.danger)
                                        .cornerRadius(10)
                                    }
                                }
                            }
                        }
                        .padding(.horizontal)
                        
                        // Kasa ve Banka Hesapları
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Kasa ve Banka Hesapları")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(AppTheme.textPrimary)
                                .padding(.horizontal)
                            
                            VStack(spacing: 8) {
                                ForEach(hesaplar) { h in
                                    GlassCard(cornerRadius: 14, padding: 14) {
                                        HStack(spacing: 12) {
                                            ZStack {
                                                Circle()
                                                    .fill(AppTheme.primary.opacity(0.15))
                                                    .frame(width: 40, height: 40)
                                                Image(systemName: h.hesapTuru == "KASA" ? "wallet.pass.fill" : "building.columns.fill")
                                                    .foregroundColor(AppTheme.primary)
                                            }
                                            
                                            VStack(alignment: .leading, spacing: 2) {
                                                Text(h.hesapAdi)
                                                    .font(.system(size: 14, weight: .bold))
                                                    .foregroundColor(AppTheme.textPrimary)
                                                if let iban = h.iban {
                                                    Text(iban)
                                                        .font(.system(size: 10, design: .monospaced))
                                                        .foregroundColor(AppTheme.textMuted)
                                                }
                                            }
                                            
                                            Spacer()
                                            
                                            Text(AppFormatters.money(h.bakiye))
                                                .font(.system(size: 14, weight: .heavy))
                                                .foregroundColor(AppTheme.textPrimary)
                                        }
                                    }
                                }
                            }
                            .padding(.horizontal)
                        }
                        
                        // Son Finans Hareketleri
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Son Kasa & Banka Hareketleri")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(AppTheme.textPrimary)
                                .padding(.horizontal)
                            
                            if hareketler.isEmpty {
                                Text("Henüz finansal hareket kaydı bulunamadı")
                                    .font(.system(size: 12))
                                    .foregroundColor(AppTheme.textMuted)
                                    .padding(.horizontal)
                            } else {
                                VStack(spacing: 8) {
                                    ForEach(hareketler) { h in
                                        let isGiris = h.islemTuru == "TAHSILAT" || h.islemTuru == "GIRIS"
                                        GlassCard(cornerRadius: 12, padding: 12) {
                                            HStack {
                                                ZStack {
                                                    Circle()
                                                        .fill((isGiris ? AppTheme.success : AppTheme.danger).opacity(0.15))
                                                        .frame(width: 36, height: 36)
                                                    Image(systemName: isGiris ? "arrow.down.left" : "arrow.up.right")
                                                        .foregroundColor(isGiris ? AppTheme.success : AppTheme.danger)
                                                }
                                                
                                                VStack(alignment: .leading, spacing: 2) {
                                                    Text(h.cariUnvan ?? h.islemTuru)
                                                        .font(.system(size: 13, weight: .bold))
                                                        .foregroundColor(AppTheme.textPrimary)
                                                    Text("\(h.belgeNo ?? "") • \(h.tarih)")
                                                        .font(.system(size: 11))
                                                        .foregroundColor(AppTheme.textMuted)
                                                }
                                                
                                                Spacer()
                                                
                                                Text((isGiris ? "+" : "-") + AppFormatters.money(h.tutar))
                                                    .font(.system(size: 13, weight: .heavy))
                                                    .foregroundColor(isGiris ? AppTheme.success : AppTheme.danger)
                                            }
                                        }
                                    }
                                }
                                .padding(.horizontal)
                            }
                        }
                        
                        Spacer().frame(height: 70)
                    }
                }
            }
            .navigationBarHidden(true)
            .sheet(isPresented: $showTahsilatForm) {
                TahsilatFormView(isTahsilat: isTahsilat) { newH in
                    hareketler.insert(newH, at: 0)
                    // Kasayı güncelle
                    if let idx = hesaplar.firstIndex(where: { $0.hesapTuru == "KASA" }) {
                        if isTahsilat {
                            hesaplar[idx].bakiye += newH.tutar
                        } else {
                            hesaplar[idx].bakiye -= newH.tutar
                        }
                    }
                }
            }
            .task {
                await loadFinansData()
            }
        }
    }
    
    private func loadFinansData() async {
        isLoading = true
        do {
            let hList: [KasaHareket] = try await SupabaseService.shared.fetch(from: "kasa_hareketleri", orderBy: "tarih.desc", limit: 30)
            await MainActor.run {
                self.hareketler = hList
            }
        } catch {
            print("Finans fetch error: \(error)")
            if hareketler.isEmpty {
                hareketler = [
                    KasaHareket(id: "1", tarih: "02.11.2026", islemTuru: "TAHSILAT", cariUnvan: "Ermay Ltd. Şti.", belgeNo: "MKZ-001", tutar: 15000, aciklama: "Cari Tahsilat"),
                    KasaHareket(id: "2", tarih: "01.11.2026", islemTuru: "TEDIYE", cariUnvan: "Akıncılar Çelik", belgeNo: "TED-042", tutar: 8500, aciklama: "Hammadde Avans")
                ]
            }
        }
        isLoading = false
    }
}

public struct TahsilatFormView: View {
    public let isTahsilat: Bool
    public var onSave: ((KasaHareket) -> Void)? = nil
    
    @Environment(\.dismiss) private var dismiss
    @State private var cariUnvan: String = ""
    @State private var tutar: String = ""
    @State private var aciklama: String = ""
    @State private var belgeNo: String = "MKZ-\(Int.random(in: 100...999))"
    @State private var isSaving: Bool = false
    
    public var body: some View {
        NavigationStack {
            ZStack {
                AppTheme.background.ignoresSafeArea()
                
                VStack(spacing: 16) {
                    GlassCard(cornerRadius: 16, padding: 18) {
                        VStack(spacing: 14) {
                            FormField(label: isTahsilat ? "Tahsil Edilen Cari *" : "Ödeme Yapılan Cari *", text: $cariUnvan, placeholder: "Cari unvanı")
                            FormField(label: "Tutar (₺) *", text: $tutar, placeholder: "0.00")
                            FormField(label: "Makbuz / Belge No", text: $belgeNo, placeholder: "MKZ-001")
                            FormField(label: "Açıklama", text: $aciklama, placeholder: "İşlem detayı...")
                        }
                    }
                    
                    ActionButton(
                        title: isSaving ? "Kaydediliyor..." : (isTahsilat ? "Tahsilatı Kaydet" : "Ödemeyi Kaydet"),
                        icon: "checkmark.circle.fill",
                        color: isTahsilat ? AppTheme.success : AppTheme.danger
                    ) {
                        saveTransaction()
                    }
                    
                    Spacer()
                }
                .padding()
            }
            .navigationTitle(isTahsilat ? "Yeni Tahsilat Makbuzu" : "Yeni Tediye Makbuzu")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("İptal") { dismiss() }
                        .foregroundColor(AppTheme.textSecondary)
                }
            }
        }
    }
    
    private func saveTransaction() {
        let tutarNum = Double(tutar) ?? 0.0
        guard tutarNum > 0 else { return }
        isSaving = true
        
        let df = DateFormatter()
        df.dateFormat = "yyyy-MM-dd"
        let bugun = df.string(from: Date())
        
        let h = KasaHareket(
            id: UUID().uuidString,
            tarih: bugun,
            islemTuru: isTahsilat ? "TAHSILAT" : "TEDIYE",
            cariUnvan: cariUnvan,
            belgeNo: belgeNo,
            tutar: tutarNum,
            aciklama: aciklama
        )
        
        Task {
            if let hData = try? JSONEncoder().encode(h) {
                try? await SupabaseService.shared.insertRaw(into: "kasa_hareketleri", data: hData)
            }
            await MainActor.run {
                onSave?(h)
                isSaving = false
                dismiss()
            }
        }
    }
}
