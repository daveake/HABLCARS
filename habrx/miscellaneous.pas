unit Miscellaneous;

interface

uses DateUtils, Math, Source, HABTypes, INIFiles;

type
  TStatusCallback = procedure(SourceID: Integer; IsActive, OK: Boolean) of object;

type
TSetting = record
  Name:           String;
  Value:          String;
end;

type
TSettings = record
  Settings:       Array[1..64] of TSetting;
  Count:          Integer;
end;

type
  TIPLookup = record
    HostName:   String;
    IPAddress:  String;
  end;

type
  TIPLookups = record
    IPLookups:  Array[1..8] of TIPLookup;
    Count:      Integer;
  end;


function CalculateDistance(HABLatitude, HabLongitude, CarLatitude, CarLongitude: Double): Double;
function CalculateDirection(HABLatitude, HabLongitude, CarLatitude, CarLongitude: Double): Double;
function GetJSONString(Line: String; FieldName: String): String;
function GetJSONInteger(Line: String; FieldName: String): LongInt;
function GetJSONFloat(Line: String; FieldName: String): Double;
function GetUDPString(Line: String; FieldName: String): String;
function PayloadHasFieldType(Position: THABPosition; FieldType: TFieldType): Boolean;
procedure InsertDate(var TimeStamp: TDateTime);
function CalculateDescentTime(Altitude, DescentRate, Land: Double): Double;
function DataFolder: String;
function ImageFolder: String;
function GetString(var Line: String; Delimiter: String=','): String;
function GetTime(var Line: String; Delimiter: String = ','): TDateTime;
function GetFloat(var Line: String; Delimiter: String = ','): Double;
function SourceName(SourceID: Integer): String;
procedure AddHostNameToIPAddress(HostName, IPAddress: String);
function GetIPAddressFromHostName(HostName: String): String;
function MyStrToFloat(Value: String): Double;
function MyFormatFloat(Format: String; Value: Double): String;

procedure InitialiseSettings;

function GetSettingString(Section, Item, Default: String): String;
function GetSettingInteger(Section, Item: String; Default: Integer): Integer;
function GetSettingBoolean(Section, Item: String; Default: Boolean): Boolean;
function GetGroupChangedFlag(Section: String): Boolean;

procedure SetSettingString(Section, Item, Value: String);
procedure SetSettingInteger(Section, Item: String; Value: Integer);
procedure SetSettingBoolean(Section, Item: String; Value: Boolean);
procedure SetGroupChangedFlag(Section: String; Changed: Boolean);

const
    GPS_SOURCE = 0;
    SERIAL_SOURCE = 1;
    BLUETOOTH_SOURCE = 2;
    UDP_SOURCE = 3;
    HABITAT_SOURCE = 4;
    GATEWAY_SOURCE_1 = 5;
    GATEWAY_SOURCE_2 = 6;


var
    INIFileName: String;

implementation

uses SysUtils;

var
    Settings: TSettings;
    Ini: TIniFile;
    IPLookups: TIPLookups;

function SourceName(SourceID: Integer): String;
const
    SourceNames: Array[0..6] of String = ('GPS', 'Serial', 'Bluetooth', 'UDP', 'Habitat', 'Gateway', 'Gateway 2');
begin
    if (SourceID >= Low(SourceNames)) and (SourceID <= High(SourceNames)) then begin
        Result := SourceNames[SourceID];
    end else begin
        Result := '';
    end;
end;

function DataFolder: String;
begin
    if ParamCount > 0 then begin
        Result := ParamStr(1);
    end else begin
        Result := ExtractFilePath(ParamStr(0));
    end;

    Result := IncludeTrailingPathDelimiter(Result);
end;

function ImageFolder: String;
begin
    // Result := IncludeTrailingPathDelimiter(DataFolder + 'images');

    Result := 'http://51.89.167.6:8889/markers/';
end;


function GetUDPString(Line: String; FieldName: String): String;
var
    Position: Integer;
begin
    // Gateway:HOST=xxxx,IP=yyyyy

    Position := Pos(FieldName + '=', Line);

    if Position > 0 then begin
        Line := Copy(Line, Position + Length(FieldName) + 1, 999);

        Position := Pos(',', Line);

        Result := Copy(Line, 1, Position-1);
    end;
end;

