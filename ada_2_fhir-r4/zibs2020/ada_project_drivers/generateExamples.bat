@echo off
setlocal enabledelayedexpansion

:: CHECK BEFORE RUNNING ####
SET jarPath=C:\Saxon\saxon-he-10.5.jar
SET inputDir=..\ada_instance
SET outputDir=..\fhir_instance

if not exist "%jarPath%" (
    echo.
    echo.Did not find Saxon JAR here '%jarPath%'. Either add it here, or change the script to supply a different path...
    echo.http://saxon.sourceforge.net
    pause
)

if exist "%outputDir%" (
    echo.
    echo Removing output dir
    rmdir "%outputDir%" /s /q
)

for /f %%f in ('dir /b "%inputDir%"') do (
 set id=%%~nf
 if "!id:~0,8!" == "nl-core-" (
  if not exist "%inputDir%\!id!-bundled.xml" (
   echo Converting !id!
   set noDriverId=!id:-bundled=!
   set baseId=!noDriverId:~0, -3!

   java -jar "%jarPath%" -s:"%inputDir%/!id!.xml" -xsl:!baseId!-driver.xsl -o:"%outputDir%/!noDriverId!.xml
  )
 )
)

pause