

#Do mappings

$mappings = & (join-path $PSScriptRoot Generate-PSDrives.ps1)
if($mappings) {
    iex ([string]::Join([Environment]::NewLine, $mappings))
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
        $fsiArgs = & { Join-Path $PSScriptRoot Set-NugetRefs.fsx; $args };
        & ( $fsiPath ) $fsiArgs
    }

    Set-Alias fsi $fsiPath

    Export-ModuleMember -function Set-NugetRefs
    Export-ModuleMember -alias fsi
}
else {
    Write-Verbose "[PSUtils] Could not find fsi.exe"
}

## Cusom Actions
if(Test-Path (Join-Path $env:USERPROFILE PSUtils-Custom.ps1))
{
    . (Join-Path $env:USERPROFILE PSUtils-Custom.ps1)
}

## Extenal PS1 Scripts
. (Join-Path $PSScriptRoot Invoke-ForeachParallel.ps1)
. (Join-Path $PSScriptRoot Set-VS2012.ps1)
. (Join-Path $PSScriptRoot Set-VS2013.ps1)
. (Join-Path $PSScriptRoot Write-Prompt.ps1)
. (Join-Path $PSScriptRoot Get-FindLocation.ps1)
. (Join-Path $PSScriptRoot Invoke-TFS.ps1)
. (Join-Path $PSScriptRoot Start-gVim.ps1)
. (Join-Path $PSScriptRoot Start-Vim.ps1)
. (Join-Path $PSScriptRoot Get-Manual.ps1)
. (Join-Path $PSScriptRoot Add-Link.ps1)

# Aliases
Set-Alias %p Invoke-ForeachParallel
Set-Alias vs2012 Set-VS2012
Set-Alias vs2013 Set-VS2013
Set-Alias which Get-FindLocation
Set-Alias nuget (Join-Path $PSScriptRoot 'NuGet.exe')
Set-Alias tf Invoke-TFS
Set-Alias gvim Start-gVim
Set-Alias vim Start-Vim
Set-Alias gman Get-Manual
Set-Alias mklink Add-Link
Set-Alias prompt Write-Prompt

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

# Export scripts
Export-ModuleMember -function Invoke-ForeachParallel
Export-ModuleMember -function Set-VS2012
Export-ModuleMember -function Set-VS2013
Export-ModuleMember -function Write-Prompt
Export-ModuleMember -function Get-FindLocation
Export-ModuleMember -function Invoke-TFS
Export-ModuleMember -function Start-gVim
Export-ModuleMember -function Start-Vim
Export-ModuleMember -function Get-Manual
Export-ModuleMember -function Add-Link

#Export aliases
Export-ModuleMember -alias %p
Export-ModuleMember -alias vs2012
Export-ModuleMember -alias vs2013
Export-ModuleMember -alias which
Export-ModuleMember -alias nuget
Export-ModuleMember -alias tf
Export-ModuleMember -alias gvim
Export-ModuleMember -alias vim
Export-ModuleMember -alias gman
Export-ModuleMember -alias mklink
Export-ModuleMember -alias prompt

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

# Export dbgtools aliases
Export-ModuleMember -alias symchk
Export-ModuleMember -alias symstore
Export-ModuleMember -alias pdbstr
Export-ModuleMember -alias srctool

