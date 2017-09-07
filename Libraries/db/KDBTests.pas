unit KDBTests;

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


{$DEFINE DIFF}

interface

Uses
  SysUtils, Classes,
  DateSupport, TextUtilities,
  KDBDialects,
  KDBManager, KDBOdbc, KDBSQLite, SQLite3, SQLite3Wrap,
  DUnitX.TestFramework;

Type
  [TextFixture]
  TKDBTests = Class (TObject)
  private
    procedure test(manager : TKDBManager);
    procedure testSQLite();
  Published
//    {[TestCase] }procedure TestMSSQL;
    [TestCase] procedure TestMySQL;
//    {[TestCase] }procedure TestMySQLMaria;
    [TestCase] procedure TestSQLite;
  End;

implementation

function BlobIsSame(l, r : TBytes) : boolean;
var
  i : integer;
begin
  if length(l) <> length(r) then
    exit(false);
  result := true;
  for i := 0 to length(l) - 1 do
    if l[i] <> r[i] then
      exit(false);
end;


function isSame(l, r : Double) : boolean;
var
  d : Double;
begin
  d := abs(l-r);
  result := d < 0.00001;
end;

{ TKDBTests }

procedure TKDBTests.test(manager: TKDBManager);
var
  conn : TKDBConnection;
  d, od : TDateTimeEx;
  b : TBytes;
  i64 : Int64;
  md : TKDBMetaData;
