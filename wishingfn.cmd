@echo off
setlocal
set DIR=%~dp0
if exist "%DIR%WishingFn.exe" (
  "%DIR%WishingFn.exe" %*
) else (
  python -m wishingfn %*
)
