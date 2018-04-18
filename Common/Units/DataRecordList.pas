unit DataRecordList;

interface

uses
  SysUtils, Classes, CommonFunctions;

type
  TDataRecordList = class
    protected
      {Protected declarations }
      function GetCount: Integer; virtual; abstract;
      function GetFieldCount: Integer; virtual; abstract;
      function GetFieldCaption(AIndex: Integer): String; virtual; abstract;
      function GetFieldData(ARecord, AIndex: Integer): Variant; virtual; abstract;
    public
      {Protected declarations }
      property Count: Integer read GetCount;
      property FieldCount: Integer read GetFieldCount;
      property FieldCaptions[AIndex: Integer]: String read GetFieldCaption;
      property FieldData[ARecord, AIndex: Integer]: Variant read GetFieldData;
  end;


implementation

end.
