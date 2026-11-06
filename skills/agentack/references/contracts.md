# Contract Kuralları

Contract tek doğruluk kaynağıdır. Kod contract'tan üretilir, contract koddan değil.

## Formatlar

- **HTTP:** OpenAPI 3.1, modül başına `contracts/<module>/openapi.yaml`.
- **Event:** AsyncAPI 3, `contracts/<module>/events.asyncapi.yaml`. Payload şemaları JSON Schema.
- **Ortak:** `contracts/shared/components.yaml` (Problem Details hata modeli, cursor pagination,
  Money, timestamp formatı). Modüller `$ref` ile kullanır, kopyalamaz.

## Yazım kuralları

- `operationId` zorunlu ve benzersiz: `<module>.<verb><Noun>` (ör. `billing.createInvoice`).
- Hatalar `application/problem+json` (RFC 9457). Her endpoint 4xx/5xx yanıtlarını belirtir.
- Alanlar `camelCase`; ID'ler string (UUID/ULID); zaman `date-time` (UTC, RFC 3339).
- Her şemada `required` açıkça yazılır; `additionalProperties: false` istek gövdelerinde.
- Liste endpoint'leri cursor pagination kullanır (`limit`, `cursor`, `nextCursor`).
- Her alanın `description` ve gerekiyorsa `example` değeri vardır.
- Event adları geçmiş zaman: `invoice.paid`, `user.registered`; payload `eventId`,
  `occurredAt`, `version` içerir.

## Versiyonlama

- **Ekleyici değişiklik** (opsiyonel alan, yeni endpoint, yeni enum değeri istemcide toleranslıysa):
  aynı major versiyonda yapılabilir.
- **Kırıcı değişiklik** (alan silme/yeniden adlandırma, tip değişimi, opsiyonelin zorunlu olması,
  response şeklinin değişmesi): yeni versiyon (`/v2/...` veya yeni event `version`) + eskisi
  `deprecated: true` ile en az bir sürüm boyunca yaşar. Kullanıcı onayı şart.
- Breaking-change kontrolü `oasdiff breaking` ile ana dala karşı yapılır.

## Araç zinciri (proje CLAUDE.md'si farklısını söylemiyorsa)

| Adım | Araç |
|---|---|
| Lint | `@redocly/cli lint` veya `spectral lint` |
| Breaking change | `oasdiff breaking <base> <head>` |
| Mock sunucu | `@stoplight/prism-cli mock` |
| Go codegen | `oapi-codegen` (strict-server + types), çıktısı `infra/http/gen` altında |
| Node codegen | `openapi-typescript` (tipler) + istek doğrulama için `zod` şemaları (`openapi-zod-client` veya `orval`) |
| Next.js client | `orval` (fetch + React Query) veya `openapi-fetch`, çıktı `packages/api-client` |
| Angular client | `orval` angular hedefi veya `ng-openapi-gen`, çıktı `packages/api-client/angular` |
| Contract test | `schemathesis` (çalışan backend'e karşı) |

## Kurallar

- Üretilmiş kod elle düzenlenmez; başına "GENERATED - DO NOT EDIT" yazılır ve codegen
  komutu CI'da tekrar çalıştırılıp diff kontrol edilir.
- Contract değişikliği ve onu kullanan kod aynı PR'da olur, contract commit'i önce gelir.
- Backend handler'ı üretilen arayüzü implemente etmek zorundadır; derleyici/typecheck
  contract uyumsuzluğunu yakalamalıdır.
