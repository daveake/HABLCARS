unit GPSSource;

interface

uses Source, SysUtils, Classes, synaser;

type
  TGPSSource = class(TSource)
  private
    { Private declarations }
  protected
    { Protected declarations }
{$IFDEF MSWINDOWS}
    function ExtractPositionFrom(Line: String; PayloadID: String = ''): THABPosition; override;
    procedure Execute; override;
{$ENDIF}
  public
    { Public declarations }
  end;

implementation

uses Miscellaneous;

function FixPosition(Position: Double): Double;
var
    Minutes, Seconds: Double;
begin
	Position := Position / 100;

	Minutes := Trunc(Position);
	Seconds := Frac(Position);

	Result := Minutes + Seconds * 5 / 3;
end;

function TGPSSource.ExtractPositionFrom(Line: String; PayloadID: String = ''): THABPosition;
const
    Direction: Double = 0;
    CurrentDate: TDateTime = 0;
var
    Position: THABPosition;
    Fields: TStringList;
    Satellites: Integer;
    Speed: Double;
begin
    FillChar(Position, SizeOf(Position), 0);

    if CurrentDate = 0 then begin
        CurrentDate := Trunc(Now);
    end;

    try
        if Copy(Line, 1, 2) = '$G' then begin
            // Looks like an NME sentence so far
            if Copy(Line, 4, 3) = 'RMC' then begin
                // Just get direction from RMC
                Fields := TStringList.Create;
                ExtractStrings([','], [], pChar(Line), Fields, True);
                if Fields.Count >= 10 then begin
                    Speed := MyStrToFloat(Fields[7]);
                    if Speed > 2 then begin
                        Direction := MyStrToFloat(Fields[8]);
                    end;
                    if Length(Fields[9]) = 6 then begin
                        try
                            CurrentDate := EncodeDate(StrToIntDef(Copy(Fields[9], 5, 2), 0) + 2000,
                                                      StrToIntDef(Copy(Fields[9], 3, 2), 0),
                                                      StrToIntDef(Copy(Fields[9], 1, 2), 0));
                        except
                        end;
                    end;
                end;
                Fields.Free;
            end else if Copy(Line, 4, 3) = 'GGA' then begin
                Fields := TStringList.Create;
                ExtractStrings([','], [], pChar(Line), Fields, True);
                if Fields.Count >= 10 then begin
                    Satellites := StrToIntDef(Fields[7], 0);
                    if Satellites >= 3 then begin
                        Position.TimeStamp := CurrentDate +
                                              EncodeTime(StrToIntDef(Copy(Fields[1], 1, 2), 0),
                                                         StrToIntDef(Copy(Fields[1], 3, 2), 0),
                                                         StrToIntDef(Copy(Fields[1], 5, 2), 0),
                                                         0);

                        Position.Latitude := FixPosition(MyStrToFloat(Fields[2]));
                        if Fields[3] = 'S' then Position.Latitude := -Position.Latitude;

                        Position.Longitude := FixPosition(MyStrToFloat(Fields[4]));
                        if Fields[5] = 'W' then Position.Longitude := -Position.Longitude;

                        if Fields[9] = 'M' then begin
                            Position.Altitude := MyStrToFloat(Fields[8]);
                        end else begin
                            Position.Altitude := MyStrToFloat(Fields[9]);
                        end;

                        Position.Direction := Direction;

                        Position.InUse := True;
                    end;
                end;
                Fields.Free;
            end;
        end;
    finally
        //
    end;

    Result := Position;
end;

procedure TGPSSource.Execute;
var
    Line: AnsiString='';
    Position: THABPosition;
    CommPort: String;
    SerialDevice: TBlockSerial;
    Character: Char;
begin
    while not Terminated do begin
        CommPort := GetSettingString(GroupName, 'Port', '');
        SetGroupChangedFlag(GroupName, False);

        try
            Position := default(THABPosition);

            SerialDevice := TBlockserial.Create;

            SerialDevice.RaiseExcept := True;
            SerialDevice.Connect(CommPort);
            SerialDevice.Config(4800,8,'N',0,False,False);


            SyncCallback(SourceID, True, '', Position);

            while (not Terminated) and (not GetGroupChangedFlag(GroupName)) and (SerialDevice.LastError = 0) do begin
                if SerialDevice.canread(1000) then  begin
                    Character := Char(SerialDevice.RecvByte(1000));

                    if Character = #13 then begin
                        Position := ExtractPositionFrom(String(Line));
                        if Position.InUse then begin
                            SyncCallback(SourceID, True, string(Line), Position);
                        end;
                        Line := '';
                    end else if Character = '$' then begin
                        Line := Character;
                    end else if Line <> '' then begin
                        Line := Line + Character;
                    end;
                end;
            end;
        finally
            SerialDevice.Free;
            SyncCallback(SourceID, False, '', Position);
        end;

        Sleep(100);
    end;
end;


end.

