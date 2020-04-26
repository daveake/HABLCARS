unit CarUpload;

interface

uses Classes, SysUtils, Math, Miscellaneous, httpsend, synacode;

type
  TCarPosition = record
    InUse:      Boolean;
    TimeStamp:  TDateTime;
    Latitude:   Double;
    Longitude:  Double;
    Altitude:   Double;
  end;

type
  TCallbackParameters = record
    Active:     Boolean;
    OK:         Boolean;
  end;

type
  TCarUpload = class(TThread)
  private
    { Private declarations }
    Position: TCarPosition;
    StatusCallback: TStatusCallback;
    procedure OurCallback;
    procedure SyncCallback(Active, OK: Boolean);
  protected
    { Protected declarations }
    Enabled: Boolean;
    procedure Execute; override;
  public
    { Public declarations }
    CallbackParameters: TCallbackParameters;
    procedure Enable;
    procedure Disable;
    procedure SetPosition(NewPosition: TCarPosition);
  public
    constructor Create(Callback: TStatusCallback);
  end;

implementation

procedure TCarUpload.Execute;
var
    URL, Params, Password, Callsign: String;
    Upload: Boolean;
    Response: TMemoryStream;
    Seconds: Integer;
begin
    Seconds := 0;
    while not Terminated do begin
        Callsign := GetSettingString('CHASE', 'Callsign', '');
        Upload := GetSettingBoolean('CHASE', 'Upload', False);

        Callsign := 'M0RPI';
        Upload := True;

        if Position.InUse and
           (Callsign <> '') and
            Upload and
           (Seconds >= Min(10, GetSettingInteger('CHASE', 'Period', 30))) then begin
            Password := 'aurora';

            Response := TMemoryStream.Create;

            try
                URL := 'http://spacenear.us/tracker/track.php' +
                       '?vehicle=' + Callsign + '_Chase';

                Params := 'time=' + FormatDateTime('hhmmss', Position.TimeStamp) +
                          '&lat=' + FormatFloat('00.000000', Position.Latitude) +
                          '&lon=' + FormatFloat('00.000000', Position.Longitude) +
                          '&alt=' + FormatFloat('0', Position.Altitude) +
                          '&pass=' + Password;

                if HttpPostURL(URL, Params, Response) then begin
                    //
                end;
                SyncCallback(True, True);
            except
                SyncCallback(True, False);
            end;

            Response.Free;

            Seconds := 0;
        end else begin
            SyncCallback(False, False);
        end;
        Sleep(10000);
        Inc(Seconds, 10);
    end;
end;

constructor TCarUpload.Create(Callback: TStatusCallback);
begin
    Enabled := True;
    StatusCallback := Callback;
    inherited Create(False);
end;

procedure TCarUpload.Enable;
begin
    Enabled := True;
end;

procedure TCarUpload.Disable;
begin
    Enabled := False;
end;

procedure TCarUpload.SetPosition(NewPosition: TCarPosition);
begin
    Position := NewPosition;
end;

procedure TCarUpload.OurCallback;
begin
    PositionCallback(GPS_SOURCE, CallbackParameters.Active, CallbackParameters.OK);
end;

procedure TCarUpload.SyncCallback(Active, OK: Boolean);
begin
    CallbackParameters.Active := Active;
    CallbackParameters.OK := OK;

    Synchronize(@OurCallback);
end;


end.
