
namespace TFS

#r "Microsoft.TeamFoundation.Client"
#r "Microsoft.TeamFoundation.VersionControl.Common"
#r "Microsoft.TeamFoundation.VersionControl.Client"

open Microsoft.TeamFoundation.Client
open Microsoft.TeamFoundation.VersionControl.Client

exception WorkspaceNotFound of string

type TFSConnection(workspaceDirectory) =
    
    let workspaceInfo = Workstation.Current.GetLocalWorkspaceInfo(workspaceDirectory)

    let tfsConnection =
        if workspaceInfo = null then
            raise (WorkspaceNotFound workspaceDirectory)    
        new TfsTeamProjectCollection(workspaceInfo.ServerUri)

    let mutable versionControlServerOption = None
    let mutable workspaceOption = None

    new() = new TFSConnection(".")

    member this.VersionControlServer
        with get() =
            match versionControlServerOption with
                | Some(value) -> value
                | None ->
                    let instance = tfsConnection.GetService<VersionControlServer>();
                    versionControlServerOption <- Some(instance)
                    instance

    member this.Workspace
        with get() =
            match workspaceOption with
                | Some(value) -> value
                | None ->
                    let instance = this.VersionControlServer.GetWorkspace(workspaceInfo)
                    workspaceOption <- Some(instance)
                    instance

    interface System.IDisposable with
        member this.Dispose() =
            tfsConnection.Dispose()
        
            
