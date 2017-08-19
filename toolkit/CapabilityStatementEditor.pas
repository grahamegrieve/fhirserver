unit CapabilityStatementEditor;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Graphics, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.StdCtrls,
  FMX.TabControl, FMX.Layouts, FMX.TreeView, FMX.Controls.Presentation,
  FMX.ScrollBox, FMX.Memo, FMX.DateTimeCtrls, FMX.ListBox, FMX.Edit,
  BaseResourceFrame,
  DateSupport, StringSupport,
  AdvGenerics,
  FHIRBase, FHIRConstants, FHIRTypes, FHIRResources, FHIRUtilities, FHIRIndexBase, FHIRIndexInformation, FHIRSupport,
  SearchParameterEditor, ListSelector, AddRestResourceDialog;

type
  TFrame = TBaseResourceFrame; // re-aliasing the Frame to work around a designer bug

  TCapabilityStatementEditorFrame = class(TFrame)
    Panel2: TPanel;
    Splitter1: TSplitter;
    Panel3: TPanel;
    Panel4: TPanel;
    tvStructure: TTreeView;
    tbStructure: TTabControl;
    tbMetadata: TTabItem;
    tbRest: TTabItem;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    cbExperimental: TCheckBox;
    Label7: TLabel;
    Label8: TLabel;
    Label9: TLabel;
    Label10: TLabel;
    Label11: TLabel;
    Label12: TLabel;
    Label13: TLabel;
    Label14: TLabel;
    cbXml: TCheckBox;
    cbJson: TCheckBox;
    cbTurtle: TCheckBox;
    cbTerminologyService: TCheckBox;
    Label15: TLabel;
    edtURL: TEdit;
    edtName: TEdit;
    edtTitle: TEdit;
    cbxStatus: TComboBox;
    dedDate: TDateEdit;
    edtPublisher: TEdit;
    edtDescription: TEdit;
    edtPurpose: TEdit;
    edtCopyright: TEdit;
    cbxKind: TComboBox;
    cbxJurisdiction: TComboBox;
    edtFHIRVersion: TEdit;
    mImplementationGuides: TMemo;
    edtVersion: TEdit;
    tvMetadata: TTreeViewItem;
    Label16: TLabel;
    mSecurity: TMemo;
    cbCORS: TCheckBox;
    cbClientCerts: TCheckBox;
    cbOAuth: TCheckBox;
    cbSmart: TCheckBox;
    Label17: TLabel;
    mDoco: TMemo;
    tbResource: TTabItem;
    Label18: TLabel;
    mDocoRes: TMemo;
    Label19: TLabel;
    Label20: TLabel;
    cbRead: TCheckBox;
    edtDocoRead: TEdit;
    cbVRead: TCheckBox;
    edtDocoVRead: TEdit;
    edtDocoSearch: TEdit;
    cbUpdate: TCheckBox;
    edtDocoCreate: TEdit;
    cbPatch: TCheckBox;
    cbDelete: TCheckBox;
    edtDocoUpdate: TEdit;
    cbHistoryInstance: TCheckBox;
    edtDocoPatch: TEdit;
    cbHistoryType: TCheckBox;
    edtDocoDelete: TEdit;
    cbCreate: TCheckBox;
    edtDocoHistoryInstance: TEdit;
    edtDocoHistoryType: TEdit;
    cbSearch: TCheckBox;
    cbUpdateCreate: TCheckBox;
    Label21: TLabel;
    cbCondCreate: TCheckBox;
    cbCondUpdate: TCheckBox;
    cbCondDelete: TCheckBox;
    Label22: TLabel;
    cbxReadCondition: TComboBox;
    Label23: TLabel;
    cbRefLiteral: TCheckBox;
    cbRefLogical: TCheckBox;
    cbRefResolve: TCheckBox;
    cbRefEnforced: TCheckBox;
    cbRefLocal: TCheckBox;
    edtProfile: TEdit;
    Label24: TLabel;
    cbxVersioning: TComboBox;
    Label25: TLabel;
    lbSearch: TListBox;
    btnParamAdd: TButton;
    btnParamAddStd: TButton;
    btnParamEdit: TButton;
    btnParamDelete: TButton;
    Label26: TLabel;
    cbTransaction: TCheckBox;
    edtTransaction: TEdit;
    cbBatch: TCheckBox;
    edtBatch: TEdit;
    cbSystemSearch: TCheckBox;
    edtSystemSearch: TEdit;
    cbSystemHistory: TCheckBox;
    edtSystemHistory: TEdit;
    btnAddClient: TButton;
    btnAddServer: TButton;
    Panel1: TPanel;
    btnAddResources: TButton;
    VertScrollBox1: TVertScrollBox;
    btnDeleteResources: TButton;
    procedure tvStructureClick(Sender: TObject);
    procedure btnCancelClick(Sender: TObject);
    procedure inputChanged(Sender: TObject);
    procedure btnParamEditClick(Sender: TObject);
    procedure lbSearchClick(Sender: TObject);
    procedure btnParamDeleteClick(Sender: TObject);
    procedure btnParamAddClick(Sender: TObject);
    procedure btnParamAddStdClick(Sender: TObject);
    procedure btnAddClientClick(Sender: TObject);
    procedure btnAddServerClick(Sender: TObject);
    procedure btnAddResourcesClick(Sender: TObject);
    procedure btnDeleteResourcesClick(Sender: TObject);
  private
    function GetCapabilityStatement: TFHIRCapabilityStatement;
    function readJurisdiction : Integer;
    function getJurisdiction(i : integer) : TFHIRCodeableConcept;

    procedure loadMetadata;
    procedure loadRest(rest : TFhirCapabilityStatementRest);
    procedure loadResource(res : TFhirCapabilityStatementRestResource);

    procedure commitMetadata;
    procedure commitRest(rest : TFhirCapabilityStatementRest);
    procedure commitResource(res : TFhirCapabilityStatementRestResource);

    procedure commit; override;
    procedure cancel; override;
  public
    { Public declarations }
    property CapabilityStatement : TFHIRCapabilityStatement read GetCapabilityStatement;
    procedure load; override;

  end;

