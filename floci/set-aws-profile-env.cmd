@echo off

if "%~1"=="" (
  set "AWS_PROFILE=testing"
) else (
  set "AWS_PROFILE=%~1"
)

if "%~2"=="" (
  set "AWS_REGION=eu-central-1"
) else (
  set "AWS_REGION=%~2"
)

set "AWS_DEFAULT_REGION=%AWS_REGION%"
set "AWS_SDK_LOAD_CONFIG=1"

echo AWS_PROFILE=%AWS_PROFILE%
echo AWS_REGION=%AWS_REGION%
echo AWS_DEFAULT_REGION=%AWS_DEFAULT_REGION%
echo AWS_SDK_LOAD_CONFIG=%AWS_SDK_LOAD_CONFIG%
echo.
echo Variables configuradas para esta sesion de CMD.
echo Ahora puedes ejecutar: terraform plan
