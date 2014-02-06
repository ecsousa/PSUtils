
#r "Microsoft.TeamFoundation.Client"
#r "Microsoft.TeamFoundation.VersionControl.Common"
#r "Microsoft.TeamFoundation.VersionControl.Client"

open System
open System.IO
open System.Diagnostics
open System.Text.RegularExpressions
open Microsoft.TeamFoundation.Client
open Microsoft.TeamFoundation.VersionControl.Client

if fsi.CommandLineArgs.Length < 2 then
    printfn "É necessário infomar o arquivo .pdb a ser indexado"
    Environment.Exit(1)

let relativePath file =
    let myPath = FileInfo(fsi.CommandLineArgs.[0]).DirectoryName
    Path.Combine(myPath, file)

let pdbstrPath = relativePath @"dbgtools\pdbstr.exe"
let srctoolPath = relativePath @"dbgtools\srctool.exe"

let pdb = fsi.CommandLineArgs.[1]

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
                printfn "Não é possível indexar o arquivo .pdb. Os seguintes arquivos não foram encontrados em um Workspace do TFS:"
                for file in snd info do
                    printfn " - %s" file
                Environment.Exit(1)

            yield (sprintf "%s=%s" (serverName wi)) (wi.ServerUri.ToString())

        yield "SRCSRVTRG=%TFS_extract_target%"
        yield "SRCSRVCMD=%TFS_extract_cmd%"
        yield "SRCSRV: source files ---------------------------------------"

        for info in infoFiles do
            let wi = fst info
            use tpc = new TfsTeamProjectCollection(wi.ServerUri)
            let vcs = tpc.GetService<VersionControlServer>()
            let wsp = vcs.GetWorkspace(wi)

            for file in snd info do
                let item = vcs.GetItem(file)
                yield (sprintf "%s*%s*%s*%d" file (serverName wi) item.ServerItem item.ChangesetId)

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

writeSrcsrv pdb

