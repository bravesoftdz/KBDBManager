unit MyRAPFunctions;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, ComCtrls, raFunc, ppRTTI, CommonFunctions,
  DeploymentSelect, KBModule, AgentsByOS, DateRangeSelect;

type
  TDataFunction = class(traSystemFunction)
    public
      class function Category: String; override;
  end;

  TSelectorFunction = class(traSystemFunction)
    public
      class function Category: String; override;
  end;

  TDeploymentSelectionFunction = class(TSelectorFunction)
    procedure ExecuteFunction(AParams: TraParamList); override;
    class function GetSignature: String; override;
  end;

  TDateRangeSelectionFunction = class(TSelectorFunction)
    procedure ExecuteFunction(AParams: TraParamList); override;
    class function GetSignature: String; override;
  end;

implementation

class function TDataFunction.Category: String;
begin
  Result := 'Data Functions';
end;

class function TSelectorFunction.Category: String;
begin
  Result := 'Selector Functions';
end;

procedure TDeploymentSelectionFunction.ExecuteFunction(AParams: TraParamList);
var
  LName: String;
  LMasterLicenceID: Integer;
  LResult: Integer;
  fm: TfmDeploymentSelect;
begin
  LResult := -1;
  LName := '';
  LMasterLicenceID := -1;
  fm := TfmDeploymentSelect.Create(nil, FM_VIEW, FALSE);
  try
    if (mrOK = fm.ShowModal) then
    begin
      LResult := fm.PrimaryKey;
      LName := fm.Name;
      LMasterLicenceID := fm.MasterLicenceID;
    end;
  finally
    fm.Free;
  end;
  SetParamValue(0,LMasterLicenceID);
  SetParamValue(1,LName);
  SetParamValue(2,LResult);
end;

class function TDeploymentSelectionFunction.GetSignature: String;
begin
  Result := 'function SelectDeplyment(var AMasterLicenceID: Integer; var ADeploymentName: String): Integer;';
end;

procedure TDateRangeSelectionFunction.ExecuteFunction(AParams: TraParamList);
var
  LName: String;
  LMasterLicenceID: Integer;
  LFrom, LTo: TDateTime;
  LResult: Boolean;
  fm: TfmSelectDateRange;
begin
  LResult := FALSE;
  LName := '';
  LMasterLicenceID := -1;
  fm := TfmSelectDateRange.Create(nil);
  try
    if (mrOK = fm.ShowModal) then
    begin
      LResult := TRUE;
      LFrom := fm.DateFrom;
      LTo := fm.DateTo;
    end;
  finally
    fm.Free;
  end;
  SetParamValue(0,LFrom);
  SetParamValue(1,LTo);
  SetParamValue(2,LResult);
end;

class function TDateRangeSelectionFunction.GetSignature: String;
begin
  Result := 'function GetDateRange(var AFromDate, AToDate: TDateTime): Boolean;';
end;

initialization
  raRegisterFunction('SelectDeplyment', TDeploymentSelectionFunction);
  raRegisterFunction('GetDateRange', TDateRangeSelectionFunction);

end.

