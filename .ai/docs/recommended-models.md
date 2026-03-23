# Recommended Models per Task

[🇪🇸 Leer en español](es/recommended-models.md)

Model choice directly impacts quality, speed and cost. Don't use the most expensive model for everything — use the right one for each task.

> **Disclaimer:** This guide is indicative. The AI model ecosystem changes constantly — new models come out, prices change and capabilities evolve. Verify information with providers before making cost decisions. Today's best model may not be tomorrow's.

## Principle: Model per Task

| Task type | Recommended model | Reason |
|---|---|---|
| **Analysis and design** (architecture, decisions) | Reasoning (Opus, o1, Gemini thinking) | Needs to think, not go fast |
| **Code implementation** | Code (Opus, Claude Sonnet) | Best at code generation |
| **Security review** | Code (Opus, Claude Sonnet) | Deep line-by-line analysis |
| **Documentation** | General (Sonnet, GPT-4o) | Sufficient quality, lower cost |
| **Scripts and configs** | Fast (Haiku, GPT-4o-mini) | Repetitive tasks, don't need thinking |
| **Planning (plan mode)** | Reasoning (Opus, o1) | The plan defines everything that follows |

## Model per Agent

| Agent | Suggested model | Reason |
|---|---|---|
| @architect | Reasoning | Architectural decisions require deep analysis |
| @product-owner | Reasoning | Requirements analysis and business value |
| @tdd-developer | Code | Implementation and refactoring |
| @security-auditor | Code | Detailed vulnerability analysis |
| @database-engineer | Code | Schema design and queries |
| @qa-engineer | Code | Test design |
| @performance-engineer | Code | Profiling and optimization |
| @technical-writer | General | Documentation, sufficient quality |
| @devops | Fast | Configs, scripts, repetitive tasks |
| @observability-engineer | General | Metrics and logs configuration |
| @ux-designer | General | Accessibility and UX review |

## Available Models (March 2026)

### Paid

| Model | Provider | Strong at | Relative cost |
|---|---|---|---|
| **Claude Opus 4.6** | Anthropic | Code + reasoning | High (3x Sonnet) |
| **Claude Sonnet 4.6** | Anthropic | Code, quality/cost balance | Medium |
| **GPT-4o** | OpenAI | General, multimodal | Medium |
| **o1** | OpenAI | Deep reasoning | High |
| **Gemini 2.0 Pro** | Google | Long context (1M tokens) | Medium |

### Free / Low Cost

| Model | Provider | Strong at | How to use |
|---|---|---|---|
| **Claude Haiku 4.5** | Anthropic | Fast, cheap | Claude Code (basic plan) |
| **GPT-4o-mini** | OpenAI | General, very cheap | OpenAI API |
| **Gemini Flash** | Google | Fast, long context | Google API / Gemini CLI |
| **Llama 70B** | Meta (via Groq) | Code, open source | Groq free tier (1000 RPD) |
| **Qwen 2.5** | Alibaba | Code, open source | Local with Ollama/LM Studio |
| **OpenCode models** | Various | General | OpenCode free tier |

## Cost Strategy

### If you don't want to spend anything

- **OpenCode** with free models for implementation
- **Groq free tier** (Llama 70B) for code tasks
- **Ollama/LM Studio** with Qwen 2.5 for quick local tasks
- **GitHub Copilot free tier** for autocomplete

### If you can spend a little (~20EUR/month)

- **Claude Code** basic plan (Sonnet for code, Haiku for scripts)
- Reserve Opus only for planning and architecture (plan mode)

### If you have a budget (~100EUR/month)

- **Claude Code** advanced plan (Opus for everything complex)
- Sonnet/Haiku for routine tasks
- Model routing per agent

## Current Model Routing Support

| Tool | Supports model routing | How |
|---|---|---|
| **OpenCode** | Yes | Configurable per agent |
| **Cursor** | Yes | Per rule |
| **Claude Code** | No (1 model per session) | Switch manually between sessions |
| **Windsurf** | No | — |
| **Gemini CLI** | No | — |
| **GitHub Copilot** | Partial | Manual selection |

## Local Models

If you want zero cost and total privacy, you can run models on your machine. You need a GPU or a CPU with enough RAM.

### Tools for Running Local Models

