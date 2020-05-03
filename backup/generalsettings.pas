unit GeneralSettings;

{$mode objfpc}{$H+}

interface

uses
    Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ExtCtrls, Buttons,
    StdCtrls, SettingsBase, Miscellaneous;

type

    { TfrmGeneralSettings }

    TfrmGeneralSettings = class(TfrmSettingsBase)
        edtCallsign: TEdit;
        Label1: TLabel;
        procedure buttonClick(Sender: TObject);
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
end;

procedure TfrmGeneralSettings.buttonClick(Sender: TObject);
begin
    LCARSCheckBoxClick(TButton(Sender));
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

    SetSettingBoolean(Group, 'PositionBeeps', GetLCARSCheckBoxValue(chkPositionBeeps));
    SetSettingBoolean(Group, 'AlarmBeeps', GetLCARSCheckBoxValue(chkAlarmBeeps));
    SetSettingBoolean(Group, 'Speech', GetLCARSCheckBoxValue(chkSpeech));
    SetSettingBoolean(Group, 'SpellOut', GetLCARSCheckBoxValue(chkSpellOut));
    SetSettingBoolean(Group, 'Tweet', GetLCARSCheckBoxValue(chkTweet));

    inherited;
end;

procedure TfrmGeneralSettings.CancelChanges;
begin
    inherited;

    edtCallsign.Text := GetSettingString(Group, 'Callsign', '');

    SetLCARSCheckBoxValue(chkPositionBeeps, GetSettingBoolean(Group, 'PositionBeeps', False));
    SetLCARSCheckBoxValue(chkAlarmBeeps, GetSettingBoolean(Group, 'AlarmBeeps', False));
    SetLCARSCheckBoxValue(chkSpellOut, GetSettingBoolean(Group, 'SpellOut', False));
    SetLCARSCheckBoxValue(chkSpeech, GetSettingBoolean(Group, 'Speech', False));
    SetLCARSCheckBoxValue(chkTweet, GetSettingBoolean(Group, 'Tweet', False));

    inherited;
end;

procedure TfrmGeneralSettings.LoadForm;
begin
    inherited;

end;

end.

