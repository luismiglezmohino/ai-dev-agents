# Por qué existen estos Quality Gates

[🇬🇧 Read in English](../why-these-gates.md)

> Volver al [README](../../README.es.md)

Los Quality Gates no son teoría. Nacieron de cadenas reales de PRs correctivos donde un error no detectado causó múltiples correcciones consecutivas:

| Cadena de errores | PRs correctivos | Causa raíz | Gate que lo previene |
|---|---|---|---|
| Integración ORM rota | 3 consecutivos | DI no verificado después de GREEN | tdd-developer Gate 4: verificar que DI compila |
| Cascada de despliegue | 9 consecutivos | Sin health check ni variables de entorno | devops Gates 3-4: readiness check |
| Headers Security/CSP | 5 consecutivos | Seguridad y observabilidad no coordinados | Verificación cruzada entre agentes |
| Auditoría reactiva | 6 consecutivos | Gates sin paso de verificación final | Verificación Final en cada agente |

Cada gate existe porque su ausencia causó trabajo repetido y evitable.
