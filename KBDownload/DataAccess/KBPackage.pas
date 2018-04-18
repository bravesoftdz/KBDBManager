unit KBPackage;

interface

uses
  SysUtils, Classes, DataServices, FireDAC.Stan.Error, FireDAC.UI.Intf,
  FireDAC.Phys.Intf, FireDAC.Stan.Def, FireDAC.Stan.Pool, FireDAC.Stan.Async,
  FireDAC.Phys, FireDAC.Phys.MSSQL, FireDAC.Comp.Client, FireDAC.Stan.Param,
  FireDAC.Stan.Intf, FireDAC.DatS,  FireDAC.DApt.Intf, FireDAC.DApt, DB,
  DBLoginSettings, CommonFunctions, FireDAC.Stan.Option,
  System.Generics.Collections;

type
  TKBPackage = class
    protected
      FKBPackageUID: String;
      FCreated: TDateTime;
      FModified: TDateTime;
      FModifier: String;
      FName: String;
      FCoreVersion: String;
      FFileContents: TMemoryStream;
    public
      constructor Create; overload; virtual;
      constructor Create(AKBPackage: TKBPackage); overload; virtual;
      destructor Destroy; override;
      procedure LoadFileContents;
      procedure Save;
      property KBPackageUID: String read FKBPackageUID write FKBPackageUID;
      property Created: TDateTime read FCreated write FCreated;
      property Modified: TDateTime read FModified write FModified;
      property Modifier: String read FModifier write FModifier;
      property Name: String read FName write FName;
      property CoreVersion: String read FCoreVersion write FCoreVersion;
      property FileContents: TMemoryStream read FFileContents;
  end;

  TKBPackageList = class
    protected
      FList: TObjectList<TKBPackage>;
      function GetCount: Integer;
      function GetKBPackage(AIndex: Integer): TKBPackage;
      class function GetInitialSQL: TStringList;
      class function CreateKBPackage(ADataSet: TDataSet): TKBPackage;
    public
      constructor Create; overload; virtual;
      constructor Create(AKBPackageList: TKBPackageList); overload; virtual;
      destructor Destroy; override;
      procedure Clear;
      procedure Add(AKBPackage: TKBPackage);
      class function GetAll(AOrderBy: String = ''): TKBPackageList;
      property Count: Integer read GetCount;
      property KBPackage[AIndex: Integer]: TKBPackage read GetKBPackage; default;
  end;

implementation

constructor TKBPackage.Create;
begin
  FKBPackageUID := '';
  FCreated := -1.00;
  FModified := -1.00;
  FModifier := '';
  FName := '';
  FCoreVersion := '';
  FFileContents := TMemoryStream.Create;
end;

constructor TKBPackage.Create(AKBPackage: TKBPackage);
begin
  FKBPackageUID := AKBPackage.KBPackageUID;
  FCreated := AKBPackage.Created;
  FModified := AKBPackage.Modified;
  FModifier := AKBPackage.Modifier;
  FName := AKBPackage.Name;
  FCoreVersion := AKBPackage.CoreVersion;
  FFileContents := TMemoryStream.Create;
  FFileContents.LoadFromStream(AKBPackage.FileContents);
end;

destructor TKBPackage.Destroy;
begin
  FFileContents.Free;
  inherited Destroy;
end;

procedure TKBPackage.LoadFileContents;
var
  LConnection: TFDConnection;
  LQuery: TFDQuery;
  LSettings: TDBLoginSettings;
  LStream: TStream;
begin
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
      LQuery.SQL.Add('Select FileContents From KBPackage Where KBPackageUID=:UID');
      LQuery.Params.Add('UID', ftGuid, 16, ptInput);
      LQuery.Params[0].Value := FKBPackageUID;
      LConnection.Open;
      LQuery.Open;
      if not LQuery.IsEmpty then
      begin
        LStream := LQuery.CreateBlobStream(LQuery.Fields[0], bmRead);
        try
          FFileContents.Clear;
          FFileContents.Seek(0,0);
          FFileContents.LoadFromStream(LStream);
        finally
          LStream.Free;
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

