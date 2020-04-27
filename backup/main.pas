unit main;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ExtCtrls, StdCtrls,
  Buttons, LCLTMSFNCMaps, Base, SourcesForm, Splash, Source, Miscellaneous,
  payloads, direction, navigate, map, ssdv, log, settings, math;

type
  TPayload = record
      Previous:     THABPosition;
      Position:     THABPosition;
      Button:       TLabel;
      Colour:       TColor;
      ColourName:   String;
      GoodPosition: Boolean;
      LoggedLoss:   Boolean;
  end;

type
  TSource = record
    Button:         TLabel;
    LastPositionAt: TDateTime;
    Circle:         TShape;
end;

type

  { TfrmMain }

  TfrmMain = class(TForm)
      btnGoogle: TLabel;
    btnPayload: TLabel;
    btnFree: TLabel;
    btnCar: TLabel;
    btnPayloads: TLabel;
    btnSSDV: TLabel;
    btnPayload2: TLabel;
    btnGPS: TLabel;
    btnHabHub: TLabel;
    btnGateway1: TLabel;
    btnUDP: TLabel;
    btnNavigate: TLabel;
    btnMap: TLabel;
    btnDirection: TLabel;
    btnSources: TLabel;
    btnSettings: TLabel;
    btnLog: TLabel;
    btnPayload1: TLabel;
    btnPayload3: TLabel;
    lblDirection: TLabel;
    lblMap: TLabel;
    lblNavigate: TLabel;
    lblSSDV: TLabel;
    lblLog: TLabel;
    lblSources: TLabel;
    lblSettings: TLabel;
    btnPayloadsSpace8: TLabel;
    Label3: TLabel;
    lblPayload: TLabel;
    lblGPS: TLabel;
    Panel1: TPanel;
    pnlBottomBar: TPanel;
    pnlCentre: TPanel;
    pnlMap: TPanel;
    pnlTopBar1: TPanel;
    pnlTopBar2: TPanel;
    pnlTopLeft: TPanel;
    Panel6: TPanel;
    pnlMain: TPanel;
    pnlTop: TPanel;
    pnlTopBar: TPanel;
    pnlBottom: TPanel;
    pnlButtons: TPanel;
    shpGPS: TShape;
    Shape2: TShape;
    shpTopLeft: TShape;
    Shape3: TShape;
    Shape4: TShape;
    tmrLoad: TTimer;
    GMap: TTMSFNCMaps;
    tmrUpdates: TTimer;
    procedure btnCarClick(Sender: TObject);
    procedure btnCloseClick(Sender: TObject);
    procedure btnDirectionClick(Sender: TObject);
    procedure btnFreeClick(Sender: TObject);
    procedure btnGoogleClick(Sender: TObject);
    procedure btnLogClick(Sender: TObject);
    procedure btnlSourcesClick(Sender: TObject);
    procedure btnMapClick(Sender: TObject);
    procedure btnNavigateClick(Sender: TObject);
    procedure btnPayload1Click(Sender: TObject);
    procedure btnPayloadClick(Sender: TObject);
    procedure btnPayloadsClick(Sender: TObject);
    procedure btnSettingsClick(Sender: TObject);
    procedure btnSSDVClick(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure pnlBottomResize(Sender: TObject);
    procedure pnlTopBarClick(Sender: TObject);
    procedure pnlTopResize(Sender: TObject);
    procedure Shape2MouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure tmrLoadTimer(Sender: TObject);
    procedure tmrUpdatesTimer(Sender: TObject);
  private
    CurrentForm: TfrmBase;
    SelectedPayload: Integer;
    Payloads: Array[1..3] of TPayload;
    Sources: Array[0..6] of TSource;
    ChasePosition: THABPosition;
    procedure UpdatePayloadList;
    procedure SelectPayload(Button: TLabel);
    procedure ShowSelectedPayloadPosition;
    function FindOrAddPayload(HABPosition: THABPosition): Integer;
    function PlacePayloadInList(var HABPosition: THABPosition): Integer;
    procedure ShowSelectedButton(Button: TLabel);
    procedure ShowSelectedMapButton(Button: TLabel);
    procedure DoPayloadCalcs(PreviousPosition: THabPosition; var HABPosition: THABPosition);
  public
    procedure NewPosition(SourceID: Integer; HABPosition: THABPosition);
    function LoadForm(Button: TLabel; NewForm: TfrmBase): Boolean;
    procedure ShowSourceStatus(SourceID: Integer; IsActive, Recent: Boolean);
    procedure UploadStatus(SourceID: Integer; IsActive, OK: Boolean);
    function BalloonIconName(PayloadIndex: Integer; Target: Boolean=False): String;
  end;

var
  frmMain: TfrmMain;

implementation

{$R *.lfm}

{ TfrmMain }

procedure TfrmMain.pnlTopResize(Sender: TObject);
begin
    pnlTopBar.Width := pnlTop.Width - pnlTop.Height;
end;

procedure TfrmMain.Shape2MouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
end;

procedure TfrmMain.tmrLoadTimer(Sender: TObject);
begin
    tmrLoad.Enabled := False;

    // Main Forms
    frmMap := TfrmMap.Create(nil);
    frmPayloads := TfrmPayloads.Create(nil);
    frmDirection := TfrmDirection.Create(nil);
    frmNavigate := TfrmNavigate.Create(nil);
    frmSSDV := TfrmSSDV.Create(nil);
    frmLog := TfrmLog.Create(nil);
    frmSettings := TfrmSettings.Create(nil);

    // Sources Form
    frmSources := TfrmSources.Create(nil);



    // frmSources.EnableCompass;

    //LoadMapIfNotLoaded;

    frmSplash.lblLoading.Caption := 'ACCESS GRANTED';

    //lblGPS.Text := '';
    tmrUpdates.Enabled := True;
end;

procedure TfrmMain.tmrUpdatesTimer(Sender: TObject);
var
    SourceID, Index: Integer;
begin
    if frmPayloads <> nil then begin
        for Index := Low(Payloads) to High(Payloads) do begin
            if Payloads[Index].Position.InUse and (Payloads[Index].Position.ReceivedAt > 0) then begin
                frmPayloads.ShowTimeSinceUpdate(Index, Now - Payloads[Index].Position.ReceivedAt, Payloads[Index].Position.Repeated);
                if (Now - Payloads[Index].Position.ReceivedAt) > 60/86400 then begin
                    if not Payloads[Index].LoggedLoss then begin
                        Payloads[Index].Button.Font.Color := clRed;
                        Payloads[Index].LoggedLoss := True;
                        // frmLog.AddMessage(Payloads[Index].Position.PayloadID, 'Signal Lost', True, False);
                        //if GetSettingBoolean('General', 'AlarmBeeps', False) then begin
                        //    tmrBleep.Tag := 2;
                        //end;
                    end;
                end else begin
                    Payloads[Index].Button.Font.Color := clGreen;
                end;
            end;
        end;
    end;

    for SourceID := Low(Sources) to High(Sources) do begin
        if (Now - Sources[SourceID].LastPositionAt) > 60/86400 then begin
            ShowSourceStatus(SourceID, Sources[SourceID].LastPositionAt > 0, False);
        end;
    end;
end;

procedure TfrmMain.pnlBottomResize(Sender: TObject);
begin
    pnlBottomBar.Width := pnlBottom.Width - pnlBottom.Height;
end;

procedure TfrmMain.pnlTopBarClick(Sender: TObject);
begin
    LoadForm(nil, frmSplash);
end;

procedure TfrmMain.btnCloseClick(Sender: TObject);
begin
    Close;
end;

procedure TfrmMain.btnCarClick(Sender: TObject);
begin
    ShowSelectedMapButton(TLabel(Sender));
    if ChasePosition.InUse then begin
        GMap.SetCenterCoordinate(ChasePosition.Latitude, ChasePosition.Longitude);
        GMap.Options.DefaultLatitude := ChasePosition.Latitude;
        GMap.Options.DefaultLongitude := ChasePosition.Longitude;
    end;
    frmMap.FollowMode := fmCar;
end;

procedure TfrmMain.btnFreeClick(Sender: TObject);
begin
    ShowSelectedMapButton(TLabel(Sender));
    frmMap.FollowMode := fmNone;
end;

procedure TfrmMain.btnGoogleClick(Sender: TObject);
begin
    if TFontStyle.fsUnderline in btnGoogle.Font.Style then begin
        btnGoogle.Font.Style := btnGoogle.Font.Style - [TFontStyle.fsUnderline];
        frmMap.SetMapService(msOpenLayers);
    end else begin
        btnGoogle.Font.Style := btnGoogle.Font.Style + [TFontStyle.fsUnderline];
        frmMap.SetMapService(msGoogleMaps);
    end;
end;

procedure TfrmMain.btnPayloadClick(Sender: TObject);
begin
    ShowSelectedMapButton(TLabel(Sender));
    if SelectedPayload > 0 then begin
        if Payloads[SelectedPayload].Position.InUse then begin
            GMap.SetCenterCoordinate(Payloads[SelectedPayload].Position.Latitude, Payloads[SelectedPayload].Position.Longitude);
            GMap.Options.DefaultLatitude := Payloads[SelectedPayload].Position.Latitude;
            GMap.Options.DefaultLongitude := Payloads[SelectedPayload].Position.Longitude;
        end;
    end;
    frmMap.FollowMode := fmPayload;
end;

procedure TfrmMain.btnDirectionClick(Sender: TObject);
begin
    LoadForm(btnDirection, frmDirection);
end;

procedure TfrmMain.btnLogClick(Sender: TObject);
begin
    LoadForm(btnLog, frmLog);
end;

procedure TfrmMain.btnlSourcesClick(Sender: TObject);
begin
    LoadForm(btnSources, frmSources);
end;

procedure TfrmMain.btnMapClick(Sender: TObject);
begin
     LoadForm(btnMap, frmMap);
end;

procedure TfrmMain.btnNavigateClick(Sender: TObject);
begin
    LoadForm(btnNavigate, frmNavigate);
end;

procedure TfrmMain.btnPayload1Click(Sender: TObject);
begin
    SelectPayload(TLabel(Sender));
end;

procedure TfrmMain.btnPayloadsClick(Sender: TObject);
begin
    LoadForm(btnPayloads, frmPayloads);
end;

procedure TfrmMain.btnSettingsClick(Sender: TObject);
begin
    LoadForm(btnSettings, frmSettings);
end;

procedure TfrmMain.btnSSDVClick(Sender: TObject);
begin
    LoadForm(btnSSDV, frmSSDV);
end;

procedure TfrmMain.FormActivate(Sender: TObject);
const
    FirstTime: Boolean = True;
begin
    if FirstTime then begin
        FirstTime := False;

        // Splash form
        frmSplash := TfrmSplash.Create(nil);
        LoadForm(nil, frmSplash);

        // Source Form

        tmrLoad.Enabled := True;
    end;
end;

procedure TfrmMain.FormCreate(Sender: TObject);
begin
     CurrentForm := nil;

    // Payload info
    Payloads[1].Button := btnPayload1;
    Payloads[2].Button := btnPayload2;
    Payloads[3].Button := btnPayload3;

    Payloads[1].Colour := clBlue;
    Payloads[2].Colour := clRed;
    Payloads[3].Colour := clLime;

    Payloads[1].ColourName := 'blue';
    Payloads[2].ColourName := 'red';
    Payloads[3].ColourName :='green';

    // InitialiseSettings;

    SelectedPayload := 0;

    Sources[GPS_SOURCE].Button := btnGPS;
    Sources[GPS_SOURCE].Circle := shpGPS;

    Sources[GATEWAY_SOURCE_1].Button := btnGateway1;
    Sources[GATEWAY_SOURCE_1].Circle := nil;

    //Sources[GATEWAY_SOURCE_2].Button := btnGateway2;
    //Sources[GATEWAY_SOURCE_2].Circle := nil;

    //Sources[SERIAL_SOURCE].Button := btnLoRaSerial;
    //Sources[SERIAL_SOURCE].Circle := crcLoRaSerial;

    //Sources[BLUETOOTH_SOURCE].Button := btnLoRaBT;
    //Sources[BLUETOOTH_SOURCE].Circle := crcLoRaBluetooth;

    Sources[UDP_SOURCE].Button := btnUDP;
    Sources[UDP_SOURCE].Circle := nil;

    Sources[HABITAT_SOURCE].Button := btnHabHub;
    Sources[HABITAT_SOURCE].Circle := nil;
end;

function TfrmMain.LoadForm(Button: TLabel; NewForm: TfrmBase): Boolean;
begin
    if NewForm <> nil then begin
        ShowSelectedButton(Button);

        if CurrentForm <> nil then begin
            CurrentForm.HideForm;
        end;

        CurrentForm := NewForm;

        if NewForm = frmMap then begin
            pnlMap.Visible := True;
        end else begin
            pnlMap.Visible := False;

            NewForm.pnlMain.Parent := pnlCentre;
        end;

        NewForm.LoadForm;

        Result := True;
    end else begin
        Result := False;
    end;
end;

procedure TfrmMain.ShowSelectedButton(Button: TLabel);
begin
    btnPayloads.Font.Style := btnPayloads.Font.Style - [TFontStyle.fsUnderline];
    btnDirection.Font.Style := btnDirection.Font.Style - [TFontStyle.fsUnderline];
    btnMap.Font.Style := btnMap.Font.Style - [TFontStyle.fsUnderline];
    btnNavigate.Font.Style := btnNavigate.Font.Style - [TFontStyle.fsUnderline];
    btnSSDV.Font.Style := btnSSDV.Font.Style - [TFontStyle.fsUnderline];
    btnLog.Font.Style := btnLog.Font.Style - [TFontStyle.fsUnderline];
    btnSettings.Font.Style := btnSettings.Font.Style - [TFontStyle.fsUnderline];

    btnSources.Font.Style := btnSources.Font.Style - [TFontStyle.fsUnderline];

    if Button <> nil then begin
        Button.Font.Style := Button.Font.Style + [TFontStyle.fsUnderline];
    end;
end;

procedure TfrmMain.ShowSelectedMapButton(Button: TLabel);
begin
    btnCar.Font.Style := btnCar.Font.Style - [TFontStyle.fsUnderline];
    btnFree.Font.Style := btnFree.Font.Style - [TFontStyle.fsUnderline];
    btnPayload.Font.Style := btnPayload.Font.Style - [TFontStyle.fsUnderline];

    if Button <> nil then begin
        Button.Font.Style := Button.Font.Style + [TFontStyle.fsUnderline];
    end;
end;

procedure TfrmMain.NewPosition(SourceID: Integer; HABPosition: THABPosition);
var
    Index: Integer;
    PositionOK: Boolean;
begin
    ShowSourceStatus(SourceID, True, True);

    Index := PlacePayloadInList(HABPosition);

    if HABPosition.IsChase or (Index > 0) then begin
        if HABPosition.IsChase then begin
            // Chase car only
            ChasePosition := HABPosition;
    //        if frmDirection <> nil then frmDirection.NewPosition(0, Position);
        end else begin
    //        // Payloads only
            if Payloads[Index].LoggedLoss then begin
                Payloads[Index].LoggedLoss := False;
                // frmLog.AddMessage(Payloads[Index].Position.PayloadID, 'Signal Regained', True, False);
            end;

            PositionOK := (HABPosition.Latitude <> 0.0) or (HABPosition.Longitude <> 0.0);

            if PositionOK <> Payloads[Index].GoodPosition then begin
                Payloads[Index].GoodPosition := PositionOK;

                if PositionOK then begin
                    //frmLog.AddMessage(Payloads[Index].Position.PayloadID, 'GPS Position Valid', True, False);
                end else begin
                    //frmLog.AddMessage(Payloads[Index].Position.PayloadID, 'GPS Position Lost', True, False);
                end;
            end;

            if frmPayloads <> nil then frmPayloads.NewPosition(Index, HABPosition);
            // if frmSSDV <> nil then frmSSDV.NewPosition(Index, HABPosition);

            // Select payload if it's the only one
            if SelectedPayload < 1 then begin
                SelectPayload(btnPayload1);
            end;

            // Selected payload only
            if Index = SelectedPayload then begin
                if frmDirection <> nil then frmDirection.NewPosition(Index, HABPosition);
                ShowSelectedPayloadPosition;
            end;


            //if GetSettingBoolean('General', 'PositionBeeps', False) then begin
            //    tmrBleep.Tag := 1;
            //end;
        end;

        // Payloads and Chase Car
        if frmMap <> nil then begin
            if (HABPosition.Latitude <> 0) or (HABPosition.Longitude <> 0) then begin
                frmMap.NewPosition(Index, HABPosition);
            end;
        end;
    end;

    // Show active on status bar
//    if SourceID = 1 then lblGateway.FontColor := TAlphaColorRec.Black;
//    if SourceID = 2 then Label2.FontColor := TAlphaColorRec.Black;
//    if SourceID = 3 then Label3.FontColor := TAlphaColorRec.Black;
//    if SourceID = 4 then Label4.FontColor := TAlphaColorRec.Black;
//    if SourceID = 5 then Label5.FontColor := TAlphaColorRec.Black;
end;

procedure TfrmMain.ShowSourceStatus(SourceID: Integer; IsActive, Recent: Boolean);
begin
    if Sources[SourceID].Button <> nil then begin
        if IsActive then begin
            if Recent then begin
                Sources[SourceID].Button.Font.Color := clGreen;
                Sources[SourceID].LastPositionAt := Now;
            end else begin
                Sources[SourceID].Button.Font.Color := clRed;
            end;
        end else begin
            Sources[SourceID].Button.Font.Color := clBlack;
        end;
    end;
end;

procedure TfrmMain.UploadStatus(SourceID: Integer; IsActive, OK: Boolean);
begin
    // Show status on screen
    if Sources[SourceID].Circle <> nil then begin
        if IsActive then begin
            Sources[SourceID].Button.Color := $006FDFF1;
            if OK then begin
                Sources[SourceID].Circle.Brush.Color := clLime;
            end else begin
                Sources[SourceID].Circle.Brush.Color := clRed;
            end;
        end else begin
            Sources[SourceID].Button.Color := $0014AFCB;
            Sources[SourceID].Circle.Brush.Color := clSilver;
        end;
    end;

    // Log errors in debug screen
    //if Active and (not OK) and (frmDebug <> nil) then begin
    //    frmDebug.Debug(SourceName(SourceID) + ' failed to upload position');
    //end;
end;

function TfrmMain.PlacePayloadInList(var HABPosition: THABPosition): Integer;
var
    Index: Integer;
    PayloadChanged: Boolean;
begin
    Result := 0;

    if HABPosition.InUse and not HABPosition.IsChase then begin
        Index := FindOrAddPayload(HABPosition);

        if Index > 0 then begin
            // Update forms with payload list, if it has changed
            if (not Payloads[Index].Position.InUse) or (HABPosition.PayloadID <> Payloads[Index].Position.PayloadID) then begin
                // frmLog.AddMessage(HABPosition.PayloadID, 'Online', True, True);
                PayloadChanged := True;
            end else begin
                PayloadChanged := False;
            end;

            // if (Position.TimeStamp - Payloads[Index].Previous.TimeStamp) >= 1/86400 then begin
            if (HABPosition.TimeStamp > Payloads[Index].Position.TimeStamp) or (HABPosition.PayloadID <> Payloads[Index].Position.PayloadID) then begin
                HABPosition.FlightMode := Payloads[Index].Previous.FlightMode;

                // Calculate ascent rate etc
                DoPayloadCalcs(Payloads[Index].Previous, HABPosition);

                // Update buttons
                Payloads[Index].Button.Caption := HABPosition.PayloadID;
                Payloads[Index].Button.Color := $006FDFF1;

                // Store new position
                Payloads[Index].Previous := Payloads[Index].Position;
                Payloads[Index].Position := HABPosition;
                Payloads[Index].Previous.FlightMode := HABPosition.FlightMode;

                // Select payload if it's the only one
                if SelectedPayload < 1 then begin
                    SelectPayload(btnPayload1);
                end;

                if PayloadChanged then begin
                    UpdatePayloadList;
                end;

                Result := Index;
            end;
        end;
    end;
end;

function TfrmMain.FindOrAddPayload(HABPosition: THABPosition): Integer;
var
    i: Integer;
begin
    // Look for same payload
    for i := Low(Payloads) to High(Payloads) do begin
        if Payloads[i].Position.InUse then begin
            if HABPosition.PayloadID = Payloads[i].Position.PayloadID then begin
                Result := i;
                Exit;
            end;
        end;
    end;

    // Look for empty slot
    for i := Low(Payloads) to High(Payloads) do begin
        if not Payloads[i].Position.InUse then begin
            Result := i;
            Exit;
        end;
    end;

    // Look for oldest payload
    Result := Low(Payloads);
    for i := Low(Payloads)+1 to High(Payloads) do begin
        if Payloads[i].Position.TimeStamp < Payloads[Result].Position.TimeStamp then begin
            // This one is older than oldest so far
            Result := i;
        end;
    end;
end;

procedure TfrmMain.UpdatePayloadList;
var
    PayloadList: String;
    i: Integer;
begin
    PayloadList := '';

    for i := Low(Payloads) to High(Payloads) do begin
        if Payloads[i].Position.InUse then begin
            PayloadList := PayloadList + ';' + Payloads[i].Position.PayloadID;
        end;
    end;

    PayloadList := Copy(PayloadList, 2, 999);

    //!! frmSources.UpdatePayloadList(PayloadList);

    for i := Low(Payloads) to High(Payloads) do begin
        //!! frmNavigate.UpdatePayloadID(i, Payloads[i].Position.PayloadID);
    end;
end;

procedure TfrmMain.SelectPayload(Button: TLabel);
begin
    if Button.Tag <> SelectedPayload then begin
        if Payloads[Button.Tag].Position.InUse then begin
            // Select payload
            SelectedPayload := Button.Tag;

            // Show selected payload on buttons
            btnPayload1.Font.Style := btnPayload1.Font.Style - [TFontStyle.fsUnderline];
            btnPayload2.Font.Style := btnPayload1.Font.Style - [TFontStyle.fsUnderline];
            btnPayload2.Font.Style := btnPayload1.Font.Style - [TFontStyle.fsUnderline];
            Button.Font.Style := btnPayload1.Font.Style + [TFontStyle.fsUnderline];

            // Tell forms that need to know
            //if frmSSDV <> nil then frmSSDV.NewSelection(SelectedPayload);
            //if frmDirection <> nil then frmDirection.NewSelection(SelectedPayload);
            //if frmNavigate <> nil then frmNavigate.NewSelection(SelectedPayload);
            //if frmMap <> nil then frmMap.NewSelection(SelectedPayload);

            // Update main screen
            ShowSelectedPayloadPosition;
        end;
    end;
end;

procedure TfrmMain.ShowSelectedPayloadPosition;
begin
    with Payloads[SelectedPayload].Position do begin
        lblPayload.Caption := FormatDateTime('hh:nn:ss', TimeStamp) + '  ' +
                              Format('%2.6f', [Latitude]) + ',' +
                              Format('%2.6f', [Longitude]) + ' at ' +
                              Format('%.0f', [Altitude]) + 'm';
    end;
end;

function TfrmMain.BalloonIconName(PayloadIndex: Integer; Target: Boolean=False): String;
begin

    Result := 'balloon-' + Payloads[PayloadIndex].ColourName;

    if Target then begin
        Result := 'x-' + Payloads[PayloadIndex].ColourName;
    end else begin
        case Payloads[PayloadIndex].Position.FlightMode of
            fmIdle:         Result := 'payload-' + Payloads[PayloadIndex].ColourName;
            fmLaunched:     Result := 'balloon-' + Payloads[PayloadIndex].ColourName;
            fmDescending:   Result := 'parachute-' + Payloads[PayloadIndex].ColourName;
            fmLanded:       Result := 'payload-' + Payloads[PayloadIndex].ColourName;
        end;
    end;
end;

procedure TfrmMain.DoPayloadCalcs(PreviousPosition: THabPosition; var HABPosition: THABPosition);
const
    FlightModes: Array[0..8] of String = ('Idle', 'Launched', 'Descending', 'Homing', 'Direct To Target', 'Downwind', 'Upwind', 'Landing', 'Landed');
begin
    HABPosition.AscentRate := (HABPosition.Altitude - PreviousPosition.Altitude) / (86400 * (HABPosition.TimeStamp - PreviousPosition.TimeStamp));
    HABPosition.MaxAltitude := max(HABPosition.Altitude, PreviousPosition.MaxAltitude);

    // Flight mode
    case PreviousPosition.FlightMode of
        fmIdle: begin
            if ((HABPosition.AscentRate > 2.0) and (HABPosition.Altitude > 100)) or
               (HABPosition.Altitude > 5000) or
               (Abs(Position.AscentRate) > 20) or
               ((HABPosition.AscentRate > 1.0) and (HABPosition.Altitude > 300)) then begin
                HABPosition.FlightMode := fmLaunched;
                // frmLog.AddMessage(HABPosition.PayloadID, FlightModes[Ord(Position.FlightMode)], True, True);
            end;
        end;

        fmLaunched: begin
            if HABPosition.AscentRate < -4 then begin
                HABPosition.FlightMode := fmDescending;
                // frmLog.AddMessage(Position.PayloadID, FlightModes[Ord(Position.FlightMode)], True, True);
                if GetSettingBoolean('General', 'AlarmBeeps', False) then begin
                    //tmrBleep.Tag := 3;
                end;
            end;
        end;

        fmDescending: begin
            if HABPosition.AscentRate > -1 then begin
                HABPosition.FlightMode := fmLanded;
                // frmLog.AddMessage(Position.PayloadID, FlightModes[Ord(Position.FlightMode)], True, True);
            end;
        end;

        fmLanded: begin
            if ((HABPosition.AscentRate > 3.0) and (HABPosition.Altitude > 100)) or
               ((HABPosition.AscentRate > 2.0) and (HABPosition.Altitude > 500)) then begin
                HABPosition.FlightMode := fmLaunched;
                // frmLog.AddMessage(Position.PayloadID, FlightModes[Ord(Position.FlightMode)], True, True);
            end;
        end;
    end;
end;

end.

