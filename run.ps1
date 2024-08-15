# $env:HUGO_MODULE_REPLACEMENTS = "github.com/unacro/hugo-theme-blowfish-mod -> ../../hugo-theme-blowfish-mod"
$env:HUGO_NOCODB_TOKEN = "This is a NocoDB token @$(Get-Date -Format "yyyy-MM-dd HH:mm:ss")"

[int]$Script:Port = 1313
[string]$Script:Version = "0.1.0"
[string]$Script:ScriptPath = Split-Path -Parent $MyInvocation.MyCommand.Definition
[string[]]$Script:CommandString = @(
  # https://gohugo.io/commands/hugo_server/
  # --appendPort false 无效 原因不明
  # --panicOnWarning
  @"
hugo server ``
  --baseURL "http://dev.ews.internal/" ``
  --port ${Script:Port} ``
  --appendPort false ``
  --printI18nWarnings --printMemoryUsage --printPathWarnings --printUnusedTemplates ``
  --logLevel debug ``
  --disableBrowserError ``
  --watch ``
  --noHTTPCache ``
  --forceSyncStatic ``
  --cleanDestinationDir ``
  --renderToMemory ``
  --gc
"@, # development 开发网站本身 (采用本地主题 渲染远程仓库内容)
  @"
hugo server --environment staging ``
  --contentDir '${env:BLOG_CONTENT}' ``
  --baseURL "http://writing.ews.internal/" ``
  --port $($Script:Port + 1) ``
  --appendPort false ``
  --printI18nWarnings --printMemoryUsage --printPathWarnings --printUnusedTemplates ``
  --logLevel warn ``
  --watch ``
  --navigateToChanged ``
  --forceSyncStatic ``
  --cleanDestinationDir ``
  --renderToMemory ``
  --gc
"@, # staging 撰写博客文章 (采用本地主题 渲染本地文件内容)
  @"
hugo server --environment production ``
  --baseURL "http://preview.ews.internal/" ``
  --port $($Script:Port + 2) ``
  --appendPort false ``
  --printI18nWarnings --printMemoryUsage --printPathWarnings --printUnusedTemplates ``
  --logLevel info ``
  --disableFastRender ``
  --cleanDestinationDir ``
  --minify ``
  --gc
"@ # production 预览生产环境效果 (采用远程主题 渲染远程仓库内容)
  @"
hugo --environment production ``
  --cleanDestinationDir ``
  --minify ``
  --gc
"@ # production 正常编译 (测试编译结果 以便纳入自动 CI/CD 工作流)
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
    "0" { $option = 0 }
    "dev*" { $option = 0 }
    "1" { $option = 1 }
    "edit*" { $option = 1 }
    "2" { $option = 2 }
    "prev*" { $option = 2 }
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
