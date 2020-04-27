
unit TargetForm;

{$mode objfpc}{$H+}

interface

uses
    Classes, SysUtils, Forms, Controls, Graphics, Dialogs, base, Source;

type
  TPositions = record
    Position: THABPosition;
    Changed: Boolean;
  end;

type
    TfrmTarget = class(TfrmBase)
    private

    protected
      SelectedIndex: Integer;
      Positions: Array[0..3] of TPositions;
      function ProcessNewPosition(Index: Integer): Boolean; virtual;
      //procedure ProcessNewDirection(Index: Integer); virtual;
    public
      //procedure UpdatePayloadID(Index: Integer; PayloadID: String); virtual;
      //procedure NewSelection(Index: Integer); virtual;
      procedure NewPosition(Index: Integer; HABPosition: THABPosition); virtual;
    end;


implementation

{$R *.lfm}

procedure TfrmTarget.NewPosition(Index: Integer; HABPosition: THABPosition);
begin
    // virtual
    Positions[Index].Position := HABPosition;
    Positions[Index].Changed := True;
end;

function TfrmTarget.ProcessNewPosition(Index: Integer): Boolean;
begin
    // virtual
    Result := True;
end;



end.

