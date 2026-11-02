import SwiftUI

public struct MaliyetHesaplamaView: View {
    @State private var hammadde: String = "150"
    @State private var iscilik: String = "40"
    @State private var genelGider: String = "20"
    @State private var karMarji: String = "30"
    @State private var kdvOrani: Double = 20.0
    
    public init() {}
    
    public var toplamMaliyet: Double {
        (Double(hammadde) ?? 0) + (Double(iscilik) ?? 0) + (Double(genelGider) ?? 0)
    }
    
    public var karTutari: Double {
        let marj = Double(karMarji) ?? 0
        return toplamMaliyet * (marj / 100.0)
    }
    
    public var satisFiyatiKdvHaric: Double {
        toplamMaliyet + karTutari
    }
    
    public var nihaiSatisFiyatiKdvDahil: Double {
        satisFiyatiKdvHaric * (1.0 + (kdvOrani / 100.0))
    }
    
    public var body: some View {
        ZStack {
            AppTheme.background.ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 16) {
                    GlassCard(cornerRadius: 18, padding: 18) {
                        VStack(spacing: 14) {
                            Text("MALİYET BİLEŞENLERİ (BİRİM)")
                                .font(.system(size: 11, weight: .bold))
                                .foregroundColor(AppTheme.textSecondary)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            
                            FormField(label: "Hammadde / Malzeme Maliyeti (₺)", text: $hammadde, placeholder: "0.00")
                            FormField(label: "İşçilik Maliyeti (₺)", text: $iscilik, placeholder: "0.00")
                            FormField(label: "Genel Üretim / Amortisman Gideri (₺)", text: $genelGider, placeholder: "0.00")
                            FormField(label: "Hedef Kar Marjı (%)", text: $karMarji, placeholder: "30")
                            
                            VStack(alignment: .leading, spacing: 6) {
                                Text("Uygulanacak KDV: %\(Int(kdvOrani))")
                                    .font(.system(size: 12, weight: .semibold))
                                    .foregroundColor(AppTheme.textSecondary)
                                
                                Picker("KDV", selection: $kdvOrani) {
                                    Text("%1").tag(1.0)
                                    Text("%10").tag(10.0)
                                    Text("%20").tag(20.0)
                                }
                                .pickerStyle(.segmented)
                            }
                        }
                    }
                    
                    // Sonuç Kartı
                    GlassCard(cornerRadius: 18, padding: 18) {
                        VStack(spacing: 10) {
                            DetailSummaryRow(label: "Toplam Üretim Maliyeti:", value: AppFormatters.money(toplamMaliyet))
                            DetailSummaryRow(label: "Birim Kar Tutarı (% \(karMarji)):", value: AppFormatters.money(karTutari))
                            DetailSummaryRow(label: "Satış Fiyatı (KDV Hariç):", value: AppFormatters.money(satisFiyatiKdvHaric))
                            
                            Divider().background(AppTheme.border)
                            
                            VStack(spacing: 4) {
                                Text("TAVSİYE EDİLEN SATIŞ FİYATI (KDV DAHİL)")
                                    .font(.system(size: 11, weight: .bold))
                                    .foregroundColor(AppTheme.textSecondary)
                                
                                Text(AppFormatters.money(nihaiSatisFiyatiKdvDahil))
                                    .font(.system(size: 26, weight: .heavy))
                                    .foregroundColor(AppTheme.success)
                            }
                        }
                    }
                    
                    Spacer().frame(height: 20)
                }
                .padding()
            }
        }
        .navigationTitle("Maliyet Simülatörü")
        .navigationBarTitleDisplayMode(.inline)
    }
}

