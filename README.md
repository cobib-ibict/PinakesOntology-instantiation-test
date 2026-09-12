 Teste de Instanciação e Integração Semântica: Ontologia Pinakes e Base MARC/XML

  
### 1. ESTRUTURA RECOMENDADA DO REPOSITÓRIO pinakes-obda-test/
### ├── docs/
### │   └── quadro_correspondencia_marc21_pinakes
### │├── data/
### ││   ├── pinakes_marc.sql (com MARC_XML_TABLE)
### ││   └── pinakes_marc.csv
### │├── ontology/
### ││   ├── ontology.rdf
### ││   ├── ontology.obda
### ││   └── ontology.properties
### │├── queries/
### ││   ├── consulta_validacao_periodicos.sparql
### ││   └── consulta_checagem_issn.sparql
### │└── README.md

---------------------------------------------------------------------------------------------------
  
 ## 2. QUADRO DE CORRESPONDÊNCIA MARC21 X ONTOLOGIA PINAKES (ver https://docs.google.com/spreadsheets/d/108g3mGr87Xc4p03HaC37cS08C9pe97AvHK-mBhkBp4s/edit?usp=sharing)
  

  ---------------------------------------------------------------------------------------------------
 ## 3. ESPECIFICAÇÃO DO MAPEAMENTO OBDA (ver ontology.obda)
  
---------------------------------------------------------------------------------------------------

  
 ## 4. CONFIGURAÇÃO DE CONEXÃO JDBC (pinakes_marc_mapping.properties)
  
jdbc.url=jdbc:mysql: jdbc:mysql://escrevaSualocalhost/escervaNomebancodedadosgerado
jdbc.driver=com.mysql.cj.jdbc.Driver
jdbc.user=seu_usuario (root)
jdbc.password=sua_senha (ignorar)

 --------------------------------------------------------------------------------------------------- 
 ## 5. REQUISITOS E PROCEDIMENTO DE CONFIGURAÇÃO DO AMBIENTE
  
 Requisitos de Software:
 1. Protégé Desktop (versão 5.5 ou superior).
 2. Plugin Ontop para Protégé (versão 4.2 ou superior. Já ativado nas versões recentes do  Protégé).
 3. MySQL Server (versão 8.0 ou superior) (ou outro banco compativel com Ontop).
 4. Java Development Kit (JDK) versão 11 ou superior. (para MySQL)
 5. Ativar o JDBC Drivers com o arquivo jar no menu preferencias do Protégé


 Criação e Carga do Banco de Dados Relacional no MySQL pinakes_marc.sql:
 Comando SQL 1: CREATE DATABASE pinakes_marc_db CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
 Comando de carga no terminal: mysql -u seu_usuario -p pinakes_marc_db < data/pinakes_marc.sql

 Execução no Protégé via Ontop (Passo a Passo):
 1. Abra o Protégé e carregue o arquivo RDF ontology.owl.
 2. No menu superior, selecione Reasoner -> Ontop.
 3. Acesse a aba Ontop Mappings (Window -> Views -> Mappings views -> Ontop Mappings).
 4. Copie o código das declarações do ontology.obda  e cole na interface do editor de mapeamentos do Ontop. 
 5. Verifique se o arquivo ontology.properties está presente no mesmo diretório ou configure os parâmetros de conexão JDBC diretamente na janela de preferências do Ontop.
 6. No menu Reasoner, clique em Start Reasoner. Se a conexão estiver válida, o status do motor de inferência mudará para ativo.

 --------------------------------------------------------------------------------------------------- 
 ## 6. CONSULTAS SPARQL DE VALIDAÇÃO
  
 Consulta 1: Extração Agregada de Periódicos (Prevenção de Duplicatas)
 PREFIX : <https://cobib-ibict.github.io/ontologies/pinakes#>
 PREFIX xsd: <http://www.w3.org/2001/XMLSchema#>
 SELECT ?titulo (SAMPLE(STR(?codigoISSN)) AS ?issn) (SAMPLE(STR(?periodicidade)) AS ?frequencia) (SAMPLE(STR(?Local)) AS ?localidade) (SAMPLE(STR(?nomeEditora)) AS ?editora)
 WHERE {
   ?pub a :PublicacaoSeriada ; :tituloProprio ?titulo .
   OPTIONAL { ?pub :frequencia ?periodicidade . }
   OPTIONAL { ?pub :hasISSN ?instanciaISSN . ?instanciaISSN :descricao ?codigoISSN . }
   OPTIONAL {
     ?pub :hasPublicationDate ?imprentaObj .
     OPTIONAL { ?imprentaObj :hasPlacePublication/ :nome ?Local . }
     OPTIONAL { ?imprentaObj :hasPublisher/ :nome ?nomeEditora . }
   }
 } GROUP BY ?titulo

 Consulta 2: Checagem de Mapeamento Direto de ISSNs e Títulos
 PREFIX : <https://cobib-ibict.github.io/ontologies/pinakes#>
 SELECT ?pub ?titulo ?codigoISSN WHERE {
   ?pub a :PublicacaoSeriada ; :tituloProprio ?titulo ; :hasISSN ?instanciaISSN .
   ?instanciaISSN :descricao ?codigoISSN .
 }

 --------------------------------------------------------------------------------------------------- 
