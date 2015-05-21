function Start-gVim {
    $paths = & {
        $env:Path.Split(';');
        Join-Path $PSScriptRoot '..\vim'
    } | ? {
        $_
    } | % {
        Join-Path $_ gvim.exe
    } | ? {
        Test-Path $_
    }

    if(-not($paths)) {
        Write-Warning "Could not find gVim in $(Join-Path $PSScriptRoot ..\vim)"
        return;
    }

    Write-Verbose "Start gVim from '$(@($paths)[0])'"

    $newArgs = & {
        $vimrc = (Join-Path $PSScriptRoot vim\vimrc);

        if(Test-Path $vimrc) {
            '-u';
            $vimrc;
        }

        Expand-Arguments $args | Resolve-PSDrive;
    } $args;

    & @($paths)[0] $newArgs
}