begin
  d := TDateTimeEx.makeLocal(dtpSec);
  {$IFDEF MACOS}
  b := FileToBytes(IncludeTrailingPathDelimiter(ExtractFilePath(paramstr(0)))+'libcgsqlite3.dylib');
  {$ELSE}
  b := FileToBytes('C:\work\fhirserver\Libraries\db\KDBTests.pas');
  {$ENDIF}
  i64 := MaxInt;
  i64 := i64+2;

  conn := manager.GetConnection('test');
  try
    md := conn.FetchMetaData;
    try
      if md.HasTable('TestTable') then
        conn.DropTable('TestTable');
    finally
      md.Free;
    end;

    conn.ExecSQL('CREATE TABLE TestTable ( '+#13#10+
         ' TestKey '+DBKeyType(conn.owner.platform)+' '+ColCanBeNull(conn.owner.platform, False)+', '+#13#10+
         ' Name nchar(255) '+ColCanBeNull(conn.owner.platform, False)+', '+#13#10+
         ' Number int '+ColCanBeNull(conn.owner.platform, True)+', '+#13#10+
         ' BigNumber bigint '+ColCanBeNull(conn.owner.platform, True)+', '+#13#10+
         ' FloatNumber float '+ColCanBeNull(conn.owner.platform, True)+', '+#13#10+
         ' Instant '+DBDateTimeType(conn.owner.platform)+' '+ColCanBeNull(conn.owner.platform, False)+', '+#13#10+
         ' Content '+DBBlobType(conn.owner.platform)+' '+ColCanBeNull(conn.owner.platform, true)+', '+#13#10+
         PrimaryKeyType(conn.owner.Platform, 'PK_TestTable', 'TestKey')+') '+CreateTableInfo(conn.owner.platform));
    conn.ExecSQL('Create Unique INDEX SK_TestTable_Index ON TestTable (Name, Number)');

    try
      md := conn.FetchMetaData;
      try
        Assert.IsTrue(md.HasTable('TestTable'))
      finally
        md.Free;
      end;
      Assert.IsTrue(conn.CountSQL('Select count(*) from TestTable') = 0);

      conn.ExecSQL('Insert into TestTable (TestKey, Name, Number, BigNumber, FloatNumber, Instant) values (1, ''a name'', 2, '+IntToStr(i64)+', 3.2, '+DBGetDate(manager.Platform)+')');
      conn.sql := 'Insert into TestTable (TestKey, Name, Number, BigNumber, FloatNumber, Instant, Content) values (:k, :n, :i, :bi, :d, :ts, :c)';
      conn.Prepare;
      conn.BindKey('k', 2);
      conn.BindString('n', 'Name 2');
      conn.BindInteger('i', 3);
      conn.BindInt64('bi', -i64);
      conn.BindDouble('d', 3.4);
      conn.BindDateTimeEx('ts', d);
      conn.BindBlob('c', b);
      conn.Execute;
      conn.Terminate;

      Assert.IsTrue(conn.CountSQL('Select count(*) from TestTable where  TestKey = 1') = 1);
      Assert.IsTrue(conn.CountSQL('Select count(*) from TestTable where  TestKey = 0') = 0);

      conn.sql := 'Select * from TestTable';
      conn.Prepare;
      conn.Execute;
      conn.FetchNext;
      assert.IsTrue(Conn.ColIntegerByName['TestKey'] = 1);
      assert.IsTrue(Conn.ColStringByName['Name'] = 'a name');
      assert.IsTrue(Conn.ColIntegerByName['Number'] = 2);
      assert.IsTrue(Conn.ColInt64ByName['BigNumber'] = i64);
      assert.IsTrue(isSame(Conn.ColDoubleByName['FloatNumber'], 3.2));
      assert.IsTrue(TSToDateTime(Conn.ColTimestampByName['Instant']) < now);
      assert.IsTrue(TSToDateTime(Conn.ColTimestampByName['Instant']) > now - DATETIME_MINUTE_ONE);
      od := Conn.ColDateTimeExByName['Instant'];
      assert.IsTrue(length(Conn.ColBlobByName['Content']) = 0);
      assert.IsTrue(Conn.ColNullByName['Content']);

      conn.FetchNext;
      assert.IsTrue(Conn.ColIntegerByName['TestKey'] = 2);
      assert.IsTrue(Conn.ColStringByName['Name'] = 'Name 2');
      assert.IsTrue(Conn.ColIntegerByName['Number'] = 3);
      assert.IsTrue(Conn.ColInt64ByName['BigNumber'] = -i64);
      assert.IsTrue(isSame(Conn.ColDoubleByName['FloatNumber'], 3.4));
      assert.IsTrue(Conn.ColDateTimeExByName['Instant'].fixPrecision(dtpSec).equal(d));
       assert.IsTrue(BlobIsSame(Conn.ColBlobByName['Content'], b));
      conn.Terminate;

      sleep(1000);

      conn.ExecSQL('Update TestTable set Name = ''3rd Name'', Number = 3, BigNumber = '+IntToStr(-i64)+', FloatNumber = 3.1, Instant = '+DBGetDate(manager.Platform)+' where TestKey = 1');
      conn.sql := 'Update TestTable set Name = :n, Number = :i, BigNumber = :bi, FloatNumber = :d, Instant = :ts, Content = :c where TestKey = :k';
      conn.Prepare;
      conn.BindKey('k', 2);
      conn.BindString('n', 'Name 4');
      conn.BindInteger('i', -4);
      conn.BindInt64('bi', i64);
      conn.BindDouble('d', 3.01);
      conn.BindDateTimeEx('ts', od);
      conn.BindNull('c');
      conn.Execute;
      conn.Terminate;

      conn.sql := 'Select * from TestTable';
      conn.Prepare;
      conn.Execute;
      conn.FetchNext;
      assert.IsTrue(Conn.ColIntegerByName['TestKey'] = 1);
      assert.IsTrue(Conn.ColStringByName['Name'] = '3rd Name');
      assert.IsTrue(Conn.ColIntegerByName['Number'] = 3);
      assert.IsTrue(Conn.ColInt64ByName['BigNumber'] = -i64);
      assert.IsTrue(isSame(Conn.ColDoubleByName['FloatNumber'], 3.1));
      assert.IsTrue(Conn.ColDateTimeExByName['Instant'].after(od, false));
      assert.IsTrue(length(Conn.ColBlobByName['Content']) = 0);
      assert.IsTrue(Conn.ColNullByName['Content']);

      conn.FetchNext;
      assert.IsTrue(Conn.ColIntegerByName['TestKey'] = 2);
      assert.IsTrue(Conn.ColStringByName['Name'] = 'Name 4');
      assert.IsTrue(Conn.ColIntegerByName['Number'] = -4);
      assert.IsTrue(Conn.ColInt64ByName['BigNumber'] = i64);
      assert.IsTrue(isSame(Conn.ColDoubleByName['FloatNumber'], 3.01));
      assert.IsTrue(Conn.ColDateTimeExByName['Instant'].equal(od));
      assert.IsTrue(length(Conn.ColBlobByName['Content']) = 0);
      assert.IsTrue(Conn.ColNullByName['Content']);
      conn.Terminate;

      conn.ExecSQL('Delete from TestTable where TestKey = 1');
      conn.sql := 'Delete from TestTable where TestKey = :k';
      conn.Prepare;
      conn.BindKey('k', 2);
      conn.Execute;
      conn.Terminate;

      Assert.IsTrue(conn.CountSQL('Select count(*) from TestTable') = 0);

    finally
      conn.DropTable('TestTable');
    end;
    md := conn.FetchMetaData;
    try
      Assert.Isfalse(md.HasTable('TestTable'))
    finally
      md.Free;
    end;

    conn.Release;
  except
    on e:exception do
    begin
      Assert.IsTrue(false, e.message);
      conn.Error(e);
    end;
  end;