## 7. DIRETRIZES PARA TRATAMENTO DE DADOS E RESOLUÇÃO DE PROBLEMAS
 
 ## 1. Inconsistências por Campos Nulos e Cadeias Vazias na Tabela MARC_XML_TABLE:
    - Sintoma: Criação de recursos e instâncias desprovidas de propriedades descritivas no grafo.
    - Ação: Assegure que todas as cláusulas source no arquivo ontology.obda contenham explicitamente a instrução WHERE campo IS NOT NULL AND campo != ''.

 ## 2. Incompatibilidade e Tipagem de Datatypes (XML Schema):
    - Sintoma: Falha na validação de triplas e recusa de processamento pelo Reasoner.
    - Ano de Publicação (264c): O dado deve ser tipado obrigatoriamente com a marcação "{marc264c}"^^xsd:gYear no bloco target.
    - Carimbo de Data/Hora (005): O formato nativo do MARC21 (YYYYMMDDHHMMSS.F) possui a especificação técnica xsd:dateTimeStamp (ou padrão estendido ISO 8601). Para a compatibilidade com a ontologia e o SPARQL, a string precisa ser convertida no SQL de origem da cláusula source da tabela MARC_XML_TABLE para o formato estendido YYYY-MM-DDThh:mm:ss antes da atribuição ao tipo xsd:dateTime / xsd:dateTimeStamp.

 ## 3. Multiplicação Cartesiana de Registros:
    - Sintoma: Um mesmo periódico replicado em múltiplas linhas (ex.: 8 ocorrências para um único título).
    - Causa: Construção de URIs virtuais utilizando a chave primária genérica do registro (:Localidade_{identificador}) combinada à divergência de marcadores de idioma (@pt-br vs xsd:string).
    - Solução Paliativa: Utilização de consultas com GROUP BY e SAMPLE(STR()) na validação via Protégé.
    - Solução Definitiva recomendada: Refatoração do SQL no arquivo obda.obda para restringir seleções únicas na extração do CSV pinakes_marc.csv e revisão da modelagem de URIs das entidades independentes.

 ---------------------------------------------------------------------------------------------------
 ## 8. PRÓXIMOS PASSOS DO PROJETO
 
 1. Refatoração da Arquitetura de URIs: Reestruturar a criação de URIs no arquivo pinakes_marc_mapping.obda para instanciar :Localidade e :Editora como recursos globais reutilizáveis, desvinculando-os da chave do registro relacional da tabela MARC_XML_TABLE.
 2. Suporte Nativo a Campos Multivalorados: Modelar a ontologia e o arquivo de mapeamento ontologyobda para suportar múltiplos assuntos controlados (650a) e múltiplos ISSNs sem induzir a geração de produtos cartesianos.
 3. Automação de Conversão de Datatypes: Implementar rotinas SQL automatizadas no arquivo pinakes_marc_mapping.obda para formatar a data de controle 005 do MARC21 diretamente para a sintaxe aceita em xsd:dateTimeStamp.
 4. Curadoria Semântica: Promover reuniões técnicas de homologação com especialistas em catalogação do IBICT para validar a precisão semântica do cruzamento de campos.
 5. Escalonamento: Expansão e validação da camada OBDA para maior amostra dos acervos do Catálogo Coletivo Nacional (CCN) e das bibliotecas associadas.
 6. Expansão da ontologia para representar mais campos MARC21 XML.
