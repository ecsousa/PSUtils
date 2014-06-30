function Set-VS2010 {
    if(-not($env:VS100COMNTOOLS)) {
        Write-Warning "Environment variable VS100COMNTOOLS is undefined"
        return;
    }

    $vsvars32FullPath = Join-Path $env:VS100COMNTOOLS "vsvars32.bat"

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

    $Global:TitlePrefix = '[vs2010] ';
}

