unit FHIR.R3.Organiser;

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

  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
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

{$IFDEF FPC}{$MODE DELPHI}{$ENDIF}

interface

uses
  SysUtils,
  FHIR.Support.Base,
  FHIR.R3.Resources, FHIR.R3.Resources.Base;

type
  TFHIRResourceOrganiser = class (TFslObject)
  private
    procedure organiseCS(res : TFhirCapabilityStatement);
    function sortCSRest(pA, pB: Pointer): Integer;
    function sortCSRInteraction(pA, pB: Pointer): Integer;
  public
    function canOrganise(res : TFhirResourceType) : boolean;
    procedure organise(res : TFhirResource);
  end;

implementation

{ TFHIRResourceOrganiser }

function TFHIRResourceOrganiser.canOrganise(res: TFhirResourceType): boolean;
begin
  result := res in [frtCapabilityStatement];
end;

procedure TFHIRResourceOrganiser.organise(res: TFhirResource);
begin
  case res.ResourceType of
    frtCapabilityStatement: organiseCS(res as TFhirCapabilityStatement);
  else
    // nothing to do;
  end;
end;

Function TFHIRResourceOrganiser.sortCSRInteraction(pA, pB : Pointer) : Integer;
var
  rA, rB : TFhirCapabilityStatementRestResourceInteraction;
begin
  rA := TFhirCapabilityStatementRestResourceInteraction(pA);
  rB := TFhirCapabilityStatementRestResourceInteraction(pB);
  result := ord(rA.code) - ord(rb.code);
end;

Function TFHIRResourceOrganiser.sortCSRest(pA, pB : Pointer) : Integer;
var
  rA, rB : TFhirCapabilityStatementRestResource;
begin
  rA := TFhirCapabilityStatementRestResource(pA);
  rB := TFhirCapabilityStatementRestResource(pB);
  result := ord(rA.type_) - ord(rb.type_);
end;

procedure TFHIRResourceOrganiser.organiseCS(res: TFhirCapabilityStatement);
var
  csr : TFhirCapabilityStatementRest;
  csrr : TFhirCapabilityStatementRestResource;
begin
  for csr in res.restList do
  begin
    csr.resourceList.SortedBy(sortCSRest);
    for csrr in csr.resourceList do
    begin
      csrr.interactionList.SortedBy(sortCSRInteraction);
    end;
  end;
end;

end.

