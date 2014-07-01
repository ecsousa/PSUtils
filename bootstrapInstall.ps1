if(-not(Test-Path PSUtils)) {
    function Find-Git {
        & { ($env:Path).Split(';'); gi (Join-Path $env:ProgramFiles git\bin) -ErrorAction SilentlyContinue; gi (Join-Path ($env:ProgramFiles + ' (x86)') git\bin) -ErrorAction SilentlyContinue }  | % { Join-Path $_ git.exe } | ? { Test-Path $_ } | Select -First 1
    }


    $git = Find-Git

    if(-not($git)) {

        Invoke-WebRequest 'https://github.com/msysgit/msysgit/releases/download/Git-1.9.4-preview20140611/Git-1.9.4-preview20140611.exe' -OutFile .\install-git.exe

        [System.Diagnostics.Process]::Start('.\install-git.exe').WaitForExit();

        rm .\install-git.exe

    }

    if(-not($git)) {
        Write-Warning "Could not find or install Git";
    }

    & $git clone https://bitbucket.org/ecsousa/psutils PSUtils
}

if(-not(Test-Path ConEmu)) {

    if( (Get-ExecutionPolicy) -ne 'Restricted') {
        Import-Module .\PSUtils\PSUtils.psm1 -Force
        Install-ConEmu

    }
    else {
        Write-Warning "Could not install ConEmu -- PowerShell execution policy is set to Restricted"
        Write-Warning "Execunting this again with less restrictive executing policy will install it"
    }
}

if($env:PROCESSOR_ARCHITECTURE -eq 'x64') {
    & .\ConEmu\ConEmu64
}
else {
    & .\ConEmu\ConEmu32
}