end;

//procedure TKDBTests.TestMSSQL;
//var
//  db : TKDBManager;
//begin
//  db := TKDBOdbcManager.create('test', 8, 200, 'SQL Server', 'localhost', 'test', '', '');
//  try
//    test(db);
//  finally
//    db.Free;
//  end;
//end;
//
procedure TKDBTests.TestMySQL;
var
  db : TKDBManager;
begin
  db := TKDBOdbcManager.create('test', 8, 0, 'MySQL ODBC 5.2 Unicode Driver', 'localhost', 'test', 'test', 'test');
  try
    test(db);
  finally
    db.Free;
  end;
end;

procedure TKDBTests.testSQLite;
var
  DB: TSQLite3Database;
  Stmt: TSQLite3Statement;
  IDs: array[1..6] of Integer;
begin
  // Delete database if it already exists
  DeleteFile('artists.db');

  // Create database and fill it with example data
  DB := TSQLite3Database.Create;
  try
    DB.Open('artists.db');

    // Create table "artists"
    DB.Execute('CREATE TABLE artists (name TEXT, born REAL, died REAL)');

    // Fill the table with artists
    Stmt := DB.Prepare('INSERT INTO artists (name, born, died) VALUES (:p1, :p2, :p3)');
    try
      Stmt.BindText  (':p1', 'Leonardo da Vinci');
      Stmt.BindDouble(':p2', EncodeDate(1452, 4, 15));
      Stmt.BindDouble(':p3', EncodeDate(1519, 5, 2));

      Stmt.StepAndReset; // StepAndReset executes a prepared statement
                         // and resets it so we can reuse it again

      IDs[1] := DB.LastInsertRowID; // Save newly added artist's ID to use it
                                    // when filling "paintings" table below

      Stmt.BindText  (1, 'Raphael');
      Stmt.BindDouble(2, EncodeDate(1483, 3, 28));
      Stmt.BindDouble(3, EncodeDate(1520, 4, 6));
      Stmt.StepAndReset;
      IDs[2] := DB.LastInsertRowID;

      Stmt.BindText  (1, 'Arkhip Kuindzhi');
      Stmt.BindDouble(2, EncodeDate(1842, 1, 27));
      Stmt.BindDouble(3, EncodeDate(1898, 7, 24));
      Stmt.StepAndReset;
      IDs[3] := DB.LastInsertRowID;

      Stmt.BindText  (1, 'Nicholas Roerich');
      Stmt.BindDouble(2, EncodeDate(1874, 10, 9));
      Stmt.BindDouble(3, EncodeDate(1947, 12, 13));
      Stmt.StepAndReset;
      IDs[4] := DB.LastInsertRowID;

      Stmt.BindText  (1, 'Ivan Aivazovsky');
      Stmt.BindDouble(2, EncodeDate(1817, 7, 29));
      Stmt.BindDouble(3, EncodeDate(1900, 5, 5));
      Stmt.StepAndReset;
      IDs[5] := DB.LastInsertRowID;

      Stmt.BindText  (1, 'Ivan Shishkin');
      Stmt.BindDouble(2, EncodeDate(1832, 1, 25));
      Stmt.BindDouble(3, EncodeDate(1898, 3, 20));
      Stmt.StepAndReset;
      IDs[6] := DB.LastInsertRowID;
    finally
      Stmt.Free;
    end;

    // Create table "paintings"
    DB.Execute('CREATE TABLE paintings (title TEXT, year INTEGER, artist INTEGER)');

    // Fill the table with paintings info
    Stmt := DB.Prepare('INSERT INTO paintings (title, year, artist) VALUES (?, ?, ?)');
    try
      // Leonardo da Vinci
      Stmt.BindText(1, 'The Virgin and Child with St. Anne');
      Stmt.BindInt (2, 1508);
      Stmt.BindInt (3, IDs[1]);
      Stmt.StepAndReset;

      Stmt.BindText(1, 'Mona Lisa');
      Stmt.BindInt (2, 1519);
      Stmt.BindInt (3, IDs[1]);
      Stmt.StepAndReset;

      // Raphael
      Stmt.BindText(1, 'Sistine Madonna');
      Stmt.BindInt (2, 1514);
      Stmt.BindInt (3, IDs[2]);
      Stmt.StepAndReset;

      Stmt.BindText(1, 'Transfiguration');
      Stmt.BindInt (2, 1520);
      Stmt.BindInt (3, IDs[2]);
      Stmt.StepAndReset;

      // Arkhip Kuindzhi
      Stmt.BindText(1, 'After a rain');
      Stmt.BindInt (2, 1879);
      Stmt.BindInt (3, IDs[3]);
      Stmt.StepAndReset;

      Stmt.BindText(1, 'Elbrus');
      Stmt.BindInt (2, 1895);
      Stmt.BindInt (3, IDs[3]);
      Stmt.StepAndReset;

      // Nicholas Roerich
      Stmt.BindText(1, 'To Kailas. Lahul');
      Stmt.BindInt (2, 1932);
      Stmt.BindInt (3, IDs[4]);
      Stmt.StepAndReset;

      Stmt.BindText(1, 'Krishna');
      Stmt.BindInt (2, 1929);
      Stmt.BindInt (3, IDs[4]);
      Stmt.StepAndReset;

      // Ivan Aivazovsky
      Stmt.BindText(1, 'The Mary Caught in a Storm');
      Stmt.BindInt (2, 1892);
      Stmt.BindInt (3, IDs[5]);
      Stmt.StepAndReset;

      Stmt.BindText(1, 'Brig "Mercury" Attacked by Two Turkish Ships');
      Stmt.BindInt (2, 1892);
      Stmt.BindInt (3, IDs[5]);
      Stmt.StepAndReset;

      // Ivan Shishkin
      Stmt.BindText(1, 'Morning in a Pine Forest');
      Stmt.BindInt (2, 1889);
      Stmt.BindInt (3, IDs[6]);
      Stmt.StepAndReset;

      Stmt.BindText(1, 'Wood Distances');
      Stmt.BindInt (2, 1884);
      Stmt.BindInt (3, IDs[6]);
      Stmt.StepAndReset;
    finally
      Stmt.Free;
    end;

  finally
    DB.Free;
  end;
end;

procedure TKDBTests.TestSQLite;
var
  db : TKDBManager;
begin
//  testSQLite;
  DeleteFile('c:\temp\sql.db');
  db := TKDBSQLiteManager.create('test', 'c:\temp\sql.db', true);
  try
    test(db);
  finally
    db.Free;
  end;
end;

//procedure TKDBTests.TestMySQLMaria;
//var
//  db : TKDBManager;
//begin
//  db := TKDBOdbcManager.create('test', 8, 0, 'MariaDB ODBC 3.0 Driver', 'localhost', 'test', 'root', 'h_Erp3ChJ![~C7~oL|61');
//  try
//    test(db);
//  finally
//    db.Free;
//  end;
//end;
//



initialization
  TDUnitX.RegisterTestFixture(TKDBTests);
end.
