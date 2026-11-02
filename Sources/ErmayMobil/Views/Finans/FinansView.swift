import SwiftUI

public struct FinansView: View {
    @State private var selectedTab: String = "ozet" // "ozet", "hesaplar", "hareketler"
    @State private var period: String = "Aylık" // "Haftalık", "Aylık", "6 Aylık", "Yıllık"
    @State private var searchText: String = ""
    
    @State private var hesaplar: [KasaBanka] = [
        KasaBanka(id: "1", hesapAdi: "Merkez TL Kasası", hesapTuru: "KASA", bakiye: 45850.50),
        KasaBanka(id: "2", hesapAdi: "Garanti BBVA Ticari TL", hesapTuru: "BANKA", bankaAdi: "Garanti BBVA", iban: "TR12 0006 2000 1234 5678 9012 34", bakiye: 154000.00),
        KasaBanka(id: "3", hesapAdi: "İş Bankası Şirket Hesabı", hesapTuru: "BANKA", bankaAdi: "Türkiye İş Bankası", iban: "TR64 0006 4000 0012 3456 7890 12", bakiye: 46000.00)
    ]
    
    @State private var hareketler: [KasaHareket] = [
        KasaHareket(id: "1", tarih: "02.11.2026", islemTuru: "Tahsilat", belgeNo: "THS-094", tutar: 15000.0, aciklama: "Ermay Bilişim Nakit Tahsilat"),
        KasaHareket(id: "2", tarih: "01.11.2026", islemTuru: "Ödeme", belgeNo: "EFT-102", tutar: 28000.0, aciklama: "Akıncılar Çelik Döküm Malzeme Bedeli"),
        KasaHareket(id: "3", tarih: "30.10.2026", islemTuru: "Tahsilat", belgeNo: "THS-093", tutar: 35000.0, aciklama: "Kaya Metal Kalıp Çek Tahsilatı"),
        KasaHareket(id: "4", tarih: "28.10.2026", islemTuru: "Ödeme", belgeNo: "EFT-101", tutar: 9400.0, aciklama: "Özkanlar Ambalaj Fatura Kapatma"),
        KasaHareket(id: "5", tarih: "25.10.2026", islemTuru: "Virman", belgeNo: "VRM-003", tutar: 10000.0, aciklama: "Kasadan Garanti Bankasına Nakit Yatırma")
    ]
    
    // Sheets
    @State private var showTahsilatForm: Bool = false
    @State private var isTahsilat: Bool = true
    @State private var isLoading: Bool = false
    
    public init() {}
    
    public var toplamKasa: Double {
        hesaplar.filter { $0.hesapTuru.uppercased() == "KASA" }.reduce(0.0) { $0 + $1.bakiye }
    }
    
    public var toplamBanka: Double {
        hesaplar.filter { $0.hesapTuru.uppercased() == "BANKA" }.reduce(0.0) { $0 + $1.bakiye }
    }
    
    public var netLikidite: Double {
        toplamKasa + toplamBanka
    }
    
    public var filteredHareketler: [KasaHareket] {
        hareketler.filter { h in
            searchText.isEmpty ||
                h.aciklama.localizedCaseInsensitiveContains(searchText) ||
                h.islemTuru.localizedCaseInsensitiveContains(searchText) ||
                (h.belgeNo?.localizedCaseInsensitiveContains(searchText) ?? false)
        }
    }
    
