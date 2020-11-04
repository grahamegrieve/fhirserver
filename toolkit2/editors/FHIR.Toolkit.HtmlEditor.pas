unit FHIR.Toolkit.HtmlEditor;

{$i fhir.inc}

interface

uses
  Classes, SysUtils, Controls,
  SynEditHighlighter, SynHighlighterHtml, HTMLView,
  FHIR.Support.Base, FHIR.Base.XHtml, FHIR.Support.Logging,
  FHIR.Toolkit.Context, FHIR.Toolkit.Store,
  FHIR.Toolkit.BaseEditor;

type

  { THtmlEditor }

  THtmlEditor = class (TBaseEditor)
  private
    FHtml : THtmlViewer;
  protected
    function makeHighlighter : TSynCustomHighlighter; override;
    procedure getNavigationList(navpoints : TStringList); override;
  public
    constructor Create(context : TToolkitContext; session : TToolkitEditSession; store : TStorageService); override;
    destructor Destroy; override;

    procedure newContent(); override;
    function FileExtension : String; override;
    procedure validate; override;

    function hasDesigner : boolean; override;
    procedure makeDesigner; override;
    procedure updateDesigner; override;
  end;


implementation

function THtmlEditor.makeHighlighter: TSynCustomHighlighter;
begin
  Result := TSynHtmlSyn.create(nil);
end;

procedure THtmlEditor.getNavigationList(navpoints: TStringList);
begin
end;

procedure THtmlEditor.makeDesigner;
begin
  inherited makeDesigner;
  FHtml := THtmlViewer.create(FDesignerPanelWork);
  FHtml.parent := FDesignerPanelWork;
  FHtml.align := alClient;
end;

constructor THtmlEditor.Create(context: TToolkitContext; session: TToolkitEditSession; store: TStorageService);
begin
  inherited Create(context, session, store);
//  FParser := TMHtmlParser.create;
end;

destructor THtmlEditor.Destroy;
begin
//  FParser.free;
  inherited Destroy;
end;

procedure THtmlEditor.newContent();
begin
  Session.HasBOM := false;
  Session.EndOfLines := PLATFORM_DEFAULT_EOLN;
  Session.Encoding := senUTF8;

  TextEditor.Text := '<html>'+#13#10+'<head></head>'+#13#10+'<body></body>'+#13#10+'</html>'+#13#10;
  updateToolbarButtons;
end;

function THtmlEditor.FileExtension: String;
begin
  result := 'html';
end;

procedure THtmlEditor.validate;
var
  i : integer;
  s : String;
  //Html : TMHtmlDocument;
  t : QWord;
begin
  t := GetTickCount64;
  updateToContent;
  StartValidating;
  try
    for i := 0 to FContent.count - 1 do
    begin
      s := TextEditor.lines[i];
      checkForEncoding(s, i);
    end;
    //try
    //  Html := FParser.parse(FContent.text, [xpResolveNamespaces]);
    //  try
    //    // todo: any semantic validation?
    //  finally
    //    Html.free;
    //  end;
    //except
    //  on e : EParserException do
    //  begin
    //    validationError(e.Line, e.Col, e.message);
    //  end;
    //  on e : Exception do
    //  begin
    //    validationError(1, 1, 'Error Parsing Html: '+e.message);
    //  end;
    //end;
  finally
    finishValidating;
  end;
  Logging.log('Validate '+describe+' in '+inttostr(GetTickCount64 - t)+'ms');
end;

function THtmlEditor.hasDesigner : boolean;
begin
  Result := true;
end;

procedure THtmlEditor.updateDesigner;
begin
  FHtml.LoadFromString(FContent.Text);
end;


end.