implementation

{$R *.fmx}

{ TCapabilityStatementEditorFrame }

procedure TCapabilityStatementEditorFrame.btnAddClientClick(Sender: TObject);
var
  rest : TFhirCapabilityStatementRest;
  tiRest : TTreeViewItem;
begin
  rest := CapabilityStatement.restList.Append;
  rest.mode := RestfulCapabilityModeClient;
  tiRest := TTreeViewItem.Create(tvMetadata);
  tiRest.text := 'Client';
  tvMetadata.AddObject(tiRest);
  tiRest.TagObject := rest;
  rest.TagObject := tiRest;
  btnAddClient.Enabled := false;
  tvStructure.Selected := tiRest;
  tvStructureClick(nil);
  ResourceIsDirty := true;
end;

procedure TCapabilityStatementEditorFrame.btnAddResourcesClick(Sender: TObject);
var
  form : TAddRestResourceForm;
  res : TFhirCapabilityStatementRestResource;
  rs : TFhirResourceTypeSet;
  r : TFhirResourceType;
  rest : TFhirCapabilityStatementRest;
  i : integer;
  indexes : TFhirIndexList;
  compartments : TFHIRCompartmentList;
  builder : TFHIRIndexBuilder;
  list : TAdvList<TFhirIndex>;
  index : TFhirIndex;
  p : TFhirCapabilityStatementRestResourceSearchParam;
  tiRes : TTreeViewItem;
begin
  rest := tvStructure.Selected.TagObject as TFhirCapabilityStatementRest;
  rs := ALL_RESOURCE_TYPES;
  for res in rest.resourceList do
  begin
    r := ResourceTypeByName(CODES_TFhirResourceTypesEnum[res.type_]);
    rs := rs - [r];
  end;

  form := TAddRestResourceForm.create(self);
  try
    for r in rs do
      if r <> frtCustom then
        form.ListBox1.Items.addObject(CODES_TFhirResourceType[r], TObject(r));
    if form.showmodal = mrOk then
    begin
      for i := 0 to form.ListBox1.Items.Count - 1 do
        if form.ListBox1.ListItems[i].isChecked then
        begin
          r := TFhirResourceType(form.ListBox1.Items.Objects[i]);
          res := rest.resourceList.Append;
          res.type_ := TFhirResourceTypesEnum(StringArrayIndexOfSensitive(CODES_TFhirResourceTypesEnum, CODES_TFhirResourceType[r]));
          if form.cbRead.IsChecked then res.interactionList.Append.code := TypeRestfulInteractionRead;
          if form.cbVRead.IsChecked then res.interactionList.Append.code := TypeRestfulInteractionVRead;
          if form.cbSearch.IsChecked then res.interactionList.Append.code := TypeRestfulInteractionSearchType;
          if form.cbCreate.IsChecked then res.interactionList.Append.code := TypeRestfulInteractionCreate;
          if form.cbUpdate.IsChecked then res.interactionList.Append.code := TypeRestfulInteractionUpdate;
          if form.cbDelete.IsChecked then res.interactionList.Append.code := TypeRestfulInteractionDelete;
          if form.cbHistoryInstance.IsChecked then res.interactionList.Append.code := TypeRestfulInteractionHistoryInstance;
          if form.cbHistoryType.IsChecked then res.interactionList.Append.code := TypeRestfulInteractionHistoryType;
          if form.cbPatch.IsChecked then res.interactionList.Append.code := TypeRestfulInteractionPatch;
          if form.cbUpdateCreate.IsChecked then res.updateCreate := true;
          if form.cbCondCreate.IsChecked then res.conditionalCreate := true;
          if form.cbCondUpdate.IsChecked then res.conditionalUpdate := true;
          if form.cbCondDelete.IsChecked then res.conditionalDelete := ConditionalDeleteStatusSingle;
          if form.cbxVersioning.ItemIndex > -1 then
            res.versioning := TFhirVersioningPolicyEnum(form.cbxVersioning.ItemIndex);
          if form.cbxReadCondition.ItemIndex > -1 then
            res.conditionalRead := TFhirConditionalReadStatusEnum(form.cbxReadCondition.ItemIndex);
          if form.cbRefLocal.IsChecked then res.referencePolicy := res.referencePolicy + [ReferenceHandlingPolicyLocal];
          if form.cbRefEnforced.IsChecked then res.referencePolicy := res.referencePolicy + [ReferenceHandlingPolicyEnforced];
          if form.cbRefLogical.IsChecked then res.referencePolicy := res.referencePolicy + [ReferenceHandlingPolicyLogical];
          if form.cbRefResolve.IsChecked then res.referencePolicy := res.referencePolicy + [ReferenceHandlingPolicyResolves];
          if form.cbRefLiteral.IsChecked then res.referencePolicy := res.referencePolicy + [ReferenceHandlingPolicyLiteral];
          if form.cbStandardSearch.isChecked then
          begin
            compartments := TFHIRCompartmentList.create;
            indexes := TFhirIndexList.Create;
            try
              builder := TFHIRIndexBuilder.Create;
              try
                builder.registerIndexes(indexes, compartments);
              finally
                builder.Free;
              end;
              list := indexes.listByType(CODES_TFhirResourceTypesEnum[res.type_]);
              try
                for index in list do
                begin
                  p := TFhirCapabilityStatementRestResourceSearchParam.Create;
                  try
                    p.name := index.Name;
                    p.type_ := index.SearchType;
                    p.definition := index.URI;
                    p.documentation := index.Description;
                    res.searchParamList.Add(p.Link);
                  finally
                    p.Free;
                  end;
                end;
              finally
                list.free;
              end;
            finally
              indexes.Free;
              compartments.Free;
            end;

          tiRes := TTreeViewItem.Create(tvStructure.Selected);
          tiRes.text := CODES_TFhirResourceTypesEnum[res.type_];
          tvStructure.Selected.AddObject(tiRes);
          tiRes.TagObject := res;
          res.TagObject := tiRes;
          end;
        end;
      ResourceIsDirty := true;
    end;
  finally
    form.free;
  end;
