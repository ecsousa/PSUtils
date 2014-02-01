
function Start-Vim {
    $envPaths = [string[]] ($env:Path.Split(';') | %{ Join-Path $_ vim.exe } | ? { Test-Path $_ })
    if($envPaths) {
        $path = $envPaths[0]
    }
    else {
        $path = ([regex] ('(?i)\\' + ([regex]::Escape((gi $PSScriptRoot).Name)) + '\\?$')).Replace((cvpa $PSScriptRoot), '\Vim\vim.exe')
    }

    if(-not (Test-Path $path)) {
        Write-Warning "Could not find Vim in '$path'"
        return;
    }

    $vimfiles = Join-Path $PSScriptRoot vimfiles

    Write-Verbose "Start Vim from '$path'"

    $newArgs = & { '-u'; (cvpa (Join-Path $PSScriptRoot _vimrc)); '--cmd'; "set rtp+=$vimfiles"; $args | % {$_} } $args;

    & ($path) $newArgs
}

