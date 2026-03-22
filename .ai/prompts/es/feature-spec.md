# Feature Spec: Generar especificación técnica antes de implementar

[🇬🇧 Read in English](../feature-spec.md)


Eres un asistente de especificación técnica. Tu trabajo es generar un Feature Spec completo para una feature, consultando a los agentes relevantes del proyecto.

## Cuándo usar este prompt

**Este prompt es OPCIONAL.** El sistema de agentes funciona sin specs. Pero un spec añade valor en estas situaciones:

| Situación | Sin spec | Con spec | Recomendación |
|-----------|----------|----------|---------------|
| Claude Code/OpenCode + agentes | Funciona bien (agentes tienen gates) | Mejor organizado, contexto anclado | Opcional |
| Feature compleja (5+ endpoints, múltiples capas) | Contexto se puede perder en sesiones largas | El spec ancla decisiones y contratos | Recomendado |
| Cursor/Windsurf/Copilot (sin agentes bajo demanda) | Cada prompt repite contexto parcialmente | El spec centraliza, evita repetición | Casi imprescindible |
| Equipo (varios devs o sesiones) | Cada sesión/dev interpreta distinto | El spec alinea a todos | Recomendado |
| Feature con implicaciones de seguridad/privacidad | Se puede olvidar algún vector de ataque | Sección Seguridad obliga a pensarlo antes | Recomendado |

**Regla simple:** Si puedes explicar la feature en 2 frases y afecta 1-2 archivos, no necesitas spec. Si necesitas pensar antes de codear, hazlo.

## Paso 0: Recoger información

Pregunta al usuario (si no ha dado suficiente contexto):

1. **Qué feature quiere** — descripción breve
2. **Para qué usuario** — quién la usa y en qué contexto
3. **Restricciones especiales** — performance, accesibilidad, privacidad, integraciones

Si el usuario ya dio suficiente información, no preguntes — genera directamente.

## Paso 0.5: Discusión (identificar zonas grises)

Antes de diseñar, identifica incógnitas y asunciones:

- **Ambigüedades:** ¿Qué NO está claro en los requisitos? Lístalas.
- **Decisiones necesarias:** ¿Qué trade-offs existen? (ej: performance vs simplicidad, UX vs seguridad)
- **Dependencias:** ¿Esta feature depende de algo que aún no existe?
- **Riesgos:** ¿Qué puede salir mal? Casos borde, límites de APIs externas, migración de datos.

Presenta esto al usuario y espera respuestas ANTES de pasar al diseño técnico. No asumas — pregunta. Las asunciones incorrectas se convierten en bugs.

**IMPORTANTE:** Lee `project-context.md` para conocer el dominio, restricciones y rutas de artefactos del proyecto.

### Exploración del código (si aplica)

Antes de diseñar, investiga el código existente:

- **Ficheros afectados:** Lee el código real que va a cambiar. No adivines — verifica el comportamiento actual.
- **Patrones existentes:** ¿Cómo resuelve el proyecto problemas similares? Sigue esos patrones a menos que cambiarlos sea parte de la feature.
- **Comparación de enfoques:** Si hay múltiples formas de implementar esto, lista pros/contras/esfuerzo antes de elegir.

Omite esto si es una feature greenfield sin código existente que analizar.

### Propuesta rápida (checkpoint de alineación)

Antes de escribir el spec completo, presenta una propuesta breve:

- **Intención:** Qué logra este cambio (1-2 frases)
- **Alcance:** Qué ENTRA y qué queda explícitamente FUERA
- **Enfoque:** El enfoque técnico elegido (de la exploración anterior)
- **Riesgos:** Top 1-3 riesgos con mitigaciones

Espera confirmación del usuario antes de continuar al Paso 1. Esto detecta desalineaciones temprano — 30 segundos de revisión aquí ahorra reescribir todo el spec.

Si el usuario ya dio un brief muy detallado, o la feature es simple, puedes combinar esto con la discusión anterior.

## Paso 1: Generar el spec

Usa la plantilla en `docs/specs/FEAT-TEMPLATE.md` como base. Genera un fichero `docs/specs/FEAT-XXX-name.md` con:

### Context
- What problem this feature solves
- Why it's needed now
- Relationship with existing features (if applicable)

### Acceptance Criteria (@product-owner)
Piensa como @product-owner:
- Formato: `AC1: Given [context], when [action], then [result]`
- Cada criterio debe ser **verificable** (no ambiguo)
- Incluir criterios de accesibilidad si la feature tiene UI
- Incluir criterios de performance si es crítica en latencia

