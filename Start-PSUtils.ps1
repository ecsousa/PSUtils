function Start-PSUtils {
    $psi = new-object System.Diagnostics.ProcessStartInfo
    $psi.FileName = $env:WINDIR + '\System32\WindowsPowerShell\v1.0\powershell.exe'
    $psi.Arguments = '-ExecutionPolicy ' + (Get-ExecutionPolicy) + ' -NoExit -Command "Import-Module ''' + $PSScriptRoot + '''"'

    if($args) {
        $psi.Arguments = '-new_console:' + $args[0] + ' ' + $psi.Arguments
    }
    else {
        $psi.Arguments = '-new_console ' + $psi.Arguments
    }

    $psi.UseShellExecute = $false

    [System.Diagnostics.Process]::Start($psi) | out-null
}

