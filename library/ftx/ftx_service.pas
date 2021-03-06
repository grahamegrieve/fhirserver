unit ftx_service;

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

uses
  SysUtils, Classes, Generics.Collections,
  fsl_utilities, fsl_base, fsl_collections, fsl_fpc, fsl_lang,
  fsl_http,
  fhir_common, fhir_factory, fhir_features,
  fhir_cdshooks;

const
  ANY_CODE_VS = 'http://hl7.org/fhir/ValueSet/@all';
  ALL_CODE_CS = 'http://hl7.org/fhir/CodeSystem/@all';

Type

  TFhirFilterOperator = fhir_common.TFilterOperator;

  TCodeSystemProviderContext = class (TFslObject)
  public
    function Link : TCodeSystemProviderContext; overload;
  end;

  TCodeSystemIteratorContext = class (TFslObject)
  protected
    FContext: TCodeSystemProviderContext;
    FCount: integer;
    FCurrent: integer;
  public
    constructor Create(context : TCodeSystemProviderContext; count : integer);
    destructor Destroy; override;

    function Link : TCodeSystemIteratorContext; overload;

    property context : TCodeSystemProviderContext read FContext;
    property count : integer read FCount;
    property current : integer read FCurrent;

    function more : boolean; virtual;
    procedure next; // only call from within a provider
  end;

  TCodeSystemProviderFilterContext = class (TFslObject)
  public
    function Link : TCodeSystemProviderFilterContext; overload;
  end;

  TCodeSystemProviderFilterPreparationContext = class (TFslObject)
  public
    function Link : TCodeSystemProviderFilterPreparationContext; overload;
  end;

  TCodeDisplay = class (TFslObject)
  private
    FLanguage: String;
    FValue: String;
    FLang: TIETFLang;
    procedure SetLang(const Value: TIETFLang);
  public
    destructor Destroy; override;
    function link : TCodeDisplay; overload;

    property language : String read FLanguage write FLanguage;
    property lang : TIETFLang read FLang write SetLang;
    property value : String read FValue write FValue;
  end;

  TCodeDisplays = class (TFslList<TCodeDisplay>)
  private
    function getDisplay(i: integer): String;
    function findMatch(languages : TIETFLanguageDefinitions; lang: TIETFLang; out display : String) : boolean;
    function langMatches(requested, stated : String) : boolean;
  public
    procedure see(value : String; overwrite : boolean = false); overload;
    procedure see(values : TStringList; overwrite : boolean = false); overload;
    procedure see(lang, value : String; overwrite : boolean = false); overload;

    function chooseDisplay(languages : TIETFLanguageDefinitions; lang : THTTPLanguages) : String;
    function present : String;
    function has(display : String) : boolean; overload;
    function has(languages : TIETFLanguageDefinitions; lang : THTTPLanguages; display : String) : boolean; overload;
    function preferred : String;
    property display[i : integer] : String read getDisplay;
  end;

  TSearchFilterText = class (TFslObject)
  private
    FFilter: string;
    FStems : TStringList;
    FStemmer : TFslWordStemmer;

    function find(s : String) : boolean;

    procedure process;
  protected
    function sizeInBytesV : cardinal; override;
  public
    constructor Create(filter : String);  overload;
    destructor Destroy; override;

    function Link : TSearchFilterText; overload;

    function null : Boolean;
    function passes(value : String) : boolean; overload;
    function passes(cds : TCodeDisplays) : boolean; overload;
    function passes(value : String; var rating : double) : boolean; overload;
    function passes(stems : TFslStringList; var rating : double) : boolean; overload;
    property filter : string read FFilter;
    property stems : TStringList read FStems;
  end;

  TCodeSystemProvider = class abstract (TFslObject)
  private
    FUseCount : cardinal;
  protected
    FLanguages : TIETFLanguageDefinitions;
  public
    constructor Create(languages : TIETFLanguageDefinitions);
    destructor Destroy; override;

    function Link : TCodeSystemProvider; overload;

    function description : String;  virtual; abstract;
    function TotalCount : integer;  virtual; abstract;
    function getIterator(context : TCodeSystemProviderContext) : TCodeSystemIteratorContext; virtual; abstract;
    function getNextContext(context : TCodeSystemIteratorContext) : TCodeSystemProviderContext; virtual; abstract;
    function systemUri(context : TCodeSystemProviderContext) : String; virtual; abstract;
    function version(context : TCodeSystemProviderContext) : String; virtual;
    function name(context : TCodeSystemProviderContext) : String; virtual;
    function getDisplay(code : String; const lang : THTTPLanguages):String; virtual; abstract;
    function getDefinition(code : String):String; virtual; abstract;
    function locate(code : String; var message : String) : TCodeSystemProviderContext; overload; virtual; abstract;
    function locate(code : String) : TCodeSystemProviderContext; overload; virtual;
    function locateIsA(code, parent : String; disallowParent : boolean = false) : TCodeSystemProviderContext; virtual; abstract;
    function IsAbstract(context : TCodeSystemProviderContext) : boolean; virtual; abstract;
    function IsInactive(context : TCodeSystemProviderContext) : boolean; overload; virtual;
    function IsInactive(code : String) : boolean; overload; virtual;
    function Code(context : TCodeSystemProviderContext) : string; virtual; abstract;
    function Display(context : TCodeSystemProviderContext; const lang : THTTPLanguages) : string; virtual; abstract;
    function Definition(context : TCodeSystemProviderContext) : string; virtual; abstract;
    procedure Displays(context : TCodeSystemProviderContext; list : TCodeDisplays); overload; virtual; abstract;  // get all displays for all languages
    function doesFilter(prop : String; op : TFhirFilterOperator; value : String) : boolean; virtual;

    function hasSupplement(url : String) : boolean; virtual;
    function getPrepContext : TCodeSystemProviderFilterPreparationContext; virtual;
    function searchFilter(filter : TSearchFilterText; prep : TCodeSystemProviderFilterPreparationContext; sort : boolean) : TCodeSystemProviderFilterContext; virtual; abstract;
    function specialFilter(prep : TCodeSystemProviderFilterPreparationContext; sort : boolean) : TCodeSystemProviderFilterContext; virtual;
    function filter(forIteration : boolean; prop : String; op : TFhirFilterOperator; value : String; prep : TCodeSystemProviderFilterPreparationContext) : TCodeSystemProviderFilterContext; virtual; abstract;
    function prepare(prep : TCodeSystemProviderFilterPreparationContext) : boolean; virtual; // true if the underlying provider collapsed multiple filters
    function filterLocate(ctxt : TCodeSystemProviderFilterContext; code : String; var message : String) : TCodeSystemProviderContext; overload; virtual; abstract;
    function filterLocate(ctxt : TCodeSystemProviderFilterContext; code : String) : TCodeSystemProviderContext; overload; virtual;
    function FilterMore(ctxt : TCodeSystemProviderFilterContext) : boolean; virtual; abstract;
    function FilterConcept(ctxt : TCodeSystemProviderFilterContext): TCodeSystemProviderContext; virtual; abstract;
    function InFilter(ctxt : TCodeSystemProviderFilterContext; concept : TCodeSystemProviderContext) : Boolean; virtual; abstract;
    function isNotClosed(textFilter : TSearchFilterText; propFilter : TCodeSystemProviderFilterContext = nil) : boolean; virtual; abstract;
    procedure extendLookup(factory : TFHIRFactory; ctxt : TCodeSystemProviderContext; const lang : THTTPLanguages; props : TArray<String>; resp : TFHIRLookupOpResponseW); virtual;
    function subsumesTest(codeA, codeB : String) : String; virtual;

    function SpecialEnumeration : String; virtual;
    procedure defineFeatures(features : TFslList<TFHIRFeature>); virtual; abstract;
    procedure getCDSInfo(card : TCDSHookCard; const lang : THTTPLanguages; baseURL, code, display : String); virtual;

    procedure Close(ctxt : TCodeSystemProviderFilterPreparationContext); overload; virtual;
    procedure Close(ctxt : TCodeSystemProviderFilterContext); overload; virtual; abstract;
    procedure Close(ctxt : TCodeSystemProviderContext); overload; virtual; abstract;

    procedure RecordUse;
    function defToThisVersion(specifiedVersion : String) : boolean; virtual;
    property UseCount : cardinal read FUseCount;
  end;

