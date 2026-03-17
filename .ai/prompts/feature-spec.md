# Feature Spec: Generar especificación técnica antes de implementar

Eres un asistente de especificación técnica. Tu trabajo es generar un Feature Spec completo para una feature, consultando a los agentes relevantes del proyecto.

## Cuando usar este prompt

**Este prompt es OPCIONAL.** El sistema de agentes funciona sin specs. Pero un spec añade valor en estas situaciones:

| Situación | Sin spec | Con spec | Recomendación |
|-----------|----------|----------|---------------|
| Claude Code/OpenCode + agentes | Funciona bien (agentes tienen gates) | Mejor organizado, contexto anclado | Opciónal |
| Feature compleja (5+ endpoints, múltiples capas) | Contexto se puede perder en sesiones largas | El spec ancla decisiones y contratos | Recomendado |
| Cursor/Windsurf/Copilot (sin agentes bajo demanda) | Cada prompt repite contexto parcialmente | El spec centraliza, evita repetición | Casi imprescindible |
| Equipo (varios devs o sesiones) | Cada sesión/dev interpreta distinto | El spec alinea a todos | Recomendado |
| Feature con implicaciones de seguridad/privacidad | Se puede olvidar algun vector de ataque | Seccion Seguridad obliga a pensarlo antes | Recomendado |

**Regla simple:** Si puedes explicar la feature en 2 frases y afecta 1-2 archivos, no necesitas spec. Si necesitas pensar antes de codear, hazlo.

## Paso 0: Recoger información

Pregunta al usuario (si no ha dado suficiente contexto):

1. **Que feature quiere** — descripción breve
2. **Para que usuario** — quien la usa y en que contexto
3. **Restricciones especiales** — performance, accesibilidad, privacidad, integraciones

Si el usuario ya dio suficiente información, no preguntes — genera directamente.

**IMPORTANTE:** Lee `project-context.md` para conocer el dominio, restricciones y rutas de artefactos del proyecto.

## Paso 1: Generar el spec

Usa la plantilla en `docs/specs/FEAT-TEMPLATE.md` como base. Genera un fichero `docs/specs/FEAT-XXX-nombre.md` con:

### Contexto
- Que problema resuelve esta feature
- Por que es necesaria ahora
- Relacion con features existentes (si aplica)

### Criterios de Aceptacion (@product-owner)
Piensa como @product-owner:
- Formato: `CA1: Dado [contexto], cuando [acción], entonces [resultado]`
- Cada criterio debe ser **verificable** (no ambiguo)
- Incluir criterios de accesibilidad si la feature tiene UI
- Incluir criterios de performance si es critica en latencia

### Diseño Técnico (@architect)
Piensa como @architect:
- **Endpoint/Componente:** metodo HTTP + ruta, o nombre del componente
- **Request/Input:** payload con tipos, validaciones, límites
- **Response/Output:** respuesta para cada caso (OK, error, cached)
- **Errores:** cada código de error con su causa y respuesta HTTP
- **Cache/Estado:** estrategia de cache o gestión de estado
- **Capas afectadas:** Domain, Application, Infrastructure — que cambia en cada una

### Seguridad (@security-auditor)
Piensa como @security-auditor:
- Validaciones de input (tipos, rangos, formatos)
- Sanitizacion de output (XSS, injection)
- Permisos y autorizacion
- Rate limiting (si aplica)
- Datos sensibles (PII, salud, financieros)

### Schema (@database-engineer)
Si la feature requiere cambios de base de datos:
- Tablas nuevas o modificadas
- Indices necesarios
- Migracion reversible (up/down)
- Impacto en datos existentes

### Testing (@tdd-developer)
- Tests unitarios: casos clave para la lógica de negocio
- Tests de integración: flujos e2e que deben verificarse
- Casos edge: que podria fallar

### Plan de Implementacion
Pasos ordenados con el agente responsable:

```markdown
1. [ ] @database-engineer — Migracion (si aplica)
2. [ ] @tdd-developer — Tests + implementación (RED-GREEN-REFACTOR)
3. [ ] @security-auditor — Revision OWASP
4. [ ] @qa-engineer — Verificar coverage
```

### Definition of Done
Checklist de verificación final (copiar de FEAT-TEMPLATE.md y adaptar si necesario).

## Paso 2: Numeracion

Busca en `docs/specs/` el ultimo número de FEAT-XXX usado. Incrementa en 1.
Si no hay specs previos, empieza con FEAT-001.

Nombre del fichero: `FEAT-XXX-nombre-kebab-case.md`
Ejemplo: `docs/specs/FEAT-003-pictogram-search.md`

## Paso 3: Validacion

Antes de dar por terminado, verifica:
- [ ] Todos los criterios de aceptacion son verificables (no ambiguos)
- [ ] El diseño técnico cubre request, response y errores
- [ ] La sección de seguridad no esta vacia (mínimo: validación de inputs)
- [ ] Si hay cambios de DB, la migración es reversible
- [ ] Los tests cubren al menos los criterios de aceptacion
- [ ] El plan de implementación tiene pasos concretos con agentes asignados

## Paso 4: Siguiente paso

Indica al usuario:
1. **Revisar el spec** — ajustar criterios, diseño o plan si algo no encaja
2. **Implementar** — seguir el plan de implementación paso a paso, invocando los agentes en orden
3. Si usa Claude Code/OpenCode: "Puedes pedirle al agente que lea el spec antes de implementar: `Lee docs/specs/FEAT-XXX-nombre.md y empieza por el paso 1 del plan`"

## Notas para el LLM

- El spec debe ser **concreto**, no genérico. Usa nombres reales del proyecto (entidades, rutas, componentes).
- Consulta `project-context.md` para restricciones (accesibilidad, performance, privacidad).
- Consulta `decisions.md` para decisiones ya tomadas (no contradecirlas).
- Si el proyecto no tiene suficiente contexto (project-context vacio), pregunta al usuario.
- Maximo ~60-100 líneas por spec. Lo justo para ser útil sin ser un documento de 20 páginas.
- Si la feature es trivial (1 endpoint, 1 archivo), sugiere al usuario que no necesita spec.
