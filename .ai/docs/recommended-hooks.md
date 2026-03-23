# Recommended Git Hooks

[🇪🇸 Leer en español](es/recommended-hooks.md)

Git hooks automate validations before code reaches the repository. They are the first line of defense: if something doesn't pass the hook, it doesn't get committed.

## Recommended Tools

| Tool | Requirements | Best for |
|---|---|---|
| **[Lefthook](https://github.com/evilmartians/lefthook)** | Standalone binary (Go). No Node.js required | Projects without Node.js (pure PHP, Python, Go, Java) |
| **[Husky](https://typicode.github.io/husky/)** | Requires `package.json` (Node.js) | Projects with Node.js frontend or monorepos with Vue/React |

If your project has a `package.json` (Vue, React frontend, etc.), use **Husky**. If not, use **Lefthook**.

## Minimum Recommended Hooks

### Pre-commit (before each commit)

| Hook | What it does | Tools by stack |
|---|---|---|
| **Commitlint** | Validates conventional commits format (`feat:`, `fix:`, `docs:`...) | commitlint + @commitlint/config-conventional |
| **Linter** | Static code errors | ESLint (JS/TS), PHPStan (PHP), Pylint (Python), golangci-lint (Go) |
| **Formatter** | Consistent formatting | Prettier (JS/TS/CSS), PHP-CS-Fixer (PHP), Black (Python), gofmt (Go) |
| **Type check** | Type errors | TypeScript `tsc --noEmit`, PHPStan level 8, mypy (Python) |
| **Secrets scan** | Detects API keys, passwords in code | [gitleaks](https://github.com/gitleaks/gitleaks), [detect-secrets](https://github.com/Yelp/detect-secrets) |
| **Branch name** | Validates branch format (`feature/`, `fix/`, `docs/`...) | Custom script or [validate-branch-name](https://www.npmjs.com/package/validate-branch-name) |

### Pre-push (before each push)

| Hook | What it does | Tools by stack |
|---|---|---|
| **Unit tests** | Runs fast tests | PestPHP (PHP), Vitest (JS/TS), pytest (Python), go test (Go) |
| **Build check** | Verifies the project compiles | `npm run build`, `php bin/console cache:clear` |

## Configuration Examples

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

## When NOT to Use Hooks

- For slow tests (E2E, integration) → better in CI/CD
- For deploy → always in CI/CD, never in local hooks
- If they block the workflow too much → move from pre-commit to pre-push
