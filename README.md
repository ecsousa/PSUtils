# PSUtils

PSUtils is a PowerShell module containing several utility scripts.

Please refer to [PSUtils Wiki](https://github.com/ecsousa/PSUtils/wiki)
to learn more about its functions.

_(PS: you will probably need to execute PowerShell with `-ExecutionPolicy RemoteSigned`
command line option)_

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

*PS: This will require PowerShell 3.0*

## PSUtils Launcher

If you want an easy way to download PSUtils module, and integrate it with ConEmu, you can just jump
to [PSUtils Launcher](https://github.com/ecsousa/PSUtilsLauncher/releases/latest). It's a small
executable (requieres .NET 4.0), which will download PSUtils repository and ConEmu (if not present - ConEmu
download will requiere PowerShell 3.0).

Also, it will keep PSUtils up to date.

It does not requiere native Git client installed.
 
---

Hope you'll all enjoy it!
