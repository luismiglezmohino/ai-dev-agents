---
name: git
description: Git workflow, conventional commits, branch naming and PR conventions
license: MIT
compatibility: opencode
metadata:
  type: infra
  framework: git
  language: agnostic
---

# SKILL: Git

> **REVISAR:** Este skill fue generado con best practices genéricas.
> Adaptalo a las convenciones de tu proyecto antes de usarlo en producción.
> Ultima revision: 2026-02-24

## Tech Stack

- Git >= 2.40
- Husky >= 9.0 (git hooks)
- GitHub Flow (trunk-based simplificado)
- Conventional Commits 1.0.0

## Patrones del Proyecto

### Branch Naming

Formato: `<tipo>/<descripción-kebab-case>`

```
feature/add-user-auth
fix/login-redirect-loop
docs/update-api-readme
refactor/extract-payment-service
chore/upgrade-dependencies
hotfix/critical-null-pointer
```

**Reglas:**
- Siempre en ingles, kebab-case
- Descripción corta pero descriptiva (3-5 palabras max)
- Rama base: `main` (nunca `develop` en GitHub Flow)
- Borrar rama después de merge

### Conventional Commits

Formato: `<tipo>(<alcance>): <descripción>`

```bash
feat(auth): add JWT token refresh endpoint
fix(pictograms): correct ARASAAC API timeout handling
docs(api): update OpenAPI spec for /users endpoint
test(auth): add integration tests for login flow
refactor(domain): extract ValueObject base class
perf(search): add index for pictogram full-text search
chore(deps): upgrade symfony to 7.2
```

**Tipos permitidos:**

| Tipo | Cuando usar | Ejemplo |
|------|-------------|---------|
| `feat` | Nueva funcionalidad | `feat(board): add drag-and-drop pictograms` |
| `fix` | Corrección de bug | `fix(tts): handle empty text in speech synthesis` |
| `docs` | Solo documentación | `docs(readme): add setup instructions` |
| `test` | Añadir o corregir tests | `test(api): add e2e tests for auth flow` |
| `refactor` | Sin cambio de comportamiento | `refactor(users): extract repository interface` |
| `perf` | Mejora de rendimiento | `perf(api): cache pictogram responses` |
| `chore` | Mantenimiento, deps, CI | `chore(docker): update PHP base image` |
| `ci` | Cambios en CI/CD | `ci(github): add deploy workflow` |

**Reglas del mensaje:**
- Descripción en imperativo, minusculas, sin punto final
- Alcance opcional pero recomendado (modulo o capa afectada)
- Primera línea < 72 caracteres
- Body opcional: separado por línea en blanco, explica el "por que"
- Footer: `BREAKING CHANGE:` si rompe compatibilidad, `Closes #123` para issues

```bash
feat(auth): add password reset via email

Users reported being locked out of their accounts. This adds
a password reset flow using time-limited tokens sent via email.

Closes #45
```

### GitHub Flow

```
main ─────●─────●─────●─────●─────── (siempre deployable)
           \                 /
            feature/xyz ────● (PR + review + merge)
```

1. **Crear rama** desde `main`
2. **Desarrollar** con commits frecuentes y descriptivos
3. **Push** y crear PR cuando este listo para review
4. **Review** — mínimo 1 aprobación
5. **Merge** a `main` (squash o merge commit segun preferencia)
6. **Deploy** automático tras merge
7. **Borrar** rama feature

### PR Template

```markdown
## Que cambia

[Descripción breve de los cambios]

## Por que

[Motivacion, issue que resuelve, contexto]

## Como probarlo

1. [Paso 1]
2. [Paso 2]

## Checklist

- [ ] Tests pasan
- [ ] Lint limpio
- [ ] Documentación actualizada (si aplica)
- [ ] Sin secrets hardcodeados
```

### Husky (Git Hooks)

Husky ejecuta scripts automáticamente en eventos de git. Garantiza que ningun commit ni push rompa las reglas del proyecto.

**Instalacion:**

```bash
npm install --save-dev husky
npx husky init
```

Esto crea `.husky/` con un `pre-commit` de ejemplo. Estructura:

```
.husky/
├── pre-commit       # Se ejecuta ANTES de cada commit
├── pre-push         # Se ejecuta ANTES de cada push
└── commit-msg       # Valida el mensaje de commit
```

**pre-commit** — Lint y formato (solo archivos staged):

```bash
#!/bin/sh
# .husky/pre-commit

# Backend: lint PHP
cd backend && composer lint 2>/dev/null

# Frontend: lint + format staged files
cd frontend && npx lint-staged
```

**commit-msg** — Validar conventional commits:

