
if([Diagnostics.Process]::GetCurrentProcess().Modules | ? { ($_.ModuleName -eq 'ConEmuHk.dll') -or ($_.ModuleName -eq 'ConEmuHk64.dll') }) {
    #We are inside ConEmu, with ConEmuHk enabled!

    function Start-Elevated {

        if($args.Length -eq 0) {
            $psi = new-object System.Diagnostics.ProcessStartInfo
            $psi.FileName = $env:WINDIR + '\System32\WindowsPowerShell\v1.0\powershell.exe'
            $psi.Arguments = '-new_console:a -ExecutionPolicy ' + (Get-ExecutionPolicy) + ' -NoExit -Command "Import-Module ''' + $PSScriptRoot + '''"'
            $psi.UseShellExecute = $false
        }
        else {

            $program = $args[0]

            $alias = Get-Alias $program -ErrorAction SilentlyContinue
            while($alias) {
                $program = $alias.Definition;
                $alias = Get-Alias $program -ErrorAction SilentlyContinue
            }

            $cmdLine = '-new_console:a ';
            if($args.Length -ne 1) {
                $cmdLine = $cmdLine + [string]::Join(' ', ($args[1..$args.Length] | % { '"' + (([string] $_).Replace('"', '""')) + '"' }) )
            }

            $psi = new-object System.Diagnostics.ProcessStartInfo
            $psi.FileName = $program
            $psi.Arguments = $cmdLine
            $psi.UseShellExecute = $false

        }

        [System.Diagnostics.Process]::Start($psi) | out-null

    }
}

else {

    function Start-Elevated {

        if($args.Length -eq 0) {
            Write-Warning "You must provived to program to be executed and its command line arguments"
            return
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

        [System.Diagnostics.Process]::Start($psi) | out-null

    }
}
