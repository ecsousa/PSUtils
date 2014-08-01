$host.UI.RawUI.ForegroundColor = 'Gray'

if($host.UI.RawUI.BackgroundColor -ne 'Black') {
    $host.UI.RawUI.BackgroundColor = 'Black'
    clear
}

Write-Host PSUtils

#Detect ConEmuHk
if([Diagnostics.Process]::GetCurrentProcess().Modules | ? { ($_.ModuleName -eq 'ConEmuHk.dll') -or ($_.ModuleName -eq 'ConEmuHk64.dll') }) {
    $emuHk = $true;
}
else {
    $emuHk = $false;
}

#Do mappings

$mappings = & (join-path $PSScriptRoot Generate-PSDrives.ps1)
if($mappings) {
    iex ([string]::Join([Environment]::NewLine, $mappings))
}


#FSC Path
$paths = ([string[]] ((
    'C:\Program Files (x86)\Microsoft SDKs\F#\3.1\Framework\v4.0\Fsc.exe',
    'C:\Program Files\Microsoft SDKs\F#\3.1\Framework\v4.0\Fsc.exe',
    'C:\Program Files (x86)\Microsoft SDKs\F#\3.0\Framework\v4.0\Fsc.exe',
    'C:\Program Files\Microsoft SDKs\F#\3.0\Framework\v4.0\Fsc.exe'
    ) | ? { Test-Path $_ }))

if($paths) {
    $fscPath = $paths[0];

    Write-Verbose "[PSUtils] Set FSC alias to '$fscPath'"

    Set-Alias fsc $fscPath

    Export-ModuleMember -alias fsc
}
else {
    Write-Verbose "[PSUtils] Could not find fsc.exe"
}

#FSI Path
$paths = ([string[]] ((
    'C:\Program Files (x86)\Microsoft SDKs\F#\3.1\Framework\v4.0\Fsi.exe',
    'C:\Program Files\Microsoft SDKs\F#\3.1\Framework\v4.0\Fsi.exe',
    'C:\Program Files (x86)\Microsoft SDKs\F#\3.0\Framework\v4.0\Fsi.exe',
    'C:\Program Files\Microsoft SDKs\F#\3.0\Framework\v4.0\Fsi.exe'
    ) | ? { Test-Path $_ }))

if($paths) {
    $fsiPath = $paths[0];

    Write-Verbose "[PSUtils] Set FSI alias to '$fsiPath'"

    # F# Scripts
    function Set-NugetRefs {
        $fsiArgs = & { "--codepage:1252"; Join-Path $PSScriptRoot Set-NugetRefs.fsx; $args | %{$_} } $args;
        & ( $fsiPath ) $fsiArgs
    }

    function Update-SymbolIndex {
        $fsiArgs = & { "--codepage:1252"; Join-Path $PSScriptRoot Update-SymbolIndex.fsx; $args | %{$_} } $args;
        & ( $fsiPath ) $fsiArgs
    }

    Set-Alias fsi $fsiPath

    Export-ModuleMember -function Set-NugetRefs
    Export-ModuleMember -function Update-SymbolIndex
    Export-ModuleMember -alias fsi
}
else {
    Write-Verbose "[PSUtils] Could not find fsi.exe"
}

$vcDir = ([string[]] ((
    $env:VS120COMNTOOLS,
    $env:VS110COMNTOOLS,
    $env:VS100COMNTOOLS) |
    ? { $_} |
    % { Join-Path $_ ..\..\VC } |
    ? { Test-Path $_})) | select-object -first 1

#VC Tools
If($vcDir) {
    Write-Verbose "[PSUtils] VC directory found on $vcDir";
    Set-Alias dumpbin $vcDir\BIN\dumpbin.exe
    Export-ModuleMember -alias dumpbin
}
else {
    Write-Verbose "[PSUtils] VC directory not found";
}

## Cusom Actions
if(Test-Path (Join-Path $env:USERPROFILE PSUtils-Custom.ps1))
{
    . (Join-Path $env:USERPROFILE PSUtils-Custom.ps1)
}

#New PSUtils tab on ConEmu, if using COnEmuHk
if($emuHk) {
    . (Join-Path $PSScriptRoot Start-PSUtils.ps1)
    Set-Alias PSUtils Start-PSUtils
    Export-ModuleMember -Function Start-PSUtils -Alias PSUtils
}

