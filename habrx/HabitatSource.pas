unit HabitatSource;

interface

uses Source, DateUtils, SysUtils, Classes, httpsend, synacode;

type
  THabitatSource = class(TSource)
  private
    { Private declarations }
    function ProcessHabitatResponse(Strings: TStringList): Boolean;
    procedure GetAndProcessHabitatResponse(URL: String);
  protected
    { Protected declarations }
    procedure Execute; override;
  public
    { Public declarations }
    PayloadList: String;
  public
    constructor Create(ID: Integer; Group: String; Callback: TSourcePositionCallback);
  end;

implementation

uses Miscellaneous;

constructor THabitatSource.Create(ID: Integer; Group: String; Callback: TSourcePositionCallback);
begin
    inherited Create(ID, Group, Callback);
end;

procedure THabitatSource.GetAndProcessHabitatResponse(URL: String);
var
    Response: TStringList;
    html: string;
begin
    Response := TStringList.Create;

    try
        if HttpGetText(URL, Response) then begin
           ProcessHabitatResponse(Response);
        end;
    finally
        Response.Free;
    end;
end;


//            ResponseStream := TMemoryStream.Create;
//            HTTP := TIdHTTP.Create(nil);
//            HTTP.Request.ContentType := 'text/xml; charset=utf-8';
//            HTTP.Request.ContentEncoding := 'utf-8';
//            HTTP.HTTPOptions := [hoForceEncodeParams];
//            HTTP.Get(url, responseStream);
//            with TStringStream.Create do begin
//                try
//                    try
//                        LoadFromStream(ResponseStream);
//                        Result := DataString;
//                    except
//                        on E : Exception do begin
//                            SendMessage('Error: '+E.Message);
//                        end;
//                    end;
//                finally
//                    Free;
//                end;
//            end;
//        except
//            //
//        end;
//    finally
//        try
//            HTTP.Disconnect;
//        except
//        end;
//
//        HTTP.Free;
//        ResponseStream.Free;
//    end;
//end;

function THabitatSource.ProcessHabitatResponse(Strings: TStringList): Boolean;
var
    i: Integer;
    Position: THABPosition;
    Line, TimeStamp: String;
    GotPosition: Boolean;
begin
    GotPosition := False;

    for i := 0 to Strings.Count-1 do begin
        Line := Strings[i];
        if GetJSONInteger(Line, 'position_id') > 0 then begin
            FillChar(Position, SizeOf(Position), 0);
            // "position_id":"21593335","vehicle":"PTE2"
            Position.PayloadID := GetJSONString(Line, 'vehicle');

            // "gps_time":"2018-09-19 11:14:58",
            TimeStamp := GetJSONString(Line, 'gps_time');

            Position.TimeStamp := EncodeDateTime(StrToIntDef(Copy(TimeStamp, 1, 4), 0),
                                                 StrToIntDef(Copy(TimeStamp, 6, 2), 0),
                                                 StrToIntDef(Copy(TimeStamp, 9, 2), 0),
                                                 StrToIntDef(Copy(TimeStamp, 12, 2), 0),
                                                 StrToIntDef(Copy(TimeStamp, 15, 2), 0),
                                                 StrToIntDef(Copy(TimeStamp, 18, 2), 0),
                                                 0);

            // Ignore if old
            if Position.TimeStamp > (Now - 0.25) then begin
                // "gps_lat":"51.95016","gps_lon":"-2.5446","gps_alt":"130"
                Position.Latitude := GetJSONFloat(Line, 'gps_lat');
                Position.Longitude := GetJSONFloat(Line, 'gps_lon');
                Position.Altitude := GetJSONFloat(Line, 'gps_alt');

                // "data":{"landing_speed":"0.0","cda":"0.66","predicted_latitude":"0.0","temperature_internal":"40.1","ttl":0,"satellites":10,"predicted_longitude":"0.0"},"callsign":"M0RPI\/5","sequence":"50"},
                // "predicted_latitude":"0.0","temperature_internal":"40.1","ttl":0,"satellites":10,"predicted_longitude":"0.0"},"callsign":"M0RPI\/5","sequence":"50"},
                Position.PredictedLatitude := GetJSONFloat(Line, 'predicted_latitude');
                Position.PredictedLongitude := GetJSONFloat(Line, 'predicted_longitude');
                Position.ContainsPrediction := (Position.PredictedLatitude <> 0) or (Position.PredictedLongitude <> 0);

                Position.Line := ' ' + Position.PayloadID + ': ' + FormatDateTime('hh:nn:ss', Position.TimeStamp) + ',' + Position.Latitude.ToString + ',' + Position.Longitude.ToString + ',' + Position.Altitude.ToString;

                Position.ReceivedAt := Now;
                Position.InUse := True;

                SyncCallback(SourceID, True, '', Position);

                Position.ReceivedAt := Now;

                GotPosition := True;
            end;
        end;
    end;

    Result := GotPosition;
end;


procedure THabitatSource.Execute;
var
    List, WhiteList, SearchList, PayloadID, Request: String;
begin
    while not Terminated do begin
        if GetSettingBoolean(GroupName, 'Enable', False) then begin
            // Get white list
            WhiteList := GetSettingString('Habitat', 'WhiteList', '');

            // Get current payloads
            List := PayloadList;
            SearchList := ',' + PayloadList + ',';

            // Cycle through whitelist payloads
            while WhiteList <> '' do begin
                PayloadID := GetString(WhiteList);

                if PayloadID <> '' then begin
                    if Pos(',' + PayloadID + ',', SearchList) = 0 then begin
                        if List = '' then begin
                            List := PayloadID;
                        end else begin
                            List := List + ';' + PayloadID;
                        end;
                    end;
                end;
            end;

            if List = '' then begin
                SendMessage('No payloads yet');
            end else begin
                Request := 'http://spacenear.us/tracker/datanew.php?mode=Position&type=positions&format=json&max_positions=10&vehicles=' + List;
                GetAndProcessHabitatResponse(Request);
                Sleep(9000);
            end;
        end else begin
            SendMessage('Habitat Download Disabled');
        end;
        Sleep(1000);
    end;
end;


end.