implementation

{ TCodeSystemProvider }

procedure TCodeSystemProvider.Close(ctxt: TCodeSystemProviderFilterPreparationContext);
begin
  // do nothing
end;

constructor TCodeSystemProvider.Create(languages: TIETFLanguageDefinitions);
begin
  inherited create;
  FLanguages := languages;
end;

function TCodeSystemProvider.defToThisVersion(specifiedVersion : String): boolean;
begin
  result := true;
end;

destructor TCodeSystemProvider.Destroy;
begin
  FLanguages.Free;
  inherited;
end;

function TCodeSystemProvider.doesFilter(prop: String; op: TFhirFilterOperator; value: String): boolean;
var
  ctxt : TCodeSystemProviderFilterContext;
begin
  result := false;
  ctxt := filter(true, prop, op, value, nil);
  try
    result := ctxt <> nil;
  finally
    if result then
      Close(ctxt);
  end;
end;

procedure TCodeSystemProvider.extendLookup(factory : TFHIRFactory; ctxt: TCodeSystemProviderContext; const lang : THTTPLanguages; props : TArray<String>; resp : TFHIRLookupOpResponseW);
begin
  // nothing here
end;

function TCodeSystemProvider.filterLocate(ctxt: TCodeSystemProviderFilterContext; code: String): TCodeSystemProviderContext;
var
  msg : String;
