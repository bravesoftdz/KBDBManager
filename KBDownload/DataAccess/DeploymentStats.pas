unit DeploymentStats;

interface

uses
  SysUtils, Classes, DataServices, FireDAC.Stan.Error, FireDAC.UI.Intf,
  FireDAC.Phys.Intf, FireDAC.Stan.Def, FireDAC.Stan.Pool, FireDAC.Stan.Async,
  FireDAC.Phys, FireDAC.Phys.MSSQL, FireDAC.Comp.Client, FireDAC.Stan.Param,
  FireDAC.DatS,  FireDAC.DApt.Intf, FireDAC.DApt, DB, DBLoginSettings,
  CommonFunctions, FireDAC.Stan.Option, System.Generics.Collections;

type
  TDeploymentStats = class
    protected
      FDeploymentStatsID: Integer;
      FDeploymentID: Integer;
      FStatDate: TDateTime;
      FUpdateChecks: Integer;
      FDownloads: Integer;
    public
      constructor Create; overload; virtual;
      constructor Create(ADeploymentStats: TDeploymentStats); overload; virtual;
      procedure Save;
      property DeploymentStatsID: Integer read FDeploymentStatsID write FDeploymentStatsID;
      property DeploymentID: Integer read FDeploymentID write FDeploymentID;
      property StatDate: TDateTime read FStatDate write FStatDate;
      property UpdateChecks: Integer read FUpdateChecks write FUpdateChecks;
      property Downloads: Integer read FDownloads write FDownloads;
  end;

  TDeploymentStatsList = class
    protected
      FList: TObjectList<TDeploymentStats>;
      function GetCount: Integer;
      function GetDeploymentStats(AIndex: Integer): TDeploymentStats;
      class function GetInitialSQL: TStringList;
      class function CreateDeploymentStats(ADataSet: TDataSet): TDeploymentStats;
    public
      constructor Create; overload; virtual;
      constructor Create(ADeploymentStatsList: TDeploymentStatsList); overload; virtual;
      destructor Destroy; override;
      procedure Clear;
      procedure Add(ADeploymentStats: TDeploymentStats);
      class function GetAll: TDeploymentStatsList;
      class function GetAllForDeployment(ADeploymentID: Integer): TDeploymentStatsList;
      property Count: Integer read GetCount;
      property DeploymentStats[AIndex: Integer]: TDeploymentStats read GetDeploymentStats; default; 
  end;

implementation

constructor TDeploymentStats.Create;
begin
  FDeploymentStatsID := 0;
  FDeploymentID := 0;
  FStatDate := -1.00;
  FUpdateChecks := 0;
  FDownloads := 0;
end;

constructor TDeploymentStats.Create(ADeploymentStats: TDeploymentStats);
begin
  FDeploymentStatsID := ADeploymentStats.DeploymentStatsID;
  FDeploymentID := ADeploymentStats.DeploymentID;
  FStatDate := ADeploymentStats.StatDate;
  FUpdateChecks := ADeploymentStats.UpdateChecks;
  FDownloads := ADeploymentStats.Downloads;
end;

procedure TDeploymentStats.Save;
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
      LUpsert.StoredProcName := 'dbo.UpdateDeploymentStats';
      LUpsert.Params.Clear;
      LUpsert.Params.Add('@RETURN_VALUE', ftInteger, -1, ptResult);
      LUpsert.Params.Add('@DeploymentStatsID', ftInteger, -1, ptInput);
      LUpsert.Params.Add('@DeploymentID', ftInteger, -1, ptInput);
      LUpsert.Params.Add('@StatDate', ftDateTime, -1, ptInput);
      LUpsert.Params.Add('@UpdateChecks', ftInteger, -1, ptInput);
      LUpsert.Params.Add('@Downloads', ftInteger, -1, ptInput);
      LUpsert.Params.Add('@NextDeploymentStatsID', ftInteger, -1, ptOutput);

      LUpsert.Connection := LConnection;
      LConnection.Connected := TRUE;

      LUpsert.Params.ParamByName('@DeploymentStatsID').AsInteger := FDeploymentStatsID;
      LUpsert.Params.ParamByName('@DeploymentID').AsInteger := FDeploymentID;
      LUpsert.Params.ParamByName('@StatDate').AsDateTime := FStatDate;
      LUpsert.Params.ParamByName('@UpdateChecks').AsInteger := FUpdateChecks;
      LUpsert.Params.ParamByName('@Downloads').AsInteger := FDownloads;

      LUpsert.ExecProc;

      FDeploymentStatsID := LUpsert.Params.ParamByName('@NextDeploymentStatsPK').AsInteger;
    finally
      LConnection.Connected := FALSE;
      LUpsert.Free;
    end;
  finally
    LConnection.Free;
  end;