end;

procedure TCapabilityStatementEditorFrame.btnAddServerClick(Sender: TObject);
var
  rest : TFhirCapabilityStatementRest;
  tiRest : TTreeViewItem;
begin
  rest := CapabilityStatement.restList.Append;
  rest.mode := RestfulCapabilityModeServer;
  tiRest := TTreeViewItem.Create(tvMetadata);
  tiRest.text := 'Server';
  tvMetadata.AddObject(tiRest);
  tiRest.TagObject := rest;
  rest.TagObject := tiRest;
  btnAddServer.Enabled := false;
  tvStructure.Selected := tiRest;
  tvStructureClick(nil);
  ResourceIsDirty := true;
end;

procedure TCapabilityStatementEditorFrame.btnCancelClick(Sender: TObject);
begin
  cancel;
end;

procedure TCapabilityStatementEditorFrame.btnDeleteResourcesClick(Sender: TObject);
var
  form : TListSelectorForm;
  r : TFhirCapabilityStatementRestResource;
  rest : TFhirCapabilityStatementRest;
  i : integer;
begin
  rest := tvStructure.Selected.TagObject as TFhirCapabilityStatementRest;
  form := TListSelectorForm.create(self);
  try
    form.Caption := 'Choose Resources to Delete';
    for r in rest.resourceList do
      form.ListBox1.items.AddObject(CODES_TFHIRResourceTypesEnum[r.type_], r);

    if form.ListBox1.Items.Count = 0 then
      ShowMessage('No resources to delete')
    else if form.ShowModal = mrOk then
    begin
      for i := 0 to form.ListBox1.Items.Count - 1 do
        if form.ListBox1.ListItems[i].IsChecked then
        begin
          r :=  form.ListBox1.Items.Objects[i] as TFhirCapabilityStatementRestResource;
          tvStructure.Selected.RemoveObject(r.TagObject as TFmxObject);
          rest.resourceList.DeleteByReference(r);
        end;
    end;
  finally
    form.free;
  end;
end;

procedure TCapabilityStatementEditorFrame.btnParamAddClick(Sender: TObject);
var
  p : TFhirCapabilityStatementRestResourceSearchParam;
  form : TSearchParameterEditorForm;
  res : TFhirCapabilityStatementRestResource;
begin
  res := tvStructure.Selected.TagObject as TFhirCapabilityStatementRestResource;
  p := TFhirCapabilityStatementRestResourceSearchParam.Create;
  try
    form := TSearchParameterEditorForm.create(self);
    try
      form.param := p.link;
      if form.showModal = mrOk then
      begin
        res.searchParamList.Add(p.link);
        lbSearch.Items.AddObject(p.summary, p);
        lbSearch.ItemIndex := lbSearch.Items.Count - 1;
        ResourceIsDirty := true;
      end;
    finally
      form.free;
    end;
    lbSearchClick(nil);
  finally
    p.Free;
  end;
end;

