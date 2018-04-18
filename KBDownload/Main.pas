unit Main;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.Menus, RzButton, Vcl.ImgList,
  Vcl.ExtCtrls, RzPanel, FireDAC.UI.Intf, FireDAC.VCLUI.Wait, FireDAC.Stan.Intf,
  FireDAC.Comp.UI, ppComm, ppRelatv, ppProd, ppClass, ppReport, ppFormWrapper,
  ppRptExp, FireDAC.Stan.Option, FireDAC.Stan.Error, FireDAC.Phys.Intf,
  FireDAC.Stan.Def, FireDAC.Stan.Pool, FireDAC.Stan.Async, FireDAC.Phys,
  FireDAC.Phys.MSSQL, FireDAC.Phys.MSSQLDef, Data.DB, FireDAC.Comp.Client,
  DBLoginSettings, DataServices, FireDAC.Stan.Param, FireDAC.DatS,
  FireDAC.DApt.Intf, FireDAC.DApt, FireDAC.Comp.DataSet, Datasnap.DBClient,
  Datasnap.Provider, ppDB, ppDBPipe, System.ImageList, raIDE, ppEndUsr,
  ppDesignLayer, ppParameter, ppChrt, daIDE, daFireDAC, myChkBoxDesign, ppChrtUI,
  RzStatus, RptItem, RptFolder;

type
  TfmMain = class(TForm)
    menMain: TMainMenu;
    menFile: TMenuItem;
    miDBSettings: TMenuItem;
    tbMain: TRzToolbar;
    ilMain: TImageList;
    btnDeployments: TRzToolButton;
    FDGUIxWaitCursor1: TFDGUIxWaitCursor;
    btnReleses: TRzToolButton;
    btnPackages: TRzToolButton;
    btnStatLists: TRzToolButton;
    btnServerSettings: TRzToolButton;
    reMain: TppReportExplorer;
    btnReports: TRzToolButton;
    conMain: TFDConnection;
    qFolder: TFDQuery;
    qItem: TFDQuery;
    prvFolder: TDataSetProvider;
    prvItem: TDataSetProvider;
    cdsItem: TClientDataSet;
    cdsFolder: TClientDataSet;
    cdsFolderRptFolderID: TAutoIncField;
    cdsFolderRptFolderName: TStringField;
    cdsFolderParentID: TIntegerField;
    dsFolder: TDataSource;
    dsItem: TDataSource;
    pplFolder: TppDBPipeline;
    pplItems: TppDBPipeline;
    MainDesigner: TppDesigner;
    MainReport: TppReport;
    cdsItemRptItemID: TAutoIncField;
    cdsItemRptFolderID: TIntegerField;
    cdsItemItemType: TIntegerField;
    cdsItemModified: TSQLTimeStampField;
    cdsItemDeleted: TSQLTimeStampField;
    cdsItemReportName: TStringField;
    cdsItemReportSize: TIntegerField;
    cdsItemReportTemplate: TBlobField;
    miDeploymentSelect: TMenuItem;
    viMain: TRzVersionInfo;
    qFolderRptFolderID: TIntegerField;
    qFolderRptFolderName: TStringField;
    qFolderParentID: TIntegerField;
    qItemRptItemID: TIntegerField;
    qItemRptFolderID: TIntegerField;
    qItemItemType: TIntegerField;
    qItemModified: TSQLTimeStampField;
    qItemDeleted: TSQLTimeStampField;
    qItemReportName: TStringField;
    qItemReportSize: TIntegerField;
    qItemReportTemplate: TBlobField;
    procedure miDBSettingsClick(Sender: TObject);
    procedure btnDeploymentsClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure btnRelesesClick(Sender: TObject);
    procedure btnPackagesClick(Sender: TObject);
    procedure btnStatListsClick(Sender: TObject);
    procedure btnServerSettingsClick(Sender: TObject);
    procedure btnReportsClick(Sender: TObject);
    procedure cdsFolderAfterPost(DataSet: TDataSet);
    procedure cdsItemAfterPost(DataSet: TDataSet);
    procedure miDeploymentSelectClick(Sender: TObject);
    procedure reMainClose(Sender: TObject; var Action: TCloseAction);
    procedure reMainShow(Sender: TObject);
    procedure cdsFolderBeforePost(DataSet: TDataSet);
    procedure cdsItemBeforePost(DataSet: TDataSet);
  private
    { Private declarations }
    FReportsVisible: Boolean;
    function UserOKToRun: Boolean;
    procedure CloseMDIChildren;
    procedure ConnectToDB;
    procedure DisconnectFromDB;
  public
    { Public declarations }
    constructor Create(AOWner: TComponent); override;
  end;

var
  fmMain: TfmMain;

implementation

uses
  IAmABigBoy, DBSettings, Deployments, Releases, KBPackages, StatLists,
  ServerSettings, CommonFunctions, DeploymentSelect, SnapshotDataPrep,
  FullAppPassword, FullApplication;

{$R *.dfm}
{===============================================================================
  Custom Methods
===============================================================================}
constructor TfmMain.Create(AOWner: TComponent);
begin
  inherited Create(AOWner);
  FReportsVisible := FALSE;
  if not UserOKToRun then
    Application.Terminate;
  Self.Caption := 'KB Download DDA Prototype ' +  viMain.FileVersion;
end;

function TfmMain.UserOKToRun: Boolean;
var
  fm: TfmBigBoy;
begin
  fm := TfmBigBoy.Create(nil);
  try
    fm.ShowModal;
    Result := fm.UserOK;
  finally
    fm.Free;
  end;
end;

procedure TfmMain.ConnectToDB;
var
  LSettings: TDBLoginSettings;
