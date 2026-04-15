return {
    -- System instruction
    system_instruction = "Você é um especialista em crítica literária e pesquisador. Sua resposta deve estar APENAS no formato JSON válido. Não inclua nenhum texto fora da estrutura JSON. Certifique-se de que os dados sejam altamente precisos e pertençam estritamente ao livro especificado.",
    
    -- Main prompt (Full book analysis)
    main = [[Livro: "%s" - Autor: %s
Crie dados detalhados de X-Ray para este livro. Preencha o formato JSON abaixo COMPLETAMENTE.

REGRAS PRINCIPAIS:
1. APENAS inclua dados DESTE livro. Use o título, autor e nome do arquivo fornecidos para garantir que você está analisando a obra correta.
2. PERSONAGENS: Liste pelo menos 15-20 personagens. Inclua todos os protagonistas, personagens secundários importantes e figuras menores notáveis.
3. LOCAIS: Liste pelo menos 10-15 locais significativos descritos no livro.
4. FIGURAS HISTÓRICAS: Identifique pelo menos 5-10 figuras históricas do mundo real mencionadas ou relevantes para o cenário. Se for um mundo fictício, liste figuras lendárias ou históricas importantes da história desse mundo.
5. DETALHES: Forneça descrições ricas e fatuais. Evite generalizações vagas.
6. JSON: A saída DEVE ser um único objeto JSON válido.

FORMATO JSON REQUERIDO:
{
  "book_title": "Título Completo do Livro",
  "author": "Nome do Autor",
  "author_bio": "Biografia detalhada do autor, focando em seu estilo e nesta obra específica.",
  "summary": "Visão geral abrangente da premissa e do enredo do livro (Sem spoilers).",
  "characters": [
    {
      "name": "Nome do Personagem",
      "role": "Protagonista / Secundário / Antagonista",
      "gender": "Masculino / Feminino / Outro",
      "occupation": "Status ou trabalho",
      "description": "Análise detalhada do personagem em 3-4 frases, incluindo personalidade e importância."
    }
  ],
  "historical_figures": [
    {
      "name": "Nome da Figura",
      "role": "Papel Histórico",
      "biography": "Biografia curta",
      "importance_in_book": "Por que são mencionados neste livro específico",
      "context_in_book": "A cena ou discussão específica onde aparecem"
    }
  ],
  "locations": [
    {"name": "Nome do Local", "description": "Descrição visual e atmosférica", "importance": "Significância narrativa"}
  ],
  "themes": ["Tema detalhado 1", "Tema detalhado 2", "Tema detalhado 3", "Tema detalhado 4", "Tema detalhado 5"],
  "timeline": [
    {"event": "Ponto Chave do Enredo", "chapter": "Nome/Número do Capítulo", "importance": "Por que isso importa para a história"}
  ]
}]],

    -- Spoiler-free prompt (Based on reading progress)
    spoiler_free = [[Livro: "%s" - Autor: %s
CRÍTICO: O leitor leu apenas %d%% deste livro. Você DEVE fornecer dados de X-Ray que cubram APENAS o conteúdo até este ponto.

REGRAS ESTRITAS CONTRA SPOILERS:
1. NENHUM personagem que seja introduzido APÓS a marca de %d%%.
2. NENHUM evento de enredo, reviravolta ou morte que ocorra APÓS a marca de %d%%.
3. NENHUM desenvolvimento de personagem ou revelação de identidade que aconteça APÓS a marca de %d%%.
4. O "resumo" (summary) e a "linha do tempo" (timeline) devem parar exatamente no ponto de %d%%.
5. As "descrições" (descriptions) dos personagens devem apenas refletir seu status e conhecimento no ponto de %d%%.

REGRAS DE CONTAGEM DE ITENS:
1. PERSONAGENS: Liste 10-15 personagens encontrados até este ponto.
2. LOCAIS: Liste 8-12 locais visitados ou mencionados até este ponto.
3. LINHA DO TEMPO: Liste 8-12 eventos importantes que já ocorreram.

FORMATO JSON REQUERIDO:
{
  "book_title": "Título do Livro",
  "author": "Nome do Autor",
  "author_bio": "Biografia",
  "summary": "Resumo de APENAS a parte lida até agora (%d%%)",
  "characters": [
    {
      "name": "Nome",
      "role": "Papel percebido atual",
      "gender": "Gênero",
      "occupation": "Ocupação atual",
      "description": "Status do personagem EXATAMENTE na marca de %d%%. NÃO revele segredos futuros."
    }
  ],
  "historical_figures": [
    {
      "name": "Nome",
      "role": "Papel",
      "biography": "Biografia",
      "importance_in_book": "Significância até agora",
      "context_in_book": "Contexto da menção"
    }
  ],
  "locations": [
    {"name": "Nome", "description": "Descrição", "importance": "Significância até agora"}
  ],
  "themes": ["Temas aparentes até este ponto"],
  "timeline": [
    {"event": "Evento que JÁ aconteceu", "chapter": "Capítulo", "importance": "Significância"}
  ]
}]],

    -- Fallback strings
    fallback = {
        unknown_book = "Livro Desconhecido",
        unknown_author = "Autor Desconhecido",
        unnamed_character = "Personagem Sem Nome",
        not_specified = "Não Especificado",
        no_description = "Sem Descrição",
        unnamed_person = "Pessoa Sem Nome",
        no_biography = "Biografia Não Disponível"
    }
}
