import SwiftUI

public enum FinansTab: String, CaseIterable {
    case dashboard = "Özet Panel"
    case nakit = "Kasa & Nakit"
    case cek = "Çek & Senet"
    case kk = "POS & Kart"
    case eft = "Banka & EFT"
}

public struct FinansView: View {
    @State private var activeTab: FinansTab = .dashboard
    
    // Veri State'leri
    @State private var kasalar: [KasaBanka] = [
        KasaBanka(id: "1", hesapAdi: "Merkez TL Kasası", hesapTuru: "KASA", bakiye: 54200.0),
        KasaBanka(id: "2", hesapAdi: "Şube Dolar Kasası", hesapTuru: "KASA", dovizCinsi: "USD", bakiye: 2450.0)
    ]
    @State private var bankalar: [KasaBanka] = [
        KasaBanka(id: "3", hesapAdi: "Garanti BBVA Ticari TL", hesapTuru: "BANKA", bankaAdi: "Garanti BBVA", iban: "TR12 0006 2000 1234 5678 9012 34", bakiye: 184500.0),
        KasaBanka(id: "4", hesapAdi: "İş Bankası Şirket Hesabı", hesapTuru: "BANKA", bankaAdi: "İş Bankası", iban: "TR64 0006 4000 0012 3456 7890 12", bakiye: 92400.0)
    ]
    @State private var cekler: [Cek] = [
        Cek(id: "1", cekNo: "CK-8841", cariUnvan: "Ermay Ltd. Şti.", portfoyNo: "P-101", seriNo: "SR-00412", vadeTarihi: "15.11.2026", tutar: 45000, borclu: "Ermay Bilişim", banka: "Garanti", sube: "Güneşli", cekTuru: "MUSTERI", durum: "PORTFOYDE"),
        Cek(id: "2", cekNo: "CK-8842", cariUnvan: "Akıncılar Çelik Döküm", portfoyNo: "P-102", seriNo: "SR-00413", vadeTarihi: "05.11.2026", tutar: 32000, borclu: "Akıncılar A.Ş.", banka: "İş Bankası", sube: "Tuzla", cekTuru: "MUSTERI", durum: "BANKADA")
    ]
    @State private var hareketler: [KasaHareket] = [
        KasaHareket(id: "1", tarih: "03.11.2026", islemTuru: "TAHSILAT", cariUnvan: "Ermay Ltd.", belgeNo: "TS-2026001", tutar: 15000, aciklama: "Nakit Tahsilat"),
        KasaHareket(id: "2", tarih: "02.11.2026", islemTuru: "TEDIYE", cariUnvan: "Akıncılar Çelik", belgeNo: "TS-2026002", tutar: 8500, aciklama: "Hammadde Nakliyesi")
    ]
    
    // Modals
    @State private var isTransactionModalOpen: Bool = false
    @State private var isCekStatusModalOpen: Bool = false
    @State private var isHesapModalOpen: Bool = false
    @State private var selectedCek: Cek? = nil
    
    // Yeni İşlem Form State
    @State private var transType: IslemTuru = "Tahsilat"
    @State private var transMethod: OdemeYontemi = "Nakit"
    @State private var transAmount: String = ""
    @State private var transDesc: String = ""
    @State private var transCariUnvan: String = ""
    @State private var transEvrakNo: String = ""
    @State private var isSaving: Bool = false
    
    public init() {}
    
    private var toplamKasaBakiye: Double {
        kasalar.reduce(0.0) { $0 + $1.bakiye }
    }
    
    private var toplamBankaBakiye: Double {
        bankalar.reduce(0.0) { $0 + $1.bakiye }
    }
    
    private var toplamCekBakiye: Double {
        cekler.filter { $0.durum == "PORTFOYDE" || $0.durum == "BANKADA" }.reduce(0.0) { $0 + $1.tutar }
    }
    
    private var toplamHazirDegerler: Double {
        toplamKasaBakiye + toplamBankaBakiye + toplamCekBakiye
    }
    
