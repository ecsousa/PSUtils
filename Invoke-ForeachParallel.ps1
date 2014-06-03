function Invoke-ForeachParallel {
<#
.SYNOPSIS
A parallel ForEach that uses runspaces

.PARAMETER ScriptBlock
ScriptBlock to execute for each InputObject

.PARAMETER ScriptFile
Script file to execute for each InputObject

.PARAMETER InputObject
Object(s) to run script against in parallel

.PARAMETER Throttle
Maximum number of threads to run at one time.  Default: 5

.PARAMETER Timeout
Stop each thread after this many minutes.  Default: 0

WARNING:  This parameter should be used as a failsafe only
Set it for roughly the entire duration you expect for all threads to complete

.PARAMETER SleepTimer
When looping through open threads, wait this many milliseconds before looping again.  Default: 200

.EXAMPLE
(0..50) | ForEach-Parallel -Throttle 4 { $_; sleep (Get-Random -Minimum 0 -Maximum 5) }
}

Send the number 0 through 50 to scriptblock.  For each, display the number and then sleep for 0 to 5 seconds.  Only execute 4 threads at a time.

.EXAMPLE
$servers | Foreach-Parallel -Throttle 20 -Timeout 60 -sleeptimer 200 -verbose -scriptFile C:\query.ps1

Run query.ps1 against each computer in $servers.  Run 20 threads at a time, timeout a thread if it takes longer than 60 minutes to run, give verbose output.

.FUNCTIONALITY 
PowerShell Language

.NOTES
Credit to Tome Tanasovski
http://powertoe.wordpress.com/2012/05/03/foreach-parallel/
#>
    [cmdletbinding()]
    param(
        [Parameter(Mandatory=$false,position=0,ParameterSetName='ScriptBlock')]
            [System.Management.Automation.ScriptBlock]$ScriptBlock,

        [Parameter(Mandatory=$false,ParameterSetName='ScriptFile')]
        [ValidateScript({test-path $_ -pathtype leaf})]
            $scriptFile,

        [Parameter(Mandatory=$true,ValueFromPipeline=$true)]
            [PSObject]$InputObject,

            [int]$Throttle=5,

            [double]$sleepTimer = 200,

            [double]$Timeout = 0
    )
    BEGIN {
        
        #Build the scriptblock depending on the parameter used
        switch ($PSCmdlet.ParameterSetName){
            'ScriptBlock' {$ScriptBlock = $ExecutionContext.InvokeCommand.NewScriptBlock("param(`$_)`r`n" + $Scriptblock.ToString())}
            'ScriptFile' {$scriptblock = [scriptblock]::Create($(get-content $scriptFile | out-string))}
            Default {Write-Error ("Must provide ScriptBlock or ScriptFile"); Return}
        }
        
        #Define the initial sessionstate, create the runspacepool
        Write-Verbose "Creating runspace pool with $Throttle threads"
        $sessionState = [system.management.automation.runspaces.initialsessionstate]::CreateDefault()
        $pool = [Runspacefactory]::CreateRunspacePool(1, $Throttle, $sessionState, $host)
        $pool.open()
        
        #array to hold details on each thread
        $threads = @()

        #If inputObject is bound get a total count and set bound to true
        $bound = $false
        if( $PSBoundParameters.ContainsKey("inputObject") ){
            $bound = $true
            $totalCount = $inputObject.count
        }
        
    }

    PROCESS {
        
$run = @'
        #For each pipeline object, create a new powershell instance, add to runspacepool
        $powershell = [powershell]::Create().addscript($scriptblock).addargument($InputObject)
        $powershell.runspacepool=$pool
        $startTime = get-date

        #add references to inputobject, instance, handle and startTime to threads array
        $threads += New-Object psobject -Property @{
            Object = $inputObject;
            instance = $powershell;
            handle = $powershell.begininvoke();
            startTime = $startTime
        }

        Write-Verbose "Added $inputobject to the runspacepool at $startTime"
'@

        #Run the here string.  Put it in a foreach loop if it didn't come from the pipeline
        if($bound){   
            $run = $run -replace 'inputObject', 'object'
            foreach($object in $inputObject){ 
                Invoke-Expression -command $run
            }
        }

        else{
        
            Invoke-Expression -command $run
        }

    }
    END {
        $notdone = $true
        
        #Loop through threads.
        while ($notdone) {

            $notdone = $false
            for ($i=0; $i -lt $threads.count; $i++) {
                $thread = $threads[$i]
                if ($thread) {

                    #If thread is complete, dispose of it.
                    if ($thread.handle.iscompleted) {
                        Write-verbose "Closing thread for $($thread.Object)"
                        $thread.instance.endinvoke($thread.handle)
                        $thread.instance.dispose()
                        $threads[$i] = $null
                    }

                    #Thread exceeded maxruntime timeout threshold
                    elseif( $Timeout -ne 0 -and ( (get-date) - $thread.startTime ).totalminutes -gt $Timeout ){
                        Write-Error "Closing thread for $($thread.Object): Thread exceeded $Timeout minute limit" -TargetObject $thread.inputObject
                        $thread.instance.dispose()
                        $threads[$i] = $null
                    }

                    #Thread is running, loop again!
                    else {
                        $notdone = $true
                    }
                }           
            }

            #Sleep for specified time before looping again
            Start-Sleep -Milliseconds $sleepTimer
        }
    }
}

