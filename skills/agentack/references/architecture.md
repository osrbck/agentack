# Modular Monolith Kuralları

Tek deploy birimi, sert iç sınırlar. Her modül ileride ayrı servis olarak çıkarılabilecek
kadar bağımsız olmalı ama bugün ağ çağrısı maliyeti ödenmez.

## Temel ilkeler

1. **Modül = bounded context.** Teknik katmana göre değil iş yeteneğine göre bölünür
   (`billing`, `catalog`, `identity`), `services/`, `controllers/` gibi değil.
2. **Public yüzey dardır.** Her modül dışarıya yalnızca kendi `api` paketini/barrel'ını açar.
   Diğer modüllerin `domain`, `app`, `infra` katmanlarına import yasaktır.
3. **Veri sahipliği.** Her modül kendi şemasının/tablolarının sahibidir. Başka modülün
   tablosuna doğrudan sorgu, join veya foreign key yok. Gerekirse public API ya da event.
4. **Modüller arası iletişim.**
   - Senkron: diğer modülün public arayüzü üzerinden in-process çağrı.
   - Asenkron: domain event'leri, transactional outbox ile. Event şemaları `contracts/` altında.
   - Döngüsel bağımlılık yasak. Döngü çıkarsa event'e çevir veya sorumluluğu taşı.
5. **Paylaşılan kod minimum.** `shared/` sadece gerçekten jenerik şeyler içindir (logger,
   config, hata tipleri, para/tarih value object'leri). İş kuralı asla `shared/`'a girmez.
6. **Sınırlar araçla zorlanır.** Kural yazılı olarak değil, CI'da kırmızı olarak var olur.

## Önerilen repo yapısı (proje CLAUDE.md'si yoksa varsayılan)

```
contracts/
  shared/components.yaml        # Problem (RFC 9457), pagination, ortak şemalar
  <module>/openapi.yaml         # HTTP sözleşmesi
  <module>/events.asyncapi.yaml # yayınlanan event'ler
apps/
  api-go/
    cmd/server/main.go          # composition root: modülleri bağlar
    internal/modules/<module>/
      api/                      # public arayüz (interface + DTO). Diğer modüller sadece bunu import eder
      app/                      # use case'ler
      domain/                   # entity, value object, domain event, kurallar
      infra/                    # repo, http handler (üretilen stub'ı implemente eder), outbox
    internal/platform/          # db, logger, config, eventbus
  api-node/
    src/modules/<module>/
      index.ts                  # public barrel; dışarıya sadece bu
      application/ domain/ infrastructure/ http/
    src/platform/
  web-next/                     # App Router; feature klasörleri modül adlarını izler
  web-angular/                  # standalone; src/app/features/<module>/
packages/
  api-client/                   # contract'tan üretilen TS tipleri ve client (elle düzenlenmez)
docs/
  adr/                          # mimari kararlar
  features/<slug>/              # plan.md, status.md
```

## Stack bazlı zorlama

| Stack | Sınır kontrolü |
|---|---|
| Go | `internal/` görünürlüğü + `go-arch-lint` veya `depguard` (golangci-lint) ile `modules/X/{app,domain,infra}` → başka modülden import yasağı |
| Node | `dependency-cruiser` ya da `eslint-plugin-boundaries`; Nx kullanılıyorsa `@nx/enforce-module-boundaries` + tag'ler |
| Next.js | Feature klasörleri dışından iç dosya import'u yasak (eslint `no-restricted-imports`); API erişimi sadece `packages/api-client` üzerinden |
| Angular | Nx tag'leri veya `eslint-plugin-boundaries`; feature'lar arası import yok, ortak UI `shared/ui` |

## Katman kuralları

- `domain` hiçbir framework'e bağımlı değildir (Go: sadece stdlib; Node: Nest/Express import'u yok).
- `app` use case'leri `domain`'i ve port arayüzlerini kullanır; `infra` portları implemente eder.
- HTTP katmanı ince: doğrula (contract'tan üretilen tiplerle), use case'i çağır, cevabı eşle.
- Transaction sınırı use case'tedir; modül dışına transaction taşınmaz.

## Ne zaman yeni modül?

Ayrı dil (ubiquitous language), ayrı veri sahipliği ve ayrı değişim hızı varsa. Sadece
"dosya çok büyüdü" yeni modül gerekçesi değildir. Yeni modül her zaman ağır yoldan geçer (ADR).