    public var body: some View {
        NavigationStack {
            ZStack {
                AppTheme.background.ignoresSafeArea()
                
                VStack(spacing: 12) {
                    // Header Bar (Exact match to FinansScreen.tsx)
                    HStack {
                        Text("Finans Yönetimi")
                            .font(.system(size: 24, weight: .black))
                            .foregroundColor(AppTheme.textPrimary)
                        
                        Spacer()
                        
                        HStack(spacing: 8) {
                            Button {
                                isTahsilat = true
                                showTahsilatForm = true
                            } label: {
                                Image(systemName: "arrow.down.left.circle.fill")
                                    .font(.system(size: 26))
                                    .foregroundColor(Color(hex: "30D158"))
                            }
                            
                            Button {
                                isTahsilat = false
                                showTahsilatForm = true
                            } label: {
                                Image(systemName: "arrow.up.right.circle.fill")
                                    .font(.system(size: 26))
                                    .foregroundColor(Color(hex: "FF453A"))
                            }
                        }
                    }
                    .padding(.horizontal)
                    .padding(.top, 8)
                    
                    // Segmented Tabs (Özet & Akış / Kasa & Banka / Hareketler)
                    HStack(spacing: 6) {
                        TabPill(title: "Özet & Akış", isSelected: selectedTab == "ozet") {
                            selectedTab = "ozet"
                        }
                        TabPill(title: "Kasa & Banka", isSelected: selectedTab == "hesaplar") {
                            selectedTab = "hesaplar"
                        }
                        TabPill(title: "Hareketler", isSelected: selectedTab == "hareketler") {
                            selectedTab = "hareketler"
                        }
                    }
                    .padding(.horizontal)
                    
                    ScrollView {
                        VStack(spacing: 16) {
                            if selectedTab == "ozet" {
                                ozetView
                            } else if selectedTab == "hesaplar" {
                                hesaplarView
                            } else {
                                hareketlerView
                            }
                            
                            Spacer().frame(height: 80)
                        }
                    }
                }
            }
            .navigationBarHidden(true)
            .sheet(isPresented: $showTahsilatForm) {
                TahsilatFormView(isTahsilat: isTahsilat) { yeniHareket in
                    hareketler.insert(yeniHareket, at: 0)
                }
                .enableSwipeBack()
            }
        }
    }
    
    // MARK: - Subviews
    private var ozetView: some View {
        VStack(spacing: 14) {
            // Dönem Filtresi (Haftalık / Aylık / 6 Aylık / Yıllık)
            HStack(spacing: 4) {
                ForEach(["Haftalık", "Aylık", "6 Aylık", "Yıllık"], id: \.self) { p in
                    Button {
                        period = p
                    } label: {
                        Text(p)
                            .font(.system(size: 11, weight: period == p ? .bold : .medium))
                            .foregroundColor(period == p ? .white : Color(hex: "94A3B8"))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 7)
                            .background(period == p ? Color(hex: "0061FF") : Color.white.opacity(0.04))
                            .cornerRadius(8)
                    }
                }
            }
            .padding(.horizontal)
            
            // 4'lü Finansal Gösterge Izgarası
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                MetricBox(title: "TOPLAM KASA", value: AppFormatters.money(toplamKasa), subtitle: "Nakit Mevcut", icon: "centsign.circle.fill", accentColor: Color(hex: "30D158"), isNet: false)
                MetricBox(title: "TOPLAM BANKA", value: AppFormatters.money(toplamBanka), subtitle: "Banka Mevcut", icon: "building.columns.fill", accentColor: Color(hex: "0A84FF"), isNet: false)
                MetricBox(title: "NET LİKİDİTE", value: AppFormatters.money(netLikidite), subtitle: "Hazır Değerler", icon: "wallet.pass.fill", accentColor: Color(hex: "00FF87"), isNet: true)
                MetricBox(title: "BEKLEYEN ÇEK", value: "₺42.500,00", subtitle: "Portföydeki Çekler", icon: "doc.plaintext.fill", accentColor: Color(hex: "BF5AF2"), isNet: false)
            }
            .padding(.horizontal)
            
