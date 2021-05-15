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
