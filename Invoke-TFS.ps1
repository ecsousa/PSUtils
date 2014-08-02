
function Invoke-TFS {
    $tfPaths = @((
        $env:VS120COMNTOOLS,
        $env:VS110COMNTOOLS,
        $env:VS100COMNTOOLS ) |
        ? { $_ } |
        % { Join-Path $_ '..\IDE\tf.exe' } |
        ? { Test-Path $_ })

    if(-not $tfPaths) {
        Write-Warning "Could not find tf.exe"
        return
    }

    Write-Verbose ("Invoking tf.exe from '" + $tfPaths[0] + "'")

    & ($tfPaths[0]) (Expand-Arguments $args | Resolve-PSDrive)

}


