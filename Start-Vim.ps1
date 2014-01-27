
function Start-Vim {
    $path = ([regex] ('(?i)\\' + ([regex]::Escape((gi $PSScriptRoot).Name)) + '\\?$')).Replace((cvpa $PSScriptRoot), '\Vim\Vim.exe')
    $vimfiles = Join-Path $PSScriptRoot vimfiles

    if(-not (Test-Path $path)) {
        Write-Warning "Could not find gVim in $path"
        return;
    }

    $newArgs = & { '-u'; (cvpa (Join-Path $PSScriptRoot _vimrc)); '--cmd'; "set rtp+=$vimfiles"; $args } $args;

    & ($path) $newArgs
}