begin
  result := filterLocate(ctxt, code, msg);
end;

procedure TCodeSystemProvider.getCDSInfo(card: TCDSHookCard; const lang : THTTPLanguages; baseURL, code, display: String);
begin
  card.summary := 'No CDSHook Implemeentation for code system '+systemUri(nil)+' for code '+code+' ('+display+')';
end;

function TCodeSystemProvider.getPrepContext: TCodeSystemProviderFilterPreparationContext;
begin
  result := nil;
end;

function TCodeSystemProvider.hasSupplement(url: String): boolean;
begin
  result := false;
end;

function TCodeSystemProvider.IsInactive(code: String): boolean;
var
  ctxt : TCodeSystemProviderContext;
begin
  ctxt := locate(code);
  try
    result := IsInactive(ctxt);
  finally
    Close(ctxt);
  end;
end;

function TCodeSystemProvider.IsInactive(context: TCodeSystemProviderContext): boolean;
begin
  result := false;
end;

function TCodeSystemProvider.Link: TCodeSystemProvider;
begin
  result := TCodeSystemProvider(inherited link);
end;

function TCodeSystemProvider.locate(code: String): TCodeSystemProviderContext;
var
  msg : String;
begin
  result := locate(code, msg);
end;

function TCodeSystemProvider.name(context: TCodeSystemProviderContext): String;
begin
  result := '';
end;

function TCodeSystemProvider.prepare(prep : TCodeSystemProviderFilterPreparationContext) : boolean;
begin
  result := false;
end;

procedure TCodeSystemProvider.RecordUse;
begin
  inc(FUseCount);
end;

function TCodeSystemProvider.SpecialEnumeration: String;
begin
  result := '';
end;

function TCodeSystemProvider.specialFilter(prep: TCodeSystemProviderFilterPreparationContext; sort: boolean): TCodeSystemProviderFilterContext;
begin
  raise ETerminologyError.create('Not implemented for '+ClassName);
end;

function TCodeSystemProvider.subsumesTest(codeA, codeB: String): String;
begin
  raise ETerminologyError.create('Subsumption Testing is not supported for system '+systemUri(nil));
end;

function TCodeSystemProvider.version(context: TCodeSystemProviderContext): String;
begin
  result := '';
end;

{ TSearchFilterText }

constructor TSearchFilterText.create(filter: String);
begin
  Create;
  FStemmer := TFslWordStemmer.create('english');
  FStems := TStringList.Create;
  FFilter := filter;
  process;
end;

destructor TSearchFilterText.destroy;
begin
  FStems.Free;
  FStemmer.Free;
  inherited;
