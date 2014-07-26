function Install-Vim {

    $urls = & {
        New-Object Uri('ftp://ftp.vim.org/pub/vim/pc/vim74rt.zip')
        New-Object Uri('ftp://ftp.vim.org/pub/vim/pc/gvim74.zip')
        New-Object Uri('ftp://ftp.vim.org/pub/vim/pc/vim74w32.zip')
    }

    $output = Join-Path $PSScriptRoot '..\vim'

    if(Test-Path $output) {
        $choices = [System.Management.Automation.Host.ChoiceDescription[]] @("&Yes", "&No")
        $choice = $host.UI.PromptForChoice('Overwrite Confirmation', 'Vim directory already exists. Want to overwrite it?', $choices, 1)

        if($choice -ne 0) {
            return;
        }
    }
    else {
        mkdir $output | out-null
    }

    foreach($url in $urls) {
        $zip = Join-Path $output $url.Segments[-1]

        if(-not(Test-Path($zip))) {
            Invoke-WebRequest $url -OutFile $zip
        }
    }


    try {
        pushd $output

        foreach($url in $urls) {
            $zip = Join-Path $output $url.Segments[-1]

            unzip -o $zip

            if($?) {
                rm $zip
            }
        }

        mv vim\vim74\* .
        rm vim\vim74
        rm vim

    }
    finally {
        popd
    }

}
