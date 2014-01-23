$file = Join-Path $env:UserProfile psdrives.txt

if(Test-Path $file) {
    $reg = [regex] '^(\S+)\s+(\S.*)'

    foreach($linha in (gc $file)) {
        $m = $reg.Match($linha)
        $prefix = $m.Groups[1].Value;
        $path = $m.Groups[2].Value;

        "New-PSDrive -PSProvider FileSystem -Scope Global -Name $prefix -Root '$path' | out-null"
        "function Set-Location_$prefix { cd ${prefix}: }"
        "Set-Alias '${prefix}:' 'Set-Location_$prefix'"
        "Export-ModuleMember -function Set-Location_$prefix"
        "Export-ModuleMember -alias ${prefix}:"
    }

}
