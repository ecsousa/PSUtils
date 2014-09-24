function Start-Vim {
    $paths = & {
        $env:Path.Split(';');
        Join-Path $PSScriptRoot '..\vim'
    } | ? {
        $_
    } | % {
        Join-Path $_ vim.exe
    } | ? {
        Test-Path $_
    }

    if(-not($paths)) {
        Write-Warning "Could not find Vim in $(Join-Path $PSScriptRoot ..\vim)"
        return;
    }

    Write-Verbose "Start Vim from '$(@($paths)[0])'"

    $newArgs = & {
        '-u';
        cvpa (Join-Path $PSScriptRoot _vimrc);
        '--cmd';
        "set rtp+=$(Join-Path $PSScriptRoot vimfiles)";
        Expand-Arguments $args | Resolve-PSDrive;
    } $args;


    & @($paths)[0] $newArgs
}


