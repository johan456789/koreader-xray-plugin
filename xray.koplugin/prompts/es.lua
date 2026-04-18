return {
    -- Instrucción del sistema
    system_instruction = "Eres un experto investigador literario. Tu respuesta debe estar ÚNICAMENTE en formato JSON válido. Asegúrate de que los datos sean altamente precisos y pertenezcan estrictamente al contexto proporcionado.",
    
    -- Sección especializada para Personajes y Figuras Históricas
    character_section = [[Libro: "%s" - Autor: %s
Progreso de lectura: %d%%

TAREA: Enumera los 15-25 personajes más importantes y de 3 a 7 figuras históricas del mundo real.

REGLAS ESTRICTAS:
1. NOMBRES FORMALES: Usa el nombre formal completo del personaje (ej. "Abraham Van Helsing" en lugar de "el Profesor"). Solo usa apodos si no existe un nombre formal.
2. FIGURAS HISTÓRICAS: DEBES identificar personas del mundo real mencionadas (autores, reyes, científicos, etc.).
3. PROFUNDIDAD DEL PERSONAJE: Proporciona un análisis exhaustivo (250-300 caracteres). Abarca su historia completa y su papel a lo largo de todo el libro hasta la marca del %d%%.
4. SIN SPOILERS: ABSOLUTAMENTE NINGUNA información posterior a la marca del %d%%.

FORMATO JSON REQUERIDO:
{
  "characters": [
    {
      "name": "Nombre Formal Completo",
      "role": "Papel al %d%%",
      "gender": "Género",
      "occupation": "Trabajo",
      "description": "Análisis/historia exhaustiva (250-300 caracteres). SIN SPOILERS."
    }
  ],
  "historical_figures": [
    {
      "name": "Nombre Completo",
      "role": "Papel Histórico",
      "biography": "Biografía breve (MÁX 150 caracteres)",
      "importance_in_book": "Importancia al %d%%",
      "context_in_book": "Contexto"
    }
  ]
}]],

    -- Sección especializada para Ubicaciones
    location_section = [[Libro: "%s" - Autor: %s
Progreso de lectura: %d%%

TAREA: Enumera de 5 a 10 ubicaciones significativas visitadas o mencionadas hasta la marca del %d%%. 
BUSCA: Nombres de ciudades, edificios específicos, monumentos o incluso habitaciones recurrentes.

REGLAS:
1. SIN SPOILERS: No menciones ubicaciones o eventos que ocurran después de la marca del %d%%.
2. CONCISIÓN: Las descripciones deben tener un MÁXIMO de 150 caracteres.

FORMATO JSON REQUERIDO:
{
  "locations": [
    {"name": "Lugar", "description": "Descripción breve (MÁX 150 caracteres)", "importance": "Importancia al %d%%"}
  ]
}]],

    -- Sección especializada para la Línea de Tiempo
    timeline_section = [[Libro: "%s" - Autor: %s
Progreso de lectura: %d%%

TAREA: Crea una línea de tiempo cronológica de los eventos narrativos clave hasta la marca del %d%%.

REGLAS ESTRICTAS:
1. COBERTURA: Proporciona EXACTAMENTE UN punto destacado clave para CADA capítulo narrativo hasta la marca del %d%%.
2. SIN AGRUPAR: NO combines varios capítulos en un solo evento.
3. SIN DUPLICADOS: NO proporciones más de un evento para el mismo capítulo.
4. EXCLUSIÓN: IGNORA preliminares, índice, "otras obras de" o apéndices.
5. BREVEDAD: Cada descripción de evento debe tener un MÁXIMO de 120 caracteres.
6. SIN SPOILERS: Detente exactamente en la marca del %d%%.

FORMATO JSON REQUERIDO:
{
  "timeline": [
    {"event": "Evento narrativo clave (MÁX 120 caracteres)", "chapter": "Nombre/Número del capítulo"}
  ]
}]],

    -- Mensaje solo para el autor (Para búsqueda rápida de biografía)
    author_only = [[Identifica y proporciona una biografía del autor del libro "%s". 
Los metadatos sugieren que el autor es "%s", pero verifícalo basándote en el título del libro.

FORMATO JSON REQUERIDO:
{
  "author": "Nombre Completo Correcto",
  "author_bio": "Biografía exhaustiva centrada en su carrera literaria y obras principales.",
  "author_birth": "Fecha de nacimiento",
  "author_death": "Fecha de fallecimiento"
}]],

    -- Obtención integral única (Personajes, ubicaciones y línea de tiempo combinados)
    comprehensive_xray = [[Libro: "%s" - Autor: %s
Progreso de lectura: %d%%

TAREA: Proporciona un análisis X-Ray exhaustivo del libro hasta la marca del %d%%.

1. LÍNEA DE TIEMPO (MÁXIMA PRIORIDAD):
- Se te proporcionará una "LISTA DE CAPÍTULOS" numerada a continuación; esta es tu clave principal para listados únicos.
- OBLIGATORIO: Tu matriz de línea de tiempo DEBE tener EXACTAMENTE UNA entrada para cada uno de los capítulos numerados proporcionados.
- NO proporciones múltiples eventos para un capítulo.
- NO combines capítulos. 
- NO te saltes capítulos. 
- Usa el contexto de "MUESTRAS DE CAPÍTULOS" para resumir cada capítulo.
- Cada descripción de evento debe tener un MÁXIMO de 200 caracteres.
- Tu matriz de línea de tiempo DEBE estar en el orden cronológico EXACTO de la lista de capítulos proporcionada.
- EXCLUSIÓN: IGNORA preliminares, índice, "otras obras de" o apéndices.

2. PERSONAJES Y FIGURAS:
- Enumera los 15-25 personajes más importantes. Usa nombres formales completos. Ordena por importancia/frecuencia en el libro, con el más importante primero.
- Enumera de 3 a 7 figuras históricas del mundo real mencionadas.
- Proporciona un análisis profundo de cada uno (250-300 caracteres), cubriendo su historia/papel en este libro hasta el %d%%.

3. UBICACIONES:
- Enumera de 5 a 10 ubicaciones significativas (ciudades, edificios, monumentos).
- Descripciones concisas (MÁX 150 caracteres).

REGLAS ESTRICTAS:
- SIN SPOILERS: Detén todo análisis e información exactamente en la marca del %d%%.
- FORMATO: Devuelve ÚNICAMENTE JSON válido.

FORMATO JSON REQUERIDO:
{
  "timeline": [
    {"event": "Eventos narrativos clave de este capítulo (MÁX 200 caracteres)", "chapter": "Título exacto del capítulo de la lista"}
  ],
  "characters": [
    {
      "name": "Nombre Completo",
      "role": "Papel al %d%%",
      "gender": "Género",
      "occupation": "Trabajo",
      "description": "Análisis profundo (250-300 caracteres). SIN SPOILERS."
    }
  ],
  "historical_figures": [
    {
      "name": "Nombre Completo",
      "role": "Papel Histórico",
      "biography": "Bio (MÁX 150 caracteres)",
      "importance_in_book": "Importancia al %d%%",
      "context_in_book": "Contexto"
    }
  ],
  "locations": [
    {"name": "Lugar", "description": "Descripción breve (MÁX 150 caracteres)", "importance": "Importancia al %d%%"}
  ]
}]],

    -- Cadenas de respaldo
    fallback = {
        unknown_book = "Libro desconocido",
        unknown_author = "Autor desconocido",
        unnamed_character = "Personaje sin nombre",
        not_specified = "No especificado",
        no_description = "Sin descripción",
        unnamed_person = "Persona sin nombre",
        no_biography = "Biografía no disponible"
    }
}