```bash
#!/bin/sh
# .husky/commit-msg

message=$(cat "$1")
pattern="^(feat|fix|docs|test|refactor|perf|chore|ci)(\(.+\))?: .{1,68}$"

if ! echo "$message" | head -1 | grep -qE "$pattern"; then
  echo "ERROR: Commit message no sigue Conventional Commits"
  echo "Formato: tipo(alcance): descripción"
  echo "Ejemplo: feat(auth): add login endpoint"
  exit 1
fi
```

**pre-push** — Tests antes de push:

```bash
#!/bin/sh
# .husky/pre-push

# Backend tests
cd backend && ./vendor/bin/pest --bail 2>/dev/null || exit 1

# Frontend tests
cd frontend && npm run test -- --bail 2>/dev/null || exit 1
```

**lint-staged** (complemento de Husky para pre-commit eficiente):

```json
// package.json
{
  "lint-staged": {
    "*.{ts,vue}": ["eslint --fix", "prettier --write"],
    "*.php": ["php-cs-fixer fix"]
  }
}
```

**Reglas:**
- Los hooks `.husky/` se commitean al repo (todo el equipo los comparte)
- Usar `lint-staged` en pre-commit para no relintear todo el proyecto
- Pre-push ejecuta tests — es la ultima barrera antes del remoto
- Nunca usar `--no-verify` salvo emergencia justificada

### .gitignore Patterns

Mantener organizado por secciones:

```gitignore
# OS
.DS_Store
Thumbs.db

# IDE
.idea/
.vscode/
*.swp
*.swo

# Dependencies
/vendor/
/node_modules/

# Environment
.env
.env.local

# Build
/dist/
/build/
/var/

# Session state (local per developer)
.ai/.local/*
!.ai/.local/.gitkeep

# Generated (AI tools — regenerar con .ai/sync.sh)
.claude/agents/
.claude/rules/
.claude/skills
.opencode/agents
.opencode/skills
.opencode/decisions.md
.cursorrules
.windsurfrules
GEMINI.md
.github/copilot-instructions.md
```

## Errores Conocidos y Soluciones

- **Problema:** Commit con tipo incorrecto (ej: `fix` cuando es `refactor`)
  **Causa:** No distinguir entre cambio de comportamiento y reestructuracion
  **Solucion:** Si el usuario ve un cambio diferente, es `fix` o `feat`. Si no nota nada, es `refactor`

- **Problema:** Ramas huerfanas que no se borran después de merge
  **Causa:** No configurar auto-delete en GitHub o no borrar manualmente
  **Solucion:** Activar "Automatically delete head branches" en Settings > General del repo

- **Problema:** Merge conflicts frecuentes en ramas de larga vida
  **Causa:** Rama feature abierta demasiado tiempo sin sincronizar con main
  **Solucion:** Hacer `git rebase main` o merge de main frecuentemente. Ramas cortas (< 3 dias)

- **Problema:** Commits con secrets (API keys, passwords)
  **Causa:** Archivos .env o config no excluidos en .gitignore
  **Solucion:** Pre-commit hook con detección de secrets. Si ya se commiteo, rotar el secret inmediatamente (el historial de git lo retiene)

- **Problema:** Husky hooks no se ejecutan después de `git clone`
  **Causa:** Husky 9+ requiere `npm install` para activar los hooks via el script `prepare`
  **Solucion:** Verificar que `package.json` tiene `"prepare": "husky"` en scripts. Tras clone: `npm install`

- **Problema:** Hooks lentos bloquean el flujo de desarrollo
  **Causa:** Pre-commit ejecuta lint/tests sobre todo el proyecto
  **Solucion:** Usar `lint-staged` para pre-commit (solo archivos staged). Tests completos solo en pre-push

## Checklist

- [ ] Rama creada desde `main` con naming correcto (`tipo/descripción`)
- [ ] Commits siguen Conventional Commits (`tipo(alcance): descripción`)
- [ ] Mensaje de commit < 72 caracteres en primera línea
- [ ] No hay secrets en el commit (`grep -r "password\|secret\|api_key"`)
- [ ] PR tiene descripción, motivacion y como probarlo
- [ ] Rama borrada después de merge
- [ ] Husky instalado (`npx husky init`) con `"prepare": "husky"` en package.json
- [ ] Pre-commit: lint con `lint-staged` (solo archivos staged)
- [ ] Commit-msg: valida formato Conventional Commits
- [ ] Pre-push: ejecuta tests antes de enviar al remoto

## Referencias

- [Conventional Commits 1.0.0](https://www.conventionalcommits.org/en/v1.0.0/)
- [GitHub Flow](https://docs.github.com/en/get-started/using-git/github-flow)
- [Husky](https://typicode.github.io/husky/)
- [lint-staged](https://github.com/lint-staged/lint-staged)
- [Git Best Practices](https://git-scm.com/book/en/v2)
