return {
    -- Instrução do sistema
    system_instruction = "Você é um pesquisador literário especialista. Sua resposta deve estar APENAS no formato JSON válido. Certifique-se de que os dados sejam altamente precisos e pertençam estritamente ao contexto fornecido.",
    
    -- Seção especializada para Personagens e Figuras Históricas
    character_section = [[Livro: "%s" - Autor: %s
Progresso de Leitura: %d%%

TAREFA: Liste os 15-25 personagens mais importantes e 3-7 figuras históricas do mundo real.

REGRAS ESTRITAS:
1. NOMES FORMAIS: Use o nome formal completo do personagem (ex: "Abraham Van Helsing" em vez de "o Professor"). Use apelidos apenas se não existir um nome formal.
2. FIGURAS HISTÓRICAS: Você DEVE identificar pessoas do mundo real mencionadas (autores, reis, cientistas, etc.).
3. PROFUNDIDADE DO PERSONAGEM: Forneça uma análise abrangente (250-300 caracteres). Inclua sua história completa e papel ao longo de todo o livro até a marca de %d%%.
4. SEM SPOILERS: ABSOLUTAMENTE NENHUMA informação após a marca de %d%%.

FORMATO JSON REQUERIDO:
{
  "characters": [
    {
      "name": "Nome Formal Completo",
      "role": "Papel em %d%%",
      "gender": "Gênero",
      "occupation": "Profissão",
      "description": "Análise/história abrangente (250-300 caracteres). SEM SPOILERS."
    }
  ],
  "historical_figures": [
    {
      "name": "Nome Completo",
      "role": "Papel Histórico",
      "biography": "Biografia curta (MÁX 150 caracteres)",
      "importance_in_book": "Significado em %d%%",
      "context_in_book": "Contexto"
    }
  ]
}]],

    -- Seção especializada para Locais
    location_section = [[Livro: "%s" - Autor: %s
Progresso de Leitura: %d%%

TAREFA: Liste 5-10 locais significativos visitados ou mencionados até a marca de %d%%. 
PROCURE POR: Nomes de cidades, edifícios específicos, marcos históricos ou até mesmo salas recorrentes.

REGRAS:
1. SEM SPOILERS: Não mencione locais ou eventos que ocorram após a marca de %d%%.
2. CONCISÃO: As descrições devem ter no MÁXIMO 150 caracteres.

FORMATO JSON REQUERIDO:
{
  "locations": [
    {"name": "Local", "description": "Desc curta (MÁX 150 caracteres)", "importance": "Significado em %d%%"}
  ]
}]],

    -- Seção especializada para Cronologia (Timeline)
    timeline_section = [[Livro: "%s" - Autor: %s
Progresso de Leitura: %d%%

TAREFA: Crie uma linha do tempo cronológica dos principais eventos narrativos até a marca de %d%%.

REGRAS ESTRITAS:
1. COBERTURA: Forneça EXATAMENTE UM destaque principal para CADA capítulo narrativo até a marca de %d%%.
2. SEM AGRUPAMENTO: NÃO combine vários capítulos em um único evento.
3. SEM DUPLICATAS: NÃO forneça mais de um evento para o mesmo capítulo.
4. EXCLUSÃO: IGNORE Prefácios, Sumários, "Outras obras de" ou Apêndices.
5. BREVIDADE: Cada descrição de evento deve ter no MÁXIMO 120 caracteres.
6. SEM SPOILERS: Pare exatamente na marca de %d%%.

FORMATO JSON REQUERIDO:
{
  "timeline": [
    {"event": "Evento narrativo principal (MÁX 120 caracteres)", "chapter": "Nome/Número do Capítulo"}
  ]
}]],

    -- Prompt apenas do autor (Para busca rápida de biografia)
    author_only = [[Identifique e forneça a biografia do autor do livro "%s". 
Os metadados sugerem que o autor é "%s", mas verifique isso com base no título do livro.

FORMATO JSON REQUERIDO:
{
  "author": "Nome Completo Correto",
  "author_bio": "Biografia abrangente focada em sua carreira literária e principais obras.",
  "author_birth": "Data de Nascimento",
  "author_death": "Data de Falecimento"
}]],

    -- Busca Abrangente Única (Personagens, Locais e Cronologia combinados)
    comprehensive_xray = [[Livro: "%s" - Autor: %s
Progresso de Leitura: %d%%

TAREFA: Forneça uma análise X-Ray abrangente do livro até a marca de %d%%.

1. CRONOLOGIA (PRIORIDADE MÁXIMA):
- Você receberá uma "LISTA DE CAPÍTULOS" numerada abaixo; esta é sua chave principal para listagens exclusivas.
- OBRIGATÓRIO: Seu array de linha do tempo DEVE ter EXATAMENTE UMA entrada para cada um dos capítulos numerados fornecidos.
- NÃO forneça múltiplos eventos para um único capítulo.
- NÃO combine capítulos. 
- NÃO pule capítulos. 
- Use o contexto de "AMOSTRAS DE CAPÍTULOS" para resumir cada capítulo.
- Cada descrição de evento deve ter no MÁXIMO 200 caracteres.
- Seu array de linha do tempo DEVE estar na ordem cronológica EXATA da lista de capítulos fornecida.
- EXCLUSÃO: IGNORE Prefácios, Sumários, "Outras obras de" ou Apêndices.

2. PERSONAGENS E FIGURAS:
- Liste os 15-25 personagens mais importantes. Use nomes formais completos. Ordene por importância/frequência no livro, com o mais importante primeiro.
- Liste 3-7 figuras históricas do mundo real mencionadas.
- Forneça uma análise profunda para cada (250-300 caracteres), cobrindo sua história/papel neste livro até %d%%.

3. LOCAIS:
- Liste 5-10 locais significativos (cidades, edifícios, marcos).
- Descrições concisas (MÁX 150 caracteres).

REGRAS ESTRITAS:
- SEM SPOILERS: Pare toda a análise e informação exatamente na marca de %d%%.
- FORMATO: Retorne APENAS JSON válido.

FORMATO JSON REQUERIDO:
{
  "timeline": [
    {"event": "Eventos narrativos principais deste capítulo (MÁX 200 caracteres)", "chapter": "Título Exato do Capítulo da Lista"}
  ],
  "characters": [
    {
      "name": "Nome Completo",
      "role": "Papel em %d%%",
      "gender": "Gênero",
      "occupation": "Profissão",
      "description": "Análise profunda (250-300 caracteres). SEM SPOILERS."
    }
  ],
  "historical_figures": [
    {
      "name": "Nome Completo",
      "role": "Papel Histórico",
      "biography": "Biografia (MÁX 150 caracteres)",
      "importance_in_book": "Significado em %d%%",
      "context_in_book": "Contexto"
    }
  ],
  "locations": [
    {"name": "Local", "description": "Desc curta (MÁX 150 caracteres)", "importance": "Significado em %d%%"}
  ]
}]],

    -- Strings de reserva (Fallback)
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