    public var body: some View {
        NavigationStack {
            ZStack {
                AppTheme.background.ignoresSafeArea()
                
                VStack(spacing: 12) {
                    // Header Bar
                    HStack {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Finans & Likidite")
                                .font(.system(size: 22, weight: .bold))
                                .foregroundColor(AppTheme.textPrimary)
                            Text("Toplam Değer: \(AppFormatters.money(toplamHazirDegerler))")
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundColor(AppTheme.success)
                        }
                        
                        Spacer()
                        
                        Button {
                            isTransactionModalOpen = true
                        } label: {
                            HStack(spacing: 4) {
                                Image(systemName: "plus.circle.fill")
                                Text("Yeni İşlem")
                            }
                            .font(.system(size: 13, weight: .bold))
                            .foregroundColor(.white)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 7)
                            .background(AppTheme.primary)
                            .cornerRadius(8)
                        }
                    }
                    .padding(.horizontal)
                    .padding(.top, 6)
                    
                    // 5 Sekmeli Kaydırmalı Tab Bar
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            ForEach(FinansTab.allCases, id: \.self) { tab in
                                let isSelected = activeTab == tab
                                Button {
                                    withAnimation(.spring(response: 0.25, dampingFraction: 0.8)) {
                                        activeTab = tab
                                    }
                                } label: {
                                    Text(tab.rawValue)
                                        .font(.system(size: 13, weight: isSelected ? .bold : .medium))
                                        .foregroundColor(isSelected ? .white : AppTheme.textSecondary)
                                        .padding(.horizontal, 14)
                                        .padding(.vertical, 8)
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
                    
                    // Sekme İçeriği
                    ScrollView {
                        VStack(spacing: 16) {
                            switch activeTab {
                            case .dashboard:
                                renderDashboardTab()
                            case .nakit:
                                renderNakitTab()
                            case .cek:
                                renderCekTab()
                            case .kk:
                                renderKrediKartiTab()
                            case .eft:
                                renderBankaTab()
                            }
                            
                            Spacer().frame(height: 70)
                        }
                        .padding(.horizontal)
                        .padding(.top, 4)
                    }
                }
                
                // Modals
                renderTransactionModal()
                renderCekStatusModal()
            }
            .navigationBarHidden(true)
        }
    }
    