function GetJSONString(Line: String; FieldName: String): String;
var
    Position: Integer;
begin
    // {"class":"POSN","payload":"NOTAFLIGHT","time":"13:01:56","lat":52.01363,"lon":-2.50647,"alt":5507,"rate":7.0}

    Position := Pos('"' + FieldName + '":', Line);

    if Copy(Line, Position + Length(FieldName) + 3, 1) = '"' then begin
        Line := Copy(Line, Position + Length(FieldName) + 4, 999);
        Position := Pos('"', Line);

        Result := Copy(Line, 1, Position-1);
//    end else if Line[Position + Length(FieldName) + 4] = '"' then begin
//        Line := Copy(Line, Position + Length(FieldName) + 5, 999);
//        Position := Pos('"', Line);
//
//        Result := Copy(Line, 1, Position-1);
    end else begin
        Line := Copy(Line, Position + Length(FieldName) + 3, 999);

        Position := Pos(',', Line);
        if Position = 0 then begin
            Position := Pos('}', Line);
        end;

        Result := Copy(Line, 1, Position-1);
    end;
end;

function GetJSONFloat(Line: String; FieldName: String): Double;
var
    Position: Integer;
begin
    // {"class":"POSN","payload":"NOTAFLIGHT","time":"13:01:56","lat":52.01363,"lon":-2.50647,"alt":5507,"rate":7.0}

    Position := Pos('"' + FieldName + '":', Line);

    if Position > 0 then begin
        Line := Copy(Line, Position + Length(FieldName) + 3, 999);

        Position := Pos(',', Line);
        if Position = 0 then begin
            Position := Pos('}', Line);
        end else if Pos('}', Line) < Position then begin
            Position := Pos('}', Line);
        end;


        Line := Copy(Line, 1, Position-1);

        if Copy(Line, 1, 1) = '"' then begin
            Line := Copy(Line,2, Length(Line)-2);
        end;

        try
            Result := MyStrToFloat(Line);
        except
            Result := 0;
        end;
    end else begin
        Result := 0;
    end;
end;

function GetJSONInteger(Line: String; FieldName: String): LongInt;
var
    Position: Integer;
begin
    // {"class":"POSN","payload":"NOTAFLIGHT","time":"13:01:56","lat":52.01363,"lon":-2.50647,"alt":5507,"rate":7.0}

    Position := Pos('"' + FieldName + '":', Line);

    if Position > 0 then begin
        Line := Copy(Line, Position + Length(FieldName) + 3, 999);

        Position := Pos(',', Line);
        if Position = 0 then begin
            Position := Pos('}', Line);
        end;

        Line := Copy(Line, 1, Position-1);

        if Copy(Line, 1, 1) = '"' then begin
            Line := Copy(Line,2, Length(Line)-2);
        end;

        Result := StrToIntDef(Line, 0);
    end else begin
        Result := 0;
    end;
end;

function PayloadHasFieldType(Position: THABPosition; FieldType: TFieldType): Boolean;
var
    i: Integer;
begin
    for i := 0 to length(Position.FieldList)-1 do begin
        if Position.FieldList[i] = FieldType then begin
            Result := True;
            Exit;
        end;
    end;

    Result := False;
end;

procedure InsertDate(var TimeStamp: TDateTime);
begin
    if TimeStamp < 1 then begin
        // Add today's date
        // TimeStamp := TimeStamp + Trunc(TTimeZone.Local.ToUniversalTime(Now));

        //if (TimeStamp > 0.99) and (Frac(TTimeZone.Local.ToUniversalTime(Now)) < 0.01) then begin
        //    // Just past midnight, but payload transmitted just before midnight, so use yesterday's date
        //    TimeStamp := TimeStamp - 1;
        //end;
    end;
end;


function CalculateAirDensity(alt: Double): Double;
var
    Temperature, Pressure: Double;
begin
    if alt < 11000.0 then begin
        // below 11Km - Troposphere
        Temperature := 15.04 - (0.00649 * alt);
        Pressure := 101.29 * power((Temperature + 273.1) / 288.08, 5.256);
    end else if alt < 25000.0 then begin
        // between 11Km and 25Km - lower Stratosphere
        Temperature := -56.46;
        Pressure := 22.65 * exp(1.73 - ( 0.000157 * alt));
    end else begin
        // above 25Km - upper Stratosphere
        Temperature := -131.21 + (0.00299 * alt);
        Pressure := 2.488 * power((Temperature + 273.1) / 216.6, -11.388);
    end;

    Result := Pressure / (0.2869 * (Temperature + 273.1));
