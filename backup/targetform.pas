
unit TargetForm;

{$mode objfpc}{$H+}

interface

uses
    Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ExtCtrls, base,
    Source;

type
  TPositions = record
    Position: THABPosition;
    Changed: Boolean;
  end;

type

    { TfrmTarget }

    TfrmTarget = class(TfrmBase)
        tmrUpdates: TTimer;
        procedure tmrUpdatesTimer(Sender: TObject);
    private

    protected
      SelectedIndex: Integer;
      Positions: Array[0..3] of TPositions;
      function ProcessNewPosition(Index: Integer): Boolean; virtual;
      procedure ProcessNewDirection(Index: Integer); virtual;
    public
      //procedure UpdatePayloadID(Index: Integer; PayloadID: String); virtual;
      procedure NewSelection(Index: Integer); virtual;
      procedure NewPosition(Index: Integer; HABPosition: THABPosition); virtual;
    end;


implementation

{$R *.lfm}

procedure TfrmTarget.NewSelection(Index: Integer);
begin
    // virtual
    SelectedIndex := Index;
    if Positions[0].Position.Inuse and Positions[SelectedIndex].Position.InUse then begin
        ProcessNewDirection(SelectedIndex);
    end;
end;


procedure TfrmTarget.NewPosition(Index: Integer; HABPosition: THABPosition);
begin
    // virtual
    Positions[Index].Position := HABPosition;
    Positions[Index].Changed := True;
end;

procedure TfrmTarget.tmrUpdatesTimer(Sender: TObject);
var
    Index: Integer;
begin
    // Update direction ?
    if SelectedIndex > 0 then begin
        if Positions[0].Changed or Positions[SelectedIndex].Changed then begin
            // ProcessNewDirection(SelectedIndex);
        end;
    end;

    for Index := 0 to 3 do begin
        if Positions[Index].Changed then begin
            if ProcessNewPosition(Index) then begin
                Positions[Index].Changed := False;
            end;
        end;
    end;
end;

function TfrmTarget.ProcessNewPosition(Index: Integer): Boolean;
begin
    // virtual
    Result := True;
end;

procedure TfrmTarget.ProcessNewDirection(Index: Integer);
begin
    // virtual
end;


end.

