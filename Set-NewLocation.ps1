function Set-NewLocation {
    param(
            [Parameter(Position=0, Mandatory=$TRUE, ValueFromPipeline=$FALSE)]
            [string] $path
         );

    if(Test-Path($path)) {
        cd $path
    }
    else {
        cd (md $path)
    }
}
