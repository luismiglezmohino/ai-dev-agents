# Prompt: Auditoría de código legacy

Pega este prompt en tu herramienta de IA cuando necesites analizar código legacy antes de modernizarlo.

---

Analiza el código legacy de este proyecto y genera un informe de modernización.

## Qué necesito que hagas

1. **Inventario**: Lista todas las tecnologías, frameworks, versiones y dependencias actuales.

2. **Riesgos**: Identifica:
   - Dependencias obsoletas o sin mantenimiento
   - Vulnerabilidades de seguridad conocidas
   - Código sin tests (zonas de riesgo)
   - Acoplamiento fuerte entre módulos
   - Patrones anti-clean architecture (lógica de negocio en controladores, entidades acopladas al ORM, etc.)

3. **Cobertura de tests actual**: ¿Qué porcentaje del código tiene tests? ¿Qué zonas críticas no están cubiertas?

4. **Plan de modernización**: Propón un plan paso a paso:
   - Fase 1: Escribir tests para el código existente (red de seguridad)
   - Fase 2: Refactorizar módulo por módulo (de menor a mayor riesgo)
   - Fase 3: Migrar a stack moderno (si aplica)
   - Para cada fase: agentes involucrados y skills necesarios

5. **Priorización**: Ordena por impacto/riesgo. ¿Qué modernizar primero?

## Formato de salida

Genera el informe en `docs/legacy-audit.md` con las secciones anteriores.

## Restricciones

- NO modifiques ningún código. Este prompt es solo de análisis.
- NO propongas reescribir todo desde cero. Moderniza incrementalmente.
- Sigue el Flujo 5 del orchestrator (código legacy) para la implementación posterior.
