$Script:Version = "0.0.1"
[String]$Script:ScriptPath = Split-Path -Parent $MyInvocation.MyCommand.Definition
$Script:CommandString = @(
@"
hugo server --buildDrafts --buildExpired --buildFuture --navigateToChanged --forceSyncStatic --renderToMemory --cleanDestinationDir --gc
"@
,
@"
hugo server --environment production --navigateToChanged --forceSyncStatic --renderToMemory
"@
,
@"
hugo --minify --cleanDestinationDir --gc
"@
)

$debug = $false

function Initialize-WorkingDirectory {
    Set-Location $Script:ScriptPath
    # 已经将 [工作目录] 切换到 [此脚本所在目录] 下
}

function Invoke-Command {
    [CmdletBinding()]
    param (
        [Boolean]$is_debug = $true
    )
    $option = -1
    switch -Wildcard -CaseSensitive ($args[0]) {
        "1" { $option = 1 }
        "prev*" { $option = 1 }
        "2" { $option = 2 }
        "dist*" { $option = 2 }
        default { $option = 0 }
    }
    if ($is_debug) {
        $debugInfo = "[DEBUG] Script parameters: " + $args
        $debugInfo += " (`$option = $option)"
        $debugInfo += "`n[DEBUG] Try to exec this command:`n" + $Script:CommandString[$option]
        Write-Host $debugInfo
    }
    else {
        $command = [scriptblock]::Create($Script:CommandString[$option])
        & $command
    }
}

Initialize-WorkingDirectory
# $debug = $true
Invoke-Command($debug)