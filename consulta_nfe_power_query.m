let
    // CONFIGURAÇÃO: Altere o caminho do diretório onde estão os arquivos XML da NFe
    CaminhoArquivos = "C:\Caminho\Para\Seus\Arquivos\NFe\",
    
    // Lista todos os arquivos XML no diretório
    Fonte = Folder.Files(CaminhoArquivos),
    
    // Filtra apenas arquivos XML
    ArquivosXML = Table.SelectRows(Fonte, each Text.EndsWith([Name], ".xml")),
    
    // Função para extrair dados de uma NFe
    ExtrairDadosNFe = (conteudoXML as binary) =>
        let
            // Converte o binário em XML
            xml = Xml.Document(conteudoXML),
            
            // Navega até o nó principal da NFe
            nfeProc = try xml{0}[Name] otherwise null,
            
            // Extrai dados da NFe - ajusta navegação conforme estrutura do XML
            dadosNFe = 
                if nfeProc = "nfeProc" then
                    let
                        NFe = xml{0}[Content]{0}[Content],
                        infNFe = NFe{0}[Content],
                        
                        // Identificação da NFe
                        ide = try infNFe{0}[Content] otherwise null,
                        numeroNF = try ide{[Name="nNF"]}[Content]{0}[Value] otherwise null,
                        serie = try ide{[Name="serie"]}[Content]{0}[Value] otherwise null,
                        dataEmissao = try ide{[Name="dhEmi"]}[Content]{0}[Value] otherwise null,
                        modelo = try ide{[Name="mod"]}[Content]{0}[Value] otherwise null,
                        chaveAcesso = try infNFe[Attributes][Id] otherwise null,
                        
                        // Emitente
                        emit = try infNFe{1}[Content] otherwise null,
                        cnpjEmit = try emit{[Name="CNPJ"]}[Content]{0}[Value] otherwise null,
                        nomeEmit = try emit{[Name="xNome"]}[Content]{0}[Value] otherwise null,
                        
                        // Destinatário
                        dest = try infNFe{2}[Content] otherwise null,
                        cnpjDest = try dest{[Name="CNPJ"]}[Content]{0}[Value] otherwise 
                                   try dest{[Name="CPF"]}[Content]{0}[Value] otherwise null,
                        nomeDest = try dest{[Name="xNome"]}[Content]{0}[Value] otherwise null,
                        
                        // Totais da NFe
                        total = try infNFe{[Name="total"]}[Content] otherwise null,
                        ICMSTot = try total{[Name="ICMSTot"]}[Content] otherwise null,
                        valorTotal = try ICMSTot{[Name="vNF"]}[Content]{0}[Value] otherwise null,
                        baseICMS = try ICMSTot{[Name="vBC"]}[Content]{0}[Value] otherwise null,
                        valorICMS = try ICMSTot{[Name="vICMS"]}[Content]{0}[Value] otherwise null,
                        valorProdutos = try ICMSTot{[Name="vProd"]}[Content]{0}[Value] otherwise null,
                        valorFrete = try ICMSTot{[Name="vFrete"]}[Content]{0}[Value] otherwise null,
                        valorDesconto = try ICMSTot{[Name="vDesc"]}[Content]{0}[Value] otherwise null,
                        
                        // Informações adicionais de impostos
                        valorIPI = try ICMSTot{[Name="vIPI"]}[Content]{0}[Value] otherwise null,
                        valorPIS = try ICMSTot{[Name="vPIS"]}[Content]{0}[Value] otherwise null,
                        valorCOFINS = try ICMSTot{[Name="vCOFINS"]}[Content]{0}[Value] otherwise null,
                        
                        // Protocolo de autorização
                        protNFe = try xml{0}[Content]{1}[Content] otherwise null,
                        infProt = try protNFe{[Name="infProt"]}[Content] otherwise null,
                        protocolo = try infProt{[Name="nProt"]}[Content]{0}[Value] otherwise null,
                        statusProtocolo = try infProt{[Name="cStat"]}[Content]{0}[Value] otherwise null,
                        dataAutorizacao = try infProt{[Name="dhRecbto"]}[Content]{0}[Value] otherwise null
                    in
                        [
                            ChaveAcesso = if chaveAcesso <> null then Text.Replace(chaveAcesso, "NFe", "") else null,
                            NumeroNF = numeroNF,
                            Serie = serie,
                            Modelo = modelo,
                            DataEmissao = if dataEmissao <> null then DateTime.FromText(dataEmissao) else null,
                            CNPJ_Emitente = cnpjEmit,
                            Nome_Emitente = nomeEmit,
                            CNPJ_CPF_Destinatario = cnpjDest,
                            Nome_Destinatario = nomeDest,
                            Valor_Total = if valorTotal <> null then Number.FromText(valorTotal) else null,
                            Base_ICMS = if baseICMS <> null then Number.FromText(baseICMS) else null,
                            Valor_ICMS = if valorICMS <> null then Number.FromText(valorICMS) else null,
                            Valor_Produtos = if valorProdutos <> null then Number.FromText(valorProdutos) else null,
                            Valor_Frete = if valorFrete <> null then Number.FromText(valorFrete) else null,
                            Valor_Desconto = if valorDesconto <> null then Number.FromText(valorDesconto) else null,
                            Valor_IPI = if valorIPI <> null then Number.FromText(valorIPI) else null,
                            Valor_PIS = if valorPIS <> null then Number.FromText(valorPIS) else null,
                            Valor_COFINS = if valorCOFINS <> null then Number.FromText(valorCOFINS) else null,
                            Protocolo = protocolo,
                            Status_Protocolo = statusProtocolo,
                            Data_Autorizacao = if dataAutorizacao <> null then DateTime.FromText(dataAutorizacao) else null
                        ]
                else
                    // Se não for nfeProc, tenta estrutura simplificada
                    let
                        NFe = try xml{0}[Content] otherwise null,
                        infNFe = try NFe{0}[Content] otherwise null,
                        ide = try infNFe{0}[Content] otherwise null,
                        numeroNF = try ide{[Name="nNF"]}[Content]{0}[Value] otherwise null,
                        chaveAcesso = try infNFe[Attributes][Id] otherwise null
                    in
                        [
                            ChaveAcesso = if chaveAcesso <> null then Text.Replace(chaveAcesso, "NFe", "") else null,
                            NumeroNF = numeroNF,
                            Serie = null,
                            Modelo = null,
                            DataEmissao = null,
                            CNPJ_Emitente = null,
                            Nome_Emitente = null,
                            CNPJ_CPF_Destinatario = null,
                            Nome_Destinatario = null,
                            Valor_Total = null,
                            Base_ICMS = null,
                            Valor_ICMS = null,
                            Valor_Produtos = null,
                            Valor_Frete = null,
                            Valor_Desconto = null,
                            Valor_IPI = null,
                            Valor_PIS = null,
                            Valor_COFINS = null,
                            Protocolo = null,
                            Status_Protocolo = null,
                            Data_Autorizacao = null
                        ]
        in
            dadosNFe,
    
    // Adiciona coluna com dados extraídos da NFe
    ComDadosNFe = Table.AddColumn(ArquivosXML, "DadosNFe", each 
        try ExtrairDadosNFe([Content]) 
        otherwise [
            ChaveAcesso = "ERRO",
            NumeroNF = "ERRO",
            Serie = null,
            Modelo = null,
            DataEmissao = null,
            CNPJ_Emitente = null,
            Nome_Emitente = null,
            CNPJ_CPF_Destinatario = null,
            Nome_Destinatario = null,
            Valor_Total = null,
            Base_ICMS = null,
            Valor_ICMS = null,
            Valor_Produtos = null,
            Valor_Frete = null,
            Valor_Desconto = null,
            Valor_IPI = null,
            Valor_PIS = null,
            Valor_COFINS = null,
            Protocolo = null,
            Status_Protocolo = null,
            Data_Autorizacao = null
        ]),
    
    // Expande os dados da NFe em colunas separadas
    ExpandirDados = Table.ExpandRecordColumn(ComDadosNFe, "DadosNFe", 
        {"ChaveAcesso", "NumeroNF", "Serie", "Modelo", "DataEmissao", 
         "CNPJ_Emitente", "Nome_Emitente", "CNPJ_CPF_Destinatario", "Nome_Destinatario",
         "Valor_Total", "Base_ICMS", "Valor_ICMS", "Valor_Produtos", 
         "Valor_Frete", "Valor_Desconto", "Valor_IPI", "Valor_PIS", "Valor_COFINS",
         "Protocolo", "Status_Protocolo", "Data_Autorizacao"}),
    
    // Adiciona coluna com nome do arquivo para referência
    ComNomeArquivo = Table.AddColumn(ExpandirDados, "Arquivo_Origem", each [Name]),
    
    // Remove colunas desnecessárias
    ColunasFinal = Table.SelectColumns(ComNomeArquivo, {
        "Arquivo_Origem", "ChaveAcesso", "NumeroNF", "Serie", "Modelo", "DataEmissao",
        "CNPJ_Emitente", "Nome_Emitente", "CNPJ_CPF_Destinatario", "Nome_Destinatario",
        "Valor_Total", "Base_ICMS", "Valor_ICMS", "Valor_Produtos", 
        "Valor_Frete", "Valor_Desconto", "Valor_IPI", "Valor_PIS", "Valor_COFINS",
        "Protocolo", "Status_Protocolo", "Data_Autorizacao"
    }),
    
    // Ordena por data de emissão
    Ordenado = Table.Sort(ColunasFinal, {{"DataEmissao", Order.Descending}})
    
in
    Ordenado