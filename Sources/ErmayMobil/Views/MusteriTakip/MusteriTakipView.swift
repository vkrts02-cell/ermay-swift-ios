import SwiftUI

public struct MusteriTakipView: View {
    @State private var kayitlar: [MusteriTakipKayit] = [
        MusteriTakipKayit(id: "1", cariUnvan: "Ermay Bilişim", gorusmeTarihi: "02.11.2026", gorusmeTuru: "ZIYARET", konu: "Yeni Proje Görüşmesi", notlar: "Yıllık bakım sözleşmesi ve yeni parça talepleri görüşüldü.", sonrakiEylem: "Teklif Hazırlanacak", sonrakiEylemTarihi: "05.11.2026", durum: "TAMAMLANDI"),
        MusteriTakipKayit(id: "2", cariUnvan: "Akıncılar Çelik", gorusmeTarihi: "01.11.2026", gorusmeTuru: "TELEFON", konu: "Sipariş Sevkiyat Durumu", notlar: "Cıvata ve rulman sevkiyatının Cuma gününe yetişeceği bildirildi.", sonrakiEylem: "İrsaliye Takip", sonrakiEylemTarihi: "06.11.2026", durum: "PLANLANDI")
    ]
    @State private var showForm: Bool = false
    
    public init() {}
    
    public var body: some View {
        NavigationStack {
            ZStack {
                AppTheme.background.ignoresSafeArea()
                
                VStack(spacing: 14) {
                    HStack {
                        Text("Müşteri Takip & CRM")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(AppTheme.textPrimary)
                        Spacer()
                        Button {
                            showForm = true
                        } label: {
                            Image(systemName: "plus.circle.fill")
                                .font(.system(size: 28))
                                .foregroundColor(AppTheme.primary)
                        }
                    }
                    .padding(.horizontal)
                    .padding(.top, 8)
                    
                    List {
                        ForEach(kayitlar) { item in
                            NavigationLink(destination: MusteriTakipDetayView(kayit: item)) {
                                GlassCard(cornerRadius: 14, padding: 14) {
                                    VStack(alignment: .leading, spacing: 8) {
                                        HStack {
                                            StatusBadge(
                                                title: item.gorusmeTuru,
                                                color: AppTheme.primary
                                            )
                                            Spacer()
                                            StatusBadge(
                                                title: item.durum,
                                                color: item.durum == "TAMAMLANDI" ? AppTheme.success : AppTheme.warning
                                            )
                                        }
                                        
                                        Text(item.cariUnvan)
                                            .font(.system(size: 15, weight: .bold))
                                            .foregroundColor(AppTheme.textPrimary)
                                        
                                        Text(item.konu)
                                            .font(.system(size: 13, weight: .medium))
                                            .foregroundColor(AppTheme.textSecondary)
                                        
                                        if let eylem = item.sonrakiEylem {
                                            HStack(spacing: 4) {
                                                Image(systemName: "arrow.turn.down.right")
                                                    .font(.system(size: 10))
                                                    .foregroundColor(AppTheme.info)
                                                Text("Sonraki: \(eylem) (\(item.sonrakiEylemTarihi ?? "-"))")
                                                    .font(.system(size: 11, weight: .semibold))
                                                    .foregroundColor(AppTheme.info)
                                            }
                                        }
                                    }
                                }
                            }
                            .listRowBackground(Color.clear)
                            .listRowSeparator(.hidden)
                            .listRowInsets(EdgeInsets(top: 4, leading: 16, bottom: 4, trailing: 16))
                        }
                    }
                    .listStyle(.plain)
                    
                    Spacer().frame(height: 70)
                }
            }
            .navigationBarHidden(true)
            .sheet(isPresented: $showForm) {
                YeniGorusmeFormView { yeni in
                    kayitlar.insert(yeni, at: 0)
                }
            }
        }
    }
}

public struct MusteriTakipDetayView: View {
    public let kayit: MusteriTakipKayit
    
