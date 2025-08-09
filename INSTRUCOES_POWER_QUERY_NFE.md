# Consulta Power Query para Leitura Massiva de Arquivos XML NFe

## Objetivo
Esta solução permite importar e analisar múltiplos arquivos XML de Notas Fiscais Eletrônicas (NFe) de um diretório, extraindo automaticamente os dados principais para conferência massiva.

## Arquivos Disponíveis

### 1. NFe_PowerQuery_Consulta.m
**Versão Completa** - Extrai dados detalhados incluindo:
- Número e série da NFe
- Data de emissão
- CNPJ e nome do emitente
- CNPJ/CPF e nome do destinatário
- Valores totais, produtos, ICMS e IPI
- Status do processamento

### 2. NFe_PowerQuery_Versao_Simplificada.m
**Versão Simplificada** - Mais robusta para diferentes estruturas XML:
- Número e série da NFe
- Data de emissão
- CNPJ do emitente
- Valores total e de produtos
- Status do processamento

## Como Implementar no Excel

### Passo 1: Preparar os Arquivos
1. Organize todos os arquivos XML de NFe em um diretório específico
2. Anote o caminho completo do diretório (ex: `C:\Arquivos_NFe\`)

### Passo 2: Abrir Power Query no Excel
1. Abra o Excel
2. Vá para a aba **Dados**
3. Clique em **Obter Dados** > **Consulta em Branco**

### Passo 3: Implementar a Consulta
1. No Editor do Power Query, clique em **Editor Avançado**
2. Copie e cole o código de uma das consultas (.m)
3. **IMPORTANTE**: Altere o caminho na linha:
   ```m
   CaminhoArquivos = "C:\Arquivos_NFe\",
   ```
   Substitua pelo caminho real dos seus arquivos XML

### Passo 4: Executar e Validar
1. Clique em **Concluído** no Editor Avançado
2. O Power Query processará todos os arquivos automaticamente
3. Verifique se os dados foram extraídos corretamente
4. Clique em **Fechar e Carregar** para importar para o Excel

## Personalização da Consulta

### Adicionar Novos Campos
Para extrair campos adicionais, modifique a seção de extração:

```m
// Exemplo: Adicionar natureza da operação
NaturezaOp = List.Select(InfoIde, each [Name] = "natOp"){0}[Children]{0}[Value],

// E incluir no resultado:
NaturezaOperacao = NaturezaOp,
```

### Filtrar por Período
Adicione filtro de data após a extração:

```m
// Filtrar NFe dos últimos 30 dias
DataFiltrada = Table.SelectRows(TiposDefinidos, 
    each [DataEmissao] >= Date.AddDays(DateTime.Date(DateTime.LocalNow()), -30))
```

### Alterar Formato de Números
Modifique a seção de tipos para diferentes formatos:

```m
{"ValorTotalNF", Currency.Type},  // Para formato moeda
{"ValorProdutos", Percentage.Type}, // Para porcentagem
```

## Solução de Problemas

### Erro: "Arquivo não encontrado"
- Verifique se o caminho do diretório está correto
- Certifique-se de usar barras invertidas (`\`) no Windows
- Confirme se os arquivos XML estão no diretório especificado

### Erro: "Erro no processamento"
- Alguns arquivos XML podem ter estruturas diferentes
- Use a versão simplificada que é mais tolerante
- Verifique se os arquivos XML são válidos

### Performance Lenta
- Para muitos arquivos (>100), considere processar em lotes
- Use a versão simplificada que é mais rápida
- Feche outros programas para liberar memória

### Dados Incorretos
- Verifique se os arquivos são NFe válidas
- Confirme se a estrutura XML corresponde ao padrão esperado
- Use a coluna "Status" para identificar arquivos problemáticos

## Campos Extraídos

### Versão Completa
| Campo | Descrição | Tipo |
|-------|-----------|------|
| NomeArquivo | Nome do arquivo XML | Texto |
| NumeroNF | Número da nota fiscal | Texto |
| SerieNF | Série da nota fiscal | Texto |
| DataEmissao | Data e hora de emissão | Data/Hora |
| CNPJEmitente | CNPJ do emitente | Texto |
| NomeEmitente | Razão social do emitente | Texto |
| CNPJDestinatario | CNPJ/CPF do destinatário | Texto |
| NomeDestinatario | Nome do destinatário | Texto |
| ValorTotalNF | Valor total da NFe | Número |
| ValorProdutos | Valor dos produtos | Número |
| ValorICMS | Valor do ICMS | Número |
| ValorIPI | Valor do IPI | Número |
| Status | Status do processamento | Texto |

### Versão Simplificada
| Campo | Descrição | Tipo |
|-------|-----------|------|
| Arquivo | Nome do arquivo XML | Texto |
| Número NFe | Número da nota fiscal | Texto |
| Série | Série da nota fiscal | Texto |
| Data Emissão | Data de emissão | Data/Hora |
| CNPJ Emitente | CNPJ do emitente | Texto |
| Valor Total | Valor total da NFe | Número |
| Valor Produtos | Valor dos produtos | Número |
| Status | Status do processamento | Texto |

## Análises Sugeridas

### 1. Resumo por Período
- Agrupar por mês/ano da data de emissão
- Somar valores totais
- Contar quantidade de notas

### 2. Análise por Emitente
- Agrupar por CNPJ/nome do emitente
- Identificar maiores fornecedores
- Analisar distribuição de valores

### 3. Controle de Sequência
- Verificar sequência numérica das NFe
- Identificar possíveis gaps
- Validar série utilizada

### 4. Análise Tributária
- Somar valores de ICMS e IPI
- Calcular alíquotas médias
- Comparar com valores de produtos

## Atualizações Automáticas
Para atualizar os dados automaticamente:
1. Salve a planilha com a consulta configurada
2. Configure atualização automática em **Dados** > **Conexões** > **Propriedades**
3. Defina intervalo de atualização desejado

## Notas Importantes
- A consulta funciona com arquivos NFe padrão (versões 3.10 e 4.00)
- Arquivos compactados (.zip) precisam ser extraídos antes
- A primeira execução pode ser mais lenta devido à indexação
- Mantenha backup dos arquivos XML originais