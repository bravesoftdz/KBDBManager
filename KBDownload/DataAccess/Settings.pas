unit Settings;

interface

uses
  SysUtils, Classes, DataServices, FireDAC.Stan.Error, FireDAC.UI.Intf,
  FireDAC.Phys.Intf, FireDAC.Stan.Def, FireDAC.Stan.Pool, FireDAC.Stan.Async,
  FireDAC.Phys, FireDAC.Phys.MSSQL, FireDAC.Comp.Client, FireDAC.Stan.Param,
  FireDAC.DatS,  FireDAC.DApt.Intf, FireDAC.DApt, DB, DBLoginSettings,
  CommonFunctions, FireDAC.Stan.Option, System.Generics.Collections;

type
  TSettings = class
    protected
      FSettingsID: Integer;
      FRowVer: TDateTime;
      FCreated: TDateTime;
      FModified: TDateTime;
      FModifier: String;
      FUploadPath: String;
      FUploadUrl: String;
      FDownloadPath: String;
      FDownloadUrl: String;
      FStagingPath: String;
      FStagingUrl: String;
      FCertificateName: String;
      FMaxKBDownloads: Integer;
    public
      constructor Create; overload; virtual;
      constructor Create(ASettings: TSettings); overload; virtual;
      procedure Save;
      property SettingsID: Integer read FSettingsID write FSettingsID;
      property RowVer: TDateTime read FRowVer write FRowVer;
      property Created: TDateTime read FCreated write FCreated;
      property Modified: TDateTime read FModified write FModified;
      property Modifier: String read FModifier write FModifier;
      property UploadPath: String read FUploadPath write FUploadPath;
      property UploadUrl: String read FUploadUrl write FUploadUrl;
      property DownloadPath: String read FDownloadPath write FDownloadPath;
      property DownloadUrl: String read FDownloadUrl write FDownloadUrl;
      property StagingPath: String read FStagingPath write FStagingPath;
      property StagingUrl: String read FStagingUrl write FStagingUrl;
      property CertificateName: String read FCertificateName write FCertificateName;
      property MaxKBDownloads: Integer read FMaxKBDownloads write FMaxKBDownloads;
  end;

  TSettingsList = class
    protected
      FList: TObjectList<TSettings>;
      function GetCount: Integer;
      function GetSettings(AIndex: Integer): TSettings;
      class function GetInitialSQL: TStringList;
      class function CreateSettings(ADataSet: TDataSet): TSettings;
    public
      constructor Create; overload; virtual;
      constructor Create(ASettingsList: TSettingsList); overload; virtual;
      destructor Destroy; override;
      procedure Clear;
      procedure Add(ASettings: TSettings);
      class function GetAll: TSettingsList;
      property Count: Integer read GetCount;
      property Settings[AIndex: Integer]: TSettings read GetSettings; default; 
  end;

implementation

constructor TSettings.Create;
begin
  FSettingsID := 0;
  FCreated := -1.00;
  FModified := -1.00;
  FModifier := '';
  FUploadPath := '';
  FUploadUrl := '';
  FDownloadPath := '';
  FDownloadUrl := '';
  FStagingPath := '';
  FStagingUrl := '';
  FCertificateName := '';
  FMaxKBDownloads := 0;
end;

constructor TSettings.Create(ASettings: TSettings);
begin
  FSettingsID := ASettings.SettingsID;
  FRowVer := ASettings.RowVer;
  FCreated := ASettings.Created;
  FModified := ASettings.Modified;
  FModifier := ASettings.Modifier;
  FUploadPath := ASettings.UploadPath;
  FUploadUrl := ASettings.UploadUrl;
  FDownloadPath := ASettings.DownloadPath;
  FDownloadUrl := ASettings.DownloadUrl;
  FStagingPath := ASettings.StagingPath;
  FStagingUrl := ASettings.StagingUrl;
  FCertificateName := ASettings.CertificateName;
  FMaxKBDownloads := ASettings.MaxKBDownloads;
end;

procedure TSettings.Save;
var
  LConnection: TFDConnection;
  LSettings: TDBLoginSettings;
  LUpsert: TFDStoredProc;
  LUser, LDomain: String;
