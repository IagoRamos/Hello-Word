let
    // Versão Simplificada - Apenas campos essenciais para conferência rápida
    
    // CONFIGURAÇÃO: Altere o caminho para seus arquivos XML
    CaminhoArquivos = "C:\Temp\NFe\",
    
    // Função simplificada para extrair apenas dados essenciais
    ExtrairDadosEssenciais = (xml as binary) =>
        let
            xmlText = Text.FromBinary(xml),
            xmlDoc = Xml.Document(xmlText),
            nfeNode = xmlDoc{0}[Value]{0}[Value],
            infNFe = nfeNode{0}[Value],
            
            // Dados básicos
            ide = infNFe{0}[Value],
            numeroNF = try ide{5}[Value] otherwise "ERRO",
            serie = try ide{4}[Value] otherwise "ERRO",
            dataEmissao = try ide{6}[Value] otherwise "ERRO",
            
            // Emitente
            emit = infNFe{1}[Value],
            cnpjEmitente = try emit{0}[Value] otherwise "ERRO",
            nomeEmitente = try emit{1}[Value] otherwise "ERRO",
            
            // Destinatário
            dest = infNFe{2}[Value],
            nomeDestinatario = try dest{1}[Value] otherwise "ERRO",
            
            // Totais (campos mais importantes)
            total = try infNFe{List.Count(infNFe) - 3}[Value] otherwise null,
            icmsTot = try total{0}[Value] otherwise null,
            valorProdutos = try icmsTot{12}[Value] otherwise "ERRO",
            valorICMS = try icmsTot{1}[Value] otherwise "ERRO",
            valorTotal = try icmsTot{22}[Value] otherwise "ERRO",
            
            // Chave NFe
            chaveNFe = try Text.Range(infNFe[Attributes][Id], 3, 44) otherwise "ERRO",
            
            resultado = [
                ChaveNFe = chaveNFe,
                NumeroNF = numeroNF,
                Serie = serie,
                DataEmissao = dataEmissao,
                CNPJEmitente = cnpjEmitente,
                NomeEmitente = nomeEmitente,
                NomeDestinatario = nomeDestinatario,
                ValorProdutos = valorProdutos,
                ValorICMS = valorICMS,
                ValorTotal = valorTotal
            ]
        in
            resultado,
    
    // Processamento dos arquivos
    Fonte = Folder.Files(CaminhoArquivos),
    ArquivosXML = Table.SelectRows(Fonte, each Text.EndsWith([Name], ".xml")),
    
    ComDados = Table.AddColumn(ArquivosXML, "DadosNFe", each 
        try ExtrairDadosEssenciais([Content]) 
        otherwise [
            ChaveNFe = "ERRO",
            NumeroNF = "ERRO", 
            Serie = "ERRO",
            DataEmissao = "ERRO",
            CNPJEmitente = "ERRO",
            NomeEmitente = "ERRO",
            NomeDestinatario = "ERRO",
            ValorProdutos = "ERRO",
            ValorICMS = "ERRO",
            ValorTotal = "ERRO"
        ]
    ),
    
    DadosExpandidos = Table.ExpandRecordColumn(ComDados, "DadosNFe", 
        {"ChaveNFe", "NumeroNF", "Serie", "DataEmissao", "CNPJEmitente", 
         "NomeEmitente", "NomeDestinatario", "ValorProdutos", "ValorICMS", "ValorTotal"}),
    
    TabelaLimpa = Table.SelectColumns(DadosExpandidos, 
        {"Name", "ChaveNFe", "NumeroNF", "Serie", "DataEmissao", "CNPJEmitente", 
         "NomeEmitente", "NomeDestinatario", "ValorProdutos", "ValorICMS", "ValorTotal"}),
    
    TabelaFinal = Table.RenameColumns(TabelaLimpa, {{"Name", "Arquivo"}}),
    
    // Converter tipos (apenas numéricos)
    TiposConvertidos = Table.TransformColumnTypes(TabelaFinal,{
        {"NumeroNF", Int64.Type}, 
        {"Serie", Int64.Type}, 
        {"DataEmissao", type datetime},
        {"ValorProdutos", type number}, 
        {"ValorICMS", type number}, 
        {"ValorTotal", type number}
    })
in
    TiposConvertidos