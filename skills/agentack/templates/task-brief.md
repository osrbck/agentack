# Görev Brief'i

**Görev:** <tek cümle>
**Feature:** docs/features/<slug>/plan.md → Görev #<n>
**Ajan:** <be-go | be-node | fe-next | fe-angular | qa | scout>

## Kapsam
- Dokunabileceğin yerler: `<yol>`, `<yol>`
- Dokunamayacağın yerler: diğer modüller, `contracts/` (değişiklik gerekiyorsa DUR ve raporla), üretilmiş kod

## Contract
- `contracts/<module>/openapi.yaml` → operationId: `<...>`
- Üretilmiş tipler: `<yol>`

## Kabul kriterleri
- [ ] <davranış 1>
- [ ] <davranış 2>
- [ ] Unit testler yazıldı ve geçiyor

## Doğrulama komutları
```
<lint komutu>
<typecheck komutu>
<test komutu>
```

## Önceki denemeler (eskalasyonda doldurulur)
<özet + hata çıktısı>

## Dönüş formatı
1. Değişen dosyalar (yol + bir satırlık açıklama)
2. Doğrulama komutlarının sonucu (geçti / kaldı + ilgili satırlar)
3. Verdiğin kararlar ve varsayımlar
4. Açık sorular veya contract'ta gördüğün sorunlar
