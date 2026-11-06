# Feature: <Başlık>

**Slug:** <slug> · **Boyut:** S/M/L · **Contract etkisi:** yok/ekleyici/kırıcı · **Risk:** normal/yüksek

## Hedef
<Kullanıcı açısından ne değişecek, 2–3 cümle>

## Etkilenen modüller
| Modül | Değişiklik | Contract |
|---|---|---|

## Contract değişiklikleri
- `contracts/<module>/openapi.yaml`: <ekle/değiştir>
- `contracts/<module>/events.asyncapi.yaml`: <...>

## Görevler
| # | Görev | Ajan | Bağımlı | Dokunacağı yerler |
|---|---|---|---|---|
| 1 | Contract taslağı | architect | — | contracts/<module> |
| 2 | Contract kontrol + codegen | contract-guard | 1 | packages/api-client, gen/ |
| 3 | ... | be-go | 2 | apps/api-go/internal/modules/<module> |
| 4 | ... | fe-next | 2 | apps/web-next/... |
| 5 | Contract + entegrasyon testleri | qa | 3,4 | tests/ |
| 6 | Review | reviewer | 5 | — |

## Kabul kriterleri
- [ ]

## Riskler ve açık sorular
-
