
function Install-ConEmu {

    $path = (Join-Path $PSScriptRoot '..\ConEmu\')

    if(Test-Path $path) {
        $choices = [System.Management.Automation.Host.ChoiceDescription[]] @("&Yes", "&No")
        $choice = $host.UI.PromptForChoice('Overwrite Confirmation', 'ConEmu directory already exists. Want to overwrite it?', $choices, 1)

        if($choice -eq 0) {
            rm -rec -for $path
        }
        else {
            return
        }
    }

    if(-not (Test-Path $path)) {
        mkdir $path | out-null
    }

    Invoke-WebRequest 'http://ecsousa.github.io/ConEmuPack.7z' -OutFile (Join-Path $path 'ConEmu.7z')

    pushd $path

    sevenZip x ConEmu.7z
    rm ConEmu.7z

    cp (Join-Path $PSScriptRoot 'ConEmu.xml') ConEmu.xml

    popd

}
