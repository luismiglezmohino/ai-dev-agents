# Refinar Skills: Actualizar skills con patrones reales del proyecto

Eres el @technical-writer. Tu trabajo es analizar el código ya implementado en este proyecto y refinar los skills en `.ai/skills/` para que reflejen los patrones REALES, no best practices genéricas.

## Cuando usar este prompt

Después de implementar 2-3 features. En ese punto ya hay suficiente código para extraer patrones reales.

## Paso 1: Analisis del código existente

Para CADA skill en `.ai/skills/`:

1. Identifica la tecnologia del skill (ej: `vue`, `symfony`, `postgresql`).
2. Busca archivos del proyecto que usen esa tecnologia:
   - Código fuente (componentes, controladores, entidades, migraciones, tests, etc.)
   - Configuracion (configs, env, docker, CI/CD)
3. Extrae los patrones que se REPITEN en el código:
   - Estructura de archivos (donde se pone cada cosa)
   - Naming real (como se nombran clases, metodos, variables, archivos)
   - Patrones de código (como se hacen los tests, como se estructuran los componentes, como se manejan errores)
   - Dependencias internas (que librerias/helpers usa el proyecto)
   - Configuracion especifica (que plugins, que reglas de lint, que opciones de compilación)
4. Analiza `git log --oneline -30` para detectar:
   - Patrones que evolucionaron (refactors, renombrados)
   - Errores recurrentes (commits de fix consecutivos)
   - Convenciones de commits que se usan

**IMPORTANTE:** No inventes patrones. Si solo hay 1 ejemplo de algo, no es un patrón. Necesitas al menos 2-3 repeticiones.

## Paso 2: Comparacion con skill actual

Para cada skill, compara:

| Aspecto | Skill actual (genérico) | Código real |
|---------|------------------------|-------------|
| Patrones | [lo que dice el skill] | [lo que hace el código] |
| Convenciones | [lo que dice el skill] | [lo que hace el código] |
| Testing | [lo que dice el skill] | [lo que hace el código] |
| Errores comunes | [lo que dice el skill] | [errores encontrados en el código o git log] |

Si el skill actual dice algo que el proyecto NO hace, **elimina o adapta** esa sección.
Si el proyecto hace algo que el skill NO menciona, **anade** esa sección.

## Paso 3: Reescribir el skill

Reescribe el skill con el formato actualizado:

```markdown
# Skill: [Nombre]

## Version

[Version REAL usada en el proyecto, extraida de package.json/composer.json]

## Patrones del Proyecto

[Patrones extraidos del código REAL. Cada patrón con:]
[1. Nombre del patrón]
[2. Ejemplo REAL del proyecto (no inventado)]
[3. Por que se usa asi]

## Convenciones

[Convenciones REALES extraidas del código:]
[- Naming de archivos, clases, metodos]
[- Estructura de carpetas]
[- Imports/exports]

## Testing

[Como se testea REALMENTE en el proyecto:]
[- Framework y configuración real]
[- Patrón de test usado (ejemplo real)]
[- Mocks/fixtures que se usan]

## Ejemplo de output esperado

[Muestra un ejemplo REAL del proyecto de cómo debe quedar el código generado por este skill. Un fragmento que sirva de referencia para la IA:]

```
// Ejemplo real del proyecto — la IA debe generar código que siga este estilo
[código real extraído del proyecto]
```

> Un ejemplo vale más que tres párrafos de explicación.

## Errores Conocidos

[Errores que ya ocurrieron en el proyecto o que son específicos de esta configuración]

## Checklist

- [ ] [Verificaciones especificas del proyecto]

## Referencias

- [Documentación oficial](url)
- [Archivos de referencia en el proyecto](ruta relativa)
```

**Reglas de reescritura:**
- ELIMINA el aviso `> REVISAR: Este skill fue generado automáticamente...` — ya no es genérico.
- Los ejemplos deben ser del PROYECTO, no de la documentación oficial.
- Anade una sección `## Archivos de referencia` con rutas a archivos del proyecto que sirvan de ejemplo.
- Si un patrón del skill genérico no se usa en el proyecto, eliminalo.
- Si descubres un patrón que no estaba en el skill, anadelo.

## Paso 4: Nuevos skills

Si durante el analisis detectas tecnologias/patrones que NO tienen skill:

1. Lista las tecnologias sin skill.
2. Genera un skill nuevo para cada una siguiendo el mismo formato.
3. Estos SI llevan el aviso `> REVISAR` porque aun no estan validados con uso real.

## Paso 5: Actualizar CLAUDE.md

Si se crearon skills nuevos en el Paso 4, actualiza la sección `## Skills` de `CLAUDE.md` para que liste los nuevos skills.

## Paso 6: Resumen

Al terminar, muestra:

```
Skills refinados:
- {nombre}: [que cambio respecto al genérico]
- ...

Skills nuevos creados:
- {nombre}: [que cubre]
- ...

Skills sin cambios (el genérico era correcto):
- {nombre}
- ...

Proxima revisión recomendada: después de [X] features mas.
```

## Notas para el LLM

- Este prompt asume que hay código implementado. Si no hay suficiente código, indicalo y sugiere volver después de más features.
- No fuerces patrones. Si el proyecto es inconsistente en algo, senalalo como "Inconsistencia detectada" en vez de inventar un patrón.
- Los skills refinados reemplazan a los genéricos — sobreescribe el archivo.
- Maximo ~60-80 líneas por skill. Lo justo para ser útil sin ser un manual.
- Incluye rutas relativas a archivos del proyecto como ejemplos vivos (ej: `ver backend/src/Domain/User/User.php`).
