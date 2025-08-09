let
    // Função para extrair dados específicos da NFe
    ExtrairDadosNFe = (xml as binary) =>
        let
            // Converter binary para text
            xmlText = Text.FromBinary(xml),
            
            // Parse do XML
            xmlDoc = Xml.Document(xmlText),
            
            // Navegar para o nó NFe
            nfeNode = xmlDoc{0}[Value]{0}[Value],
            infNFe = nfeNode{0}[Value],
            
            // Extrair dados básicos da identificação
            ide = infNFe{0}[Value],
            nNF = try ide{5}[Value] otherwise null,
            serie = try ide{4}[Value] otherwise null,
            dhEmi = try ide{6}[Value] otherwise null,
            natOp = try ide{2}[Value] otherwise null,
            
            // Extrair dados do emitente
            emit = infNFe{1}[Value],
            cnpjEmit = try emit{0}[Value] otherwise null,
            xNomeEmit = try emit{1}[Value] otherwise null,
            xFantEmit = try emit{2}[Value] otherwise null,
            
            // Extrair endereço do emitente
            enderEmit = try emit{3}[Value] otherwise null,
            xLgrEmit = try enderEmit{0}[Value] otherwise null,
            nroEmit = try enderEmit{1}[Value] otherwise null,
            xBairroEmit = try enderEmit{2}[Value] otherwise null,
            xMunEmit = try enderEmit{4}[Value] otherwise null,
            ufEmit = try enderEmit{5}[Value] otherwise null,
            cepEmit = try enderEmit{6}[Value] otherwise null,
            
            // Extrair dados do destinatário
            dest = infNFe{2}[Value],
            cpfCnpjDest = try (if Table.HasColumns(Table.FromRecords({dest{0}}), "Name") 
                               then if dest{0}[Name] = "CPF" then dest{0}[Value] 
                               else if dest{0}[Name] = "CNPJ" then dest{0}[Value] 
                               else null 
                               else null) otherwise null,
            xNomeDest = try dest{1}[Value] otherwise null,
            
            // Extrair endereço do destinatário
            enderDest = try dest{2}[Value] otherwise null,
            xLgrDest = try enderDest{0}[Value] otherwise null,
            nroDest = try enderDest{1}[Value] otherwise null,
            xBairroDest = try enderDest{2}[Value] otherwise null,
            xMunDest = try enderDest{4}[Value] otherwise null,
            ufDest = try enderDest{5}[Value] otherwise null,
            cepDest = try enderDest{6}[Value] otherwise null,
            
            // Extrair dados dos totais
            total = try infNFe{List.Count(infNFe) - 3}[Value] otherwise null,
            icmsTot = try total{0}[Value] otherwise null,
            vBC = try icmsTot{0}[Value] otherwise null,
            vICMS = try icmsTot{1}[Value] otherwise null,
            vProd = try icmsTot{12}[Value] otherwise null,
            vFrete = try icmsTot{13}[Value] otherwise null,
            vSeg = try icmsTot{14}[Value] otherwise null,
            vDesc = try icmsTot{15}[Value] otherwise null,
            vII = try icmsTot{16}[Value] otherwise null,
            vIPI = try icmsTot{17}[Value] otherwise null,
            vPIS = try icmsTot{19}[Value] otherwise null,
            vCOFINS = try icmsTot{20}[Value] otherwise null,
            vOutro = try icmsTot{21}[Value] otherwise null,
            vNF = try icmsTot{22}[Value] otherwise null,
            
            // Extrair chave da NFe do atributo Id
            chaveNFe = try Text.Range(infNFe[Attributes][Id], 3, 44) otherwise null,
            
            // Criar registro com os dados extraídos
            resultado = [
                ChaveNFe = chaveNFe,
                NumeroNF = nNF,
                Serie = serie,
                DataEmissao = dhEmi,
                NaturezaOperacao = natOp,
                CNPJEmitente = cnpjEmit,
                NomeEmitente = xNomeEmit,
                FantasiaEmitente = xFantEmit,
                LogradouroEmitente = xLgrEmit,
                NumeroEmitente = nroEmit,
                BairroEmitente = xBairroEmit,
                MunicipioEmitente = xMunEmit,
                UFEmitente = ufEmit,
                CEPEmitente = cepEmit,
                CPFCNPJDestinatario = cpfCnpjDest,
                NomeDestinatario = xNomeDest,
                LogradouroDestinatario = xLgrDest,
                NumeroDestinatario = nroDest,
                BairroDestinatario = xBairroDest,
                MunicipioDestinatario = xMunDest,
                UFDestinatario = ufDest,
                CEPDestinatario = cepDest,
                BaseCalculoICMS = vBC,
                ValorICMS = vICMS,
                ValorProdutos = vProd,
                ValorFrete = vFrete,
                ValorSeguro = vSeg,
                ValorDesconto = vDesc,
                ValorII = vII,
                ValorIPI = vIPI,
                ValorPIS = vPIS,
                ValorCOFINS = vCOFINS,
                ValorOutros = vOutro,
                ValorTotalNF = vNF
            ]
        in
            resultado,
    
    // Configurar o diretório dos arquivos XML
    // ALTERE ESTE CAMINHO PARA O SEU DIRETÓRIO
    CaminhoArquivos = "C:\Temp\NFe\",
    
    // Listar todos os arquivos XML do diretório
    Fonte = Folder.Files(CaminhoArquivos),
    
    // Filtrar apenas arquivos XML
    ArquivosXML = Table.SelectRows(Fonte, each Text.EndsWith([Name], ".xml")),
    
    // Adicionar coluna com dados extraídos da NFe
    ComDadosNFe = Table.AddColumn(ArquivosXML, "DadosNFe", each 
        try ExtrairDadosNFe([Content]) 
        otherwise [
            ChaveNFe = "ERRO",
            NumeroNF = "ERRO",
            Serie = "ERRO",
            DataEmissao = "ERRO",
            NaturezaOperacao = "ERRO",
            CNPJEmitente = "ERRO",
            NomeEmitente = "ERRO",
            FantasiaEmitente = "ERRO",
            LogradouroEmitente = "ERRO",
            NumeroEmitente = "ERRO",
            BairroEmitente = "ERRO",
            MunicipioEmitente = "ERRO",
            UFEmitente = "ERRO",
            CEPEmitente = "ERRO",
            CPFCNPJDestinatario = "ERRO",
            NomeDestinatario = "ERRO",
            LogradouroDestinatario = "ERRO",
            NumeroDestinatario = "ERRO",
            BairroDestinatario = "ERRO",
            MunicipioDestinatario = "ERRO",
            UFDestinatario = "ERRO",
            CEPDestinatario = "ERRO",
            BaseCalculoICMS = "ERRO",
            ValorICMS = "ERRO",
            ValorProdutos = "ERRO",
            ValorFrete = "ERRO",
            ValorSeguro = "ERRO",
            ValorDesconto = "ERRO",
            ValorII = "ERRO",
            ValorIPI = "ERRO",
            ValorPIS = "ERRO",
            ValorCOFINS = "ERRO",
            ValorOutros = "ERRO",
            ValorTotalNF = "ERRO"
        ]
    ),
    
    // Expandir os dados da NFe em colunas separadas
    DadosExpandidos = Table.ExpandRecordColumn(ComDadosNFe, "DadosNFe", 
        {"ChaveNFe", "NumeroNF", "Serie", "DataEmissao", "NaturezaOperacao", 
         "CNPJEmitente", "NomeEmitente", "FantasiaEmitente", "LogradouroEmitente", 
         "NumeroEmitente", "BairroEmitente", "MunicipioEmitente", "UFEmitente", "CEPEmitente",
         "CPFCNPJDestinatario", "NomeDestinatario", "LogradouroDestinatario", 
         "NumeroDestinatario", "BairroDestinatario", "MunicipioDestinatario", "UFDestinatario", "CEPDestinatario",
         "BaseCalculoICMS", "ValorICMS", "ValorProdutos", "ValorFrete", "ValorSeguro", 
         "ValorDesconto", "ValorII", "ValorIPI", "ValorPIS", "ValorCOFINS", "ValorOutros", "ValorTotalNF"},
        {"ChaveNFe", "NumeroNF", "Serie", "DataEmissao", "NaturezaOperacao", 
         "CNPJEmitente", "NomeEmitente", "FantasiaEmitente", "LogradouroEmitente", 
         "NumeroEmitente", "BairroEmitente", "MunicipioEmitente", "UFEmitente", "CEPEmitente",
         "CPFCNPJDestinatario", "NomeDestinatario", "LogradouroDestinatario", 
         "NumeroDestinatario", "BairroDestinatario", "MunicipioDestinatario", "UFDestinatario", "CEPDestinatario",
         "BaseCalculoICMS", "ValorICMS", "ValorProdutos", "ValorFrete", "ValorSeguro", 
         "ValorDesconto", "ValorII", "ValorIPI", "ValorPIS", "ValorCOFINS", "ValorOutros", "ValorTotalNF"}),
    
    // Remover colunas desnecessárias e manter apenas as relevantes
    ColunasSelecionadas = Table.SelectColumns(DadosExpandidos, 
        {"Name", "ChaveNFe", "NumeroNF", "Serie", "DataEmissao", "NaturezaOperacao", 
         "CNPJEmitente", "NomeEmitente", "FantasiaEmitente", 
         "CPFCNPJDestinatario", "NomeDestinatario", 
         "BaseCalculoICMS", "ValorICMS", "ValorProdutos", "ValorFrete", "ValorSeguro", 
         "ValorDesconto", "ValorII", "ValorIPI", "ValorPIS", "ValorCOFINS", "ValorOutros", "ValorTotalNF"}),
    
    // Renomear a coluna Name para NomeArquivo
    TabelaFinal = Table.RenameColumns(ColunasSelecionadas, {{"Name", "NomeArquivo"}}),
    
    // Converter tipos de dados apropriados
    TiposConvertidos = Table.TransformColumnTypes(TabelaFinal,{
        {"NumeroNF", Int64.Type}, 
        {"Serie", Int64.Type}, 
        {"DataEmissao", type datetime}, 
        {"BaseCalculoICMS", type number}, 
        {"ValorICMS", type number}, 
        {"ValorProdutos", type number}, 
        {"ValorFrete", type number}, 
        {"ValorSeguro", type number}, 
        {"ValorDesconto", type number}, 
        {"ValorII", type number}, 
        {"ValorIPI", type number}, 
        {"ValorPIS", type number}, 
        {"ValorCOFINS", type number}, 
        {"ValorOutros", type number}, 
        {"ValorTotalNF", type number}
    })
in
    TiposConvertidos