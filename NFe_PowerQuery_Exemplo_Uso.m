// Exemplo Prático - Consulta Power Query para Conferência de NFe
// Foco em auditoria e conferência de dados

let
    // CONFIGURAÇÃO
    CaminhoArquivos = "C:\Auditoria_NFe\",
    
    // Função para conferência de dados críticos
    ConferirNFe = (arquivo as binary) =>
    let
        ProcessarXML = try
            let
                XML = Xml.Document(arquivo),
                Elementos = Xml.Tables(XML),
                
                // Dados de identificação
                NumNF = try Elementos{[Name="nNF"]}?[Table]?{0}?[Value] otherwise "N/A",
                Serie = try Elementos{[Name="serie"]}?[Table]?{0}?[Value] otherwise "N/A",
                DataEmi = try Elementos{[Name="dhEmi"]}?[Table]?{0}?[Value] otherwise "",
                Modelo = try Elementos{[Name="mod"]}?[Table]?{0}?[Value] otherwise "N/A",
                
                // Dados do emitente
                CNPJEmit = try Elementos{[Name="CNPJ"]}?[Table]?{0}?[Value] otherwise "N/A",
                
                // Valores financeiros
                ValorNF = try Elementos{[Name="vNF"]}?[Table]?{0}?[Value] otherwise "0",
                ValorProd = try Elementos{[Name="vProd"]}?[Table]?{0}?[Value] otherwise "0",
                ValorICMS = try Elementos{[Name="vICMS"]}?[Table]?{0}?[Value] otherwise "0",
                ValorIPI = try Elementos{[Name="vIPI"]}?[Table]?{0}?[Value] otherwise "0",
                BaseICMS = try Elementos{[Name="vBC"]}?[Table]?{0}?[Value] otherwise "0",
                
                // Chave de acesso
                ChaveAcesso = try Elementos{[Name="Id"]}?[Table]?{0}?[Value] otherwise "N/A",
                
                // Conversões numéricas
                VlrNF = try Number.FromText(ValorNF) otherwise 0,
                VlrProd = try Number.FromText(ValorProd) otherwise 0,
                VlrICMS = try Number.FromText(ValorICMS) otherwise 0,
                VlrIPI = try Number.FromText(ValorIPI) otherwise 0,
                VlrBase = try Number.FromText(BaseICMS) otherwise 0,
                
                // Validações e conferências
                DiferencaTotal = Number.Round(VlrNF - (VlrProd + VlrICMS + VlrIPI), 2),
                PercentualICMS = if VlrBase > 0 then Number.Round((VlrICMS / VlrBase) * 100, 2) else 0,
                
                // Status de conferência
                StatusConferencia = 
                    if NumNF = "N/A" or Serie = "N/A" then "Dados Incompletos"
                    else if Number.Abs(DiferencaTotal) > 0.1 then "Divergência nos Valores"
                    else if VlrNF = 0 then "Valor Zerado"
                    else "Conferido",
                
                // Data formatada
                DataFormatada = if DataEmi = "" then null else 
                               try Date.FromText(Text.Start(DataEmi, 10)) otherwise null,
                
                Resultado = [
                    Numero = NumNF,
                    Serie = Serie,
                    Modelo = Modelo,
                    DataEmissao = DataFormatada,
                    ChaveAcesso = Text.Replace(ChaveAcesso, "NFe", ""),
                    CNPJEmitente = CNPJEmit,
                    ValorNF = VlrNF,
                    ValorProdutos = VlrProd,
                    ValorICMS = VlrICMS,
                    ValorIPI = VlrIPI,
                    BaseCalculoICMS = VlrBase,
                    AliquotaICMS = PercentualICMS,
                    DiferencaCalculada = DiferencaTotal,
                    StatusConferencia = StatusConferencia
                ]
            in
                Resultado
        otherwise
            [
                Numero = "ERRO",
                Serie = "ERRO",
                Modelo = "ERRO",
                DataEmissao = null,
                ChaveAcesso = "ERRO",
                CNPJEmitente = "ERRO",
                ValorNF = 0,
                ValorProdutos = 0,
                ValorICMS = 0,
                ValorIPI = 0,
                BaseCalculoICMS = 0,
                AliquotaICMS = 0,
                DiferencaCalculada = 0,
                StatusConferencia = "Erro no Processamento"
            ]
    in
        ProcessarXML,
    
    // Processar arquivos
    Arquivos = Folder.Files(CaminhoArquivos),
    ArquivosXML = Table.SelectRows(Arquivos, each Text.EndsWith([Name], ".xml")),
    
    // Adicionar dados de conferência
    ComDados = Table.AddColumn(ArquivosXML, "Conferencia", each ConferirNFe([Content])),
    
    // Expandir dados
    DadosExpandidos = Table.ExpandRecordColumn(ComDados, "Conferencia",
        {"Numero", "Serie", "Modelo", "DataEmissao", "ChaveAcesso", "CNPJEmitente",
         "ValorNF", "ValorProdutos", "ValorICMS", "ValorIPI", "BaseCalculoICMS",
         "AliquotaICMS", "DiferencaCalculada", "StatusConferencia"}),
    
    // Adicionar colunas de análise
    ComAnalise = Table.AddColumn(DadosExpandidos, "TipoProblema", each
        if [StatusConferencia] = "Divergência nos Valores" then "CRÍTICO"
        else if [StatusConferencia] = "Dados Incompletos" then "ATENÇÃO"
        else if [StatusConferencia] = "Valor Zerado" then "VERIFICAR"
        else "OK"),
    
    // Adicionar indicador de duplicatas (mesmo número e série)
    ComDuplicatas = Table.AddColumn(ComAnalise, "PossívelDuplicata", each
        Table.RowCount(Table.SelectRows(ComAnalise, 
            (linha) => linha[Numero] = [Numero] and linha[Serie] = [Serie])) > 1),
    
    // Selecionar colunas finais
    ColunasFinais = Table.SelectColumns(ComDuplicatas, {
        "Name", "Numero", "Serie", "Modelo", "DataEmissao", "ChaveAcesso",
        "CNPJEmitente", "ValorNF", "ValorProdutos", "ValorICMS", "ValorIPI",
        "AliquotaICMS", "DiferencaCalculada", "StatusConferencia", 
        "TipoProblema", "PossívelDuplicata"
    }),
    
    // Renomear colunas
    ColunasRenomeadas = Table.RenameColumns(ColunasFinais, {
        {"Name", "Arquivo"},
        {"Numero", "Número"},
        {"Serie", "Série"},
        {"DataEmissao", "Data Emissão"},
        {"ChaveAcesso", "Chave de Acesso"},
        {"CNPJEmitente", "CNPJ Emitente"},
        {"ValorNF", "Valor Total NFe"},
        {"ValorProdutos", "Valor Produtos"},
        {"ValorICMS", "Valor ICMS"},
        {"ValorIPI", "Valor IPI"},
        {"AliquotaICMS", "% ICMS"},
        {"DiferencaCalculada", "Diferença Calculada"},
        {"StatusConferencia", "Status Conferência"},
        {"TipoProblema", "Tipo Problema"},
        {"PossívelDuplicata", "Possível Duplicata"}
    }),
    
    // Ordenar por tipo de problema (críticos primeiro)
    ResultadoOrdenado = Table.Sort(ColunasRenomeadas, {
        {"Tipo Problema", Order.Ascending},
        {"Data Emissão", Order.Descending}
    })
    
in
    ResultadoOrdenado