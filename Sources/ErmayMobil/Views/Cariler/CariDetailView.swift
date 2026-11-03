import SwiftUI

public struct CariDetailView: View {
    @Environment(\.presentationMode) var presentationMode
    public let cari: CariKart
    
    // Quick Modals
    @State private var showSatisForm: Bool = false
    @State private var showAlisForm: Bool = false
    @State private var showTahsilatForm: Bool = false
    @State private var showOdemeForm: Bool = false
    @State private var showDekontModal: Bool = false
    @State private var dekontTuru: String = "Alacak Dekontu"
    @State private var showYaslandirma: Bool = false
    @State private var showEditForm: Bool = false
    @State private var showDeleteConfirm: Bool = false
    @State private var showShareSheet: Bool = false
    @State private var shareText: String = ""
    
    // Sample Cari Hareketler
    @State private var hareketler: [CariHareket] = [
        CariHareket(id: "1", tarih: "03.11.2026", belgeNo: "FTR-2026-0042", islemTuru: "Satış Faturası", aciklama: "Rulman & Keçe Satışı", alacak: 24500.0),
        CariHareket(id: "2", tarih: "28.10.2026", belgeNo: "THS-0089", islemTuru: "Tahsilat (Banka)", aciklama: "Garanti BBVA Havalesi", alacak: 35000.0),
        CariHareket(id: "3", tarih: "15.10.2026", belgeNo: "FTR-2026-0038", islemTuru: "Alış Faturası", aciklama: "Hammadde Alımı", borc: 18200.0),
        CariHareket(id: "4", tarih: "01.10.2026", belgeNo: "TED-0044", islemTuru: "Ödeme (Kasa)", aciklama: "Nakit Kasa Ödemesi", borc: 6200.0)
    ]
    
    public init(cari: CariKart) {
        self.cari = cari
    }
    