begin
  conMain.LoginPrompt := FALSE;
  conMain.DriverName := 'MSSQL';
  LSettings := TDBLoginSettings.Create;
  try
    conMain.Params.Clear;
    LSettings.Load;
    conMain.Params.Add('User_Name=' + LSettings.UserName);
    conMain.Params.Add('Password=' + LSettings.Password);
    conMain.Params.Add('Server=' + LSettings.Host);
    conMain.Params.Add('Database=' + LSettings.Database);
    conMain.Params.Add('DriverID=MSSQL');
    if LSettings.WindowsAuthentication then
      conMain.Params.Add('OSAuthent=Yes');
  finally
    LSettings.Free;
  end;

  conMain.Connected := TRUE;
end;

procedure TfmMain.DisconnectFromDB;
begin
  conMain.Connected := TRUE;
end;

procedure TfmMain.CloseMDIChildren;
var
  iLoop  : Integer;
begin
  if FReportsVisible then
    reMain.Close;
  iLoop := fmMain.MDIChildCount-1;
  while iLoop >= 0 do
  begin
    fmMain.MDIChildren[iLoop].Close;
    iLoop := iLoop - 1;
  end;
end;

procedure TfmMain.miDBSettingsClick(Sender: TObject);
var
  fm: TfmDBSettings;
begin
  fm := TfmDBSettings.Create(nil);
  try
    fm.ShowModal;
  finally
    fm.Free;
  end;
end;
{===============================================================================
  End Of Custom Methods
===============================================================================}
procedure TfmMain.btnDeploymentsClick(Sender: TObject);
var
  LForm: TForm;
begin
  CloseMDIChildren;
  try
    Screen.Cursor := crHourglass;
    LockWindowUpdate(fmMain.Handle); //Locks Main Form to prevent flashing while
    LForm := TfmDeployments.Create(nil);
    LForm.WindowState := wsMaximized;
    LForm.Show;
  finally
    Screen.Cursor := crDefault;
    LockWindowUpdate(0);//Feeding 0 to function unlocks the locked window
  end;
end;

procedure TfmMain.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  CloseMDIChildren;
end;

procedure TfmMain.btnRelesesClick(Sender: TObject);
var
  LForm: TForm;
begin
  CloseMDIChildren;
  try
    Screen.Cursor := crHourglass;
    LockWindowUpdate(fmMain.Handle); //Locks Main Form to prevent flashing while
    LForm := TfmReleases.Create(nil);
    LForm.WindowState := wsMaximized;
    LForm.Show;
  finally
    Screen.Cursor := crDefault;
    LockWindowUpdate(0);//Feeding 0 to function unlocks the locked window
  end;
end;

procedure TfmMain.btnPackagesClick(Sender: TObject);
var
  LForm: TForm;
begin
  CloseMDIChildren;
  try
    Screen.Cursor := crHourglass;
    LockWindowUpdate(fmMain.Handle); //Locks Main Form to prevent flashing while
    LForm := TfmKBPackages.Create(nil);
    LForm.WindowState := wsMaximized;
    LForm.Show;
  finally
    Screen.Cursor := crDefault;
    LockWindowUpdate(0);//Feeding 0 to function unlocks the locked window
  end;
end;

procedure TfmMain.btnStatListsClick(Sender: TObject);
var
  LForm: TForm;
begin
  CloseMDIChildren;
  try
    Screen.Cursor := crHourglass;
    LockWindowUpdate(fmMain.Handle); //Locks Main Form to prevent flashing while
    LForm := TfmStatLists.Create(nil);
    LForm.WindowState := wsMaximized;
    LForm.Show;
  finally
    Screen.Cursor := crDefault;
    LockWindowUpdate(0);//Feeding 0 to function unlocks the locked window
  end;
end;

procedure TfmMain.btnServerSettingsClick(Sender: TObject);
var
  fm: TfmServerSettings;
begin
  fm := TfmServerSettings.Create(nil);
  try
    fm.ShowModal;
  finally
    fm.Free;
  end;
end;

procedure TfmMain.btnReportsClick(Sender: TObject);
begin
  ConnectToDB;
  cdsFolder.Open;
  cdsItem.Open;
  reMain.Execute;
end;

procedure TfmMain.cdsFolderBeforePost(DataSet: TDataSet);
begin
  if cdsFolder.FieldByName('RptFolderID').IsNull then
    cdsFolder.FieldByName('RptFolderID').AsInteger := TRptFolder.GetNextRptFolderID;
end;

procedure TfmMain.cdsFolderAfterPost(DataSet: TDataSet);
begin
  cdsFolder.ApplyUpdates(0);
  cdsFolder.Refresh;
end;

procedure TfmMain.cdsItemBeforePost(DataSet: TDataSet);
begin
  if cdsItem.FieldByName('RptItemID').IsNull then
    cdsItem.FieldByName('RptItemID').AsInteger := TRptItem.GetNextRptItemID;
end;

procedure TfmMain.cdsItemAfterPost(DataSet: TDataSet);
begin
  cdsItem.ApplyUpdates(0);
  cdsItem.Refresh;
end;

procedure TfmMain.miDeploymentSelectClick(Sender: TObject);
var
  fm : TfmSnapshotDataPrep;
begin
  fm := TfmSnapshotDataPrep.Create(nil);
  try
    fm.ShowModal;
  finally
    fm.Free;
  end;
end;

procedure TfmMain.reMainClose(Sender: TObject; var Action: TCloseAction);
begin
  cdsItem.Close;
  cdsFolder.Close;
  DisconnectFromDB;
  FReportsVisible := FALSE;
end;

procedure TfmMain.reMainShow(Sender: TObject);
begin
  FReportsVisible := TRUE;
end;

end.
