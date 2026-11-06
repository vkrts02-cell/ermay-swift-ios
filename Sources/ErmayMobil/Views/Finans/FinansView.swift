import SwiftUI

public struct FinansView: View {
    @State private var activeTab: String = "dashboard" // "dashboard" | "nakit" | "cek" | "kk" | "eft"
    
    // KPI Data
    @State private var kasaBakiye: Double = 0.0
    @State private var bankaBakiye: Double = 0.0
    @State private var posBakiye: Double = 0.0
    @State private var portfoyCekBakiye: Double = 0.0
    
    // Modals
    @State private var showYeniIslem: Bool = false
    @State private var showKasaSayimi: Bool = false
    @State private var showYeniHesap: Bool = false
    
    // Yeni İşlem Form State
    @State private var islemTuru: String = "Tahsilat" // "Tahsilat" | "Ödeme" | "Virman" | "Gider"
    @State private var odemeYontemi: String = "Nakit" // "Nakit" | "Kredi Kartı" | "Havale/EFT"
    @State private var cariUnvan: String = ""
    @State private var seciliHesap: String = "Merkez Kasa (TL)"
    @State private var islemTutar: String = ""
    @State private var islemAciklama: String = ""
    @State private var islemEvrakNo: String = ""
    
    // Çek Modülü Toggle
    @State private var cekTuru: String = "ALINAN" // "ALINAN" | "VERILEN"
    
    // Finansal İşlemler Listesi
    struct FinansListItem: Identifiable {
        let id = UUID()
        let title: String
        let description: String
        let amount: Double
        let date: String
        let type: String // "In" | "Out"
        let method: String
    }
    
    @State private var hareketler: [FinansListItem] = []
    
    // Çek Kayıtları
    struct CekItem: Identifiable {
        let id = UUID()
        let portfoyNo: String
        let kesideci: String
        let banka: String
        let vade: String
        let tutar: Double
        let durum: String
        let tip: String
    }
    
    @State private var cekler: [CekItem] = []
    
    private var toplamLikidite: Double {
        kasaBakiye + bankaBakiye + posBakiye
    }
    
    public init() {}
    
