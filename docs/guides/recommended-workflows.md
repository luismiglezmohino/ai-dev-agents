# GitHub Actions workflows recomendados

Los workflows de GitHub Actions son la segunda línea de defensa después de los Git hooks. Se ejecutan en el servidor, no en tu máquina — nadie puede saltárselos.

## Workflows mínimos recomendados

| Workflow | Cuándo se ejecuta | Qué hace |
|---|---|---|
| **CI Backend** | En cada PR y push a main | Tests + linter + type check del backend |
| **CI Frontend** | En cada PR y push a main | Tests + linter + build del frontend |
| **Commitlint** | En cada PR | Valida que los commits sigan conventional commits |
| **Security Review** | En cada PR | Auditoría de seguridad del código con IA |
| **CD Deploy** | Al mergear a main (tras CI verde) | Deploy automático a producción |
| **Dependabot/Renovate** | Automático (periódico) | Actualización automática de dependencias |

## Ejemplos de workflows

### CI Backend (PHP/Symfony)

```yaml
# .github/workflows/ci-backend.yml
name: CI Backend

on:
  pull_request:
    paths: ['backend/**']
  push:
    branches: [main]
    paths: ['backend/**']

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: Setup PHP
        uses: shivammathur/setup-php@v2
        with:
          php-version: '8.4'
          extensions: pdo_pgsql
      - run: composer install --no-interaction
      - run: php vendor/bin/phpstan analyse --memory-limit=512M
      - run: php vendor/bin/pest --coverage
```

### CI Frontend (Vue/TypeScript)

```yaml
# .github/workflows/ci-frontend.yml
name: CI Frontend

on:
  pull_request:
    paths: ['frontend/**']
  push:
    branches: [main]
    paths: ['frontend/**']

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
        with:
          node-version: '20'
      - run: npm ci
      - run: npm run lint
      - run: npm run test
      - run: npm run build
```

### Commitlint

```yaml
# .github/workflows/commitlint.yml
name: Commitlint

on:
  pull_request:
    types: [opened, synchronize, reopened]

jobs:
  lint:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
        with:
          fetch-depth: 0
      - uses: actions/setup-node@v4
        with:
          node-version: '20'
      - run: npm install --save-dev @commitlint/{cli,config-conventional}
      - run: npx commitlint --from ${{ github.event.pull_request.base.sha }} --to ${{ github.event.pull_request.head.sha }}
```

### Security Review con Claude Code (Anthropic)

```yaml
# .github/workflows/security-review.yml
name: Security Review

on:
  pull_request:
    types: [opened, synchronize, reopened]

jobs:
  review:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: anthropics/claude-code-action@v1
        with:
          anthropic_api_key: ${{ secrets.ANTHROPIC_API_KEY }}
```

> Requiere una API key de Anthropic configurada en Settings → Secrets → Actions del repositorio.
> Repositorio oficial: [anthropics/claude-code-action](https://github.com/anthropics/claude-code-action)

### CD Deploy (ejemplo con SSH)

```yaml
# .github/workflows/deploy.yml
name: Deploy

on:
  push:
    branches: [main]

jobs:
  deploy:
    runs-on: ubuntu-latest
    needs: [ci-backend, ci-frontend]
    steps:
      - uses: actions/checkout@v4
      - name: Deploy via SSH
        uses: appleboy/ssh-action@v1
        with:
          host: ${{ secrets.SERVER_HOST }}
          username: ${{ secrets.SERVER_USER }}
          key: ${{ secrets.SERVER_SSH_KEY }}
          script: |
            cd /var/www/proyecto
            git pull origin main
            # Comandos de deploy según stack
```

### Dependabot

```yaml
# .github/dependabot.yml
version: 2
updates:
  - package-ecosystem: "composer"
    directory: "/backend"
    schedule:
      interval: "weekly"
  - package-ecosystem: "npm"
    directory: "/frontend"
    schedule:
      interval: "weekly"
  - package-ecosystem: "github-actions"
    directory: "/"
    schedule:
      interval: "weekly"
```

## Protección de ramas

Configura estas reglas en GitHub → Settings → Rules:

| Branch | Protección | Agentes |
|---|---|---|
| `main` | Require 2 approvals + CI verde obligatorio | No pueden mergear |
| `staging` | Require 1 approval | Pueden abrir PRs |
| `feature/*` | Sin protección | Pueden commitear |

> "Blast radius controlado": si un agente la lía, solo afecta a una feature branch, nunca a producción.

## Criterios para añadir un workflow

1. **¿Es crítico para la calidad?** CI y commitlint son obligatorios
2. **¿Bloquea PRs?** Los checks obligatorios evitan que código malo llegue a main
3. **¿Tiene coste?** GitHub Actions tiene límites gratuitos (2000 min/mes para repos públicos, 500 min para privados)
4. **¿Se puede hacer en un hook local?** Si es rápido (lint, format), mejor en hook. Si es lento (E2E, deploy), mejor en CI
