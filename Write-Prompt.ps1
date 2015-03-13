$Global:TitlePrefix = '[psh] ';

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
    $isFS = (gi .).PSProvider.Name -eq 'FileSystem';

    if($isFS) {
        [system.Environment]::CurrentDirectory = (convert-path ".");
    }
 
	$host.UI.RawUI.WindowTitle = $Global:TitlePrefix + ([regex] '\\\.\.\\[^\\\.>]+').Replace((gl).Path, '\'); #(Get-Location);

    $user = [Security.Principal.WindowsIdentity]::GetCurrent();
    $admin = (New-Object Security.Principal.WindowsPrincipal $user).IsInRole([Security.Principal.WindowsBuiltinRole]::Administrator)

    $branch = $null;
    
    if( $isFS -and (Test-Git (cvpa .)) -and (which git)) {
        $branch = (git branch 2>$null) | %{ ([regex] '\* (.*)').match($_) } | ? { $_.Success } | %{ $_.Groups[1].Value } | Select-Object -First 1
    }


    if($emuHk) {
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
            $begining = $begining + "$(esc '36;1m')($branch) ";
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
            Write-Host "($branch) " -NoNewLine -ForegroundColor Cyan
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


