
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

    $conemu = [xml] (Invoke-WebRequest 'https://code.google.com/feeds/p/conemu-maximus5/downloads/basic').Content

    $entry = $conemu.feed.entry | ? {$_.title.Split([System.Environment]::NewLine)[1] -like '*ConEmuPack.*.7z*'}

    if(-not($entry)) 
    {
        Write-Warning 'Could not find lastest ConEmu version'
        return;
    }

    $link = $entry.link | ? { $_.rel -eq 'direct'}

    if(-not($entry)) 
    {
        Write-Warning 'Could not find lastet ConEmu download link on feed'
        return;
    }


    if(-not (Test-Path $path)) {
        mkdir $path | out-null
    }

    Invoke-WebRequest $link.href -OutFile (Join-Path $path 'ConEmu.7z')

    pushd $path

    7z x ConEmu.7z
    rm ConEmu.7z
    mv ConEmu.exe ConEmu32.exe

    cp (Join-Path $PSScriptRoot 'ConEmu.xml') ConEmu.xml

    popd

}
