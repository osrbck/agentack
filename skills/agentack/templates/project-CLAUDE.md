# <Proje adı>

Bu proje `agentack` skill'i ile yönetilir. Aşağıdaki değerler skill'deki
varsayılanların üstündedir.

## Uygulamalar
| Uygulama | Yol | Stack |
|---|---|---|
| web | apps/web-next | Next.js <sürüm>, App Router |
| admin | apps/web-angular | Angular <sürüm>, standalone + signals |
| api | apps/api-go | Go <sürüm>, chi/echo/stdlib |
| api-node | apps/api-node | Node <sürüm>, NestJS/Fastify |

## Modüller
| Modül | Sahip uygulama | Contract |
|---|---|---|
| identity | api-go | contracts/identity |

## Komutlar
| Amaç | Komut |
|---|---|
| Kurulum | `pnpm install` |
| Lint (tümü) | `pnpm lint` |
| Typecheck | `pnpm typecheck` |
| Test (tümü) | `pnpm test` |
| Go test | `cd apps/api-go && go test ./...` |
| Go lint | `cd apps/api-go && golangci-lint run` |
| Contract lint | `pnpm contracts:lint` |
| Breaking check | `pnpm contracts:breaking` |
| Codegen | `pnpm contracts:gen` |
| Mock API | `pnpm contracts:mock` |
| Sınır kontrolü | `pnpm boundaries` |
| E2E | `pnpm e2e` |
| Tam doğrulama | `pnpm verify` |
| Lokal ortam | `docker compose up -d` |

## Proje kuralları
- Ana dal: `main`. Branch adı: `feat/<slug>`, `fix/<slug>`.
- Veritabanı: <PostgreSQL>, modül başına şema (`identity.*`, `billing.*`).
- Migration aracı: <goose / atlas / prisma migrate>.
