RequestExecutionLevel admin ;
Name "NSIS-nodejs-installer"
Unicode true
InstallDir "$LOCALAPPDATA\NSIS-nodejs-installer"
SilentInstall silent
OutFile "installer.exe"

Function .onInit
  System::Call 'kernel32::CreateMutex(p 0, i 0, t "myMutex") p .r1 ?e'
    Pop $R0

    StrCmp $R0 0 +3
      MessageBox MB_OK|MB_ICONEXCLAMATION "The installer is already running."
      Abort
  /* todo: remove this message and replace it in install.js */
  MessageBox MB_YESNO "This will install Clusterio and nodejs/npm (if not already installed). Continue?" IDYES NoAbort
    Abort ; causes installer to quit.
  NoAbort:

  ; from ConnectInternet function (uses Dialer plug-in) - Written by Joost Verburg
  ;
  ; This function attempts to make a connection to the internet if there is no
  ; connection available. If you are not sure that a system using the installer
  ; has an active internet connection, call this function before downloading
  ; files with NSISdl.
  ;
  ; The function requires Internet Explorer 3, but asks to connect manually if
  ; IE3 is not installed.
  ClearErrors
  Dialer::AttemptConnect
  IfErrors noie3

  Pop $R0
  StrCmp $R0 "online" connected
    MessageBox MB_OK|MB_ICONSTOP "Cannot connect to the internet. Internet is required for installation. Please connect and retry"
    Abort ; This will quit the installer. You might want to add your own error handling.

  noie3:

   ; IE3 not installed
  MessageBox MB_OK|MB_ICONINFORMATION "Please connect to the internet now to install Clusterio."

  connected:

FunctionEnd

Section
  /*gets nodejs - make sure to update regularly*/
  inetc::get "https://nodejs.org/dist/v14.15.3/node-v14.15.3-x64.msi" "$EXEDIR\nodejs-install.msi"
  Pop $0
    StrCmp $0 "OK" dlok
    MessageBox MB_OK|MB_ICONEXCLAMATION "Nodejs download Error, click OK to abort installation" /SD IDOK
    Abort
  dlok:

  /*replace with your install.js*/
  inetc::get "https://raw.githubusercontent.com/smartguy1196/NSIS-nodejs/master/install.js" "$EXEDIR\nodejs-install.msi"
  Pop $0
    StrCmp $0 "OK" jlok
    MessageBox MB_OK|MB_ICONEXCLAMATION "Installer download error: could not download installation dependency: 'install.js'. click OK to abort installation" /SD IDOK
    Abort
  jlok:

  ExecWait "$EXEDIR\nodejs-install.msi" $0
    StrCmp $0 0 nInstallSucc 0
    MessageBox MB_OK|MB_ICONEXCLAMATION "Installer failed, because Nodejs install exited with exit code $0. Click OK to abort install" /SD IDOK
    Abort
  nInstallSucc:

  ExecWait "node $EXEDIR\install.js" $0
    StrCmp $0 0 jsInstallSucc 0
    MessageBox MB_OK|MB_ICONEXCLAMATION "Installer failed. Nodejs installed, but the installation script returned exit code $0. Click OK to abort install" /SD IDOK
    Abort
  jsInstallSucc:
SectionEnd
