function Update-Path {

    $configuredPaths = [string[]] (& {
        foreach($path in & {
            (Get-ItemProperty 'HKLM:\System\CurrentControlSet\Control\Session Manager\Environment').Path;
            (Get-ItemProperty 'HKCU:\Environment').Path;
        }) {
            if($path) {
                $path.Split(';') | % { if($_) { $_ } }
            }
        }
    })

    $currentPaths = $env:Path.Split(';')

    $newPaths = [string[]] $configuredPaths | ? { -not ($currentPaths -contains $_) }

    foreach($path in $newPaths) {
        Write-Warning "Adding $path will be added to PATH."
        $env:Path = $env:Path + ';' + $path
    }

}
