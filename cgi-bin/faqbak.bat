@echo off
echo ___ FaqBAK - sichern der Daten der FAQ - Thomas Hofmann, Mar 2016 ___
REM @echo on

echo *** pushd ***
pushd .

REM Verzeichnistiefe muss mindestens 2 sein UND darf aber hoechstens 2 sein
set FAQBAK_BATNAME=faqbak.bat
set FAQBAK_DOKNAME=DRX-FAQ-Bearbeiten-der-FAQ.pdf
set FAQBAK_DRIVE=D:
set FAQBAK_ROOT=%FAQBAK_DRIVE%\work\
set FAQBAK_DIR=%FAQBAK_ROOT%faq\
set FAQBAK_IMG_DIR=%FAQBAK_DIR%img\
set FAQBAK_XAMPPDRIVE=D:
set FAQBAK_SOURCE=%FAQBAK_XAMPPDRIVE%\xampp\htdocs\faq\cgi-bin\
set FAQBAK_IMG_SRC=%FAQBAK_SOURCE%..\img\
set FAQBAK_ZIP=FAQBAK-%DATE%.zip
set FAQBAK_ZIP_SMALL=F%DATE%.zip
set FAQBAK_IMG_ZIP=FAQBAK-IMG-%DATE%.zip
set FAQBAK_CGI_ZIP=FAQBAK-CGI.zip
set FAQBAK_LIST_CONF=faq_i18n.conf faq_i18n-*.conf
set FAQBAK_LIST=faq-inh.dat faq-kat.dat faq-tit.dat index.php tagleft.gif tagleft-dark.gif %FAQBAK_BATNAME% %FAQBAK_DOKNAME% %FAQBAK_IMG_ZIP% %FAQBAK_CGI_ZIP% %FAQBAK_LIST_CONF%
set FAQBAK_LIST_SMALL=faq-inh.dat faq-kat.dat faq-tit.dat index.php %FAQBAK_BATNAME% %FAQBAK_CGI_ZIP% %FAQBAK_LIST_CONF%
set FAQBAK_H_DRIVE=H:
set FAQBAK_H_ROOT=%FAQBAK_H_DRIVE%\work\
set FAQBAK_H_DIR=%FAQBAK_H_ROOT%faq\
set FAQBAK_H_ZIP_DIR=%FAQBAK_H_DIR%zip\
set FAQBAK_O_DRIVE=O:
set FAQBAK_O_ROOT=%FAQBAK_O_DRIVE%\DRXTransfer\
set FAQBAK_O_ROOT=%FAQBAK_O_DRIVE%\_DRXGroup\I\006_SW_Dev\300_SW_Development\312_Build_QA_Rollout\_Orga\Team\
set FAQBAK_O_PARENT=HofmannThomas
set FAQBAK_O_DIR=%FAQBAK_O_ROOT%%FAQBAK_O_PARENT%\faq\
set ZIP="C:\Program Files\7-Zip\7z.exe"
set FAQBAK_BAT=D:\temp\%FAQBAK_BATNAME%
set FAQBAK_DOK=D:\temp\%FAQBAK_DOKNAME%

:checkdir
if not exist %FAQBAK_DIR%. goto dirnotfound
echo ___ Yippieh! Verzeichnis %FAQBAK_DIR% gefunden _____________________________

:dirfound
:performwork
%FAQBAK_DRIVE%
cd %FAQBAK_DIR%

:copyfiles
%FAQBAK_XAMPPDRIVE%
cd %FAQBAK_SOURCE%
REM  copy images
%ZIP% u -r %FAQBAK_IMG_ZIP% %FAQBAK_IMG_SRC%*.*
%ZIP% u %FAQBAK_CGI_ZIP% *.pl *.css
  echo ___ Hole Batch-Job ___ %FAQBAK_BAT% _____________________________
  copy %FAQBAK_BAT% .
REM  echo Fertig Hole Batch-Job ___ %FAQBAK_BAT%
  echo ___ Hole Doku ___ %FAQBAK_DOK% _____________________________
  copy %FAQBAK_DOK% .
REM  echo ___ Fertig Hole Doku ___ %FAQBAK_DOK%
 for %%f in ( %FAQBAK_LIST% ) do echo %%f %FAQBAK_DIR%
 for %%f in ( %FAQBAK_LIST% ) do copy /y %%f %FAQBAK_DIR%
 
:zipfiles
%FAQBAK_XAMPPDRIVE%
cd %FAQBAK_SOURCE%
%ZIP% u %FAQBAK_DIR%%FAQBAK_ZIP% %FAQBAK_LIST%


:check_H_dir
if not exist %FAQBAK_H_DIR%. goto dir_H_notfound
echo ___ Yippieh! Verzeichnis %FAQBAK_H_DIR% gefunden _____________________________

:copyfilesH
%FAQBAK_XAMPPDRIVE%
cd %FAQBAK_SOURCE%
 for %%f in ( %FAQBAK_LIST% ) do echo %%f %FAQBAK_H_DIR%
 for %%f in ( %FAQBAK_LIST% ) do copy /y %%f %FAQBAK_H_DIR%

