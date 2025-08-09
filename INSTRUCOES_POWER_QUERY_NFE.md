# Power Query para Leitura Massiva de NFe (XML)

Esta solução permite ler múltiplos arquivos XML de NFe de um diretório e extrair automaticamente as principais informações em formato de planilha para conferência massiva de dados.

## 📋 Funcionalidades

- **Leitura automática** de todos os arquivos XML NFe de um diretório
- **Extração das principais tags** da NFe em colunas separadas
- **Tratamento de erros** para arquivos corrompidos ou com estrutura diferente
- **Conversão automática** de tipos de dados (números, datas, texto)
- **Interface amigável** em formato de tabela no Excel

## 🏷️ Dados Extraídos

### Informações Básicas
- Chave da NFe (44 dígitos)
- Número da Nota Fiscal
- Série
- Data/Hora de Emissão
- Natureza da Operação

### Dados do Emitente
- CNPJ do Emitente
- Nome/Razão Social do Emitente
- Nome Fantasia do Emitente

### Dados do Destinatário
- CPF/CNPJ do Destinatário
- Nome do Destinatário

### Valores Fiscais
- Base de Cálculo do ICMS
- Valor do ICMS
- Valor dos Produtos/Serviços
- Valor do Frete
- Valor do Seguro
- Valor do Desconto
- Valor do Imposto de Importação (II)
- Valor do IPI
- Valor do PIS
- Valor da COFINS
- Outros Valores
- **Valor Total da Nota Fiscal**

## 🚀 Como Usar

### 1. Preparar os Arquivos
1. Organize todos os arquivos XML das NFe em um diretório específico
2. Anote o caminho completo do diretório (ex: `C:\Temp\NFe\`)

### 2. Configurar no Excel

#### Opção A: Importar o código completo
1. Abra o Excel
2. Vá em **Dados** → **Obter Dados** → **De Outras Fontes** → **Consulta em Branco**
3. No Editor do Power Query, vá em **Visualizar** → **Editor Avançado**
4. Cole todo o conteúdo do arquivo `PowerQuery_NFe_Reader.pq`
5. **IMPORTANTE**: Altere a linha `CaminhoArquivos = "C:\Temp\NFe\"` para o seu diretório
6. Clique em **Concluído**

#### Opção B: Criar passo a passo
1. **Dados** → **Obter Dados** → **Do Arquivo** → **Da Pasta**
2. Selecione o diretório com os arquivos XML
3. Clique em **Transformar Dados**
4. No Editor do Power Query, cole a função `ExtrairDadosNFe` no Editor Avançado

### 3. Executar a Consulta
1. Clique em **Fechar e Carregar**
2. O Excel processará todos os arquivos XML
3. Uma nova planilha será criada com os dados extraídos

## 🛠️ Personalização

### Adicionar Mais Campos
Para extrair campos adicionais da NFe, edite a função `ExtrairDadosNFe`:

```powerquery
// Exemplo: Extrair Inscrição Estadual do Emitente
ieEmit = try emit{4}[Value] otherwise null,

// Adicionar no registro resultado:
InscricaoEstadualEmitente = ieEmit,
```

### Filtrar por Período
Para filtrar NFe por período específico:

```powerquery
// Adicionar após TiposConvertidos
FiltradoPorData = Table.SelectRows(TiposConvertidos, 
    each [DataEmissao] >= #datetime(2023, 1, 1, 0, 0, 0) 
    and [DataEmissao] <= #datetime(2023, 12, 31, 23, 59, 59)
)
```

### Filtrar por Emitente
Para filtrar por CNPJ específico:

```powerquery
// Filtrar por CNPJ do emitente
FiltradoPorEmitente = Table.SelectRows(TiposConvertidos, 
    each [CNPJEmitente] = "12345678000199"
)
```

## ⚠️ Tratamento de Erros

A consulta inclui tratamento robusto de erros:
- Arquivos XML malformados são marcados com "ERRO"
- Estruturas diferentes de NFe são tratadas com valores nulos
- Continue a execução mesmo com arquivos problemáticos

## 📊 Casos de Uso

### 1. Auditoria Fiscal
- Conferir valores totais de vendas
- Verificar ICMS recolhido
- Analisar base de cálculo

### 2. Análise de Vendas
- Relatórios por período
- Análise por cliente
- Comparação de volumes

### 3. Conciliação Contábil
- Conferir lançamentos contábeis
- Validar impostos
- Verificar divergências

### 4. Compliance Fiscal
- Verificar obrigatoriedades
- Conferir dados cadastrais
- Validar cálculos fiscais

## 🔧 Solução de Problemas

### Erro: "Não foi possível encontrar o diretório"
- Verifique se o caminho está correto
- Use barras duplas: `"C:\\Temp\\NFe\\"`
- Certifique-se que o diretório existe

### Erro: "Arquivo não é um XML válido"
- Verifique se os arquivos são XMLs de NFe válidos
- Arquivos corrompidos serão marcados como "ERRO"

### Performance Lenta
- Processe em lotes menores (mova arquivos para subpastas)
- Remova campos desnecessários da extração
- Use um computador com mais memória RAM

### Dados Incompletos
- Algumas NFe podem ter estruturas diferentes
- A consulta é defensiva e usa `try...otherwise null`
- Verifique a versão do layout da NFe

## 📝 Notas Importantes

1. **Backup**: Sempre faça backup dos arquivos XML originais
2. **Versões**: Testado com NFe versão 4.00 (mais comum)
3. **Performance**: Para muitos arquivos (>1000), considere processamento em lotes
4. **Memória**: Arquivos muito grandes podem consumir muita RAM
5. **Segurança**: Mantenha os arquivos XML em local seguro (dados sensíveis)

## 📞 Suporte

Para dúvidas ou problemas:
1. Verifique se o arquivo XML é uma NFe válida
2. Confirme a versão do layout da NFe
3. Teste com um arquivo individual primeiro
4. Verifique os logs de erro no Power Query

---

**Desenvolvido para facilitar a análise massiva de Notas Fiscais Eletrônicas (NFe)**