unit FHIR.Base.Factory;

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

interface

uses
  SysUtils,
  FHIR.Support.Objects,
  FHIR.Ucum.IFace,
  FHIR.Base.Objects, FHIR.Base.Parser, FHIR.Base.Validator, FHIR.Base.Narrative, FHIR.Base.PathEngine, FHIR.XVersion.Resources,
  FHIR.Client.Base, FHIR.Client.Threaded, FHIR.Client.HTTP;

type
  TFHIRFactory = class (TFslObject)
  public
    function link : TFHIRFactory; overload;
    function version : TFHIRVersion; virtual;
    function description : String; virtual;

    function makeParser(worker : TFHIRWorkerContextV; format : TFHIRFormat; lang : String) : TFHIRParser; virtual;
    function makeComposer(worker : TFHIRWorkerContextV; format : TFHIRFormat; lang : String; style: TFHIROutputStyle) : TFHIRComposer; virtual;
    function makeValidator(worker : TFHIRWorkerContextV) : TFHIRValidatorV; virtual;
    function makeGenerator(worker : TFHIRWorkerContextV) : TFHIRNarrativeGeneratorBase; virtual;
    function makePathEngine(worker : TFHIRWorkerContextV; ucum : TUcumServiceInterface) : TFHIRPathEngineV; virtual;

    function makeClientHTTP(worker : TFHIRWorkerContextV; url : String; json : boolean) : TFhirClientV; overload;
    function makeClientHTTP(worker : TFHIRWorkerContextV; url : String; json : boolean; timeout : cardinal) : TFhirClientV; overload;
    function makeClientHTTP(worker : TFHIRWorkerContextV; url : String; mimeType : String) : TFhirClientV; overload;
    function makeClientIndy(worker : TFHIRWorkerContextV; url : String; json : boolean) : TFhirClientV; overload;
    function makeClientIndy(worker : TFHIRWorkerContextV; url : String; json : boolean; timeout : cardinal) : TFhirClientV; overload;
    function makeClientHTTP(worker : TFHIRWorkerContextV; url : String; fmt : TFHIRFormat; timeout : cardinal; proxy : String) : TFhirClientV; overload; virtual;

    function makeClientThreaded(worker : TFHIRWorkerContextV; internal : TFhirClientV; event : TThreadManagementEvent) : TFhirClientV; overload; virtual;

    function makeByName(const name : String) : TFHIRObject; virtual;
    function makeBoolean(b : boolean): TFHIRObject; virtual;
    function makeCode(s : string) : TFHIRObject; virtual;
    function makeString(s : string) : TFHIRObject; virtual;
    function makeInteger(s : string) : TFHIRObject; virtual;
    function makeDecimal(s : string) : TFHIRObject; virtual;
    function makeBase64Binary(s : string) : TFHIRObject; virtual; // must DecodeBase64
    function makeParameters : TFHIRParametersW; virtual;
    function wrapCapabilityStatement(r : TFHIRResourceV) : TFHIRCapabilityStatementW; virtual;
  end;

  TFHIRVersionFactories = class (TFslObject)
  private
    FVersionArray : array [TFHIRVersion] of TFHIRFactory;
    function getHasVersion(v: TFHIRVersion): boolean;
    function getVersion(v: TFHIRVersion): TFHIRFactory;
    procedure SetVersion(v: TFHIRVersion; const Value: TFHIRFactory);
  public
    constructor Create; override;
    destructor Destroy; override;

    property version[v : TFHIRVersion] : TFHIRFactory read getVersion write SetVersion; default;
    property hasVersion[v : TFHIRVersion] : boolean read getHasVersion;
  end;

implementation

{ TFHIRFactory }

function TFHIRFactory.description: String;
begin
  result := 'Unknown version';
end;

function TFHIRFactory.link: TFHIRFactory;
begin
  result := TFHIRFactory(inherited link);
end;

function TFHIRFactory.makeClientHTTP(worker: TFHIRWorkerContextV; url: String; json: boolean): TFhirClientV;
begin
  if json then
    result := makeClientHTTP(worker, url, ffJson, 0, '')
  else
    result := makeClientHTTP(worker, url, ffXml, 0, '')
end;

function TFHIRFactory.makeClientHTTP(worker: TFHIRWorkerContextV; url: String; json: boolean; timeout: cardinal): TFhirClientV;
begin
  result := makeClientHTTP(worker, url, json, timeout);
end;

function TFHIRFactory.makeClientHTTP(worker: TFHIRWorkerContextV; url, mimeType: String): TFhirClientV;
begin
  result := makeClientHTTP(worker, url, mimeType.contains('json'));
end;

function TFHIRFactory.makeBase64Binary(s: string): TFHIRObject;
begin
  raise Exception.Create('The function TFHIRFactory.makeBase64Binary should never be called');
end;

