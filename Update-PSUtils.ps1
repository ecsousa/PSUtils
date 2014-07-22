function Update-PSUtils {
    $git = Find-Git

    if(-not($git)) {
        return;
    }

    & $git "--git-dir=$PSScriptRoot\.git" pull | tee -Variable 'Updated'


    if($Updated -ne 'Already up-to-date.') {
        Write-Warning "PSUtils has been updated. Realoding PSUtils Globally."

        if( (get-process powershell).Length -gt 1) {
            Write-Warning "You will need to reload it manually on other PowerShell instances."
        }

        $module = Get-Module PSUtils
        Import-Module $module.Path -Force -Global
    }

}
