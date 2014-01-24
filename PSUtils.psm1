

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

    # F# Scripts
    function Change-NugetRefs {
        $fsiArgs = & { Join-Path $PSScriptRoot Change-NugetRefs.fsx; $args };
        & ( $fsiPath ) $fsiArgs
    }

    Set-Alias fsi $fsiPath

    Export-ModuleMember -function Change-NugetRefs
    Export-ModuleMember -alias fsi

}

## Extenal PS1 Scripts
. (Join-Path $PSScriptRoot Foreach-Parallel.ps1)
. (Join-Path $PSScriptRoot Set-VS2012.ps1)
. (Join-Path $PSScriptRoot Set-VS2013.ps1)
. (Join-Path $PSScriptRoot prompt.ps1)
. (Join-Path $PSScriptRoot Get-FindLocation.ps1)
. (Join-Path $PSScriptRoot Execute-TFS.ps1)
. (Join-Path $PSScriptRoot Get-Manual.ps1)

# Aliases
Set-Alias vs2012 Set-VS2012
Set-Alias vs2013 Set-VS2013
Set-Alias which Get-FindLocation
Set-Alias nuget (Join-Path $PSScriptRoot 'NuGet.exe')
Set-Alias tf Execute-TFS
Set-Alias gman Get-Manual

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

# Export scripts
Export-ModuleMember -function Foreach-Parallel
Export-ModuleMember -function Set-VS2012
Export-ModuleMember -function Set-VS2013
Export-ModuleMember -function prompt
Export-ModuleMember -function Get-FindLocation
Export-ModuleMember -function Execute-TFS
Export-ModuleMember -function Get-Manual

#Export aliases
Export-ModuleMember -alias vs2012
Export-ModuleMember -alias vs2013
Export-ModuleMember -alias which
Export-ModuleMember -alias nuget
Export-ModuleMember -alias tf
Export-ModuleMember -alias gman

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

