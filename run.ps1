# $env:HUGO_MODULE_REPLACEMENTS = "github.com/unacro/hugo-theme-blowfish-mod -> ../../hugo-theme-blowfish-mod"
$env:HUGO_NOCODB_TOKEN = "This is a NocoDB token @$(Get-Date -Format "yyyy-MM-dd HH:mm:ss")"

[int]$Script:Port = 1313
[string]$Script:Version = "0.1.0"
[string]$Script:ScriptPath = Split-Path -Parent $MyInvocation.MyCommand.Definition
[string[]]$Script:CommandString = @(
  # https://gohugo.io/commands/hugo_server/
  # --disableBrowserError      do not show build errors in the browser
  # --disableFastRender        enables full re-renders on changes
  # --forceSyncStatic          copy all files when static is changed.
  # --noHTTPCache              prevent HTTP caching
  # --printUnusedTemplates
  @"
hugo server ``
  --contentDir '${env:BLOG_CONTENT}' ``
  --gc ``
  --logLevel info ``
  --navigateToChanged ``
  --port ${Script:Port} ``
  --printMemoryUsage --printPathWarnings ``
  --watch ``
  --forceSyncStatic ``
  --renderToMemory
"@, # development
@"
hugo server --environment staging ``
  --cleanDestinationDir ``
  --contentDir '${env:BLOG_CONTENT}' ``
  --gc ``
  --logLevel info ``
  --minify ``
  --navigateToChanged ``
  --port $($Script:Port + 1) ``
  --printMemoryUsage --printPathWarnings ``
  --watch ``
  --forceSyncStatic ``
  --renderToMemory
"@, # staging
  @"
hugo server --environment production ``
  --cleanDestinationDir ``
  --gc ``
  --logLevel info ``
  --minify ``
  --navigateToChanged ``
  --panicOnWarning ``
  --port $($Script:Port + 1) ``
  --printMemoryUsage --printPathWarnings ``
  --watch ``
  --forceSyncStatic ``
  --renderToMemory
"@ # production
  @"
hugo --environment production ``
  --minify ``
  --cleanDestinationDir ``
  --gc
"@ # production (build & deploy)
)

[bool]$debugMode = $false

function Initialize-WorkingDirectory {
  # 将 [工作目录] 切换到 [此脚本所在目录] 下
  Set-Location $Script:ScriptPath
}

function Invoke-Command {
  [CmdletBinding()]
  param (
    [bool]$isDebug = $true
  )
  [int]$option = -1
  switch -Wildcard -CaseSensitive ($args[0]) {
    "1" { $option = 1 }
    "edit*" { $option = 1 }
    "2" { $option = 2 }
    "prev*" { $option = 3 }
    "3" { $option = 3 }
    "dist*" { $option = 3 }
    default { $option = 0 }
  }
  if ($option -eq 1 -and (-not (Test-Path $env:BLOG_CONTENT))) {
    [string]$invalidInfo = "Custom hugo content path ${env:BLOG_CONTENT} is invalid."
    # Write-Error $invalidInfo
    Write-Warning $invalidInfo
    return
  }
  if ($isDebug) {
    [string]$debugInfo = "[DEBUG] Script parameters: " + $args
    $debugInfo += " (`$option = $option)"
    $debugInfo += "`n[DEBUG] Try to exec this command:`n" + $Script:CommandString[$option]
    Write-Host $debugInfo
    return
  }
  $command = [scriptblock]::Create($Script:CommandString[$option])
  & $command
}

Initialize-WorkingDirectory
# $debugMode = $true
Invoke-Command($debugMode)