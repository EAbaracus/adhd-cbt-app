# Adult ADHD Self-Help App — Market Research Report

> Date: 2026-08-15 · Status: DRAFT (Task 0 deliverable, awaiting user review gate)
> Method: 3 parallel researcher workstreams (deleg_412ae8ec, ~36 min) + orchestrator consolidation. Every claim sourced; unverifiable numbers marked UNVERIFIED. Sources: official sites, App Store/Google Play pages, clinician-curated lists (ADDA, ADDitude, ChoosingTherapy), peer-reviewed literature (PMC12436941), regulatory anchors (Apple Review Guidelines, FTC).
> Language: TR with EN technical terms (user preference).

## 1. Özet — Yönetici Bulguları

1. **Kategori boşluğu doğrulandı (3 bağımsız kaynak):** ADDA, ADDitude ve ChoosingTherapy'nin küratörlü "best ADHD/CBT apps" listelerinin **hiçbirinde rehberli (guided), program-bütünlüklü ADHD-CBT uygulaması yok.** Liste hâkimiyeti toolbox'ta (timer, task manager, alarm, not, email). Kategori farkındalığı sıfırdan yaratılmalı — bu hem fırsat (whitespace) hem dağıtım zorluğu.
2. **Anker rakip: Inflow** — 12-hafta, ADHD-spesifik CBT, günlük 5-dk alışkanlık + kütüphane-kilidi (4 modül önce tamamla) + canlı body-doubling topluluğu + AI Quinn 24/7. Fiyat $22.49–47.99/ay, $95.99–199.99/yıl. Streak mekanizması kanıtlanamadı → UNVERIFIED.
3. **Bizim kilit farklarımız pazarda eşsiz:** tamamlama-bazlı progresyon (G2 — rakipler takvim/gate-bazlı) ve anti-engagement UX (I1 — rakipler streak/puan/ceza kullanıyor: Forest "ölü ağaç", RescueTime skor).
4. **Fiyat baskısı gerçek:** ücretsiz, kanıta-dayalı generic CBT kümesi var (MindShift, FreeCBT, MoodTools, CBT-i Coach) — hiçbiri ADHD-spesifik değil. Abonelik, "temel CBT aracı" ile değil **yapı (12-hafta program) + ADHD entegrasyonu** ile meşrulaşmalı.
5. **Risk yoğunluğu yüksek:** klinik-iddia/store-listing (Apple §1.4.1), churn (sağlık app'lerinde 90 günde %46.8 paid churn), kriz güvenliği (988 yönlendirme zorunlu), sağlık-verisi gizliliği (FTC BetterHelp $7.8M emsal).

## 2. Rekabet Haritası

### Katman 1 — ADHD-spesifik program/koçluk (doğrudan rakipler)

| App | Model | Fiyat | Rating | Program |
|---|---|---|---|---|
| **Inflow** | guided_program | 7-gün trial; $22.49–47.99/ay (koçsuz/koçlu); $95.99–199.99/yıl | 4.4 App Store / 3.9 Play | 12-hafta CBT; 4 modül (Anxiety, Procrastination, Impulsivity, Avoidance); günlük 5-dk alışkanlık; kütüphane-kilidi + 4-modül gate; canlı body-doubling + AI Quinn 24/7 (apps.apple.com/inflow; getinflow.io/faqs) |
| **Shimmer** | coach | $139.99–344.99/ay (15/30/45-dk haftalık 1:1 video); trial yok, ilk ay %25 indirim | 4.7 App Store / 4.3 Play | 12-hafta yapılandırılmış koçluk; ACT + pozitif psikoloji; hedef-bazlı, esnek süre (apps.apple.com/shimmer-care; techcrunch.com) |
| **Done** | coach | $199 ilk ay → $79/ay (değerlendirme + ilaç + koçluk) | UNVERIFIED (post-assessment kapalı) | 12-hafta: assessment, medikasyon, CBT-koçluk, progres takibi |
| **EndeavorOTC** | guided_program (FDA 510(k)) | $24.99/ay, $129.99/yıl; trial yok; "6 hafta 50+ dk/hafta yapmazsan para iadesi" | — | FDA temizlenmiş DTx; çocuk/genç oyun terapisi (endeavorotc.com/faq) |

### Katman 2 — Generic CBT / mental health (dolaylı + fiyat ankoru)

| App | Fiyat | Not |
|---|---|---|
| MindDoc | free–$34.99/yıl | En iyi genel (ChoosingTherapy); "aylık ödeme yok" CON |
| MindShift CBT | **free** | Anksiyete; "text-heavy" eleştirisi |
| MoodTools | free–$4.99/yıl | Depresyon; premium sadece renk değiştirir |
| CBT-i Coach | **free** (VA) | İnsomnia |
| FreeCBT | **open-source free** | Üç-sütun thought record (bizim TR tasarımımızın dış doğrulaması) |
| Clarity | $59.99–69.99/yıl | Guided CBT journal (TR UX referansı) |
| Youper | $69.99/yıl, free yok | AI chatbot CBT (AI hook referansı); "free tier yok" CON |
| Happify | free–$14.99/yıl | Oyunlaştırma; premium trial yok |
| Wysa / Woebot | freemium | AI chatbot CBT; Wysa 4.8 iOS 24K |
| Sanvello | $8.99/ay, $53.99/yıl | Guided Journeys (evidence-based CBT programlar) |
| Online-Therapy.com | $240–480/ay | Terapi + yapılandırılmış kurs (web-only) |

### Katman 3 — Toolbox/utility (küratör listeleri; ADDA + ADDitude, ~40 araç)

Focusmate ($8/ay body doubling) · Forest ($3.99 tek seferlik, "ölü ağaç" ceza streak) · Focus Keeper · RescueTime (skor) · Focus@Will · Freedom · Goblin Tools Magic ToDo (free/$3) · Todoist (free/$3-5/ay) · Due ($10/ay) · Tiimo ($5.99/ay, $44.99/yıl) · Sunsama ($25/ay) · Remember the Milk · Evernote · SimpleMind · Brili · + alarm/uyku/not/email araçları. **Hiçbirinin sabit müfredatlı CBT program yapısı yok.**

## 3. Inflow — Anker Rakip Derin Analizi

| Boyut | Inflow | Bizim tasarım |
|---|---|---|
| Program | 12 hafta, modüller; **günlük 5-dk alışkanlık**; trial'da kütüphane kilidi + 4-modül gate (store yorumları, teyitli) | 12 hafta, oturum-bazlı (haftalık ritüel + okuma + egzersiz + ödev); G2 tamamlama-bazlı, gate/kilit yok, kaçırma = normal akış |
| İçerik | Lisanslı CBT, klinisyen-geliştirilmiş; kullanıcı şikayeti: **tekrarlayıcı içerik, progres takibi zor** (ChoosingTherapy review) | Safren protokolüne bağlı şema-tanımlı forms-as-data motor (fidelity odaklı) |
| Retention | Body-doubling topluluğu + AI Quinn 24/7 + günlük alışkanlık; streak **UNVERIFIED** | I1: streak/puan/ceza yok; sakin ilerleme grafikleri |
| UX | Temiz, minimal, rau tonlar; hafif onboarding (3-dk test → kişiselleştirilmiş plan) | I1 aynı yönde: anti-engagement; onboarding psikoeğitim-odaklı |
| Fiyat | $22.49–47.99/ay, $95.99–199.99/yıl | Önerilen: $8.99/ay, $69.99/yıl (aşağıda) |
| Veri | Play Store data-safety: **6+ veri tipi üçüncü tarafla paylaşılabiliyor** (play.google.com/inflow) | Zorunlu hesap ama snapshot-restore; "sağlık verisi reklam için asla paylaşılmaz" taahhüdü (FTC emsali) |

## 4. Fiyat Benchmark

| Band | Örnekler |
|---|---|
| Terapi-ankor | BetterHelp $260–400/ay · Talkspace $276–436/ay · Online-Therapy $240–480/ay · Shimmer $139.99–344.99/ay |
| ADHD program | Inflow $22.49–47.99/ay ($95.99–199.99/yıl) · EndeavorOTC $24.99/ay ($129.99/yıl) |
| Genel mental-health (annual-dominant) | Headspace $12.99/ay/$69.99/yıl · Calm $14.99/ay/$69.99/yıl · Sanvello $8.99/ay/$53.99/yıl · MindDoc $34.99/yıl · Youper $69.99/yıl · Clarity $59.99–69.99/yıl |
| Ücretsiz/kanıta-dayalı | MindShift, FreeCBT, CBT-i Coach, MoodTools (hiçbiri ADHD-spesifik değil) |

**Sinyal:** "aylık ödeme yok" ve "free tier yok" açıkça CON olarak raporlanıyor (MindDoc, Youper) → **monthly + yearly + trial bizim seçimimizi dışarıdan doğruluyor.**

## 5. Pazar Boşlukları

1. **Program fidelity boşluğu** — PMC12436941: dijital CBT ADHD'de orta-kesinlilik iyileşme; protokol-bağlılık (fidelity) ve kişiselleştirme eksik. Protokol-complete (Safren'e bağlı, şema-tanımlı) rehber program pazarda yok — Inflow/Wysa mikro-öğretici/kütüphane modeli.
2. **Dağıtım/küratörlük boşluğu** — 3 otorite listesinde sıfır guided program; kategori farkındalığı biz yaratmalıyız.
3. **Tamamlama-bazlı progresyon boşluğu** — Inflow (gate/kütüphane-kilidi + günlük 5-dk) ve EndeavorOTC (6-hafta 50+dk yoksa para iadesi) **takvim/gate-bazlı**; bizim G2 (kaçırma = normal akış) pazarda eşsiz.
4. **Anti-engagement/sakin UX boşluğu** — Forest ceza-streak, RescueTime skor; I1'i tasarımdan yaşatan ilk CBT rehber programı olma pozisyonu.