    public var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 16) {
                    renderHeaderBar()
                    renderMainCard()
                    renderActionGrid()
                    renderHareketler()
                    renderIletisim()
                    renderFinansal()
                    renderRiskDurum()
                    renderFooterButtons()
                    Spacer().frame(height: 50)
                }
                .padding(.horizontal, 16)
            }
        }
        .navigationBarHidden(true)
        .sheet(isPresented: $showSatisForm) {
            FaturaFormView(initialTur: "Satış")
        }
        .sheet(isPresented: $showAlisForm) {
            FaturaFormView(initialTur: "Alış")
        }
        .sheet(isPresented: $showTahsilatForm) {
            TahsilatFormView(initialCari: cari, isTahsilat: true)
        }
        .sheet(isPresented: $showOdemeForm) {
            TahsilatFormView(initialCari: cari, isTahsilat: false)
        }
        .sheet(isPresented: $showEditForm) {
            CariFormView(cariToEdit: cari)
        }
        .alert("Cari Sil", isPresented: $showDeleteConfirm) {
            Button("Sil", role: .destructive) {
                presentationMode.wrappedValue.dismiss()
            }
            Button("Vazgeç", role: .cancel) {}
        } message: {
            Text("Bu cariyi silmek istediğinize emin misiniz?")
        }
    }
    
    // MARK: - Subviews
    @ViewBuilder
    private func renderHeaderBar() -> some View {
        HStack {
            Button {
                presentationMode.wrappedValue.dismiss()
            } label: {
                Image(systemName: "chevron.left")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.white)
                    .padding(8)
            }
            
            Text("Cari Detayı")
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(.white)
            
            Spacer()
        }
        .padding(.top, 6)
    }
    
    @ViewBuilder
    private func renderMainCard() -> some View {
        VStack(spacing: 12) {
            Image(systemName: "person.crop.circle.fill")
                .font(.system(size: 64))
                .foregroundColor(Color(hex: "0061FF"))
                .padding(.top, 4)
            
            Text(cari.unvan)
                .font(.system(size: 18, weight: .heavy))
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
            
            Text("\(cari.cariTuru ?? "Alıcı") • \(cari.grupAdi ?? "Müşteri") • \(cari.cariKodu ?? "CARI-000")")
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(Color(hex: "8E8E93"))
            
            // Bakiye Box (Borç / Alacak)
            HStack {
                VStack(spacing: 2) {
                    Text("Borç")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(Color(hex: "8E8E93"))
                    Text(AppFormatters.money(cari.bakiyeTuru == "B" ? cari.bakiye : 0))
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(Color(hex: "EF4444"))
                }
                .frame(maxWidth: .infinity)
                
                Rectangle()
                    .fill(Color.white.opacity(0.1))
                    .frame(width: 1, height: 36)
                
                VStack(spacing: 2) {
                    Text("Alacak")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(Color(hex: "8E8E93"))
                    Text(AppFormatters.money(cari.bakiyeTuru == "A" ? cari.bakiye : 0))
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(Color(hex: "10B981"))
                }
                .frame(maxWidth: .infinity)
            }
            .padding(.vertical, 10)
            .background(Color.white.opacity(0.04))
            .cornerRadius(12)
        }
        .padding(16)
        .background(Color(hex: "121216"))
        .cornerRadius(20)
        .overlay(RoundedRectangle(cornerRadius: 20).stroke(Color.white.opacity(0.08), lineWidth: 1))
    }
    
    @ViewBuilder
    private func renderActionGrid() -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("HIZLI İŞLEMLER")
                .font(.system(size: 12, weight: .bold))
                .foregroundColor(Color(hex: "8E8E93"))
            
            LazyVGrid(columns: [GridItem(.flexible(), spacing: 8), GridItem(.flexible(), spacing: 8)], spacing: 8) {
                actionGridBtn(title: "SATIŞ", iconName: "arrow.up.right", color: Color(hex: "2563EB")) {
                    showSatisForm = true
                }
                actionGridBtn(title: "ALIŞ", iconName: "arrow.down.right", color: Color(hex: "D97706")) {
                    showAlisForm = true
                }
                actionGridBtn(title: "TAHSİLAT", iconName: "arrow.down.left", color: Color(hex: "10B981")) {
                    showTahsilatForm = true
                }
                actionGridBtn(title: "ÖDEME", iconName: "arrow.up.right", color: Color(hex: "EF4444")) {
                    showOdemeForm = true
                }
                actionGridBtn(title: "ALACAK", iconName: "plus", color: Color(hex: "8B5CF6")) {
                    dekontTuru = "Alacak Dekontu"
                    showDekontModal = true
                }
                actionGridBtn(title: "BORÇ", iconName: "plus", color: Color(hex: "EC4899")) {
                    dekontTuru = "Borç Dekontu"
                    showDekontModal = true
                }
                actionGridBtn(title: "Ekstre (PDF)", iconName: "doc.text.fill", color: Color(hex: "2A2A2A")) {
                    exportEkstre(detayli: false)
                }
                actionGridBtn(title: "Det. Ekstre", iconName: "doc.text.magnifyingglass", color: Color(hex: "2A2A2A")) {
                    exportEkstre(detayli: true)
                }
                actionGridBtn(title: "Excel (CSV)", iconName: "tablecells.fill", color: Color(hex: "2A2A2A")) {
                    exportExcel()
                }
                actionGridBtn(title: "Yaşlandırma", iconName: "chart.bar.xaxis", color: Color(hex: "2A2A2A")) {
                    showYaslandirma = true
                }
            }
        }
        .padding(16)
        .background(Color(hex: "121216"))
        .cornerRadius(20)
        .overlay(RoundedRectangle(cornerRadius: 20).stroke(Color.white.opacity(0.08), lineWidth: 1))
    }
    
    @ViewBuilder
    private func renderHareketler() -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Cari Hareketler (Son İşlemler)")
                .font(.system(size: 13, weight: .bold))
                .foregroundColor(.white)
            
            VStack(spacing: 0) {
                ForEach(Array(hareketler.enumerated()), id: \.element.id) { idx, h in
                    HStack {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("\(h.islemTuru ?? "İşlem") • \(h.aciklama ?? "")")
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundColor(.white)
                                .lineLimit(1)
                            Text(h.tarih ?? "-")
                                .font(.system(size: 10))
                                .foregroundColor(Color(hex: "8E8E93"))
                        }
                        
                        Spacer()
                        
                        let isBorc = h.borc > 0
                        let val = isBorc ? h.borc : h.alacak
                        Text("\(isBorc ? "-" : "+")\(AppFormatters.money(val))")
                            .font(.system(size: 13, weight: .bold))
                            .foregroundColor(isBorc ? Color(hex: "EF4444") : Color(hex: "10B981"))
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
    
    @ViewBuilder
    private func renderIletisim() -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("İletişim Bilgileri")
                .font(.system(size: 13, weight: .bold))
                .foregroundColor(.white)
            
            detailRow(icon: "person.circle", text: "Yetkili: \(cari.yetkili ?? "-")")
            detailRow(icon: "phone.fill", text: "Telefon: \(cari.telefon ?? "-")")
            detailRow(icon: "phone.fill", text: "Cep Telefonu: \(cari.gsm ?? "-")")
            detailRow(icon: "envelope.fill", text: "E-Posta: \(cari.email ?? "-")")
            detailRow(icon: "mappin.and.ellipse", text: "Adres: \(cari.adres ?? "-") \(cari.ilce ?? "") / \(cari.sehir ?? "")")
            detailRow(icon: "shippingbox.fill", text: "Sevk Adresi: \(cari.sevkAdresi ?? "-")")
        }
        .padding(16)
        .background(Color(hex: "121216"))
        .cornerRadius(20)
        .overlay(RoundedRectangle(cornerRadius: 20).stroke(Color.white.opacity(0.08), lineWidth: 1))
    }
    
    @ViewBuilder
    private func renderFinansal() -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Finansal & Vergi Bilgileri")
                .font(.system(size: 13, weight: .bold))
                .foregroundColor(.white)
            
            infoRow(label: "T.C. Kimlik No:", val: cari.tcKimlikNo ?? "-")
            infoRow(label: "Vergi Dairesi/No:", val: "\(cari.vergiDairesi ?? "-") / \(cari.vergiNo ?? "-")")
            infoRow(label: "Ticaret Sicil No:", val: cari.ticaretSicilNo ?? "-")
            infoRow(label: "IBAN:", val: cari.iban ?? "-")
            infoRow(label: "Ödeme Planı / Vade:", val: "\(cari.odemePlani ?? "Peşin") / \(cari.vadeGunu ?? 0) Gün")
            infoRow(label: "Risk Limiti:", val: AppFormatters.money(cari.riskLimiti ?? 0))
        }
        .padding(16)
        .background(Color(hex: "121216"))
        .cornerRadius(20)
        .overlay(RoundedRectangle(cornerRadius: 20).stroke(Color.white.opacity(0.08), lineWidth: 1))
    }
    
    @ViewBuilder
    private func renderRiskDurum() -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Risk & Durum Seçenekleri")
                .font(.system(size: 13, weight: .bold))
                .foregroundColor(.white)
            
            infoRow(label: "Risk Takibi Aktif Mi:", val: "Evet")
            infoRow(label: "Geçmiş Vadede Engelle:", val: "Hayır")
            infoRow(label: "Faturada Risk Kontrolü:", val: "Evet")
            infoRow(label: "Kart Durumu:", val: "Aktif", valColor: Color(hex: "10B981"))
        }
        .padding(16)
        .background(Color(hex: "121216"))
        .cornerRadius(20)
        .overlay(RoundedRectangle(cornerRadius: 20).stroke(Color.white.opacity(0.08), lineWidth: 1))
    }
    
    @ViewBuilder
    private func renderFooterButtons() -> some View {
        HStack(spacing: 12) {
            Button {
                showEditForm = true
            } label: {
                HStack(spacing: 6) {
                    Image(systemName: "square.and.pencil")
                    Text("Düzenle")
                }
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(Color(hex: "2563EB"))
                .cornerRadius(12)
            }
            
            Button {
                showDeleteConfirm = true
            } label: {
                HStack(spacing: 6) {
                    Image(systemName: "trash.fill")
                    Text("Sil")
                }
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(Color(hex: "EF4444"))
                .cornerRadius(12)
            }
        }
        .padding(.top, 4)
                    
                    Spacer().frame(height: 50)
                }
                .padding(.horizontal, 16)
            }
        }
        .navigationBarHidden(true)
        .sheet(isPresented: $showSatisForm) {
            FaturaFormView(initialTur: "Satış")
        }
        .sheet(isPresented: $showAlisForm) {
            FaturaFormView(initialTur: "Alış")
        }
        .sheet(isPresented: $showTahsilatForm) {
            TahsilatFormView(initialCari: cari, isTahsilat: true)
        }
        .sheet(isPresented: $showOdemeForm) {
            TahsilatFormView(initialCari: cari, isTahsilat: false)
        }
        .sheet(isPresented: $showEditForm) {
            CariFormView(cariToEdit: cari)
        }
        .alert("Cari Sil", isPresented: $showDeleteConfirm) {
            Button("Sil", role: .destructive) {
                presentationMode.wrappedValue.dismiss()
            }
            Button("Vazgeç", role: .cancel) {}
        } message: {
            Text("\(cari.unvan) isimli cari kartını silmek istediğinize emin misiniz?")
        }
    }
    
    private func actionGridBtn(title: String, iconName: String, color: Color, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Image(systemName: iconName)
                    .font(.system(size: 11, weight: .bold))
                Text(title)
                    .font(.system(size: 11, weight: .bold))
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 10)
            .background(color)
            .cornerRadius(8)
        }
    }
    
    private func detailRow(icon: String, text: String) -> some View {
        HStack(spacing: 10) {
            Image(systemName: icon)
                .font(.system(size: 14))
                .foregroundColor(Color(hex: "64748B"))
                .frame(width: 18)
            Text(text)
                .font(.system(size: 12))
                .foregroundColor(Color(hex: "E2E8F0"))
            Spacer()
        }
    }
    
    private func infoRow(label: String, val: String, valColor: Color = .white) -> some View {
        HStack {
            Text(label)
                .font(.system(size: 12))
                .foregroundColor(Color(hex: "8E8E93"))
            Spacer()
            Text(val)
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(valColor)
        }
    }
    
    private func exportEkstre(detayli: Bool) {
        #if canImport(UIKit)
        let reportText = """
        CARİ HESAP EKSTRESİ
        -------------------
        Cari: \(cari.unvan)
        Vergi No: \(cari.vergiNo ?? "-")
        Tarih: \(ISO8601DateFormatter().string(from: Date()))
        Tür: \(detayli ? "Detaylı Ekstre" : "Özet Ekstre")
        
        Bakiye Durumu: \(AppFormatters.money(cari.bakiye)) \(cari.bakiyeTuru == "A" ? "(Alacaklı)" : "(Borçlu)")
        """
        let av = UIActivityViewController(activityItems: [reportText], applicationActivities: nil)
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let rootVC = windowScene.windows.first?.rootViewController {
            rootVC.present(av, animated: true)
        }
        #endif
    }
    
    private func exportExcel() {
        #if canImport(UIKit)
        let csvText = "Tarih,BelgeNo,IslemTuru,Borc,Alacak,Bakiye\n" +
            hareketler.map { "\($0.tarih ?? ""),\"\($0.belgeNo ?? "")\",\"\($0.islemTuru ?? "")\",\($0.borc ?? 0),\($0.alacak ?? 0)" }.joined(separator: "\n")
        let av = UIActivityViewController(activityItems: [csvText], applicationActivities: nil)
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let rootVC = windowScene.windows.first?.rootViewController {
            rootVC.present(av, animated: true)
        }
        #endif
    }
}
