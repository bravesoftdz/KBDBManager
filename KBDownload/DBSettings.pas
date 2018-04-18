unit DBSettings;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.Mask, RzEdit, RzLabel,
  RzButton, RzRadChk, RzSpnEdt;

type
  TfmDBSettings = class(TForm)
    RzLabel1: TRzLabel;
    ebUserName: TRzEdit;
    RzLabel2: TRzLabel;
    ebPassword: TRzEdit;
    RzLabel3: TRzLabel;
    ebDBName: TRzEdit;
    RzLabel4: TRzLabel;
    ebHost: TRzEdit;
    btnOK: TRzBitBtn;
    btnCancel: TRzBitBtn;
    ckbWindowsAuth: TRzCheckBox;
    procedure btnOKClick(Sender: TObject);
    procedure btnCancelClick(Sender: TObject);
    procedure ckbWindowsAuthClick(Sender: TObject);
  private
    { Private declarations }
    FUser: String;
    FDomain: String;
  public
    { Public declarations }
    constructor Create(AOwner: TComponent); override;
  end;

implementation

uses
  DBLoginSettings, CommonFunctions;

{$R *.dfm}

constructor TfmDBSettings.Create(AOwner: TComponent);
var
  LSettings: TDBLoginSettings;
begin
  inherited Create(AOwner);
  GetCurrentUserAndDomain(FUser, FDomain);
  LSettings := TDBLoginSettings.Create;
  try
    LSettings.Load;
    ebUserName.Text := LSettings.UserName;
    ebPassword.Text := LSettings.Password;
    ebDBName.Text := LSettings.Database;
    ebHost.Text := LSettings.Host;
    ckbWindowsAuth.Checked := LSettings.WindowsAuthentication;
    if ckbWindowsAuth.Checked then
    begin
      ebUserName.Text := FDomain + '\' + FUser;
      ebUserName.Enabled := FALSE;
      ebPassword.Text := '';
      ebPassword.Enabled := FALSE;
    end;
  finally
    LSettings.Free;
  end;
end;

procedure TfmDBSettings.btnOKClick(Sender: TObject);
var
  LSettings: TDBLoginSettings;
begin
  LSettings := TDBLoginSettings.Create;
  try
    LSettings.UserName := Trim(ebUserName.Text);
    LSettings.Password := ebPassword.Text;
    LSettings.Database := Trim(ebDBName.Text);
    LSettings.Host := Trim(ebHost.Text);
    LSettings.WindowsAuthentication := ckbWindowsAuth.Checked;
    if LSettings.WindowsAuthentication then
    begin
      LSettings.Password := '';
    end;
    LSettings.Save;
  finally
    LSettings.Free;
  end;
  ModalResult := mrOK;
end;

procedure TfmDBSettings.ckbWindowsAuthClick(Sender: TObject);
begin
  if ckbWindowsAuth.Checked then
  begin
    ebUserName.Text := FDomain + '\' + FUser;
    ebUserName.Enabled := FALSE;
    ebPassword.Text := '';
    ebPassword.Enabled := FALSE;
  end else
  begin
    ebUserName.Enabled := TRUE;
    ebPassword.Enabled := TRUE;
  end;
end;

procedure TfmDBSettings.btnCancelClick(Sender: TObject);
begin
  ModalResult := mrCancel;
end;

end.