## Extenal private PS1 Scripts 
. (Join-Path $PSScriptRoot Find-Git.ps1)
. (Join-Path $PSScriptRoot Resolve-VimArgs.ps1)

## Extenal PS1 Scripts
. (Join-Path $PSScriptRoot Invoke-ForeachParallel.ps1)
. (Join-Path $PSScriptRoot Set-VS2010.ps1)
. (Join-Path $PSScriptRoot Set-VS2012.ps1)
. (Join-Path $PSScriptRoot Set-VS2013.ps1)
. (Join-Path $PSScriptRoot Set-WAIK.ps1)
. (Join-Path $PSScriptRoot Write-Prompt.ps1)
. (Join-Path $PSScriptRoot Get-FindLocation.ps1)
. (Join-Path $PSScriptRoot Invoke-TFS.ps1)
. (Join-Path $PSScriptRoot Start-gVim.ps1)
. (Join-Path $PSScriptRoot Start-Vim.ps1)
. (Join-Path $PSScriptRoot Get-Manual.ps1)
. (Join-Path $PSScriptRoot Add-Link.ps1)
. (Join-Path $PSScriptRoot Set-Clipboard.ps1)
. (Join-Path $PSScriptRoot Get-Clipboard.ps1)
. (Join-Path $PSScriptRoot Start-Elevated.ps1)
. (Join-Path $PSScriptRoot Get-Shelveset.ps1)
. (Join-Path $PSScriptRoot Set-Signature.ps1)
. (Join-Path $PSScriptRoot Install-ConEmu.ps1)
. (Join-Path $PSScriptRoot Install-Sysinternals.ps1)
. (Join-Path $PSScriptRoot Install-Vim.ps1)
. (Join-Path $PSScriptRoot Update-PSUtils.ps1)
. (Join-Path $PSScriptRoot Update-Path.ps1)
. (Join-Path $PSScriptRoot Format-SplitHorizontal.ps1)
. (Join-Path $PSScriptRoot Format-SplitVertical.ps1)
. (Join-Path $PSScriptRoot Format-NewTab.ps1)

# Aliases
Set-Alias %p Invoke-ForeachParallel
Set-Alias vs2010 Set-VS2010
Set-Alias vs2012 Set-VS2012
Set-Alias vs2013 Set-VS2013
Set-Alias waik Set-WAIK
Set-Alias which Get-FindLocation
Set-Alias nuget (Join-Path $PSScriptRoot 'NuGet.exe')
Set-Alias proget (Join-Path $PSScriptRoot 'proget.exe')
Set-Alias tf Invoke-TFS
Set-Alias gvim Start-gVim
Set-Alias vim Start-Vim
Set-Alias gman Get-Manual
Set-Alias mklink Add-Link
Set-Alias prompt Write-Prompt
Set-Alias scb Set-Clipboard
Set-Alias gcb Get-Clipboard
Set-Alias sudo Start-Elevated
Set-Alias unshelve Get-Shelveset
Set-Alias sign Set-Signature
Set-Alias sevenZip (Join-Path $PSScriptRoot '7z\7z.exe')
Set-Alias sph Format-SplitHorizontal
Set-Alias spv Format-SplitVertical
Set-Alias ntab Format-NewTab

# GNU Win32 Aliases
Set-Alias sed (Join-Path $PSScriptRoot 'GnuWin32\bin\sed.exe')
Set-Alias gzip (Join-Path $PSScriptRoot 'GnuWin32\bin\gzip.exe')
Set-Alias gwget (Join-Path $PSScriptRoot 'GnuWin32\bin\wget.exe')
Set-Alias zip (Join-Path $PSScriptRoot 'GnuWin32\bin\zip.exe')
Set-Alias unzip (Join-Path $PSScriptRoot 'GnuWin32\bin\unzip.exe')
Set-Alias tar (Join-Path $PSScriptRoot 'GnuWin32\bin\tar.exe')
Set-Alias awk (Join-Path $PSScriptRoot 'GnuWin32\bin\awk.exe')
Set-Alias gawk (Join-Path $PSScriptRoot 'GnuWin32\bin\gawk.exe')
Set-Alias less (Join-Path $PSScriptRoot 'GnuWin32\bin\less.exe')

