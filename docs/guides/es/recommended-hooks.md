# Git hooks recomendados

[🇬🇧 Read in English](../recommended-hooks.md)


Los Git hooks automatizan validaciones antes de que el código llegue al repositorio. Son la primera línea de defensa: si algo no pasa el hook, no se commitea.

## Herramientas recomendadas

| Herramienta | Requisitos | Mejor para |
|---|---|---|
| **[Lefthook](https://github.com/evilmartians/lefthook)** | Binario standalone (Go). No necesita Node.js | Proyectos sin Node.js (PHP puro, Python, Go, Java) |
| **[Husky](https://typicode.github.io/husky/)** | Necesita `package.json` (Node.js) | Proyectos con frontend Node.js o monorepos con Vue/React |

Si tu proyecto tiene `package.json` (frontend Vue, React, etc.), usa **Husky**. Si no, usa **Lefthook**.

## Hooks mínimos recomendados

### Pre-commit (antes de cada commit)

| Hook | Qué hace | Herramientas por stack |
|---|---|---|
| **Commitlint** | Valida formato conventional commits (`feat:`, `fix:`, `docs:`...) | commitlint + @commitlint/config-conventional |
| **Linter** | Errores de código estático | ESLint (JS/TS), PHPStan (PHP), Pylint (Python), golangci-lint (Go) |
| **Formatter** | Formato consistente | Prettier (JS/TS/CSS), PHP-CS-Fixer (PHP), Black (Python), gofmt (Go) |
| **Type check** | Errores de tipos | TypeScript `tsc --noEmit`, PHPStan level 8, mypy (Python) |
| **Secrets scan** | Detecta API keys, contraseñas en código | [gitleaks](https://github.com/gitleaks/gitleaks), [detect-secrets](https://github.com/Yelp/detect-secrets) |
| **Branch name** | Valida formato de rama (`feature/`, `fix/`, `docs/`...) | Script custom o [validate-branch-name](https://www.npmjs.com/package/validate-branch-name) |

### Pre-push (antes de cada push)

| Hook | Qué hace | Herramientas por stack |
|---|---|---|
| **Tests unitarios** | Ejecuta tests rápidos | PestPHP (PHP), Vitest (JS/TS), pytest (Python), go test (Go) |
| **Build check** | Verifica que el proyecto compila | `npm run build`, `php bin/console cache:clear` |

## Ejemplos de configuración

### Lefthook (`lefthook.yml`)

```yaml
pre-commit:
  commands:
    commitlint:
      run: npx commitlint --edit {1}
    lint-backend:
      glob: "*.php"
      run: php vendor/bin/phpstan analyse --memory-limit=512M
    lint-frontend:
      glob: "*.{ts,vue}"
      run: npx eslint {staged_files}
    format:
      glob: "*.{ts,vue,css,json}"
      run: npx prettier --check {staged_files}
    secrets:
      run: gitleaks protect --staged

pre-push:
  commands:
    tests-backend:
      run: php vendor/bin/pest
    tests-frontend:
      run: npx vitest run
```

### Husky + lint-staged

```json
// package.json
{
  "scripts": {
    "prepare": "husky"
  },
  "lint-staged": {
    "*.{ts,vue}": ["eslint --fix", "prettier --write"],
    "*.php": ["php vendor/bin/php-cs-fixer fix"],
    "*.{css,json,md}": ["prettier --write"]
  }
}
```

```bash
# .husky/pre-commit
npx lint-staged
npx commitlint --edit $1
gitleaks protect --staged
```

```bash
# .husky/pre-push
npm run test
```

## Cuándo NO usar hooks

- Para tests lentos (E2E, integración) → mejor en CI/CD
- Para deploy → siempre en CI/CD, nunca en hooks locales
- Si bloquean demasiado el flujo → mover de pre-commit a pre-push
