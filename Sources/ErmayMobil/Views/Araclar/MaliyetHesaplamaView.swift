import SwiftUI

public struct MaliyetHesaplamaView: View {
    // Section 1: Toplam KG Hesaplama
    @State private var gr: String = "0"
    @State private var en: String = "160"
    @State private var sarim: String = "0"
    @State private var toplamKgSonuc: String = "0.00 KG"
    
    // Section 2: Top Fiyatı Hesaplama
    @State private var toplamKg: String = "0"
    @State private var kgFiyati: String = "0"
    @State private var topFiyatiSonuc: String = "0.00 $"
    
    // Section 3: Metrekare Hesaplama
    @State private var topBoy: String = "0"
    @State private var metrekareSonuc: String = "0.00 m²"
    
    // Section 4: Birim Metrekare Maliyeti Hesaplama
    @State private var toplamMetrekare: String = "0"
    @State private var topFiyatiInput: String = "0"
    @State private var birimMaliyetSonuc: String = "0.00 $"
    
    public init() {}
    
    private func parseNum(_ val: String) -> Double {
        let clean = val.replacingOccurrences(of: ",", with: ".")
        return Double(clean) ?? 0.0
    }
    
    // Section 1: Toplam KG Hesapla ((g * e * s) / 100000.0)
    private func hesaplaKg() {
        let g = parseNum(gr)
        let e = parseNum(en)
        let s = parseNum(sarim)
        let sonuc = (g * e * s) / 100000.0
        let formatted = String(format: "%.2f", sonuc)
        toplamKgSonuc = "\(formatted) KG"
        toplamKg = formatted
        topBoy = sarim
    }
    
    // Section 2: Top Fiyatı Hesapla (kg * f)
    private func hesaplaTopFiyati() {
        let kg = parseNum(toplamKg)
        let f = parseNum(kgFiyati)
        let sonuc = kg * f
        let formatted = String(format: "%.2f", sonuc)
        topFiyatiSonuc = "\(formatted) $"
        topFiyatiInput = formatted
    }
    
    // Section 3: Metrekare Hesapla (boy * 1.6)
    private func hesaplaMetrekare() {
        let boy = parseNum(topBoy)
        let sonuc = boy * 1.6
        let formatted = String(format: "%.2f", sonuc)
        metrekareSonuc = "\(formatted) m²"
        toplamMetrekare = formatted
    }
    
    // Section 4: Birim Metrekare Maliyeti Hesapla (topFiyati / m2)
    private func hesaplaBirimMaliyet() {
        let m2 = parseNum(toplamMetrekare)
        let f = parseNum(topFiyatiInput)
        if m2 == 0 {
            birimMaliyetSonuc = "0.00 $"
            return
        }
        let sonuc = f / m2
        birimMaliyetSonuc = String(format: "%.2f $", sonuc)
    }
    
