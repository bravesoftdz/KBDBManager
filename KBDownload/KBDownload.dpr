program KBDownload;

uses
  EMemLeaks,
  EResLeaks,
  EDialogWinAPIMSClassic,
  EDialogWinAPIEurekaLogDetailed,
  EDialogWinAPIStepsToReproduce,
  EDebugExports,
  EDebugJCL,
  EMapWin32,
  EAppVCL,
  ExceptionLog7,
  Vcl.Forms,
  System.SysUtils,
  Vcl.FileCtrl,
  System.IOUtils,
  Main in 'Main.pas' {fmMain},
  CommonFunctions in '..\Common\Units\CommonFunctions.pas',
  CryptoAPI in '..\Common\Units\CryptoAPI.pas',
  Wcrypt2 in '..\Common\Units\Wcrypt2.pas',
  DBLoginSettings in '..\Common\Units\DBLoginSettings.pas',
  IAmABigBoy in 'IAmABigBoy.pas' {fmBigBoy},
  DBSettings in 'DBSettings.pas' {fmDBSettings},
  Deployments in 'Deployments.pas' {fmDeployments},
  Deployment in 'DataAccess\Deployment.pas',
  DataServices in '..\Common\DataObjects\DataServices.pas',
  DeploymentEdit in 'DeploymentEdit.pas' {fmDeploymentEdit},
  KBPackage in 'DataAccess\KBPackage.pas',
  Release in 'DataAccess\Release.pas',
  Releases in 'Releases.pas' {fmReleases},
  DeploymentSnapshots in 'DeploymentSnapshots.pas' {fmDeploymentSnapshots},
  ReleaseEdit in 'ReleaseEdit.pas' {fmReleaseEdit},
  KBPackages in 'KBPackages.pas' {fmKBPackages},
  Settings in 'DataAccess\Settings.pas',
  StatList in 'DataAccess\StatList.pas',
  StatLists in 'StatLists.pas' {fmStatLists},
  DeploymentStats in 'DataAccess\DeploymentStats.pas',
  DataRecordList in '..\Common\Units\DataRecordList.pas',
  ServerSettings in 'ServerSettings.pas' {fmServerSettings},
  Snapshot in 'DataAccess\Snapshot.pas',
  SpreadsheetBase in '..\Common\Forms\SpreadsheetBase.pas' {fmSpreadSheetBase},
  RecordListExport in 'RecordListExport.pas' {fmRecordListExport},
  SingleRecordLookupUnbound in '..\Common\Forms\SingleRecordLookupUnbound.pas' {fmSingleRecordLookupUnbound},
  DeploymentSelect in 'DeploymentSelect.pas' {fmDeploymentSelect},
  MyRAPFunctions in 'MyRAPFunctions.pas',
  KBModule in 'DataAccess\KBModule.pas',
  AgentsByOS in 'DataAccess\AgentsByOS.pas',
  DateRangeSelect in '..\Common\Forms\DateRangeSelect.pas' {fmSelectDateRange},
  SnapshotDataPrep in 'SnapshotDataPrep.pas' {fmSnapshotDataPrep},
  RptFolder in 'DataAccess\RptFolder.pas',
  RptItem in 'DataAccess\RptItem.pas',
  KBPackageEdit in 'KBPackageEdit.pas' {fmKBPackageEdit},
  KBPackageSelect in 'KBPackageSelect.pas' {fmKBPackageSelect},
  FullAppPassword in 'FullAppPassword.pas' {fmFullAppPassword},
  FullApplication in 'FullApplication.pas' {fmUseFullApplication},
  KBVersion in 'KBVersion.pas';

{$R *.res}

function IntializeDataFolder: Boolean;
var
  LDataDir: String;
begin
  LDataDir := IncludeTrailingPathDelimiter(GetCommonAppDataDir) + 'BastardSoftware\KBDownload';
  if not (System.SysUtils.DirectoryExists(LDataDir)) then
    TDirectory.CreateDirectory(LDataDir);
  Result := TRUE;
  TDBLoginSettings.DefaultFileName := LDataDir + '\Settings.ini'
end;

begin
  IntializeDataFolder;
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TfmMain, fmMain);
  Application.Run;
end.
