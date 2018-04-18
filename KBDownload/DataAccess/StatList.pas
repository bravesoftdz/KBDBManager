unit StatList;

interface

uses
  SysUtils, Classes, DataServices, FireDAC.Stan.Error, FireDAC.UI.Intf,
  FireDAC.Phys.Intf, FireDAC.Stan.Def, FireDAC.Stan.Pool, FireDAC.Stan.Async,
  FireDAC.Phys, FireDAC.Phys.MSSQL, FireDAC.Comp.Client, FireDAC.Stan.Param,
  FireDAC.DatS,  FireDAC.DApt.Intf, FireDAC.DApt, DB, DBLoginSettings,
  CommonFunctions, FireDAC.Stan.Option, System.Generics.Collections;

type
  TStatList = class
    protected
      FStatListID: Integer;
      FCreated: TDateTime;
      FModified: TDateTime;
      FModifier: String;
      FCurKBDownloads: Integer;
      //FDownloads7Days: Integer;
      //FDownloads1Day: Integer;
      //FDownloads1Hour: Integer;
    public
      constructor Create; overload; virtual;
      constructor Create(AStatList: TStatList); overload; virtual;
      procedure Save;
      property StatListID: Integer read FStatListID write FStatListID;
      property Created: TDateTime read FCreated write FCreated;
      property Modified: TDateTime read FModified write FModified;
      property Modifier: String read FModifier write FModifier;
      property CurKBDownloads: Integer read FCurKBDownloads write FCurKBDownloads;
      //property Downloads7Days: Integer read FDownloads7Days write FDownloads7Days;
      //property Downloads1Day: Integer read FDownloads1Day write FDownloads1Day;
      //property Downloads1Hour: Integer read FDownloads1Hour write FDownloads1Hour;
  end;

  TStatListList = class
    protected
      FList: TObjectList<TStatList>;
      function GetCount: Integer;
      function GetStatList(AIndex: Integer): TStatList;
      class function GetInitialSQL: TStringList;
      class function CreateStatList(ADataSet: TDataSet): TStatList;
    public
      constructor Create; overload; virtual;
      constructor Create(AStatListList: TStatListList); overload; virtual;
      destructor Destroy; override;
      procedure Clear;
      procedure Add(AStatList: TStatList);
      class function GetAll: TStatListList;
      property Count: Integer read GetCount;
      property StatList[AIndex: Integer]: TStatList read GetStatList; default; 
  end;

implementation

constructor TStatList.Create;
begin
  FStatListID := 0;
  FCreated := -1.00;
  FModified := -1.00;
  FModifier := '';
  FCurKBDownloads := 0;
  (*
  FDownloads7Days := 0;
  FDownloads1Day := 0;
  FDownloads1Hour := 0;
  *)
end;

constructor TStatList.Create(AStatList: TStatList);
begin
  FStatListID := AStatList.StatListID;
  FCreated := AStatList.Created;
  FModified := AStatList.Modified;
  FModifier := AStatList.Modifier;
  FCurKBDownloads := AStatList.CurKBDownloads;
  (*
  FDownloads7Days := AStatList.Downloads7Days;
  FDownloads1Day := AStatList.Downloads1Day;
  FDownloads1Hour := AStatList.Downloads1Hour;
  *)
end;

procedure TStatList.Save;
var
  LConnection: TFDConnection;
  LSettings: TDBLoginSettings;
  LUpsert: TFDStoredProc;
  LUserName: String;
