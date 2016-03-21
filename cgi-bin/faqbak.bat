@echo off
echo ___ FaqBAK - sichern der Daten der FAQ - Thomas Hofmann, Mar 2016 ___
REM @echo on

REM Verzeichnistiefe muss mindestens 2 sein UND darf aber hoechstens 2 sein
set FAQBAK_DRIVE=D:
set FAQBAK_ROOT=%FAQBAK_DRIVE%\work\
set FAQBAK_DIR=%FAQBAK_ROOT%faq\
set FAQBAK_LIST=faq-inh.dat faq-kat.dat faq-tit.dat faqbak.bat
set FAQBAK_XAMPPDRIVE=D:
set FAQBAK_SOURCE=%FAQBAK_XAMPPDRIVE%\xampp\htdocs\faq\cgi-bin\
set FAQBAK_ZIP=FAQBAK.zip
set FAQBAK_O_DRIVE=H:
set FAQBAK_O_ROOT=%FAQBAK_O_DRIVE%\work\
set FAQBAK_O_DIR=%FAQBAK_O_ROOT%faq\
set ZIP="C:\Program Files\7-Zip\7z.exe"

:checkdir
if not exist %FAQBAK_DIR%. goto dirnotfound
echo Yippieh! Verzeichnis %FAQBAK_DIR% gefunden

:dirfound
:performwork
%FAQBAK_DRIVE%
cd %FAQBAK_DIR%

:copyfiles
%FAQBAK_XAMPPDRIVE%
cd %FAQBAK_SOURCE%
 for %%f in ( %FAQBAK_LIST% ) do echo %%f %FAQBAK_DIR%
 for %%f in ( %FAQBAK_LIST% ) do copy /y %%f %FAQBAK_DIR%

:zipfiles
%FAQBAK_XAMPPDRIVE%
cd %FAQBAK_SOURCE%
%ZIP% u %FAQBAK_DIR%%FAQBAK_ZIP% %FAQBAK_LIST%

:copyfilesO
%FAQBAK_XAMPPDRIVE%
cd %FAQBAK_SOURCE%
 for %%f in ( %FAQBAK_LIST% ) do echo %%f %FAQBAK_O_DIR%
 for %%f in ( %FAQBAK_LIST% ) do copy /y %%f %FAQBAK_O_DIR%

:zipfilesO
%FAQBAK_XAMPPDRIVE%
cd %FAQBAK_SOURCE%
%ZIP% u %FAQBAK_O_DIR%%FAQBAK_ZIP% %FAQBAK_LIST%

:finished
goto ende

:dirnotfound
echo Verzeichnis %FAQBAK_DIR% nicht gefunden, suche FAQ-Root
if not exist %FAQBAK_ROOT%. goto rootnotfound

:rootfound
:createdir
%FAQBAK_DRIVE%
md %FAQBAK_DIR%
if not exist %FAQBAK_DIR%. goto dirreallynotfound
goto checkdir

:rootnotfound
echo FAQ Wurzel-Verzeichnis %FAQBAK_ROOT% nicht gefunden, suche Laufwerk
if not exist %FAQBAK_DRIVE%\. goto drivenotfound

:drivefound
:createroot
%FAQBAK_DRIVE%
md %FAQBAK_ROOT%
md %FAQBAK_DIR%
if not exist %FAQBAK_DIR%. goto dirreallynotfound
goto checkdir

:drivenotfound
echo Laufwerk %FAQBAK_DRIVE% nicht gefunden, Abbruch
goto ende

:dirreallynotfound
echo Verzeichnis %FAQBAK_DIR% wirklich nicht gefunden, Abbruch
goto ende

:ende
echo *** ENDE FaqBAK ***
