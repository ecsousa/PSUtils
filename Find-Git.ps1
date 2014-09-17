function Find-Git {
    $git = & {
        ($env:Path).Split(';');
        gi (Join-Path $env:ProgramFiles git\bin) -ErrorAction SilentlyContinue;
        gi (Join-Path ($env:ProgramFiles + ' (x86)') git\bin) -ErrorAction SilentlyContinue
    } | ? {
        $_
    }  | % {
        Join-Path $_ git.exe
    } | ? {
        Test-Path $_
    } | Select -First 1

    if(-not($git)) {
        Write-Warning "Could not find git.exe"
    }

    $git
}

