# Prompt: Auditoría de código legacy

[🇬🇧 Read in English](../legacy-audit.md)


Pega este prompt en tu herramienta de IA cuando necesites analizar código legacy antes de modernizarlo.

---

Analiza el código legacy de este proyecto y genera un informe de modernización.

## Qué necesito que hagas

1. **Inventory**: Lista todas las tecnologías, frameworks, versiones y dependencias actuales.

2. **Risks**: Identifica:
   - Dependencias obsoletas o sin mantenimiento
   - Vulnerabilidades de seguridad conocidas
   - Código sin tests (zonas de riesgo)
   - Acoplamiento fuerte entre módulos
   - Patrones anti-clean architecture (lógica de negocio en controladores, entidades acopladas al ORM, etc.)

3. **Current test coverage**: ¿Qué porcentaje del código tiene tests? ¿Qué zonas críticas no están cubiertas?

4. **Modernization plan**: Propón un plan paso a paso:
   - Phase 1: Write tests for existing code (safety net)
   - Phase 2: Refactor module by module (lowest to highest risk)
   - Phase 3: Migrate to modern stack (if applicable)
   - For each phase: involved agents and required skills

5. **Prioritization**: Ordena por impacto/riesgo. ¿Qué modernizar primero?

## Formato de salida

Genera el informe en `docs/legacy-audit.md` con las secciones anteriores.

## Restricciones

- NO modifiques ningún código. Este prompt es solo de análisis.
- NO propongas reescribir todo desde cero. Moderniza incrementalmente.
- Sigue el Flujo 5 del orchestrator (código legacy) para la implementación posterior.
