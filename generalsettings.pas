unit GeneralSettings;

{$mode objfpc}{$H+}

interface

uses
    Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ExtCtrls, Buttons,
    StdCtrls, SettingsBase, Miscellaneous;

type

    { TfrmGeneralSettings }

    TfrmGeneralSettings = class(TfrmSettingsBase)
        chkAlarmBeeps: TSpeedButton;
        chkSpellOut: TSpeedButton;
        chkTweet: TSpeedButton;
        chkPositionBeeps: TSpeedButton;
        chkSpeech: TSpeedButton;
        edtCallsign: TEdit;
        Label1: TLabel;
        procedure chkSpeechClick(Sender: TObject);
        procedure edtCallsignEditingDone(Sender: TObject);
        procedure edtCallsignKeyPress(Sender: TObject; var Key: char);
        procedure FormCreate(Sender: TObject);
    private
    protected
      procedure ApplyChanges; override;
      procedure CancelChanges; override;
    public
      procedure LoadForm; override;
    public
    end;

var
    frmGeneralSettings: TfrmGeneralSettings;

implementation

{$R *.lfm}

{ TfrmGeneralSettings }

procedure TfrmGeneralSettings.edtCallsignEditingDone(Sender: TObject);
begin
end;

procedure TfrmGeneralSettings.chkSpeechClick(Sender: TObject);
begin
    SettingsHaveChanged;
end;

procedure TfrmGeneralSettings.edtCallsignKeyPress(Sender: TObject; var Key: char);
begin
    SettingsHaveChanged;
end;

procedure TfrmGeneralSettings.FormCreate(Sender: TObject);
begin
    inherited;
    Group := 'General';
end;

procedure TfrmGeneralSettings.ApplyChanges;
begin
    SetSettingString(Group, 'Callsign', edtCallsign.Text);

    SetSettingBoolean(Group, 'PositionBeeps', chkPositionBeeps.Down);
    SetSettingBoolean(Group, 'AlarmBeeps', chkAlarmBeeps.Down);
    SetSettingBoolean(Group, 'Speech', chkSpeech.Down);
    SetSettingBoolean(Group, 'SpellOut', chkSpellOut.Down);
    SetSettingBoolean(Group, 'Tweet', chkTweet.Down);

    inherited;
end;

procedure TfrmGeneralSettings.CancelChanges;
begin
    inherited;

    edtCallsign.Text := GetSettingString(Group, 'Callsign', '');

    chkPositionBeeps.Down := GetSettingBoolean(Group, 'PositionBeeps', False);
    chkAlarmBeeps.Down := GetSettingBoolean(Group, 'AlarmBeeps', False);
    chkSpellOut.Down := GetSettingBoolean(Group, 'SpellOut', False);
    chkSpeech.Down := GetSettingBoolean(Group, 'Speech', False);
    chkTweet.Down := GetSettingBoolean(Group, 'Tweet', False);

    inherited;
end;

procedure TfrmGeneralSettings.LoadForm;
begin
    inherited;

end;

end.