| Tool | Interface | Link |
|---|---|---|
| **[Ollama](https://ollama.ai)** | CLI + REST API | Most popular, easy to use |
| **[LM Studio](https://lmstudio.ai)** | Desktop GUI | More visual, ideal for testing models |

### Recommended Local Models

| Model | Parameters | Min RAM | Strong at | Quality |
|---|---|---|---|---|
| **Qwen 2.5 Coder** | 7B | ~6 GB | Code, instructions | Good for its size |
| **DeepSeek Coder V2** | 16B | ~12 GB | Code, reasoning | Very good |
| **Llama 3.1** | 8B | ~6 GB | General, instructions | Good |
| **Llama 3.1** | 70B | ~48 GB | General, code | Excellent (requires powerful GPU) |
| **Mistral** | 7B | ~6 GB | General, fast | Acceptable |
| **CodeGemma** | 7B | ~6 GB | Code | Good |
| **Phi-3** | 3.8B | ~3 GB | General, very lightweight | Acceptable for simple tasks |

### Using Local Models with Dev Tools

| Tool | Compatible with local models | How |
|---|---|---|
| **OpenCode** | Yes | Configure Ollama provider in settings |
| **Claude Code** | Yes | Configure local model as provider |
| **Cursor** | Yes | Configure Ollama as custom model |
| **Continue (VS Code)** | Yes | Native Ollama integration |

This allows you to use the same template agent workflow but with local models at zero cost.

### Hardware and Local Models

The model you can run depends directly on your hardware. A Mac M4 with 24 GB of unified memory is not the same as a PC with Intel and 16 GB of RAM.

| Hardware | Models you can run | Performance |
|---|---|---|
| **Mac M3/M4 (24+ GB)** | Up to 70B (quantized), 7B-16B comfortable | Fast thanks to unified GPU/CPU memory |
| **Mac M1/M2 (16 GB)** | 7B comfortable, 16B tight | Acceptable |
| **PC with NVIDIA GPU (8+ GB VRAM)** | 7B with GPU, 16B tight | Fast if it fits in VRAM |
| **PC without GPU (16 GB RAM)** | 3.8B-7B on CPU | Slow but functional |
| **PC without GPU (8 GB RAM)** | 3.8B maximum | Very slow, testing only |

> **Rule of thumb:** a 7B model needs ~6 GB of RAM/VRAM. A 16B model needs ~12 GB. If the model doesn't fit in memory, it runs partially from disk and speed drops drastically.

> **Mac vs PC:** Macs with Apple Silicon (M1-M4) have an advantage for local models because memory is unified (CPU and GPU share the same RAM). On PC, if you don't have an NVIDIA GPU with enough VRAM, the model runs on CPU and is much slower.

### Local Model Limitations

- **Lower quality** than cloud models (Opus, GPT-4o) for complex tasks
- **Speed** depends on your hardware (GPU >> CPU)
- **Limited context** — most support 4K-32K tokens vs 200K from cloud models
- **No native tools** — they don't execute commands or read files like Claude Code. You need a tool that integrates them (OpenCode, Continue, etc.)

### When to Use Local

| Situation | Local | Cloud |
|---|---|---|
| No budget | Yes | No |
| Sensitive data (cannot leave your machine) | Yes | No |
| Simple tasks (scripts, configs, docs) | Yes | Unnecessary |
| Complex code (architecture, large refactor) | No | Yes |
| Plan mode / deep reasoning | No | Yes |

> **Disclaimer:** Local models evolve very fast. This list is indicative. Check [Ollama library](https://ollama.ai/library) for the latest models.

## When to Switch Models

- If the AI hallucinates → switch to a more powerful model
- If it's too slow → switch to a faster model
- If costs spike → switch to Haiku/GPT-4o-mini for simple tasks
- If context fills up → use a model with a larger window (Gemini 1M)

## Model Routing per Agent

Each agent can use the model best suited for its task:

| Role | Suggested model | Reason |
|---|---|---|
| @architect, @product-owner | Reasoning (Gemini, o1) | Analysis, design, decisions |
| @tdd-developer | Code (Opus, Claude) | Best at implementation |
| @security-auditor | Code (Opus, Claude) | Deep code analysis |
| @technical-writer | General (Sonnet, GPT-4o) | Documentation, sufficient quality |
| @devops | Fast (Haiku, GPT-4o-mini) | Scripts, configs, repetitive tasks |

**Current state:** Claude Code uses one model per session. OpenCode supports model routing. Documented as a future pattern for when tools natively support it.
