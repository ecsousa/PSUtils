Add-Type -AssemblyName 'System.Windows.Forms'

function Set-Clipboard {
    $str = $input | Out-String

    [Windows.Forms.Clipboard]::Clear();

    if ( ($str -ne $null) -and ($str -ne '') ) {
        [Windows.Forms.Clipboard]::SetText( $str )
    }
}

