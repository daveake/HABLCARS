unit payloads;

{$mode objfpc}{$H+}

interface

uses
    Classes, SysUtils, Forms, Controls, Graphics, Dialogs, TargetForm;

type
    TfrmPayloads = class(TfrmTarget)
    private

    public
      procedure ShowTimeSinceUpdate(Index: Integer; TimeSinceUpdate: TDateTime; Repeated: Boolean);
    end;

var
    frmPayloads: TfrmPayloads;

implementation

{$R *.lfm}

procedure TfrmPayloads.ShowTimeSinceUpdate(Index: Integer; TimeSinceUpdate: TDateTime; Repeated: Boolean);
begin
    //if (Index >= Low(Rectangles)) and (Index <= High(Rectangles)) then begin
    //    Labels[Index,1].Text := FormatDateTime('nn:ss', TimeSinceUpdate) + RepeatString(Repeated);
    //end;
end;

end.

