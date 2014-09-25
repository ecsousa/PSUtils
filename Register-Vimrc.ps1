function Register-Vimrc {
    $vimrc = Join-Path $env:USERPROFILE _vimrc

    $newContent = & {
        $vimRuntime = Join-Path $PSScriptRoot vim
        $localRc = Join-Path $PSScriptRoot _vimrc

        if(Test-Path $vimrc) {
            sed $vimrc -e '/^\"\" >>>>>>>> PSUtils vim init\s*$/,/^\"\" <<<<<<<< PSUtils vim init\s*$/d'
        }
        else {
            touch $vimrc
        }

        '"" >>>>>>>> PSUtils vim init'
        "source $localRc"
        '"" <<<<<<<< PSUtils vim init'
    }

    Set-Content $vimrc $newContent
}

