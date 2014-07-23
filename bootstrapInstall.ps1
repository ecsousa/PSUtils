if(-not(Test-Path PSUtils)) {
    function Find-Git {
        & { ($env:Path).Split(';'); gi (Join-Path $env:ProgramFiles git\bin) -ErrorAction SilentlyContinue; gi (Join-Path ($env:ProgramFiles + ' (x86)') git\bin) -ErrorAction SilentlyContinue }  | % { Join-Path $_ git.exe } | ? { Test-Path $_ } | Select -First 1
    }


    $git = Find-Git

    if(-not($git)) {

        $choices = [System.Management.Automation.Host.ChoiceDescription[]] @("&Yes", "&No")
        $choice = $host.UI.PromptForChoice('Git download', 'Git was not found. Do you want to download it?', $choices, 1)

        if($choice -eq 1) {
            return;
        }

        Invoke-WebRequest 'https://github.com/msysgit/msysgit/releases/download/Git-1.9.4-preview20140611/Git-1.9.4-preview20140611.exe' -OutFile .\install-git.exe

        $proc = [System.Diagnostics.Process]::Start((cvpa '.\install-git.exe'))
        
        if($proc) {
            $proc.WaitForExit();

            rm .\install-git.exe
        }

        $git = Find-Git
    }


    if(-not($git)) {
        Write-Warning "Could not find or install Git";
        return;
    }

    & $git clone https://github.com/ecsousa/PSUtils.git PSUtils
}

if(-not(Test-Path ConEmu)) {

    if( (Get-ExecutionPolicy) -ne 'Restricted') {
        Import-Module .\PSUtils\PSUtils.psm1 -Force
        Install-ConEmu

        if($?) {
            if($env:PROCESSOR_ARCHITECTURE -eq 'x64') {
                pushd .\ConEmu
                & .\ConEmu64
                popd
            }
            else {
                pushd .\ConEmu
                & .\ConEmu32
                popd
            }
        }

    }
    else {
        Write-Warning "Could not install ConEmu -- PowerShell execution policy is set to Restricted"
        Write-Warning "Execunting this again with less restrictive executing policy will install it"
    }
}


