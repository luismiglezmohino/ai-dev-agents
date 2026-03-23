# Why These Gates Exist

[🇪🇸 Leer en español](es/why-these-gates.md)

> Back to [README](../../README.md)

Quality Gates are not theory. They were born from real chains of corrective PRs where an undetected error caused multiple consecutive fixes:

| Error chain | Corrective PRs | Root cause | Gate that prevents it |
|---|---|---|---|
| Broken ORM integration | 3 consecutive | DI not verified after GREEN | tdd-developer Gate 4: verify DI compiles |
| Deployment cascade | 9 consecutive | No health check or env vars | devops Gates 3-4: readiness check |
| Security/CSP headers | 5 consecutive | Security and observability not coordinated | Cross-verification between agents |
| Reactive auditing | 6 consecutive | Gates without final verification step | Final Verification in each agent |

Each gate exists because its absence caused repeated and avoidable work.
