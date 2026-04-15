return {
    -- System instruction
    system_instruction = "Eres un experto crítico literario e investigador. Tu respuesta debe estar ÚNICAMENTE en formato JSON válido. No incluyas ningún texto fuera de la estructura JSON. Asegúrate de que los datos sean altamente precisos y se refieran estrictamente al libro especificado.",
    
    -- Main prompt (Full book analysis)
    main = [[Libro: "%s" - Autor: %s
Crea datos detallados de X-Ray para este libro. Completa el formato JSON a continuación TOTALMENTE.

REGLAS PRINCIPALES:
1. SOLO incluye datos de ESTE libro. Usa el título, autor y nombre de archivo proporcionados para asegurarte de analizar la obra correcta.
2. PERSONAJES: Enumera al menos 15-20 personajes. Incluye a todos los protagonistas, personajes secundarios importantes y figuras menores notables.
3. UBICACIONES: Enumera al menos 10-15 ubicaciones significativas descritas en el libro.
4. FIGURAS HISTÓRICAS: Identifica al menos 5-10 figuras históricas del mundo real mencionadas o relevantes para el entorno. Si es un mundo ficticio, enumera figuras legendarias o históricas importantes de la historia de ese mundo.
5. DETALLES: Proporciona descripciones ricas y fácticas. Evita generalizaciones vagas.
6. JSON: La salida DEBE ser un único objeto JSON válido.

FORMATO JSON REQUERIDO:
{
  "book_title": "Título completo del libro",
  "author": "Nombre del autor",
  "author_bio": "Biografía detallada del autor, centrándose en su estilo y esta obra específica.",
  "summary": "Resumen completo de la premisa y la trama del libro (Sin spoilers).",
  "characters": [
    {
      "name": "Nombre del personaje",
      "role": "Protagonista / Secundario / Antagonista",
      "gender": "Masculino / Femenino / Otro",
      "occupation": "Estado o trabajo",
      "description": "Análisis detallado del personaje de 3-4 frases, incluyendo personalidad e importancia."
    }
  ],
  "historical_figures": [
    {
      "name": "Nombre de la figura",
      "role": "Rol histórico",
      "biography": "Biografía corta",
      "importance_in_book": "Por qué se mencionan en este libro específico",
      "context_in_book": "La escena o discusión específica donde aparecen"
    }
  ],
  "locations": [
    {"name": "Nombre de la ubicación", "description": "Descripción visual y atmosférica", "importance": "Significancia narrativa"}
  ],
  "themes": ["Tema detallado 1", "Tema detallado 2", "Tema detallado 3", "Tema detallado 4", "Tema detallado 5"],
  "timeline": [
    {"event": "Punto clave de la trama", "chapter": "Nombre/Número del capítulo", "importance": "Por qué esto es importante para la historia"}
  ]
}]],

    -- Spoiler-free prompt (Based on reading progress)
    spoiler_free = [[Libro: "%s" - Autor: %s
CRÍTICO: El lector solo ha leído el %d%% de este libro. DEBES proporcionar datos de X-Ray que cubran ÚNICAMENTE el contenido hasta este punto.

REGLAS ESTRICTAS CONTRA SPOILERS:
1. NO incluyas personajes que se presenten DESPUÉS de la marca del %d%%.
2. NO incluyas eventos de la trama, giros o muertes que ocurran DESPUÉS de la marca del %d%%.
3. NO reveles desarrollos de personajes o revelaciones de identidad que sucedan DESPUÉS de la marca del %d%%.
4. El "resumen" y la "línea de tiempo" deben detenerse exactamente en el punto del %d%%.
5. Las "descripciones" de los personajes solo deben reflejar su estado y conocimiento en el punto del %d%%.

REGLAS DE CONTEO DE ELEMENTOS:
1. PERSONAJES: Enumera 10-15 personajes encontrados hasta este punto.
2. UBICACIONES: Enumera 8-12 ubicaciones visitadas o mencionadas hasta este punto.
3. LÍNEA DE TIEMPO: Enumera 8-12 eventos importantes que ya hayan ocurrido.

FORMATO JSON REQUERIDO:
{
  "book_title": "Título del libro",
  "author": "Nombre del autor",
  "author_bio": "Biografía",
  "summary": "Resumen de ÚNICAMENTE la parte leída hasta ahora (%d%%)",
  "characters": [
    {
      "name": "Nombre",
      "role": "Rol percibido actual",
      "gender": "Género",
      "occupation": "Ocupación actual",
      "description": "Estado del personaje EXACTAMENTE en la marca del %d%%. NO reveles secretos futuros."
    }
  ],
  "historical_figures": [
    {
      "name": "Nombre",
      "role": "Rol",
      "biography": "Bio",
      "importance_in_book": "Significancia hasta ahora",
      "context_in_book": "Contexto de la mención"
    }
  ],
  "locations": [
    {"name": "Nombre", "description": "Descripción", "importance": "Significancia hasta ahora"}
  ],
  "themes": ["Temas evidentes hasta este punto"],
  "timeline": [
    {"event": "Evento que YA sucedió", "chapter": "Capítulo", "importance": "Significancia"}
  ]
}]],

    -- Fallback strings
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
