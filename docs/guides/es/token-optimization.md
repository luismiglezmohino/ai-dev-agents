# Optimización de tokens

[🇬🇧 Read in English](../token-optimization.md)

> Volver al [README](../../README.es.md)

## Ahorro de tokens

### Estrategia de idioma

Todos los ficheros consumidos por la IA (agentes, skills, decisiones, templates, hooks) están escritos en **inglés** para minimizar el uso de tokens. El inglés es más eficiente en tokens que la mayoría de idiomas, lo que significa menor coste y más espacio en la ventana de contexto.

Los ficheros orientados al usuario (README, guías) son bilingües: inglés principal (`README.md`, `docs/guides/`) + español (`README.es.md`, `docs/guides/es/`). La salida del proyecto (specs, ADRs, docs) puede estar en el idioma que el usuario prefiera.

### Decisiones de diseño

Cada decisión de diseño del template reduce el consumo de tokens:

| Mejora | Por qué ahorra tokens |
|---|---|
| Inglés para ficheros de IA | ~20-30% menos tokens que español/otros idiomas para el mismo contenido |
| `project-context.md` | Restricciones del proyecto en 1 fichero. Sin él, cada agente las repite en su prompt |
| `decisions.md` | Decisiones rápidas (~30 líneas). Evita redescubrir o preguntar lo que ya se decidió |
| Feature Specs | Una spec compartida reemplaza N explicaciones parciales a N agentes |
| Reglas compactas | `sync.sh` genera 1 fichero para Cursor/Windsurf/Gemini/Copilot vs 11 agentes completos |
| Agentes bajo demanda | Solo se carga el agente invocado, no los 11 |
| Sub-CLAUDE.md por módulo | `backend/CLAUDE.md` no se carga cuando trabajas en frontend |
| `_base.md` + expansión | Boilerplate compartido en fuente, expandido en ficheros generados |

## Optimización de tokens

### Jerarquía de carga

```
Siempre cargado (cada mensaje):
  └── CLAUDE.md / AGENTS.md         → MANTENER < 120 líneas

Bajo demanda (solo cuando se invoca):
  ├── .ai/agents/*.md               → Sin límite
  └── .ai/skills/*.md               → Sin límite

Por directorio (solo en ese contexto):
  ├── backend/CLAUDE.md             → Stack backend
  └── frontend/CLAUDE.md            → Stack frontend
```

### Recomendaciones
- El fichero principal NO debe incluir: templates, snippets, checklists, workflows detallados
- Los roles en el fichero principal son una lista compacta (1 línea por rol)
- Los detalles de cada rol van en `.ai/agents/{rol}.md`
- Los detalles de frameworks van en `.ai/skills/{skill}/SKILL.md`
- Crea sub-CLAUDE.md por módulo para contexto específico del stack

### Herramientas externas para reducción de tokens

| Herramienta | Qué hace | Ahorro de tokens | Link |
|---|---|---|---|
| **[RTK](https://github.com/rtk-ai/rtk)** | Proxy CLI que filtra ruido del output de terminal (git status, test results, ls) antes de que llegue al modelo | 60-90% en output de comandos | Solo local, zero dependencies (Rust) |

RTK es complementario a la estrategia de tokens del template. El template reduce tokens en **instrucciones** (agentes, skills, contexto). RTK reduce tokens en **output de herramientas** (comandos de terminal). Ambos funcionan juntos.
