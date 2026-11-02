import SwiftUI

public struct AraclarView: View {
    @State private var tutar: String = "1000"
    @State private var kdvOrani: Double = 20.0
    @State private var isDahil: Bool = false
    
    public init() {}
    
    public var girilenTutar: Double {
        Double(tutar.replacingOccurrences(of: ",", with: ".")) ?? 0.0
    }
    
    public var matrah: Double {
        if isDahil {
            return girilenTutar / (1.0 + (kdvOrani / 100.0))
        } else {
            return girilenTutar
        }
    }
    
    public var kdvTutari: Double {
        if isDahil {
            return girilenTutar - matrah
        } else {
            return girilenTutar * (kdvOrani / 100.0)
        }
    }
    
    public var toplamTutar: Double {
        if isDahil {
            return girilenTutar
        } else {
            return girilenTutar + kdvTutari
        }
    }
    
    public var body: some View {
        NavigationStack {
            ZStack {
                AppTheme.background.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 20) {
                        HStack {
                            Text("Finansal Araçlar")
                                .font(.system(size: 24, weight: .bold))
                                .foregroundColor(AppTheme.textPrimary)
                            Spacer()
                        }
                        .padding(.horizontal)
                        .padding(.top, 8)
                        
                        // KDV Hesaplayıcı Kartı
                        GlassCard(cornerRadius: 18, padding: 18) {
                            VStack(spacing: 16) {
                                HStack {
                                    Text("KDV HESAPLAYICI")
                                        .font(.system(size: 12, weight: .bold))
                                        .foregroundColor(AppTheme.textSecondary)
                                    Spacer()
                                    Image(systemName: "percent")
                                        .foregroundColor(AppTheme.primary)
                                }
                                
                                Picker("Hesaplama Türü", selection: $isDahil) {
                                    Text("KDV Hariçten Dahile").tag(false)
                                    Text("KDV Dahilden Harice").tag(true)
                                }
                                .pickerStyle(.segmented)
                                
                                FormField(label: "Tutar (₺)", text: $tutar, placeholder: "1000")
                                
                                VStack(alignment: .leading, spacing: 6) {
                                    Text("KDV Oranı: %\(Int(kdvOrani))")
                                        .font(.system(size: 12, weight: .semibold))
                                        .foregroundColor(AppTheme.textSecondary)
                                    
                                    Picker("KDV Oranı", selection: $kdvOrani) {
                                        Text("%1").tag(1.0)
                                        Text("%10").tag(10.0)
                                        Text("%20").tag(20.0)
                                    }
                                    .pickerStyle(.segmented)
                                }
                                
                                Divider().background(AppTheme.border)
                                
                                DetailSummaryRow(label: "Net Matrah:", value: AppFormatters.money(matrah))
                                DetailSummaryRow(label: "KDV Tutarı (% \(Int(kdvOrani))):", value: AppFormatters.money(kdvTutari))
                                
                                HStack {
                                    Text("GENEL TOPLAM:")
                                        .font(.system(size: 14, weight: .bold))
                                        .foregroundColor(AppTheme.textPrimary)
                                    Spacer()
                                    Text(AppFormatters.money(toplamTutar))
                                        .font(.system(size: 20, weight: .heavy))
                                        .foregroundColor(AppTheme.primary)
                                }
                            }
                        }
                        .padding(.horizontal)
                        
                        // Maliyet Hesaplama Kısayolu
                        NavigationLink(destination: MaliyetHesaplamaView()) {
                            GlassCard(cornerRadius: 16, padding: 16) {
                                HStack(spacing: 14) {
                                    ZStack {
                                        Circle()
                                            .fill(AppTheme.success.opacity(0.15))
                                            .frame(width: 44, height: 44)
                                        Image(systemName: "slider.horizontal.3")
                                            .font(.system(size: 20, weight: .bold))
                                            .foregroundColor(AppTheme.success)
                                    }
                                    
                                    VStack(alignment: .leading, spacing: 3) {
                                        Text("Ürün & Reçete Maliyet Simülatörü")
                                            .font(.system(size: 14, weight: .bold))
                                            .foregroundColor(AppTheme.textPrimary)
                                        Text("Hammadde, işçilik, genel gider ve kar marjı hesabı")
                                            .font(.system(size: 11))
                                            .foregroundColor(AppTheme.textSecondary)
                                    }
                                    
                                    Spacer()
                                    
                                    Image(systemName: "chevron.right")
                                        .foregroundColor(AppTheme.textMuted)
                                }
                            }
                        }
                        .padding(.horizontal)
                        
                        Spacer().frame(height: 70)
                    }
                }
            }
            .navigationBarHidden(true)
        }
    }
}