end;

function TSearchFilterText.find(s: String): boolean;
var
  L, H, I, C: Integer;
begin
  Result := False;
  L := 0;
  H := FStems.Count - 1;
  while not result and (L <= H) do
  begin
    I := (L + H) shr 1;
    C := CompareStr(FStems[I], copy(S, 1, length(FStems[i])));
    if C = 0 then
      Result := True
    else if C < 0 then
      L := I + 1
    else
      H := I - 1;
  end;
end;

function TSearchFilterText.Link: TSearchFilterText;
begin
  result := TSearchFilterText(inherited link);
end;

function TSearchFilterText.null: Boolean;
begin
  result := FStems.Count = 0;
end;

function TSearchFilterText.passes(value: String): boolean;
var
  r : double;
begin
  result := passes(value, r);
end;

function TSearchFilterText.passes(value: String; var rating : double): boolean;
var
  i, j : integer;
begin
  result := Null;
  i := 1;
  rating := 0;
  while (not result) and (i <= length(value)) Do
  begin
    if CharInSet(value[i], ['0'..'9', 'a'..'z', 'A'..'Z']) then
    begin
      j := i;
      while (i <= length(value)) and CharInSet(value[i], ['0'..'9', 'a'..'z', 'A'..'Z']) do
        inc(i);
      result := find(lowercase(FStemmer.Stem(copy(value, j, i-j))));
      if result then
        rating := rating + length(value) / FStems.Count;
    end
    else
      inc(i);
  End;
end;

function TSearchFilterText.passes(stems: TFslStringList; var rating : double): boolean;
var
  i : integer;
  all, any, this : boolean;
begin
  rating := 0;
  if FStems.Count = 0 then
    result := true
  else
  begin
    all := true;
    any := false;
    for i := 0 to stems.count - 1 do
    begin
      this := find(stems[i]);
      all := all and this;
      any := any or this;
      if this then
        rating := rating + length(stems[i])/Fstems.count;
    end;
    result := any;
  end;
end;

function TSearchFilterText.passes(cds: TCodeDisplays): boolean;
var
  cd : TCodeDisplay;
begin
  result := false;
  for cd in cds do
    if passes(cd.value) then
      exit(true);
end;

procedure TSearchFilterText.process;
var
  i, j : Integer;
begin
  i := 1;
  while i <= length(FFilter) Do
  begin
    if CharInSet(FFilter[i], ['0'..'9', 'a'..'z', 'A'..'Z']) then
    begin
      j := i;
      while (i <= length(FFilter)) and CharInSet(FFilter[i], ['0'..'9', 'a'..'z', 'A'..'Z']) do
        inc(i);
      FStems.Add(lowercase(FStemmer.Stem(copy(FFilter, j, i-j))));
    end
    else
      inc(i);
  End;
  FStems.Sort;
end;

function TSearchFilterText.sizeInBytesV : cardinal;
begin
  result := inherited sizeInBytesV;
  inc(result, (FFilter.length * sizeof(char)) + 12);
  inc(result, FStems.sizeInBytes);
  inc(result, FStemmer.sizeInBytes);
end;

{ TCodeSystemProviderContext }

function TCodeSystemProviderContext.Link: TCodeSystemProviderContext;
begin
  result := TCodeSystemProviderContext(inherited link);
end;

{ TCodeSystemProviderFilterContext }

function TCodeSystemProviderFilterContext.Link: TCodeSystemProviderFilterContext;
begin
  result := TCodeSystemProviderFilterContext(inherited link);
end;

{ TCodeSystemProviderFilterPreparationContext }

function TCodeSystemProviderFilterPreparationContext.Link: TCodeSystemProviderFilterPreparationContext;
begin
  result := TCodeSystemProviderFilterPreparationContext(inherited Link);
end;

{ TCodeDisplays }

function TCodeDisplays.chooseDisplay(languages : TIETFLanguageDefinitions; lang: THTTPLanguages): String;
var
  l : string;
  rl : TIETFLang;