procedure TCapabilityStatementEditorFrame.btnParamAddStdClick(Sender: TObject);
var
  res : TFhirCapabilityStatementRestResource;
  form : TListSelectorForm;
  indexes : TFhirIndexList;
  compartments : TFHIRCompartmentList;
  builder : TFHIRIndexBuilder;
  list : TAdvList<TFhirIndex>;
  index : TFhirIndex;
  found : boolean;
  p : TFhirCapabilityStatementRestResourceSearchParam;
  i : integer;
begin
  res := tvStructure.Selected.TagObject as TFhirCapabilityStatementRestResource;
  form := TListSelectorForm.create(self);
  try
    form.Caption := 'Choose Standard Parameters';
    compartments := TFHIRCompartmentList.create;
    indexes := TFhirIndexList.Create;
    try
      builder := TFHIRIndexBuilder.Create;
      try
        builder.registerIndexes(indexes, compartments);
      finally
        builder.Free;
      end;
      list := indexes.listByType(CODES_TFhirResourceTypesEnum[res.type_]);
      try
        for index in list do
        begin
          found := false;
          for p in res.searchParamList do
            if p.name = index.Name then
              found := true;
          if not found then
            form.ListBox1.items.AddObject(index.summary, index);
        end;
        if form.ListBox1.Items.Count = 0 then
          ShowMessage('No Standard Search Parameters Left to add')
        else if form.ShowModal = mrOk then
        begin
          for i := 0 to form.ListBox1.Items.Count - 1 do
            if form.ListBox1.ListItems[i].IsChecked then
            begin
              index := form.ListBox1.Items.Objects[i] as TFhirIndex;
              p := TFhirCapabilityStatementRestResourceSearchParam.Create;
              try
                p.name := index.Name;
                p.type_ := index.SearchType;
                p.definition := index.URI;
                p.documentation := index.Description;
                res.searchParamList.Add(p.Link);
                lbSearch.Items.AddObject(p.summary, p);
              finally
                p.Free;
              end;
            end;
          lbSearch.ItemIndex := lbSearch.Items.Count - 1;
          lbSearchClick(nil);
        end;
      finally
        list.free;
      end;
    finally
      indexes.Free;
      compartments.Free;
    end;
  finally
    form.free;
  end;
end;

procedure TCapabilityStatementEditorFrame.btnParamDeleteClick(Sender: TObject);
var
  p : TFhirCapabilityStatementRestResourceSearchParam;
  res : TFhirCapabilityStatementRestResource;
begin
  p := lbSearch.Items.Objects[lbSearch.ItemIndex] as TFhirCapabilityStatementRestResourceSearchParam;
  res := tvStructure.Selected.TagObject as TFhirCapabilityStatementRestResource;
  res.searchParamList.DeleteByReference(p);
  lbSearch.Items.Delete(lbSearch.ItemIndex);
  lbSearchClick(nil);
end;

procedure TCapabilityStatementEditorFrame.btnParamEditClick(Sender: TObject);
var
  p : TFhirCapabilityStatementRestResourceSearchParam;
  form : TSearchParameterEditorForm;
begin
  p := lbSearch.Items.Objects[lbSearch.ItemIndex] as TFhirCapabilityStatementRestResourceSearchParam;
  form := TSearchParameterEditorForm.create(self);
  try
    form.param := p.link;
    if form.showModal = mrOk then
    begin
      lbSearch.Items[lbSearch.ItemIndex] := p.summary;
      ResourceIsDirty := true;
    end;
  finally
    form.free;
  end;
  lbSearchClick(nil);
end;

procedure TCapabilityStatementEditorFrame.cancel;
begin
end;

procedure TCapabilityStatementEditorFrame.commit;
var
  obj : TObject;
begin
  obj := tvStructure.Selected.TagObject;
  if obj is TFhirCapabilityStatement then
    CommitMetadata
  else if obj is TFhirCapabilityStatementRest then
    commitRest(obj as TFhirCapabilityStatementRest)
  else if obj is TFhirCapabilityStatementRestResource then
    commitResource(obj as TFhirCapabilityStatementRestResource);
  ResourceIsDirty := true;
end;

procedure TCapabilityStatementEditorFrame.commitMetadata;
var
  s : String;
  cc : TFHIRCodeableConcept;
