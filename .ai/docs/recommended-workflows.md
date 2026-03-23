# Recommended GitHub Actions Workflows

[🇪🇸 Leer en español](es/recommended-workflows.md)

GitHub Actions workflows are the second line of defense after Git hooks. They run on the server, not on your machine — nobody can skip them.

## Minimum Recommended Workflows

| Workflow | When it runs | What it does |
|---|---|---|
| **CI Backend** | On each PR and push to main | Backend tests + linter + type check |
| **CI Frontend** | On each PR and push to main | Frontend tests + linter + build |
| **Commitlint** | On each PR | Validates commits follow conventional commits |
| **Security Review** | On each PR | AI-powered code security audit |
| **CD Deploy** | On merge to main (after green CI) | Automatic deploy to production |
| **Dependabot/Renovate** | Automatic (periodic) | Automatic dependency updates |

## Workflow Examples

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

### Security Review with Claude Code (Anthropic)

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

> Requires an Anthropic API key configured in Settings → Secrets → Actions of the repository.
> Official repository: [anthropics/claude-code-action](https://github.com/anthropics/claude-code-action)

### Security Review with OpsGuard-AI (alternative)

```yaml
# .github/workflows/opsguard.yml
name: OpsGuard Security Review

on:
  pull_request:
    types: [opened, synchronize, reopened]

jobs:
  security:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: oscaar90/opsguard-ai@v1
        with:
          openai_api_key: ${{ secrets.OPENAI_API_KEY }}
```

> AI-powered security analysis that scores PR risk (0-10) and detects vulnerabilities like SQL injection, hardcoded secrets, and insecure patterns. Works as a last line of defense — catches what developers and agents miss.
> Available on [GitHub Marketplace](https://github.com/marketplace/actions/opsguard-ai) | [Repository](https://github.com/oscaar90/OpsGuard-AI)

> **Security note:** Both Claude Code Action and OpsGuard-AI send your PR diff to external LLM providers (Anthropic / OpenAI) for analysis. If your project handles sensitive data (health, financial, PII), verify that your organization allows sending code to third-party APIs.

### CD Deploy (SSH example)

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
            cd /var/www/project
            git pull origin main
            # Deploy commands per stack
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

## Branch Protection

Configure these rules in GitHub → Settings → Rules:

| Branch | Protection | Agents |
|---|---|---|
| `main` | Require 2 approvals + mandatory green CI | Cannot merge |
| `staging` | Require 1 approval | Can open PRs |
| `feature/*` | No protection | Can commit |

> "Controlled blast radius": if an agent makes a mistake, it only affects a feature branch, never production.

## Criteria for Adding a Workflow

1. **Is it critical for quality?** CI and commitlint are mandatory
2. **Does it block PRs?** Required checks prevent bad code from reaching main
3. **Does it have a cost?** GitHub Actions has free limits (2000 min/month for public repos, 500 min for private)
4. **Can it be done in a local hook?** If it's fast (lint, format), better as a hook. If it's slow (E2E, deploy), better in CI
