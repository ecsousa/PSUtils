function Start-gVim {
    $paths = & {
        $env:Path.Split(';');
        Join-Path $PSScriptRoot '..\vim'
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
        '-u';
        cvpa (Join-Path $PSScriptRoot _vimrc);
        '--cmd';
        "set rtp+=$(Join-Path $PSScriptRoot vimfiles)";
        Expand-Arguments $args | Resolve-PSDrive;
    } $args;


    & @($paths)[0] $newArgs
}


