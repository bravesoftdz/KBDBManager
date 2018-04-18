unit DBLoginSettings;

interface

uses
  SysUtils, Classes, INIFiles, CryptoAPI;

type
  TDBLoginSettings = class
    private
      class var FIniFile: String;
      class var FUserName: String;
      class var FPassword: String;
      class var FDatabase: String;
      class var FHost: String;
      class var FWindowsAuthentication: Boolean;
      class var FConnectionName: String;
      class var FDefaultFileName: String;
    public
      constructor Create(AIniFileName: String = ''); virtual;
      procedure Load;
      procedure Save;
      class property UserName: String read FUserName write FUserName;
      class property Password: String read FPassword write FPassword;
      class property Database: String read FDatabase write FDatabase;
      class property Host: String read FHost write FHost;
      class property WindowsAuthentication: Boolean read FWindowsAuthentication write FWindowsAuthentication;
      class property ConnectionName: String read FConnectionName write FConnectionName;
      class property DefaultFileName: String read FDefaultFileName write FDefaultFileName;
  end;

implementation

constructor TDBLoginSettings.Create(AIniFileName: String = '');
begin
  inherited Create;
  FIniFile := AIniFileName;
  if '' = FIniFile then
    FIniFile := FDefaultFileName;
end;

procedure TDBLoginSettings.Load;
var
  LIniFile: TIniFile;
  LPassword: String;
begin
  if not FileExists(FIniFile) then
    EXIT;

  LIniFile := TIniFile.Create(FIniFile);
  try
    FUserName := LIniFile.ReadString('DBLogin', 'UserName', '');
    LPassword := Trim(LIniFile.ReadString('DBLogin', 'Password', ''));
    if '' <> LPassword then
      TCryptoAPI.aesDecryptString(LIniFile.ReadString('DBLogin', 'Password', ''), LPassword);
    FPassword := LPassword;
    FDatabase := LIniFile.ReadString('DBLogin', 'Database', '');
    FHost := LIniFile.ReadString('DBLogin', 'Host', '');
    FWindowsAuthentication := LIniFile.ReadBool('DBLogin', 'WindowsAuth', FALSE);
  finally
    LIniFile.Free;
  end;
end;

procedure TDBLoginSettings.Save;
var
  LIniFile: TIniFile;
  LPassword: String;
begin
  LIniFile := TIniFile.Create(FIniFile);
  try
    LIniFile.WriteString('DBLogin', 'UserName', FUserName);
    if '' <> Trim(FPassword) then
      TCryptoAPI.aesEncryptString(FPassword, LPassword)
    else
      LPassword := '';
    LIniFile.WriteString('DBLogin', 'Password', LPassword);
    LIniFile.WriteString('DBLogin', 'Database', FDatabase);
    LIniFile.WriteString('DBLogin', 'Host', FHost);
    LIniFile.WriteBool('DBLogin', 'WindowsAuth', FWindowsAuthentication);
  finally
    LIniFile.Free;
  end;
end;

end.
