
function Invoke-TFS {
    $tfPaths = [string[]] ((
        $env:VS120COMNTOOLS,
        $env:VS110COMNTOOLS,
        $env:VS100COMNTOOLS ) |
        ? { $_ } |
        % { Join-Path $_ '..\IDE\tf.exe' } |
        ? { Test-Path $_ })

    if(-not $tfPaths) {
        Write-Warning 'Não foi possível localizar tf.exe'
        return
    }

    Write-Verbose ('Usando tf.exe em ' + $tfPaths[0])

    & ($tfPaths[0]) $args
}

