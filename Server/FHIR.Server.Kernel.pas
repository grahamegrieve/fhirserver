unit FHIR.Server.Kernel;

{
Copyright (c) 2011+, HL7 and Health Intersections Pty Ltd (http://www.healthintersections.com.au)
All rights reserved.

Redistribution and use in source and binary forms, with or without modification,
are permitted provided that the following conditions are met:

 * Redistributions of source code must retain the above copyright notice, this
   list of conditions and the following disclaimer.
 * Redistributions in binary form must reproduce the above copyright notice,
   this list of conditions and the following disclaimer in the documentation
   and/or other materials provided with the distribution.
 * Neither the name of HL7 nor the names of its contributors may be used to
   endorse or promote products derived from this software without specific
   prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS 'AS IS' AND
ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.
IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT,
INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT
NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY,
WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
POSSIBILITY OF SUCH DAMAGE.
}

{$I fhir.inc}

interface

Uses
  {$IFDEF WINDOWS} Windows, ActiveX, {$ENDIF}
  SysUtils, StrUtils, Classes, IniFiles,
  IdSSLOpenSSLHeaders,

  FHIR.Support.Base, FHIR.Support.Utilities,

  {$IFNDEF FPC} FHIR.Server.Manager, {$ENDIF}
  FHIR.Server.Constants, FHIR.Server.Ini, FHIR.Server.Utilities, FHIR.Server.Javascript,
  FHIR.Server.Kernel.Base, FHIR.Server.Kernel.General, FHIR.Server.Kernel.Tx, FHIR.Server.Kernel.Bridge,
  FHIR.Server.Gui.Vcl;

procedure ExecuteFhirServer; overload;

implementation

uses
  FHIR.Support.Logging {$IFDEF WINDOWS}, JclDebug {$ENDIF};

procedure RunGui(ini : TFHIRServerIniFile);
begin
  {$IFDEF WINDOWS}
  FreeConsole;
  {$ENDIF}

  {$IFDEF FPC}
  raise Exception.create('Not implemented yet');
  {$ELSE}
  ServerGUI := TServerGUI.Create(nil);
  try
    ServerGUI.ShowModal;
  finally
    FreeAndNil(ServerGUI);
  end;
//  ServerManagerForm := TServerManagerForm.Create(nil);
//  try
//    ServerManagerForm.ShowModal;
//  finally
//    FreeAndNil(ServerManagerForm);
//  end;
  {$ENDIF}
end;

function makeKernel(const ASystemName, ADisplayName, Welcome : String; ini : TFHIRServerIniFile) : TFHIRServiceBase;
var
  mode : String;
begin
  mode := ini.kernel['mode'];
  if mode = 'bridge' then
  begin
    Logging.log('Run Bridge Mode Server');
    result := TFHIRServiceBridgeServer.Create(ASystemName, ADisplayName, Welcome, ini)
  end
  else if mode = 'tx' then
  begin
    Logging.log('Run Terminology Server');
    result := TFHIRServiceTxServer.Create(ASystemName, ADisplayName, Welcome, ini)
  end
  else if (mode = 'general') or (mode = '') then
  begin
    Logging.log('Run General purpose Server');
    result := TFHIRServiceGeneral.Create(ASystemName, ADisplayName, Welcome, ini)
  end
  else
    raise Exception.Create('Unknown kernel mode '+mode);
end;

procedure ExecuteFhirServer(ini : TFHIRServerIniFile); overload;
var
  svcName : String;
  dispName : String;
  cmd : String;
  fn : String;
  svc : TFHIRServiceBase;
  logMsg : String;
begin
  // 1. logging.
  if getCommandLineParam('log', fn) then
  begin
    filelog := true;
    logfile := fn;
  end;

  // if we're running the gui, go do that
  if (hasCommandLineParam('gui') or hasCommandLineParam('manager')) then
    RunGui(ini)
  else
  begin
    // if there's no parameters, then we don't log to the screen
    // if the cmd parameter is 'console' or 'exec' then we also log to the
    if (not filelog) then
    begin
      filelog := true;
      if (FileExists('c:\temp')) then
        logfile := 'c:\temp\fhirserver.log'
      else
        logfile := tempFile('fhirserver.log');
    end;
    if ParamCount > 0 then
      Consolelog := true;

    SetConsoleTitle('FHIR Server R4');
    Logging.log(commandLineAsString);

    if not getCommandLineParam('name', svcName) then
      if ini.service['name'] <> '' then
        svcName := ini.service['name']
      else
        svcName := 'FHIRServer';

    if not getCommandLineParam('title', dispName) then
      if ini.service['title'] <> '' then
        dispName := ini.service['title']
      else
        dispName := 'FHIR Server';

    {$IFDEF WINDOWS}
    if JclExceptionTrackingActive then
      logMsg := 'FHIR Server '+SERVER_VERSION+'. Using ini file '+ini.FileName+' (+stack dumps)'
    else
    {$ENDIF}
      logMsg := 'FHIR Server '+SERVER_VERSION+'. Using ini file '+ini.FileName;
    if filelog then
      logMsg := logMsg + '. Log File = '+logfile;

    Logging.log(logMsg);
    dispName := dispName + ' '+SERVER_VERSION;

    svc := makeKernel(svcName, dispName, logMsg, ini.link);
    try
      if hasCommandLineParam('installer') then
      begin
        svc.Installer := true;
        svc.callback := svc.InstallerCallBack;
      end;
      svc.LoadStore := not hasCommandLineParam('noload');

      if getCommandLineParam('cmd', cmd) then
      begin
        if (cmd = 'exec') or (cmd = 'console') then
          svc.ConsoleExecute
        else if not svc.command(cmd) then
          raise EFslException.Create('Unknown command '+cmd);
      end
      else
      begin
        try
          writeln('No -cmd parameter - exiting now'); // won't see this if an actual windows service
        except
          // catch 105 err
        end;
        svc.Execute;
      end;
    finally
      svc.Free;
    end;
  end;
end;

procedure ExecuteFhirServer;
var
  ini : TFHIRServerIniFile;
  iniName : String;
begin
  JclStartExceptionTracking;
  IdOpenSSLSetLibPath(ExtractFilePath(Paramstr(0)));
  try
    {$IFDEF WINDOWS}
    CoInitialize(nil);
    {$ENDIF}
    try
      {$IFNDEF NO_JS}
      GJsHost := TJsHost.Create;
      try
      {$ENDIF}
        if not getCommandLineParam('ini', iniName) then
          iniName := IncludeTrailingPathDelimiter(ExtractFilePath(ParamStr(0)))+'fhirserver.ini';

        ini := TFHIRServerIniFile.create(iniName);
        try
          ExecuteFhirServer(ini);
        finally
          ini.free;
        end;
      {$IFNDEF NO_JS}
      finally
        GJsHost.free;
      end;
      {$ENDIF}
    finally
    {$IFDEF WINDOWS}
    CoUninitialize();
    {$ENDIF}
    end;
  except
    on e : Exception do
    begin
      if hasCommandLineParam('installer') then
        writeln('##> Exception '+E.Message)
      else
        writeln(E.ClassName+ ': '+E.Message+#13#10#13#10+ExceptionStack(e));
      sleep(1000);
    end;
  end;
end;

end.