begin
  result := '';
  if (length(lang.codes) = 0) then
  begin
    rl := languages.parse('');
    try
      if findMatch(languages, rl, result) then
        exit;
    finally
      rl.Free;
    end;
  end
  else
  begin
    for l in lang.codes do
    begin
      rl := languages.parse(l);
      try
        if findMatch(languages, rl, result) then
          exit;
      finally
        rl.Free;
      end;
    end;
  end;
end;

function TCodeDisplays.findMatch(languages : TIETFLanguageDefinitions; lang: TIETFLang; out display: String): boolean;
var
  cd : TCodeDisplay;
  a : TIETFLangPartType;
begin
  result := false;
  for a := High(TIETFLangPartType) downto Low(TIETFLangPartType) do
  begin
    for cd in self do
    begin
      if cd.lang = nil then
        cd.lang := languages.parse(cd.language);
      if cd.lang.matches(lang, a) then
      begin
        display := cd.Value;
        exit(true);
      end;
    end;
  end;
end;

function TCodeDisplays.langMatches(requested, stated: String): boolean;
begin
  result := stated.StartsWith(requested);
end;

procedure TCodeDisplays.see(value: String; overwrite: boolean);
begin
  see('', value, overwrite);
end;

procedure TCodeDisplays.see(values: TStringList; overwrite: boolean);
var
  s : String;
begin
  for s in values do
    see('', s, overwrite);
end;

procedure TCodeDisplays.see(lang, value: String; overwrite: boolean);
var
  cd : TCodeDisplay;
  i : integer;
begin
  if overwrite then
    for i := count - 1 downto 0 do
      if Items[i].language = lang then
        delete(i);

  cd := TCodeDisplay.create;
  try
    cd.language := lang;
    cd.value := value;
    add(cd.Link);
  finally
    cd.Free;
  end;
end;

function TCodeDisplays.getDisplay(i: integer): String;
begin
  result := Items[i].value;
end;

function TCodeDisplays.has(languages: TIETFLanguageDefinitions; lang: THTTPLanguages; display: String): boolean;
var
  l : string;
  rl : TIETFLang;
  cd : TCodeDisplay;
begin
  result := false;
  if (length(lang.codes) = 0) then
  begin
    for cd in self do
      if (SameText(cd.value, display)) then
        exit(true);
  end
  else
  begin
    for l in lang.codes do
    begin
      rl := languages.parse(l);
      try
        for cd in self do
          if (langMatches(l, cd.FLanguage) or (cd.FLanguage = '')) and SameText(cd.value, display) then
            exit(true);
      finally
        rl.Free;
      end;
    end;
  end;
end;

function TCodeDisplays.has(display: String): boolean;
var
  cd : TCodeDisplay;
begin
  result := false;
  for cd in self do
    if (cd.value = display) then
      exit(true);
end;

function TCodeDisplays.preferred: String;
begin
  if Count = 0 then
    result := ''
  else
    result := display[0];
end;

function TCodeDisplays.present: String;
var
  cd : TCodeDisplay;
begin
  result := '';
  for cd in self do
    CommaAdd(result, cd.value);
end;

{ TCodeDisplay }

destructor TCodeDisplay.Destroy;
begin
  FLang.Free;
  inherited;
end;

function TCodeDisplay.link: TCodeDisplay;
begin
  result := TCodeDisplay(inherited link);
end;

procedure TCodeDisplay.SetLang(const Value: TIETFLang);
begin
  FLang.Free;
  FLang := Value;
end;

{ TCodeSystemIndexBasedIterator }

constructor TCodeSystemIteratorContext.Create(context: TCodeSystemProviderContext; count: integer);
begin
  inherited Create;
  FContext := context;
  FCount := count;
end;

destructor TCodeSystemIteratorContext.Destroy;
begin
  FContext.free;
  inherited;
end;

function TCodeSystemIteratorContext.Link: TCodeSystemIteratorContext;
begin
  result := TCodeSystemIteratorContext(inherited Link);
end;

function TCodeSystemIteratorContext.more: boolean;
begin
  result := FCurrent < FCount;
end;

procedure TCodeSystemIteratorContext.next;
begin
  inc(FCurrent);
end;

end.
