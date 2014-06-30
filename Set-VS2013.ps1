function Set-VS2013 {
    if(-not($env:VS120COMNTOOLS)) {
        Write-Warning "Environment variable VS120COMNTOOLS is undefined"
        return;
    }

    $vsvars32FullPath = Join-Path $env:VS120COMNTOOLS "vsvars32.bat"

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

    $Global:TitlePrefix = '[vs2013] ';
}

