unit Map;

{$mode objfpc}{$H+}

interface

uses
    Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ExtCtrls,
    LCLTMSFNCMaps, TargetForm;

type
  TFollowMode = (fmInit, fmNone, fmCar, fmPayload);

type

    { TfrmMap }

    TfrmMap = class(TfrmTarget)
        procedure FormCreate(Sender: TObject);
    private
      OKToUpdateMap: Boolean;
      FollowMode: TFollowMode;
      procedure AddOrUpdateMapMarker(PayloadID: String; Latitude: Double; Longitude: Double; ImageName: String);
    protected
      function ProcessNewPosition(Index: Integer): Boolean; override;
    public
      procedure SetMapService(MapService: TTMSFNCMapsService);
      procedure LoadForm; override;
      procedure HideForm; override;
    end;

var
    frmMap: TfrmMap;

implementation

uses directions;

{$R *.lfm}


// IF THE FOLLOWING LINE GIVES AN ERROR

{$INCLUDE 'key.pas'}

(* THEN CREATE A FILE key.pas CONTAINING:

const GoogleMapsAPIKey = '<YOUR_GOOGLE_API_KEY>';

If you aren't going to use Google Maps then you don't need an API key so set it to an empty string

THIS FILE IS SPECIFICALLY EXCLUDED in .gitignore TO AVOID SHARING API KEYS
*)

procedure TfrmMap.SetMapService(MapService: TTMSFNCMapsService);
begin
    frmMain.GMap.APIKey := GoogleMapsAPIKey;
    frmMain.GMap.Service := MapService;
end;

procedure TfrmMap.FormCreate(Sender: TObject);
begin
    inherited;

    OKToUpdateMap := True;

    // SetMapService(msGoogleMaps);     // OpenLayers);
end;

procedure TfrmMap.AddOrUpdateMapMarker(PayloadID: String; Latitude: Double; Longitude: Double; ImageName: String);
var
    MarkerIndex: Integer;
    //Marker: TMarker;
    FileName: String;
begin
    //MarkerIndex := FindMapMarker(PayloadID);
    //if MarkerIndex >= 0 then begin
    //    Marker := GMap.Markers[MarkerIndex];
    //end else begin
    //    Marker := GMap.Markers.Add(Latitude, Longitude, PayloadID);
    //    MarkerIndex := GMap.Markers.Count-1;
    //end;
    //
    //Marker.Latitude := Latitude;
    //Marker.Longitude := Longitude;
    //
    //// Marker.Icon := StringReplace('File://' + 'C:\Dropbox\dev\HAB\HABMobile2\images\' + ImageName + '.png', '\', '/',[rfReplaceAll, rfIgnoreCase]);
    //FileName := System.IOUtils.TPath.Combine(ImageFolder, ImageName + '.png');
    //
    //if FileName <> MarkerNames[MarkerIndex] then begin
    //    MarkerNames[MarkerIndex] := FileName;
    //    if FileExists(FileName) then begin
    //        Marker.Icon := StringReplace('File://' + FileName, '\', '/',[rfReplaceAll, rfIgnoreCase]);
    //    end;
    //end;
end;


function TfrmMap.ProcessNewPosition(Index: Integer): Boolean;
begin
    Result := False;

    if OKToUpdateMap then begin
        // Find or create marker fo this payload
        if Index = 0 then begin
            AddOrUpdateMapMarker('Car', Positions[0].Position.Latitude, Positions[0].Position.Longitude, 'car-blue');
            if FollowMode = fmCar then begin
                frmMain.GMap.SetCenterCoordinate(Positions[Index].Position.Latitude, Positions[Index].Position.Longitude);
            end;
        end else begin
            AddOrUpdateMapMarker(Positions[Index].Position.PayloadID,
                                 Positions[Index].Position.Latitude,
                                 Positions[Index].Position.Longitude,
                                 '???');                             // frmMain.BalloonIconName(Index));

            //PolylineItems[Index].Polyline.Path.Add(Positions[Index].Position.Latitude, Positions[Index].Position.Longitude);
            //GMap.UpdateMapPolyline(PolylineItems[Index].Polyline);
            //if (FollowMode = fmPayload) and (Index = SelectedIndex) then begin
            //    GMap.MapPanTo(Positions[Index].Position.Latitude, Positions[Index].Position.Longitude);
            //end;
        end;

        if Positions[Index].Position.ContainsPrediction then begin
            AddOrUpdateMapMarker(Positions[Index].Position.PayloadID + '-X', Positions[Index].Position.PredictedLatitude, Positions[Index].Position.PredictedLongitude, '???'); // frmMain.BalloonIconName(Index, True));
        end;
        Result := True;
    end;
end;

procedure TfrmMap.LoadForm;
begin
    inherited;
end;


procedure TfrmMap.HideForm;
begin
    inherited;
end;

end.

