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
        $vimrc = (Join-Path $PSScriptRoot vim\vimrc);

        if(Test-Path $vimrc) {
            '-u';
            $vimrc;
        }

        Expand-Arguments $args | Resolve-PSDrive;
    } $args;

    $currentPos = [Console]::CursorTop
    & @($paths)[0] $newArgs

    [Console]::SetCursorPosition(0, $currentPos)
}

