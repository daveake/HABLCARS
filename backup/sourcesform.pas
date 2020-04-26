unit sourcesform;

{$mode objfpc}{$H+}

interface

uses
    Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, ExtCtrls,
    base, miscellaneous, source, GatewaySource, GPSSource, CarUpload;

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
        lblGateway1: TLabel;
        lblGateway1RSSI: TLabel;
        lblGPS: TLabel;
        Panel1: TPanel;
        Panel2: TPanel;
        Panel3: TPanel;
        Panel4: TPanel;
        procedure FormCreate(Sender: TObject);
    private
        Sources: Array[1..6] of TSourcePanel;
        GPSSource: TGPSSource;
        procedure NewGPSPosition(Timestamp: TDateTime; Latitude, Longitude, Altitude, Direction: Double; UsingCompass: Boolean);
        procedure GPSCallback(ID: Integer; Connected: Boolean; Line: String; HABPosition: THABPosition);
        procedure HABCallback(ID: Integer; Connected: Boolean; Line: String; HABPosition: THABPosition);
    public

    end;

var
    frmSources: TfrmSources;

implementation

{$R *.lfm}

uses Main;

{ TfrmSources }

procedure TfrmSources.GPSCallback(ID: Integer; Connected: Boolean; Line: String; HABPosition: THABPosition);
begin
    if HABPosition.InUse and not Application.Terminated then begin
        NewGPSPosition(HABPosition.TimeStamp, HABPosition.Latitude, HABPosition.Longitude, HABPosition.Altitude, HABPosition.Direction, False);
    end;
end;


procedure TfrmSources.FormCreate(Sender: TObject);
begin
    inherited;

    lblGateway1.Caption := '';
    lblGateway1RSSI.Caption := '';

    // Car uploader
    //CarUploader := TCarUpload.Create(CarStatusCallback);

    // Habitat uploader
//    HabitatUploader := THabitatThread.Create(HabitatStatusCallback);

    // GPS Source
    GPSSource := TGPSSource.Create(GPS_SOURCE, 'GPS', @GPSCallback);

    // Radio sources
    Sources[GATEWAY_SOURCE_1].ValueLabel := lblGateway1;
    Sources[GATEWAY_SOURCE_1].Source := TGatewaySource.Create(GATEWAY_SOURCE_1, 'LoRaGateway1', @HABCallback);
    Sources[GATEWAY_SOURCE_1].RSSILabel := lblGateway1RSSI;
//
//    Sources[GATEWAY_SOURCE_2].ValueLabel := lblGateway2;
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
//
//    Sources[UDP_SOURCE].ValueLabel := lblUDP;
//    Sources[UDP_SOURCE].Source := TUDPSource.Create(UDP_SOURCE, 'UDP', HABCallback);
//    Sources[UDP_SOURCE].RSSILabel := nil;
//
//    Sources[HABITAT_SOURCE].ValueLabel := lblHabitat;
//    Sources[HABITAT_SOURCE].Source := THabitatSource.Create(HABITAT_SOURCE, 'Habitat', HABCallback);
//    Sources[HABITAT_SOURCE].RSSILabel := nil;
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

