# Modelos recomendados por tarea

[🇬🇧 Read in English](../recommended-models.md)


La elección del modelo impacta directamente en calidad, velocidad y coste. No uses el modelo más caro para todo — usa el adecuado para cada tarea.

> **Aviso:** Esta guía es orientativa. El ecosistema de modelos de IA cambia constantemente — salen nuevos modelos, cambian precios y las capacidades evolucionan. Verifica la información con los proveedores antes de tomar decisiones de coste. Lo que hoy es el mejor modelo puede no serlo mañana.

## Principio: modelo según la tarea

| Tipo de tarea | Modelo recomendado | Razón |
|---|---|---|
| **Análisis y diseño** (arquitectura, decisiones) | Razonamiento (Opus, o1, Gemini thinking) | Necesita pensar, no ir rápido |
| **Implementación de código** | Código (Opus, Claude Sonnet) | Mejor en generación de código |
| **Revisión de seguridad** | Código (Opus, Claude Sonnet) | Análisis profundo línea por línea |
| **Documentación** | General (Sonnet, GPT-4o) | Suficiente calidad, menor coste |
| **Scripts y configs** | Rápido (Haiku, GPT-4o-mini) | Tareas repetitivas, no necesitan pensar |
| **Planificación (plan mode)** | Razonamiento (Opus, o1) | El plan define todo lo que viene después |

## Modelo por agente

| Agente | Modelo sugerido | Razón |
|---|---|---|
| @architect | Razonamiento | Decisiones arquitectónicas requieren análisis profundo |
| @product-owner | Razonamiento | Análisis de requisitos y valor de negocio |
| @tdd-developer | Código | Implementación y refactor |
| @security-auditor | Código | Análisis detallado de vulnerabilidades |
| @database-engineer | Código | Schema design y queries |
| @qa-engineer | Código | Diseño de tests |
| @performance-engineer | Código | Profiling y optimización |
| @technical-writer | General | Documentación, suficiente calidad |
| @devops | Rápido | Configs, scripts, tareas repetitivas |
| @observability-engineer | General | Configuración de métricas y logs |
| @ux-designer | General | Revisión de accesibilidad y UX |

## Modelos disponibles (marzo 2026)

### Pago

| Modelo | Proveedor | Fuerte en | Coste relativo |
|---|---|---|---|
| **Claude Opus 4.6** | Anthropic | Código + razonamiento | Alto (3x Sonnet) |
| **Claude Sonnet 4.6** | Anthropic | Código, equilibrio calidad/coste | Medio |
| **GPT-4o** | OpenAI | General, multimodal | Medio |
| **o1** | OpenAI | Razonamiento profundo | Alto |
| **Gemini 2.0 Pro** | Google | Contexto largo (1M tokens) | Medio |

### Gratuitos / bajo coste

| Modelo | Proveedor | Fuerte en | Cómo usarlo |
|---|---|---|---|
| **Claude Haiku 4.5** | Anthropic | Rápido, barato | Claude Code (plan básico) |
| **GPT-4o-mini** | OpenAI | General, muy barato | API OpenAI |
| **Gemini Flash** | Google | Rápido, contexto largo | API Google / Gemini CLI |
| **Llama 70B** | Meta (via Groq) | Código, open source | Groq free tier (1000 RPD) |
| **Qwen 2.5** | Alibaba | Código, open source | Local con Ollama/LM Studio |
| **Modelos OpenCode** | Varios | General | OpenCode free tier |

## Estrategia de costes

### Si no quieres gastar nada

- **OpenCode** con modelos gratuitos para implementación
- **Groq free tier** (Llama 70B) para tareas de código
- **Ollama/LM Studio** con Qwen 2.5 para tareas locales rápidas
- **GitHub Copilot free tier** para autocompletado

### Si puedes gastar poco (~20€/mes)

- **Claude Code** plan básico (Sonnet para código, Haiku para scripts)
- Reserva Opus solo para planificación y arquitectura (plan mode)

### Si tienes presupuesto (~100€/mes)

- **Claude Code** plan avanzado (Opus para todo lo complejo)
- Sonnet/Haiku para tareas rutinarias
- Model routing por agente

## Estado actual del model routing

| Herramienta | Soporta model routing | Cómo |
|---|---|---|
| **OpenCode** | Sí | Configurable por agente |
| **Cursor** | Sí | Por regla |
| **Claude Code** | No (1 modelo por sesión) | Cambiar manualmente entre sesiones |
| **Windsurf** | No | — |
| **Gemini CLI** | No | — |
| **GitHub Copilot** | Parcial | Selección manual |

## Modelos locales

Si quieres coste 0 y privacidad total, puedes ejecutar modelos en tu máquina. Necesitas una GPU o una CPU con suficiente RAM.

### Herramientas para ejecutar modelos locales

