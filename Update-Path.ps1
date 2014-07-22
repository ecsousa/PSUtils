function Update-Path {

    $configuredPaths = [string[]] (& {
            foreach($path in & {
                (Get-ItemProperty 'HKLM:\System\CurrentControlSet\Control\Session Manager\Environment').Path;
                (Get-ItemProperty 'HKCU:\Environment').Path;
                }) {
            if($path) {
            $path.Split(';');
            }
            }
            })

    $currentPaths = $env:Path.Split(';')

    $keptPaths = [string[]] $currentPaths | ? { -not ($configuredPaths -contains $_) }
    $newPaths = [string[]] $configuredPaths | ? { -not ($currentPaths -contains $_) }

    foreach($path in $keptPaths) {
        Write-Warning "$path will be kept in PATH."
    }

    foreach($path in $newPaths) {
        Write-Warning "Adding $path will be added to PATH."
        $env:Path = $env:Path + ';' + $path
    }

}
