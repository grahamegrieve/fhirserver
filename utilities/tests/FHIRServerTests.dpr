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
program FHIRServerTests;

{$IFNDEF TESTINSIGHT}
{$APPTYPE CONSOLE}
{$ENDIF}{$STRONGLINKTYPES ON}
uses
  FastMM4 in '..\..\dependencies\FMM\FastMM4.pas',
  FastMM4Messages in '..\..\dependencies\FMM\FastMM4Messages.pas',
  Windows,
  SysUtils,
  Classes,
  JclDebug,
  {$IFDEF TESTINSIGHT}
  TestInsight.DUnitX,
  {$ENDIF }
  IdSSLOpenSSLHeaders,
  DUnitX.Loggers.Console,
  DUnitX.Loggers.Xml.NUnit,
  DUnitX.TestFramework,
  fhir_common in '..\..\library\base\fhir_common.pas',
  fhir_elementmodel in '..\..\library\base\fhir_elementmodel.pas',
  fhir_factory in '..\..\library\base\fhir_factory.pas',
  fhir_graphdefinition in '..\..\library\base\fhir_graphdefinition.pas',
  FHIR.Base.Lang in '..\..\library\base\FHIR.Base.Lang.pas',
  fhir_narrative in '..\..\library\base\fhir_narrative.pas',
  fhir_oids in '..\..\library\base\fhir_oids.pas',
  fhir_objects in '..\..\library\base\fhir_objects.pas',
  fhir_parser in '..\..\library\base\fhir_parser.pas',
  fhir_pathengine in '..\..\library\base\fhir_pathengine.pas',
  fsl_scim in '..\..\library\base\fsl_scim.pas',
  fhir_utilities in '..\..\library\base\fhir_utilities.pas',
  fhir_validator in '..\..\library\base\fhir_validator.pas',
  fhir_xhtml in '..\..\library\base\fhir_xhtml.pas',
  fsl_npm_cache in '..\..\library\npm\fsl_npm_cache.pas',
  cda_base in '..\..\library\cda\cda_base.pas',
  cda_narrative in '..\..\library\cda\cda_narrative.pas',
  cda_types in '..\..\library\cda\cda_types.pas',
  FHIR.CdsHooks.Client in '..\..\library\cdshooks\FHIR.CdsHooks.Client.pas',
  FHIR.CdsHooks.Server in '..\..\server\FHIR.CdsHooks.Server.pas',
  FHIR.CdsHooks.Service in '..\..\server\FHIR.CdsHooks.Service.pas',
  fhir_cdshooks in '..\..\library\cdshooks\fhir_cdshooks.pas',
  fhir_client in '..\..\library\client\fhir_client.pas',
  fhir_client_http in '..\..\library\client\fhir_client_http.pas',
  fhir_js_client in '..\..\library\client\fhir_js_client.pas',
  fhir_client_threaded in '..\..\library\client\fhir_client_threaded.pas',
  FHIR.Cql.Engine in '..\..\library\cql\FHIR.Cql.Engine.pas',
  FHIR.Cql.Model in '..\..\library\cql\FHIR.Cql.Model.pas',
  FHIR.Cql.Parser in '..\..\library\cql\FHIR.Cql.Parser.pas',
  FHIR.Cql.Tests in '..\..\library\cql\FHIR.Cql.Tests.pas',
  fdb_dialects in '..\..\library\fdb\fdb_dialects.pas',
  fdb_logging in '..\..\library\fdb\fdb_logging.pas',
  fdb_manager in '..\..\library\fdb\fdb_manager.pas',
  fdb_odbc in '..\..\library\fdb\fdb_odbc.pas',
  fdb_odbc_headers in '..\..\library\fdb\fdb_odbc_headers.pas',
  fdb_odbc_objects in '..\..\library\fdb\fdb_odbc_objects.pas',
  fdb_sqlite3 in '..\..\library\fdb\fdb_sqlite3.pas',
  fdb_sqlite3_objects in '..\..\library\fdb\fdb_sqlite3_objects.pas',
  fdb_sqlite3_utilities in '..\..\library\fdb\fdb_sqlite3_utilities.pas',
  fdb_sqlite3_wrapper in '..\..\library\fdb\fdb_sqlite3_wrapper.pas',
  fdb_settings in '..\..\library\fdb\fdb_settings.pas',
  FHIR.Database.Tests in '..\..\library\fdb\FHIR.Database.Tests.pas',
  FHIR.Database.Utilities in '..\..\library\fdb\FHIR.Database.Utilities.pas',
  FHIR.Java.JNI in '..\..\library\java\FHIR.Java.JNI.pas',
  FHIR.Java.Runtime in '..\..\library\java\FHIR.Java.Runtime.pas',
  FHIR.Java.Strings in '..\..\library\java\FHIR.Java.Strings.pas',
  FHIR.Java.Utilities in '..\..\library\java\FHIR.Java.Utilities.pas',
  FHIR.Java.Wrapper in '..\..\library\java\FHIR.Java.Wrapper.pas',
  FHIR.Javascript in '..\..\library\javascript\FHIR.Javascript.pas',
  fhir_javascript in '..\..\library\javascript\fhir_javascript.pas',
  FHIR.Javascript.ObjectsTests in '..\..\library\javascript\FHIR.Javascript.ObjectsTests.pas',
  fhir_tests_javascript in '..\..\library\javascript\fhir_tests_javascript.pas',
  ftx_loinc_importer in '..\..\library\loinc\ftx_loinc_importer.pas',
  ftx_loinc_publisher in '..\..\library\loinc\ftx_loinc_publisher.pas',
  ftx_loinc_services in '..\..\library\loinc\ftx_loinc_services.pas',
  fhir2_authmap in '..\..\library\r2\fhir2_authmap.pas',
  fhir2_base in '..\..\library\r2\fhir2_base.pas',
  fhir2_client in '..\..\library\r2\fhir2_client.pas',
  fhir2_common in '..\..\library\r2\fhir2_common.pas',
  fhir2_constants in '..\..\library\r2\fhir2_constants.pas',
  fhir2_context in '..\..\library\r2\fhir2_context.pas',
  fhir2_elementmodel in '..\..\library\r2\fhir2_elementmodel.pas',
  fhir2_factory in '..\..\library\r2\fhir2_factory.pas',
  fhir2_indexinfo in '..\..\library\r2\fhir2_indexinfo.pas',
  fhir2_javascript in '..\..\library\r2\fhir2_javascript.pas',
  fhir2_json in '..\..\library\r2\fhir2_json.pas',
  fhir2_narrative in '..\..\library\r2\fhir2_narrative.pas',
  fhir2_narrative2 in '..\..\library\r2\fhir2_narrative2.pas',
  fhir2_opbase in '..\..\library\r2\fhir2_opbase.pas',
  fhir2_operations in '..\..\library\r2\fhir2_operations.pas',
  fhir2_parser in '..\..\library\r2\fhir2_parser.pas',
  fhir2_parserBase in '..\..\library\r2\fhir2_parserBase.pas',
  fhir2_pathengine in '..\..\library\r2\fhir2_pathengine.pas',
  fhir2_pathnode in '..\..\library\r2\fhir2_pathnode.pas',
  fhir2_profiles in '..\..\library\r2\fhir2_profiles.pas',
  fhir2_questionnaire in '..\..\library\r2\fhir2_questionnaire.pas',
  fhir2_resources in '..\..\library\r2\fhir2_resources.pas',
  FHIR.R2.Tags in '..\..\library\r2\FHIR.R2.Tags.pas',
  fhir2_types in '..\..\library\r2\fhir2_types.pas',
  fhir2_utilities in '..\..\library\r2\fhir2_utilities.pas',
  fhir2_validator in '..\..\library\r2\fhir2_validator.pas',
  fhir2_xml in '..\..\library\r2\fhir2_xml.pas',
  fhir3_authmap in '..\..\library\r3\fhir3_authmap.pas',
  fhir3_base in '..\..\library\r3\fhir3_base.pas',
  fhir3_client in '..\..\library\r3\fhir3_client.pas',
  fhir3_common in '..\..\library\r3\fhir3_common.pas',
  fhir3_constants in '..\..\library\r3\fhir3_constants.pas',
  fhir3_context in '..\..\library\r3\fhir3_context.pas',
  fhir3_elementmodel in '..\..\library\r3\fhir3_elementmodel.pas',
  fhir3_factory in '..\..\library\r3\fhir3_factory.pas',
  fhir3_indexinfo in '..\..\library\r3\fhir3_indexinfo.pas',
  fhir3_javascript in '..\..\library\r3\fhir3_javascript.pas',
  fhir3_json in '..\..\library\r3\fhir3_json.pas',
  fhir3_liquid in '..\..\library\r3\fhir3_liquid.pas',
  fhir3_maputils in '..\..\library\r3\fhir3_maputils.pas',
  fhir3_narrative in '..\..\library\r3\fhir3_narrative.pas',
  fhir3_narrative2 in '..\..\library\r3\fhir3_narrative2.pas',
  fhir3_opbase in '..\..\library\r3\fhir3_opbase.pas',
  fhir3_operations in '..\..\library\r3\fhir3_operations.pas',
  fhir3_parser in '..\..\library\r3\fhir3_parser.pas',
  fhir3_parserBase in '..\..\library\r3\fhir3_parserBase.pas',
  fhir3_pathengine in '..\..\library\r3\fhir3_pathengine.pas',
  fhir3_pathnode in '..\..\library\r3\fhir3_pathnode.pas',
  fhir3_profiles in '..\..\library\r3\fhir3_profiles.pas',
  fhir3_questionnaire in '..\..\library\r3\fhir3_questionnaire.pas',
  fhir3_resources in '..\..\library\r3\fhir3_resources.pas',
  fhir3_tags in '..\..\library\r3\fhir3_tags.pas',
  fhir3_turtle in '..\..\library\r3\fhir3_turtle.pas',
  fhir3_types in '..\..\library\r3\fhir3_types.pas',
  fhir3_utilities in '..\..\library\r3\fhir3_utilities.pas',
  fhir3_validator in '..\..\library\r3\fhir3_validator.pas',
  fhir3_xml in '..\..\library\r3\fhir3_xml.pas',
  fhir4_authmap in '..\..\library\r4\fhir4_authmap.pas',
  fhir4_base in '..\..\library\r4\fhir4_base.pas',
  fhir4_client in '..\..\library\r4\fhir4_client.pas',
  fhir4_common in '..\..\library\r4\fhir4_common.pas',
  fhir4_constants in '..\..\library\r4\fhir4_constants.pas',
  fhir4_context in '..\..\library\r4\fhir4_context.pas',
  fhir4_elementmodel in '..\..\library\r4\fhir4_elementmodel.pas',
  fhir4_factory in '..\..\library\r4\fhir4_factory.pas',
  fhir4_graphdefinition in '..\..\library\r4\fhir4_graphdefinition.pas',
  fhir4_indexinfo in '..\..\library\r4\fhir4_indexinfo.pas',
  fhir4_javascript in '..\..\library\r4\fhir4_javascript.pas',
  fhir4_json in '..\..\library\r4\fhir4_json.pas',
  fhir4_liquid in '..\..\library\r4\fhir4_liquid.pas',
  fhir4_maputils in '..\..\library\r4\fhir4_maputils.pas',
  fhir4_narrative in '..\..\library\r4\fhir4_narrative.pas',
  fhir4_narrative2 in '..\..\library\r4\fhir4_narrative2.pas',
  fhir4_opbase in '..\..\library\r4\fhir4_opbase.pas',
  fhir4_operations in '..\..\library\r4\fhir4_operations.pas',
  fhir4_parser in '..\..\library\r4\fhir4_parser.pas',
  fhir4_parserBase in '..\..\library\r4\fhir4_parserBase.pas',
  fhir4_pathengine in '..\..\library\r4\fhir4_pathengine.pas',
  fhir4_pathnode in '..\..\library\r4\fhir4_pathnode.pas',
  fhir4_profiles in '..\..\library\r4\fhir4_profiles.pas',
  fhir4_questionnaire in '..\..\library\r4\fhir4_questionnaire.pas',
  fhir4_resources in '..\..\library\r4\fhir4_resources.pas',
  fhir4_tags in '..\..\library\r4\fhir4_tags.pas',
  fhir4_tests_Client in '..\..\library\r4\tests\fhir4_tests_Client.pas',
  fhir4_tests_Liquid in '..\..\library\r4\tests\fhir4_tests_Liquid.pas',
  fhir4_tests_Maps in '..\..\library\r4\tests\fhir4_tests_Maps.pas',
  fhir4_tests_Parser in '..\..\library\r4\tests\fhir4_tests_Parser.pas',
  fhir4_tests_PathEngine in '..\..\library\r4\tests\fhir4_tests_PathEngine.pas',
  fhir4_tests_Utilities in '..\..\library\r4\tests\fhir4_tests_Utilities.pas',
  fhir4_tests_Validator in '..\..\library\r4\tests\fhir4_tests_Validator.pas',
  fhir4_tests_worker in '..\..\library\r4\tests\fhir4_tests_worker.pas',
  fhir4_turtle in '..\..\library\r4\fhir4_turtle.pas',
  fhir4_types in '..\..\library\r4\fhir4_types.pas',
  fhir4_utilities in '..\..\library\r4\fhir4_utilities.pas',
  fhir4_validator in '..\..\library\r4\fhir4_validator.pas',
  fhir4_xml in '..\..\library\r4\fhir4_xml.pas',
  FHIR.Scim.Search in '..\..\server\FHIR.Scim.Search.pas',
  FHIR.Scim.Server in '..\..\server\FHIR.Scim.Server.pas',
  FHIR.Server.AccessControl in '..\..\server\FHIR.Server.AccessControl.pas',
  FHIR.Server.Adaptations in '..\..\server\FHIR.Server.Adaptations.pas',
  FHIR.Server.Analytics in '..\..\server\FHIR.Server.Analytics.pas',
  FHIR.Server.AuthMgr in '..\..\server\FHIR.Server.AuthMgr.pas',
  FHIR.Server.BundleBuilder in '..\..\server\FHIR.Server.BundleBuilder.pas',
  FHIR.Server.ClosureMgr in '..\..\server\FHIR.Server.ClosureMgr.pas',
  FHIR.Server.Constants in '..\..\server\FHIR.Server.Constants.pas',
  FHIR.Server.Context in '..\..\server\FHIR.Server.Context.pas',
  FHIR.Server.DBInstaller in '..\..\server\FHIR.Server.DBInstaller.pas',
  FHIR.Server.Database in '..\..\server\FHIR.Server.Database.pas',
  FHIR.Server.EventJs in '..\..\server\FHIR.Server.EventJs.pas',
  FHIR.Server.Factory in '..\..\server\FHIR.Server.Factory.pas',
  FHIR.Server.GraphDefinition in '..\..\server\FHIR.Server.GraphDefinition.pas',
  FHIR.Server.HackingHealth in '..\..\server\Modules\FHIR.Server.HackingHealth.pas',
  FHIR.Server.IndexingR4 in '..\..\server\FHIR.Server.IndexingR4.pas',
  FHIR.Server.Ini in '..\..\server\FHIR.Server.Ini.pas',
  FHIR.Server.Javascript in '..\..\server\FHIR.Server.Javascript.pas',
  FHIR.Server.Jwt in '..\..\server\FHIR.Server.Jwt.pas',
  FHIR.Server.MpiSearch in '..\..\server\FHIR.Server.MpiSearch.pas',
  FHIR.Server.ObsStats in '..\..\server\FHIR.Server.ObsStats.pas',
  FHIR.Server.OpenMHealth in '..\..\server\FHIR.Server.OpenMHealth.pas',
  FHIR.Server.OperationsR4 in '..\..\server\FHIR.Server.OperationsR4.pas',
  FHIR.Server.ReverseClient in '..\..\server\FHIR.Server.ReverseClient.pas',
  FHIR.Server.Search in '..\..\server\FHIR.Server.Search.pas',
  FHIR.Server.SearchSyntax in '..\..\server\FHIR.Server.SearchSyntax.pas',
  FHIR.Server.Security in '..\..\server\FHIR.Server.Security.pas',
  FHIR.Server.Session in '..\..\server\FHIR.Server.Session.pas',
  FHIR.Server.SessionMgr in '..\..\server\FHIR.Server.SessionMgr.pas',
  FHIR.Server.Storage in '..\..\server\FHIR.Server.Storage.pas',
  FHIR.Server.Subscriptions in '..\..\server\FHIR.Server.Subscriptions.pas',
  FHIR.Server.SubscriptionsR4 in '..\..\server\FHIR.Server.SubscriptionsR4.pas',
  FHIR.Server.TagMgr in '..\..\server\FHIR.Server.TagMgr.pas',
  FHIR.Server.Tags in '..\..\server\FHIR.Server.Tags.pas',
  FHIR.Server.UserMgr in '..\..\server\FHIR.Server.UserMgr.pas',
  FHIR.Server.Utilities in '..\..\server\FHIR.Server.Utilities.pas',
  FHIR.Server.ValidatorR4 in '..\..\server\FHIR.Server.ValidatorR4.pas',
  FHIR.Server.Version in '..\..\server\FHIR.Server.Version.pas',
  FHIR.Server.Web in '..\..\server\FHIR.Server.Web.pas',
  FHIR.Server.WebSource in '..\..\server\FHIR.Server.WebSource.pas',
  FHIR.Server.XhtmlComp in '..\..\server\FHIR.Server.XhtmlComp.pas',
  FHIR.Smart.Login in '..\..\library\smart\FHIR.Smart.Login.pas',
  fhir_oauth in '..\..\library\smart\fhir_oauth.pas',
  ftx_sct_analysis in '..\..\library\snomed\ftx_sct_analysis.pas',
  ftx_sct_expressions in '..\..\library\snomed\ftx_sct_expressions.pas',
  ftx_sct_importer in '..\..\library\snomed\ftx_sct_importer.pas',
  ftx_sct_publisher in '..\..\library\snomed\ftx_sct_publisher.pas',
  ftx_sct_services in '..\..\library\Snomed\ftx_sct_services.pas',
  fsl_base in '..\..\library\Support\fsl_base.pas',
  FHIR.Support.Certs in '..\..\library\support\FHIR.Support.Certs.pas',
  fsl_collections in '..\..\library\Support\fsl_collections.pas',
  fsl_comparisons in '..\..\library\support\fsl_comparisons.pas',
  fsl_fpc in '..\..\library\support\fsl_fpc.pas',
  fsl_json in '..\..\library\Support\fsl_json.pas',
  fsl_javascript in '..\..\library\support\fsl_javascript.pas',
  FHIR.Support.Lang in '..\..\library\support\FHIR.Support.Lang.pas',
  fsl_logging in '..\..\library\support\fsl_logging.pas',
  fsl_xml in '..\..\library\support\fsl_xml.pas',
  fsl_msxml in '..\..\library\support\fsl_msxml.pas',
  FHIR.Support.Osx in '..\..\library\support\FHIR.Support.Osx.pas',
  fsl_scrypt in '..\..\library\support\fsl_scrypt.pas',
  fsl_service_win in '..\..\library\Support\fsl_service_win.pas',
  fsl_shell in '..\..\library\Support\fsl_shell.pas',
  FHIR.Support.Signatures in '..\..\library\Support\FHIR.Support.Signatures.pas',
  fsl_stream in '..\..\library\Support\fsl_stream.pas',
  fsl_tests in '..\..\library\support\fsl_tests.pas',
  fsl_threads in '..\..\library\Support\fsl_threads.pas',
  fsl_turtle in '..\..\library\support\fsl_turtle.pas',
  fsl_utilities in '..\..\library\Support\fsl_utilities.pas',
  fsl_xml in '..\..\library\support\fsl_xml.pas',
  FHIR.Tests.FullServer in 'FHIR.Tests.FullServer.pas',
  FHIR.Tests.GraphDefinition in 'FHIR.Tests.GraphDefinition.pas',
  fhir4_tests_graphql in 'fhir4_tests_graphql.pas',
  FHIR.Tests.IETFLang in '..\FHIR.Tests.IETFLang.pas',
  FHIR.Tests.IdUriParser in '..\FHIR.Tests.IdUriParser.pas',
  FHIR.Tests.RestFulServer in 'FHIR.Tests.RestFulServer.pas',
  FHIR.Tests.SearchSyntax in 'FHIR.Tests.SearchSyntax.pas',
  FHIR.Tests.SmartLogin in '..\FHIR.Tests.SmartLogin.pas',
  FHIR.Tests.Snomed in '..\FHIR.Tests.Snomed.pas',
  FHIR.Tools.ApplicationVerifier in '..\..\library\tools\FHIR.Tools.ApplicationVerifier.pas',
  fhir_codegen in '..\..\library\tools\fhir_codegen.pas',
  fhir_codesystem_service in '..\..\library\tools\fhir_codesystem_service.pas',
  fhir_diff in '..\..\library\tools\fhir_diff.pas',
  fhir_tests_diff in '..\..\library\tools\fhir_tests_diff.pas',
  fhir_graphql in '..\..\library\tools\fhir_graphql.pas',
  fhir_indexing in '..\..\library\tools\fhir_indexing.pas',
  fhir_ndjson in '..\..\library\tools\fhir_ndjson.pas',
  fhir_valuesets.pas in '..\..\library\tools\fhir_valuesets.pas.pas',
  FHIR.Tx.ACIR in '..\..\server\FHIR.Tx.ACIR.pas',
  FHIR.Tx.AreaCode in '..\..\server\FHIR.Tx.AreaCode.pas',
  FHIR.Tx.CountryCode in '..\..\server\FHIR.Tx.CountryCode.pas',
  FHIR.Tx.ICD10 in '..\..\server\FHIR.Tx.ICD10.pas',
  FHIR.Tx.Iso4217 in '..\..\server\FHIR.Tx.Iso4217.pas',
  FHIR.Tx.Lang in '..\..\server\FHIR.Tx.Lang.pas',
  FHIR.Tx.Manager in '..\..\server\FHIR.Tx.Manager.pas',
  FHIR.Tx.MimeTypes in '..\..\server\FHIR.Tx.MimeTypes.pas',
  FHIR.Tx.Operations in '..\..\server\FHIR.Tx.Operations.pas',
  FHIR.Tx.RxNorm in '..\..\server\FHIR.Tx.RxNorm.pas',
  FHIR.Tx.Server in '..\..\server\FHIR.Tx.Server.pas',
  ftx_service in '..\..\library\ftx_service.pas',
  FHIR.Tx.Unii in '..\..\server\FHIR.Tx.Unii.pas',
  FHIR.Tx.Uri in '..\..\server\FHIR.Tx.Uri.pas',
  FHIR.Tx.UsState in '..\..\server\FHIR.Tx.UsState.pas',
  FHIR.Tx.Web in '..\..\server\FHIR.Tx.Web.pas',
  ftx_ucum_base in '..\..\library\Ucum\ftx_ucum_base.pas',
  ftx_ucum_expressions in '..\..\library\Ucum\ftx_ucum_expressions.pas',
  ftx_ucum_handlers in '..\..\library\Ucum\ftx_ucum_handlers.pas',
  fhir_ucum in '..\..\library\ucum\fhir_ucum.pas',
  ftx_ucum_search in '..\..\library\Ucum\ftx_ucum_search.pas',
  ftx_ucum_services in '..\..\library\Ucum\ftx_ucum_services.pas',
  ftx_ucum_tests in '..\..\library\Ucum\ftx_ucum_tests.pas',
  ftx_ucum_validators in '..\..\library\Ucum\ftx_ucum_validators.pas',
  v2_objects in '..\..\library\v2\v2_objects.pas',
  FHIR.Version.Client in '..\..\library\version\FHIR.Version.Client.pas',
  FHIR.Version.Parser in '..\..\library\version\FHIR.Version.Parser.pas',
  fsl_oauth in '..\..\library\web\fsl_oauth.pas',
  fsl_fetcher in '..\..\library\web\fsl_fetcher.pas',
  fsl_graphql in '..\..\library\web\fsl_graphql.pas',
  fhir_htmlgen in '..\..\library\web\fhir_htmlgen.pas',
  fsl_http in '..\..\library\web\fsl_http.pas',
  fsl_rdf in '..\..\library\web\fsl_rdf.pas',
  fsl_websocket in '..\..\library\web\fsl_websocket.pas',
  fsl_twilio in '..\..\library\web\fsl_twilio.pas',
  fsl_wininet in '..\..\library\web\fsl_wininet.pas',
  FHIR.XVersion.ConvBase in '..\..\library\xversion\FHIR.XVersion.ConvBase.pas',
  FHIR.XVersion.Conv_30_40 in '..\..\library\xversion\FHIR.XVersion.Conv_30_40.pas',
  FHIR.XVersion.Convertors in '..\..\library\xversion\FHIR.XVersion.Convertors.pas',
  FHIR.XVersion.Tests in '..\..\library\xversion\FHIR.XVersion.Tests.pas',
  v2_base in '..\..\library\v2\v2_base.pas',
  v2_dictionary in '..\..\library\v2\v2_dictionary_pas',
  v2_dictionary_Compiled in '..\..\library\v2\v2_dictionary_Compiled.pas',
  v2_dictionary_Database in '..\..\library\v2\v2_dictionary_Database.pas',
  v2_dictionary_v21 in '..\..\library\v2\v2_dictionary_v21.pas',
  v2_dictionary_v22 in '..\..\library\v2\v2_dictionary_v22.pas',
  v2_dictionary_v23 in '..\..\library\v2\v2_dictionary_v23.pas',
  v2_dictionary_v231 in '..\..\library\v2\v2_dictionary_v231.pas',
  v2_dictionary_v24 in '..\..\library\v2\v2_dictionary_v24.pas',
  v2_dictionary_v25 in '..\..\library\v2\v2_dictionary_v25.pas',
  v2_dictionary_v251 in '..\..\library\v2\v2_dictionary_v251.pas',
  v2_dictionary_v26 in '..\..\library\v2\v2_dictionary_v26.pas',
  v2_dictionary_v27 in '..\..\library\v2\v2_dictionary_v27.pas',
  v2_engine in '..\..\library\v2\v2_engine.pas',
  v2_javascript in '..\..\library\v2\v2_javascript.pas',
  v2_message in '..\..\library\v2\v2_message.pas',
  v2_protocol in '..\..\library\v2\v2_protocol.pas',
  v2_tests in '..\..\library\v2\v2_tests.pas',
  MarkdownDaringFireball in '..\..\..\markdown\source\MarkdownDaringFireball.pas',
  MarkdownProcessor in '..\..\..\markdown\source\MarkdownProcessor.pas',
  ChakraCore in '..\..\dependencies\chakracore-delphi\ChakraCore.pas',
  Compat in '..\..\dependencies\chakracore-delphi\Compat.pas',
  ChakraCommon in '..\..\dependencies\chakracore-delphi\ChakraCommon.pas',
  ChakraCoreUtils in '..\..\dependencies\chakracore-delphi\ChakraCoreUtils.pas',
  ChakraDebug in '..\..\dependencies\chakracore-delphi\ChakraDebug.pas',
  ChakraCoreClasses in '..\..\dependencies\chakracore-delphi\ChakraCoreClasses.pas',
  MarkdownHTMLEntities in '..\..\..\markdown\source\MarkdownHTMLEntities.pas',
  MarkdownCommonMarkTests in '..\..\..\markdown\tests\MarkdownCommonMarkTests.pas',
  MarkdownCommonMark in '..\..\..\markdown\source\MarkdownCommonMark.pas',
  MarkdownDaringFireballTests in '..\..\..\markdown\tests\MarkdownDaringFireballTests.pas',
  InstanceValidator in '..\..\library\r4\InstanceValidator.pas',
  fhir4_adaptor in '..\..\library\r4\fhir4_adaptor.pas',
  FHIR.Server.ConsentEngine in '..\..\server\FHIR.Server.ConsentEngine.pas',
  FHIR.Server.SimpleConsentEngine in '..\..\server\FHIR.Server.SimpleConsentEngine.pas',
  FHIR.Server.Indexing in '..\..\server\FHIR.Server.Indexing.pas',
  FHIR.Tx.NDC in '..\..\server\FHIR.Tx.NDC.pas',
  fhir4_tests_Objects in '..\..\library\r4\tests\fhir4_tests_Objects.pas',
  FHIR.Server.UsageStats in '..\..\server\FHIR.Server.UsageStats.pas',
  fhir4_tests_Context in '..\..\library\r4\tests\fhir4_tests_Context.pas',
  fsl_npm in '..\..\library\npm\fsl_npm.pas',
  fhir5_adaptor in '..\..\library\r5\fhir5_adaptor.pas',
  fhir5_authmap in '..\..\library\r5\fhir5_authmap.pas',
  fhir5_base in '..\..\library\r5\fhir5_base.pas',
  fhir5_client in '..\..\library\r5\fhir5_client.pas',
  fhir5_common in '..\..\library\r5\fhir5_common.pas',
  fhir5_constants in '..\..\library\r5\fhir5_constants.pas',
  fhir5_context in '..\..\library\r5\fhir5_context.pas',
  fhir5_elementmodel in '..\..\library\r5\fhir5_elementmodel.pas',
  fhir5_enums in '..\..\library\r5\fhir5_enums.pas',
  fhir5_factory in '..\..\library\r5\fhir5_factory.pas',
  fhir5_graphdefinition in '..\..\library\r5\fhir5_graphdefinition.pas',
  fhir5_indexinfo in '..\..\library\r5\fhir5_indexinfo.pas',
  fhir5_javascript in '..\..\library\r5\fhir5_javascript.pas',
  fhir5_json in '..\..\library\r5\fhir5_json.pas',
  fhir5_liquid in '..\..\library\r5\fhir5_liquid.pas',
  fhir5_maputils in '..\..\library\r5\fhir5_maputils.pas',
  fhir5_narrative in '..\..\library\r5\fhir5_narrative.pas',
  fhir5_narrative2 in '..\..\library\r5\fhir5_narrative2.pas',
  fhir5_opbase in '..\..\library\r5\fhir5_opbase.pas',
  fhir5_operations in '..\..\library\r5\fhir5_operations.pas',
  fhir5_organiser in '..\..\library\r5\fhir5_organiser.pas',
  fhir5_parser in '..\..\library\r5\fhir5_parser.pas',
  fhir5_parserBase in '..\..\library\r5\fhir5_parserBase.pas',
  fhir5_patch in '..\..\library\r5\fhir5_patch.pas',
  fhir5_pathengine in '..\..\library\r5\fhir5_pathengine.pas',
  fhir5_pathnode in '..\..\library\r5\fhir5_pathnode.pas',
  fhir5_profiles in '..\..\library\r5\fhir5_profiles.pas',
  fhir5_questionnaire in '..\..\library\r5\fhir5_questionnaire.pas',
  fhir5_resources_admin in '..\..\library\r5\fhir5_resources_admin.pas',
  fhir5_resources in '..\..\library\r5\fhir5_resources.pas',
  fhir5_tags in '..\..\library\r5\fhir5_tags.pas',
  fhir5_turtle in '..\..\library\r5\fhir5_turtle.pas',
  fhir5_types in '..\..\library\r5\fhir5_types.pas',
  fhir5_utilities in '..\..\library\r5\fhir5_utilities.pas',
  fhir5_validator in '..\..\library\r5\fhir5_validator.pas',
  fhir5_xml in '..\..\library\r5\fhir5_xml.pas',
  FHIR.Server.Packages in '..\..\server\FHIR.Server.Packages.pas',
  fsl_npm_spider in '..\..\library\npm\fsl_npm_spider.pas',
  FHIR.Server.Twilio in '..\..\server\FHIR.Server.Twilio.pas',
  FHIR.Server.Covid in '..\..\server\Modules\FHIR.Server.Covid.pas',
  FHIR.Npm.Client in '..\..\library\npm\FHIR.Npm.Client.pas',
  FHIR.Server.WebBase in '..\..\server\FHIR.Server.WebBase.pas',
  FHIR.Server.ClientCacheManager in '..\..\server\FHIR.Server.ClientCacheManager.pas',
  FHIR.Tx.HGVS in '..\..\server\FHIR.Tx.HGVS.pas',
  fhir2_resources_clinical in '..\..\library\r2\fhir2_resources_clinical.pas',
  fhir2_resources_canonical in '..\..\library\r2\fhir2_resources_canonical.pas',
  fhir2_resources_other in '..\..\library\r2\fhir2_resources_other.pas',
  fhir2_resources_admin in '..\..\library\r2\fhir2_resources_admin.pas',
  fhir3_resources_canonical in '..\..\library\r3\fhir3_resources_canonical.pas',
  fhir3_resources_clinical in '..\..\library\r3\fhir3_resources_clinical.pas',
  fhir3_resources_other in '..\..\library\r3\fhir3_resources_other.pas',
  fhir3_resources_admin in '..\..\library\r3\fhir3_resources_admin.pas',
  fhir3_resources_base in '..\..\library\r3\fhir3_resources_base.pas',
  fhir2_resources_base in '..\..\library\r2\fhir2_resources_base.pas',
  fhir4_resources_canonical in '..\..\library\r4\fhir4_resources_canonical.pas',
  fhir4_resources_base in '..\..\library\r4\fhir4_resources_base.pas',
  fhir4_resources_admin in '..\..\library\r4\fhir4_resources_admin.pas',
  fhir4_resources_other in '..\..\library\r4\fhir4_resources_other.pas',
  fhir4_resources_medications in '..\..\library\r4\fhir4_resources_medications.pas',
  fhir4_resources_financial in '..\..\library\r4\fhir4_resources_financial.pas',
  fhir4_resources_clinical in '..\..\library\r4\fhir4_resources_clinical.pas',
  fhir5_resources_canonical in '..\..\library\r5\fhir5_resources_canonical.pas',
  fhir5_resources_base in '..\..\library\r5\fhir5_resources_base.pas',
  fhir5_resources_admin in '..\..\library\r5\fhir5_resources_admin.pas',
  fhir5_resources_other in '..\..\library\r5\fhir5_resources_other.pas',
  fhir5_resources_medications in '..\..\library\r5\fhir5_resources_medications.pas',
  fhir5_resources_financial in '..\..\library\r5\fhir5_resources_financial.pas',
  fhir5_resources_clinical in '..\..\library\r5\fhir5_resources_clinical.pas',
  MarkdownUnicodeUtils in '..\..\..\markdown\source\MarkdownUnicodeUtils.pas',
  CommonTestBase in '..\..\..\markdown\tests\CommonTestBase.pas',
  FHIR.Server.Telnet in '..\..\server\FHIR.Server.Telnet.pas',
  FHIR.Server.Operations in '..\..\Server\FHIR.Server.Operations.pas',
  FHIR.Server.Kernel.Testing in '..\..\server\FHIR.Server.Kernel.Testing.pas',
  fsl_testing in '..\..\library\support\fsl_testing.pas';

