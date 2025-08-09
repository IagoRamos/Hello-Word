// Consulta Power Query para leitura massiva de arquivos XML NFe
// Esta consulta lê todos os arquivos XML de um diretório e extrai informações principais da NFe

let
    // CONFIGURAÇÃO: Altere o caminho para o diretório onde estão os arquivos XML
    CaminhoArquivos = "C:\Arquivos_NFe\",
    
    // Obter lista de arquivos XML no diretório
    FonteArquivos = Folder.Files(CaminhoArquivos),
    
    // Filtrar apenas arquivos XML
    ArquivosXML = Table.SelectRows(FonteArquivos, each Text.EndsWith([Name], ".xml")),
    
    // Função para extrair dados específicos de cada NFe
    ExtrairDadosNFe = (conteudoXml as text) =>
    let
        // Converter texto XML em documento XML
        DocXML = Xml.Document(Text.FromBinary(conteudoXml)),
        
        // Navegar pela estrutura da NFe
        // Estrutura típica: nfeProc/NFe/infNFe/...
        TentarExtrair = try
            let
                // Localizar o nó principal da NFe
                NFe = DocXML{0}[Children]{0}[Children]{0}[Children],
                
                // Extrair informações da identificação (ide)
                InfoIde = List.Select(NFe, each [Name] = "ide"){0}[Children],
                NumeroNF = List.Select(InfoIde, each [Name] = "nNF"){0}[Children]{0}[Value],
                SerieNF = List.Select(InfoIde, each [Name] = "serie"){0}[Children]{0}[Value],
                DataEmissao = List.Select(InfoIde, each [Name] = "dhEmi"){0}[Children]{0}[Value],
                
                // Extrair informações do emitente
                InfoEmit = List.Select(NFe, each [Name] = "emit"){0}[Children],
                CNPJEmit = List.Select(InfoEmit, each [Name] = "CNPJ"){0}[Children]{0}[Value],
                NomeEmit = List.Select(InfoEmit, each [Name] = "xNome"){0}[Children]{0}[Value],
                
                // Extrair informações do destinatário
                InfoDest = List.Select(NFe, each [Name] = "dest"){0}[Children],
                CNPJDest = try List.Select(InfoDest, each [Name] = "CNPJ"){0}[Children]{0}[Value] otherwise 
                          try List.Select(InfoDest, each [Name] = "CPF"){0}[Children]{0}[Value] otherwise "",
                NomeDest = List.Select(InfoDest, each [Name] = "xNome"){0}[Children]{0}[Value],
                
                // Extrair totais da NFe
                InfoTotal = List.Select(NFe, each [Name] = "total"){0}[Children],
                ICMSTot = List.Select(InfoTotal, each [Name] = "ICMSTot"){0}[Children],
                ValorTotal = List.Select(ICMSTot, each [Name] = "vNF"){0}[Children]{0}[Value],
                ValorProdutos = List.Select(ICMSTot, each [Name] = "vProd"){0}[Children]{0}[Value],
                ValorICMS = List.Select(ICMSTot, each [Name] = "vICMS"){0}[Children]{0}[Value],
                ValorIPI = try List.Select(ICMSTot, each [Name] = "vIPI"){0}[Children]{0}[Value] otherwise "0",
                
                // Criar registro com os dados extraídos
                Resultado = [
                    NumeroNF = NumeroNF,
                    SerieNF = SerieNF,
                    DataEmissao = DateTime.FromText(Text.Replace(DataEmissao, "T", " ")),
                    CNPJEmitente = CNPJEmit,
                    NomeEmitente = NomeEmit,
                    CNPJDestinatario = CNPJDest,
                    NomeDestinatario = NomeDest,
                    ValorTotalNF = Number.FromText(ValorTotal),
                    ValorProdutos = Number.FromText(ValorProdutos),
                    ValorICMS = Number.FromText(ValorICMS),
                    ValorIPI = Number.FromText(ValorIPI),
                    Status = "Processado"
                ]
            in
                Resultado
        otherwise
            [
                NumeroNF = "Erro",
                SerieNF = "Erro",
                DataEmissao = null,
                CNPJEmitente = "Erro ao processar",
                NomeEmitente = "Erro ao processar",
                CNPJDestinatario = "Erro ao processar",
                NomeDestinatario = "Erro ao processar",
                ValorTotalNF = 0,
                ValorProdutos = 0,
                ValorICMS = 0,
                ValorIPI = 0,
                Status = "Erro no processamento"
            ]
    in
        TentarExtrair,
    
    // Função para processar cada arquivo
    ProcessarArquivo = (linha as record) =>
    let
        CaminhoCompleto = CaminhoArquivos & linha[Name],
        ConteudoArquivo = File.Contents(CaminhoCompleto),
        DadosExtraidos = ExtrairDadosNFe(ConteudoArquivo),
        ResultadoFinal = DadosExtraidos & [NomeArquivo = linha[Name]]
    in
        ResultadoFinal,
    
    // Aplicar função para cada arquivo XML
    DadosProcessados = Table.AddColumn(ArquivosXML, "DadosNFe", each ProcessarArquivo(_)),
    
    // Expandir os dados extraídos
    DadosExpandidos = Table.ExpandRecordColumn(DadosProcessados, "DadosNFe", 
        {"NumeroNF", "SerieNF", "DataEmissao", "CNPJEmitente", "NomeEmitente", 
         "CNPJDestinatario", "NomeDestinatario", "ValorTotalNF", "ValorProdutos", 
         "ValorICMS", "ValorIPI", "Status", "NomeArquivo"}),
    
    // Selecionar apenas as colunas necessárias
    ColunasSelecionadas = Table.SelectColumns(DadosExpandidos, 
        {"NomeArquivo", "NumeroNF", "SerieNF", "DataEmissao", "CNPJEmitente", "NomeEmitente", 
         "CNPJDestinatario", "NomeDestinatario", "ValorTotalNF", "ValorProdutos", 
         "ValorICMS", "ValorIPI", "Status"}),
    
    // Definir tipos de dados
    TiposDefinidos = Table.TransformColumnTypes(ColunasSelecionadas, {
        {"NumeroNF", type text},
        {"SerieNF", type text},
        {"DataEmissao", type datetime},
        {"CNPJEmitente", type text},
        {"NomeEmitente", type text},
        {"CNPJDestinatario", type text},
        {"NomeDestinatario", type text},
        {"ValorTotalNF", type number},
        {"ValorProdutos", type number},
        {"ValorICMS", type number},
        {"ValorIPI", type number},
        {"Status", type text},
        {"NomeArquivo", type text}
    })
    
in
    TiposDefinidos