end;

function CalculateDescentRate(Weight, Density, CDTimesArea: Double): Double;
begin
    Result := sqrt((Weight * 9.81)/(0.5 * Density * CDTimesArea));
end;

function CalculateCDA(Weight, Altitude, DescentRate: Double): Double;
var
	Density: Double;
begin
	Density := CalculateAirDensity(Altitude);

    Result := (Weight * 9.81)/(0.5 * Density * DescentRate * DescentRate);
end;

function CalculateDescentTime(Altitude, DescentRate, Land: Double): Double;
var
    Density, CDTimesArea, TimeAtAltitude, TotalTime, Step: Double;
begin
    Step := 100;

    CDTimesArea := CalculateCDA(1.0, Altitude, DescentRate);

    TotalTime := 0;

    while Altitude > Land do begin
        Density := CalculateAirDensity(Altitude);

        DescentRate := CalculateDescentRate(1.0, Density, CDTimesArea);

        TimeAtAltitude := Step / DescentRate;
        TotalTime := TotalTime + TimeAtAltitude;

        Altitude := Altitude - Step;
    end;

    Result := TotalTime;
end;

procedure InitialiseSettings;
begin
    if INIFileName <> '' then begin
        Ini := TIniFile.Create(INIFileName);
    end;
end;


function GetSettingString(Section, Item, Default: String): String;
var
    Key: String;
    i: Integer;
begin
    Result := Default;

    Key := Section + '/' + Item;

    // Cached setting ?
    for i := 1 to Settings.Count do begin
        if Settings.Settings[i].Name = Key then begin
            Result := Settings.Settings[i].Value;
            Exit;
        end;
    end;

    if Item <> '' then begin
        // Read from INI file
        if Ini <> nil then begin
            Result := Ini.ReadString(Section, Item, Default);
        end;

        // Add to cache
        if Settings.Count < High(Settings.Settings) then begin
            Inc(Settings.Count);
            Settings.Settings[Settings.Count].Name := Key;
            Settings.Settings[Settings.Count].Value := Result;
        end;
    end;
end;

function GetSettingInteger(Section, Item: String; Default: Integer): Integer;
var
    Temp: String;
begin
    Temp := GetSettingString(Section, Item, IntToStr(Default));

    Result := StrToIntDef(Temp, Default);
end;

function GetSettingBoolean(Section, Item: String; Default: Boolean): Boolean;
var
    Key, Temp: String;
begin
    Temp := GetSettingString(Section, Item, BoolToStr(Default));

    Result := StrToBoolDef(Temp, Default);
end;

procedure SetGroupChangedFlag(Section: String; Changed: Boolean);
begin
    GetSettingBoolean(Section, '', Changed);
end;

function GetGroupChangedFlag(Section: String): Boolean;
begin
     Result := GetSettingBoolean(Section, '', False);
end;

procedure SetSettingValue(Key, Value: String);
var
    i: Integer;
begin
    // Existing setting ?
    for i := 1 to Settings.Count do begin
        if Settings.Settings[i].Name = Key then begin
            Settings.Settings[i].Value := Value;
            Exit;
        end;
    end;

    // Add new setting
    if Settings.Count < High(Settings.Settings) then begin
        Inc(Settings.Count);
        Settings.Settings[Settings.Count].Name := Key;
        Settings.Settings[Settings.Count].Value := Value;
    end;
end;

procedure SetSettingString(Section, Item, Value: String);
var
    Key: String;
begin
    Key := Section + '/' + Item;

    SetSettingValue(Key, Value);

    if Item <> '' then begin
        if Ini <> nil then begin
            Ini.WriteString(Section, Item, Value);
            Ini.UpdateFile;
        end;
    end;
end;


procedure SetSettingInteger(Section, Item: String; Value: Integer);
begin
     SetSettingString(Section, Item, IntToStr(Value));
end;

procedure SetSettingBoolean(Section, Item: String; Value: Boolean);
begin
     SetSettingString(Section, Item, BoolToStr(Value));
end;