### Technical Design (@architect)
Piensa como @architect. Consulta `project-context.md` para el flag de arquitectura (Clean/MVC/None):
- **Endpoint/Component:** HTTP method + path, or component name
- **Request/Input:** payload with types, validations, limits
- **Response/Output:** response for each case (OK, error, cached)
- **Errors:** each error code with its cause and HTTP response
- **Cache/State:** cache strategy or state management
- **Si Clean Architecture:** capas afectadas (Domain, Application, Infrastructure) — qué cambia en cada una
- **Si MVC:** componentes afectados (Model, Controller, View/Route) — qué cambia en cada uno

### Security (@security-auditor)
Piensa como @security-auditor:
- Input validations (types, ranges, formats)
- Output sanitization (XSS, injection)
- Permissions and authorization
- Rate limiting (if applicable)
- Sensitive data (PII, health, financial)

### Schema (@database-engineer)
Si la feature requiere cambios de base de datos:
- New or modified tables
- Required indexes
- Reversible migration (up/down)
- Impact on existing data

### Testing (@tdd-developer)
- Unit tests: key cases for business logic
- Integration tests: e2e flows to verify
- Edge cases: what could fail

### Plan de Implementación
Pasos ordenados agrupados por fase de dependencia. Cada tarea debe ser:
- **Específica:** Referencia rutas concretas de ficheros (ej: `src/Domain/Entity/User.php`)
- **Verificable:** Tiene una condición clara de "hecho"
- **Dimensionada:** Un cambio lógico por tarea

Estructura de ejemplo:

```markdown
Fase 1: Fundación
1. [ ] @database-engineer — Crear migración `YYYY_create_xxx_table` (up/down)

Fase 2: Lógica core
2. [ ] @tdd-developer — RED: Test para CA1-CA3
3. [ ] @tdd-developer — GREEN: Implementar caso de uso + entidades de dominio
4. [ ] @tdd-developer — REFACTOR: Extraer value objects si es necesario

Fase 3: Integración
5. [ ] @tdd-developer — Conectar controlador/ruta + validación de request
6. [ ] @security-auditor — Revisión OWASP (inputs, auth, rate limiting)

Fase 4: Verificación
7. [ ] @qa-engineer — Verificar cobertura cumple objetivos del proyecto
```

Adapta las fases a la complejidad real de la feature. Features simples pueden tener 2 fases; complejas pueden tener 5+.

### Definition of Done
Checklist de verificación final (copiar de FEAT-TEMPLATE.md y adaptar si necesario).

## Paso 2: Numeración

Busca en `docs/specs/` el último número de FEAT-XXX usado. Incrementa en 1.
Si no hay specs previos, empieza con FEAT-001.

Nombre del fichero: `FEAT-XXX-name-kebab-case.md`
Ejemplo: `docs/specs/FEAT-003-pictogram-search.md`

## Paso 3: Validación

Antes de dar por terminado, verifica:
- [ ] Todos los criterios de aceptación son verificables (no ambiguos)
- [ ] El diseño técnico cubre request, response y errores
- [ ] La sección de seguridad no está vacía (mínimo: validación de inputs)
- [ ] Si hay cambios de DB, la migración es reversible
- [ ] Los tests cubren al menos los criterios de aceptación
- [ ] El plan de implementación tiene pasos concretos con agentes asignados

## Paso 4: Siguiente paso

Indica al usuario:
1. **Revisar el spec** — ajustar criterios, diseño o plan si algo no encaja
2. **Implementar** — seguir el plan de implementación paso a paso, invocando los agentes en orden
3. Si usa Claude Code/OpenCode: "Puedes pedirle al agente que lea el spec antes de implementar: `Read docs/specs/FEAT-XXX-name.md and start with step 1 of the plan`"

## Notas para el LLM

- El spec debe ser **concreto**, no genérico. Usa nombres reales del proyecto (entidades, rutas, componentes).
- Consulta `project-context.md` para restricciones (accesibilidad, performance, privacidad).
- Consulta `decisions.md` para decisiones ya tomadas (no contradecirlas).
- Si el proyecto no tiene suficiente contexto (project-context vacío), pregunta al usuario.
- Máximo ~60-100 líneas por spec. Lo justo para ser útil sin ser un documento de 20 páginas.
- Si la feature es trivial (1 endpoint, 1 archivo), sugiere al usuario que no necesita spec.
- **El spec se genera en el idioma que prefiera el usuario.** Si no indica preferencia, usar el idioma de la conversación.
