unit payloads;

{$mode objfpc}{$H+}

interface

uses
    Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ExtCtrls, StdCtrls,
    TargetForm, Types, Source;

type

    { TfrmPayloads }

    TfrmPayloads = class(TfrmTarget)
        Panel1: TPanel;
        Rectangle1: TPanel;
        Panel3: TPanel;
        Rectangle2: TPanel;
        Panel5: TPanel;
        Rectangle3: TPanel;
        procedure FormCreate(Sender: TObject);
    private
      Rectangles: Array[1..3] of TPanel;
      Labels: Array[1..3, 0..8] of TLabel;
    public
      procedure NewPosition(Index: Integer; HABPosition: THABPosition); override;
      procedure ShowTimeSinceUpdate(Index: Integer; TimeSinceUpdate: TDateTime; Repeated: Boolean);
    end;

var
    frmPayloads: TfrmPayloads;

implementation

{$R *.lfm}

procedure TfrmPayloads.FormCreate(Sender: TObject);
var
   i, j, LabelHeight: Integer;
begin
    Rectangles[1] := Rectangle1;
    Rectangles[2] := Rectangle2;
    Rectangles[3] := Rectangle3;

    LabelHeight := Rectangle1.Height div 9;

    // Create labels
    for i := 1 to 3 do begin
      for j := 0 to 8 do begin
          Labels[i,j] := TLabel.Create(nil);
          Labels[i,j].Align := alBottom;
          Labels[i,j].AutoSize := False;
          Labels[i,j].Parent := Rectangles[i];
          Labels[i,j].Height := LabelHeight;
          // Labels[i,j].Width := Rectangles[i].Width;
          // Labels[i,j].Top := Round(8 + LabelHeight * j);
          Labels[i,j].Font.Name := 'Arial Narrow';    // Swiss911 XCm BT';
          Labels[i,j].Font.Color := clYellow;
          Labels[i,j].Alignment := taCenter;
          // Labels[i,j].Caption := 'Line ' + IntToStr(j);
          Labels[i,j].Visible := True;
          Labels[i,j].Font.Size := Round(LabelHeight * 0.45);
      end;
    end;
end;

function RepeatString(Repeated: Boolean): String;
begin
    if Repeated then begin
        Result := ' (R)';
    end else begin
        Result := '';
    end;
end;

procedure TfrmPayloads.ShowTimeSinceUpdate(Index: Integer; TimeSinceUpdate: TDateTime; Repeated: Boolean);
begin
    if (Index >= Low(Rectangles)) and (Index <= High(Rectangles)) then begin
        Labels[Index,1].Caption := FormatDateTime('nn:ss', TimeSinceUpdate) + RepeatString(Repeated);
    end;
end;

procedure TfrmPayloads.NewPosition(Index: Integer; HABPosition: THABPosition);
begin
    inherited;

    if (Index >= Low(Rectangles)) and (Index <= High(Rectangles)) then begin
        Labels[Index,0].Caption := HABPosition.PayloadID;
        Labels[Index,1].Caption := '00:00' + RepeatString(HABPosition.Repeated);

        Labels[Index,3].Caption := FormatDateTime('hh:mm:ss', HABPosition.TimeStamp);
        Labels[Index,4].Caption := FormatFloat('0.00000', HABPosition.Latitude) + ',' + FormatFloat('0.00000', HABPosition.Longitude);
        if HABPosition.MaxAltitude > HABPosition.Altitude then begin
            Labels[Index,5].Caption := HABPosition.Altitude.ToString + 'm (' + HABPosition.MaxAltitude.ToString + 'm)';
        end else begin
            Labels[Index,5].Caption := HABPosition.Altitude.ToString + 'm';
        end;
        Labels[Index,6].Caption := FormatFloat('0.0', HABPosition.AscentRate) + ' m/s';

        if HABPosition.ContainsPrediction then begin
            Labels[Index,8].Caption := FormatFloat('0.00000', HABPosition.PredictedLatitude) + ',' + FormatFloat('0.00000', HABPosition.PredictedLongitude);
        end;
    end;
end;

end.

