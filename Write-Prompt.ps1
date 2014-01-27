$Global:TitlePrefix = '[psh] ';

function Write-Prompt {
    if((gi .).PSProvider.Name -eq 'FileSystem') {
        [system.Environment]::CurrentDirectory = (convert-path ".");
    }
 
	$host.UI.RawUI.WindowTitle = $Global:TitlePrefix + ([regex] '\\\.\.\\[^\\\.>]+').Replace((gl).Path, '\'); #(Get-Location);

    Write-Host ([System.Char](10) + $((([regex] '\\\.\.\\[^\\\.>]+').Replace((gl).Path, '\'))) + $(if ($nestedpromptlevel -ge 1) { '>>' }) + '>') -NoNewLine -ForegroundColor Green;

    return " `b";

}

