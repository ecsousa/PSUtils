function Register-Vimrc {
    $vimrc = Join-Path $env:USERPROFILE _vimrc

    $newContent = & {
        $vimRuntime = Join-Path $PSScriptRoot vim
        $vimInit = Join-Path $PSScriptRoot vim\init.vim

        if(Test-Path $vimrc) {
            sed $vimrc -e '/^\"\" >>>>>>>> PSUtils vim init\s*$/,/^\"\" <<<<<<<< PSUtils vim init\s*$/d'
        }

        '"" >>>>>>>> PSUtils vim init'
        "set runtimepath+=$vimRuntime"
        "source $vimInit"
        '"" <<<<<<<< PSUtils vim init'
    }

    Set-Content $vimrc $newContent
}

