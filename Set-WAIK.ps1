function Set-WAIK {
    $vsvars32FullPath = "C:\Program Files\Windows AIK\Tools\PETools\pesetenv.cmd"

    if(-not(Test-Path $vsvars32FullPath)) {
        Write-Warning "Could not find pesetenv.cmd"
        return;
    }

    Write-Verbose "Importing Windows AIK environment";
        
    $cmd = "`"$vsvars32FullPath`" > nul & set"
    cmd /c $cmd | Foreach-Object {
        $p, $v = $_.split('=')
        Set-Item -path env:$p -value $v
    }

    $Global:TitlePrefix = '[Windows AIK] ';
}

