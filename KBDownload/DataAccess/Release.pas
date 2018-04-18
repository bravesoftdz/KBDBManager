unit Release;

interface

uses
  SysUtils, Classes, DataServices, FireDAC.Stan.Error, FireDAC.UI.Intf,
  FireDAC.Phys.Intf, FireDAC.Stan.Def, FireDAC.Stan.Pool, FireDAC.Stan.Async,
  FireDAC.Phys, FireDAC.Phys.MSSQL, FireDAC.Comp.Client, FireDAC.Stan.Param,
  FireDAC.DatS,  FireDAC.DApt.Intf, FireDAC.DApt, DB, DBLoginSettings,
  CommonFunctions, FireDAC.Stan.Option, System.Generics.Collections;

type
  TRelease = class
    protected
      FReleaseID: Integer;
      FCreated: TDateTime;
      FModified: TDateTime;
      FModifier: String;
      FEmdbVersion: String;
      FKBPackageUID: String;
      FCoreVersion: String;
    public
      constructor Create; overload; virtual;
      constructor Create(ARelease: TRelease); overload; virtual;
      procedure Save;
      property ReleaseID: Integer read FReleaseID write FReleaseID;
      property Created: TDateTime read FCreated write FCreated;
      property Modified: TDateTime read FModified write FModified;
      property Modifier: String read FModifier write FModifier;
      property EmdbVersion: String read FEmdbVersion write FEmdbVersion;
      property KBPackageUID: String read FKBPackageUID write FKBPackageUID;
      property CoreVersion: String read FCoreVersion write FCoreVersion;
  end;

  TReleaseList = class
    protected
      FList: TObjectList<TRelease>;
      function GetCount: Integer;
      function GetRelease(AIndex: Integer): TRelease;
      class function GetInitialSQL: TStringList;
      class function CreateRelease(ADataSet: TDataSet): TRelease;
    public
      constructor Create; overload; virtual;
      constructor Create(AReleaseList: TReleaseList); overload; virtual;
      destructor Destroy; override;
      procedure Clear;
      procedure Add(ARelease: TRelease);
      class function GetAll: TReleaseList;
      class function GetSingleInstance(AReleaseID: Integer): TRelease;
      property Count: Integer read GetCount;
      property Release[AIndex: Integer]: TRelease read GetRelease; default; 
  end;

implementation

constructor TRelease.Create;
begin
  FReleaseID := 0;
  FCreated := -1.00;
  FModified := -1.00;
  FModifier := '';
  FEmdbVersion := '';
  KBPackageUID := '';
end;

constructor TRelease.Create(ARelease: TRelease);
begin
  FReleaseID := ARelease.ReleaseID;
  FCreated := ARelease.Created;
  FModified := ARelease.Modified;
  FModifier := ARelease.Modifier;
  FEmdbVersion := ARelease.EmdbVersion;
  FKBPackageUID := ARelease.KBPackageUID;
end;

procedure TRelease.Save;
var
  LConnection: TFDConnection;
  LSettings: TDBLoginSettings;
  LUpsert: TFDStoredProc;
begin
  LSettings := TDBLoginSettings.Create;
  try
    LSettings.Load;
    LConnection := TDataServices.GetConnection('KBDL', LSettings.UserName, LSettings.Password, LSettings.Database, LSettings.Host, LSettings.WindowsAuthentication);
  finally
    LSettings.Free;
  end;

  try
    LUpsert := TFDStoredProc.Create(nil);
    try
      LUpsert.FetchOptions.Items := LUpsert.FetchOptions.Items - [fiMeta];
      LUpsert.StoredProcName := 'dbo.UpdateRelease';
      LUpsert.Params.Clear;
      LUpsert.Params.Add('@RETURN_VALUE', ftInteger, -1, ptResult);
      LUpsert.Params.Add('@ReleaseID', ftInteger, -1, ptInput);
      LUpsert.Params.Add('@Modifier', ftString, 50, ptInput);
      LUpsert.Params.Add('@EmdbVersion', ftString, 20, ptInput);
      LUpsert.Params.Add('@KBPackageUID', ftGuid, 16, ptInput);
      LUpsert.Params.Add('@NextReleaseID', ftInteger, -1, ptOutput);

      LUpsert.Connection := LConnection;
      LConnection.Connected := TRUE;

      LUpsert.Params.ParamByName('@ReleaseID').AsInteger := FReleaseID;
      LUpsert.Params.ParamByName('@Modifier').AsString := FModifier;
      LUpsert.Params.ParamByName('@EmdbVersion').AsString := FEmdbVersion;
      LUpsert.Params.ParamByName('@KBPackageUID').Value := FKBPackageUID;

      LUpsert.ExecProc;

      FReleaseID := LUpsert.Params.ParamByName('@NextReleaseID').AsInteger;
    finally
      LConnection.Connected := FALSE;
      LUpsert.Free;
    end;
  finally
    LConnection.Free;
  end;