begin
  CapabilityStatement.experimental := cbExperimental.IsChecked;
  CapabilityStatement.Format[ffXml] := cbXml.IsChecked;
  CapabilityStatement.Format[ffJson] := cbJson.IsChecked;
  CapabilityStatement.Format[ffTurtle] := cbTurtle.IsChecked;
  CapabilityStatement.instantiates['http://hl7.org/fhir/CapabilityStatement/terminology-server'] := cbTerminologyService.IsChecked;

  CapabilityStatement.url := edtURL.Text;
  CapabilityStatement.name := edtName.Text;
  CapabilityStatement.title := edtTitle.Text;
  CapabilityStatement.fhirVersion := edtFHIRVersion.Text;
  CapabilityStatement.version := edtVersion.Text;
  CapabilityStatement.publisher := edtPublisher.text;
  CapabilityStatement.description := edtDescription.Text;
  CapabilityStatement.purpose := edtPurpose.Text;
  CapabilityStatement.copyright := edtCopyright.Text;
  CapabilityStatement.status := TFhirPublicationStatusEnum(cbxStatus.ItemIndex);
  CapabilityStatement.date := TDateTimeEx.make(dedDate.DateTime, dttzLocal);
  CapabilityStatement.kind := TFhirCapabilityStatementKindEnum(cbxKind.ItemIndex);
  CapabilityStatement.jurisdictionList.Clear;
  cc := getJurisdiction(cbxJurisdiction.ItemIndex);
  if (cc <> nil) then
    CapabilityStatement.jurisdictionList.add(cc);

  CapabilityStatement.implementationGuideList.Clear;
  for s in mImplementationGuides.Lines do
    CapabilityStatement.implementationGuideList.Append.value := s;
end;

procedure TCapabilityStatementEditorFrame.commitResource(res: TFhirCapabilityStatementRestResource);
  procedure interaction(code : TFhirTypeRestfulInteractionEnum; cb : TCheckBox; edt : TEdit);
  var
    ri : TFhirCapabilityStatementRestResourceInteraction;
  begin
    ri := res.interaction(code);
    if cb.IsChecked then
    begin
      if (ri = nil) then
      begin
        ri := res.interactionList.Append;
        ri.code := code;
      end;
      ri.documentation := edt.Text;
    end
    else if (ri <> nil) then
      res.interactionList.DeleteByReference(ri);
  end;
begin
  res.documentation := mDocoRes.Text;
  if edtProfile.Text = '' then
    res.profile := nil
  else
  begin
    if res.profile = nil then
      res.profile := TFhirReference.Create();
    res.profile.reference := edtProfile.Text;
  end;

  interaction(TypeRestfulInteractionread, cbRead, edtDocoRead);
  interaction(TypeRestfulInteractionVread, cbVRead, edtDocoVRead);
  interaction(TypeRestfulInteractionUpdate, cbUpdate, edtDocoUpdate);
  interaction(TypeRestfulInteractionPatch, cbPatch, edtDocoPatch);
  interaction(TypeRestfulInteractionDelete, cbDelete, edtDocoDelete);
  interaction(TypeRestfulInteractionHistoryInstance, cbHistoryInstance, edtDocoHistoryInstance);
  interaction(TypeRestfulInteractionHistoryType, cbHistoryType, edtDocoHistoryType);
  interaction(TypeRestfulInteractioncreate, cbCreate, edtDocoCreate);
  interaction(TypeRestfulInteractionSearchType, cbSearch, edtDocoSearch);

  res.versioning := TFhirVersioningPolicyEnum(cbxVersioning.ItemIndex);
  res.updateCreate := cbUpdateCreate.IsChecked;
  res.conditionalCreate := cbCondCreate.IsChecked;
  res.conditionalUpdate := cbCondUpdate.IsChecked;
  if cbCondDelete.IsChecked then
    res.conditionalDelete := ConditionalDeleteStatusSingle
  else
    res.conditionalDelete := ConditionalDeleteStatusNotSupported;
  res.conditionalRead := TFhirConditionalReadStatusEnum(cbxReadCondition.ItemIndex);

  if cbRefLiteral.IsChecked then
    res.referencePolicy := res.referencePolicy + [ReferenceHandlingPolicyLiteral]
  else
    res.referencePolicy := res.referencePolicy - [ReferenceHandlingPolicyLiteral];
  if cbRefLogical.IsChecked then
    res.referencePolicy := res.referencePolicy + [ReferenceHandlingPolicyLogical]
  else
    res.referencePolicy := res.referencePolicy - [ReferenceHandlingPolicyLogical];
  if cbRefResolve.IsChecked then
    res.referencePolicy := res.referencePolicy + [ReferenceHandlingPolicyResolves]
  else
    res.referencePolicy := res.referencePolicy - [ReferenceHandlingPolicyResolves];
  if cbRefEnforced.IsChecked then
    res.referencePolicy := res.referencePolicy + [ReferenceHandlingPolicyEnforced]
  else
    res.referencePolicy := res.referencePolicy - [ReferenceHandlingPolicyEnforced];
  if cbRefLocal.IsChecked then
    res.referencePolicy := res.referencePolicy + [ReferenceHandlingPolicyLocal]
  else
    res.referencePolicy := res.referencePolicy - [ReferenceHandlingPolicyLocal];
end;

procedure TCapabilityStatementEditorFrame.commitRest(rest: TFhirCapabilityStatementRest);
  procedure interaction(code : TFhirSystemRestfulInteractionEnum; cb : TCheckBox; edt : TEdit);
  var
    ri : TFhirCapabilityStatementRestInteraction;
  begin
    ri := rest.interaction(code);
    if cb.IsChecked then
    begin
      if (ri = nil) then
      begin
        ri := rest.interactionList.Append;
        ri.code := code;
      end;
      ri.documentation := edt.Text;
    end
    else if (ri <> nil) then
      rest.interactionList.DeleteByReference(ri);
  end;