:zipfilesH
%FAQBAK_XAMPPDRIVE%
cd %FAQBAK_SOURCE%
%ZIP% u %FAQBAK_H_DIR%%FAQBAK_ZIP% %FAQBAK_LIST%
del %FAQBAK_H_DIR%%FAQBAK_IMG_ZIP%

:check_H_zip
echo ___ check_H_zip _____________________________
REM pause
if not exist %FAQBAK_H_ZIP_DIR%. goto dir_H_ZIP_notfound
echo Yippieh! Verzeichnis %FAQBAK_H_ZIP_DIR% gefunden

:copyfilesHZIP
REM %FAQBAK_XAMPPDRIVE%
REM cd %FAQBAK_SOURCE%
 REM for %%f in ( %FAQBAK_LIST_SMALL% ) do echo %%f %FAQBAK_H_ZIP_DIR%
 REM for %%f in ( %FAQBAK_LIST_SMALL% ) do copy /y %%f %FAQBAK_H_ZIP_DIR%

:zipfilesHZIP
%FAQBAK_XAMPPDRIVE%
cd %FAQBAK_SOURCE%
REM %ZIP% u %FAQBAK_H_ZIP_DIR%%FAQBAK_ZIP_SMALL% %FAQBAK_LIST_SMALL%
%ZIP% u %FAQBAK_H_DIR%%FAQBAK_ZIP_SMALL% %FAQBAK_LIST_SMALL%
echo __ ENDE zipfilesHZIP _____________________________

:base64H
%FAQBAK_H_DRIVE%
cd %FAQBAK_H_ZIP_DIR%
call base64 -o %FAQBAK_H_DIR%%FAQBAK_ZIP_SMALL% %FAQBAK_ZIP_SMALL%.b64
echo __ ENDE base64H _____________________________
REM pause


:check_O_dir
REM @echo on
%FAQBAK_O_DRIVE%
if not exist %FAQBAK_O_DIR%. goto dir_O_notfound
echo ___ Yippieh! Verzeichnis %FAQBAK_O_DIR% gefunden _____________________________

:copyfilesO
%FAQBAK_XAMPPDRIVE%
cd %FAQBAK_SOURCE%
 for %%f in ( %FAQBAK_LIST% ) do echo %%f %FAQBAK_O_DIR%
 for %%f in ( %FAQBAK_LIST% ) do copy /y %%f %FAQBAK_O_DIR%

:zipfilesO
%FAQBAK_XAMPPDRIVE%
cd %FAQBAK_SOURCE%
%ZIP% u %FAQBAK_O_DIR%%FAQBAK_ZIP% %FAQBAK_LIST%
del %FAQBAK_O_DIR%%FAQBAK_IMG_ZIP%


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


:dir_O_reallynotfound
echo Verzeichnis %FAQBAK_O_DIR% wirklich nicht gefunden, Abbruch
goto ende

:dir_O_notfound
REM @echo on
@echo Verzeichnis %FAQBAK_O_DIR% nicht gefunden, suche FAQ_O_PARENT
if not exist %FAQBAK_O_ROOT%%FAQBAK_O_PARENT%\. goto FAQ_O_PARENTnotfound
md %FAQBAK_O_DIR%
if not exist %FAQBAK_O_DIR%. goto dir_O_reallynotfound
goto check_O_dir

:FAQ_O_PARENTnotfound
md %FAQBAK_O_ROOT%%FAQBAK_O_PARENT%
md %FAQBAK_O_DIR%
if not exist %FAQBAK_O_DIR%. goto dir_O_reallynotfound
goto check_O_dir

:dir_H_reallynotfound
echo Verzeichnis %FAQBAK_H_DIR% wirklich nicht gefunden, Abbruch
goto ende

:dir_H_notfound
echo Verzeichnis %FAQBAK_H_DIR% nicht gefunden, suche FAQ_H_PARENT
if not exist %FAQBAK_H_ROOT%\. goto FAQ_H_PARENTnotfound
md %FAQBAK_H_DIR%
if not exist %FAQBAK_H_DIR%. goto dir_H_reallynotfound
goto check_H_dir

:FAQ_H_PARENTnotfound
md %FAQBAK_H_ROOT%
md %FAQBAK_H_DIR%
if not exist %FAQBAK_H_DIR%. goto dir_H_reallynotfound
goto check_H_dir

:dir_H_ZIP_notfound
echo Verzeichnis %FAQBAK_H_ZIP_DIR% nicht gefunden, versuche es anzulegen
md %FAQBAK_H_ZIP_DIR%
if not exist %FAQBAK_H_ZIP_DIR%. goto dir_H_ZIP_reallynotfound
goto check_H_ZIP

:dir_H_ZIP_reallynotfound
echo Verzeichnis %FAQBAK_H_ZIP_DIR% wirklich nicht gefunden, SMALL ZIP uebersprungen!
pause
goto check_O_dir


:ende
del %FAQBAK_SOURCE%%FAQBAK_IMG_ZIP%
echo *** ENDE FaqBAK ***

echo *** popd ***
popd