# dbgtools aliases
Set-Alias symchk (Join-Path $PSScriptRoot 'dbgtools\symchk.exe')
Set-Alias symstore (Join-Path $PSScriptRoot 'dbgtools\symstore.exe')
Set-Alias pdbstr (Join-Path $PSScriptRoot 'dbgtools\pdbstr.exe')
Set-Alias srctool (Join-Path $PSScriptRoot 'dbgtools\srctool.exe')

# Aliases for sysinternals tools
if(Test-Path (Join-Path $PSScriptRoot ..\sysinternals)) {
    foreach($file in (gi (Join-Path $PSScriptRoot ..\sysinternals\*.exe))) {
        Set-Alias $file.Basename $file
        Export-ModuleMember -Alias $file.Basename
    }
}

# Export scripts
Export-ModuleMember -function Invoke-ForeachParallel
Export-ModuleMember -function Set-VS2010
Export-ModuleMember -function Set-VS2012
Export-ModuleMember -function Set-VS2013
Export-ModuleMember -function Set-WAIK
Export-ModuleMember -function Write-Prompt
Export-ModuleMember -function Get-FindLocation
Export-ModuleMember -function Invoke-TFS
Export-ModuleMember -function Start-gVim
Export-ModuleMember -function Start-Vim
Export-ModuleMember -function Get-Manual
Export-ModuleMember -function Add-Link
Export-ModuleMember -function Set-Clipboard
Export-ModuleMember -function Get-Clipboard
Export-ModuleMember -function Start-Elevated
Export-ModuleMember -function Get-Shelveset
Export-ModuleMember -function Set-Signature
Export-ModuleMember -function Install-ConEmu
Export-ModuleMember -function Install-Vim
Export-ModuleMember -function Install-Sysinternals
Export-ModuleMember -function Update-PSUtils
Export-ModuleMember -function Update-Path
Export-ModuleMember -function Format-SplitHorizontal
Export-ModuleMember -function Format-SplitVertical
Export-ModuleMember -function Format-NewTab

#Export aliases
Export-ModuleMember -alias %p
Export-ModuleMember -alias vs2010
Export-ModuleMember -alias vs2012
Export-ModuleMember -alias vs2013
Export-ModuleMember -alias waik
Export-ModuleMember -alias which
Export-ModuleMember -alias nuget
Export-ModuleMember -alias proget
Export-ModuleMember -alias tf
Export-ModuleMember -alias gvim
Export-ModuleMember -alias vim
Export-ModuleMember -alias gman
Export-ModuleMember -alias mklink
Export-ModuleMember -alias prompt
Export-ModuleMember -alias scb
Export-ModuleMember -alias gcb
Export-ModuleMember -alias sudo
Export-ModuleMember -alias unshelve
Export-ModuleMember -alias sign
Export-ModuleMember -alias sph
Export-ModuleMember -alias spv
Export-ModuleMember -alias ntab

#Export GNU Win32 Aliases
Export-ModuleMember -alias sed
Export-ModuleMember -alias gzip
Export-ModuleMember -alias gwget
Export-ModuleMember -alias zip
Export-ModuleMember -alias unzip
Export-ModuleMember -alias tar
Export-ModuleMember -alias awk
Export-ModuleMember -alias gawk
Export-ModuleMember -alias less
Export-ModuleMember -alias sevenZip

# Export dbgtools aliases
Export-ModuleMember -alias symchk
Export-ModuleMember -alias symstore
Export-ModuleMember -alias pdbstr
Export-ModuleMember -alias srctool

$msgFile = Join-Path ([Environment]::GetFolderPath('ApplicationData')) 'PSUtils\messages.txt'

if(Test-Path $msgFile) {
    try {
        $msg = gc $msgFile

        Write-Host ''

        foreach($line in $msg) {

            if($emuHk) {
                Write-Host ('  ' + [char](27) + '[33;1m' + $line)
            }
            else {
                Write-Host ('  ' + $line) -ForegroundColor Yellow
            }
        }
    }
    finally {
        rm $msgFile
    }
    
}

$conemuXml = Join-Path ([Environment]::GetFolderPath('ApplicationData')) 'PSUtils\ConEmu.xml'

if(Test-Path $conemuXml) {
    mv $conemuXml (Join-Path $PSScriptRoot 'ConEmu.xml') -Force
}


