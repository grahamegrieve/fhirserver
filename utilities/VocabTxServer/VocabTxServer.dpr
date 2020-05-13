{
Copyright (c) 2017+, Health Intersections Pty Ltd (http://www.healthintersections.com.au)
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
program VocabTxServer;

uses
  {$IFDEF MSWINDOWS}
  FastMM4 in '..\..\dependencies\FMM\FastMM4.pas',
  {$ENDIF }
  System.StartUpCopy,
  FMX.Forms,
  TxServerFormUnit in 'TxServerFormUnit.pas' {TxServerForm},
  FHIR.Ui.OSX in '..\..\library\ui\FHIR.Ui.OSX.pas',
  FHIR.Web.WinInet in '..\..\library\web\FHIR.Web.WinInet.pas',
  FHIR.CdsHooks.Client in '..\..\library\cdshooks\FHIR.CdsHooks.Client.pas',
  FHIR.Support.Osx in '..\..\library\support\FHIR.Support.Osx.pas',
  FHIR.Support.Threads in '..\..\library\support\FHIR.Support.Threads.pas',
  FHIR.Support.Base in '..\..\library\support\FHIR.Support.Base.pas',
  FHIR.R4.Resources in '..\..\library\r4\FHIR.R4.Resources.pas',
  FHIR.R4.Types in '..\..\library\r4\FHIR.R4.Types.pas',
  FHIR.Support.Stream in '..\..\library\support\FHIR.Support.Stream.pas',
  FHIR.Support.Collections in '..\..\library\support\FHIR.Support.Collections.pas',
  FHIR.Base.Objects in '..\..\library\base\FHIR.Base.Objects.pas',
  FHIR.R4.Utilities in '..\..\library\r4\FHIR.R4.Utilities.pas',
  FHIR.Web.Parsers in '..\..\library\web\FHIR.Web.Parsers.pas',
  FHIR.Support.Json in '..\..\library\support\FHIR.Support.Json.pas',
  FHIR.Web.Fetcher in '..\..\library\web\FHIR.Web.Fetcher.pas',
  FHIR.Support.Turtle in '..\..\library\support\FHIR.Support.Turtle.pas',
  FHIR.R4.Context in '..\..\library\r4\FHIR.R4.Context.pas',
  FHIR.Server.Session in '..\..\server\FHIR.Server.Session.pas',
  FHIR.Base.Scim in '..\..\library\base\FHIR.Base.Scim.pas',
  FHIR.Support.MXml in '..\..\library\support\FHIR.Support.MXml.pas',
  FHIR.R4.Constants in '..\..\library\r4\FHIR.R4.Constants.pas',
  FHIR.Server.Security in '..\..\server\FHIR.Server.Security.pas',
  FHIR.R4.Tags in '..\..\library\r4\FHIR.R4.Tags.pas',
  FHIR.Base.Lang in '..\..\library\base\FHIR.Base.Lang.pas',
  FHIR.Base.Xhtml in '..\..\library\base\FHIR.Base.Xhtml.pas',
  FHIR.Version.Parser in '..\..\library\version\FHIR.Version.Parser.pas',
  FHIR.Base.Parser in '..\..\library\base\FHIR.Base.Parser.pas',
  FHIR.R4.Xml in '..\..\library\r4\FHIR.R4.Xml.pas',
  FHIR.R4.Json in '..\..\library\r4\FHIR.R4.Json.pas',
  FHIR.R4.Turtle in '..\..\library\r4\FHIR.R4.Turtle.pas',
  FHIR.R4.ElementModel in '..\..\library\r4\FHIR.R4.ElementModel.pas',
  FHIR.R4.Profiles in '..\..\library\r4\FHIR.R4.Profiles.pas',
  FHIR.R4.PathEngine in '..\..\library\r4\FHIR.R4.PathEngine.pas',
  FHIR.Server.Storage in '..\..\Server\FHIR.Server.Storage.pas',
  FHIR.Server.Web in '..\..\Server\FHIR.Server.Web.pas',
  FHIR.Server.UserMgr in '..\..\Server\FHIR.Server.UserMgr.pas',
  FHIR.Server.Indexing in '..\..\Server\FHIR.Server.Indexing.pas',
  FHIR.Database.Manager in '..\..\library\database\FHIR.Database.Manager.pas',
  FHIR.Database.Settings in '..\..\library\database\FHIR.Database.Settings.pas',
  FHIR.Database.Logging in '..\..\library\database\FHIR.Database.Logging.pas',
  FHIR.Database.Dialects in '..\..\library\database\FHIR.Database.Dialects.pas',
  FHIR.Tx.Server in '..\..\Server\FHIR.Tx.Server.pas',
  FHIR.CdsHooks.Utilities in '..\..\library\cdshooks\FHIR.CdsHooks.Utilities.pas',
  MarkdownProcessor in '..\..\..\markdown\source\MarkdownProcessor.pas',
  MarkdownDaringFireball in '..\..\..\markdown\source\MarkdownDaringFireball.pas',
  MarkdownCommonMark in '..\..\..\markdown\source\MarkdownCommonMark.pas',
  FHIR.Smart.Utilities in '..\..\library\smart\FHIR.Smart.Utilities.pas',
  FHIR.Version.Client in '..\..\library\version\FHIR.Version.Client.pas',
  FHIR.R4.Operations in '..\..\library\r4\FHIR.R4.Operations.pas',
  FHIR.R4.OpBase in '..\..\library\r4\FHIR.R4.OpBase.pas',
  FHIR.Tx.Service in '..\..\library\FHIR.Tx.Service.pas',
  YuStemmer in '..\..\dependencies\Stem\YuStemmer.pas',
  DISystemCompat in '..\..\dependencies\Stem\DISystemCompat.pas',
  FHIR.Snomed.Services in '..\..\library\snomed\FHIR.Snomed.Services.pas',
  FHIR.Snomed.Expressions in '..\..\library\snomed\FHIR.Snomed.Expressions.pas',
  FHIR.Loinc.Services in '..\..\library\loinc\FHIR.Loinc.Services.pas',
  FHIR.Ucum.Services in '..\..\library\Ucum\FHIR.Ucum.Services.pas',
  FHIR.Ucum.Handlers in '..\..\library\Ucum\FHIR.Ucum.Handlers.pas',
  FHIR.Ucum.Base in '..\..\library\Ucum\FHIR.Ucum.Base.pas',
  FHIR.Ucum.Validators in '..\..\library\Ucum\FHIR.Ucum.Validators.pas',
  FHIR.Ucum.Expressions in '..\..\library\Ucum\FHIR.Ucum.Expressions.pas',
  FHIR.Ucum.Search in '..\..\library\Ucum\FHIR.Ucum.Search.pas',
  FHIR.Tx.RxNorm in '..\..\Server\FHIR.Tx.RxNorm.pas',
  FHIR.Tx.Unii in '..\..\Server\FHIR.Tx.Unii.pas',
  FHIR.Support.Logging in '..\..\library\support\FHIR.Support.Logging.pas',
  FHIR.Tx.ACIR in '..\..\Server\FHIR.Tx.ACIR.pas',
  FHIR.Tx.AreaCode in '..\..\Server\FHIR.Tx.AreaCode.pas',
  FHIR.Tx.Lang in '..\..\Server\FHIR.Tx.Lang.pas',
  FHIR.Tx.Manager in '..\..\Server\FHIR.Tx.Manager.pas',
  FHIR.Tx.Uri in '..\..\Server\FHIR.Tx.Uri.pas',
  FHIR.Server.ClosureMgr in '..\..\Server\FHIR.Server.ClosureMgr.pas',
  FHIR.Server.Adaptations in '..\..\Server\FHIR.Server.Adaptations.pas',
  FHIR.R4.IndexInfo in '..\..\library\r4\FHIR.R4.IndexInfo.pas',
  FHIR.R4.Validator in '..\..\library\r4\FHIR.R4.Validator.pas',
  FHIR.Web.Socket in '..\..\library\web\FHIR.Web.Socket.pas',
  FHIR.Server.Ini in '..\..\Server\FHIR.Server.Ini.pas',
  FHIR.Server.SessionMgr in '..\..\Server\FHIR.Server.SessionMgr.pas',
  FHIR.Scim.Server in '..\..\Server\FHIR.Scim.Server.pas',
  FHIR.Scim.Search in '..\..\Server\FHIR.Scim.Search.pas',
  FHIR.Server.TagMgr in '..\..\Server\FHIR.Server.TagMgr.pas',
  FHIR.Server.Jwt in '..\..\Server\FHIR.Server.Jwt.pas',
  FHIR.Tools.ApplicationVerifier in '..\..\library\tools\FHIR.Tools.ApplicationVerifier.pas',
  FHIR.Web.Twilio in '..\..\library\web\FHIR.Web.Twilio.pas',
  FHIR.Server.Context in '..\..\Server\FHIR.Server.Context.pas',
  FHIR.Web.HtmlGen in '..\..\library\web\FHIR.Web.HtmlGen.pas',
  FHIR.Web.Rdf in '..\..\library\web\FHIR.Web.Rdf.pas',
  FHIR.R4.Questionnaire in '..\..\library\r4\FHIR.R4.Questionnaire.pas',
  FHIR.R4.Narrative2 in '..\..\library\r4\FHIR.R4.Narrative2.pas',
  FHIR.Tools.GraphQL in '..\..\library\tools\FHIR.Tools.GraphQL.pas',
  FHIR.Snomed.Publisher in '..\..\library\snomed\FHIR.Snomed.Publisher.pas',
  FHIR.Loinc.Publisher in '..\..\library\loinc\FHIR.Loinc.Publisher.pas',
  FHIR.Tx.Web in '..\..\Server\FHIR.Tx.Web.pas',
  FHIR.Snomed.Analysis in '..\..\library\snomed\FHIR.Snomed.Analysis.pas',
  FHIR.Server.Constants in '..\..\Server\FHIR.Server.Constants.pas',
  FHIR.Server.AuthMgr in '..\..\Server\FHIR.Server.AuthMgr.pas',
  FHIR.Web.Facebook in '..\..\library\web\FHIR.Web.Facebook.pas',
  FHIR.R4.AuthMap in '..\..\library\r4\FHIR.R4.AuthMap.pas',
  FHIR.Server.ReverseClient in '..\..\Server\FHIR.Server.ReverseClient.pas',
  FHIR.CdsHooks.Server in '..\..\Server\FHIR.CdsHooks.Server.pas',
  FHIR.Server.OpenMHealth in '..\..\Server\FHIR.Server.OpenMHealth.pas',
  VocabPocServerCore in 'VocabPocServerCore.pas',
  FHIR.Server.SearchSyntax in '..\..\Server\FHIR.Server.SearchSyntax.pas',
  FHIR.Tools.Search in '..\..\library\tools\FHIR.Tools.Search.pas',
  FHIR.Tx.Operations in '..\..\Server\FHIR.Tx.Operations.pas',
  FHIR.Server.WebSource in '..\..\Server\FHIR.Server.WebSource.pas',
  vpocversion in 'vpocversion.pas',
  FHIR.Tools.Indexing in '..\..\library\tools\FHIR.Tools.Indexing.pas',
  FHIR.Support.SCrypt in '..\..\library\support\FHIR.Support.SCrypt.pas',
  FHIR.Tx.ICD10 in '..\..\Server\FHIR.Tx.ICD10.pas',
  FHIR.Support.Signatures in '..\..\library\support\FHIR.Support.Signatures.pas',
  FHIR.R4.Factory in '..\..\library\r4\FHIR.R4.Factory.pas',
  FHIR.Tx.CountryCode in '..\..\Server\FHIR.Tx.CountryCode.pas',
  FHIR.Tx.UsState in '..\..\Server\FHIR.Tx.UsState.pas',
  FHIR.R4.PathNode in '..\..\library\r4\FHIR.R4.PathNode.pas',
  FHIR.Server.Analytics in '..\..\Server\FHIR.Server.Analytics.pas',
  FHIR.Ucum.IFace in '..\..\library\ucum\FHIR.Ucum.IFace.pas',
  FHIR.R4.Base in '..\..\library\r4\FHIR.R4.Base.pas',
  FHIR.Server.XhtmlComp in '..\..\Server\FHIR.Server.XhtmlComp.pas',
  FHIR.R4.ParserBase in '..\..\library\r4\FHIR.R4.ParserBase.pas',
  FHIR.R4.Parser in '..\..\library\r4\FHIR.R4.Parser.pas',
  FHIR.Client.Base in '..\..\library\client\FHIR.Client.Base.pas',
  FHIR.Client.HTTP in '..\..\library\client\FHIR.Client.HTTP.pas',
  FHIR.Client.Threaded in '..\..\library\client\FHIR.Client.Threaded.pas',
  FHIR.R4.Client in '..\..\library\r4\FHIR.R4.Client.pas',
  FHIR.Support.Xml in '..\..\library\support\FHIR.Support.Xml.pas',
  FHIR.Support.Certs in '..\..\library\support\FHIR.Support.Certs.pas',
  FHIR.Web.GraphQL in '..\..\library\web\FHIR.Web.GraphQL.pas',
  {$IFDEF MSWINDOWS}
  FHIR.Support.MsXml in '..\..\library\support\FHIR.Support.MsXml.pas',
  {$ENDIF }
  FHIR.Support.Utilities in '..\..\library\support\FHIR.Support.Utilities.pas',
  FHIR.Base.Factory in '..\..\library\base\FHIR.Base.Factory.pas',
  FHIR.Base.Validator in '..\..\library\base\FHIR.Base.Validator.pas',
  FHIR.Base.Common in '..\..\library\base\FHIR.Base.Common.pas',
  FHIR.Base.Narrative in '..\..\library\base\FHIR.Base.Narrative.pas',
  FHIR.Base.PathEngine in '..\..\library\base\FHIR.Base.PathEngine.pas',
  FHIR.R4.Common in '..\..\library\r4\FHIR.R4.Common.pas',
  FHIR.R4.Narrative in '..\..\library\r4\FHIR.R4.Narrative.pas',
  FHIR.Base.Utilities in '..\..\library\base\FHIR.Base.Utilities.pas',
  fhir.support.fpc in '..\..\library\support\fhir.support.fpc.pas',
  FHIR.Tx.MimeTypes in '..\..\Server\FHIR.Tx.MimeTypes.pas',
  FHIR.Tx.Iso4217 in '..\..\Server\FHIR.Tx.Iso4217.pas',
  FHIR.Tools.ValueSets in '..\..\library\tools\FHIR.Tools.ValueSets.pas',
  FHIR.Tools.CodeSystemProvider in '..\..\library\tools\FHIR.Tools.CodeSystemProvider.pas',
  FHIR.Server.Tags in '..\..\Server\FHIR.Server.Tags.pas',
  FHIR.Server.BundleBuilder in '..\..\Server\FHIR.Server.BundleBuilder.pas',
  FHIR.Server.Factory in '..\..\Server\FHIR.Server.Factory.pas',
  FHIR.Tools.NDJsonParser in '..\..\library\tools\FHIR.Tools.NDJsonParser.pas',
  FHIR.Support.Lang in '..\..\library\support\FHIR.Support.Lang.pas',
  FHIR.Server.Utilities in '..\..\Server\FHIR.Server.Utilities.pas',
  FHIR.Base.OIDs in '..\..\library\base\FHIR.Base.OIDs.pas',
  FHIR.Cda.Base in '..\..\library\cda\FHIR.Cda.Base.pas',
  FHIR.Cda.Documents in '..\..\library\cda\FHIR.Cda.Documents.pas',
  FHIR.Cda.Narrative in '..\..\library\cda\FHIR.Cda.Narrative.pas',
  FHIR.Cda.Objects in '..\..\library\cda\FHIR.Cda.Objects.pas',
  FHIR.Cda.Types in '..\..\library\cda\FHIR.Cda.Types.pas',
  FHIR.Cda.Parser in '..\..\library\cda\FHIR.Cda.Parser.pas',
  FHIR.Cda.Writer in '..\..\library\cda\FHIR.Cda.Writer.pas',
  FHIR.Base.ElementModel in '..\..\library\base\FHIR.Base.ElementModel.pas',
  FHIR.Cache.PackageManager in '..\..\library\cache\FHIR.Cache.PackageManager.pas',
  MarkdownHTMLEntities in '..\..\..\markdown\source\MarkdownHTMLEntities.pas',
  FHIR.Server.ConsentEngine in '..\..\Server\FHIR.Server.ConsentEngine.pas' {,
  FHIR.Tx.NDC in '..\..\Server\FHIR.Tx.NDC.pas';

{$R *.res},
  {$IFDEF MSWINDOWS}
  FHIR.Support.Service in '..\..\library\support\FHIR.Support.Service.pas',
  {$ENDIF }
  FHIR.Tx.NDC in '..\..\Server\FHIR.Tx.NDC.pas',
  FHIR.Server.UsageStats in '..\..\Server\FHIR.Server.UsageStats.pas',
  FHIR.Cache.NpmPackage in '..\..\library\cache\FHIR.Cache.NpmPackage.pas',
  FHIR.Server.Subscriptions in '..\..\Server\FHIR.Server.Subscriptions.pas',
  FHIR.Server.IndexingR4 in '..\..\Server\FHIR.Server.IndexingR4.pas',
  FHIR.Server.ValidatorR4 in '..\..\Server\FHIR.Server.ValidatorR4.pas',
  FHIR.Cache.PackageUpdater in '..\..\library\cache\FHIR.Cache.PackageUpdater.pas',
  FHIR.Server.Packages in '..\..\Server\FHIR.Server.Packages.pas',
  FHIR.Server.Twilio in '..\..\Server\FHIR.Server.Twilio.pas',
  FastMM4Messages in '..\..\dependencies\FMM\FastMM4Messages.pas',
  FHIR.Database.ODBC in '..\..\library\database\FHIR.Database.ODBC.pas',
  FHIR.Database.ODBC.Objects in '..\..\library\database\FHIR.Database.ODBC.Objects.pas',
  FHIR.Database.ODBC.Headers in '..\..\library\database\FHIR.Database.ODBC.Headers.pas',
  FHIR.Cache.PackageClient in '..\..\library\cache\FHIR.Cache.PackageClient.pas',
  FHIR.Server.WebBase in '..\..\Server\FHIR.Server.WebBase.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TTxServerForm, TxServerForm);
  Application.Run;
end.
