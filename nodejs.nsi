/*=== !include "MUI.nsh" ; -use only to set custom icon ===*/
/*=== !define MUI_ICON "${NSISDIR}\Contrib\Icons\Youriconname.ico ===*/

RequestExecutionLevel admin ;
Unicode true
SilentInstall silent

/*--- Change these as you see fit ---*/
Name "NSIS-nodejs-installer"
OutFile "installer.exe"
InstallDir "$APPDATA\NSIS-nodejs-installer" /* this is the directory where the nodejs installer and install.js get downloaded to */
/*-----------------------------------*/


Function .onInit
/*--- Checks if already running installer: ---*/
  System::Call 'kernel32::CreateMutex(p 0, i 0, t "myMutex") p .r1 ?e'
    Pop $R0

    StrCmp $R0 0 +3
      MessageBox MB_OK|MB_ICONEXCLAMATION "The installer is already running."
      Abort
/*--------------------------------------------*/


/*--- Checks if connected to the internet ---*/
  ClearErrors
  Dialer::AttemptConnect
  IfErrors noie3
  Pop $R0
  StrCmp $R0 "online" connected
    MessageBox MB_OK|MB_ICONSTOP "Cannot connect to the internet. Internet is required for installation. Please connect and retry"
    Abort ; This will quit the installer. You might want to add your own error handling.
  noie3: ; IE3 not installed
  MessageBox MB_OK|MB_ICONINFORMATION "Please connect to the internet now to install Clusterio."
  connected:
/*-------------------------------------------*/
FunctionEnd

Section
/*--- Checks if node is installed by running 'node --version' ---*/
  nsExec::ExecToStack '"node" "--version"'
    Pop $0
    Pop $1
    MessageBox MB_OK|MB_ICONEXCLAMATION "debug $1" /SD IDOK
    StrCpy $2 $1 1
    StrCmp $2 "v" nInstallSucc 0 ; if it is installed, it will return vX.X.X, so we check for "v" then skip the install
/*---------------------------------------------------------------*/
/*--- downloads the node install .msi (version 14.15.3 x64 - change this url regularly!) ---*/
  inetc::get "https://nodejs.org/dist/v14.15.3/node-v14.15.3-x64.msi" "$INSTDIR\node-v14.15.3-x64.msi"
  Pop $0
    StrCmp $0 "OK" dlok
    MessageBox MB_OK|MB_ICONEXCLAMATION "Nodejs download Error, click OK to abort installation" /SD IDOK
    Quit
  dlok:

  ExecWait '"msiexec" /i "$INSTDIR\node-v14.15.3-x64.msi"' $0
    StrCmp $0 0 nInstallSucc 0
    StrCmp $0 1602 nInstallSucc 0
    MessageBox MB_OK|MB_ICONEXCLAMATION "Installer failed, because Nodejs install exited with exit code $0. Click OK to abort install" /SD IDOK
    Quit
  nInstallSucc:
/*------------------------------------------------------------------------------------------*/
/*--- downloads and runs your install.js (!!! YOU NEED TO CHANGE THIS URL !!!!!!!!!!!!!!)---*/
  inetc::get "https://raw.githubusercontent.com/smartguy1196/NSIS-nodejs/master/install.js" "$INSTDIR\install.js"
  Pop $0
    StrCmp $0 "OK" jlok
    MessageBox MB_OK|MB_ICONEXCLAMATION "Installer download error: could not download installation dependency: 'install.js'. click OK to abort installation" /SD IDOK
    Quit
  jlok:

  ExecWait '"node" "$INSTDIR\install.js"' $0
    StrCmp $0 0 jsInstallSucc 0
    MessageBox MB_OK|MB_ICONEXCLAMATION "Installer failed. Nodejs installed, but the installation script returned exit code $0. Click OK to abort install" /SD IDOK
    Quit
  jsInstallSucc:
/*------------------------------------------------------------------------------------------*/
  Quit
SectionEnd