function TFHIRFactory.makeBoolean(b: boolean): TFHIRObject;
begin
  raise Exception.Create('The function TFHIRFactory.makeBoolean should never be called');
end;

function TFHIRFactory.makeByName(const name: String): TFHIRObject;
begin
  raise Exception.Create('The function TFHIRFactory.makeCode should never be called');
end;

function TFHIRFactory.makeClientHTTP(worker: TFHIRWorkerContextV; url: String; fmt : TFHIRFormat; timeout: cardinal; proxy: String): TFhirClientV;
begin
  raise Exception.Create('The function TFHIRFactory.makeComposer should never be called');
end;

function TFHIRFactory.makeClientIndy(worker: TFHIRWorkerContextV; url: String; json: boolean; timeout: cardinal): TFhirClientV;
begin
  result := makeClientHTTP(worker, url, json, timeout);
  TFHIRHTTPCommunicator(result.Communicator).UseIndy := true;
end;

function TFHIRFactory.makeClientIndy(worker: TFHIRWorkerContextV; url: String; json: boolean): TFhirClientV;
begin
  result := makeClientHTTP(worker, url, json, 0);
  TFHIRHTTPCommunicator(result.Communicator).UseIndy := true;
end;

function TFHIRFactory.makeClientThreaded(worker: TFHIRWorkerContextV; internal: TFhirClientV; event: TThreadManagementEvent): TFhirClientV;
begin
  raise Exception.Create('The function TFHIRFactory.makeComposer should never be called');
end;

function TFHIRFactory.makeCode(s: string): TFHIRObject;
begin
  raise Exception.Create('The function TFHIRFactory.makeCode should never be called');
end;

function TFHIRFactory.makeComposer(worker: TFHIRWorkerContextV; format: TFHIRFormat; lang: String; style: TFHIROutputStyle): TFHIRComposer;
begin
  raise Exception.Create('The function TFHIRFactory.makeComposer should never be called');
end;

function TFHIRFactory.makeDecimal(s: string): TFHIRObject;
begin
  raise Exception.Create('The function TFHIRFactory.makeDecimal should never be called');
end;

function TFHIRFactory.makeGenerator(worker: TFHIRWorkerContextV): TFHIRNarrativeGeneratorBase;
begin
  raise Exception.Create('The function TFHIRFactory.makeGenerator should never be called');
end;

function TFHIRFactory.makeInteger(s: string): TFHIRObject;
begin
  raise Exception.Create('The function TFHIRFactory.makeInteger should never be called');
end;

function TFHIRFactory.makeParameters: TFHIRParametersW;
begin
  raise Exception.Create('The function TFHIRFactory.makeParameters should never be called');
end;

function TFHIRFactory.makeParser(worker: TFHIRWorkerContextV; format: TFHIRFormat; lang: String): TFHIRParser;
begin
  raise Exception.Create('The function TFHIRFactory.makeComposer should never be called');
end;

function TFHIRFactory.makePathEngine(worker: TFHIRWorkerContextV; ucum : TUcumServiceInterface): TFHIRPathEngineV;
begin
  raise Exception.Create('The function TFHIRFactory.makePathEngine should never be called');
end;

function TFHIRFactory.makeString(s: string): TFHIRObject;
begin
  raise Exception.Create('The function TFHIRFactory.makeString should never be called');
end;

function TFHIRFactory.makeValidator(worker: TFHIRWorkerContextV): TFHIRValidatorV;
begin
  raise Exception.Create('The function TFHIRFactory.makeComposer should never be called');
end;

function TFHIRFactory.version: TFHIRVersion;
begin
  result := fhirVersionUnknown;
end;


function TFHIRFactory.wrapCapabilityStatement(r: TFHIRResourceV): TFHIRCapabilityStatementW;
begin
  raise Exception.Create('The function TFHIRFactory.wrapCapabilityStatement should never be called');
end;

{ TFHIRVersionFactories }

constructor TFHIRVersionFactories.Create;
var
  v : TFHIRVersion;
begin
  inherited;
  for v := low(TFHIRVersion) to high(TFHIRVersion) do
    FVersionArray[v] := nil;
end;

destructor TFHIRVersionFactories.Destroy;
var
  v : TFHIRVersion;
begin
  for v := low(TFHIRVersion) to high(TFHIRVersion) do
    FVersionArray[v].free;
  inherited;
end;

function TFHIRVersionFactories.getHasVersion(v: TFHIRVersion): boolean;
begin
  result := FVersionArray[v] <> nil;
end;

function TFHIRVersionFactories.getVersion(v: TFHIRVersion): TFHIRFactory;
begin
  result := FVersionArray[v];
end;

procedure TFHIRVersionFactories.SetVersion(v: TFHIRVersion; const Value: TFHIRFactory);
begin
  FVersionArray[v].free;
  FVersionArray[v] := value;
end;

end.