# SIG # Begin signature block
# MIId3wYJKoZIhvcNAQcCoIId0DCCHcwCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQU53GKwWTAKxbYFBweKQoEdr3a
# 9m2gghjPMIID7jCCA1egAwIBAgIQfpPr+3zGTlnqS5p31Ab8OzANBgkqhkiG9w0B
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
# KoZIhvcNAQkEMRYEFJdF6CI6vWjU/CxP+2+Ohx9tcyT9MA0GCSqGSIb3DQEBAQUA
# BIIBAECWfwKb34ZxY7LMlPCWVPLzHuzH25WqhDmfChZ1Sp1l+VttVnKkTBMv4vOr
# uBMsDlAXxCKDkbi2nB8ciNTRgUhdnlAJuGqgCrc7QtSgILRGrrfYFMe486oj3389
# rXofdwT++YDl9rH22lUAGb0rS2AW/XutwJYpMBenSeXFKE6u9cUjBDYT55Nzl04m
# qgvbkcJENDQYmOfkk6S7mlu2scXr2dgbstDiBzQi1WD08PcM6l8wa2nKxGayz4u7
# Qtn+9n+VLW4VYB7oZz15Llj325zuetI1ghxXTOm9vn5mnW6g+P9kyJAAVO2r59i2
# ee/lCkDjdJDYzgVPbIYB/g/CAoKhggILMIICBwYJKoZIhvcNAQkGMYIB+DCCAfQC
# AQEwcjBeMQswCQYDVQQGEwJVUzEdMBsGA1UEChMUU3ltYW50ZWMgQ29ycG9yYXRp
# b24xMDAuBgNVBAMTJ1N5bWFudGVjIFRpbWUgU3RhbXBpbmcgU2VydmljZXMgQ0Eg
# LSBHMgIQDs/0OMj+vzVuBNhqmBsaUDAJBgUrDgMCGgUAoF0wGAYJKoZIhvcNAQkD
# MQsGCSqGSIb3DQEHATAcBgkqhkiG9w0BCQUxDxcNMTQwNjAzMTQxMDI1WjAjBgkq
# hkiG9w0BCQQxFgQUlx5z1HjYLlcFcoMUh37OOrrJxcAwDQYJKoZIhvcNAQEBBQAE
# ggEATO9XXf6QKTrG0zrHsECLSXkIdO87L7IouplQdBBnxtRj2jDZqaD/q5OF4USv
# lnqgxs+QW57xQAuk/bQKB/gRJi8SgPdxIIV+lpBw+5B9Fx1RiM/EEViqoxQZfyTa
# P8MJBx1KLfgpVG9Q2r+7Hqan2xbr1pxPuUvQa8CVHhXVtRlhb6G98c9a2tM9NL67
# 39SBimlOMU16cieCpzAPvHCtf1ebvfa9sFMw8b8pCXzFlGxW+cdlH+D+P1BFfNdE
# qYebaeyHql+0PpgspFVJi5fxgRJvUP64bLQ0lEtfbbTDOh0KNsySPRmrDFgtxBL8
# zn6l+m3sIvi56MmEXywx+9qYGA==
# SIG # End signature block
