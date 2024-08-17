@echo off
setlocal

@REM set "HUGO_CONTENT_DIR=TODO"

hugo server --environment staging ^
  --contentDir "%HUGO_CONTENT_DIR%" ^
  --port 1314 ^
  --appendPort false ^
  --printMemoryUsage --printPathWarnings ^
  --logLevel warn ^
  --watch ^
  --navigateToChanged ^
  --forceSyncStatic ^
  --cleanDestinationDir ^
  --renderToMemory ^
  --gc

endlocal