    // MARK: - 1. Dashboard / Karne Sekmesi
    @ViewBuilder
    private func renderDashboardTab() -> some View {
        let karne = FinansAnalizUtils.hesapKarneler(
            kasaBakiye: toplamKasaBakiye,
            bankaBakiye: toplamBankaBakiye,
            cekPortfoyBakiye: toplamCekBakiye,
            toplamAlacak: 125000.0,
            toplamBorc: 68000.0
        )
        
        VStack(spacing: 14) {
            // Likidite Karne Kartı
            GlassCard(cornerRadius: 18, padding: 18) {
                VStack(spacing: 12) {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("FİNANSAL SAĞLIK VE LİKİDİTE PUANI")
                                .font(.system(size: 10, weight: .bold))
                                .foregroundColor(AppTheme.textSecondary)
                            Text(karne.durumSeviyesi.uppercased())
                                .font(.system(size: 18, weight: .heavy))
                                .foregroundColor(karne.likiditePuani >= 70 ? AppTheme.success : AppTheme.warning)
                        }
                        Spacer()
                        ZStack {
                            Circle()
                                .stroke(AppTheme.border, lineWidth: 6)
                                .frame(width: 58, height: 58)
                            Circle()
                                .trim(from: 0, to: CGFloat(karne.likiditePuani) / 100.0)
                                .stroke(karne.likiditePuani >= 70 ? AppTheme.success : AppTheme.warning, style: StrokeStyle(lineWidth: 6, lineCap: .round))
                                .rotationEffect(.degrees(-90))
                                .frame(width: 58, height: 58)
                            Text("\(karne.likiditePuani)")
                                .font(.system(size: 16, weight: .heavy))
                                .foregroundColor(AppTheme.textPrimary)
                        }
                    }
                    
                    Text(karne.genelDurumMetni)
                        .font(.system(size: 12))
                        .foregroundColor(AppTheme.textSecondary)
                        .lineSpacing(3)
                    
                    Divider().background(AppTheme.border)
                    
                    HStack {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Toplam Varlık")
                                .font(.system(size: 10))
                                .foregroundColor(AppTheme.textMuted)
                            Text(AppFormatters.money(karne.toplamVarlik))
                                .font(.system(size: 13, weight: .bold))
                                .foregroundColor(AppTheme.textPrimary)
                        }
                        Spacer()
                        VStack(alignment: .center, spacing: 2) {
                            Text("Yükümlülük")
                                .font(.system(size: 10))
                                .foregroundColor(AppTheme.textMuted)
                            Text(AppFormatters.money(karne.toplamYukumluluk))
                                .font(.system(size: 13, weight: .bold))
                                .foregroundColor(AppTheme.danger)
                        }
                        Spacer()
                        VStack(alignment: .trailing, spacing: 2) {
                            Text("Net Pozisyon")
                                .font(.system(size: 10))
                                .foregroundColor(AppTheme.textMuted)
                            Text(AppFormatters.money(karne.netPozisyon))
                                .font(.system(size: 13, weight: .bold))
                                .foregroundColor(AppTheme.success)
                        }
                    }
                }
            }
            
            // 4'lü Özet Metrik Grid
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                StatCard(title: "Kasa Mevcudu", value: AppFormatters.money(toplamKasaBakiye), subtitle: "\(kasalar.count) Kasa", icon: "banknote.fill", accentColor: AppTheme.primary)
                StatCard(title: "Banka Mevcudu", value: AppFormatters.money(toplamBankaBakiye), subtitle: "\(bankalar.count) Hesap", icon: "building.columns.fill", accentColor: AppTheme.purple)
                StatCard(title: "Portföydeki Çekler", value: AppFormatters.money(toplamCekBakiye), subtitle: "\(cekler.count) Adet Çek", icon: "doc.text.fill", accentColor: AppTheme.warning)
                StatCard(title: "Ort. Tahsilat Vadesi", value: "34 Gün", subtitle: "Ağırlıklı Vade", icon: "clock.fill", accentColor: AppTheme.info)
            }
            
            // Finansal Trend Grafiği (Son 6 Ay)
            GlassCard(cornerRadius: 16, padding: 16) {
                VStack(alignment: .leading, spacing: 12) {
                    Text("Finansal Nakit Akış Trendi (Gelir vs Gider)")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundColor(AppTheme.textPrimary)
                    
                    let trends = FinansAnalizUtils.hesapFinansTrend(aylikFaturalar: [], kasaHareketler: hareketler)
                    HStack(alignment: .bottom, spacing: 12) {
                        ForEach(trends) { item in
                            VStack(spacing: 6) {
                                HStack(spacing: 3) {
                                    RoundedRectangle(cornerRadius: 3)
                                        .fill(AppTheme.success)
                                        .frame(width: 8, height: CGFloat(item.gelir / 2000))
                                    RoundedRectangle(cornerRadius: 3)
                                        .fill(AppTheme.danger)
                                        .frame(width: 8, height: CGFloat(item.gider / 2000))
                                }
                                Text(item.donem)
                                    .font(.system(size: 10, weight: .semibold))
                                    .foregroundColor(AppTheme.textSecondary)
                            }
                            .frame(maxWidth: .infinity)
                        }
                    }
                    .frame(height: 110)
                }
            }
        }
    }
    
    // MARK: - 2. Nakit Kasa Sekmesi
    @ViewBuilder
    private func renderNakitTab() -> some View {
        VStack(spacing: 12) {
            ForEach(kasalar) { kasa in
                GlassCard(cornerRadius: 14, padding: 14) {
                    HStack(spacing: 12) {
                        ZStack {
                            Circle().fill(AppTheme.primary.opacity(0.15)).frame(width: 42, height: 42)
                            Image(systemName: "banknote.fill").foregroundColor(AppTheme.primary)
                        }
                        VStack(alignment: .leading, spacing: 3) {
                            Text(kasa.hesapAdi)
                                .font(.system(size: 14, weight: .bold))
                                .foregroundColor(AppTheme.textPrimary)
                            Text(kasa.dovizCinsi ?? "TRY")
                                .font(.system(size: 11))
                                .foregroundColor(AppTheme.textMuted)
                        }
                        Spacer()
                        Text(AppFormatters.money(kasa.bakiye))
                            .font(.system(size: 16, weight: .heavy))
                            .foregroundColor(AppTheme.textPrimary)
                    }
                }
            }
            
            // Kasa Hareketleri
            VStack(alignment: .leading, spacing: 8) {
                Text("Kasa Hareket Dökümü")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(AppTheme.textPrimary)
                
                ForEach(hareketler) { h in
                    GlassCard(cornerRadius: 12, padding: 12) {
                        HStack {
                            VStack(alignment: .leading, spacing: 2) {
                                Text(h.cariUnvan ?? h.aciklama ?? "Nakit İşlem")
                                    .font(.system(size: 13, weight: .bold))
                                    .foregroundColor(AppTheme.textPrimary)
                                Text("\(h.tarih) • \(h.belgeNo ?? "")")
                                    .font(.system(size: 11))
                                    .foregroundColor(AppTheme.textMuted)
                            }
                            Spacer()
                            Text(AppFormatters.money(h.tutar))
                                .font(.system(size: 14, weight: .bold))
                                .foregroundColor(h.islemTuru == "TAHSILAT" ? AppTheme.success : AppTheme.danger)
                        }
                    }
                }
            }
        }
    }
    
    // MARK: - 3. Çek / Senet Portföyü Sekmesi
    @ViewBuilder
    private func renderCekTab() -> some View {
        VStack(spacing: 12) {
            ForEach(cekler) { cek in
                GlassCard(cornerRadius: 14, padding: 14) {
                    VStack(spacing: 8) {
                        HStack {
                            StatusBadge(title: cek.durum, color: cek.durum == "PORTFOYDE" ? AppTheme.warning : AppTheme.success)
                            Text(cek.seriNo ?? cek.cekNo ?? "")
                                .font(.system(size: 12, weight: .bold))
                                .foregroundColor(AppTheme.textMuted)
                            Spacer()
                            Text(AppFormatters.money(cek.tutar))
                                .font(.system(size: 15, weight: .heavy))
                                .foregroundColor(AppTheme.textPrimary)
                        }
                        
                        HStack {
                            VStack(alignment: .leading, spacing: 2) {
                                Text(cek.borclu ?? cek.cariUnvan ?? "-")
                                    .font(.system(size: 14, weight: .bold))
                                    .foregroundColor(AppTheme.textPrimary)
                                Text("Banka: \(cek.banka ?? "") - \(cek.sube ?? "") • Vade: \(cek.vadeTarihi)")
                                    .font(.system(size: 11))
                                    .foregroundColor(AppTheme.textSecondary)
                            }
                            Spacer()
                            
                            Button {
                                selectedCek = cek
                                isCekStatusModalOpen = true
                            } label: {
                                Image(systemName: "ellipsis.circle.fill")
                                    .font(.system(size: 20))
                                    .foregroundColor(AppTheme.primary)
                            }
                        }
                    }
                }
            }
        }
    }
    
    // MARK: - 4. Kredi Kartı / POS Sekmesi
    @ViewBuilder
    private func renderKrediKartiTab() -> some View {
        VStack(spacing: 12) {
            GlassCard(cornerRadius: 16, padding: 16) {
                VStack(alignment: .leading, spacing: 10) {
                    HStack {
                        Image(systemName: "creditcard.fill").foregroundColor(AppTheme.purple)
                        Text("Ana Şirket POS Cihazı (Garanti BBVA)")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(AppTheme.textPrimary)
                        Spacer()
                        StatusBadge(title: "AKTİF", color: AppTheme.success)
                    }
                    Divider().background(AppTheme.border)
                    DetailSummaryRow(label: "Komisyon Oranı:", value: "% 2.45")
                    DetailSummaryRow(label: "Bloke Çözülme Süresi:", value: "28 Gün")
                    DetailSummaryRow(label: "Bugün Çekilen:", value: "₺24.500,00")
                }
            }
        }
    }
    
    // MARK: - 5. Banka & EFT Sekmesi
    @ViewBuilder
    private func renderBankaTab() -> some View {
        VStack(spacing: 12) {
            ForEach(bankalar) { banka in
                GlassCard(cornerRadius: 14, padding: 14) {
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text(banka.hesapAdi)
                                .font(.system(size: 14, weight: .bold))
                                .foregroundColor(AppTheme.textPrimary)
                            Spacer()
                            Text(AppFormatters.money(banka.bakiye))
                                .font(.system(size: 16, weight: .heavy))
                                .foregroundColor(AppTheme.textPrimary)
                        }
                        
                        if let iban = banka.iban {
                            HStack {
                                Text(iban)
                                    .font(.system(size: 11, weight: .medium))
                                    .foregroundColor(AppTheme.textMuted)
                                Spacer()
                                Button {
                                    #if canImport(UIKit)
                                    UIPasteboard.general.string = iban
                                    #endif
                                    HardwareService.shared.hapticSuccess()
                                } label: {
                                    Image(systemName: "doc.on.doc")
                                        .font(.system(size: 12))
                                        .foregroundColor(AppTheme.primary)
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    // MARK: - Yeni İşlem Modalı
    @ViewBuilder
    private func renderTransactionModal() -> some View {
        SwipeableModal(isPresented: $isTransactionModalOpen, title: "Yeni Finansal İşlem") {
            VStack(spacing: 14) {
                Picker("İşlem Türü", selection: $transType) {
                    Text("Tahsilat (Giriş)").tag("Tahsilat")
                    Text("Ödeme (Çıkış)").tag("Ödeme")
                }
                .pickerStyle(.segmented)
                
                Picker("Ödeme Yöntemi", selection: $transMethod) {
                    Text("Nakit").tag("Nakit")
                    Text("Kredi Kartı").tag("Kredi Kartı")
                    Text("Banka / EFT").tag("Havale/EFT")
                    Text("Çek").tag("Çek")
                }
                .pickerStyle(.segmented)
                
                FormField(label: "Cari / Müşteri Unvanı *", text: $transCariUnvan, placeholder: "Örn: Akıncılar Çelik")
                FormField(label: "Tutar (₺) *", text: $transAmount, placeholder: "0.00")
                FormField(label: "Açıklama", text: $transDesc, placeholder: "İşlem notu...")
                
                ActionButton(title: isSaving ? "Kaydediliyor..." : "İşlemi Tamamla", icon: "checkmark.circle.fill", color: transType == "Tahsilat" ? AppTheme.success : AppTheme.danger) {
                    saveTransaction()
                }
                .disabled(isSaving)
            }
        }
    }
    
    // MARK: - Çek Durum Modalı
    @ViewBuilder
    private func renderCekStatusModal() -> some View {
        SwipeableModal(isPresented: $isCekStatusModalOpen, title: "Çek Portföy Durumu") {
            if let c = selectedCek {
                VStack(spacing: 12) {
                    Text("\(c.borclu ?? c.cariUnvan ?? "") - \(AppFormatters.money(c.tutar))")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(AppTheme.textPrimary)
                    
                    let options = [
                        ("Tahsile Ver (Bankada)", "BANKADA", AppTheme.info),
                        ("Tahsil Edildi (Hesaba Geçti)", "TAHSIL_EDILDI", AppTheme.success),
                        ("Karşılıksız Çıktı (Protesto)", "KARSILIKSIZ", AppTheme.danger),
                        ("Müşteriye İade Et", "IADE", AppTheme.textMuted)
                    ]
                    
                    ForEach(options, id: \.1) { opt in
                        Button {
                            updateCekStatus(c, newStatus: opt.1)
                        } label: {
                            Text(opt.0)
                                .font(.system(size: 13, weight: .bold))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 12)
                                .background(opt.2)
                                .cornerRadius(10)
                        }
                    }
                }
            }
        }
    }
    
    private func saveTransaction() {
        guard let tutarNum = Double(transAmount), tutarNum > 0, !transCariUnvan.isEmpty else { return }
        isSaving = true
        
        let cari = CariKart(unvan: transCariUnvan)
        let req = FinancialTransactionRequest(
            cari: cari,
            amount: tutarNum,
            date: AppFormatters.isoDate.string(from: Date()),
            transactionType: transType,
            method: transMethod,
            description: transDesc,
            selectedHesap: kasalar.first
        )
        
        Task {
            _ = try? await TransactionService.shared.saveFinancialTransaction(req: req)
            await MainActor.run {
                hareketler.insert(KasaHareket(
                    id: UUID().uuidString,
                    tarih: req.date,
                    islemTuru: transType == "Tahsilat" ? "TAHSILAT" : "TEDIYE",
                    cariUnvan: transCariUnvan,
                    belgeNo: "TS-\(Int.random(in: 100...999))",
                    tutar: tutarNum,
                    aciklama: transDesc
                ), at: 0)
                isSaving = false
                isTransactionModalOpen = false
                HardwareService.shared.hapticSuccess()
            }
        }
    }
    
    private func updateCekStatus(_ cek: Cek, newStatus: String) {
        if let idx = cekler.firstIndex(where: { $0.id == cek.id }) {
            cekler[idx].durum = newStatus
            isCekStatusModalOpen = false
            HardwareService.shared.hapticSuccess()
        }
    }
}