    public var body: some View {
        NavigationStack {
            ZStack {
                Color.black.ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // 1. Header Bar (Exact to FinansScreen.tsx)
                    HStack {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Finans Yönetimi")
                                .font(.system(size: 24, weight: .heavy))
                                .foregroundColor(.white)
                                .tracking(-0.5)
                            Text("Kasa, banka, çek/senet ve POS takibi")
                                .font(.system(size: 13, weight: .medium))
                                .foregroundColor(Color(hex: "94A3B8"))
                        }
                        
                        Spacer()
                        
                        HStack(spacing: 8) {
                            if activeTab == "nakit" {
                                Button {
                                    showKasaSayimi = true
                                } label: {
                                    HStack(spacing: 4) {
                                        Image(systemName: "banknote.fill")
                                        Text("Sayım")
                                    }
                                    .font(.system(size: 12, weight: .bold))
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 7)
                                    .background(Color(hex: "0D9488"))
                                    .cornerRadius(8)
                                }
                            }
                            
                            Button {
                                showYeniIslem = true
                            } label: {
                                HStack(spacing: 4) {
                                    Image(systemName: "plus")
                                    Text("Yeni İşlem")
                                }
                                .font(.system(size: 12, weight: .bold))
                                .foregroundColor(.white)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 7)
                                .background(Color(hex: "2563EB"))
                                .cornerRadius(8)
                            }
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 6)
                    .padding(.bottom, 10)
                    
                    // 2. 5 Sekmeli Menü (Dashboard | Nakit | Çekler | Kredi Kartı | Havale/EFT)
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            tabButton(title: "Dashboard", key: "dashboard")
                            tabButton(title: "Nakit", key: "nakit")
                            tabButton(title: "Çekler", key: "cek")
                            tabButton(title: "Kredi Kartı", key: "kk")
                            tabButton(title: "Havale/EFT", key: "eft")
                        }
                        .padding(.horizontal, 16)
                    }
                    .padding(.bottom, 12)
                    
                    // 3. Sekme İçerikleri
                    ScrollView(showsIndicators: false) {
                        VStack(spacing: 16) {
                            switch activeTab {
                            case "dashboard":
                                renderDashboardTab()
                            case "nakit":
                                renderNakitTab()
                            case "cek":
                                renderCeklerTab()
                            case "kk":
                                renderKrediKartiTab()
                            case "eft":
                                renderHavaleEftTab()
                            default:
                                EmptyView()
                            }
                            
                            Spacer().frame(height: 110)
                        }
                        .padding(.horizontal, 16)
                    }
                }
            }
            .navigationBarHidden(true)
            .sheet(isPresented: $showYeniIslem) {
                yeniIslemSheet()
            }
            .sheet(isPresented: $showKasaSayimi) {
                kasaSayimiSheet()
            }
            .task {
                await loadFinansData()
            }
            .onReceive(NotificationCenter.default.publisher(for: .supabaseRealtimeDataChanged)) { _ in
                Task {
                    await loadFinansData()
                }
            }
        }
    }
    
    private func tabButton(title: String, key: String) -> some View {
        let isSel = activeTab == key
        return Button {
            withAnimation(.easeInOut(duration: 0.15)) { activeTab = key }
        } label: {
            Text(title)
                .font(.system(size: 13, weight: isSel ? .bold : .medium))
                .foregroundColor(isSel ? .white : Color(hex: "8E8E93"))
                .padding(.horizontal, 14)
                .padding(.vertical, 8)
                .background(isSel ? Color(hex: "2563EB") : Color(hex: "121216"))
                .cornerRadius(10)
                .overlay(RoundedRectangle(cornerRadius: 10).stroke(isSel ? Color(hex: "2563EB") : Color.white.opacity(0.06), lineWidth: 1))
        }
    }
    
    // MARK: - 1. Dashboard Tab
    private func renderDashboardTab() -> some View {
        VStack(spacing: 14) {
            // 3 KPI Likidite Kartları
            HStack(spacing: 10) {
                kpiCard(title: "NAKİT KASA", value: AppFormatters.money(kasaBakiye), icon: "wallet.pass.fill", color: Color(hex: "30D158"))
                kpiCard(title: "BANKA MEVDUAT", value: AppFormatters.money(bankaBakiye), icon: "building.columns.fill", color: Color(hex: "0A84FF"))
            }
            
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text("TOPLAM LİKİDİTE (KASA + BANKA + POS)")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(Color(hex: "8E8E93"))
                    Spacer()
                    Image(systemName: "creditcard.fill").foregroundColor(Color(hex: "FF9F0A"))
                }
                Text(AppFormatters.money(toplamLikidite))
                    .font(.system(size: 26, weight: .heavy))
                    .foregroundColor(.white)
            }
            .padding(16)
            .background(Color(hex: "121216"))
            .cornerRadius(18)
            .overlay(RoundedRectangle(cornerRadius: 18).stroke(Color.white.opacity(0.08), lineWidth: 1))
            
            // Son Finansal İşlemler
            VStack(alignment: .leading, spacing: 12) {
                Text("Son Finansal İşlemler")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundColor(.white)
                
                VStack(spacing: 0) {
                    ForEach(Array(hareketler.enumerated()), id: \.element.id) { idx, item in
                        HStack(spacing: 12) {
                            ZStack {
                                Circle()
                                    .fill((item.type == "In" ? Color(hex: "00FF87") : Color(hex: "FF416C")).opacity(0.15))
                                    .frame(width: 36, height: 36)
                                Image(systemName: item.type == "In" ? "arrow.down.left" : "arrow.up.right")
                                    .font(.system(size: 13, weight: .bold))
                                    .foregroundColor(item.type == "In" ? Color(hex: "00FF87") : Color(hex: "FF416C"))
                            }
                            
                            VStack(alignment: .leading, spacing: 2) {
                                Text(item.title)
                                    .font(.system(size: 13, weight: .semibold))
                                    .foregroundColor(.white)
                                    .lineLimit(1)
                                Text("\(item.description) • \(item.method) • \(item.date)")
                                    .font(.system(size: 10))
                                    .foregroundColor(Color(hex: "8E8E93"))
                            }
                            
                            Spacer()
                            
                            Text("\(item.type == "In" ? "+" : "-")\(AppFormatters.money(item.amount))")
                                .font(.system(size: 13, weight: .bold))
                                .foregroundColor(item.type == "In" ? Color(hex: "00FF87") : Color(hex: "FF416C"))
                        }
                        .padding(.vertical, 10)
                        
                        if idx < hareketler.count - 1 {
                            Divider().background(Color.white.opacity(0.06))
                        }
                    }
                }
            }
            .padding(16)
            .background(Color(hex: "121216"))
            .cornerRadius(20)
            .overlay(RoundedRectangle(cornerRadius: 20).stroke(Color.white.opacity(0.08), lineWidth: 1))
        }
    }
    
    // MARK: - 2. Nakit Tab
    private func renderNakitTab() -> some View {
        VStack(spacing: 14) {
            // Kasa Kartları
            VStack(alignment: .leading, spacing: 10) {
                Text("Kasa Hesapları").font(.system(size: 13, weight: .bold)).foregroundColor(.white)
                HStack(spacing: 10) {
                    kasaBox(title: "Merkez Kasa (TL)", bakiye: 38400, color: Color(hex: "30D158"))
                    kasaBox(title: "Şantiye / Saha Kasası", bakiye: 15800, color: Color(hex: "0A84FF"))
                }
            }
            .padding(16)
            .background(Color(hex: "121216"))
            .cornerRadius(20)
            
            // Kasa Hareketleri
            VStack(alignment: .leading, spacing: 10) {
                Text("Kasa Hareket Listesi").font(.system(size: 13, weight: .bold)).foregroundColor(.white)
                ForEach(hareketler.filter { $0.method.contains("Kasa") }) { h in
                    HStack {
                        VStack(alignment: .leading, spacing: 2) {
                            Text(h.title).font(.system(size: 13, weight: .bold)).foregroundColor(.white)
                            Text("\(h.description) • \(h.date)").font(.system(size: 11)).foregroundColor(Color(hex: "8E8E93"))
                        }
                        Spacer()
                        Text("\(h.type == "In" ? "+" : "-")\(AppFormatters.money(h.amount))")
                            .font(.system(size: 13, weight: .bold))
                            .foregroundColor(h.type == "In" ? Color(hex: "00FF87") : Color(hex: "FF416C"))
                    }
                    .padding(.vertical, 8)
                }
            }
            .padding(16)
            .background(Color(hex: "121216"))
            .cornerRadius(20)
        }
    }
    
    // MARK: - 3. Çekler Tab
    private func renderCeklerTab() -> some View {
        VStack(spacing: 12) {
            Picker("Çek Türü", selection: $cekTuru) {
                Text("Alınan Müşteri Çekleri").tag("ALINAN")
                Text("Verilen Firma Çekleri").tag("VERILEN")
            }
            .pickerStyle(.segmented)
            .padding(.bottom, 4)
            
            ForEach(cekler.filter { $0.tip == cekTuru }) { c in
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text(c.portfoyNo).font(.system(size: 11, weight: .bold)).foregroundColor(Color(hex: "3B82F6"))
                        Spacer()
                        Text(c.durum)
                            .font(.system(size: 10, weight: .bold))
                            .foregroundColor(Color(hex: "10B981"))
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Color(hex: "10B981").opacity(0.12))
                            .cornerRadius(4)
                    }
                    
                    Text(c.kesideci).font(.system(size: 14, weight: .bold)).foregroundColor(.white)
                    
                    HStack {
                        Text("\(c.banka) • Vade: \(c.vade)").font(.system(size: 11)).foregroundColor(Color(hex: "8E8E93"))
                        Spacer()
                        Text(AppFormatters.money(c.tutar)).font(.system(size: 14, weight: .heavy)).foregroundColor(.white)
                    }
                }
                .padding(14)
                .background(Color(hex: "121216"))
                .cornerRadius(16)
                .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.white.opacity(0.08), lineWidth: 1))
            }
        }
    }
    
    // MARK: - 4. Kredi Kartı Tab
    private func renderKrediKartiTab() -> some View {
        VStack(spacing: 12) {
            kpiCard(title: "POS HESAP BAKİYESİ", value: AppFormatters.money(posBakiye), icon: "creditcard.and.123", color: Color(hex: "BF5AF2"))
            
            VStack(alignment: .leading, spacing: 10) {
                Text("Kredi Kartı / POS Tahsilatları").font(.system(size: 13, weight: .bold)).foregroundColor(.white)
                ForEach(hareketler.filter { $0.method.contains("Kredi") }) { h in
                    HStack {
                        VStack(alignment: .leading, spacing: 2) {
                            Text(h.title).font(.system(size: 13, weight: .bold)).foregroundColor(.white)
                            Text("\(h.description) • \(h.date)").font(.system(size: 11)).foregroundColor(Color(hex: "8E8E93"))
                        }
                        Spacer()
                        Text(AppFormatters.money(h.amount)).font(.system(size: 13, weight: .bold)).foregroundColor(Color(hex: "30D158"))
                    }
                    .padding(.vertical, 8)
                }
            }
            .padding(16)
            .background(Color(hex: "121216"))
            .cornerRadius(20)
        }
    }
    
    // MARK: - 5. Havale / EFT Tab
    private func renderHavaleEftTab() -> some View {
        VStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 10) {
                Text("Banka Hesapları").font(.system(size: 13, weight: .bold)).foregroundColor(.white)
                bankaBox(ad: "Garanti BBVA Ticari", iban: "TR44 0006 2000 1234 5678 9012 34", bakiye: 184500)
                bankaBox(ad: "Yapı Kredi Şirket Hesabı", iban: "TR12 0006 7000 9876 5432 1098 76", bakiye: 92400)
            }
            .padding(16)
            .background(Color(hex: "121216"))
            .cornerRadius(20)
            
            VStack(alignment: .leading, spacing: 10) {
                Text("Son Havale & EFT İşlemleri").font(.system(size: 13, weight: .bold)).foregroundColor(.white)
                ForEach(hareketler.filter { $0.method.contains("Banka") }) { h in
                    HStack {
                        VStack(alignment: .leading, spacing: 2) {
                            Text(h.title).font(.system(size: 13, weight: .bold)).foregroundColor(.white)
                            Text("\(h.description) • \(h.date)").font(.system(size: 11)).foregroundColor(Color(hex: "8E8E93"))
                        }
                        Spacer()
                        Text("\(h.type == "In" ? "+" : "-")\(AppFormatters.money(h.amount))")
                            .font(.system(size: 13, weight: .bold))
                            .foregroundColor(h.type == "In" ? Color(hex: "00FF87") : Color(hex: "FF416C"))
                    }
                    .padding(.vertical, 8)
                }
            }
            .padding(16)
            .background(Color(hex: "121216"))
            .cornerRadius(20)
        }
    }
    
    private func kpiCard(title: String, value: String, icon: String, color: Color) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(title).font(.system(size: 10, weight: .bold)).foregroundColor(Color(hex: "8E8E93"))
                Spacer()
                Image(systemName: icon).foregroundColor(color)
            }
            Text(value).font(.system(size: 17, weight: .heavy)).foregroundColor(.white)
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(hex: "121216"))
        .cornerRadius(16)
        .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.white.opacity(0.08), lineWidth: 1))
    }
    
    private func kasaBox(title: String, bakiye: Double, color: Color) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title).font(.system(size: 12, weight: .bold)).foregroundColor(.white)
            Text(AppFormatters.money(bakiye)).font(.system(size: 16, weight: .heavy)).foregroundColor(color)
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.white.opacity(0.03))
        .cornerRadius(12)
    }
    
    private func bankaBox(ad: String, iban: String, bakiye: Double) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(ad).font(.system(size: 13, weight: .bold)).foregroundColor(.white)
                Spacer()
                Text(AppFormatters.money(bakiye)).font(.system(size: 14, weight: .heavy)).foregroundColor(Color(hex: "0A84FF"))
            }
            Text(iban).font(.system(size: 10)).foregroundColor(Color(hex: "8E8E93"))
        }
        .padding(12)
        .background(Color.white.opacity(0.03))
        .cornerRadius(12)
    }
    
    // MARK: - Modals
    private func yeniIslemSheet() -> some View {
        VStack(spacing: 16) {
            Text("Yeni Finansal İşlem").font(.system(size: 18, weight: .bold)).foregroundColor(.white).padding(.top, 20)
            
            VStack(spacing: 12) {
                Picker("İşlem Türü", selection: $islemTuru) {
                    Text("Tahsilat").tag("Tahsilat")
                    Text("Ödeme").tag("Ödeme")
                    Text("Virman").tag("Virman")
                    Text("Gider").tag("Gider")
                }
                .pickerStyle(.segmented)
                
                Picker("Ödeme Yöntemi", selection: $odemeYontemi) {
                    Text("Nakit").tag("Nakit")
                    Text("Kredi Kartı").tag("Kredi Kartı")
                    Text("Havale/EFT").tag("Havale/EFT")
                }
                .pickerStyle(.segmented)
                
                TextField("Cari Unvanı", text: $cariUnvan)
                    .font(.system(size: 13)).foregroundColor(.white).padding(10).background(Color.white.opacity(0.05)).cornerRadius(8)
                
                TextField("Tutar (₺)", text: $islemTutar)
                    .font(.system(size: 13)).foregroundColor(.white).padding(10).background(Color.white.opacity(0.05)).cornerRadius(8)
                
                TextField("Açıklama", text: $islemAciklama)
                    .font(.system(size: 13)).foregroundColor(.white).padding(10).background(Color.white.opacity(0.05)).cornerRadius(8)
            }
            .padding(.horizontal, 20)
            
            Button {
                let tutar = Double(islemTutar) ?? 0
                guard tutar > 0 else { return }
                let newItem = FinansListItem(
                    title: cariUnvan,
                    description: islemAciklama.isEmpty ? islemTuru : islemAciklama,
                    amount: tutar,
                    date: "03.11.2026",
                    type: (islemTuru == "Tahsilat" ? "In" : "Out"),
                    method: odemeYontemi
                )
                hareketler.insert(newItem, at: 0)
                if islemTuru == "Tahsilat" {
                    kasaBakiye += tutar
                } else {
                    kasaBakiye -= tutar
                }
                showYeniIslem = false
            } label: {
                Text("İşlemi Kaydet")
                    .font(.system(size: 15, weight: .bold)).foregroundColor(.white)
                    .frame(maxWidth: .infinity).padding(.vertical, 14)
                    .background(Color(hex: "2563EB")).cornerRadius(12)
            }
            .padding(.horizontal, 20)
            
            Spacer()
        }
        .presentationDetents([.medium])
    }
    
    private func kasaSayimiSheet() -> some View {
        KasaSayimView(sistemBakiye: kasaBakiye)
    }
    
    private func loadFinansData() async {
        do {
            let bankaList: [BankaKart] = (try? await SupabaseService.shared.fetch(from: "bankalar")) ?? []
            let cekList: [Cek] = (try? await SupabaseService.shared.fetch(from: "cekler")) ?? []
            let chList: [CariHareket] = (try? await SupabaseService.shared.fetch(from: "cari_hareketler", orderBy: "tarih.desc", limit: 30)) ?? []
            
            await MainActor.run {
                self.bankaBakiye = bankaList.reduce(0.0) { $0 + $1.bakiye }
                self.portfoyCekBakiye = cekList.filter { $0.durum != "TAHSIL_EDILDI" }.reduce(0.0) { $0 + $1.tutar }
                self.posBakiye = 0.0
                self.kasaBakiye = 0.0
                
                self.hareketler = chList.map { ch in
                    let isGiris = ch.alacak > 0
                    let tutar = isGiris ? ch.alacak : ch.borc
                    let dateStr = ch.tarih != nil ? String(ch.tarih!.prefix(10)) : "Bugün"
                    return FinansListItem(
                        title: ch.aciklama ?? ch.islemTuru ?? "Cari İşlem",
                        description: ch.islemTuru ?? "Hareket",
                        amount: tutar,
                        date: dateStr,
                        type: isGiris ? "In" : "Out",
                        method: ch.islemTuru ?? "İşlem"
                    )
                }
                
                self.cekler = cekList.map { c in
                    CekItem(
                        portfoyNo: c.cekNo ?? "ÇEK",
                        kesideci: c.cariUnvan ?? (c.borclu ?? "-"),
                        banka: c.banka ?? "-",
                        vade: c.vadeTarihi,
                        tutar: c.tutar,
                        durum: c.durum,
                        tip: c.cekTuru ?? "ALINAN"
                    )
                }
            }
        }
    }
}
