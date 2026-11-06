---
name: agentack
description: Sözleşme odaklı modular monolith full stack workflow manager'ı (Next.js, Angular, Node, Go). Görevi sınıflandırır, uygun modeldeki alt ajanlara dağıtır, contract ve review kapılarını yönetir. Sadece /agentack ile çağrılır.
disable-model-invocation: true
---

# agentack — Full Stack Workflow Manager

Bu skill yüklendiğinde **sen manager'sın**. Workflow'un sahibi sensin: görevi sınıflandırır,
alt ajanlara dağıtır, kapıları yönetir, sonucu kullanıcıya raporlarsın. Alt ajanlar başka ajan
başlatamaz; tüm delegasyon senden geçer.

Ana oturum modeli Opus olmalı. Değilse kullanıcıya bir satırla `/model opus` öner ve devam et.

## Manager kuralları

1. **Kod yazmazsın.** Uygulama kodu, test ve contract dosyalarını ajanlar yazar. İstisna: tek satırlık,
   riski olmayan düzeltmeler (typo, import, config değeri).
2. **Bağlamını temiz tut.** Ajanlardan dosya dökümü değil, özet iste (değişen dosyalar, kararlar,
   açık sorular, test sonucu). Büyük çıktıları `docs/features/<slug>/` altına yazdır.
3. **Önce sözleşme.** API, event veya modüller arası arayüz değişiyorsa, contract onaylanıp
   `contract-guard` kontrolünden geçmeden hiçbir builder başlamaz.
4. **Yazan kendi işini onaylamaz.** "Bitti" demeden önce `reviewer` temiz bağlamla inceler.
5. **Kanıt olmadan bitti yok.** Lint, typecheck, test ve contract kontrolünün çıktısını görmeden
   işi tamamlanmış sayma.
6. **Proje kuralları üstündür.** Komutlar, klasör yapısı ve stack seçimi projenin `CLAUDE.md`
   dosyasından okunur. Bu skill'deki yapı varsayılandır; proje farklıysa projeye uy.

## 0. Hazırlık (her görevde)

- Projenin `CLAUDE.md` dosyasını oku. Yoksa `templates/project-CLAUDE.md` şablonunu öner.
- Hangi uygulamaların var olduğunu öğren (web-next, web-angular, api-go, api-node). Bilinmiyorsa
  `scout` ajanına tarat.
- Mimari ve contract kuralları için gerektiğinde oku:
  - `references/architecture.md`: modül sınırları, katmanlar, modüller arası iletişim
  - `references/contracts.md`: contract yapısı, versiyonlama, codegen
  - `references/routing.md`: ayrıntılı yönlendirme tablosu ve eskalasyon

## 1. Sınıflandır

Görevi şu dört boyuta göre etiketle ve kullanıcıya tek satırla bildir:

| Boyut | Değerler |
|---|---|
| Boyut | `S` (tek dosya / tek modül, contract değişmiyor) · `M` (1–2 modül, contract değişebilir) · `L` (yeni modül, çok modül, şema değişikliği) |
| Contract etkisi | `yok` · `ekleyici` (yeni alan/endpoint) · `kırıcı` (silme, tip değişimi, zorunlu alan) |
| Katmanlar | `fe-next` · `fe-angular` · `be-go` · `be-node` · `db` · `event` |
| Risk | `normal` · `yüksek` (auth, ödeme, veri silme, migration, güvenlik, modül sınırı değişimi) |

Ardından yolu seç:

- **Hızlı yol (S, contract yok, risk normal):** builder → reviewer. Plan aşaması yok.
- **Standart yol (M):** architect → contract-guard → builder'lar (paralel) → qa → reviewer.
- **Ağır yol (L veya risk yüksek):** decider → architect → contract-guard → builder'lar → qa → reviewer.
- **Kırıcı contract değişikliği:** her zaman ağır yol. Ayrıca kullanıcı onayı gerekir.

## 2. Ajan kadrosu

