
#r "Microsoft.TeamFoundation.Client"
#r "Microsoft.TeamFoundation.VersionControl.Common"
#r "Microsoft.TeamFoundation.VersionControl.Client"

open System
open System.IO
open System.Diagnostics
open System.Text.RegularExpressions
open Microsoft.TeamFoundation.Client
open Microsoft.TeamFoundation.VersionControl.Client

exception NotFoundInTFS of string list

if fsi.CommandLineArgs.Length < 2 then
    printfn "É necessário infomar o(s) arquivo(s) .pdb a ser(em) indexado(s)"
    Environment.Exit(1)

let relativePath file =
    let myPath = FileInfo(fsi.CommandLineArgs.[0]).DirectoryName
    Path.Combine(myPath, file)

let pdbstrPath = relativePath @"dbgtools\pdbstr.exe"
let srctoolPath = relativePath @"dbgtools\srctool.exe"

let execute fileName arguments =
    let psi = ProcessStartInfo(fileName, arguments)
    psi.UseShellExecute <- false
    psi.CreateNoWindow <- true

    let proc = Process.Start(psi)

    proc.WaitForExit()

let executeRead fileName arguments =
    let psi = ProcessStartInfo(fileName, arguments)
    psi.UseShellExecute <- false
    psi.CreateNoWindow <- true
    psi.RedirectStandardOutput <- true

    let proc = Process.Start(psi)

    let line = ref null

    seq {
        line := proc.StandardOutput.ReadLine()
        while !line <> null do
            yield !line
            line := proc.StandardOutput.ReadLine()
    }

let makeSrcsrv pdb = 
    let readPdb pdb =
        let arguments = sprintf "-r %s" pdb
        executeRead srctoolPath arguments

    let infoFiles =
        readPdb pdb
        |> Seq.toList
        |> Seq.groupBy (fun file -> Workstation.Current.GetLocalWorkspaceInfo(file))
        |> Seq.toList

    let serverName (wi: WorkspaceInfo) =
        "_" + (Regex.Replace(wi.ServerUri.ToString(), "[^\w]", "_")).ToUpper()

    seq {

        yield "SRCSRV: ini ------------------------------------------------"
        yield "VERSION=3"
        yield "INDEXVERSION=2"
        yield "VERCTRL=Team Foundation Server"
        yield (sprintf "DATETIME=%s" (DateTime.Now.ToString("yyyy/MM/dd HH:mm:ss.fff")))
        yield "SRCSRV: variables ------------------------------------------"
        yield "TFS_EXTRACT_CMD=tf.exe view /version:%var4% /noprompt \"$%var3%\" /server:%fnvar%(%var2%) /console >%srcsrvtrg%"
        yield "TFS_EXTRACT_TARGET=%targ%\%var2%%fnbksl%(%var3%)\%var4%\%fnfile%(%var1%)"
        yield "SRCSRVVERCTRL=tfs"
        yield "SRCSRVERRDESC=access"
        yield "SRCSRVERRVAR=var2"

        for info in infoFiles do
            let wi = fst info

            if wi = null then
                raise (NotFoundInTFS (snd info |> Seq.toList))

            yield (sprintf "%s=%s" (serverName wi)) (wi.ServerUri.ToString())

        yield "SRCSRVTRG=%TFS_extract_target%"
        yield "SRCSRVCMD=%TFS_extract_cmd%"
        yield "SRCSRV: source files ---------------------------------------"

        for info in infoFiles do
            let wi = fst info
            use tpc = new TfsTeamProjectCollection(wi.ServerUri)
            let vcs = tpc.GetService<VersionControlServer>()
            let wsp = vcs.GetWorkspace(wi)

            let specs =
                snd info
                |> Seq.map (fun file -> ItemSpec(file, RecursionType.None))
                |> Seq.toArray

            let locals =
                wsp.GetLocalVersions(specs, false)
                |> Seq.collect id

            for local in locals do
                yield (sprintf "%s*%s*%s*%d" local.Item (serverName wi) (wsp.GetServerItemForLocalItem local.Item) local.Version)

        yield "SRCSRV: end ------------------------------------------------"
    }

let writeSrcsrv pdb =
    let tempFile = Path.Combine((Environment.GetEnvironmentVariable("TEMP")), (Guid.NewGuid().ToString() + ".txt"))

    File.AppendAllLines(tempFile, (makeSrcsrv pdb))

    try
        let arguments = (sprintf "-w -p:%s -s:srcsrv -i:%s" pdb tempFile)
        execute pdbstrPath arguments
    finally
        File.Delete(tempFile)

let regPattern = Regex(@"^(.*\\)?([^\\]+)$")
for filePattern in Seq.skip 1 fsi.CommandLineArgs do
    let mat = regPattern.Match(filePattern)

    for pdbFile in Directory.EnumerateFiles((if mat.Groups.[1].Length = 0 then "." else mat.Groups.[1].Value), mat.Groups.[2].Value) do
        printf "[__] Indexando arquivo %s..." pdbFile
        try
            writeSrcsrv pdbFile
            printfn "\r[OK] Indexando arquivo %s..." pdbFile
        with
            | NotFoundInTFS notFoundFiles ->
                printfn "\r[ERRO] Não foi possível indexar arquivo %s" pdbFile
                printfn "Os seguintes arquivos não foram encontrados no TFS:"
                for notFoundFile in notFoundFiles do
                    printfn " - %s" notFoundFile

