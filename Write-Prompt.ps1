$Global:TitlePrefix = '[psh] ';

function Write-Prompt {
    if((gi .).PSProvider.Name -eq 'FileSystem') {
        [system.Environment]::CurrentDirectory = (convert-path ".");
    }
 
	$host.UI.RawUI.WindowTitle = $Global:TitlePrefix + ([regex] '\\\.\.\\[^\\\.>]+').Replace((gl).Path, '\'); #(Get-Location);

    if($emuHk) {
        if($nestedpromptlevel -ge 1) {
            $ending = '>>>'
        }
        else {
            $ending = '>'
        }

        return ( [char](27) + '[32m' + [char](27) + '[1m' + ((([regex] '\\\.\.\\[^\\\.>]+').Replace((gl).Path, '\'))) + $ending + [char](27) + '[0m' )
    }
    else {

        Write-Host ([System.Char](10) + $((([regex] '\\\.\.\\[^\\\.>]+').Replace((gl).Path, '\'))) + $(if ($nestedpromptlevel -ge 1) { '>>' }) + '>') -NoNewLine -ForegroundColor Green;

        if($host.Name -like 'StudioShell*') {
            return " ";
        }
        else {
            return " `b";
        }
    }


}


