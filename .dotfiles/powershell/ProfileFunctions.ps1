function dotfiles {
    <#
    .SYNOPSIS
        Runs Git Commands against the dotfiles repository.
    .EXAMPLE
        dotfiles add changed_file.txt
        dotfiles commit -m "Changed the file"
    #>
    & git --git-dir=$HOME/.dotfiles/.git --work-tree=$HOME $args
}

function tinypng {
    <#
    .SYNOPSIS
        Command line helper to compress images with TinyPNG.
        An API Key must be set at ~/.dotfiles/tinypng_key
    .PARAMETER FilePath
        Defaults to the current directory.
        Accepts pipeline input.
        The paths to compress. If a directory, will minify the contents of the
        directory.
    .PARAMETER Recurse
        If set, directories will be recursively enumerated.
    .PARAMETER ApiKey
        If set, this key will be used instead of the contents of
        ~/.dotfiles/tinypng_key
    #>
    [CmdletBinding()]
    param(
        [Parameter(ValueFromPipeline)]
        [string[]] $FilePath = ".",
        [switch] $Recurse,
        [string] $ApiKey
    )

    begin {
        $ErrorActionPreference = "Stop"

        if (-not $ApiKey) {
            try {
                $ApiKey = Get-Content ([IO.Path]::Combine("~", ".dotfiles", "tinypng_key"))
            }
            catch {
                Write-Error "No API Key! Create an API key at https://tinypng.com/developers and put it in ~/.dotfiles/tinypng_key"
            }
        }

        $Headers = @{
            Authorization = "Basic " + [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes("api:$ApiKey"))
        }
    }

    process {
        $paths = Get-ChildItem $FilePath -Recurse:$Recurse | `
            Where-Object { $_.Extension -in ".png", ".jpg", ".jpeg" }
        foreach ($path in $paths) {
            try {
                Write-Output "Converting $path"
                $output = Invoke-RestMethod -Method Post `
                    -Uri "https://api.tinify.com/shrink" `
                    -Headers $Headers `
                    -ContentType "multipart/form-data" `
                    -InFile $path

                $minifiedUrl = $output.output.url

                Move-Item $path "$path.bak"
                Invoke-WebRequest $minifiedUrl -ContentType "application/json" -OutFile $path
                Remove-Item "$path.bak"
            }
            catch {
                Write-Error "Request for file $path failed" -ErrorAction Continue
            }
        }
    }
}

function New-GitIgnore {
    <#
    .SYNOPSIS
        Creates a new gitignore file from the github gitignore template
        repository.
    .PARAMETER Type
        Mandatory.

        The type of gitignore to create.
    #>
    param (
        [Parameter(Mandatory)]
        [ValidateSet(
            IgnoreCase = $false,
            "Actionscript", "Ada", "Agda", "Android", "AppceleratorTitanium",
            "AppEngine", "ArchLinuxPackages", "Autotools", "C", "C++",
            "CakePHP", "CFWheels", "ChefCookbook", "Clojure", "CMake",
            "CodeIgniter", "CommonLisp", "Composer", "Concrete5", "Coq",
            "CraftCMS", "CUDA", "D", "Dart", "Delphi", "DM", "Drupal", "Eagle",
            "Elisp", "Elixir", "Elm", "EPiServer", "Erlang", "ExpressionEngine",
            "ExtJs", "Fancy", "Finale", "ForceDotCom", "Fortran", "FuelPHP",
            "Gcov", "GitBook", "Go", "Godot", "Gradle", "Grails", "GWT",
            "Haskell", "Idris", "IGORPro", "Java", "JBoss", "Jekyll",
            "JENKINS_HOME", "Joomla", "Julia", "KiCad", "Kohana", "Kotlin",
            "LabVIEW", "Laravel", "Leiningen", "LemonStand", "Lilypond",
            "Lithium", "Lua", "Magento", "Maven", "Mercury",
            "MetaProgrammingSystem", "Nanoc", "Nim", "Node", "Objective-C",
            "OCaml", "Opa", "OpenCart", "OracleForms", "Packer", "Perl",
            "Phalcon", "PlayFramework", "Plone", "Prestashop", "Processing",
            "PureScript", "Python", "Qooxdoo", "Qt", "R", "Rails", "Raku",
            "RhodesRhomobile", "ROS", "Ruby", "Rust", "Sass", "Scala", "Scheme",
            "SCons", "Scrivener", "Sdcc", "SeamGen", "SketchUp", "Smalltalk",
            "Stella", "SugarCRM", "Swift", "Symfony", "SymphonyCMS",
            "Terraform", "TeX", "Textpattern", "TurboGears2", "TwinCAT3",
            "Typo3", "Umbraco", "Unity", "UnrealEngine", "VisualStudio", "VVVV",
            "Waf", "WordPress", "Xojo", "Yeoman", "Yii", "ZendFramework",
            "Zephir"
        )]
        [string] $Type
    )

    Invoke-WebRequest -Uri "https://raw.githubusercontent.com/github/gitignore/master/$Type.gitignore" -OutFile .gitignore
}

function Use-Env {
    <#
    .SYNOPSIS
        Sets environment variables for a single script block, then resets them.
    .PARAMETER Variables
        Mandatory.

        The environment variables to temporarily set.
    .PARAMETER ScriptBlock
        Mandatory.

        The ScriptBlock to run with the modified environment variables.
    .EXAMPLE
        Write-Output $env:hello # HELLO
        Use-Env @{hello = 5} { Write-Output $env:hello } # 5
        Write-Output $env:hello # HELLO
    #>
    param (
        [Parameter(Mandatory)]
        [hashtable] $Variables,

        [Parameter(Mandatory)]
        [scriptblock] $ScriptBlock
    )

    $previousVariables = Get-ChildItem Env:
    foreach ($nv in $Variables.GetEnumerator()) {
        Set-Item -Path (Join-Path Env: $nv.Name) -Value $nv.Value
    }
    Invoke-Command $ScriptBlock
    foreach ($nv in $previousVariables.GetEnumerator()) {
        Set-Item -Path (Join-Path Env: $nv.Name) -Value $nv.Value
    }
}