## 6. Farklılaşma Vektörleri

**BEATS (biz üstün):** program fidelity (şema-tanımlı forms-as-data × Safren protokolü) · progresyon modeli (G2) · anti-engagement UX (I1) · gizlilik (veri paylaşımı yok; Inflow 6+ tip paylaşıyor) · fiyat/değer (önerilen $8.99/ay bandı, Inflow'un yarısından az).
**LOSES (rakip üstün):** FDA temizliği (EndeavorOTC 510(k); biz "supportive tool" çerçevesindeyiz) · canlı topluluk + 24/7 AI (Inflow body-doubling + Quinn; bizim MVP'de yok — retention gap, I1+gizlilik stratejimizin doğal ticari kurbanı) · marka bilinirliği · ücretsiz generic CBT baskısı.

## 7. Riskler

1. **Klinik-iddia/store**: Apple §1.4.1 tıbbi app'lere ek inceleme; "tedavi/azaltır/teşhis" iddiası red → "12-haftalık rehber destek programı; tıbbi tavsiye değildir" çerçevesi zorunlu. FTC §5: tıbbi iddialar kanıtlanmalı.
2. **Churn**: Sahha.ai — sağlık app abonelerinin %46.8'i 90 günde churn; mental-health day-30 retention %4-12. Zorunlu hesap + abonelik + ücretsiz rakipler riski artırıyor.
3. **Kriz güvenliği**: MVP'de insan koç yok; krizdeki kullanıcı (suicide/self-harm) senaryosu → 988/klinisyen yönlendirme protokolü zorunlu.
4. **Veri gizliliği**: Apple §5.1.1 (hesap silme, retention), §5.1.3 (health data reklamda kullanılamaz); GDPR/CCPA right-to-deletion; BetterHelp FTC $7.8M emsali.
5. **FDA/DTx**: "treatment/therapy" iddiası → FDA Class II cihaz (EndeavorOTC emsali); supportive-self-help çerçevesi kaçınır ama App Store §1.4.1 yine de tetiklenir.

## 8. Öneriler (Task 0 gate — user onayı gerektirir)

1. **IMPLEMENT — Fiyat: $8.99/ay + $69.99/yıl + 7-gün trial.** Inflow'un yarısı, Headspace/Calm bandı; monthly+yearly+trial, pazardaki iki CON'u (no-monthly, no-free-tier) kapatır.
2. **IMPLEMENT — Store/listing çerçevesi:** "12-haftalık rehberli CBT destek programı; tıbbi tavsiye/teşhis değildir"; onboarding + footer'da 988/NATHELP yönlendirmesi; "insan koç değil, destekleyici rehber" konumu (Apple §1.4.1).
3. **IMPLEMENT — Hesap/gizlilik:** zorunlu hesap + veri minimizasyonu + in-app hesap silme (Apple §5.1.1); privacy policy'de "sağlık verisi üçüncü taraf reklam/ticari amaçla asla paylaşılmaz" taahhüdü; GDPR/CCPA right-to-deletion (FTC $7.8M emsali).
4. **IMPLEMENT — I1'i motor seviyesinde zorla:** kaçırılan hafta UI'si "Harika, bir sonraki oturuma dön" — asla streak/puan/sertifika; bu self-compassion farkı pazarlama diline döner.
5. **NOTE — Topluluk/AI koç MVP'de yok:** Inflow'un body-doubling + AI Quinn'i retention gap yaratır; retention metrikleri baştan ölçülmeli, v1.5 roadmap'te "isteğe bağlı" topluluk modu değerlendirilmeli.

## 9. Spec Amendment Adayları (kullanıcı onayıyla işlenecek)

- **A1** → spec §1 Revenue: fiyat ankoru $8.99/ay + $69.99/yıl + 7-gün trial (trial artık "implementation-time" değil, kararlaştırılmış).
- **A2** → spec §10.3 Medical framing: store/listing dili + 988 yönlendirme protokolü detayı.
- **A3** → spec §6/§7: hesap silme + "veri paylaşımı yok" taahhüdü + GDPR/CCPA (invariant'lara ek: "Kullanıcı verisi üçüncü taraf reklam/ticari amaçla paylaşılamaz").
- **A4** → spec §8: kaçırılan-hafta UI copy standardı + retention ölçüm metrikleri (M2/M3 plan detayı).