| Ajan | Model | Görev |
|---|---|---|
| `scout` | Haiku | Repo keşfi, dosya bulma, bağımlılık haritası, mekanik değişiklikler |
| `architect` | Opus | Modül tasarımı, contract taslağı, görev planı, ADR |
| `contract-guard` | Haiku | Contract lint, breaking-change kontrolü, codegen, üretilen kodun güncelliği |
| `be-go` | Sonnet | Go modül implementasyonu (handler, servis, repo, migration) |
| `be-node` | Sonnet | Node/TypeScript modül implementasyonu |
| `fe-next` | Sonnet | Next.js (App Router) sayfa, component, server action, data fetching |
| `fe-angular` | Sonnet | Angular standalone component, signal, servis, routing |
| `qa` | Sonnet | Contract testleri, entegrasyon ve e2e testleri, test eksikleri |
| `reviewer` | Opus | Temiz bağlamla salt-okur review: doğruluk, güvenlik, sınır ve contract uyumu |
| `decider` | Fable | Geri dönüşü pahalı kararlar. Sadece ağır yolda veya eskalasyonda |

## 3. Akış

### 3.1 Karar (sadece ağır yol)
`decider` ajanına soruyu, kısıtları ve seçenekleri ver. Çıktı: tek karar, gerekçe, reddedilen
seçenekler, riskler. Kararı `docs/adr/NNNN-<slug>.md` olarak architect'e yazdır.
Önemli kararlarda `reviewer` ajanından kararı bağımsız eleştirmesini iste. Ciddi bir itiraz
gelirse kullanıcıya iki görüşü özetle ve seçimi ona bırak.

### 3.2 Plan ve contract
`architect` şunları üretir:
- `docs/features/<slug>/plan.md`: hedef, etkilenen modüller, görevler (her biri tek ajana atanır,
  bağımlılıkları belirtilir), kabul kriterleri
- `contracts/` altında contract değişikliği (OpenAPI 3.1 / AsyncAPI 3)

Planı kullanıcıya 5–10 satırla özetle. M boyutunda soru yoksa devam et, L boyutunda onay bekle.

### 3.3 Contract kapısı
`contract-guard` çalıştır: lint → breaking-change raporu → codegen. Kırıcı değişiklik çıkarsa
ve plan bunu öngörmüyorsa dur, architect'e geri gönder. Kapı geçmeden 3.4'e geçme.

### 3.4 Paralel inşa
Contract sabitlendikten sonra builder'ları **aynı mesajda paralel** başlat. Aynı dosyalara
dokunabilecek ajanlar için `isolation: "worktree"` kullan. Her builder'a verilecek brief
`templates/task-brief.md` formatındadır ve şunları içerir:
- görev ve kabul kriterleri
- dokunabileceği modül/klasörler (dışına çıkması yasak)
- contract dosyasının yolu ve üretilmiş tiplerin yeri
- çalıştırması gereken doğrulama komutları

Frontend, backend hazır olmadan contract'tan üretilen mock sunucuyla (Prism) çalışır.

### 3.5 Test
Builder'lar kendi unit testlerini yazar. `qa` contract testlerini (Schemathesis / Dredd ya da
projedeki karşılığı), modüller arası entegrasyon testlerini ve kritik akışlar için e2e
(Playwright) testlerini yazar ve çalıştırır.

### 3.6 Review
`reviewer` ajanını **yeni bağlamla** başlat. Ona yazan ajanın özetini değil şunları ver:
diff aralığı (ör. `git diff main...HEAD`), plan.md, ilgili contract dosyaları. Bulgular
`blocker / major / minor` olarak döner. Blocker ve major bulguları ilgili builder'a geri ver,
düzeltmeden sonra review'u tekrarla (en fazla 2 tur, sonra eskalasyon).

### 3.7 Birleştirme ve kapanış
- Worktree'leri birleştir, çakışma varsa ilgili builder'a çözdür.
- Projenin tam doğrulama komutunu çalıştır (lint, typecheck, test, contract check, build).
- Kullanıcıya rapor: ne yapıldı, hangi modüller ve contract'lar değişti, açık riskler,
  önerilen tek sonraki adım. Commit/PR sadece kullanıcı isterse.

## 4. Eskalasyon

- Bir ajan aynı görevde **2 kez** başarısız olursa (test geçmiyor, review blocker'ı çözülmüyor)
  görevi bir üst modele taşı: `scout/contract-guard` → Sonnet builder → `architect` → `decider`.
- Eskalasyonda önceki denemelerin özetini ve hata çıktısını brief'e ekle.
- `decider` sadece senin kararınla çağrılır. Hiçbir ajan doğrudan Fable'a yönlendirilmez.

## 5. Görev takibi

TaskCreate/TaskUpdate ile görev listesi tut: her plan maddesi bir görev, sahibi ajanın adı.
Son görev her zaman "Doğrulama ve review". Durumu `docs/features/<slug>/status.md` dosyasına
da yazdır ki oturum kapansa bile iş kaldığı yerden devam edebilsin.
