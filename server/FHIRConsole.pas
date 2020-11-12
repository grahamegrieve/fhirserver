program FHIRConsole;

{$mode objfpc}{$H+}

uses
  {$IFDEF UNIX}
  cthreads,
  {$ELSE}
  FastMM4,
  {$ENDIF}
  Interfaces, // this includes the LCL widgetset
  Forms,
  datetimectrls,
  fsl_base,
  ftx_sct_combiner, fsl_http, fhir_utilities, fhir_ucum,
  fsl_npm_cache, fhir_client, fhir_cdshooks,
  fhir_oauth, ftx_service, fdb_manager,
  ftx_loinc_services,
  { you can add units after this }
  FHIR.Server.Console,
  FHIR.Server.Connection.Lcl, IdGlobal;

{$R *.res}

begin
  RequireDerivedFormResource:=True;
  Application.Scaled:=True;
  Application.Initialize;
  Application.CreateForm(TMainConsoleForm, MainConsoleForm);
  Application.CreateForm(TServerConnectionForm, ServerConnectionForm);
  Application.Run;
end.

