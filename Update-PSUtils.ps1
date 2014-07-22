function Update-PSUtils {
    $git = Find-Git

    if(-not($git)) {
        return;
    }

    & $git pull $PSScriptRoot | tee -Variable 'Updated'

    if($Updated -ne 'Already up-to-date.') {
        $path = $env:PSModulePath.Split(';') | %{ Join-Path $_ 'PSUtils\PSUtils.psm1' } | ? { Test-Path $_ } | Select-Object -First 1
        $module = Get-Module PSUtils

        if(-not($path) -or ((cvpa $path).ToLower() -ne $module.Path.ToLower())) {
            $path = Join-Path $PSScriptRoot PSUtils.psm1
        }
        else {
            $path = 'PSUtils'
        }

        Write-Warning "PSUtils has been updated. Please execute 'Import-Module $path -Force' to reload it."
    }
}
