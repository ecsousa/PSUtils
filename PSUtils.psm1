
$paths = (
    'C:\Program Files (x86)\Microsoft SDKs\F#\3.1\Framework\v4.0\Fsi.exe',
    'C:\Program Files\Microsoft SDKs\F#\3.1\Framework\v4.0\Fsi.exe',
    'C:\Program Files (x86)\Microsoft SDKs\F#\3.0\Framework\v4.0\Fsi.exe',
    'C:\Program Files\Microsoft SDKs\F#\3.0\Framework\v4.0\Fsi.exe'
    )

$fsiPath = ($paths | ? { Test-Path $_ })[0]

## F# Scripts
function Change-NugetRefs {
    $fsiArgs = & { Join-Path $PSScriptRoot Change-NugetRefs.fsx; $args };
    & ( $fsiPath ) $fsiArgs
}


## Extenal PS1 Scripts
iex ([String]::Join([Environment]::NewLine, (gc (Join-Path $PSScriptRoot Foreach-Parallel._ps1))))
iex ([String]::Join([Environment]::NewLine, (gc (Join-Path $PSScriptRoot Set-VS2012._ps1))))
iex ([String]::Join([Environment]::NewLine, (gc (Join-Path $PSScriptRoot Set-VS2013._ps1))))
iex ([String]::Join([Environment]::NewLine, (gc (Join-Path $PSScriptRoot prompt._ps1))))
iex ([String]::Join([Environment]::NewLine, (gc (Join-Path $PSScriptRoot Get-FindLocation._ps1))))

# Aliases
Set-Alias vs2012 Set-VS2012
Set-Alias vs2013 Set-VS2013
Set-Alias which Get-FindLocation
Set-Alias nuget (Join-Path $PSScriptRoot 'NuGet.exe')

# GNU Win32 Aliases
Set-Alias sed (Join-Path $PSScriptRoot 'GnuWin32\sed.exe')
Set-Alias gzip (Join-Path $PSScriptRoot 'GnuWin32\gzip.exe')
Set-Alias wget (Join-Path $PSScriptRoot 'GnuWin32\wget.exe')
Set-Alias zip (Join-Path $PSScriptRoot 'GnuWin32\zip.exe')
Set-Alias unzip (Join-Path $PSScriptRoot 'GnuWin32\unzip.exe')

# Export scripts
Export-ModuleMember -function Foreach-Parallel
Export-ModuleMember -function Change-NugetRefs
Export-ModuleMember -function Set-VS2012
Export-ModuleMember -function Set-VS2013
Export-ModuleMember -function prompt
Export-ModuleMember -function Get-FindLocation

#Export aliases
Export-ModuleMember -alias vs2012
Export-ModuleMember -alias vs2013
Export-ModuleMember -alias which
Export-ModuleMember -alias nuget

#Export GNU Win32 Aliases
Export-ModuleMember -alias sed
Export-ModuleMember -alias gzip
Export-ModuleMember -alias wget
Export-ModuleMember -alias zip
Export-ModuleMember -alias unzip

