function Get-Manual {
    param(
        [Parameter(Mandatory=$true,position=0)]
        [string] $cmd);

    $files = foreach($dir in (dir (Join-path $PSScriptRoot gnuwin32\man))) {
        $prefix = $dir.Name.Replace('cat', '');
        dir (join-path ($dir.FullName) "$cmd.$prefix.txt") -ErrorAction SilentlyContinue
    }

    if($files) {
        less $files[0]
    }
    else {
        Write-Warning "Could not find man page for $cmd."
    }
}

