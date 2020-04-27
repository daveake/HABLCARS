unit log;

{$mode objfpc}{$H+}

interface

uses
    Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ExtCtrls, StdCtrls,
    base;

type

    { TfrmLog }

    TfrmLog = class(TfrmBase)
        lstLog: TListBox;
        Panel1: TPanel;
    private

    public
      procedure AddMessage(PayloadID, Temp: String; Speak, Tweet: Boolean);
    end;

var
    frmLog: TfrmLog;

implementation

{$R *.lfm}

procedure TfrmLog.AddMessage(PayloadID, Temp: String; Speak, Tweet: Boolean);
var
    Speech, Msg, TimedMsg: String;
begin
    if PayloadID = '' then begin
        Msg := Temp;
        Speech := Msg;
    end else begin
        Msg := PayloadID + ' - ' + Temp;
        // Speech := SpellOut(PayloadID) + Temp;
        Speech := PayloadID + ' ' + Temp;
    end;

    TimedMsg := formatDateTime('hh:nn:ss', Now) + ': ' + Msg;

    if lstLog.Items.Count > 12 then lstLog.Items.Delete(0);
    lstLog.ItemIndex := lstLog.Items.Add(TimedMsg);

    // Application.ProcessMessages;

    // Text to speech, for Android
    //if Speak and GetSettingBoolean('General', 'Speech', False) then begin
    //    lstSpeech.Items.Add(Speech);
    //end;

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

