unit log;

{$mode objfpc}{$H+}

interface

uses
    Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ExtCtrls, StdCtrls,
    base, Miscellaneous, Speech;

type

    { TfrmLog }

    TfrmLog = class(TfrmBase)
        lstLog: TListBox;
        Panel1: TPanel;
        procedure FormCreate(Sender: TObject);
        procedure lstLogClick(Sender: TObject);
        procedure tmrUpdatesTimer(Sender: TObject);
    private
      SpeechThread: TSpeech;
    public
      procedure AddMessage(PayloadID, Temp: String; Speak, Tweet: Boolean);
    end;

var
    frmLog: TfrmLog;

implementation

{$R *.lfm}

procedure TfrmLog.tmrUpdatesTimer(Sender: TObject);
begin
end;

procedure TfrmLog.FormCreate(Sender: TObject);
begin
    inherited;

    SpeechThread := TSpeech.Create;
end;

procedure TfrmLog.lstLogClick(Sender: TObject);
begin
    AddMessage('DAVE', 'Is here', True, False);
    AddMessage('JULIE', 'Is here', True, False);
    AddMessage('DAISY', 'Is here', True, False);
end;

function SpellOut(Temp: String): String;
var
    i: Integer;
begin
    Result := '';

    for i := 1 to Length(Temp) do begin
        Result := Result + Copy(Temp, i, 1) + ' ';
    end;
end;


procedure TfrmLog.AddMessage(PayloadID, Temp: String; Speak, Tweet: Boolean);
var
    Speech, Msg, TimedMsg: String;
begin
    if PayloadID = '' then begin
        Msg := Temp;
        Speech := Msg;
    end else begin
        Msg := PayloadID + ' - ' + Temp;
        if GetSettingBoolean('General', 'SpellOut', False) then begin
            Speech := SpellOut(PayloadID) + Temp;
        end else begin
            Speech := PayloadID + ' ' + Temp;
        end;
    end;

    TimedMsg := formatDateTime('hh:nn:ss', Now) + ': ' + Msg;

    if lstLog.Items.Count > 12 then lstLog.Items.Delete(0);
    lstLog.ItemIndex := lstLog.Items.Add(TimedMsg);

    if Speak and GetSettingBoolean('General', 'Speech', False) then begin
        SpeechThread.AddMessage(Speech);
    end;

    // Twitter
    //if Tweet and GetSettingBoolean('General', 'Tweet', False) then begin
    //    PostTweet('HAB PADD: ' + TimedMsg);
    //end;

    // hab.link
    //if Tweet then begin
    //    HabLinkUploader.SendMessage('MESSAGE:' + Speech);
    //end;
end;


end.

