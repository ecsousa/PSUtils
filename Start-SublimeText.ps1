function Start-SublimeText {
    $path = @(
        & {
            Join-Path $Env:ProgramFiles 'Sublime Text 3';
            if(${Env:ProgramFiles(x86)}) {
                Join-Path ${Env:ProgramFiles(x86)} 'Sublime Text 3';
            };

            Join-Path $Env:ProgramFiles 'Sublime Text 2';
            if(${Env:ProgramFiles(x86)}) {
                Join-Path ${Env:ProgramFiles(x86)} 'Sublime Text 2';
            };
        }
    ) | % {
        Join-Path $_ sublime_text.exe
    } | ? {
        Test-Path $_
    } | Select-Object -First 1

    if(-not($path)) {
        Write-Warning "Could not find Sublime Text"
        return;
    }

    Write-Verbose "Start Sublime Text from $path"

    & ($path) (Expand-Arguments $args | Resolve-PSDrive)

}