    public var body: some View {
        ZStack {
            AppTheme.background.ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 16) {
                    GlassCard(cornerRadius: 18, padding: 18) {
                        VStack(spacing: 12) {
                            Text(kayit.cariUnvan)
                                .font(.system(size: 18, weight: .bold))
                                .foregroundColor(AppTheme.textPrimary)
                            
                            HStack {
                                StatusBadge(title: kayit.gorusmeTuru, color: AppTheme.primary)
                                Spacer()
                                StatusBadge(title: kayit.durum, color: AppTheme.success)
                            }
                            
                            Divider().background(AppTheme.border)
                            
                            DetailInfoRow(label: "Konu", value: kayit.konu)
                            DetailInfoRow(label: "Tarih", value: kayit.gorusmeTarihi)
                            DetailInfoRow(label: "Sonraki Aksiyon", value: kayit.sonrakiEylem ?? "-")
                            DetailInfoRow(label: "Aksiyon Tarihi", value: kayit.sonrakiEylemTarihi ?? "-")
                        }
                    }
                    .padding(.horizontal)
                    
                    if let notlar = kayit.notlar {
                        GlassCard(cornerRadius: 16, padding: 16) {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Görüşme Notları")
                                    .font(.system(size: 13, weight: .bold))
                                    .foregroundColor(AppTheme.textSecondary)
                                Text(notlar)
                                    .font(.system(size: 14))
                                    .foregroundColor(AppTheme.textPrimary)
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        .padding(.horizontal)
                    }
                }
                .padding(.top, 12)
            }
        }
        .navigationTitle("Görüşme Detayı")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct YeniGorusmeFormView: View {
    @Environment(\.dismiss) private var dismiss
    public var onSave: (MusteriTakipKayit) -> Void
    
    @State private var cariUnvan: String = ""
    @State private var gorusmeTuru: String = "ZIYARET"
    @State private var konu: String = ""
    @State private var notlar: String = ""
    @State private var sonrakiEylem: String = ""
    
    var body: some View {
        NavigationStack {
            ZStack {
                AppTheme.background.ignoresSafeArea()
                
                VStack(spacing: 16) {
                    GlassCard(cornerRadius: 16, padding: 18) {
                        VStack(spacing: 14) {
                            FormField(label: "Müşteri / Cari Unvanı *", text: $cariUnvan, placeholder: "Cari adı")
                            
                            Picker("Görüşme Türü", selection: $gorusmeTuru) {
                                Text("Ziyaret").tag("ZIYARET")
                                Text("Telefon").tag("TELEFON")
                                Text("Online").tag("ONLINE")
                            }
                            .pickerStyle(.segmented)
                            
                            FormField(label: "Görüşme Konusu *", text: $konu, placeholder: "Örn: Sözleşme Yenileme")
                            FormField(label: "Görüşme Notları", text: $notlar, placeholder: "Konuşulan maddeler...")
                            FormField(label: "Sonraki Aksiyon", text: $sonrakiEylem, placeholder: "Örn: Teklif İletilecek")
                        }
                    }
                    
                    ActionButton(title: "Kaydet", icon: "checkmark.circle.fill", color: AppTheme.primary) {
                        let k = MusteriTakipKayit(
                            id: UUID().uuidString,
                            cariUnvan: cariUnvan,
                            gorusmeTarihi: AppFormatters.isoDate.string(from: Date()),
                            gorusmeTuru: gorusmeTuru,
                            konu: konu,
                            notlar: notlar,
                            sonrakiEylem: sonrakiEylem,
                            sonrakiEylemTarihi: AppFormatters.isoDate.string(from: Calendar.current.date(byAdding: .day, value: 3, to: Date()) ?? Date()),
                            durum: "TAMAMLANDI"
                        )
                        onSave(k)
                        dismiss()
                    }
                    
                    Spacer()
                }
                .padding()
            }
            .navigationTitle("Yeni Görüşme Kaydı")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("İptal") { dismiss() }
                        .foregroundColor(AppTheme.textSecondary)
                }
            }
        }
    }
}

