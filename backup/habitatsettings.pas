unit HabitatSettings;

{$mode objfpc}{$H+}

interface

uses
    Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ExtCtrls, Buttons,
    StdCtrls, SettingsBase, Miscellaneous;

type

    { TfrmHabitatSettings }

    TfrmHabitatSettings = class(TfrmSettingsBase)
      chkUpload: TButton;
        edtWhiteList: TEdit;
        Label1: TLabel;
        procedure chkUploadClick(Sender: TObject);
        procedure edtWhiteListKeyPress(Sender: TObject; var Key: char);
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

procedure TfrmHabitatSettings.chkUploadClick(Sender: TObject);
begin
    LCARSCheckBoxClick(TButton(Sender));
end;

procedure TfrmHabitatSettings.edtWhiteListKeyPress(Sender: TObject;
    var Key: char);
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