begin
  LSettings := TDBLoginSettings.Create;
  try
    LSettings.Load;
    LConnection := TDataServices.GetConnection('KBDL', LSettings.UserName, LSettings.Password, LSettings.Database, LSettings.Host, LSettings.WindowsAuthentication);
    LUserName := LSettings.UserName;
  finally
    LSettings.Free;
  end;

  try
    LUpsert := TFDStoredProc.Create(nil);
    try
      LUpsert.FetchOptions.Items := LUpsert.FetchOptions.Items - [fiMeta];
      LUpsert.StoredProcName := 'dbo.UpdateStatList';
      LUpsert.Params.Clear;
      LUpsert.Params.Add('@RETURN_VALUE', ftInteger, -1, ptResult);
      LUpsert.Params.Add('@StatListID', ftInteger, -1, ptInput);
      LUpsert.Params.Add('@Modifier', ftString, 50, ptInput);
      LUpsert.Params.Add('@CurKBDownloads', ftInteger, -1, ptInput);
      //LUpsert.Params.Add('@Downloads7Days', ftInteger, -1, ptInput);
      //LUpsert.Params.Add('@Downloads1Day', ftInteger, -1, ptInput);
      //LUpsert.Params.Add('@Downloads1Hour', ftInteger, -1, ptInput);
      LUpsert.Params.Add('@NextStatListPK', ftInteger, -1, ptOutput);

      LUpsert.Connection := LConnection;
      LConnection.Connected := TRUE;

      LUpsert.Params.ParamByName('@StatListID').AsInteger := FStatListID;
      LUpsert.Params.ParamByName('@Modifier').AsString := LUserName;
      LUpsert.Params.ParamByName('@CurKBDownloads').AsInteger := FCurKBDownloads;
      //LUpsert.Params.ParamByName('@Downloads7Days').AsInteger := FDownloads7Days;
      //LUpsert.Params.ParamByName('@Downloads1Day').AsInteger := FDownloads1Day;
      //LUpsert.Params.ParamByName('@Downloads1Hour').AsInteger := FDownloads1Hour;

      LUpsert.ExecProc;

      FStatListID := LUpsert.Params.ParamByName('@NextStatListID').AsInteger;
    finally
      LConnection.Connected := FALSE;
      LUpsert.Free;
    end;
  finally
    LConnection.Free;
  end;
end;

function TStatListList.GetCount: Integer;
begin
  Result := FList.Count;
end;

function TStatListList.GetStatList(AIndex: Integer): TStatList;
begin
  Result := FList[AIndex];
end;

class function TStatListList.GetInitialSQL: TStringList;
begin
  Result := TStringList.Create;
  Result.Add('Select StatList.StatListID, ');
  Result.Add('StatList.Created, ');
  Result.Add('StatList.Modified, ');
  Result.Add('StatList.Modifier, ');
  Result.Add('StatList.CurKBDownloads ');
  //Result.Add('StatList.Downloads7Days, ');
  //Result.Add('StatList.Downloads1Day, ');
  //Result.Add('StatList.Downloads1Hour ');
  Result.Add('From StatList ');
end;

class function TStatListList.CreateStatList(ADataSet: TDataSet): TStatList;
begin
  Result := TStatList.Create;
  Result.StatListID := ADataSet.Fields[0].AsInteger;
  Result.Created := ADataSet.Fields[1].AsDateTime;
  Result.Modified := ADataSet.Fields[2].AsDateTime;
  Result.Modifier := ADataSet.Fields[3].AsString;
  Result.CurKBDownloads := ADataSet.Fields[4].AsInteger;
  //Result.Downloads7Days := ADataSet.Fields[6].AsInteger;
  //Result.Downloads1Day := ADataSet.Fields[7].AsInteger;
  //Result.Downloads1Hour := ADataSet.Fields[8].AsInteger;
end;

constructor TStatListList.Create;
begin
  inherited Create;
  FList := TObjectList<TStatList>.Create(TRUE);
end;

constructor TStatListList.Create(AStatListList: TStatListList);
var
  i: Integer;
begin
  inherited Create;
  FList := TObjectList<TStatList>.Create(TRUE);
  for i := 0 to (AStatListList.Count - 1) do 
    FList.Add(TStatList.Create(AStatListList[i]));
end;

destructor TStatListList.Destroy;
begin
  FList.Free;
  inherited Destroy;
end;

procedure TStatListList.Clear;
begin
  FList.Clear;
end;

procedure TStatListList.Add(AStatList: TStatList);
begin
  FList.Add(AStatList);
end;

class function TStatListList.GetAll: TStatListList;
var
  LConnection: TFDConnection;
  LQuery: TFDQuery;
  LSQL: TStrings;
  i: Integer;
  LSettings: TDBLoginSettings;
  LRecord: TStatList;
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
        Result := TStatListList.Create;
        LQuery.First;
        while not LQuery.EOF do
        begin
          LRecord := CreateStatList(LQuery);
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
