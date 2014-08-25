$file = Join-Path $env:UserProfile psdrives.txt

$reg = [regex] '^(\S+)\s+(\S.*)'

$current = (gl).Path.Split(':') | select-object -First 1

foreach($linha in & {if(Test-Path($file)) { gc $file; }; "psu $PSScriptRoot"; } ) { 
    $m = $reg.Match($linha)

    if($m.Success) {
        $prefix = $m.Groups[1].Value.Trim();
        $path = $m.Groups[2].Value.Trim();

        Write-Verbose "[PSUtils] Mapping ${prefix}: PSDrive to $path"

        if($prefix.ToLower() -ne $current.ToLower()) {

            "get-psdrive $prefix -ErrorAction SilentlyContinue | Remove-PsDrive"
            "New-PSDrive -PSProvider FileSystem -Scope Global -Name $prefix -Root '$path' | out-null"
        }

        "function Set-Location_$prefix { cd ${prefix}: }"
        "Set-Alias '${prefix}:' 'Set-Location_$prefix'"
        "Export-ModuleMember -function Set-Location_$prefix"
        "Export-ModuleMember -alias ${prefix}:"
    }
}