            // Son Hareketler Akışı
            GlassCard(cornerRadius: 18, padding: 16) {
                VStack(alignment: .leading, spacing: 12) {
                    Text("SON NAKİT HAREKETLERİ")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(AppTheme.textSecondary)
                        .tracking(0.5)
                    
                    VStack(spacing: 10) {
                        ForEach(hareketler.prefix(5)) { h in
                            HStack(spacing: 12) {
                                ZStack {
                                    RoundedRectangle(cornerRadius: 10)
                                        .fill((h.islemTuru == "Tahsilat" ? Color(hex: "30D158") : Color(hex: "FF453A")).opacity(0.15))
                                        .frame(width: 36, height: 36)
                                    Image(systemName: h.islemTuru == "Tahsilat" ? "arrow.down.left" : "arrow.up.right")
                                        .font(.system(size: 13, weight: .bold))
                                        .foregroundColor(h.islemTuru == "Tahsilat" ? Color(hex: "30D158") : Color(hex: "FF453A"))
                                }
                                
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(h.aciklama)
                                        .font(.system(size: 13, weight: .bold))
                                        .foregroundColor(.white)
                                        .lineLimit(1)
                                    Text("\(h.islemTuru) • \(h.tarih)")
                                        .font(.system(size: 11))
                                        .foregroundColor(Color(hex: "94A3B8"))
                                }
                                
                                Spacer()
                                
                                Text((h.islemTuru == "Tahsilat" ? "+" : "-") + AppFormatters.money(h.tutar))
                                    .font(.system(size: 13, weight: .heavy))
                                    .foregroundColor(h.islemTuru == "Tahsilat" ? Color(hex: "30D158") : Color(hex: "FF453A"))
                            }
                            
                            if h.id != hareketler.prefix(5).last?.id {
                                Divider().background(AppTheme.border.opacity(0.6))
                            }
                        }
                    }
                }
            }
            .padding(.horizontal)
        }
    }
    
    private var hesaplarView: some View {
        VStack(spacing: 12) {
            ForEach(hesaplar) { acc in
                HStack(spacing: 14) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 12)
                            .fill((acc.hesapTuru == "KASA" ? Color(hex: "30D158") : Color(hex: "0A84FF")).opacity(0.15))
                            .frame(width: 44, height: 44)
                        Image(systemName: acc.hesapTuru == "KASA" ? "wallet.pass.fill" : "building.columns.fill")
                            .font(.system(size: 20))
                            .foregroundColor(acc.hesapTuru == "KASA" ? Color(hex: "30D158") : Color(hex: "0A84FF"))
                    }
                    
                    VStack(alignment: .leading, spacing: 3) {
                        Text(acc.hesapAdi)
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(.white)
                        
                        if let iban = acc.iban {
                            Text(iban)
                                .font(.system(size: 10, weight: .medium))
                                .foregroundColor(Color(hex: "94A3B8"))
                                .lineLimit(1)
                        } else {
                            Text("Nakit Kasa")
                                .font(.system(size: 11))
                                .foregroundColor(Color(hex: "94A3B8"))
                        }
                    }
                    
                    Spacer()
                    
                    Text(AppFormatters.money(acc.bakiye))
                        .font(.system(size: 14, weight: .heavy))
                        .foregroundColor(Color(hex: "00FF87"))
                }
                .padding(14)
                .background(Color(hex: "121216"))
                .cornerRadius(16)
                .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.white.opacity(0.08), lineWidth: 1))
            }
        }
        .padding(.horizontal)
    }
    
    private var hareketlerView: some View {
        VStack(spacing: 12) {
            // Search Bar
            HStack(spacing: 8) {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(Color(hex: "94A3B8"))
                TextField("Açıklama veya evrak no ara...", text: $searchText)
                    .foregroundColor(.white)
                    .font(.system(size: 14))
                if !searchText.isEmpty {
                    Button {
                        searchText = ""
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(Color(hex: "94A3B8"))
                    }
                }
            }
            .padding(12)
            .background(Color(hex: "121216"))
            .cornerRadius(12)
            .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.white.opacity(0.08), lineWidth: 1))
            .padding(.horizontal)
            
            ForEach(filteredHareketler) { h in
                HStack(spacing: 12) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 10)
                            .fill((h.islemTuru == "Tahsilat" ? Color(hex: "30D158") : Color(hex: "FF453A")).opacity(0.15))
                            .frame(width: 40, height: 40)
                        Image(systemName: h.islemTuru == "Tahsilat" ? "arrow.down.left" : "arrow.up.right")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(h.islemTuru == "Tahsilat" ? Color(hex: "30D158") : Color(hex: "FF453A"))
                    }
                    
                    VStack(alignment: .leading, spacing: 3) {
                        Text(h.aciklama)
                            .font(.system(size: 13, weight: .bold))
                            .foregroundColor(.white)
                            .lineLimit(1)
                        Text("\(h.islemTuru) • \(h.tarih)\(h.belgeNo != nil ? " • " + h.belgeNo! : "")")
                            .font(.system(size: 11))
                            .foregroundColor(Color(hex: "94A3B8"))
                    }
                    
                    Spacer()
                    
                    Text((h.islemTuru == "Tahsilat" ? "+" : "-") + AppFormatters.money(h.tutar))
                        .font(.system(size: 13, weight: .heavy))
                        .foregroundColor(h.islemTuru == "Tahsilat" ? Color(hex: "30D158") : Color(hex: "FF453A"))
                }
                .padding(12)
                .background(Color(hex: "121216"))
                .cornerRadius(14)
                .overlay(RoundedRectangle(cornerRadius: 14).stroke(Color.white.opacity(0.08), lineWidth: 1))
                .padding(.horizontal)
            }
        }
    }
}
