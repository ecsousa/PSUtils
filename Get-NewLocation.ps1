function Get-NewLocation {
    param(
            [Parameter(Position=0, Mandatory=$TRUE, ValueFromPipeline=$FALSE)]
            [string] $path
         );

    if(Test-Path($path)) {
        gi $path
    }
    else {
        md $path
    }
}
