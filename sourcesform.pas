unit sourcesform;

{$mode objfpc}{$H+}

interface

uses
    Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, ExtCtrls,
    base, miscellaneous, source, GatewaySource, GPSSource, CarUpload, HabitatSource, UDPSource;

type
  TSourcePanel = record
      Source:       TSource;
      ValueLabel:   TLabel;
      RSSILabel:    TLabel;
      CurrentRSSI:  String;
      PacketRSSI:   String;
      FreqError:    String;
  end;

type

    { TfrmSources }

    TfrmSources = class(TfrmBase)
        Label1: TLabel;
        Label2: TLabel;
        Label3: TLabel;
        Label4: TLabel;
        Label5: TLabel;
        lblGateway1: TLabel;
        lblGateway1RSSI: TLabel;
        lblHabitat: TLabel;
        lblGPS: TLabel;
        lblUDP: TLabel;
        Panel1: TPanel;
        Panel2: TPanel;
        Panel3: TPanel;
        Panel4: TPanel;
        Panel5: TPanel;
        Panel6: TPanel;
        Panel7: TPanel;
        Panel8: TPanel;
        procedure FormCreate(Sender: TObject);
    private
        Sources: Array[1..6] of TSourcePanel;
        GPSSource: TGPSSource;
        CarUploader: TCarUpload;
        procedure NewGPSPosition(Timestamp: TDateTime; Latitude, Longitude, Altitude, Direction: Double; UsingCompass: Boolean);
        procedure GPSCallback(ID: Integer; Connected: Boolean; Line: String; HABPosition: THABPosition);
        procedure HABCallback(ID: Integer; Connected: Boolean; Line: String; HABPosition: THABPosition);
        procedure HabitatStatusCallback(SourceID: Integer; IsActive, OK: Boolean);
        procedure CarStatusCallback(SourceID: Integer; IsActive, OK: Boolean);
    public
        procedure SendParameterToSource(SourceIndex: Integer; ValueName, Value: String);
    end;

var
    frmSources: TfrmSources;

implementation

{$R *.lfm}

uses main;

{ TfrmSources }

procedure TfrmSources.SendParameterToSource(SourceIndex: Integer; ValueName, Value: String);
begin
    Sources[SourceIndex].Source.SendSetting(ValueName, Value);
end;


procedure TfrmSources.NewGPSPosition(Timestamp: TDateTime; Latitude, Longitude, Altitude, Direction: Double; UsingCompass: Boolean);
var
    GPSPosition: THABPosition;
    Temp: String;
    CarPosition: TCarPosition;
begin
    GPSPosition := default(THABPosition);

    Temp := FormatDateTime('hh:nn:ss', Timestamp) + '  ' +
                           Format('%2.6f', [Latitude]) + ',' +
                           Format('%2.6f', [Longitude]) + ', ' +
                           Format('%.0f', [Altitude]) + 'm ';
    frmMain.lblGPS.Caption := Temp;

    lblGPS.Caption := Temp;

    // if Position.TimeStamp <> Timestamp then begin
        GPSPosition.ReceivedAt := Now;
    // end;

    GPSPosition.TimeStamp := Timestamp;
    GPSPosition.Latitude := Latitude;
    GPSPosition.Longitude := Longitude;
    GPSPosition.Altitude := Altitude;

    //if IsNan(Direction) then begin
    //    Position.DirectionValid := False;
    //end else begin
    //    Position.DirectionValid := True;
    //    if UsingCompass then begin
    //        lblDirection.Text := 'Compass Direction = ' + FormatFloat('0.0', Direction);
    //    end else begin
    //        lblDirection.Text := 'GPS Direction = ' + FormatFloat('0.0', Direction);
    //    end;
    //    Position.Direction := Direction;
    //end;

    GPSPosition.InUse := True;
    GPSPosition.IsChase := True;
    GPSPosition.PayloadID := 'Chase';

    frmMain.NewPosition(0, GPSPosition);

    if CarUploader <> nil then begin
        CarPosition.InUse := True;
        CarPosition.TimeStamp := GPSPosition.TimeStamp;
        CarPosition.Latitude := GPSPosition.Latitude;
        CarPosition.Longitude := GPSPosition.Longitude;
        CarPosition.Altitude := GPSPosition.Altitude;

        CarUploader.SetPosition(CarPosition);
    end;
end;

procedure TfrmSources.HabitatStatusCallback(SourceID: Integer; IsActive, OK: Boolean);
begin
    frmMain.UploadStatus(SourceID, IsActive, OK);
end;


procedure TfrmSources.CarStatusCallback(SourceID: Integer; IsActive, OK: Boolean);
begin
    frmMain.UploadStatus(SourceID, IsActive, OK);
end;

procedure TfrmSources.GPSCallback(ID: Integer; Connected: Boolean; Line: String; HABPosition: THABPosition);
begin
    if HABPosition.InUse and not Application.Terminated then begin
        NewGPSPosition(HABPosition.TimeStamp, HABPosition.Latitude, HABPosition.Longitude, HABPosition.Altitude, HABPosition.Direction, False);
    end else if Line <> '' then begin
        lblGPS.Caption := Line;
    end;
end;


