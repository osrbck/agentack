# Yönlendirme Tablosu

Somut tetikleyiciler. Birden fazla satır eşleşirse en ağır yolu seç.

| Tetikleyici | Yol | İlk ajan |
|---|---|---|
| "X nerede", "nasıl çalışıyor", bağımlılık sorusu | — | `scout` |
| Rename, format, lint düzeltme, import temizliği, boilerplate | Hızlı | `scout` |
| Contract'a dokunmayan UI değişikliği (stil, metin, component içi mantık) | Hızlı | `fe-next` / `fe-angular` |
| Net repro'su olan tek modül bug'ı | Hızlı | ilgili builder |
| Yeni endpoint veya mevcut endpoint'e opsiyonel alan | Standart | `architect` |
| Yeni ekran + yeni endpoint (uçtan uca feature) | Standart | `architect` |
| 2+ modülü etkileyen değişiklik | Standart | `architect` |
| 5'ten fazla dosyaya dokunan refactor | Standart | `architect` |
| Repro'su olmayan / aralıklı bug, performans sorunu | Standart | `architect` (teşhis), sonra builder |
| DB şema değişikliği, migration | Ağır | `decider` (veri kaybı riski varsa), yoksa `architect` |
| Yeni modül, modül bölme/birleştirme, sınır değişimi | Ağır | `decider` |
| Auth, yetkilendirme, ödeme, kişisel veri, şifreleme | Ağır | `decider` |
| Kırıcı contract değişikliği | Ağır + kullanıcı onayı | `decider` |
| Teknoloji/kütüphane seçimi (ORM, state yönetimi, queue) | Ağır | `decider` |

## Model maliyet notu

Haiku < Sonnet < Opus < Fable. Varsayılan builder Sonnet. Opus planlama ve review için,
Fable yalnızca geri dönüşü pahalı kararlar için. Ucuz modelin yapabileceği işi pahalıya verme;
ama iki başarısız denemeden sonra yükseltmekten de çekinme.

## Paralellik

- Contract sabit olduktan sonra frontend ve backend builder'ları paraleldir.
- Aynı modülün backend'ine iki builder aynı anda verilmez.
- `scout` keşfi ve `contract-guard` codegen'i sıralıdır (diğerlerini besler).
