unit HabitatSettings;

{$mode objfpc}{$H+}

interface

uses
    Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ExtCtrls, Buttons,
    StdCtrls, SettingsBase, Miscellaneous;

type

    { TfrmHabitatSettings }

    TfrmHabitatSettings = class(TfrmSettingsBase)
        chkEnable: TSpeedButton;
        edtWhiteList: TEdit;
        Label1: TLabel;
        procedure chkEnableClick(Sender: TObject);
        procedure FormCreate(Sender: TObject);
    private
    protected
      procedure ApplyChanges; override;
      procedure CancelChanges; override;
    public
    end;

var
    frmHabitatSettings: TfrmHabitatSettings;

implementation

{$R *.lfm}

{ TfrmHabitatSettings }

procedure TfrmHabitatSettings.chkEnableClick(Sender: TObject);
begin
    SettingsHaveChanged;
end;

procedure TfrmHabitatSettings.FormCreate(Sender: TObject);
begin
    inherited;
    Group := 'Habitat';
end;

procedure TfrmHabitatSettings.ApplyChanges;
begin
    SetSettingBoolean(Group, 'Enable', chkEnable.Down);
    SetSettingString(Group, 'WhiteList', edtWhiteList.Text);

    inherited;
end;

procedure TfrmHabitatSettings.CancelChanges;
begin
    inherited;

    chkEnable.Down := GetSettingBoolean(Group, 'Enable', False);
    edtWhiteList.Text := GetSettingString(Group, 'WhiteList', '');
end;

end.

