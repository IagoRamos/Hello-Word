// Versão Simplificada - Consulta Power Query para NFe
// Esta versão é mais robusta para diferentes estruturas de XML

let
    // CONFIGURAÇÃO: Altere o caminho para o diretório
    CaminhoArquivos = "C:\Arquivos_NFe\",
    
    // Função auxiliar para buscar valores em XML de forma segura
    BuscarValorXML = (xmlChildren as list, tagName as text) =>
    let
        Resultado = try 
            List.Select(xmlChildren, each [Name] = tagName){0}[Children]{0}[Value]
        otherwise 
            ""
    in
        Resultado,
    
    // Função simplificada para extrair dados básicos
    ExtrairDadosBasicos = (arquivo as binary) =>
    let
        TentarProcessar = try
            let
                // Converter para XML
                XML = Xml.Document(arquivo),
                
                // Buscar todos os elementos recursivamente
                TodosElementos = Xml.Tables(XML),
                
                // Extrair campos principais usando busca mais flexível
                NumeroNF = try TodosElementos{[Name="nNF"]}?[Table]?{0}?[Value] otherwise "",
                SerieNF = try TodosElementos{[Name="serie"]}?[Table]?{0}?[Value] otherwise "",
                DataEmissao = try TodosElementos{[Name="dhEmi"]}?[Table]?{0}?[Value] otherwise "",
                CNPJEmit = try TodosElementos{[Name="CNPJ"]}?[Table]?{0}?[Value] otherwise "",
                ValorTotal = try TodosElementos{[Name="vNF"]}?[Table]?{0}?[Value] otherwise "0",
                ValorProd = try TodosElementos{[Name="vProd"]}?[Table]?{0}?[Value] otherwise "0",
                
                // Resultado estruturado
                Resultado = [
                    Numero = if NumeroNF = "" then "N/A" else NumeroNF,
                    Serie = if SerieNF = "" then "N/A" else SerieNF,
                    Data = if DataEmissao = "" then null else 
                           try DateTime.FromText(Text.Replace(DataEmissao, "T", " ")) otherwise null,
                    CNPJ = if CNPJEmit = "" then "N/A" else CNPJEmit,
                    ValorTotal = try Number.FromText(ValorTotal) otherwise 0,
                    ValorProdutos = try Number.FromText(ValorProd) otherwise 0,
                    Status = "OK"
                ]
            in
                Resultado
        otherwise
            [
                Numero = "ERRO",
                Serie = "ERRO", 
                Data = null,
                CNPJ = "ERRO",
                ValorTotal = 0,
                ValorProdutos = 0,
                Status = "Erro no processamento"
            ]
    in
        TentarProcessar,
    
    // Obter arquivos XML
    Arquivos = Folder.Files(CaminhoArquivos),
    ArquivosXML = Table.SelectRows(Arquivos, each Text.EndsWith([Name], ".xml")),
    
    // Processar cada arquivo
    DadosProcessados = Table.AddColumn(ArquivosXML, "DadosNFe", 
        each ExtrairDadosBasicos([Content])),
    
    // Expandir dados
    DadosExpandidos = Table.ExpandRecordColumn(DadosProcessados, "DadosNFe",
        {"Numero", "Serie", "Data", "CNPJ", "ValorTotal", "ValorProdutos", "Status"}),
    
    // Selecionar colunas finais
    ResultadoFinal = Table.SelectColumns(DadosExpandidos,
        {"Name", "Numero", "Serie", "Data", "CNPJ", "ValorTotal", "ValorProdutos", "Status"}),
    
    // Renomear colunas
    ColunasRenomeadas = Table.RenameColumns(ResultadoFinal, {
        {"Name", "Arquivo"},
        {"Numero", "Número NFe"},
        {"Serie", "Série"},
        {"Data", "Data Emissão"},
        {"CNPJ", "CNPJ Emitente"},
        {"ValorTotal", "Valor Total"},
        {"ValorProdutos", "Valor Produtos"}
    })
    
in
    ColunasRenomeadas