function Get-FindLocation
{
    param(
            [Parameter(Position=0, Mandatory=$TRUE, ValueFromPipeline=$TRUE)]
            [string] $Searchee
         );

    (gci (Join-Path Alias: $Searchee) -ErrorAction SilentlyContinue) | % { 
        if($_.ResolvedCommand.CommandType -eq 'Application') {
            '[ALIAS] ' + $_.ResolvedCommand.Definition
        }
        else {
            '[ALIAS] ' + $_.ResolvedCommand.Name
        }
    }


    (gc Env:\Path).Split(';') |
        ? { -not([string]::IsNullOrWhitespace($_)) } |
        ? {Test-Path (Join-Path $_ "$Searchee.*")} |
        % { gi (Join-Path $_ "$Searchee.*") } |
        % { $_.FullName }
}
