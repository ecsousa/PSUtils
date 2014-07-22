
function Start-Elevated {

    if($args.Length -eq 0) {
        Write-Warning "You must provived to program to be executed and its command line arguments"
    }

    $program = $args[0]

    $alias = Get-Alias $program -ErrorAction SilentlyContinue
    while($alias) {
        $program = $alias.Definition;
        $alias = Get-Alias $program -ErrorAction SilentlyContinue
    }

    if($args.Length -eq 1) {
        $cmdLine = '';
    }
    else {
        $cmdLine = [string]::Join(' ', ($args[1..$args.Length] | % { '"' + (([string] $_).Replace('"', '""')) + '"' }) )
    }

    $psi = new-object System.Diagnostics.ProcessStartInfo
    $psi.FileName = $program
    $psi.Arguments = $cmdLine
    $psi.Verb = "runas"

    [System.Diagnostics.Process]::Start($psi)

}

