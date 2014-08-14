function Resolve-PSDrive {
    param(
        [Parameter(Position=0, Mandatory=$FALSE, ValueFromPipeline=$TRUE)]
        [string] $value
    );

    process {

        $splitted = $value.Split(':');

        if($splitted.Length -eq 2) {
            if($splitted[0]) {
                $psdrive = Get-PSDrive $splitted[0] -ErrorAction SilentlyContinue;;

                if($psdrive) {
                    return (Join-Path $psdrive.Root $splitted[1]);
                }
            }
        }

        return $value;
    }
}