begin
  rest.documentation := mDoco.Text;
  if (mSecurity.Text = '') and not (cbCORS.IsChecked or cbOAuth.IsChecked or cbClientCerts.IsChecked or cbSmart.IsChecked) then
    rest.security := nil
  else
  begin
    if rest.security = nil then
      rest.security := TFhirCapabilityStatementRestSecurity.Create;
    rest.security.description := mSecurity.Text;
    rest.security.cors := cbCORS.IsChecked;
    rest.security.serviceList.hasCode['http://hl7.org/fhir/restful-security-service', 'OAuth'] := cbOAuth.IsChecked;
    rest.security.serviceList.hasCode['http://hl7.org/fhir/restful-security-service', 'Certificates'] := cbClientCerts.IsChecked;
    rest.security.serviceList.hasCode['http://hl7.org/fhir/restful-security-service', 'SMART-on-FHIR'] := cbSmart.IsChecked;
  end;
  interaction(SystemRestfulInteractionTransaction, cbTransaction, edtTransaction);
  interaction(SystemRestfulInteractionBatch, cbBatch, edtBatch);
  interaction(SystemRestfulInteractionSearchSystem, cbSystemSearch, edtSystemSearch);
  interaction(SystemRestfulInteractionHistorySystem, cbSystemHistory, edtSystemHistory);
end;

function TCapabilityStatementEditorFrame.GetCapabilityStatement: TFHIRCapabilityStatement;
begin
  result := TFHIRCapabilityStatement(Resource);
end;

function TCapabilityStatementEditorFrame.getJurisdiction(i: integer): TFHIRCodeableConcept;
begin
  case i of
    1:result := TFhirCodeableConcept.Create('urn:iso:std:iso:3166', 'AT');
    2:result := TFhirCodeableConcept.Create('urn:iso:std:iso:3166', 'AU');
    3:result := TFhirCodeableConcept.Create('urn:iso:std:iso:3166', 'BR');
    4:result := TFhirCodeableConcept.Create('urn:iso:std:iso:3166', 'CA');
    5:result := TFhirCodeableConcept.Create('urn:iso:std:iso:3166', 'CH');
    6:result := TFhirCodeableConcept.Create('urn:iso:std:iso:3166', 'CL');
    7:result := TFhirCodeableConcept.Create('urn:iso:std:iso:3166', 'CN');
    8:result := TFhirCodeableConcept.Create('urn:iso:std:iso:3166', 'DE');
    9:result := TFhirCodeableConcept.Create('urn:iso:std:iso:3166', 'DK');
    10:result := TFhirCodeableConcept.Create('urn:iso:std:iso:3166', 'EE');
    11:result := TFhirCodeableConcept.Create('urn:iso:std:iso:3166', 'ES');
    12:result := TFhirCodeableConcept.Create('urn:iso:std:iso:3166', 'FI');
    13:result := TFhirCodeableConcept.Create('urn:iso:std:iso:3166', 'FR');
    14:result := TFhirCodeableConcept.Create('urn:iso:std:iso:3166', 'GB');
    15:result := TFhirCodeableConcept.Create('urn:iso:std:iso:3166', 'NL');
    16:result := TFhirCodeableConcept.Create('urn:iso:std:iso:3166', 'NO');
    17:result := TFhirCodeableConcept.Create('urn:iso:std:iso:3166', 'NZ');
    18:result := TFhirCodeableConcept.Create('urn:iso:std:iso:3166', 'RU');
    19:result := TFhirCodeableConcept.Create('urn:iso:std:iso:3166', 'US');
    21:result := TFhirCodeableConcept.Create('urn:iso:std:iso:3166', 'VN');
    22:result := TFhirCodeableConcept.Create('http://unstats.un.org/unsd/methods/m49/m49.htm', '001');
    23:result := TFhirCodeableConcept.Create('http://unstats.un.org/unsd/methods/m49/m49.htm', '002');
    24:result := TFhirCodeableConcept.Create('http://unstats.un.org/unsd/methods/m49/m49.htm', '019');
    25:result := TFhirCodeableConcept.Create('http://unstats.un.org/unsd/methods/m49/m49.htm', '142');
    26:result := TFhirCodeableConcept.Create('http://unstats.un.org/unsd/methods/m49/m49.htm', '150');
    27:result := TFhirCodeableConcept.Create('http://unstats.un.org/unsd/methods/m49/m49.htm', '053');
    else
      result := nil;
  end;
end;

procedure TCapabilityStatementEditorFrame.inputChanged(Sender: TObject);
begin
  if not Loading then
    commit;
end;

procedure TCapabilityStatementEditorFrame.lbSearchClick(Sender: TObject);
begin
  btnParamEdit.enabled := lbSearch.ItemIndex > -1;
  btnParamDelete.enabled := lbSearch.ItemIndex > -1;
end;

procedure TCapabilityStatementEditorFrame.load;
var
  rest : TFhirCapabilityStatementRest;
  tiRest, tiRes : TTreeViewItem;
  res : TFhirCapabilityStatementRestResource;
  bClient, bServer : boolean;
