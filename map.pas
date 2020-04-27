unit Map;

{$mode objfpc}{$H+}

interface

uses
    Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ExtCtrls,
    LCLTMSFNCMaps, TargetForm, Source;

type
  TFollowMode = (fmInit, fmNone, fmCar, fmPayload);

type
  TMapItem = record
    Marker:              TTMSFNCMapsMarker;
    //LandingMarker:     TTMSFNCMapsMarker;
    ImageName:           String;
  end;

type

    { TfrmMap }

    TfrmMap = class(TfrmTarget)
      procedure FormCreate(Sender: TObject);
    private
      OKToUpdateMap: Boolean;
      MapItems: Array[0..3] of TMapItem;
      procedure AddOrUpdateMapMarker(Index: Integer; PayloadID: String; Latitude: Double; Longitude: Double; ImageName: String);
    protected
      //function ProcessNewPosition(Index: Integer): Boolean; override;
    public
      FollowMode: TFollowMode;
      procedure SetMapService(MapService: TTMSFNCMapsService);
      procedure LoadForm; override;
      procedure HideForm; override;
      procedure NewPosition(Index: Integer; HABPosition: THABPosition); override;
    end;

var
    frmMap: TfrmMap;

implementation

uses main, Miscellaneous;

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
    if MapService = msGoogleMaps then begin
        frmMain.GMap.APIKey := GoogleMapsAPIKey;
    end else begin
        frmMain.GMap.APIKey := '';
    end;

    frmMain.GMap.Service := MapService;
end;

procedure TfrmMap.FormCreate(Sender: TObject);
begin
    inherited;

    OKToUpdateMap := True;

    // SetMapService(msGoogleMaps);     // OpenLayers);
end;

procedure TfrmMap.AddOrUpdateMapMarker(Index: Integer; PayloadID: String; Latitude: Double; Longitude: Double; ImageName: String);
var
    FileName: String;
begin
    FileName := ImageFolder + ImageName + '.png';
    // http://51.89.167.6/markers/car-blue.png

    //if FileExists(FileName) then begin
    //    FileName := 'file:///' + FileName;
    //end else begin
    //    FileName := '';
    //end;

    frmMain.GMap.BeginUpdate;

    if MapItems[Index].Marker = nil then begin
        MapItems[Index].Marker := frmMain.GMap.AddMarker(Latitude, Longitude, PayloadID, FileName);
        MapItems[Index].ImageName := ImageName;
    end else begin
        MapItems[Index].Marker.Latitude := Latitude;
        MapItems[Index].Marker.Longitude := Longitude;
    end;

    if ImageName <> MapItems[Index].ImageName then begin
        MapItems[Index].ImageName := ImageName;
        MapItems[Index].Marker.IconURL := FileName;
    end;

    frmMain.GMap.EndUpdate;
end;


procedure TfrmMap.NewPosition(Index: Integer; HABPosition: THABPosition);
begin
    inherited;

    if OKToUpdateMap then begin
        // Find or create marker fo this payload
        if Index = 0 then begin
            AddOrUpdateMapMarker(Index, 'Car', HABPosition.Latitude, HABPosition.Longitude, 'car-blue');
            if FollowMode = fmCar then begin
                frmMain.GMap.SetCenterCoordinate(Positions[Index].Position.Latitude, Positions[Index].Position.Longitude);
                frmMain.GMap.Options.DefaultLatitude := Positions[Index].Position.Latitude;
                frmMain.GMap.Options.DefaultLongitude := Positions[Index].Position.Longitude;
            end;
        end else begin
            AddOrUpdateMapMarker(Index,
                                 HABPosition.PayloadID,
                                 HABPosition.Latitude,
                                 HABPosition.Longitude,
                                 frmMain.BalloonIconName(Index));

            //PolylineItems[Index].Polyline.Path.Add(Positions[Index].Position.Latitude, Positions[Index].Position.Longitude);
            //GMap.UpdateMapPolyline(PolylineItems[Index].Polyline);
            if (FollowMode = fmPayload) and (Index = SelectedIndex) then begin
                frmMain.GMap.SetCenterCoordinate(Positions[Index].Position.Latitude, Positions[Index].Position.Longitude);
                frmMain.GMap.Options.DefaultLatitude := Positions[Index].Position.Latitude;
                frmMain.GMap.Options.DefaultLongitude := Positions[Index].Position.Longitude;
            end;
        end;

        //if Positions[Index].Position.ContainsPrediction then begin
        //    AddOrUpdateMapMarker(Index, Positions[Index].Position.PayloadID + '-X', Positions[Index].Position.PredictedLatitude, Positions[Index].Position.PredictedLongitude, '???'); // frmMain.BalloonIconName(Index, True));
        //end;
        // Result := True;
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

