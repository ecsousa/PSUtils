function Resolve-PSDrive {
    param([string] $value);

    $sp = $value.Split(':');

    if($sp.Length -eq 2) {
        $psdrive = Get-PSDrive $sp[0];

        if($psdrive) {
            return (Join-Path $psdrive.Root $sp[1]);
        }
    }

    return $value;
}

