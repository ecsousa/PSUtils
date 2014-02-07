
#r "Microsoft.TeamFoundation.Client"
#r "Microsoft.TeamFoundation.VersionControl.Common"
#r "Microsoft.TeamFoundation.VersionControl.Client"

open System
open System.IO
open System.Diagnostics
open System.Text.RegularExpressions
open Microsoft.TeamFoundation.Client
open Microsoft.TeamFoundation.VersionControl.Client


let relativePath file =
#if INTERACTIVE    
    let myFile = fsi.CommandLineArgs.[0]
#else
    let myFile = Reflection.Assembly.GetEntryAssembly().Location
#endif
    let myPath = FileInfo(myFile).DirectoryName
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

    let indexed = ref false

    let srcsrv =
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

            let infoFilesInTfs =
                infoFiles
                |> Seq.where( fun info -> (fst info) <> null)

            for info in infoFiles do
                let wi = fst info
                if wi = null then
                    for file in (snd info) do
                        printfn " - Arquivo %s não encontrado no TFS." file
                else
                    yield (sprintf "%s=%s" (serverName wi)) (wi.ServerUri.ToString())

            yield "SRCSRVTRG=%TFS_extract_target%"
            yield "SRCSRVCMD=%TFS_extract_cmd%"
            yield "SRCSRV: source files ---------------------------------------"

            for info in infoFilesInTfs do
                let wi = fst info
                use tpc = new TfsTeamProjectCollection(wi.ServerUri)
                let vcs = tpc.GetService<VersionControlServer>()
                let wsp = vcs.GetWorkspace(wi)

                let specs =
                    snd info
                    |> Seq.map (fun file -> ItemSpec(file, RecursionType.None))
                    |> Seq.toArray

                let penddingChanges =
                    wsp.GetPendingChanges(specs)

                for pend in penddingChanges do
                    printfn " - Arquivo %s está em checkout e não será indexado" pend.LocalItem

                let isPedding (item: string) =
                    let lowerItem = item.ToLower()
                    penddingChanges
                    |> Seq.exists (fun pend -> pend.LocalItem.ToLower() = lowerItem)

                let locals =
                    wsp.GetLocalVersions(specs, false)
                    |> Seq.collect id
                    |> Seq.where (fun local -> not (isPedding local.Item))

                for local in locals do
                    indexed := true
                    yield (sprintf "%s*%s*%s*%d" local.Item (serverName wi) (wsp.GetServerItemForLocalItem local.Item) local.Version)

            yield "SRCSRV: end ------------------------------------------------"
        }
        |> Seq.toList

    srcsrv,!indexed

let writeSrcsrv pdb =
    let tempFile = Path.Combine((Environment.GetEnvironmentVariable("TEMP")), (Guid.NewGuid().ToString() + ".txt"))


    match makeSrcsrv pdb with
        | _,false -> false
        | srcsrv,true ->
            File.AppendAllLines(tempFile, srcsrv)

            try
                let arguments = (sprintf "-w -p:%s -s:srcsrv -i:%s" pdb tempFile)
                execute pdbstrPath arguments
            finally
                File.Delete(tempFile)
            true


let regPattern = Regex(@"^(.*\\)?([^\\]+)$")

#if COMPILED
[<EntryPoint>]
#endif
let main(args: string[]) =  
    if args.Length = 0 then
        printfn "É necessário infomar o(s) arquivo(s) .pdb a ser(em) indexado(s)"
        1
    else
        for filePattern in args do
            let mat = regPattern.Match(filePattern)

            for pdbFile in Directory.EnumerateFiles((if mat.Groups.[1].Length = 0 then "." else mat.Groups.[1].Value), mat.Groups.[2].Value) do
                printfn "Indexando arquivo %s..." pdbFile
                if writeSrcsrv pdbFile then
                    printfn "Arquivo %s indexado" pdbFile
                else
                    printfn "Arquivo %s não foi indexado" pdbFile
        0

#if INTERACTIVE
main (Seq.skip 1 (fsi.CommandLineArgs) |> Seq.toArray)
#endif
