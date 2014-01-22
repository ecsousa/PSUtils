
#r "Microsoft.TeamFoundation.Client"
#r "Microsoft.TeamFoundation.VersionControl.Common"
#r "Microsoft.TeamFoundation.VersionControl.Client"

open System
open System.IO
open System.Text.RegularExpressions
open Microsoft.TeamFoundation.Client
open Microsoft.TeamFoundation.VersionControl.Client


// Define a tupla com os prefixos a serem alterados, e suas respectivas vers�es
// Baseado em um arquivo texto, contendo prefixo do pacote, e vers�o

let regLinha = Regex("^(\S+)\s+(\S+)$")

let prefixes =
    let arquivo =
        if fsi.CommandLineArgs.Length > 1 then
            fsi.CommandLineArgs.[1]
        else
            "refs.txt"

    if not (File.Exists(arquivo)) then
        failwith (sprintf "Arquivo %s nao existe" arquivo)

    seq {
        for linha in File.ReadAllLines(arquivo) do
            let m = regLinha.Match(linha)

            if not (m.Success) then
                failwith (sprintf "Linha incorreta no arquivo %s: %s" arquivo linha)

            yield m.Groups.[1].Value, m.Groups.[2].Value
    }
    |> Seq.toList

// M�todo para processar arquivos xml
let processarXml (namespaces: (string*string) list) (arquivo: string) processamento =
    let xml = Xml.XmlDocument()
    xml.Load(arquivo)

    let xnm = Xml.XmlNamespaceManager(xml.NameTable)
    for ns in namespaces do
        xnm.AddNamespace((fst ns), (snd ns))

    let selectNodes xpath =
        seq {
            for node in xml.SelectNodes(xpath, xnm) do
                yield node, xnm
        }

    processamento selectNodes

    xml.Save(arquivo)

// Obter lista de arquivo packages.config do diret�rio
let packages =
    Directory.EnumerateFiles(".", "packages.config", SearchOption.AllDirectories)
    |> Seq.map id

// Obter lista de arquivo .csproj do diret�rio
let csprojs =
    Directory.EnumerateFiles(".", "*.csproj", SearchOption.AllDirectories)
    |> Seq.map id

//Obter workspace do diret�rio atual
let wi = Workstation.Current.GetLocalWorkspaceInfo(".")

if wi <> null then
    //Montar objetos de conex�o com o TFS
    use tpc = new TfsTeamProjectCollection(wi.ServerUri);
    let vcs = tpc.GetService<VersionControlServer>();
    let wsp = vcs.GetWorkspace(wi);

    // M�todo para realizar checkout nos arquivos que ser�o alterados
    let filesToCheckout =
        packages
        |> Seq.append csprojs
        |> Seq.where (fun item ->
            vcs.ServerItemExists(item, ItemType.Any))
        |> Seq.toArray

    if filesToCheckout.Length > 0 then
        if wsp.PendEdit filesToCheckout < filesToCheckout.Length then
            failwith (sprintf "Nao foi possivel realizaer checkout de um ou mais arquivos")
        else
            printfn "Checkouts efetuados com sucesso!"


// Percorrer arquivos packages.conofig
for pkg in packages do

    try
        processarXml [] pkg (fun selectNodes ->
            for node, _ in selectNodes "/packages/package" do
                // Para cada pacote, testar se ele est� em algum prefixo
                for prefix, version in prefixes do
                    if node.Attributes.["id"].Value.ToLower().StartsWith (prefix.ToLower()) then
                        // Se estiver, alterar vers�o do pacote
                        node.Attributes.["version"].Value <- version
        )
        printfn "Arquivo %s processando com sucesso." pkg
    with
        | ex ->
            printfn "Erro ao processar arquivo %s!" pkg
            printfn "Mensagem: %s" (ex.Message)
            printfn "Stacktrace: %s" ex.StackTrace
            printfn ""
        
     
// Expresss�o regular para alterar a vers�o de refer�ncia do nome de um assembly
let verRegex = Regex(@"(?i)\b(Version=)(\d+(?:\.\d+){0,3})")

// Fun��o para normalizar vers�o
// Ex: "04.008.000.018-alpha" -> "4.0.0.18"
let normVer (ver: String) =
    let verPart = ver.Split([| '-' |]) |> Seq.head
    String.Join(".", verPart.Split([| '.' |])
        |> Seq.map (fun x -> Int32.Parse(x).ToString()))

// Compor, para cada prefixo, a express�o regular para localizar a parte do nome do
// diret�rio que precisa ser alterado
let prefixesReg =
    prefixes
    |> List.map (fun (prefix, version) ->
        prefix, version,
        Regex((sprintf  @"(?i)\\(%s[^\\]*)\\" (Regex.Escape prefix)))
        )

// Precorrer arquivos .csproj
for csproj in csprojs do

    try
        processarXml ["p", "http://schemas.microsoft.com/developer/msbuild/2003"] csproj (fun selectNodes ->
            // Selecionar as refer�ncias que possuem HintPath
            for node, xnm in selectNodes "/p:Project/p:ItemGroup/p:Reference[p:HintPath]" do
                for prefix, version, reg in prefixesReg do
                    // Testar quais refer�ncias iniciam-se com algum prefixo da lista
                    if node.Attributes.["Include"].Value.ToLower().StartsWith (prefix.ToLower()) then
                        // Alterar vers�o no nome de assembly de refer�ncia
                        node.Attributes.["Include"].Value <- verRegex.Replace (node.Attributes.["Include"].Value, "${1}" + (normVer version))
                        
                        // Alterar nome do diret�rio no HintPath
                        let hintNode = node.SelectSingleNode("p:HintPath", xnm)
                        hintNode.InnerText <- (reg.Replace(hintNode.InnerText, (sprintf "\\%s.%s\\" prefix version )))
        )

        printfn "Arquivo %s processando com sucesso." csproj
    with
        | ex ->
            printfn "Erro ao processar arquivo %s!" csproj
            printfn "Mensagem: %s" (ex.Message)
            printfn "Stacktrace: %s" ex.StackTrace
            printfn ""
        
        

