@setlocal enableextensions

@echo off

echo.ant mp9 30 ada2fhir-r4 Touchstone Cert setup ...
call ant -f _ant-buildfiles\ant-publish\build-ada2fhir-mp9-30-TS-Cert.xml setup_30 >ant-setup.log
echo.Done
pause
