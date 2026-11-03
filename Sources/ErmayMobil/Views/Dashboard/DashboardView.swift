import SwiftUI

public struct DashboardView: View {
    @State private var activeTab: String = "recents" // "recents" | "receivables" | "payables"
    @State private var goalPeriod: String = "week" // "week" | "month"
    
    // Likidite ve Bakiye Değerleri
    @State private var kasaBakiye: Double = 54200.0
    @State private var bankaBakiye: Double = 276900.0
    @State private var aylikGelir: Double = 184500.0
    @State private var aylikGider: Double = 72300.0
    @State private var bekleyenAlacak: Double = 98400.0
    @State private var bekleyenBorc: Double = 34200.0
    @State private var kritikStokSayisi: Int = 3
    
    // Satış Hedefleri
    @State private var haftalikHedef: Double = 125000.0
    @State private var haftalikGerceklesen: Double = 84500.0
    @State private var aylikHedef: Double = 500000.0
    @State private var aylikGerceklesen: Double = 184500.0
    
    // Listeler
    @State private var sonHareketler: [CariHareket] = [
        CariHareket(id: "1", tarih: "03.11.2026", belgeNo: "FTR-2026-0012", islemTuru: "Satış Faturası", aciklama: "Ermay Ltd. - Rulman Satışı", alacak: 14500.0),
        CariHareket(id: "2", tarih: "02.11.2026", belgeNo: "THS-089", islemTuru: "Tahsilat", aciklama: "Kaya Metal - Banka Havalesi", alacak: 35000.0),
        CariHareket(id: "3", tarih: "01.11.2026", belgeNo: "TED-042", islemTuru: "Tediye", aciklama: "Akıncılar Lojistik - Nakliye", borc: 6200.0),
        CariHareket(id: "4", tarih: "31.10.2026", belgeNo: "FTR-2026-0011", islemTuru: "Alış Faturası", aciklama: "Tekno Hammadde Alımı", borc: 22800.0)
    ]
    @State private var alacaklar: [VadeItem] = [
        VadeItem(cariUnvan: "Ermay Bilişim", faturaNo: "FTR-2026-0012", vadeTarihi: "15.11.2026", tutar: 24500, kalanTutar: 24500, tip: "ALACAK", gecikmeGun: 0),
        VadeItem(cariUnvan: "Mega Plastik", faturaNo: "FTR-2026-0008", vadeTarihi: "28.10.2026", tutar: 14000, kalanTutar: 14000, tip: "ALACAK", gecikmeGun: 6)
    ]
    @State private var borclar: [VadeItem] = [
        VadeItem(cariUnvan: "Akıncılar Çelik", faturaNo: "FTR-2026-0004", vadeTarihi: "10.11.2026", tutar: 18500, kalanTutar: 18500, tip: "BORC", gecikmeGun: 0)
    ]
    
    // Sheet Sunumları
    @State private var showFaturaForm: Bool = false
    @State private var showCariForm: Bool = false
    @State private var showSiparisForm: Bool = false
    @State private var showTeklifForm: Bool = false
    
    public init() {}
    
    private var toplamNakit: Double {
        kasaBakiye + bankaBakiye
    }
    
    private var netFinansalPozisyon: Double {
        toplamNakit + bekleyenAlacak - bekleyenBorc
    }
    
