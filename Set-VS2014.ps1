function Set-VS2014 {
    if(-not($env:VS140COMNTOOLS)) {
        Write-Warning "Environment variable VS140COMNTOOLS is undefined"
        return;
    }

    $vsvars32FullPath = Join-Path $env:VS140COMNTOOLS "VsDevCmd.bat"

    if(-not(Test-Path $vsvars32FullPath)) {
        Write-Warning "Could not find file '$vsvars32FullPath'";
        return;
    }

    Write-Verbose "Importing Visual Studio environment variables from '$vsvars32FullPath'";

        
    $cmd = "`"$vsvars32FullPath`" & set"
    cmd /c $cmd | Foreach-Object {
        $p, $v = $_.split('=')
        Set-Item -path env:$p -value $v
    }

    $Global:TitlePrefix = '[vs2014] ';
}

