Add-Type -AssemblyName 'System.Windows.Forms'

function Get-Clipboard {
    $clip = [Windows.Forms.Clipboard]::GetText();

    $current = 0;
    while($current -ge 0) {
        $idx = $clip.IndexOf([System.Environment]::NewLine, $current);

        if($idx -eq -1) {
            $clip.Substring($current);
            $current = $idx
        }
        else {
            $clip.Substring($current, $idx - $current);
            $current = $idx + 2
        }


    }
}

