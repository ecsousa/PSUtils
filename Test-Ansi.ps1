function Test-Ansi {

    $oldPos = $host.UI.RawUI.CursorPosition.X

        Write-Host -NoNewline "$([char](27))[0m" -ForegroundColor ($host.UI.RawUI.BackgroundColor);

    $pos = $host.UI.RawUI.CursorPosition.X

        if($pos -eq $oldPos) {
            return $true;
        }
        else {
            Write-Host -NoNewLine ("`b" * 4)
            return $false
        }
}


