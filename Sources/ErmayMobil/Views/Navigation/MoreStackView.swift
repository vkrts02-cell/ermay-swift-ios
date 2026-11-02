import SwiftUI

public struct MoreStackView: View {
    public init() {}
    
    public var body: some View {
        NavigationStack {
            ZStack {
                AppTheme.background.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 16) {
                        HStack {
                            Text("Daha Fazla Modül")
                                .font(.system(size: 24, weight: .bold))
                                .foregroundColor(AppTheme.textPrimary)
                            Spacer()
                        }
                        .padding(.horizontal)
                        .padding(.top, 8)
                        
                        VStack(spacing: 10) {
                            NavigationLink(destination: FaturalarView()) {
                                MoreMenuItem(title: "Faturalar", subtitle: "Satış & Alış faturaları, e-Fatura PDF", icon: "doc.text.fill", color: AppTheme.primary)
                            }
                            
                            NavigationLink(destination: StoklarView()) {
                                MoreMenuItem(title: "Stok Kartları & Envanter", subtitle: "Ürünler, sayım, barkod, gruplar", icon: "shippingbox.fill", color: AppTheme.purple)
                            }
                            
                            NavigationLink(destination: FinansView()) {
                                MoreMenuItem(title: "Finans & Kasa", subtitle: "Nakit akışı, tahsilat ve tediye", icon: "banknote.fill", color: AppTheme.success)
                            }
                            
                            NavigationLink(destination: KasaSayimView()) {
                                MoreMenuItem(title: "Günlük Kasa Sayımı", subtitle: "Banknot sayımı, mutabakat ve kasa fişi", icon: "centsign.circle.fill", color: Color(hex: "10B981"))
                            }
                            
                            NavigationLink(destination: BankaListView()) {
                                MoreMenuItem(title: "Banka Hesapları & EFT", subtitle: "Banka bakiyeleri, IBAN kopyalama, EFT", icon: "building.columns.fill", color: Color(hex: "0A84FF"))
                            }
                            
                            NavigationLink(destination: CekSenetListView()) {
                                MoreMenuItem(title: "Çek & Senet Takibi", subtitle: "Portföy, bankada, tahsilat, karşılıksız", icon: "newspaper.fill", color: Color(hex: "FF9F0A"))
                            }
                            
                            NavigationLink(destination: VadeTakipView()) {
                                MoreMenuItem(title: "Vade & Tahsilat Takibi", subtitle: "Vadesi yaklaşan ve geciken bakiyeler", icon: "clock.badge.checkmark.fill", color: AppTheme.warning)
                            }
                            
                            NavigationLink(destination: BorcHatirlaticiView()) {
                                MoreMenuItem(title: "Borç & Vade Hatırlatıcı", subtitle: "WhatsApp hatırlatma, alarm kurma", icon: "bell.badge.fill", color: Color(hex: "F43F5E"))
                            }
                            
                            NavigationLink(destination: MusteriLimitView()) {
                                MoreMenuItem(title: "Müşteri Risk & Limit Takibi", subtitle: "Açık hesap limiti, risk puanı, gecikme", icon: "shield.lefthalf.filled", color: Color(hex: "EF4444"))
                            }
                            
                            NavigationLink(destination: MusteriTakipView()) {
                                MoreMenuItem(title: "Müşteri Takip (CRM)", subtitle: "Ziyaretler, görüşmeler, aksiyonlar", icon: "person.crop.rectangle.stack.fill", color: AppTheme.info)
                            }
                            
                            NavigationLink(destination: DovizView()) {
                                MoreMenuItem(title: "Döviz Kurları & Çevirici", subtitle: "Canlı TCMB kurları, USD/EUR/TL", icon: "coloncurrencysign.circle.fill", color: Color(hex: "10B981"))
                            }
                            
                            NavigationLink(destination: KanbanView()) {
                                MoreMenuItem(title: "Görev Panosu (Kanban)", subtitle: "İş takibi, yapılacaklar listesi", icon: "square.grid.3x1.folder.fill.badge.plus", color: Color(hex: "EC4899"))
                            }
                            
                            NavigationLink(destination: RaporlarView()) {
                                MoreMenuItem(title: "Finans & Muhasebe Raporları", subtitle: "Gelir-Gider, KDV beyan, stok değeri", icon: "chart.bar.fill", color: Color(hex: "06B6D4"))
                            }
                            
                            NavigationLink(destination: AraclarView()) {
                                MoreMenuItem(title: "Finansal Araçlar & KDV", subtitle: "KDV hesaplayıcı, maliyet simülatörü", icon: "function", color: Color(hex: "F97316"))
                            }
                            
                            NavigationLink(destination: FaturaTasarimView()) {
                                MoreMenuItem(title: "Fatura & PDF Tasarımı", subtitle: "Firma başlığı, banka IBAN ve dipnot şablonu", icon: "paintbrush.fill", color: Color(hex: "8B5CF6"))
                            }
                            
                            NavigationLink(destination: BildirimlerView()) {
                                MoreMenuItem(title: "Bildirim Merkezi", subtitle: "Kritik stok, vade ve sistem uyarıları", icon: "app.badge.fill", color: Color(hex: "06B6D4"))
                            }
                            
                            NavigationLink(destination: AyarlarView()) {
                                MoreMenuItem(title: "Ayarlar & Sistem", subtitle: "Firma profili, kilit, bulut bağlantısı", icon: "gearshape.fill", color: AppTheme.textSecondary)
                            }
                        }
                        .padding(.horizontal)
                        
                        Spacer().frame(height: 80)
                    }
                }
            }
            .navigationBarHidden(true)
        }
    }
}

struct MoreMenuItem: View {
    let title: String
    let subtitle: String
    let icon: String
    let color: Color
    
    var body: some View {
        GlassCard(cornerRadius: 14, padding: 14) {
            HStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(color.opacity(0.15))
                        .frame(width: 40, height: 40)
                    Image(systemName: icon)
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(color)
                }
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(AppTheme.textPrimary)
                    Text(subtitle)
                        .font(.system(size: 11))
                        .foregroundColor(AppTheme.textSecondary)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(AppTheme.textMuted)
            }
        }
    }
}