procedure TfrmSources.FormCreate(Sender: TObject);
begin
    inherited;

    lblGateway1.Caption := '';
    lblGateway1RSSI.Caption := '';

    // Car uploader
    CarUploader := TCarUpload.Create(@CarStatusCallback);

    // Habitat uploader
    // HabitatUploader := THabitatThread.Create(HabitatStatusCallback);

    // GPS Source
    GPSSource := TGPSSource.Create(GPS_SOURCE, 'GPS', @GPSCallback);

    // Radio sources
    Sources[GATEWAY_SOURCE_1].ValueLabel := lblGateway1;
    Sources[GATEWAY_SOURCE_1].Source := TGatewaySource.Create(GATEWAY_SOURCE_1, 'LoRaGateway1', @HABCallback);
    Sources[GATEWAY_SOURCE_1].RSSILabel := lblGateway1RSSI;
//
//    Sources[GATEWAY_SOURCE_2].ValueLabel := lblHabitat;
//    Sources[GATEWAY_SOURCE_2].Source := TGatewaySource.Create(GATEWAY_SOURCE_2, 'LoRaGateway2', HABCallback);
//    Sources[GATEWAY_SOURCE_2].RSSILabel := lblGateway2RSSI;
//
//    // USB / Serial source
//    Sources[SERIAL_SOURCE].ValueLabel := lblSerial;
//    Sources[SERIAL_SOURCE].RSSILabel := lblSerialRSSI;
//    {$IF Defined(MSWINDOWS) or Defined(ANDROID)}
//        Sources[SERIAL_SOURCE].Source := TSerialSource.Create(SERIAL_SOURCE, 'LoRaSerial', HABCallback);
//    {$ELSE}
//        Label1.Text := '';
//        lblSerial.Text := '';
//    {$ENDIF}
//
//    // Bluetooth source
//    Sources[BLUETOOTH_SOURCE].ValueLabel := lblBT;
//    Sources[BLUETOOTH_SOURCE].RSSILabel := lblBluetoothRSSI;
//    {$IF Defined(MSWINDOWS) or Defined(ANDROID)}
//        Sources[BLUETOOTH_SOURCE].Source := TBluetoothSource.Create(BLUETOOTH_SOURCE, 'LoRaBluetooth', HABCallback);
//    {$ELSE}
//        Sources[BLUETOOTH_SOURCE].Source := TBLESource.Create(BLUETOOTH_SOURCE, 'LoRaBluetooth', HABCallback);
//        Label9.Text := 'BLE';
//    {$ENDIF}

    Sources[UDP_SOURCE].ValueLabel := lblUDP;
    Sources[UDP_SOURCE].Source := TUDPSource.Create(UDP_SOURCE, 'UDP', @HABCallback);
    Sources[UDP_SOURCE].RSSILabel := nil;

    Sources[HABITAT_SOURCE].ValueLabel := lblHabitat;
    Sources[HABITAT_SOURCE].Source := THabitatSource.Create(HABITAT_SOURCE, 'Habitat', @HABCallback);
    Sources[HABITAT_SOURCE].RSSILabel := nil;
end;

procedure TfrmSources.HABCallback(ID: Integer; Connected: Boolean; Line: String; HABPosition: THABPosition);
var
    Callsign: String;
begin
    // New Position                                  FLastError
    if HABPosition.InUse then begin
        frmMain.NewPosition(ID, HABPosition);

        if ID = SERIAL_SOURCE then begin
            if GetSettingBoolean('LoRaSerial', 'Habitat', False) then begin
                Callsign := GetSettingString('General', 'Callsign', '');
                if Callsign <> '' then begin
                    // HabitatUploader.SaveTelemetryToHabitat(ID, Position.Line, Callsign);
                end;
            end;
        end else if ID = BLUETOOTH_SOURCE then begin
            if GetSettingBoolean('LoRaBluetooth', 'Habitat', False) then begin
                Callsign := GetSettingString('General', 'Callsign', '');
                if Callsign <> '' then begin
                    // HabitatUploader.SaveTelemetryToHabitat(ID, Position.Line, Callsign);
                end;
            end;
        end;

        Sources[ID].ValueLabel.Caption := Copy(HABPosition.Line, 1, 100);
    end else if Line <> '' then begin
        Sources[ID].ValueLabel.Caption := Line;
    end;

    // SSDV Packet
    if HABPosition.IsSSDV then begin
        if GetSettingBoolean('LoRaSerial', 'SSDV', False) then begin
            Callsign := GetSettingString('LoRaSerial', 'Callsign', '');
            if Callsign <> '' then begin
                // HabitatUploader.SaveSSDVToHabitat(Position.Line, Callsign);
            end;
        end;
    end;

    if HABPosition.HasCurrentRSSI then begin
        Sources[ID].CurrentRSSI := 'Current RSSI ' + IntToStr(HABPosition.CurrentRSSI)
    end;

    if HABPosition.HasPacketRSSI then begin
        Sources[ID].PacketRSSI := ',    Packet RSSI ' + IntToStr(HABPosition.PacketRSSI);
    end;

    if HABPosition.HasFrequency then begin
        Sources[ID].FreqError := ',    Frequency Offset = ' + FormatFloat('0', HABPosition.FrequencyError*1000) + ' Hz';
    end;

    if Sources[ID].RSSILabel <> nil then begin
        Sources[ID].RSSILabel.Caption := Sources[ID].CurrentRSSI + Sources[ID].PacketRSSI + Sources[ID].FreqError;
    end;
end;

end.

