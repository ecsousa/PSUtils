
open System

// Método para processar arquivos xml
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

// Método para ler arquivos xml
let lerXml<'a> (namespaces: (string*string) list) (arquivo: string) processamento : 'a =
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