    public var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header (Exact to MaliyetHesaplamaScreen.tsx)
                HStack(spacing: 12) {
                    Image(systemName: "plus.forwardslash.minus")
                        .font(.system(size: 26))
                        .foregroundColor(Color(hex: "0D9488"))
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Hesap Makinası")
                            .font(.system(size: 24, weight: .heavy))
                            .foregroundColor(.white)
                            .tracking(-0.5)
                        Text("Reaktif Maliyet & Ölçü Hesaplayıcı")
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(Color(hex: "8E8E93"))
                    }
                    Spacer()
                }
                .padding(.horizontal, 16)
                .padding(.top, 10)
                .padding(.bottom, 14)
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 16) {
                        // 1. Toplam KG Hesaplama
                        VStack(alignment: .leading, spacing: 12) {
                            HStack(spacing: 8) {
                                Image(systemName: "scalemass.fill")
                                    .foregroundColor(Color(hex: "0D9488"))
                                Text("1. Toplam KG Hesaplama")
                                    .font(.system(size: 14, weight: .bold))
                                    .foregroundColor(.white)
                            }
                            
                            HStack(spacing: 8) {
                                calcField(label: "Gramaj (g/m²)", text: $gr)
                                calcField(label: "En (cm)", text: $en)
                                calcField(label: "Sarım (mt)", text: $sarim)
                            }
                            
                            HStack {
                                Button {
                                    hesaplaKg()
                                } label: {
                                    Text("KG Hesapla")
                                        .font(.system(size: 13, weight: .bold))
                                        .foregroundColor(.white)
                                        .padding(.horizontal, 18)
                                        .padding(.vertical, 10)
                                        .background(Color(hex: "0D9488"))
                                        .cornerRadius(8)
                                }
                                
                                Spacer()
                                
                                Text(toplamKgSonuc)
                                    .font(.system(size: 18, weight: .heavy))
                                    .foregroundColor(Color(hex: "0D9488"))
                            }
                            .padding(.top, 4)
                        }
                        .padding(16)
                        .background(Color(hex: "121216"))
                        .cornerRadius(18)
                        .overlay(RoundedRectangle(cornerRadius: 18).stroke(Color.white.opacity(0.08), lineWidth: 1))
                        
                        // 2. Top Fiyatı Hesaplama
                        VStack(alignment: .leading, spacing: 12) {
                            HStack(spacing: 8) {
                                Image(systemName: "dollarsign.circle.fill")
                                    .foregroundColor(Color(hex: "0D9488"))
                                Text("2. Top Fiyatı Hesaplama")
                                    .font(.system(size: 14, weight: .bold))
                                    .foregroundColor(.white)
                            }
                            
                            HStack(spacing: 10) {
                                calcField(label: "Toplam KG", text: $toplamKg)
                                calcField(label: "KG Fiyatı ($)", text: $kgFiyati)
                            }
                            
                            HStack {
                                Button {
                                    hesaplaTopFiyati()
                                } label: {
                                    Text("Top Fiyatı Hesapla")
                                        .font(.system(size: 13, weight: .bold))
                                        .foregroundColor(.white)
                                        .padding(.horizontal, 18)
                                        .padding(.vertical, 10)
                                        .background(Color(hex: "0D9488"))
                                        .cornerRadius(8)
                                }
                                
                                Spacer()
                                
                                Text(topFiyatiSonuc)
                                    .font(.system(size: 18, weight: .heavy))
                                    .foregroundColor(Color(hex: "0D9488"))
                            }
                            .padding(.top, 4)
                        }
                        .padding(16)
                        .background(Color(hex: "121216"))
                        .cornerRadius(18)
                        .overlay(RoundedRectangle(cornerRadius: 18).stroke(Color.white.opacity(0.08), lineWidth: 1))
                        
                        // 3. Metrekare Hesaplama
                        VStack(alignment: .leading, spacing: 12) {
                            HStack(spacing: 8) {
                                Image(systemName: "square.dashed")
                                    .foregroundColor(Color(hex: "0D9488"))
                                Text("3. Metrekare Hesaplama")
                                    .font(.system(size: 14, weight: .bold))
                                    .foregroundColor(.white)
                            }
                            
                            HStack(spacing: 10) {
                                calcField(label: "Top Boyu (mt)", text: $topBoy)
                                
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Sabit En (1.6m)").font(.system(size: 11, weight: .semibold)).foregroundColor(Color(hex: "8E8E93"))
                                    Text("160 cm (Sabit)")
                                        .font(.system(size: 13))
                                        .foregroundColor(Color(hex: "8E8E93"))
                                        .padding(10)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .background(Color.white.opacity(0.02))
                                        .cornerRadius(8)
                                }
                            }
                            
                            HStack {
                                Button {
                                    hesaplaMetrekare()
                                } label: {
                                    Text("m² Hesapla")
                                        .font(.system(size: 13, weight: .bold))
                                        .foregroundColor(.white)
                                        .padding(.horizontal, 18)
                                        .padding(.vertical, 10)
                                        .background(Color(hex: "0D9488"))
                                        .cornerRadius(8)
                                }
                                
                                Spacer()
                                
                                Text(metrekareSonuc)
                                    .font(.system(size: 18, weight: .heavy))
                                    .foregroundColor(Color(hex: "0D9488"))
                            }
                            .padding(.top, 4)
                        }
                        .padding(16)
                        .background(Color(hex: "121216"))
                        .cornerRadius(18)
                        .overlay(RoundedRectangle(cornerRadius: 18).stroke(Color.white.opacity(0.08), lineWidth: 1))
                        
                        // 4. Birim Metrekare Maliyeti Hesaplama
                        VStack(alignment: .leading, spacing: 12) {
                            HStack(spacing: 8) {
                                Image(systemName: "chart.pie.fill")
                                    .foregroundColor(Color(hex: "0D9488"))
                                Text("4. Birim Metrekare Maliyeti Hesaplama")
                                    .font(.system(size: 14, weight: .bold))
                                    .foregroundColor(.white)
                            }
                            
                            HStack(spacing: 10) {
                                calcField(label: "Toplam Metrekare (m²)", text: $toplamMetrekare)
                                calcField(label: "Top Fiyatı ($)", text: $topFiyatiInput)
                            }
                            
                            HStack {
                                Button {
                                    hesaplaBirimMaliyet()
                                } label: {
                                    Text("m² Maliyeti Hesapla")
                                        .font(.system(size: 13, weight: .bold))
                                        .foregroundColor(.white)
                                        .padding(.horizontal, 18)
                                        .padding(.vertical, 10)
                                        .background(Color(hex: "0D9488"))
                                        .cornerRadius(8)
                                }
                                
                                Spacer()
                                
                                Text(birimMaliyetSonuc)
                                    .font(.system(size: 18, weight: .heavy))
                                    .foregroundColor(Color(hex: "0D9488"))
                            }
                            .padding(.top, 4)
                        }
                        .padding(16)
                        .background(Color(hex: "121216"))
                        .cornerRadius(18)
                        .overlay(RoundedRectangle(cornerRadius: 18).stroke(Color.white.opacity(0.08), lineWidth: 1))
                        
                        Spacer().frame(height: 110)
                    }
                    .padding(.horizontal, 16)
                }
            }
        }
        .navigationBarHidden(true)
    }
    
    private func calcField(label: String, text: Binding<String>) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(label).font(.system(size: 11, weight: .semibold)).foregroundColor(Color(hex: "8E8E93"))
            TextField("0", text: text)
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.white)
                .padding(10)
                .background(Color.white.opacity(0.05))
                .cornerRadius(8)
                .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.white.opacity(0.08), lineWidth: 1))
        }
        .frame(maxWidth: .infinity)
    }
}
