let
    // VERSÃO SIMPLIFICADA - Extrai apenas dados essenciais das NFe
    // Configure o caminho dos seus arquivos XML aqui:
    CaminhoArquivos = "C:\Caminho\Para\Seus\Arquivos\NFe\",
    
    // Lista arquivos XML no diretório
    Fonte = Folder.Files(CaminhoArquivos),
    ArquivosXML = Table.SelectRows(Fonte, each Text.EndsWith([Name], ".xml")),
    
    // Função simplificada para extrair dados básicos
    ExtrairDadosBasicos = (conteudoXML as binary) =>
        let
            xml = Xml.Document(conteudoXML),
            // Tenta diferentes estruturas de NFe
            resultado = try
                let
                    // Para NFe processada (nfeProc)
                    NFe = xml{0}[Content]{0}[Content],
                    infNFe = NFe{0}[Content],
                    ide = infNFe{0}[Content],
                    emit = infNFe{1}[Content],
                    dest = infNFe{2}[Content],
                    total = infNFe{[Name="total"]}[Content],
                    ICMSTot = total{[Name="ICMSTot"]}[Content]
                in
                    [
                        NumeroNF = ide{[Name="nNF"]}[Content]{0}[Value],
                        Serie = ide{[Name="serie"]}[Content]{0}[Value],
                        DataEmissao = DateTime.FromText(ide{[Name="dhEmi"]}[Content]{0}[Value]),
                        ChaveAcesso = Text.Replace(infNFe[Attributes][Id], "NFe", ""),
                        CNPJ_Emitente = emit{[Name="CNPJ"]}[Content]{0}[Value],
                        Nome_Emitente = emit{[Name="xNome"]}[Content]{0}[Value],
                        CNPJ_Destinatario = try dest{[Name="CNPJ"]}[Content]{0}[Value] otherwise dest{[Name="CPF"]}[Content]{0}[Value],
                        Nome_Destinatario = dest{[Name="xNome"]}[Content]{0}[Value],
                        Valor_Total = Number.FromText(ICMSTot{[Name="vNF"]}[Content]{0}[Value]),
                        Valor_Produtos = Number.FromText(ICMSTot{[Name="vProd"]}[Content]{0}[Value]),
                        Valor_ICMS = Number.FromText(ICMSTot{[Name="vICMS"]}[Content]{0}[Value])
                    ]
            otherwise
                // Em caso de erro, retorna registro com valores nulos
                [
                    NumeroNF = null,
                    Serie = null,
                    DataEmissao = null,
                    ChaveAcesso = "ERRO_PROCESSAMENTO",
                    CNPJ_Emitente = null,
                    Nome_Emitente = null,
                    CNPJ_Destinatario = null,
                    Nome_Destinatario = null,
                    Valor_Total = null,
                    Valor_Produtos = null,
                    Valor_ICMS = null
                ]
        in
            resultado,
    
    // Aplica a função de extração para cada arquivo
    ComDados = Table.AddColumn(ArquivosXML, "DadosNFe", each ExtrairDadosBasicos([Content])),
    
    // Expande os dados extraídos
    Expandido = Table.ExpandRecordColumn(ComDados, "DadosNFe", 
        {"NumeroNF", "Serie", "DataEmissao", "ChaveAcesso", "CNPJ_Emitente", "Nome_Emitente", 
         "CNPJ_Destinatario", "Nome_Destinatario", "Valor_Total", "Valor_Produtos", "Valor_ICMS"}),
    
    // Seleciona apenas as colunas relevantes
    ColunasFinal = Table.SelectColumns(Expandido, {
        "Name", "NumeroNF", "Serie", "DataEmissao", "ChaveAcesso", 
        "CNPJ_Emitente", "Nome_Emitente", "CNPJ_Destinatario", "Nome_Destinatario",
        "Valor_Total", "Valor_Produtos", "Valor_ICMS"
    }),
    
    // Renomeia a coluna do arquivo
    Renomeado = Table.RenameColumns(ColunasFinal, {{"Name", "Arquivo_XML"}}),
    
    // Ordena por data de emissão (mais recentes primeiro)
    Ordenado = Table.Sort(Renomeado, {{"DataEmissao", Order.Descending}})
    
in
    Ordenado