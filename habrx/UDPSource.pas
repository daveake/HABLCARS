unit UDPSource;

interface

uses Source, Classes, SysUtils, Miscellaneous, blcksock;

type
  TUDPSource = class(TSource)
  private
    { Private declarations }
  protected
    { Protected declarations }
    procedure Execute; override;
  public
    { Public declarations }
  public
    constructor Create(ID: Integer; Group: String; Callback: TSourcePositionCallback);
  end;

implementation

procedure TUDPSource.Execute;
var
    Socket: TUDPBlockSocket;
    Position: THABPosition;
    PortList, TempPortList, Buffer, Sentence: String;
    PortNumber: Integer;
begin
    Position := default(THABPosition);
    SyncCallback(SourceID, True, '', Position);

    while not Terminated do begin
        SetGroupChangedFlag(GroupName, False);
        PortList := GetSettingString(GroupName, 'Port', '');

        if PortList = '' then begin
            SyncCallback(SourceID, True, 'No ports specified', Position);
        end else begin
            Socket := TUDPBlockSocket.Create;
            try
                Socket.Bind('0.0.0.0', PortList);
                if Socket.LastError = 0 then begin
                    SyncCallback(SourceID, True, 'Listening to ' + PortList + ' ...', Position);
                    while (not Terminated) and (not GetGroupChangedFlag(GroupName)) do begin
                        Buffer := Socket.RecvPacket(1000);
                        while Length(Buffer) > 2 do begin
                            Sentence := GetString(Buffer, #10);

                            try
                                Position := ExtractPositionFrom(Sentence, 'UDP');

                                if Position.InUse then begin
                                    SyncCallback(SourceID, True, Sentence, Position);
                                end;
                            except
                                //
                            end;
                        end;
                    end;
                end else begin
                    SyncCallback(SourceID, False, 'Failed to listening to ' + PortList, Position);
                end;
            finally
                Socket.CloseSocket;
                Socket.Free;
            end;
        end;

        Sleep(1000);
    end;
end;

constructor TUDPSource.Create(ID: Integer; Group: String; Callback: TSourcePositionCallback);
begin
    inherited Create(ID, Group, Callback);
end;

end.