end;

function TReleaseList.GetCount: Integer;
begin
  Result := FList.Count;
end;

function TReleaseList.GetRelease(AIndex: Integer): TRelease;
begin
  Result := FList[AIndex];
end;

class function TReleaseList.GetInitialSQL: TStringList;
begin
  Result := TStringList.Create;
  Result.Add('Select Release.ReleaseID, ');
  Result.Add('Release.Created, ');
  Result.Add('Release.Modified, ');
  Result.Add('Release.Modifier, ');
  Result.Add('Release.EmdbVersion, ');
  Result.Add('Release.KBPackageUID, ');
  Result.Add('KBPackage.CoreVersion ');
  Result.Add('From Release ');
  Result.Add('Inner Join KBPackage on KBPackage.KBPackageUID = Release.KBPackageUID ');
end;

class function TReleaseList.CreateRelease(ADataSet: TDataSet): TRelease;
begin
  Result := TRelease.Create;
  Result.ReleaseID := ADataSet.Fields[0].AsInteger;
  Result.Created := ADataSet.Fields[1].AsDateTime;
  Result.Modified := ADataSet.Fields[2].AsDateTime;
  Result.Modifier := ADataSet.Fields[3].AsString;
  Result.EmdbVersion := ADataSet.Fields[4].AsString;
  Result.KBPackageUID := ADataSet.Fields[5].AsString;
  Result.CoreVersion := ADataSet.Fields[6].AsString;
end;

constructor TReleaseList.Create;
begin
  inherited Create;
  FList := TObjectList<TRelease>.Create(TRUE);
end;

constructor TReleaseList.Create(AReleaseList: TReleaseList);
var
  i: Integer;
begin
  inherited Create;
  FList := TObjectList<TRelease>.Create(TRUE);
  for i := 0 to (AReleaseList.Count - 1) do 
    FList.Add(TRelease.Create(AReleaseList[i]));
end;

destructor TReleaseList.Destroy;
begin
  FList.Free;
  inherited Destroy;
end;

procedure TReleaseList.Clear;
begin
  FList.Clear;
end;

procedure TReleaseList.Add(ARelease: TRelease);
begin
  FList.Add(ARelease);
end;

class function TReleaseList.GetSingleInstance(AReleaseID: Integer): TRelease;
var
  LConnection: TFDConnection;
  LQuery: TFDQuery;
  LSQL: TStrings;
  i: Integer;
  LSettings: TDBLoginSettings;
begin
  Result := nil;
  LSettings := TDBLoginSettings.Create;
  try
    LSettings.Load;
    LConnection := TDataServices.GetConnection('KBDL', LSettings.UserName, LSettings.Password, LSettings.Database, LSettings.Host, LSettings.WindowsAuthentication);
  finally
    LSettings.Free;
  end;
  try
    LQuery := TDataServices.GetQuery(LConnection);
    try
      LSQL := GetInitialSQL;
      LSQL.Add('Where Release.ReleaseID=' + IntToStr(AReleaseID) + ' ');
      try
        for i := 0 to (LSQL.Count - 1) do
          LQuery.SQL.Add(LSQL[i]);
      finally
        LSQL.Free;
      end;

      LConnection.Open;
      LQuery.Open;
      if not LQuery.IsEmpty then
      begin
        LQuery.First;
        Result := CreateRelease(LQuery);
      end;
    finally
      LQuery.Close;
      LQuery.Free;
    end;
  finally
    LConnection.Close;
    LConnection.Free;
  end;
end;

class function TReleaseList.GetAll: TReleaseList;
var
  LConnection: TFDConnection;
  LQuery: TFDQuery;
  LSQL: TStrings;
  i: Integer;
  LSettings: TDBLoginSettings;
  LRecord: TRelease;
begin
  Result := nil;
  LRecord := nil;
  LSettings := TDBLoginSettings.Create;
  try
    LSettings.Load;
    LConnection := TDataServices.GetConnection('KBDL', LSettings.UserName, LSettings.Password, LSettings.Database, LSettings.Host, LSettings.WindowsAuthentication);
  finally
    LSettings.Free;
  end;
  try
    LQuery := TDataServices.GetQuery(LConnection);
    try
      LSQL := GetInitialSQL;
      try
        for i := 0 to (LSQL.Count - 1) do
          LQuery.SQL.Add(LSQL[i]);
      finally
        LSQL.Free;
      end;

      LConnection.Open;
      LQuery.Open;
      if not LQuery.IsEmpty then
      begin
        Result := TReleaseList.Create;
        LQuery.First;
        while not LQuery.EOF do
        begin
          LRecord := CreateRelease(LQuery);
          Result.Add(LRecord);
          LQuery.Next;
        end;
      end;
    finally
      LQuery.Close;
      LQuery.Free;
    end;
  finally
    LConnection.Close;
    LConnection.Free;
  end;
end;

end.