begin
  inherited;
  tvMetadata.TagObject := CapabilityStatement;
  bClient := false;
  bServer := false;

  for rest in CapabilityStatement.restList do
  begin
    tiRest := TTreeViewItem.Create(tvMetadata);
    if rest.mode = RestfulCapabilityModeClient then
    begin
      tiRest.text := 'Client';
      bClient := true;
    end
    else
    begin
      tiRest.text := 'Server';
      bServer := true;
    end;
    tvMetadata.AddObject(tiRest);
    tiRest.TagObject := rest;
    rest.TagObject := tiRest;
    for res in rest.resourceList do
    begin
      tiRes := TTreeViewItem.Create(tiRest);
      tiRes.text := CODES_TFhirResourceTypesEnum[res.type_];
      tiRest.AddObject(tiRes);
      tiRes.TagObject := res;
      res.TagObject := tiRes;
    end;

  end;
  btnAddClient.Enabled := not bClient;
  btnAddServer.Enabled := not bServer;

  tvStructure.Selected := tvMetadata;
  tvStructure.ExpandAll;
  tvStructureClick(nil);
end;

procedure TCapabilityStatementEditorFrame.loadMetadata;
var
  url : TFHIRUri;
begin
  cbExperimental.IsChecked := CapabilityStatement.experimental;
  cbXml.IsChecked := CapabilityStatement.Format[ffXml];
  cbJson.IsChecked := CapabilityStatement.Format[ffJson];
  cbTurtle.IsChecked := CapabilityStatement.Format[ffTurtle];
  cbTerminologyService.IsChecked := CapabilityStatement.instantiates['http://hl7.org/fhir/CapabilityStatement/terminology-server'];

  edtURL.Text := CapabilityStatement.url;
  edtName.Text := CapabilityStatement.name;
  edtTitle.Text := CapabilityStatement.title;
  edtFHIRVersion.Text := CapabilityStatement.fhirVersion;
  edtVersion.Text := CapabilityStatement.version;
  edtPublisher.text := CapabilityStatement.publisher;
  edtDescription.Text := CapabilityStatement.description;
  edtPurpose.Text := CapabilityStatement.purpose;
  edtCopyright.Text := CapabilityStatement.copyright;
  cbxStatus.ItemIndex := ord(CapabilityStatement.status);
  dedDate.DateTime := CapabilityStatement.date.DateTime;
  cbxKind.ItemIndex := ord(CapabilityStatement.kind);
  cbxJurisdiction.ItemIndex := readJurisdiction;

  mImplementationGuides.Text := '';
  for url in CapabilityStatement.implementationGuideList do
    mImplementationGuides.Text := mImplementationGuides.Text + url.value+#13#10;
end;

procedure TCapabilityStatementEditorFrame.loadResource(res: TFhirCapabilityStatementRestResource);
  procedure interaction(code : TFhirTypeRestfulInteractionEnum; cb : TCheckBox; edt : TEdit);
  var
    ri : TFhirCapabilityStatementRestResourceInteraction;
  begin
    ri := res.interaction(code);
    cb.IsChecked := ri <> nil;
    if cb.IsChecked then
      edt.Text := ri.documentation;
  end;
var
  search : TFhirCapabilityStatementRestResourceSearchParam;
begin
  mDocoRes.Text := res.documentation;
  if res.profile <> nil then
    edtProfile.Text := res.profile.reference
  else
    edtProfile.Text := '';

  interaction(TypeRestfulInteractionread, cbRead, edtDocoRead);
  interaction(TypeRestfulInteractionVread, cbVRead, edtDocoVRead);
  interaction(TypeRestfulInteractionUpdate, cbUpdate, edtDocoUpdate);
  interaction(TypeRestfulInteractionPatch, cbPatch, edtDocoPatch);
  interaction(TypeRestfulInteractionDelete, cbDelete, edtDocoDelete);
  interaction(TypeRestfulInteractionHistoryInstance, cbHistoryInstance, edtDocoHistoryInstance);
  interaction(TypeRestfulInteractionHistoryType, cbHistoryType, edtDocoHistoryType);
  interaction(TypeRestfulInteractioncreate, cbCreate, edtDocoCreate);
  interaction(TypeRestfulInteractionSearchType, cbSearch, edtDocoSearch);

  cbxVersioning.ItemIndex := ord(res.versioning);
  cbUpdateCreate.IsChecked := res.updateCreate;
  cbCondCreate.IsChecked := res.conditionalCreate;
  cbCondUpdate.IsChecked := res.conditionalUpdate;
  cbCondDelete.IsChecked := ord(res.conditionalDelete) > 1;
  cbxReadCondition.ItemIndex := ord(res.conditionalRead);
  cbRefLiteral.IsChecked := ReferenceHandlingPolicyLiteral in res.referencePolicy;
  cbRefLogical.IsChecked := ReferenceHandlingPolicyLogical in res.referencePolicy;
  cbRefResolve.IsChecked := ReferenceHandlingPolicyResolves in res.referencePolicy;
  cbRefEnforced.IsChecked := ReferenceHandlingPolicyEnforced in res.referencePolicy;
  cbRefLocal.IsChecked := ReferenceHandlingPolicyLocal in res.referencePolicy;

  lbSearch.Items.Clear;
  for search in res.searchParamList do
    lbSearch.Items.AddObject(search.summary, search);
  if lbSearch.Items.Count > 0 then
    lbSearch.ItemIndex := 0;
  lbSearchClick(nil);

