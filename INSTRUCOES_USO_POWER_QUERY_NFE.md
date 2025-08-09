# Como Usar a Consulta Power Query para Análise Massiva de NFe

## 📋 Pré-requisitos
- Microsoft Excel com Power Query (versões 2016+ ou Office 365)
- Arquivos XML de NFe salvos em um diretório local
- Permissões de leitura no diretório dos arquivos

## 🚀 Passo a Passo para Implementar

### 1. Preparar os Arquivos
- Organize todos os arquivos XML das NFe em uma pasta específica
- Exemplo: `C:\NFe_Analise\XMLs\`
- Certifique-se de que todos os arquivos têm extensão `.xml`

### 2. Abrir o Power Query no Excel

#### No Excel 2016/2019:
1. Aba **Dados** → **Obter Dados** → **Consulta em Branco**

#### No Excel 365:
1. Aba **Dados** → **Obter Dados** → **De Outras Fontes** → **Consulta em Branco**

### 3. Inserir o Código da Consulta

1. No Editor do Power Query, clique em **Exibição** → **Editor Avançado**
2. Apague todo o código existente
3. Copie e cole o código do arquivo `consulta_nfe_power_query.m`
4. **IMPORTANTE**: Altere a linha 3 do código:
   ```m
   CaminhoArquivos = "C:\Caminho\Para\Seus\Arquivos\NFe\",
   ```
   Para o caminho real onde estão seus arquivos XML. Exemplo:
   ```m
   CaminhoArquivos = "C:\NFe_Analise\XMLs\",
   ```

### 4. Executar a Consulta

1. Clique em **Concluído** no Editor Avançado
2. O Power Query começará a processar os arquivos
3. Aguarde o processamento (pode demorar dependendo da quantidade de arquivos)
4. Clique em **Fechar e Carregar** para importar os dados para o Excel

## 📊 Dados Extraídos

A consulta extrai as seguintes informações de cada NFe:

### Identificação
- **Arquivo_Origem**: Nome do arquivo XML original
- **ChaveAcesso**: Chave de acesso da NFe (44 dígitos)
- **NumeroNF**: Número da nota fiscal
- **Serie**: Série da nota fiscal
- **Modelo**: Modelo da nota (geralmente 55 para NFe)
- **DataEmissao**: Data e hora de emissão

### Partes Envolvidas
- **CNPJ_Emitente**: CNPJ da empresa emitente
- **Nome_Emitente**: Razão social do emitente
- **CNPJ_CPF_Destinatario**: CNPJ ou CPF do destinatário
- **Nome_Destinatario**: Nome do destinatário

### Valores Financeiros
- **Valor_Total**: Valor total da nota fiscal
- **Base_ICMS**: Base de cálculo do ICMS
- **Valor_ICMS**: Valor do ICMS
- **Valor_Produtos**: Valor total dos produtos/serviços
- **Valor_Frete**: Valor do frete
- **Valor_Desconto**: Valor dos descontos
- **Valor_IPI**: Valor do IPI
- **Valor_PIS**: Valor do PIS
- **Valor_COFINS**: Valor da COFINS

### Protocolo
- **Protocolo**: Número do protocolo de autorização
- **Status_Protocolo**: Status do protocolo (100 = autorizada)
- **Data_Autorizacao**: Data e hora da autorização

## 🔧 Troubleshooting

### Problemas Comuns

#### "Não foi possível acessar o diretório"
- Verifique se o caminho está correto
- Certifique-se de ter permissões de leitura na pasta
- Use barras invertidas duplas `\\` ou barras simples `/`

#### "Erro ao processar XML"
- Alguns arquivos podem estar corrompidos
- A consulta marcará esses arquivos como "ERRO" na coluna ChaveAcesso
- Verifique os arquivos marcados como erro individualmente

#### Dados aparecendo como "null"
- Alguns campos podem não existir em todas as NFe
- Isso é normal e não indica erro
- Campos vazios aparecem como células em branco no Excel

### Performance

#### Para Muitos Arquivos (1000+)
- O processamento pode demorar alguns minutos
- Considere processar em lotes menores
- Feche outros programas para liberar memória

#### Otimizações
- Mantenha apenas arquivos XML necessários na pasta
- Use SSD para melhor performance de leitura
- Aumente a memória disponível para o Excel

## 📈 Análises Sugeridas

Com os dados carregados, você pode:

### Análises Básicas
- **Totalizadores**: Somar valores por período
- **Relatórios de Emitente**: Agrupar por CNPJ do emitente
- **Análise Temporal**: Gráficos por data de emissão
- **Conferência de Impostos**: Validar cálculos de ICMS, PIS, COFINS

### Fórmulas Úteis no Excel
```excel
=SOMA(Valor_Total)                    // Total geral das NFe
=CONT.VALORES(NumeroNF)               // Quantidade de NFe
=MÉDIA(Valor_Total)                   // Ticket médio
=SOMASE(Status_Protocolo,"100",Valor_Total)  // Total de NFe autorizadas
```

### Tabelas Dinâmicas Recomendadas
- **Por Emitente**: CNPJ_Emitente vs Soma de Valor_Total
- **Por Mês**: DataEmissao (agrupada) vs Soma de Valor_Total
- **Por Status**: Status_Protocolo vs Contagem de NumeroNF

## 🔄 Atualizando os Dados

Para processar novos arquivos XML:

1. Adicione os novos arquivos XML na pasta configurada
2. No Excel, clique na tabela de dados
3. Aba **Dados** → **Atualizar Tudo**
4. O Power Query processará apenas os novos arquivos

## ⚠️ Observações Importantes

- **Backup**: Sempre mantenha backup dos arquivos XML originais
- **Privacidade**: Os dados extraídos contêm informações sensíveis
- **Legislação**: Certifique-se de estar em conformidade com a LGPD
- **Validação**: Sempre valide uma amostra dos dados extraídos
- **Versões**: A consulta foi testada com NFe versão 4.00, mas deve funcionar com versões anteriores

## 📞 Suporte

Se encontrar problemas:
1. Verifique se o caminho dos arquivos está correto
2. Confirme que os arquivos XML são válidos
3. Teste com uma quantidade menor de arquivos primeiro
4. Verifique se há atualizações do Excel disponíveis