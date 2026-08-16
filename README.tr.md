<p align="center">
  <a href="README.md"><kbd>🇬🇧 English</kbd></a> ·
  <kbd>🇹🇷 <b>Türkçe</b></kbd>
</p>

# ADHD CBT — 12 Haftalık Rehberli Program

> Yetişkin DEHB için sakin, bilime dayalı 12 haftalık CBT (bilişsel davranışçı terapi) tabanlı kendi kendine yardım programı.
> **Streak yok. Suçluluk yok. Yargı yok.** Program sizi cezalandıramaz — tasarım gereği böyle.

Yetişkin DEHB için kanıta dayalı CBT teknikleri üzerine kurulu (organizasyon becerileri, dikkat çalışması, bilişsel yeniden yapılandırma, nüks önleme), **sürümlenmiş içerik** olarak dağıtılan, **saf Dart program motoru** tarafından çalıştırılan ve bilinçli olarak *anti-engagement* (katılım tuzağı karşıtı) bir UX ile çevrelenmiş, önce-yerel (local-first) bir mobil program.

**İngilizce + Türkçe. 13 oturum. 8 klinik form. 145 test. Sıfır oyunlaştırma.**

---

## Bu uygulama neden var

Çoğu alışkanlık uygulaması bırakacağınızı varsayar — bu yüzden oyunlaştırırlar: streak'ler, rozetler, baskı.
Ama DEHB için **baskı sorunun kendisidir, çözüm değil**. Yıllarca süren zorlanma insana başarısızlık beklemeyi öğretir; kaçırılan haftayı cezalandıran uygulamalar da o döngüyü besler.

Bu program diğer yönde çalışır:

- **Bir hafta kaçırdınız mı?** *"Bir oturumu kaçırmak sürecin parçasıdır, sürecin başarısızlığı değil"* cümlesiyle karşılaşırsınız.
- **Bir egzersizi atladınız mı?** Atlanmış kalır — kırmızı rozet yok, "GERİDE KALIYORSUNUZ" yok.
- **Ortasında dikkatiniz mi dağıldı?** Zamanlayıcı dikkat dağıtan şeyi savaşmak yerine park eder.
- **Formu yarıda mı bıraktınız?** Yazdığınız an kaydedilir — geri gel, yeniden aç, devam et.

Her ekran, her metin, her durum makinesi tek bir değişmez etrafında kuruldu:
**kullanıcı asla cezalandırılmaz.**

## İçinde ne var

| Katman | Ne yapar |
|---|---|
| **12 haftalık müfredat** | 6 modül — psikoeğitim, organizasyon ve planlama, dikkat dağınıklığı, uyumlu düşünme, erteleme, nüks önleme. Her oturum: ritüel kontrol → beceri okuması → egzersiz → ev pratiği → haftayı öngör. |
| **8 klinik form** | Haftalık belirti kontrolü (18 madde), ilaç uyumu, dikkat ölçer, Düşünce Kaydı, 6 adımlı problem çözme, artılar/eksiler, modül değerlendirmesi, strateji derecelendirmesi. |
| **Program motoru** | Saf Dart durum makinesi: tamamlandı / devam ediyor / atlandı / sıradaki aday. Tarih mantığı yok, takvim cezası yok. |
| **Form motoru** | Şema güdümlü renderer — **yeni form veridir, kod değil**. Alan ekle, göç et, yayınla. |
| **Canlı OTA** | sha256 manifest'li sürümlenmiş içerik paketleri, aşamalı atomik aktivasyon, her arızada otomatik geri alma. |
| **Senkron + hak sahipliği** | Opsiyonel FastAPI backend: kullanıcı başına şifreli bearer kimlik doğrulama (PBKDF2-HMAC-SHA256), idempotent senkron, 3 günlük ödemesiz dönemli makbuz doğrulama. |
| **Yerelleştirme** | Tam EN/TR içerik — 13 oturum ve 8 form çevrildi, zarif fallback'li yerel ayar duyarlı render. |

## Mimari

```
content/            sürümlenmiş, doğrulanmış JSON (tek doğruluk kaynağı)
   └─ tools/        validate.py + build.py → sha256 manifest paketi
        │
        ├─▶ app/    Flutter (önce-yerel, Drift/SQLite)
        │             ProgramMotoru → Oturumlar → Formlar → Drift
        │             Assets paketi → OTA farkı → atomik yayına alma
        │
        └─▶ backend/ FastAPI (opsiyonel hesap katmanı)
                      kimlik · senkron · içerik API · fatura/hak sahipliği
```