begin
  LSettings := TDBLoginSettings.Create;
  try
    LSettings.Load;
    LConnection := TDataServices.GetConnection('KBDL', LSettings.UserName, LSettings.Password, LSettings.Database, LSettings.Host, LSettings.WindowsAuthentication);
    LUser := LSettings.UserName;
  finally
    LSettings.Free;
  end;

  try
    GetCurrentUserAndDomain(LUser, LDomain);
    LUser := LDomain + '\' + LUser;
  except
    //Do Nothing since we will have the db login as User Name
  end;

  try
    LUpsert := TFDStoredProc.Create(nil);
    try
      LUpsert.FetchOptions.Items := LUpsert.FetchOptions.Items - [fiMeta];
      LUpsert.StoredProcName := 'PatientData_UpdateSettings';
      LUpsert.Params.Clear;
      LUpsert.Params.Add('@RETURN_VALUE', ftInteger, -1, ptResult);
      LUpsert.Params.Add('@SettingsID', ftInteger, -1, ptInput);
      LUpsert.Params.Add('@Modifier', ftString, 50, ptInput);
      LUpsert.Params.Add('@UploadPath', ftString, 255, ptInput);
      LUpsert.Params.Add('@UploadUrl', ftString, 255, ptInput);
      LUpsert.Params.Add('@DownloadPath', ftString, 255, ptInput);
      LUpsert.Params.Add('@DownloadUrl', ftString, 255, ptInput);
      LUpsert.Params.Add('@StagingPath', ftString, 255, ptInput);
      LUpsert.Params.Add('@StagingUrl', ftString, 255, ptInput);
      LUpsert.Params.Add('@CertificateName', ftString, 255, ptInput);
      LUpsert.Params.Add('@MaxKBDownloads', ftInteger, -1, ptInput);
      LUpsert.Params.Add('@NextSettingsPK', ftInteger, -1, ptOutput);

      LUpsert.Connection := LConnection;
      LConnection.Connected := TRUE;

      LUpsert.Params.ParamByName('@SettingsID').AsInteger := FSettingsID;
      LUpsert.Params.ParamByName('@Modifier').AsString := LUser;
      LUpsert.Params.ParamByName('@UploadPath').AsString := FUploadPath;
      LUpsert.Params.ParamByName('@UploadUrl').AsString := FUploadUrl;
      LUpsert.Params.ParamByName('@DownloadPath').AsString := FDownloadPath;
      LUpsert.Params.ParamByName('@DownloadUrl').AsString := FDownloadUrl;
      LUpsert.Params.ParamByName('@StagingPath').AsString := FStagingPath;
      LUpsert.Params.ParamByName('@StagingUrl').AsString := FStagingUrl;
      LUpsert.Params.ParamByName('@CertificateName').AsString := FCertificateName;
      LUpsert.Params.ParamByName('@MaxKBDownloads').AsInteger := FMaxKBDownloads;

      LUpsert.ExecProc;

      FSettingsID := LUpsert.Params.ParamByName('@NextSettingsPK').AsInteger;
    finally
      LConnection.Connected := FALSE;
      LUpsert.Free;
    end;
  finally
    LConnection.Free;
  end;
end;

function TSettingsList.GetCount: Integer;
begin
  Result := FList.Count;
end;

function TSettingsList.GetSettings(AIndex: Integer): TSettings;
begin
  Result := FList[AIndex];
end;

class function TSettingsList.GetInitialSQL: TStringList;
begin
  Result := TStringList.Create;
  Result.Add('Select Settings.SettingsID, ');
  Result.Add('Settings.RowVer, ');
  Result.Add('Settings.Created, ');
  Result.Add('Settings.Modified, ');
  Result.Add('Settings.Modifier, ');
  Result.Add('Settings.UploadPath, ');
  Result.Add('Settings.UploadUrl, ');
  Result.Add('Settings.DownloadPath, ');
  Result.Add('Settings.DownloadUrl, ');
  Result.Add('Settings.StagingPath, ');
  Result.Add('Settings.StagingUrl, ');
  Result.Add('Settings.CertificateName, ');
  Result.Add('Settings.MaxKBDownloads ');
  Result.Add('From Settings ');
end;

class function TSettingsList.CreateSettings(ADataSet: TDataSet): TSettings;
begin
  Result := TSettings.Create;
  Result.SettingsID := ADataSet.Fields[0].AsInteger;
  Result.Created := ADataSet.Fields[2].AsDateTime;
  Result.Modified := ADataSet.Fields[3].AsDateTime;
  Result.Modifier := ADataSet.Fields[4].AsString;
  Result.UploadPath := ADataSet.Fields[5].AsString;
  Result.UploadUrl := ADataSet.Fields[6].AsString;
  Result.DownloadPath := ADataSet.Fields[7].AsString;
  Result.DownloadUrl := ADataSet.Fields[8].AsString;
  Result.StagingPath := ADataSet.Fields[9].AsString;
  Result.StagingUrl := ADataSet.Fields[10].AsString;
  Result.CertificateName := ADataSet.Fields[11].AsString;
  Result.MaxKBDownloads := ADataSet.Fields[12].AsInteger;
end;

constructor TSettingsList.Create;
begin
  inherited Create;
  FList := TObjectList<TSettings>.Create(TRUE);
end;

constructor TSettingsList.Create(ASettingsList: TSettingsList);
var
  i: Integer;
begin
  inherited Create;
  FList := TObjectList<TSettings>.Create(TRUE);
  for i := 0 to (ASettingsList.Count - 1) do 
    FList.Add(TSettings.Create(ASettingsList[i]));
end;

destructor TSettingsList.Destroy;
begin
  FList.Free;
  inherited Destroy;
end;

procedure TSettingsList.Clear;
begin
  FList.Clear;
end;

procedure TSettingsList.Add(ASettings: TSettings);
begin
  FList.Add(ASettings);
end;

class function TSettingsList.GetAll: TSettingsList;
var
  LConnection: TFDConnection;
  LQuery: TFDQuery;
  LSQL: TStrings;
  i: Integer;
  LSettings: TDBLoginSettings;
  LRecord: TSettings;
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
        Result := TSettingsList.Create;
        LQuery.First;
        while not LQuery.EOF do
        begin
          LRecord := CreateSettings(LQuery);
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
