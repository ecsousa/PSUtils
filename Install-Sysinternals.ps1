function Install-Sysinternals {

    $url = New-Object Uri('http://download.sysinternals.com/files/SysinternalsSuite.zip')
    $output = Join-Path $PSScriptRoot '..\sysinternals'
    $zip = Join-Path $PSScriptRoot '..\sysinternals\sysinternals.zip'

    if(Test-Path $output) {
        $choices = [System.Management.Automation.Host.ChoiceDescription[]] @("&Yes", "&No")
        $choice = $host.UI.PromptForChoice('Overwrite Confirmation', 'Sysinternals directory already exists. Want to overwrite it?', $choices, 1)

        if($choice -ne 0) {
            return;
        }
    }
    else {
        mkdir $output | out-null
    }

    if(-not(Test-Path($zip))) {
        Download-File $url -OutFile $zip
    }

    try {
        pushd $output

        unzip -o sysinternals.zip

        if($?) {
            rm $zip
            $output = cvpa $output
            Write-Host "Sysinternals tools unpacked at $output. Reload PSUtils module to get its aliases setted." -ForegroundColor Yellow
        }
    }
    finally {
        popd
    }

}
