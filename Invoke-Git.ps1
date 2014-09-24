
function Invoke-Git {
    $paths = & {
        $env:Path.Split(';');
        Join-Path $Env:ProgramFiles Git\bin;
        if(${Env:ProgramFiles(x86)}) {
            Join-Path ${Env:ProgramFiles(x86)} Git\bin;
        }
    } | ? {
        $_
    } | % {
        Join-Path $_ git.exe
    } | ? {
        Test-Path $_
    }

    if(-not $paths) {
        Write-Warning "Could not find git.exe"
        return
    }

    Write-Verbose "Invoking git.exe from $(@($paths)[0])"

    & (@($paths)[0]) (Expand-Arguments $args | Resolve-PSDrive)

}