procedure TKBPackage.Save;
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
      LUpsert.StoredProcName := 'dbo.UpdateKBPackage';
      LUpsert.Params.Clear;
      LUpsert.Params.Add('@RETURN_VALUE', ftInteger, -1, ptResult);
      LUpsert.Params.Add('@KBPackageUID', ftGuid, 16, ptInput);
      LUpsert.Params.Add('@Modifier', ftString, 50, ptInput);
      LUpsert.Params.Add('@Name', ftString, 50, ptInput);
      LUpsert.Params.Add('@CoreVersion', ftString, 20, ptInput);
      LUpsert.Params.Add('@FileContents', ftBlob, -1, ptInput);

      LUpsert.Connection := LConnection;
      LConnection.Connected := TRUE;

      if '' = Trim(FKBPackageUID) then
        LUpsert.Params.ParamByName('@KBPackageUID').Clear
      else
        LUpsert.Params.ParamByName('@KBPackageUID').Value := FKBPackageUID;
      LUpsert.Params.ParamByName('@Modifier').AsString := FModifier;
      LUpsert.Params.ParamByName('@Name').AsString := FName;
      LUpsert.Params.ParamByName('@CoreVersion').AsString := FCoreVersion;
      FFileContents.Seek(0, 0);
      LUpsert.Params.ParamByName('@FileContents').SetStream(FFileContents, ftBlob, FALSE);
      LUpsert.ExecProc;

    finally
      LConnection.Connected := FALSE;
      LUpsert.Free;
    end;
  finally
    LConnection.Free;
  end;
end;

function TKBPackageList.GetCount: Integer;
begin
  Result := FList.Count;
end;

function TKBPackageList.GetKBPackage(AIndex: Integer): TKBPackage;
begin
  Result := FList[AIndex];
end;

class function TKBPackageList.GetInitialSQL: TStringList;
begin
  Result := TStringList.Create;
  Result.Add('Select KBPackage.KBPackageUID, ');
  Result.Add('KBPackage.Created, ');
  Result.Add('KBPackage.Modified, ');
  Result.Add('KBPackage.Modifier, ');
  Result.Add('KBPackage.Name, ');
  Result.Add('KBPackage.CoreVersion ');
  Result.Add('From KBPackage ');
end;

class function TKBPackageList.CreateKBPackage(ADataSet: TDataSet): TKBPackage;
begin
  Result := TKBPackage.Create;
  Result.KBPackageUID := ADataSet.Fields[0].AsString;
  Result.Created := ADataSet.Fields[1].AsDateTime;
  Result.Modified := ADataSet.Fields[2].AsDateTime;
  Result.Modifier := ADataSet.Fields[3].AsString;
  Result.Name := ADataSet.Fields[4].AsString;
  Result.CoreVersion := ADataSet.Fields[5].AsString;
end;

constructor TKBPackageList.Create;
begin
  inherited Create;
  FList := TObjectList<TKBPackage>.Create(TRUE);
end;

constructor TKBPackageList.Create(AKBPackageList: TKBPackageList);
var
  i: Integer;
begin
  inherited Create;
  FList := TObjectList<TKBPackage>.Create(TRUE);
  for i := 0 to (AKBPackageList.Count - 1) do 
    FList.Add(TKBPackage.Create(AKBPackageList[i]));
end;

destructor TKBPackageList.Destroy;
begin
  FList.Free;
  inherited Destroy;
end;

procedure TKBPackageList.Clear;
begin
  FList.Clear;
end;

procedure TKBPackageList.Add(AKBPackage: TKBPackage);
begin
  FList.Add(AKBPackage);
end;

class function TKBPackageList.GetAll(AOrderBy: String = ''): TKBPackageList;
var
  LConnection: TFDConnection;
  LQuery: TFDQuery;
  LSQL: TStrings;
  i: Integer;
  LSettings: TDBLoginSettings;
  LRecord: TKBPackage;
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
        if not String.IsNullOrWhitespace(AOrderBy) then
        begin
          LQuery.SQL.Add(AOrderBy);
        end;
      finally
        LSQL.Free;
      end;

      LConnection.Open;
      LQuery.Open;
      if not LQuery.IsEmpty then
      begin
        Result := TKBPackageList.Create;
        LQuery.First;
        while not LQuery.EOF do
        begin
          LRecord := CreateKBPackage(LQuery);
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
