
function New-Solution {
    param(
            [Parameter(Position=0, Mandatory=$TRUE, ValueFromPipeline=$TRUE)]
            [IO.FileInfo] $project,
            [string] $version = '12.00'

         );

    begin {
        switch($version) {
            '12.00' {
                ''
                'Microsoft Visual Studio Solution File, Format Version 12.00'
                '# Visual Studio 2013'
                'VisualStudioVersion = 12.0.30110.0'
                'MinimumVisualStudioVersion = 10.0.40219.1'
            }

            '11.00' {
                ''
                'Microsoft Visual Studio Solution File, Format Version 11.00'
                '# Visual Studio 2012'
            }

            default {
                "Microsoft Visual Studio Solution File, Format Version $version"
            }
        }

        $baseUri = new-Object Uri("$(cvpa .\)\")
        $projects = @()

    }

    process {
        $name = $project.Basename
        $path = $baseUri.MakeRelativeUri((new-object Uri((cvpa $project)))).ToString().Replace('/', '\')
        $projId = ([xml] (gc $project)).Project.PropertyGroup[0].ProjectGuid

        $projType = switch($project.Extension.ToLower()) {
            '.csproj' { 'FAE04EC0-301F-11D3-BF4B-00C04F79EFBC' };
            '.vbproj' { 'F184B08F-C81C-45F6-A57F-5ABD9991F28F' };
            '.fsproj' { 'F2A71F9B-5D33-465A-A702-920D77279786' };
            '.vcxproj' { '8BC9CEB8-8B4A-11D0-8D11-00A0C91BC942' };
            default { '00000000-0000-0000-0000-000000000000' };
        }


        "Project(`"$projType`") = `"$name`", `"$path`", `"$projId`""
        'EndProject'

        $projects += $projId
    }

    end {
        "Global"
        "	GlobalSection(SolutionConfigurationPlatforms) = preSolution"
        "		Debug|Any CPU = Debug|Any CPU"
        "		Release|Any CPU = Release|Any CPU"
        "	EndGlobalSection"
        "	GlobalSection(ProjectConfigurationPlatforms) = postSolution"
        foreach($proj in $projects) {
            "		$proj.Debug|Any CPU.ActiveCfg = Debug|Any CPU"
            "		$proj.Debug|Any CPU.Build.0 = Debug|Any CPU"
            "		$proj.Release|Any CPU.ActiveCfg = Release|Any CPU"
            "		$proj.Release|Any CPU.Build.0 = Release|Any CPU"
        }
        "	EndGlobalSection"
        "EndGlobal"
    }
}

