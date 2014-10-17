function Download-File {
    param(
        [Parameter(Position=0, Mandatory=$TRUE, ValueFromPipeline=$false)]
        [System.Uri] $Uri,
        [Parameter(Position=1, Mandatory=$TRUE, ValueFromPipeline=$false)]
        [string] $OutFile
    );

    Write-Host "Downloading $($Uri.Segments[-1])... " -NoNewLine

    (new-object System.Net.WebClient).DownloadFile($uri, $OutFile)
    Write-Host "done!"

}


