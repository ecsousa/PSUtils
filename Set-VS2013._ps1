function Set-VS2013 {
    $vs120comntools = (Get-ChildItem env:VS120COMNTOOLS).Value
    $vsvars32FullPath = [System.IO.Path]::Combine($vs120comntools, "vsvars32.bat")
        
    $cmd = "`"$vsvars32FullPath`" & set"
    cmd /c $cmd | Foreach-Object {
        $p, $v = $_.split('=')
        Set-Item -path env:$p -value $v
    }

    $Global:TitlePrefix = '[vs2013] ';
}
