# PSUtils

PSUtils is a PowerShell module containing several utility scripts.

To get a full list of all its command, execute the following command
after PSUtils is imported into PowerShell:

    (Get-Module PSUtils).ExportedCommands

(PS: you will probably need to execute PowerShell with `-ExecutionPolicy RemoteSigned`
command line option)

## Import Module

To import PSUtils module, you just have to execute the following
command in PowerShell:

    Import-Module <Path to PSUtils folder>

(as you would with any other PowerShell script module)

Alternatively, if the PSUtils parent folder is listed
in PSModulePath environment variable, you can just execute:

    Import-Module PSUtils

If PSUtils is already imported, and you went to reload it after and
update, you will have to execute:

    Import-Module PSUtils -Force

## ConEmu

PSUtil works greatly with [ConEmu](https://code.google.com/p/conemu-maximus5/)!
It have a script to install its lastest version. If you execute the
following PSUtils command:

    Install-ConEmu

it will install ConEmu at PSUtils parent folder, and configure it to open
Powershell in startup with PSUtils module imported.

Alternatively, you can execute Install-ConEmu.cmd CMD script, which will execute
PowerShell, install ConEmu as described above, and then execute it.

## Bootstrap installing

You can also easily install PSUtils and ConEmu in any given folder by executing the following
command in PowerShell inside the folder where they should be installed:

    Invoke-Expression (Invoke-WebRequest https://bitbucket.org/ecsousa/psutils/raw/HEAD/bootstrapInstall.ps1).Content

PS:

* It will also install Git client if not found
* ConEmu will only be installed if PowerShell is **NOT** in restricted execution policy.
 
---

Hope you'll all enjoy it!