function GetString(var Line: String; Delimiter: String=','): String;
var
    Position: Integer;
begin
    Position := Pos(Delimiter, string(Line));
    if Position > 0 then begin
        Result := Copy(Line, 1, Position-1);
        Line := Copy(Line, Position+Length(Delimiter), Length(Line));
    end else begin
        Result := Line;
        Line := '';
    end;
end;

function GetFloat(var Line: String; Delimiter: String = ','): Double;
var
    Temp: String;
begin
    Temp := GetString(Line, Delimiter);

    try
        Result := StrToFloat(Temp);
    except
        Result := 0.0;
    end;
end;

function GetTime(var Line: String; Delimiter: String = ','): TDateTime;
var
    Temp: String;
begin
    Temp := GetString(Line, Delimiter);

    try
        if Pos(':', Temp) > 0 then begin
            Result := EncodeTime(StrToIntDef(Copy(Temp, 1, 2), 0),
                      StrToIntDef(Copy(Temp, 4, 2), 0),
                      StrToIntDef(Copy(Temp, 7, 2), 0),
                      0);
        end else begin
            Result := EncodeTime(StrToIntDef(Copy(Temp, 1, 2), 0),
                      StrToIntDef(Copy(Temp, 3, 2), 0),
                      StrToIntDef(Copy(Temp, 5, 2), 0),
                      0);
        end;
    except
        Result := 0;
    end;
end;

procedure AddHostNameToIPAddress(HostName, IPAddress: String);
var
    i: Integer;
begin
    for i := 1 to IPLookups.Count do begin
        if IPLookups.IPLookups[i].HostName = HostName then begin
            if IPLookups.IPLookups[i].IPAddress <> IPAddress then begin
                IPLookups.IPLookups[i].IPAddress := IPAddress;
            end;
            Exit;
        end;
    end;

    if IPLookups.Count < High(IPLookups.IPLookups) then begin
        Inc(IPLookups.Count);
        IPLookups.IPLookups[IPLookups.Count].HostName := HostName;
        IPLookups.IPLookups[IPLookups.Count].IPAddress := IPAddress;
    end;
end;

function GetIPAddressFromHostName(HostName: String): String;
var
    i: Integer;
begin
    for i := 1 to IPLookups.Count do begin
        if UpperCase(IPLookups.IPLookups[i].HostName) = UpperCase(HostName) then begin
            Result := IPLookups.IPLookups[i].IPAddress;
            Exit;
        end;
    end;

    Result := '';
end;

function MyStrToFloat(Value: String): Double;
var
    LFormat: TFormatSettings;
begin
    if FormatSettings.DecimalSeparator <> '.' then begin
        Value := StringReplace(Value, '.', FormatSettings.DecimalSeparator, []);
    end;

    //LFormat := TFormatSettings.Create;          // Note: no need to free this
    //LFormat.DecimalSeparator := '.';
    //LFormat.ThousandSeparator := ',';

    try
        Result := StrToFloat(Value);   // , LFormat);
    except
        Result := 0;
    end;
end;


function CalculateDistance(HABLatitude, HABLongitude, CarLatitude, CarLongitude: Double): Double;
begin
    // Return distance in metres

    HABLatitude := HABLatitude * Pi / 180;
    HABLongitude := HABLongitude * Pi / 180;
    CarLatitude := CarLatitude * Pi / 180;
    CarLongitude := CarLongitude * Pi / 180;

    try
        Result := 6371000 * (sin(CarLatitude) * sin(HABLatitude) +
                                   cos(CarLatitude) * cos(HABLatitude) * cos(HABLongitude-CarLongitude));
    except
        Result := 0.0;
    end;
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

    try
        Result := ArcTan2(y, x);
    except
        Result := 0.0;
    end;
end;

function MyFormatFloat(Format: String; Value: Double): String;
//var
//    LFormat: TFormatSettings;
begin
    //LFormat := TFormatSettings.Create;          // Note: no need to free this
    //LFormat.DecimalSeparator := '.';
    //LFormat.ThousandSeparator := ',';
    //
    //Result := FormatFloat(Format, Value, LFormat);

    if FormatSettings.DecimalSeparator <> '.' then begin
        Result := StringReplace(Result, FormatSettings.DecimalSeparator, '.', []);
    end;
end;


end.