end;


procedure TCapabilityStatementEditorFrame.loadRest(rest: TFhirCapabilityStatementRest);
  procedure interaction(code : TFhirSystemRestfulInteractionEnum; cb : TCheckBox; edt : TEdit);
  var
    ri : TFhirCapabilityStatementRestInteraction;
  begin
    ri := rest.interaction(code);
    cb.IsChecked := ri <> nil;
    if cb.IsChecked then
      edt.Text := ri.documentation;
  end;
var
  res : TFhirCapabilityStatementRestResource;
  rs : TFhirResourceTypeSet;
  r : TFhirResourceType;
begin
  mDoco.Text := rest.documentation;
  if rest.security <> nil then
  begin
    mSecurity.Text := rest.security.description;
    cbCORS.IsChecked := rest.security.cors;
    cbOAuth.IsChecked := rest.security.serviceList.hasCode['http://hl7.org/fhir/restful-security-service', 'OAuth'];
    cbClientCerts.IsChecked := rest.security.serviceList.hasCode['http://hl7.org/fhir/restful-security-service', 'Certificates'];
    cbSmart.IsChecked := rest.security.serviceList.hasCode['http://hl7.org/fhir/restful-security-service', 'SMART-on-FHIR'];
  end;
  interaction(SystemRestfulInteractionTransaction, cbTransaction, edtTransaction);
  interaction(SystemRestfulInteractionBatch, cbBatch, edtBatch);
  interaction(SystemRestfulInteractionSearchSystem, cbSystemSearch, edtSystemSearch);
  interaction(SystemRestfulInteractionHistorySystem, cbSystemHistory, edtSystemHistory);
  rs := ALL_RESOURCE_TYPES;
  for res in rest.resourceList do
  begin
    r := ResourceTypeByName(CODES_TFhirResourceTypesEnum[res.type_]);
    rs := rs - [r];
  end;
  btnAddResources.Enabled := rs <> [frtCustom];
end;

function TCapabilityStatementEditorFrame.readJurisdiction: Integer;
var
  cc : TFhirCodeableConcept;
  c : TFhirCoding;
begin
  result := -1;
  for cc in CapabilityStatement.jurisdictionList do
    for c in cc.codingList do
    begin
      if c.system = 'urn:iso:std:iso:3166' then
      begin
        if c.code = 'AT' then exit(1);
        if c.code = 'AU' then exit(2);
        if c.code = 'BR' then exit(3);
        if c.code = 'CA' then exit(4);
        if c.code = 'CH' then exit(5);
        if c.code = 'CL' then exit(6);
        if c.code = 'CN' then exit(7);
        if c.code = 'DE' then exit(8);
        if c.code = 'DK' then exit(9);
        if c.code = 'EE' then exit(10);
        if c.code = 'ES' then exit(11);
        if c.code = 'FI' then exit(12);
        if c.code = 'FR' then exit(13);
        if c.code = 'GB' then exit(14);
        if c.code = 'NL' then exit(15);
        if c.code = 'NO' then exit(16);
        if c.code = 'NZ' then exit(17);
        if c.code = 'RU' then exit(18);
        if c.code = 'US' then exit(19);
        if c.code = 'VN' then exit(20);
      end
      else if c.system = 'http://unstats.un.org/unsd/methods/m49/m49.htm' then
      begin
        if c.code = '001' { World } then exit(22);
        if c.code = '002' { Africa } then exit(23);
        if c.code = '019' { Americas } then exit(24);
        if c.code = '142' { Asia } then exit(25);
        if c.code = '150' { Europe } then exit(26);
        if c.code = '053' { Australia and New Zealand } then exit(27);
      end
    end;
end;


procedure TCapabilityStatementEditorFrame.tvStructureClick(Sender: TObject);
var
  obj : TObject;
begin
  Loading := true;
  try
    obj := tvStructure.Selected.TagObject;
    if obj is TFhirCapabilityStatement then
    begin
      tbMetadata.TagObject := obj;
      tbStructure.ActiveTab := tbMetadata;
      loadMetadata;
    end
    else if obj is TFhirCapabilityStatementRest then
    begin
      tbRest.TagObject := obj;
      tbStructure.ActiveTab := tbRest;
      loadRest(obj as TFhirCapabilityStatementRest);
    end
    else if obj is TFhirCapabilityStatementRestResource then
    begin
      tbResource.TagObject := obj;
      tbStructure.ActiveTab := tbResource;
      loadResource(obj as TFhirCapabilityStatementRestResource);
    end
  finally
    Loading := false;
  end;
end;

end.