    public var body: some View {
        NavigationStack {
            ZStack {
                AppTheme.background.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 16) {
                        // Üst Bar / Karşılama
                        HStack {
                            VStack(alignment: .leading, spacing: 3) {
                                Text("Hoş Geldiniz,")
                                    .font(.system(size: 12, weight: .medium))
                                    .foregroundColor(AppTheme.textSecondary)
                                Text("ERMAY MUHASEBE")
                                    .font(.system(size: 22, weight: .bold))
                                    .foregroundColor(AppTheme.textPrimary)
                            }
                            Spacer()
                            Button {
                                HardwareService.shared.hapticSuccess()
                            } label: {
                                Image(systemName: "bell.badge.fill")
                                    .font(.system(size: 20))
                                    .foregroundColor(AppTheme.primary)
                                    .padding(8)
                                    .background(Circle().fill(AppTheme.cardSecondary))
                            }
                        }
                        .padding(.horizontal)
                        .padding(.top, 6)
                        
                        // Hero Likidite Kartı
                        GlassCard(cornerRadius: 18, padding: 18) {
                            VStack(alignment: .leading, spacing: 12) {
                                HStack {
                                    Text("TOPLAM LİKİDİTE (KASA & BANKA)")
                                        .font(.system(size: 10, weight: .bold))
                                        .foregroundColor(AppTheme.textSecondary)
                                    Spacer()
                                    Image(systemName: "wallet.pass.fill").foregroundColor(AppTheme.primary)
                                }
                                
                                Text(AppFormatters.money(toplamNakit))
                                    .font(.system(size: 30, weight: .heavy))
                                    .foregroundColor(AppTheme.textPrimary)
                                
                                Divider().background(AppTheme.border)
                                
                                HStack {
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text("Bu Ay Gelir").font(.system(size: 10)).foregroundColor(AppTheme.textMuted)
                                        Text(AppFormatters.money(aylikGelir)).font(.system(size: 13, weight: .bold)).foregroundColor(AppTheme.success)
                                    }
                                    Spacer()
                                    VStack(alignment: .center, spacing: 2) {
                                        Text("Bu Ay Gider").font(.system(size: 10)).foregroundColor(AppTheme.textMuted)
                                        Text(AppFormatters.money(aylikGider)).font(.system(size: 13, weight: .bold)).foregroundColor(AppTheme.danger)
                                    }
                                    Spacer()
                                    VStack(alignment: .trailing, spacing: 2) {
                                        Text("Net Pozisyon").font(.system(size: 10)).foregroundColor(AppTheme.textMuted)
                                        Text(AppFormatters.money(netFinansalPozisyon)).font(.system(size: 13, weight: .bold)).foregroundColor(AppTheme.info)
                                    }
                                }
                            }
                        }
                        .padding(.horizontal)
                        
                        // Satış Hedefi İlerleme Çubuğu
                        GlassCard(cornerRadius: 16, padding: 16) {
                            VStack(alignment: .leading, spacing: 10) {
                                HStack {
                                    Text("SATIŞ HEDEFİ İLERLEMESİ")
                                        .font(.system(size: 10, weight: .bold))
                                        .foregroundColor(AppTheme.textSecondary)
                                    Spacer()
                                    Picker("Dönem", selection: $goalPeriod) {
                                        Text("Haftalık").tag("week")
                                        Text("Aylık").tag("month")
                                    }
                                    .pickerStyle(.segmented)
                                    .frame(width: 140)
                                }
                                
                                let hedef = goalPeriod == "week" ? haftalikHedef : aylikHedef
                                let gerceklesen = goalPeriod == "week" ? haftalikGerceklesen : aylikGerceklesen
                                let oran = hedef > 0 ? (gerceklesen / hedef) : 0
                                
                                HStack {
                                    Text("\(AppFormatters.money(gerceklesen)) / \(AppFormatters.money(hedef))")
                                        .font(.system(size: 13, weight: .bold))
                                        .foregroundColor(AppTheme.textPrimary)
                                    Spacer()
                                    Text("% \(Int(oran * 100))")
                                        .font(.system(size: 14, weight: .heavy))
                                        .foregroundColor(AppTheme.primary)
                                }
                                
                                ProgressView(value: min(1.0, oran)).tint(AppTheme.primary)
                            }
                        }
                        .padding(.horizontal)
                        
                        // 4'lü Özet Metrik Grid
                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                            StatCard(title: "Bekleyen Alacak", value: AppFormatters.money(bekleyenAlacak), subtitle: "Tahsil Edilecek", icon: "arrow.down.left", accentColor: AppTheme.success, isIncrease: true)
                            StatCard(title: "Bekleyen Borç", value: AppFormatters.money(bekleyenBorc), subtitle: "Ödenecek", icon: "arrow.up.right", accentColor: AppTheme.danger, isIncrease: false)
                            StatCard(title: "Kritik Stoklar", value: "\(kritikStokSayisi) Kalem", subtitle: "Sipariş Gerekli", icon: "exclamationmark.triangle.fill", accentColor: AppTheme.warning)
                            StatCard(title: "Dönem Karı", value: AppFormatters.money(aylikGelir - aylikGider), subtitle: "Net Karlılık", icon: "chart.line.uptrend.xyaxis", accentColor: AppTheme.info)
                        }
                        .padding(.horizontal)
                        
                        // Hızlı İşlem Kısayolları
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Hızlı İşlemler")
                                .font(.system(size: 15, weight: .bold))
                                .foregroundColor(AppTheme.textPrimary)
                                .padding(.horizontal)
                            
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 10) {
                                    QuickActionItem(title: "Fatura Kes", icon: "doc.badge.plus", color: AppTheme.primary) { showFaturaForm = true }
                                    QuickActionItem(title: "Yeni Cari", icon: "person.crop.circle.badge.plus", color: AppTheme.success) { showCariForm = true }
                                    QuickActionItem(title: "Sipariş Al", icon: "cart.badge.plus", color: AppTheme.purple) { showSiparisForm = true }
                                    QuickActionItem(title: "Teklif Ver", icon: "paperplane.fill", color: AppTheme.info) { showTeklifForm = true }
                                }
                                .padding(.horizontal)
                            }
                        }
                        
                        // 3 Sekmeli Liste (Son Hareketler | Alacaklar | Borçlar)
                        VStack(alignment: .leading, spacing: 10) {
                            Picker("Sekme", selection: $activeTab) {
                                Text("Son Hareketler").tag("recents")
                                Text("Bekleyen Alacaklar").tag("receivables")
                                Text("Ödenecek Borçlar").tag("payables")
                            }
                            .pickerStyle(.segmented)
                            .padding(.horizontal)
                            
                            VStack(spacing: 8) {
                                if activeTab == "recents" {
                                    ForEach(sonHareketler) { item in
                                        HStack(spacing: 12) {
                                            ZStack {
                                                Circle().fill((item.borc > 0 ? AppTheme.danger : AppTheme.success).opacity(0.15)).frame(width: 38, height: 38)
                                                Image(systemName: item.borc > 0 ? "arrow.up.right" : "arrow.down.left")
                                                    .font(.system(size: 14, weight: .bold))
                                                    .foregroundColor(item.borc > 0 ? AppTheme.danger : AppTheme.success)
                                            }
                                            VStack(alignment: .leading, spacing: 2) {
                                                Text(item.aciklama ?? item.islemTuru ?? "Hareket")
                                                    .font(.system(size: 13, weight: .semibold))
                                                    .foregroundColor(AppTheme.textPrimary)
                                                    .lineLimit(1)
                                                Text(item.tarih ?? "-")
                                                    .font(.system(size: 11))
                                                    .foregroundColor(AppTheme.textMuted)
                                            }
                                            Spacer()
                                            let tutar = item.borc > 0 ? item.borc : item.alacak
                                            Text(AppFormatters.money(tutar))
                                                .font(.system(size: 13, weight: .bold))
                                                .foregroundColor(item.borc > 0 ? AppTheme.danger : AppTheme.success)
                                        }
                                        .padding(12)
                                        .background(AppTheme.cardBackground)
                                        .cornerRadius(12)
                                        .overlay(RoundedRectangle(cornerRadius: 12).stroke(AppTheme.border, lineWidth: 1))
                                    }
                                } else if activeTab == "receivables" {
                                    ForEach(alacaklar) { alacak in
                                        HStack {
                                            VStack(alignment: .leading, spacing: 2) {
                                                Text(alacak.cariUnvan).font(.system(size: 13, weight: .bold)).foregroundColor(AppTheme.textPrimary)
                                                Text("Vade: \(alacak.vadeTarihi) • \(alacak.faturaNo ?? "")").font(.system(size: 11)).foregroundColor(AppTheme.textMuted)
                                            }
                                            Spacer()
                                            Text(AppFormatters.money(alacak.kalanTutar)).font(.system(size: 13, weight: .bold)).foregroundColor(AppTheme.success)
                                        }
                                        .padding(12)
                                        .background(AppTheme.cardBackground)
                                        .cornerRadius(12)
                                    }
                                } else {
                                    ForEach(borclar) { borc in
                                        HStack {
                                            VStack(alignment: .leading, spacing: 2) {
                                                Text(borc.cariUnvan).font(.system(size: 13, weight: .bold)).foregroundColor(AppTheme.textPrimary)
                                                Text("Vade: \(borc.vadeTarihi) • \(borc.faturaNo ?? "")").font(.system(size: 11)).foregroundColor(AppTheme.textMuted)
                                            }
                                            Spacer()
                                            Text(AppFormatters.money(borc.kalanTutar)).font(.system(size: 13, weight: .bold)).foregroundColor(AppTheme.danger)
                                        }
                                        .padding(12)
                                        .background(AppTheme.cardBackground)
                                        .cornerRadius(12)
                                    }
                                }
                            }
                            .padding(.horizontal)
                        }
                        
                        Spacer().frame(height: 80)
                    }
                }
            }
            .navigationBarHidden(true)
            .sheet(isPresented: $showFaturaForm) { FaturaFormView() }
            .sheet(isPresented: $showCariForm) { CariFormView() }
            .sheet(isPresented: $showSiparisForm) { SiparisFormView() }
            .sheet(isPresented: $showTeklifForm) { TeklifFormView() }
        }
    }
}
