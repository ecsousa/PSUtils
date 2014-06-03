

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
    ? { Test-Path $_}))[0]

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

## Extenal PS1 Scripts
. (Join-Path $PSScriptRoot Invoke-ForeachParallel.ps1)
. (Join-Path $PSScriptRoot Set-VS2010.ps1)
. (Join-Path $PSScriptRoot Set-VS2012.ps1)
. (Join-Path $PSScriptRoot Set-VS2013.ps1)
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

# Aliases
Set-Alias %p Invoke-ForeachParallel
Set-Alias vs2010 Set-VS2010
Set-Alias vs2012 Set-VS2012
Set-Alias vs2013 Set-VS2013
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
Export-ModuleMember -function Set-VS2010
Export-ModuleMember -function Set-VS2012
Export-ModuleMember -function Set-VS2013
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

#Export aliases
Export-ModuleMember -alias %p
Export-ModuleMember -alias vs2010
Export-ModuleMember -alias vs2012
Export-ModuleMember -alias vs2013
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

$host.UI.RawUI.ForegroundColor = 'Gray'
$host.UI.RawUI.BackgroundColor = 'Black'

# SIG # Begin signature block
# MIId3wYJKoZIhvcNAQcCoIId0DCCHcwCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUtrjYvcnW3eAVbi/bJo3U5fL4
# pyqgghjPMIID7jCCA1egAwIBAgIQfpPr+3zGTlnqS5p31Ab8OzANBgkqhkiG9w0B
# AQUFADCBizELMAkGA1UEBhMCWkExFTATBgNVBAgTDFdlc3Rlcm4gQ2FwZTEUMBIG
# A1UEBxMLRHVyYmFudmlsbGUxDzANBgNVBAoTBlRoYXd0ZTEdMBsGA1UECxMUVGhh
# d3RlIENlcnRpZmljYXRpb24xHzAdBgNVBAMTFlRoYXd0ZSBUaW1lc3RhbXBpbmcg
# Q0EwHhcNMTIxMjIxMDAwMDAwWhcNMjAxMjMwMjM1OTU5WjBeMQswCQYDVQQGEwJV
# UzEdMBsGA1UEChMUU3ltYW50ZWMgQ29ycG9yYXRpb24xMDAuBgNVBAMTJ1N5bWFu
# dGVjIFRpbWUgU3RhbXBpbmcgU2VydmljZXMgQ0EgLSBHMjCCASIwDQYJKoZIhvcN
# AQEBBQADggEPADCCAQoCggEBALGss0lUS5ccEgrYJXmRIlcqb9y4JsRDc2vCvy5Q
# WvsUwnaOQwElQ7Sh4kX06Ld7w3TMIte0lAAC903tv7S3RCRrzV9FO9FEzkMScxeC
# i2m0K8uZHqxyGyZNcR+xMd37UWECU6aq9UksBXhFpS+JzueZ5/6M4lc/PcaS3Er4
# ezPkeQr78HWIQZz/xQNRmarXbJ+TaYdlKYOFwmAUxMjJOxTawIHwHw103pIiq8r3
# +3R8J+b3Sht/p8OeLa6K6qbmqicWfWH3mHERvOJQoUvlXfrlDqcsn6plINPYlujI
# fKVOSET/GeJEB5IL12iEgF1qeGRFzWBGflTBE3zFefHJwXECAwEAAaOB+jCB9zAd
# BgNVHQ4EFgQUX5r1blzMzHSa1N197z/b7EyALt0wMgYIKwYBBQUHAQEEJjAkMCIG
# CCsGAQUFBzABhhZodHRwOi8vb2NzcC50aGF3dGUuY29tMBIGA1UdEwEB/wQIMAYB
# Af8CAQAwPwYDVR0fBDgwNjA0oDKgMIYuaHR0cDovL2NybC50aGF3dGUuY29tL1Ro
# YXd0ZVRpbWVzdGFtcGluZ0NBLmNybDATBgNVHSUEDDAKBggrBgEFBQcDCDAOBgNV
# HQ8BAf8EBAMCAQYwKAYDVR0RBCEwH6QdMBsxGTAXBgNVBAMTEFRpbWVTdGFtcC0y
# MDQ4LTEwDQYJKoZIhvcNAQEFBQADgYEAAwmbj3nvf1kwqu9otfrjCR27T4IGXTdf
# plKfFo3qHJIJRG71betYfDDo+WmNI3MLEm9Hqa45EfgqsZuwGsOO61mWAK3ODE2y
# 0DGmCFwqevzieh1XTKhlGOl5QGIllm7HxzdqgyEIjkHq3dlXPx13SYcqFgZepjhq
# IhKjURmDfrYwggSjMIIDi6ADAgECAhAOz/Q4yP6/NW4E2GqYGxpQMA0GCSqGSIb3
# DQEBBQUAMF4xCzAJBgNVBAYTAlVTMR0wGwYDVQQKExRTeW1hbnRlYyBDb3Jwb3Jh
# dGlvbjEwMC4GA1UEAxMnU3ltYW50ZWMgVGltZSBTdGFtcGluZyBTZXJ2aWNlcyBD
# QSAtIEcyMB4XDTEyMTAxODAwMDAwMFoXDTIwMTIyOTIzNTk1OVowYjELMAkGA1UE
# BhMCVVMxHTAbBgNVBAoTFFN5bWFudGVjIENvcnBvcmF0aW9uMTQwMgYDVQQDEytT
# eW1hbnRlYyBUaW1lIFN0YW1waW5nIFNlcnZpY2VzIFNpZ25lciAtIEc0MIIBIjAN
# BgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAomMLOUS4uyOnREm7Dv+h8GEKU5Ow
# mNutLA9KxW7/hjxTVQ8VzgQ/K/2plpbZvmF5C1vJTIZ25eBDSyKV7sIrQ8Gf2Gi0
# jkBP7oU4uRHFI/JkWPAVMm9OV6GuiKQC1yoezUvh3WPVF4kyW7BemVqonShQDhfu
# ltthO0VRHc8SVguSR/yrrvZmPUescHLnkudfzRC5xINklBm9JYDh6NIipdC6Anqh
# d5NbZcPuF3S8QYYq3AhMjJKMkS2ed0QfaNaodHfbDlsyi1aLM73ZY8hJnTrFxeoz
# C9Lxoxv0i77Zs1eLO94Ep3oisiSuLsdwxb5OgyYI+wu9qU+ZCOEQKHKqzQIDAQAB
# o4IBVzCCAVMwDAYDVR0TAQH/BAIwADAWBgNVHSUBAf8EDDAKBggrBgEFBQcDCDAO
# BgNVHQ8BAf8EBAMCB4AwcwYIKwYBBQUHAQEEZzBlMCoGCCsGAQUFBzABhh5odHRw
# Oi8vdHMtb2NzcC53cy5zeW1hbnRlYy5jb20wNwYIKwYBBQUHMAKGK2h0dHA6Ly90
# cy1haWEud3Muc3ltYW50ZWMuY29tL3Rzcy1jYS1nMi5jZXIwPAYDVR0fBDUwMzAx
# oC+gLYYraHR0cDovL3RzLWNybC53cy5zeW1hbnRlYy5jb20vdHNzLWNhLWcyLmNy
# bDAoBgNVHREEITAfpB0wGzEZMBcGA1UEAxMQVGltZVN0YW1wLTIwNDgtMjAdBgNV
# HQ4EFgQURsZpow5KFB7VTNpSYxc/Xja8DeYwHwYDVR0jBBgwFoAUX5r1blzMzHSa
# 1N197z/b7EyALt0wDQYJKoZIhvcNAQEFBQADggEBAHg7tJEqAEzwj2IwN3ijhCcH
# bxiy3iXcoNSUA6qGTiWfmkADHN3O43nLIWgG2rYytG2/9CwmYzPkSWRtDebDZw73
# BaQ1bHyJFsbpst+y6d0gxnEPzZV03LZc3r03H0N45ni1zSgEIKOq8UvEiCmRDoDR
# EfzdXHZuT14ORUZBbg2w6jiasTraCXEQ/Bx5tIB7rGn0/Zy2DBYr8X9bCT2bW+IW
# yhOBbQAuOA2oKY8s4bL0WqkBrxWcLC9JG9siu8P+eJRRw4axgohd8D20UaF5Mysu
# e7ncIAkTcetqGVvP6KUwVyyJST+5z3/Jvz4iaGNTmr1pdKzFHTx/kuDDvBzYBHUw
# ggTTMIIDu6ADAgECAhAY2tGeJn3ou0ohWM3MaztKMA0GCSqGSIb3DQEBBQUAMIHK
# MQswCQYDVQQGEwJVUzEXMBUGA1UEChMOVmVyaVNpZ24sIEluYy4xHzAdBgNVBAsT
# FlZlcmlTaWduIFRydXN0IE5ldHdvcmsxOjA4BgNVBAsTMShjKSAyMDA2IFZlcmlT
# aWduLCBJbmMuIC0gRm9yIGF1dGhvcml6ZWQgdXNlIG9ubHkxRTBDBgNVBAMTPFZl
# cmlTaWduIENsYXNzIDMgUHVibGljIFByaW1hcnkgQ2VydGlmaWNhdGlvbiBBdXRo
# b3JpdHkgLSBHNTAeFw0wNjExMDgwMDAwMDBaFw0zNjA3MTYyMzU5NTlaMIHKMQsw
# CQYDVQQGEwJVUzEXMBUGA1UEChMOVmVyaVNpZ24sIEluYy4xHzAdBgNVBAsTFlZl
# cmlTaWduIFRydXN0IE5ldHdvcmsxOjA4BgNVBAsTMShjKSAyMDA2IFZlcmlTaWdu
# LCBJbmMuIC0gRm9yIGF1dGhvcml6ZWQgdXNlIG9ubHkxRTBDBgNVBAMTPFZlcmlT
# aWduIENsYXNzIDMgUHVibGljIFByaW1hcnkgQ2VydGlmaWNhdGlvbiBBdXRob3Jp
# dHkgLSBHNTCCASIwDQYJKoZIhvcNAQEBBQADggEPADCCAQoCggEBAK8kCAgpejWe
# YAyq50s7Ttx8vDxFHLsr4P4pAvlXCKNkhRUn9fGtyDGJXSLoKqqmQrOP+LlVt7G3
# S7P+j34HV+zvQ9tmYhVhz2ANpNje+ODDYgg9VBPrScpZVIUm5SuPG5/r9aGRwjNJ
# 2ENjalJL0o/ocFFN0Ylpe8dw9rPcEnTbe11LVtOWvxV3obD0oiXyrxySZxjl9AYE
# 75C55ADk3Tq1Gf8CuvQ87uCL6zeL7PTXrPL28D2v3XWRMxkdHEDLdCQZIZPZFP6s
# KlLHj9UESeSNY0eIPGmDy/5HvSt+T8WVrg6d1NFDwGdz4xQIfuU/n3O4MwrPXT80
# h5aK7lPoJRUCAwEAAaOBsjCBrzAPBgNVHRMBAf8EBTADAQH/MA4GA1UdDwEB/wQE
# AwIBBjBtBggrBgEFBQcBDARhMF+hXaBbMFkwVzBVFglpbWFnZS9naWYwITAfMAcG
# BSsOAwIaBBSP5dMahqyNjmvDz4Bq1EgYLHsZLjAlFiNodHRwOi8vbG9nby52ZXJp
# c2lnbi5jb20vdnNsb2dvLmdpZjAdBgNVHQ4EFgQUf9Nlp8Ld7LvwMAnzQzn6Aq8z
# MTMwDQYJKoZIhvcNAQEFBQADggEBAJMkSjBfYs/YGpgvPercmS29d/aleSI47MSn
# oHgSrWIORXBkxeeXZi2YCX5fr9bMKGXyAaoIGkfe+fl8kloIaSAN2T5tbjwNbtjm
# BpFAGLn4we3f20Gq4JYgyc1kFTiByZTuooQpCxNvjtsM3SUC26SLGUTSQXoFaUpY
# T2DKfoJqCwKqJRc5tdt/54RlKpWKvYbeXoEWgy0QzN79qIIqbSgfDQvE5ecaJhnh
# 9BFvELWV/OdCBTLbzp1RXii2noXTW++lfUVAco63DmsOBvszNUhxuJ0ni8RlXw2G
# dpxEevaVXPZdMggzpFS2GD9oXPJCSoU4VINf0egs8qwR1qjtY2owggVNMIIENaAD
# AgECAhBhTE4rwvY1VXq0itQOJ/+pMA0GCSqGSIb3DQEBBQUAMIG0MQswCQYDVQQG
# EwJVUzEXMBUGA1UEChMOVmVyaVNpZ24sIEluYy4xHzAdBgNVBAsTFlZlcmlTaWdu
# IFRydXN0IE5ldHdvcmsxOzA5BgNVBAsTMlRlcm1zIG9mIHVzZSBhdCBodHRwczov
# L3d3dy52ZXJpc2lnbi5jb20vcnBhIChjKTEwMS4wLAYDVQQDEyVWZXJpU2lnbiBD
# bGFzcyAzIENvZGUgU2lnbmluZyAyMDEwIENBMB4XDTE0MDYwMzAwMDAwMFoXDTE1
# MDYwMzIzNTk1OVowfzELMAkGA1UEBhMCQlIxFTATBgNVBAgTDE1pbmFzIEdhcmFp
# czEXMBUGA1UEBxMOQmVsbyBIb3Jpem9udGUxHzAdBgNVBAoUFmF0dC9QUyBJbmZv
# cm1hdGljYSBTL0ExHzAdBgNVBAMUFmF0dC9QUyBJbmZvcm1hdGljYSBTL0EwggEi
# MA0GCSqGSIb3DQEBAQUAA4IBDwAwggEKAoIBAQDEJK79CTNRniCI57g0oMyelYTT
# Acs8VeYRkeyJ+JE77nVmVXYlNyE5U7Q10UmGmAusw0iW854vwokY3v1L7kOuj7mf
# ZLGe5CodIlSn0QgYpaknUpHHdHqrCRGXtzlo3VGAZ/dV+Ss8TS6e70YHUS9163T7
# 45zEO2h9NreyW+bdtjg28Jq9Sr/VcZuy92+mtYckUhkQrKj05rVozph2z8IrYaxC
# 2Ge7C38dHzjZLqJf/mUoVNwyatlLOCRDcEjmSWS7inf0265N2dTVQvT9IKDvNtfJ
# 2VoAU/18ZYX4+v881O71baYkhu4gZ1iTyUhIC/dneOdYIjJMtqAMEdiytwdvAgMB
# AAGjggGNMIIBiTAJBgNVHRMEAjAAMA4GA1UdDwEB/wQEAwIHgDArBgNVHR8EJDAi
# MCCgHqAchhpodHRwOi8vc2Yuc3ltY2IuY29tL3NmLmNybDBmBgNVHSAEXzBdMFsG
# C2CGSAGG+EUBBxcDMEwwIwYIKwYBBQUHAgEWF2h0dHBzOi8vZC5zeW1jYi5jb20v
# Y3BzMCUGCCsGAQUFBwICMBkWF2h0dHBzOi8vZC5zeW1jYi5jb20vcnBhMBMGA1Ud
# JQQMMAoGCCsGAQUFBwMDMFcGCCsGAQUFBwEBBEswSTAfBggrBgEFBQcwAYYTaHR0
# cDovL3NmLnN5bWNkLmNvbTAmBggrBgEFBQcwAoYaaHR0cDovL3NmLnN5bWNiLmNv
# bS9zZi5jcnQwHwYDVR0jBBgwFoAUz5mp6nsm9EvJjo/X8AUm7+PSp50wHQYDVR0O
# BBYEFO0WbJMshFss2QRZfq06a4A6d41sMBEGCWCGSAGG+EIBAQQEAwIEEDAWBgor
# BgEEAYI3AgEbBAgwBgEBAAEB/zANBgkqhkiG9w0BAQUFAAOCAQEACqrXkjC8QKcP
# XaXHoCU6ZzHeUMy7FfdlDtIXqC5TmxMB2Y+zA98ao0N18YPpZZ7wOJXHCzgcNmXP
# +hGNHhWswyIhcJWwkjIMWkMr60y/Q354rIGkUmJ3PUnM2qeyLQP3RsyrW5EAD8Il
# CR87tj5wbcQMbu2+yrEF3IJZ2UbyxleK+Yk0ipdmcronr7nZnp0EtpnYK6saENMQ
# OurMtqMTRc7WEDlIY9eC6ch6bxVZxJX1X/+vWtuvcXDgQ7t/WcrZ/XFtjna9RPlW
# Do5Jms+0yEUzMZDJr9xeit8gx3p7FVsj0HUcIjTXRCNGyXQeXzz6jdRNK3Os5wWR
# kwWWai+s+TCCBgowggTyoAMCAQICEFIA5aolVvwahu2WydRLM8cwDQYJKoZIhvcN
# AQEFBQAwgcoxCzAJBgNVBAYTAlVTMRcwFQYDVQQKEw5WZXJpU2lnbiwgSW5jLjEf
# MB0GA1UECxMWVmVyaVNpZ24gVHJ1c3QgTmV0d29yazE6MDgGA1UECxMxKGMpIDIw
# MDYgVmVyaVNpZ24sIEluYy4gLSBGb3IgYXV0aG9yaXplZCB1c2Ugb25seTFFMEMG
# A1UEAxM8VmVyaVNpZ24gQ2xhc3MgMyBQdWJsaWMgUHJpbWFyeSBDZXJ0aWZpY2F0
# aW9uIEF1dGhvcml0eSAtIEc1MB4XDTEwMDIwODAwMDAwMFoXDTIwMDIwNzIzNTk1
# OVowgbQxCzAJBgNVBAYTAlVTMRcwFQYDVQQKEw5WZXJpU2lnbiwgSW5jLjEfMB0G
# A1UECxMWVmVyaVNpZ24gVHJ1c3QgTmV0d29yazE7MDkGA1UECxMyVGVybXMgb2Yg
# dXNlIGF0IGh0dHBzOi8vd3d3LnZlcmlzaWduLmNvbS9ycGEgKGMpMTAxLjAsBgNV
# BAMTJVZlcmlTaWduIENsYXNzIDMgQ29kZSBTaWduaW5nIDIwMTAgQ0EwggEiMA0G
# CSqGSIb3DQEBAQUAA4IBDwAwggEKAoIBAQD1I0tepdeKuzLp1Ff37+THJn6tGZj+
# qJ19lPY2axDXdYEwfwRof8srdR7NHQiM32mUpzejnHuA4Jnh7jdNX847FO6G1ND1
# JzW8JQs4p4xjnRejCKWrsPvNamKCTNUh2hvZ8eOEO4oqT4VbkAFPyad2EH8nA3y+
# rn59wd35BbwbSJxp58CkPDxBAD7fluXF5JRx1lUBxwAmSkA8taEmqQynbYCOkCV7
# z78/HOsvlvrlh3fGtVayejtUMFMb32I0/x7R9FqTKIXlTBdOflv9pJOZf9/N76R1
# 7+8V9kfn+Bly2C40Gqa0p0x+vbtPDD1X8TDWpjaO1oB21xkupc1+NC2JAgMBAAGj
# ggH+MIIB+jASBgNVHRMBAf8ECDAGAQH/AgEAMHAGA1UdIARpMGcwZQYLYIZIAYb4
# RQEHFwMwVjAoBggrBgEFBQcCARYcaHR0cHM6Ly93d3cudmVyaXNpZ24uY29tL2Nw
# czAqBggrBgEFBQcCAjAeGhxodHRwczovL3d3dy52ZXJpc2lnbi5jb20vcnBhMA4G
# A1UdDwEB/wQEAwIBBjBtBggrBgEFBQcBDARhMF+hXaBbMFkwVzBVFglpbWFnZS9n
# aWYwITAfMAcGBSsOAwIaBBSP5dMahqyNjmvDz4Bq1EgYLHsZLjAlFiNodHRwOi8v
# bG9nby52ZXJpc2lnbi5jb20vdnNsb2dvLmdpZjA0BgNVHR8ELTArMCmgJ6AlhiNo
# dHRwOi8vY3JsLnZlcmlzaWduLmNvbS9wY2EzLWc1LmNybDA0BggrBgEFBQcBAQQo
# MCYwJAYIKwYBBQUHMAGGGGh0dHA6Ly9vY3NwLnZlcmlzaWduLmNvbTAdBgNVHSUE
# FjAUBggrBgEFBQcDAgYIKwYBBQUHAwMwKAYDVR0RBCEwH6QdMBsxGTAXBgNVBAMT
# EFZlcmlTaWduTVBLSS0yLTgwHQYDVR0OBBYEFM+Zqep7JvRLyY6P1/AFJu/j0qed
# MB8GA1UdIwQYMBaAFH/TZafC3ey78DAJ80M5+gKvMzEzMA0GCSqGSIb3DQEBBQUA
# A4IBAQBWIuY0pMRhy0i5Aa1WqGQP2YyRxLvMDOWteqAif99HOEotbNF/cRp87HCp
# sfBP5A8MU/oVXv50mEkkhYEmHJEUR7BMY4y7oTTUxkXoDYUmcwPQqYxkbdxxkuZF
# BWAVWVE5/FgUa/7UpO15awgMQXLnNyIGCb4j6T9Emh7pYZ3MsZBc/D3SjaxCPWU2
# 1LQ9QCiPmxDPIybMSyDLkB9djEw0yjzY5TfWb6UgvTTrJtmuDefFmvehtCGRM2+G
# 6Fi7JXx0Dlj+dRtjP84xfJuPG5aexVN2hFucrZH6rO2Tul3IIVPCglNjrxINUIcR
# Gz1UUpaKLJw9khoImgUux5OlSJHTMYIEejCCBHYCAQEwgckwgbQxCzAJBgNVBAYT
# AlVTMRcwFQYDVQQKEw5WZXJpU2lnbiwgSW5jLjEfMB0GA1UECxMWVmVyaVNpZ24g
# VHJ1c3QgTmV0d29yazE7MDkGA1UECxMyVGVybXMgb2YgdXNlIGF0IGh0dHBzOi8v
# d3d3LnZlcmlzaWduLmNvbS9ycGEgKGMpMTAxLjAsBgNVBAMTJVZlcmlTaWduIENs
# YXNzIDMgQ29kZSBTaWduaW5nIDIwMTAgQ0ECEGFMTivC9jVVerSK1A4n/6kwCQYF
# Kw4DAhoFAKB4MBgGCisGAQQBgjcCAQwxCjAIoAKAAKECgAAwGQYJKoZIhvcNAQkD
# MQwGCisGAQQBgjcCAQQwHAYKKwYBBAGCNwIBCzEOMAwGCisGAQQBgjcCARUwIwYJ
# KoZIhvcNAQkEMRYEFMjJKKqJWmc0s5n7ubZ8DFI3jQlGMA0GCSqGSIb3DQEBAQUA
# BIIBAEHX1UznjMA36tEu8e9kFxF1wSCQYGpEDX4Te1JnoNqTgLaOZimLrqZF4COF
# eZhql5xTFgsGl9Cxymcs52UAL29N/LZ2XdWBoISsZDJNiZPD9GxZg5mrJt2viBDM
# 4tA9TLUgW8qM5ZNX1wEIrOBUopyLCIivPvVnkOBZhohepP0vxdI+bp4BsZJTBMCg
# E//gQ0t9az0av1Ko1Dt06eLzDixH7g7+3Oek9XAyu5FK2eSCyfy8CjIaerPtu8L+
# oqDw+pLIe2EZomcqkqQPfEAtLu7o3nGYimhowpXjowiaYWalT8fis7cDNasWY+uR
# 1v4reV3YDz0iTpGbW3LId5S5kAahggILMIICBwYJKoZIhvcNAQkGMYIB+DCCAfQC
# AQEwcjBeMQswCQYDVQQGEwJVUzEdMBsGA1UEChMUU3ltYW50ZWMgQ29ycG9yYXRp
# b24xMDAuBgNVBAMTJ1N5bWFudGVjIFRpbWUgU3RhbXBpbmcgU2VydmljZXMgQ0Eg
# LSBHMgIQDs/0OMj+vzVuBNhqmBsaUDAJBgUrDgMCGgUAoF0wGAYJKoZIhvcNAQkD
# MQsGCSqGSIb3DQEHATAcBgkqhkiG9w0BCQUxDxcNMTQwNjAzMTQxOTAwWjAjBgkq
# hkiG9w0BCQQxFgQUhPGBu2ru3lYcdbwF3wtqBScNyQ0wDQYJKoZIhvcNAQEBBQAE
# ggEAdjP59cMuoFTCcGKVpXVIxG3B+8LJ0Oq4QmIRzAjuVBJUAjFIy2rtfiCAsL3q
# RpogEKe9LjhRvJ5PjZg/2YWTINzbtpUQQ2NiDlwKgJ1kkzhQfbpfw2P6d1zUE/z5
# 72ZT+sKOJHXfaaIr6orIE/Ve3VCxBRlWcGQwXgqhfl4eMJ8FRClxE8tXJIi9kPWy
# BCcr6LwraE2Ilu/QTtS+/l7diHKQSbPx6ETkMUnlAP+CO18uLNsFq5QstuAGvdjB
# iyvCRmwwKjUtye5KQIooQlcCuXt070kvfdWzH490qb7JYZRIzj+mJbPXQNRORl9G
# HRFK/orPGYf45La4a49lZdnf3Q==
# SIG # End signature block
