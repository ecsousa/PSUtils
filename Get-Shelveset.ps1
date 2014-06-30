function Get-Shelveset {
    param([string] $shelve, [string] $source)

    if($source -eq $null) {
        $source = (cvpa .)
    }

    $wf = (tf workfold $source)[3].Split(':', 2) | %{ $_.Trim() }
    $from = $wf[0]

    $wf = (tf workfold .)[3].Split(':', 2) | %{ $_.Trim() }
    $to = $wf[1]

    foreach($file in (tf status $source /r "/shelveset:$shelve" /format:detailed | ? { $_ -like '$*' })) {
        $local = $file.Replace($from, $to).Split(';')[0]

        if(Test-Path $local) {
            tf edit $local | out-null
        }

        Write-Host "Getting $file to $local"
        tf view $file "/shelveset:$shelve" /console | out-file $local
    }
}

