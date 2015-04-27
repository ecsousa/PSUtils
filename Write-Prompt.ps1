function Test-Git {
    param([IO.DirectoryInfo] $dir)

    if(Test-Path (Join-Path $dir.FullName '.git')) {
        return $true;
    }

    if(($dir.Parent -eq $null) -or ($dir -eq $dir.Parent)) {
        return $false;
    }

    return Test-Git ($dir.Parent.FullName)
}

function Write-Prompt {
    if($global:FSFormatDefaultColor) {
        [Console]::ForegroundColor = $global:FSFormatDefaultColor
    }

    $isFS = (gi .).PSProvider.Name -eq 'FileSystem';

    if($isFS) {
        [system.Environment]::CurrentDirectory = (convert-path ".");
    }


    $user = [Security.Principal.WindowsIdentity]::GetCurrent();
    $admin = (New-Object Security.Principal.WindowsPrincipal $user).IsInRole([Security.Principal.WindowsBuiltinRole]::Administrator)

    $branch = $null;

    if( $isFS -and (Test-Git (cvpa .)) -and (which git)) {
        $branch = (git branch 2>$null) | %{ ([regex] '\* (.*)').match($_) } | ? { $_.Success } | %{ $_.Groups[1].Value } | Select-Object -First 1
    }

    $drive = (Get-Location).Drive

    if($drive.Root -eq "$($drive.Name):\") {
        $title = $executionContext.SessionState.Path.CurrentLocation

        if($branch) {
            $title = "[$branch] $title";
        }
    }
    else {
        $title = $drive.Name

        if($branch) {
            $title = "$title@$branch";
        }
    }

    $host.UI.RawUI.WindowTitle = $title

    if(Test-Ansi) {
        $begining = ''

        $ending = '>' * ($nestedPromptLevel + 1)

        function esc {
            param([string] $code);
            [char](27) + "[$code"
        }

        if($admin) {
            $color = '33;1m';
        }
        else {
            $color = '32;1m';
        }

        if($host.UI.RawUI.CursorPosition.ToString() -ne '0,0')
        {
            $begining = $begining + [Environment]::NewLine;
        }

        if($branch) {
            $begining = $begining + "$(esc '33;1m')[$(esc '36;1m')$branch$(esc '33;1m')] ";
        }

        return ( $begining + (esc $color) + $executionContext.SessionState.Path.CurrentLocation + $ending + (esc '37;2m') )
    }
    else {

        if($admin) {
            $color = 'Yellow';
        }
        else {
            $color = 'Green';
        }

        Write-Host ([System.Char](10)) -NoNewLine;

        if($branch) {
            Write-Host "[" -NoNewLine -ForegroundColor Yellow
            Write-Host "$branch" -NoNewLine -ForegroundColor Cyan
            Write-Host "] " -NoNewLine -ForegroundColor Yellow
        }

        Write-Host $executionContext.SessionState.Path.CurrentLocation -NoNewLine -ForegroundColor $color;
        Write-Host ('>' * ($nestedPromptLevel + 1)) -NoNewLine -ForegroundColor $color;

        if($host.Name -like 'StudioShell*') {
            return " ";
        }
        else {
            return " `b";
        }
    }


}


