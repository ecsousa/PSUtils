function Out-FilePSUtils { 
    
    [CmdletBinding(DefaultParameterSetName='ByPath', SupportsShouldProcess=$true, ConfirmImpact='Medium', HelpUri='http://go.microsoft.com/fwlink/?LinkID=113363')]
    param(

        [Parameter(ParameterSetName='ByPath', Mandatory=$true, Position=0)]
        [string]
        ${FilePath},

        [Parameter(ParameterSetName='ByLiteralPath', Mandatory=$true, ValueFromPipelineByPropertyName=$true)]
        [Alias('PSPath')]
        [string]
        ${LiteralPath},

        [Parameter(Position=1)]
        [ValidateNotNullOrEmpty()]
        [ValidateSet('unknown','string','unicode','bigendianunicode','utf8','utf7','utf32','ascii','default','oem')]
        [string]
        ${Encoding},

        [switch]
        ${Append},

        [switch]
        ${Force},

        [Alias('NoOverwrite')]
        [switch]
        ${NoClobber},

        [ValidateRange(2, 2147483647)]
        [int]
        ${Width},

        [Parameter(ValueFromPipeline=$true)]
        [psobject]
        ${InputObject}
    )
    begin
    {
       try {
           
     
           ## Access the REAL Foreach-Object command, so that command
           ## wrappers do not interfere with this script
           $foreachObject = $executionContext.InvokeCommand.GetCmdlet(
               "Microsoft.PowerShell.Core\Foreach-Object")
     
           $wrappedCmd = $ExecutionContext.InvokeCommand.GetCommand(
               'Out-File',
               [System.Management.Automation.CommandTypes]::Cmdlet)
     
           ## TargetParameters represents the hashtable of parameters that
           ## we will pass along to the wrapped command
           $targetParameters = @{}
           $PSBoundParameters.GetEnumerator() |
               & $foreachObject {
                   if($command.Parameters.ContainsKey($_.Key))
                   {
                       $targetParameters.Add($_.Key, $_.Value)
                   }
               }
     
           ## finalPipeline represents the pipeline we wil ultimately run
           $newPipeline = { & $wrappedCmd @targetParameters }
           $finalPipeline = $newPipeline.ToString()
     
           
     
           $steppablePipeline = [ScriptBlock]::Create(
               $finalPipeline).GetSteppablePipeline()
           $global:SuppresPSUtilsColoring = $true;
           $steppablePipeline.Begin($PSCmdlet)
       } catch {
           throw
       }
    }
     
    process
    {
       try {
           
           $steppablePipeline.Process($_)
       } catch {
           throw
       }
    }
     
    end
    {
       try {
           
           $steppablePipeline.End()
           $global:SuppresPSUtilsColoring = $false;
       } catch {
           throw
       }
    }
     
    dynamicparam
    {
       ## Access the REAL Get-Command, Foreach-Object, and Where-Object
       ## commands, so that command wrappers do not interfere with this script
       $getCommand = $executionContext.InvokeCommand.GetCmdlet(
           "Microsoft.PowerShell.Core\Get-Command")
       $foreachObject = $executionContext.InvokeCommand.GetCmdlet(
           "Microsoft.PowerShell.Core\Foreach-Object")
       $whereObject = $executionContext.InvokeCommand.GetCmdlet(
           "Microsoft.PowerShell.Core\Where-Object")
     
       ## Find the parameters of the original command, and remove everything
       ## else from the bound parameter list so we hide parameters the wrapped
       ## command does not recognize.
       $command = & $getCommand Out-File -Type Cmdlet
       $targetParameters = @{}
       $PSBoundParameters.GetEnumerator() |
           & $foreachObject {
               if($command.Parameters.ContainsKey($_.Key))
               {
                   $targetParameters.Add($_.Key, $_.Value)
               }
           }
     
       ## Get the argumment list as it would be passed to the target command
       $argList = @($targetParameters.GetEnumerator() |
           Foreach-Object { "-$($_.Key)"; $_.Value })
     
       ## Get the dynamic parameters of the wrapped command, based on the
       ## arguments to this command
       $command = $null
       try
       {
           $command = & $getCommand Out-File -Type Cmdlet `
               -ArgumentList $argList
       }
       catch
       {
     
       }
     
       $dynamicParams = @($command.Parameters.GetEnumerator() |
           & $whereObject { $_.Value.IsDynamic })
     
       ## For each of the dynamic parameters, add them to the dynamic
       ## parameters that we return.
       if ($dynamicParams.Length -gt 0)
       {
           $paramDictionary = `
               New-Object Management.Automation.RuntimeDefinedParameterDictionary
           foreach ($param in $dynamicParams)
           {
               $param = $param.Value
               $arguments = $param.Name, $param.ParameterType, $param.Attributes
               $newParameter = `
                   New-Object Management.Automation.RuntimeDefinedParameter `
                   $arguments
               $paramDictionary.Add($param.Name, $newParameter)
           }
           return $paramDictionary
       }
    }
     
<#
 
.ForwardHelpTargetName Out-File
.ForwardHelpCategory Cmdlet
 
#>
}