var
  runner : ITestRunner;
  results : IRunResults;
  logger : ITestLogger;
  nunitLogger : ITestLogger;
  s : String;
begin
{$IFDEF TESTINSIGHT}
  TestInsight.DUnitX.RunRegisteredTests;
  exit;
{$ENDIF}
  try
    //Check command line options, will exit if invalid
    TDUnitX.CheckCommandLine;
    //Create the test runner
    runner := TDUnitX.CreateRunner;
    //Tell the runner to use RTTI to find Fixtures
    runner.UseRTTI := True;
    //tell the runner how we will log things
    //Log to the console window
    logger := TDUnitXConsoleLogger.Create(true);
    runner.AddLogger(logger);
    //Generate an NUnit compatible XML File
    nunitLogger := TDUnitXXMLNUnitFileLogger.Create(TDUnitX.Options.XMLOutputFile);
    runner.AddLogger(nunitLogger);
    runner.FailsOnNoAsserts := False; //When true, Assertions must be made during tests;

    //Run tests
    results := runner.Execute;
    if not results.AllPassed then
      System.ExitCode := EXIT_ERRORS;

    {$IFNDEF CI}
    //We don't want this happening when running under CI.
    if TDUnitX.Options.ExitBehavior = TDUnitXExitBehavior.Pause then
    begin
      System.Write('Done.. press <Enter> key to quit.');
      System.Readln;
    end;
    {$ENDIF}
  except
    on E: Exception do
      System.Writeln(E.ClassName, ': ', E.Message);
  end;
end.
