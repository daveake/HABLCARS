unit GPSSettings;

{$mode objfpc}{$H+}

interface

uses
    Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ExtCtrls, Buttons,
    StdCtrls, SettingsBase, Miscellaneous;

type

    { TfrmGPSSettings }

    TfrmGPSSettings = class(TfrmSettingsBase)
      chkUpload: TButton;
        edtPort: TEdit;
        edtCallsign: TEdit;
        edtPeriod: TEdit;
        Label1: TLabel;
        Label2: TLabel;
        Label3: TLabel;
        procedure chkUploadClick(Sender: TObject);
        procedure edtPortKeyPress(Sender: TObject; var Key: char);
        procedure FormCreate(Sender: TObject);
    private
    protected
      procedure ApplyChanges; override;
      procedure CancelChanges; override;
    public
      procedure LoadForm; override;
    end;

var
    frmGPSSettings: TfrmGPSSettings;

implementation

{$R *.lfm}

{ TfrmGPSSettings }

procedure TfrmGPSSettings.FormCreate(Sender: TObject);
begin
    inherited;
    Group := 'GPS';
end;

procedure TfrmGPSSettings.edtPortKeyPress(Sender: TObject; var Key: char);
begin
    SettingsHaveChanged;
end;

procedure TfrmGPSSettings.chkUploadClick(Sender: TObject);
begin
    LCARSCheckBoxClick(TButton(Sender));
end;

procedure TfrmGPSSettings.ApplyChanges;
begin
    SetSettingString(Group, 'Port', edtPort.Text);

    inherited;

    SetSettingString('CHASE', 'Callsign', edtCallsign.Text);
    SetSettingBoolean('CHASE', 'Upload', GetLCARSCheckBoxValue(chkUpload));
    SetSettingInteger('CHASE', 'Period', StrToIntDef(edtPeriod.Text, 0));
end;

procedure TfrmGPSSettings.CancelChanges;
begin
    inherited;

    edtPort.Text := GetSettingString(Group, 'Port', '');

    edtCallsign.Text := GetSettingString('CHASE', 'Callsign', '');
    SetLCARSCheckBoxValue(chkUpload, GetSettingBoolean('CHASE', 'Upload', False));
    edtPeriod.Text := GetSettingString('CHASE', 'Period', '');

    inherited;
end;

procedure TfrmGPSSettings.LoadForm;
begin
    inherited;
end;

end.

