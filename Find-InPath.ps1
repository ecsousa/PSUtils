function Find-InPath {
    param([string] $name)

    @(
        $env:Path.Split(';') |
        ? { $_ } |
        % { Join-Path $_ $name } |
        ? { Test-Path $_ }
    ) | Select-Object -First 1

}

