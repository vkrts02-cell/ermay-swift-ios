# Ermay Muhasebe - Native Swift / SwiftUI Mobil Uygulaması

Bu proje, **Ermay Muhasebe** ekosisteminin mobil uygulamasının (`ermaymuhasebe-mobil`) **Apple iOS & macOS** platformları için modern **Swift 5.9+ ve SwiftUI** kullanılarak geliştirilmiş birebir native kopyasıdır.

Masaüstü ve web versiyonları ile birebir aynı iş mantığı, Supabase bulut mimarisi ve veri yapılarını paylaşır.

---

## 🚀 Mimari & Teknolojiler

- **Kullanıcı Arayüzü:** Modern Declarative SwiftUI (iOS 16+ & macOS 13+ Destekli).
- **Tasarım Dili:** Apple Human Interface Guidelines uyumlu, Koyu OLED (#000000) zemin, cam (Liquid Glass/Blur) efektleri ve elektrik mavisi / yeşil aksanlar.
- **Backend Entegrasyonu:** Supabase PostgreSQL REST API (PostgREST v1) & Supabase Auth.
- **Eşzamanlılık (Concurrency):** Modern Swift Concurrency (`async` / `await` / `@MainActor`).
- **Veri Güvenliği:** Apple `LocalAuthentication` ile Face ID / Touch ID biyometrik doğrulama ve 4 haneli PIN kilit mekanizması.
- **Çevrimdışı Çalışma (Offline Queue):** Ağ bağlantısı kesildiğinde yapılan işlemleri sıraya alan ve bağlantı geldiğinde otomatik eşitleyen kuyruk mimarisi.
- **Native PDF & Paylaşım:** `PDFKit` ve CoreGraphics ile profesyonel e-Fatura, teklif, sipariş ve hesap ekstresi PDF çıktısı oluşturma, AirPrint ve WhatsApp / iOS Paylaşım Sayfası (UIActivityViewController) entegrasyonu.

---

## 📂 Proje Dizin Yapısı

```
E:\avalonia yedek\swiftapp\
├── Package.swift                    # Swift Package Manager manifestosu
├── README.md                        # Proje kullanım ve mimari dokümantasyonu
├── Sources\ErmayMobil\
│   ├── App\
│   │   ├── ErmayApp.swift           # @main SwiftUI uygulama giriş noktası
│   │   └── RootView.swift           # Auth / Lock / Main geçiş yönlendiricisi
│   ├── Models\                      # Masaüstü C# ve Supabase tabloları ile birebir uyumlu
│   │   ├── Cari.swift               # CariKart, CariHareket
│   │   ├── Stok.swift               # StokKart, StokHareket, StokGrup
│   │   ├── Fatura.swift             # Fatura, FaturaKalem, KDV & İskonto
│   │   ├── Siparis.swift            # Siparis, SiparisKalem
│   │   ├── Teklif.swift             # Teklif, TeklifKalem
│   │   ├── Finans.swift             # KasaBanka, KasaHareket
│   │   ├── CekSenet.swift           # Çek & Senet, portföy ve tahsilat durumları
│   │   ├── Banka.swift              # BankaKart, BankaHareket, EftIslem
│   │   ├── MusteriLimit.swift       # Kredi limiti ve risk analiz modeli
│   │   ├── Doviz.swift              # Canlı TCMB döviz kurları
│   │   ├── Vade.swift               # VadeItem, gecikme gün hesabı
│   │   ├── MusteriTakip.swift       # CRM & Müşteri Görüşme kayıtları
│   │   ├── Kanban.swift             # Görevler (Yapılacak, Devam Eden, Tamamlandı)
│   │   └── User.swift               # Kullanıcı ve Firma Profili
│   ├── Services\
│   │   ├── SupabaseService.swift    # URLSession tabanlı PostgREST ve ham payload istemcisi
│   │   ├── AuthService.swift        # Kullanıcı girişi, session ve tenant yönetimi
│   │   ├── BiometricLockService.swift # Face ID / Touch ID / PIN güvenliği
│   │   ├── OfflineQueueService.swift# Çevrimdışı INSERT, UPDATE, DELETE kuyruğu ve senkronizasyon
│   │   └── PDFService.swift         # e-Fatura & Rapor PDF motoru
│   ├── Theme\
│   │   ├── Colors.swift             # Apple Dark OLED paleti
│   │   └── Formatters.swift         # Türk Lirası (₺) ve tarih formatlayıcılar
│   ├── Components\
│   │   ├── GlassCard.swift          # Cam efektli kart bileşeni
│   │   ├── FloatingTabBar.swift     # Alt yüzen navigasyon dock'u
│   │   ├── BarcodeScannerView.swift # Native AVFoundation kamera barkod okuyucu
│   │   ├── StatCard.swift           # Metrik gösterge kartları
│   │   └── CommonComponents.swift   # Arama çubuğu, rozetler ve eylem butonları
│   └── Views\
│       ├── Auth\                    # Giriş ve Kilit Ekranları
│       ├── Navigation\              # TabBar ve Daha Fazla Yığını
│       ├── Dashboard\               # Ana Sayfa, 4'lü metrik, hedef & gerçekleşme grafiği
│       ├── Cariler\                 # Cari listesi, detay, WhatsApp, ekstre, form
│       ├── Faturalar\               # Fatura listesi, dinamik kalemli form, detay, PDF
│       ├── Stoklar\                 # Stok listesi, kritik stok uyarısı, kameralı hızlı sayım, grup
│       ├── CekSenet\                # Çek & Senet takibi, portföy/banka/tahsilat yönetimi
│       ├── Banka\                   # Banka hesapları, 1-tık IBAN kopyalama, Havale/EFT
│       ├── MusteriLimit\            # Müşteri kredi limiti aşımı ve risk skor kartları
│       ├── Doviz\                   # TCMB canlı kurlar ve interaktif döviz çevirici
│       ├── Siparisler\              # Alınan/verilen siparişler, faturaya dönüştürme
│       ├── Teklifler\               # Teklif hazırlama, onaylama, PDF paylaşma
│       ├── Finans\                  # Kasa/Banka bakiyeleri, tahsilat & tediye veritabanı kaydı
│       ├── VadeTakip\               # Vadesi geçen/yaklaşan borç ve alacak takvimi
│       ├── MusteriTakip\            # Müşteri ziyaret & CRM görüşmeleri
│       ├── Kanban\                  # İş & görev panosu
│       ├── Raporlar\                # Gelir-gider, KDV beyannamesi, envanter maliyeti
│       ├── Araclar\                 # KDV hesaplayıcı ve ürün maliyet simülatörü
│       └── Ayarlar\                 # Bulut bağlantısı, güvenlik ve şirket profili
└── Tests\
    └── ErmayMobilTests\             # Model serileştirme ve hesaplama birim testleri
```

---

## 🛠️ Xcode ile Çalıştırma & Geliştirme

1. Bir Mac bilgisayarda veya macOS sanal makinesinde bu klasörü açın:
   - Xcode uygulamasını açıp **File > Open** seçeneğiyle `E:\avalonia yedek\swiftapp` klasörünü veya doğrudan `Package.swift` dosyasını seçin.
2. Xcode, SPM (Swift Package Manager) bağımlılıklarını otomatik olarak çözümleyecek ve derlemeye hazır hale getirecektir.
3. Hedef cihaz olarak **iPhone 15 / 16 Pro** veya **Mac (Designed for iPad)** seçip **Cmd + R** ile projeyi çalıştırın.

