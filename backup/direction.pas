unit direction;

{$mode objfpc}{$H+}

interface

uses
    Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ExtCtrls, StdCtrls,
    TargetForm, math, Source, Miscellaneous;

type

    { TfrmDirection }

    TfrmDirection = class(TfrmTarget)
        btnGoogle: TLabel;
        Label1: TLabel;
        lblAscentRate: TLabel;
        lblDistance: TLabel;
        lblRelativeAltitude: TLabel;
        lblTTL: TLabel;
        Label2: TLabel;
        Label3: TLabel;
        Label4: TLabel;
        Label5: TLabel;
        Label6: TLabel;
        lblLatitude: TLabel;
        lblLongitude: TLabel;
        lblAltitude: TLabel;
        shpCompass: TShape;
        shpDot: TShape;
        Shape3: TShape;
        Shape4: TShape;
        Shape5: TShape;
        Shape6: TShape;
        Shape7: TShape;
    private
    protected
        function ProcessNewPosition(Index: Integer): Boolean; override;
        procedure ProcessNewDirection(Index: Integer); override;
    public

    end;

var
    frmDirection: TfrmDirection;

implementation

{$R *.lfm}

function CalculateDistance(HABLatitude, HabLongitude, CarLatitude, CarLongitude: Double): Double;
begin
    // Return distance in metres

    HABLatitude := HABLatitude * Pi / 180;
    HabLongitude := HABLongitude * Pi / 180;
    CarLatitude := CarLatitude * Pi / 180;
    CarLongitude := CarLongitude * Pi / 180;

    Result := 6371000 * arccos(sin(CarLatitude) * sin(HABLatitude) +
                               cos(CarLatitude) * cos(HABLatitude) * cos(HABLongitude-CarLongitude));
end;

function CalculateDirection(HABLatitude, HabLongitude, CarLatitude, CarLongitude: Double): Double;
var
    x, y: Double;
begin
    HABLatitude := HABLatitude * Pi / 180;
    HabLongitude := HABLongitude * Pi / 180;
    CarLatitude := CarLatitude * Pi / 180;
    CarLongitude := CarLongitude * Pi / 180;

    y := sin(HABLongitude - CarLongitude) * cos(HABLatitude);
    x := cos(CarLatitude) * sin(HABLatitude) - sin(CarLatitude) * cos(HABLatitude) * cos(HABLongitude - CarLongitude);

    Result := ArcTan2(y, x);    // * 180 / Pi;
end;

function TfrmDirection.ProcessNewPosition(Index: Integer): Boolean;
begin
    if (SelectedIndex > 0) and (Index = SelectedIndex) then begin
        with Positions[SelectedIndex].Position do begin
            lblLatitude.Caption := FormatFloat('0.00000', Latitude);
            lblLongitude.Caption := FormatFloat('0.00000', Longitude);
            lblAltitude.Caption := FormatFloat('0', Altitude) + 'm';
            lblAscentRate.Caption := FormatFloat('0.0', AscentRate) + 'm/s';
        end;
    end;

    Result := inherited;
end;

procedure TfrmDirection.ProcessNewDirection(Index: Integer);
var
    Distance, Direction, TargetLatitude, TargetLongitude, Radius, Seconds: Double;
begin
    inherited;

    //if LCARSLabelIsChecked(chkPrediction) and Positions[SelectedIndex].Position.ContainsPrediction then begin
    //    TargetLatitude := Positions[SelectedIndex].Position.PredictedLatitude;
    //    TargetLongitude := Positions[SelectedIndex].Position.PredictedLongitude;
    //end else begin
    //    TargetLatitude := Positions[SelectedIndex].Position.Latitude;
    //    TargetLongitude := Positions[SelectedIndex].Position.Longitude;
    //end;

    // Horizontal distance to payload
    Distance := CalculateDistance(TargetLatitude,
                                  TargetLongitude,
                                  Positions[0].Position.Latitude,
                                  Positions[0].Position.Longitude);

    if Distance < 2000 then begin
        lblDistance.Caption := FormatFloat('0', Distance) + 'm';
    end else begin
        lblDistance.Caption := FormatFloat('0.0', Distance/1000) + 'km';
    end;

    // Direction to payload
    Direction := CalculateDirection(TargetLatitude,
                                    TargetLongitude,
                                    Positions[0].Position.Latitude,
                                    Positions[0].Position.Longitude);

    // Relative to GPS direction
    Direction := Direction - Positions[SelectedIndex].Position.Direction * Pi / 180;

    Radius := Min(shpCompass.Width, shpCompass.Height) / 2;
    Radius := Radius * (1 - shpCompass.Pen.Width * 0.48 / Radius);

    shpDot.Left := Round(((shpCompass.Width / 2) + shpCompass.BorderSpacing.Around - shpDot.Width / 2) + Radius * sin(Direction));
    shpDot.Top := Round(((shpCompass.Height / 2) + shpCompass.BorderSpacing.Around - shpDot.Height / 2) - Radius * cos(Direction));

    if Positions[0].Position.DirectionValid then begin
        shpDot.Brush.Color := clLime;
    end else begin
        shpDot.Brush.Color := clRed;
    end;

    // Altitude, or vertical distance to payload, as appropriate
    if not IsNan(Positions[0].Position.Altitude) then begin
        if Positions[SelectedIndex].Position.Altitude >= (Positions[0].Position.Altitude + 2000) then begin
            lblRelativeAltitude.Caption := '';
        end else if Positions[SelectedIndex].Position.Altitude >= Positions[0].Position.Altitude then begin
            lblRelativeAltitude.Caption := '+' + IntToStr(Round(Positions[SelectedIndex].Position.Altitude - Positions[0].Position.Altitude)) + 'm';
        end else begin
            lblRelativeAltitude.Caption := IntToStr(Round(Positions[SelectedIndex].Position.Altitude - Positions[0].Position.Altitude)) + 'm';
        end;
    end;

    if Positions[SelectedIndex].Position.FlightMode = fmDescending then begin
        Seconds := CalculateDescentTime(Positions[SelectedIndex].Position.Altitude, -Positions[SelectedIndex].Position.AscentRate, Positions[0].Position.Altitude);

        if Seconds >= 60 then begin
            lblTTL.Caption := FormatFloat('0', Seconds / 60) + ' min';
        end else begin
            lblTTL.Caption := FormatFloat('0', Seconds) + ' s';
        end;
    end else begin
        lblTTL.Caption := '';
    end;
end;

end.

