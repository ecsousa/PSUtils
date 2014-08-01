
function Start-gVim {
    $envPaths = [string[]] ($env:Path.Split(';') | %{ Join-Path $_ gvim.exe } | ? { Test-Path $_ })
    if($envPaths) {
        $path = $envPaths[0]
    }
    else {
        $path = ([regex] ('(?i)\\' + ([regex]::Escape((gi $PSScriptRoot).Name)) + '\\?$')).Replace((cvpa $PSScriptRoot), '\Vim\gVim.exe')
    }

    if(-not (Test-Path $path)) {
        Write-Warning "Could not find gVim in '$path'"
        return;
    }

    $vimfiles = Join-Path $PSScriptRoot vimfiles

    Write-Verbose "Start gVim from '$path'"

    function Resolve-Args {
        param($myArgs);
        
        if($myArgs.GetType().IsArray) {
            foreach($arg in $myArgs) {
                $results = Resolve-Args $arg;
                if($results.GetType().IsArray) {
                    foreach($result in $results) {
                        $result;
                    }
                }
                else {
                    $results
                }
            }
        }
        else {
            $arg;
        }
    }

    $newArgs = & { '-u'; (cvpa (Join-Path $PSScriptRoot _vimrc)); '--cmd'; "set rtp+=$vimfiles"; (Resolve-FileArgs $args) | % {$_} } $args;

    & ($path) $newArgs
}


