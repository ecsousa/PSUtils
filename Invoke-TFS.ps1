
function Invoke-TFS {
    $tfPath = @((
        $env:VS120COMNTOOLS,
        $env:VS110COMNTOOLS,
        $env:VS100COMNTOOLS ) |
        ? { $_ } |
        % { Join-Path $_ '..\IDE\tf.exe' } |
        ? { Test-Path $_ }) |
        Select-Object -First 1

    if(-not $tfPath) {
        Write-Warning "Could not find tf.exe"
        return
    }

    Write-Verbose ("Invoking tf.exe from '" + $tfPath + "'")

    & ($tfPath) (Expand-Arguments $args | Resolve-PSDrive)

}