**İçerik-veri-olarak (content-as-data) temel bahistir:** oturumlar, formlar ve klinik metinler
şema ve hermetic test'leri olan JSON yapıtlarıdır — Flutter kodu değil. Tıbbi içerik ve onu
çalıştıran uygulama bağımsız evrilir.

## Teknoloji yığını

| Parça | Seçim |
|---|---|
| Uygulama | Flutter 3.44 / Dart 3.12 — **saf Dart motor** (mantık katmanlarında sıfır Flutter import'u) |
| Yerel depo | Drift/SQLite, şema sürümlü göçler |
| Backend | FastAPI + SQLite, yalnızca standart kütüphane şifreleme (PBKDF2-HMAC-SHA256, 240 bin iterasyon) |
| İçerik | JSON Schema (draft 2020-12) + özel doğrulayıcı + deterministik derleyici |
| Tasarım | Refactoring-UI temelli token sistemi — `AppTheme` tek kanonik kaynaktır; başıboş değerler review engelleyen kusurdur |

## Başlarken

```bash
# İçerik hattı (doğrula + test + paket derle)
cd content
./.venv/Scripts/python.exe -m pytest tests -q
./.venv/Scripts/python.exe -m tools.validate
./.venv/Scripts/python.exe -m tools.build          # → build/ (sha256 manifest)

# Backend
cd backend
.venv/Scripts/python.exe -m pytest tests/ -q
.venv/Scripts/python.exe -m uvicorn app.main:create_app --factory --port 8123

# Flutter uygulaması
cd app
flutter test --no-pub
flutter run
```

## Testler

**145 test, hermetic ve deterministik** — içerik (21), backend (29), uygulama (95):

- şema doğrulama, formRef/ISO-tarih/tekrar invariant'ları, paket determinizmi
- kimlik doğrulama numaralama direnci, kullanıcı başına senkron izolasyonu, hak sahipliği kapısı
- motor durum makinesi kabul testleri, atomik OTA geri alma, çökme-güvenli zamanlayıcı kurtarma
- kural olarak test'lenen UX: draft kalıcılık yarış korumaları, durum anlık görüntüsü değişmezliği, metin standartları

## Yol haritası

| Aşama | Tag | Teslim |
|---|---|---|
| M0 — İçerik hattı | `v0.1.0-content` | şemalar, doğrulayıcı, derleyici, 13 oturum, 8 form |
| M1 — Backend | `v0.1.0-backend` | kimlik, senkron, içerik API, fatura/hak sahipliği |
| M2 — Uygulama çekirdeği | `v0.1.0-app` | program motoru, içerik çalışma zamanı, atomik yayına alma, kayıt |
| M3 — Formlar + araçlar | `v0.1.0-m3` | form motoru, görev listesi, zamanlayıcı, problem çözme, Drift |
| M4 — Ritüel + grafikler | `v0.1.0-m4` | haftalık ritüel, Düşünce Kaydı, belirti grafikleri |
| M5 — Canlı OTA + push | `v0.1.0-m5` | OTA istemcisi, bildirimler, hak kapısı, tutma (retention) |
| M6 — Ayarlar + TR | `v0.1.0-m6`, `v0.1.0-tr` | hesap silme, kriz banner'ı, tam TR yerelleştirme |

*Sırada:* mağaza başvurusu (dış kimlik bilgileri), UI tasarım sistemi konsolidasyonu, reviewer kapılı sağlamlaştırma.

## Sorumluluk reddi

Bu, **tıbbi tavsiye, tanı veya terapi DEĞİL; bir kendi kendine yardım destek aracıdır.**
Program kanıta dayalı yetişkin DEHB CBT'nin yapısını izler; bir klinisyenin yerini tutmaz.
Krizdeyseniz yerel acil servislere veya ruh sağlığı hattına ulaşın (ABD: **988**).

---

*Bilinçli kuruldu: sakin renkler, ekran başına tek birincil eylem ve sizden neden ayrıldığınızı
asla sorgulamayan bir tamamlama kartı — "Harika, bir sonraki oturuma dön."*
