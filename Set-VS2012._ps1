function Set-VS2012 {
    $vs110comntools = (Get-ChildItem env:VS110COMNTOOLS).Value
    $vsvars32FullPath = [System.IO.Path]::Combine($vs110comntools, "vsvars32.bat")
        
    $cmd = "`"$vsvars32FullPath`" & set"
    cmd /c $cmd | Foreach-Object {
        $p, $v = $_.split('=')
        Set-Item -path env:$p -value $v
    }

    $Global:TitlePrefix = '[vs2012] ';
}