| Herramienta | Interfaz | Enlace |
|---|---|---|
| **[Ollama](https://ollama.ai)** | CLI + API REST | Más popular, fácil de usar |
| **[LM Studio](https://lmstudio.ai)** | GUI de escritorio | Más visual, ideal para probar modelos |

### Modelos locales recomendados

| Modelo | Parámetros | RAM mínima | Fuerte en | Calidad |
|---|---|---|---|---|
| **Qwen 2.5 Coder** | 7B | ~6 GB | Código, instrucciones | Buena para su tamaño |
| **DeepSeek Coder V2** | 16B | ~12 GB | Código, razonamiento | Muy buena |
| **Llama 3.1** | 8B | ~6 GB | General, instrucciones | Buena |
| **Llama 3.1** | 70B | ~48 GB | General, código | Excelente (requiere GPU potente) |
| **Mistral** | 7B | ~6 GB | General, rápido | Aceptable |
| **CodeGemma** | 7B | ~6 GB | Código | Buena |
| **Phi-3** | 3.8B | ~3 GB | General, muy ligero | Aceptable para tareas simples |

### Usar modelos locales con herramientas de desarrollo

| Herramienta | Compatible con modelos locales | Cómo |
|---|---|---|
| **OpenCode** | Sí | Configurar proveedor Ollama en settings |
| **Claude Code** | Sí | Configurar modelo local como proveedor |
| **Cursor** | Sí | Configurar Ollama como modelo custom |
| **Continue (VS Code)** | Sí | Integración nativa con Ollama |

Esto te permite usar el mismo flujo de agentes del template pero con modelos locales y coste 0.

### Hardware y modelos locales

El modelo que puedas ejecutar depende directamente de tu equipo. No es lo mismo un Mac M4 con 24 GB de memoria unificada que un PC con Intel y 16 GB de RAM.

| Hardware | Modelos que puedes ejecutar | Rendimiento |
|---|---|---|
| **Mac M3/M4 (24+ GB)** | Hasta 70B (quantizado), 7B-16B cómodo | Rápido gracias a la memoria unificada GPU/CPU |
| **Mac M1/M2 (16 GB)** | 7B cómodo, 16B justo | Aceptable |
| **PC con GPU NVIDIA (8+ GB VRAM)** | 7B con GPU, 16B justo | Rápido si cabe en VRAM |
| **PC sin GPU (16 GB RAM)** | 3.8B-7B en CPU | Lento pero funcional |
| **PC sin GPU (8 GB RAM)** | 3.8B máximo | Muy lento, solo para probar |

> **Regla general:** un modelo de 7B necesita ~6 GB de RAM/VRAM. Un modelo de 16B necesita ~12 GB. Si el modelo no cabe en memoria, se ejecuta parcialmente en disco y la velocidad cae drásticamente.

> **Mac vs PC:** Los Mac con chip Apple Silicon (M1-M4) tienen ventaja en modelos locales porque la memoria es unificada (CPU y GPU comparten la misma RAM). En PC, si no tienes GPU NVIDIA con suficiente VRAM, el modelo se ejecuta en CPU y es mucho más lento.

### Limitaciones de modelos locales

- **Calidad inferior** a modelos cloud (Opus, GPT-4o) para tareas complejas
- **Velocidad** depende de tu hardware (GPU >> CPU)
- **Contexto limitado** — la mayoría soportan 4K-32K tokens vs 200K de modelos cloud
- **Sin herramientas nativas** — no ejecutan comandos ni leen ficheros como Claude Code. Necesitas una herramienta que los integre (OpenCode, Continue, etc.)

### Cuándo usar local

| Situación | Local | Cloud |
|---|---|---|
| Sin presupuesto | Sí | No |
| Datos sensibles (no pueden salir de tu máquina) | Sí | No |
| Tareas simples (scripts, configs, docs) | Sí | Innecesario |
| Código complejo (arquitectura, refactor grande) | No | Sí |
| Plan mode / razonamiento profundo | No | Sí |

> **Aviso:** Los modelos locales evolucionan muy rápido. Esta lista es orientativa. Consulta [Ollama library](https://ollama.ai/library) para ver los modelos más recientes.

## Cuándo cambiar de modelo

- Si la IA alucina → sube a un modelo más potente
- Si tarda demasiado → baja a un modelo más rápido
- Si el coste se dispara → baja a Haiku/GPT-4o-mini para tareas simples
- Si el contexto se llena → usa un modelo con ventana más grande (Gemini 1M)

## Model routing por agente

Cada agente puede usar el modelo más adecuado para su tarea:

| Rol | Modelo sugerido | Razón |
|---|---|---|
| @architect, @product-owner | Razonamiento (Gemini, o1) | Análisis, diseño, decisiones |
| @tdd-developer | Código (Opus, Claude) | Mejor en implementación |
| @security-auditor | Código (Opus, Claude) | Análisis profundo de código |
| @technical-writer | General (Sonnet, GPT-4o) | Documentación, suficiente calidad |
| @devops | Rápido (Haiku, GPT-4o-mini) | Scripts, configs, tareas repetitivas |

**Estado actual:** Claude Code usa un modelo por sesión. OpenCode soporta model routing. Documentado como patrón futuro para cuando las herramientas lo soporten nativamente.
