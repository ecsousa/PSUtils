function Get-Shelveset {
    param([string] $shelve)

    $wf = (tf workfold .)[3].Split(':', 2) | %{ $_.Trim() }
    $from = $wf[0]
    $to = $wf[1]

    foreach($file in (tf status . /r "/shelveset:$shelve" /format:detailed | ? { $_ -like '$*' })) {
        $local = $file.Replace($from, $to).Split(';')[0]

        if(Test-Path $local) {
            tf edit $local
        }

        tf view $file "/shelveset:$shelve" /console | out-file $local -enc oem
    }
}
