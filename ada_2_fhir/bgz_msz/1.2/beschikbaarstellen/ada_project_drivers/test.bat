@echo off
setlocal enabledelayedexpansion

:: CHECK BEFORE RUNNING ####
if "%saxonPath%"=="" (
  SET saxonPath=C:\Program Files\Java\Saxon\saxon-he-11.4.jar
)
SET inputDir=..\ada_processed
SET xsltDir=..\payload
SET outputDir=..\fhir_instance_bundles


if not exist "%saxonPath%" (
    echo.
    echo.Did not find Saxon JAR here '%saxonPath%'. Either add it here or set the 'saxonPath' environment variable to supply a different path...
    echo.http://saxon.sourceforge.net
    pause
)

for /f %%f in ('dir /b "%inputDir%"') do (
	set id=%%~nf
	call :doTransformation !id!
)

pause
exit /b


:doTransformation
set input=%1

echo Converting !input!
set noDriverId=!input:-bundled=!
set baseId=!noDriverId:~0, -3!

echo Removing previous output
if exist "%outputDir%\!noDriverId!*.xml" (
	del "%outputDir%\!noDriverId!*.xml" /Q
)


java -jar "%saxonPath%" -s:"%inputDir%/!input!.xml" -xsl:"%xsltDir%/beschikbaarstellen_2_fhir.xsl" -o:"%outputDir%/!noDriverId!.xml