end;

function TDeploymentStatsList.GetCount: Integer;
begin
  Result := FList.Count;
end;

function TDeploymentStatsList.GetDeploymentStats(AIndex: Integer): TDeploymentStats;
begin
  Result := FList[AIndex];
end;

class function TDeploymentStatsList.GetInitialSQL: TStringList;
begin
  Result := TStringList.Create;
  Result.Add('Select DeploymentStats.DeploymentStatsID, ');
  Result.Add('DeploymentStats.DeploymentID, ');
  Result.Add('DeploymentStats.StatDate, ');
  Result.Add('DeploymentStats.UpdateChecks, ');
  Result.Add('DeploymentStats.Downloads ');
  Result.Add('From DeploymentStats ');
end;

class function TDeploymentStatsList.CreateDeploymentStats(ADataSet: TDataSet): TDeploymentStats;
begin
  Result := TDeploymentStats.Create;
  Result.DeploymentStatsID := ADataSet.Fields[0].AsInteger;
  Result.DeploymentID := ADataSet.Fields[1].AsInteger;
  Result.StatDate := ADataSet.Fields[2].AsDateTime;
  Result.UpdateChecks := ADataSet.Fields[3].AsInteger;
  Result.Downloads := ADataSet.Fields[4].AsInteger;
end;

constructor TDeploymentStatsList.Create;
begin
  inherited Create;
  FList := TObjectList<TDeploymentStats>.Create(TRUE);
end;

constructor TDeploymentStatsList.Create(ADeploymentStatsList: TDeploymentStatsList);
var
  i: Integer;
begin
  inherited Create;
  FList := TObjectList<TDeploymentStats>.Create(TRUE);
  for i := 0 to (ADeploymentStatsList.Count - 1) do 
    FList.Add(TDeploymentStats.Create(ADeploymentStatsList[i]));
end;

destructor TDeploymentStatsList.Destroy;
begin
  FList.Free;
  inherited Destroy;
end;

procedure TDeploymentStatsList.Clear;
begin
  FList.Clear;
end;

procedure TDeploymentStatsList.Add(ADeploymentStats: TDeploymentStats);
begin
  FList.Add(ADeploymentStats);
end;

class function TDeploymentStatsList.GetAll: TDeploymentStatsList;
var
  LConnection: TFDConnection;
  LQuery: TFDQuery;
  LSQL: TStrings;
  i: Integer;
  LSettings: TDBLoginSettings;
  LRecord: TDeploymentStats;
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
        Result := TDeploymentStatsList.Create;
        LQuery.First;
        while not LQuery.EOF do
        begin
          LRecord := CreateDeploymentStats(LQuery);
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

class function TDeploymentStatsList.GetAllForDeployment(ADeploymentID: Integer): TDeploymentStatsList;
var
  LConnection: TFDConnection;
  LQuery: TFDQuery;
  LSQL: TStrings;
  i: Integer;
  LSettings: TDBLoginSettings;
  LRecord: TDeploymentStats;
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
      LSQL.Add('Where DeploymentStats.DeploymentID=' + IntToStr(ADeploymentID) + ' ');
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
        Result := TDeploymentStatsList.Create;
        LQuery.First;
        while not LQuery.EOF do
        begin
          LRecord := CreateDeploymentStats(LQuery);
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
