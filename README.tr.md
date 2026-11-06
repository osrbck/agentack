# agentack — agentic stack

**[Claude Code](https://docs.claude.com/en/docs/claude-code) için, sözleşme odaklı modular monolith projelere yönelik, manager yönetiminde çok modelli ajan workflow'u.**

agentack, ana Claude Code oturumunu bir *manager*'a dönüştürür. Manager her görevi sınıflandırır,
doğru Claude modelindeki uzman alt ajana yönlendirir ve iki kapıyı zorunlu kılar:
**contract kontrol edilmeden inşa yok**, **bağımsız review olmadan "bitti" yok**.

Desteklenen stack'ler: **Next.js · Angular · Node.js (TypeScript) · Go**.

> 🇬🇧 English: [README.md](README.md)

## Neden

Her şeyi tek modelde yapan tek bir ajanın iki sorunu var: basit işler için pahalı ve kendi işini
kendisi notluyor. agentack işi gerçek bir ekip gibi böler:

- Mekanik işe ucuz model, plan ve review'a güçlü model, en güçlü model sadece geri dönüşü pahalı kararlara.
- Contract tek doğruluk kaynağıdır. Önce OpenAPI/AsyncAPI yazılır ve doğrulanır; frontend ve backend
  üretilmiş tiplere göre paralel inşa edilir.
- Modül sınırları sadece yazılı kalmaz, araçla zorlanır.
- Yazan kendi işini onaylamaz. Review temiz bağlamda ve salt-okur araçlarla yapılır.

## Kadro

```
Ana oturum (Opus) = MANAGER   ← skills/agentack/SKILL.md
 ├── scout           Haiku    repo keşfi, mekanik işler
 ├── architect       Opus     feature planı, contract, ADR
 ├── contract-guard  Haiku    lint, breaking-change kontrolü, codegen
 ├── be-go           Sonnet   Go modül implementasyonu
 ├── be-node         Sonnet   Node/TypeScript modül implementasyonu
 ├── fe-next         Sonnet   Next.js (App Router)
 ├── fe-angular      Sonnet   Angular (standalone + signals)
 ├── qa              Sonnet   contract, entegrasyon ve e2e testleri
 ├── reviewer        Opus     temiz bağlam, salt-okur review
 └── decider         Fable    sadece zor ve geri dönüşü pahalı kararlar
```

Manager ayrı bir alt ajan değil, ana oturumun kendisidir. Claude Code'da sadece ana oturum alt ajan
başlatabilir. Manager kod yazmaz; delege eder, durumu takip eder ve kapıları yönetir.

## Akış

```
sınıflandır ─► (karar) ─► plan + contract ─► contract kapısı ─► paralel inşa ─► test ─► review ─► birleştir
```

| Yol | Ne zaman | Ajanlar |
|---|---|---|
| **Hızlı** | S, contract değişmiyor, risk normal | builder → reviewer |
| **Standart** | M | architect → contract-guard → builder'lar (paralel) → qa → reviewer |
| **Ağır** | L, yüksek risk veya kırıcı contract | decider → architect → contract-guard → builder'lar → qa → reviewer |

**Eskalasyon:** Bir ajan aynı görevde iki kez başarısız olursa görev bir üst modele çıkar
(Haiku → Sonnet → Opus → Fable).

## Gereksinimler

- Skill ve alt ajan desteği olan Claude Code
- Opus, Sonnet, Haiku modellerine erişim (Fable opsiyonel, bkz. [Özelleştirme](#özelleştirme))
- Projenin bir **git** reposu olması (paralel builder'lar worktree kullanır)
- Kurulum betiği için `bash` (macOS, Linux, WSL)

## Kurulum

```bash
git clone https://github.com/osrbck/agentack.git ~/agentack
~/agentack/install.sh
```

Ana oturum modelini Opus yap: `~/.claude/settings.json` içine `"model": "opus"` ekle ya da oturumda `/model opus`.

**Güncelleme:** `cd ~/agentack && git pull && ./install.sh`
**Kaldırma:** `~/agentack/install.sh --uninstall`

## Kullanım

agentack sadece `/agentack` yazınca çalışır, diğer projelere karışmaz.

**1. Projede ilk sefer:**
```
/agentack Bu repoyu tara ve project-CLAUDE.md şablonuna göre CLAUDE.md oluştur. Eksik contract araçlarını listele.
```

**2. Sonra:**
```
/agentack billing modülüne fatura listeleme endpoint'i ve Next.js'te liste sayfası ekle
```

## Özelleştirme

- **Model değiştirme:** `agents/<ad>.md` içindeki `model:` alanını düzenle. `decider` `claude-fable-5-1`
  kullanır; hesabında Fable yoksa `opus` yap.
- **Yeni stack:** Bir builder'ı kopyala (ör. `agents/be-node.md`), kurallarını uyarla, `SKILL.md` içindeki
  kadro ve yönlendirme tablolarına ekle.
- **Proje kuralları:** Skill'i değiştirmek yerine projenin `CLAUDE.md` dosyasını kullan.
- Değişiklikleri her zaman repoda yap, `~/.claude` altındaki kopyada değil.

## Katkı

Issue ve pull request'ler açıktır. Bkz. [CONTRIBUTING.md](CONTRIBUTING.md).

## Lisans

[MIT](LICENSE)

---

agentack bir topluluk projesidir; Anthropic ile bağlantılı değildir ve Anthropic tarafından onaylanmamıştır.
