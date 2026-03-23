# Ciclo de vida de un agente

[🇬🇧 Read in English](../agent-lifecycle.md)

> Volver al [README](../../README.es.md)

## Ciclo de vida de un agente

Los agentes son **efímeros**: nacen limpios, ejecutan su tarea y mueren. No tienen memoria entre sesiones.

```
El orquestador invoca al agente
       |
       v
  Nace limpio (carga solo su .md + skills relevantes)
       |
       v
  Ejecuta (trabaja con contexto mínimo)
       |
       v
  Reporta (devuelve resumen al orquestador)
       |
       v
  Muere (contexto descartado)
```

**Entrada:** El agente recibe del orquestador solo el contexto necesario para su tarea.
**Ejecución:** Carga sus Quality Gates y skills relevantes. No hereda contexto de otros agentes.
**Salida:** Devuelve un resumen. El orquestador decide el siguiente paso.

## Anti-patrón: el agente que hace todo

Un error común es usar un único agente para analizar, diseñar, implementar, testear y documentar. Esto falla porque:

- La ventana de contexto se llena al 80% antes de escribir la primera línea de código
- Los Quality Gates de diferentes roles pueden entrar en conflicto
- El agente empieza a alucinar cuando el contexto está saturado

**Regla:** Si la tarea requiere múltiples fases (diseño + implementación + testing), delega en sub-agentes especializados. Cada uno trabaja con contexto limpio.
