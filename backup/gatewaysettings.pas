unit GatewaySettings;

{$mode objfpc}{$H+}

interface

uses
    Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ExtCtrls, Buttons,
    StdCtrls, SettingsBase, SourcesForm, Miscellaneous, Math;

type

    { TfrmLoRaGatewaySettings }

    TfrmLoRaGatewaySettings = class(TfrmSettingsBase)
        chkUpload: TSpeedButton;
        chkUpload1: TSpeedButton;
        chkUpload2: TSpeedButton;
        chkUpload3: TSpeedButton;
        edtFrequency2: TEdit;
        edtHost: TEdit;
        edtFrequency1: TEdit;
        edtMode1: TEdit;
        edtMode2: TEdit;
        edtPort: TEdit;
        Label1: TLabel;
        Label2: TLabel;
        Label3: TLabel;
        Label4: TLabel;
        procedure chkUpload1Click(Sender: TObject);
        procedure chkUpload2Click(Sender: TObject);
        procedure chkUpload3Click(Sender: TObject);
        procedure chkUploadClick(Sender: TObject);
        procedure edtFrequency2KeyPress(Sender: TObject; var Key: char);
        procedure FormCreate(Sender: TObject);
    private
        procedure SendSettingsToDevice;
    protected
      SourceIndex: Integer;
      procedure ApplyChanges; override;
      procedure CancelChanges; override;
    public

    end;

var
    frmLoRaGatewaySettings: TfrmLoRaGatewaySettings;

implementation

{$R *.lfm}

{ TfrmLoRaGatewaySettings }

procedure TfrmLoRaGatewaySettings.ApplyChanges;
begin
    SetSettingString(Group, 'Host', edtHost.Text);
    SetSettingInteger(Group, 'Port', StrToIntDef(edtPort.Text, 0));

    SetSettingString(Group, 'Frequency_0', edtFrequency1.Text);
    SetSettingInteger(Group, 'Mode_0', StrToIntDef(edtMode1.Text, 0));

    SetSettingString(Group, 'Frequency_1', edtFrequency2.Text);
    SetSettingInteger(Group, 'Mode_1', StrToIntDef(edtMode2.Text, 0));

    SendSettingsToDevice;

    inherited;
end;

procedure TfrmLoRaGatewaySettings.CancelChanges;
begin
    edtHost.Text := GetSettingString(Group, 'Host', '');
    edtPort.Text := GetSettingInteger(Group, 'Port', 0).ToString;

    edtFrequency1.Text := GetSettingString(Group, 'Frequency_0', '');
    edtMode1.Text := GetSettingString(Group, 'Mode_0', '');

    edtFrequency2.Text := GetSettingString(Group, 'Frequency_1', '');
    edtMode2.Text := GetSettingString(Group, 'Mode_1', '');

    inherited;
end;


procedure TfrmLoRaGatewaySettings.FormCreate(Sender: TObject);
begin
    inherited;
    Group := 'LoRaGateway1';
    SourceIndex := GATEWAY_SOURCE_1;
end;

procedure TfrmLoRaGatewaySettings.chkUploadClick(Sender: TObject);
begin
    edtMode1.Text := IntToStr(Max(0,Min(7,StrToIntDef(edtMode1.Text, 0)-1)));
end;

procedure TfrmLoRaGatewaySettings.edtFrequency2KeyPress(Sender: TObject;
    var Key: char);
begin
    SettingsHaveChanged;
end;

procedure TfrmLoRaGatewaySettings.chkUpload1Click(Sender: TObject);
begin
    edtMode1.Text := IntToStr(Max(0,Min(7,StrToIntDef(edtMode1.Text, 0)+1)));
end;

procedure TfrmLoRaGatewaySettings.chkUpload2Click(Sender: TObject);
begin
    edtMode2.Text := IntToStr(Max(0,Min(7,StrToIntDef(edtMode2.Text, 0)+1)));
end;

procedure TfrmLoRaGatewaySettings.chkUpload3Click(Sender: TObject);
begin
    edtMode2.Text := IntToStr(Max(0,Min(7,StrToIntDef(edtMode2.Text, 0)-1)));
end;

procedure TfrmLoRaGatewaySettings.SendSettingsToDevice;
begin
    frmSources.SendParameterToSource(SourceIndex, 'frequency_0', edtFrequency1.Text);
    frmSources.SendParameterToSource(SourceIndex, 'mode_0', edtMode1.Text);

    frmSources.SendParameterToSource(SourceIndex, 'frequency_1', edtFrequency2.Text);
    frmSources.SendParameterToSource(SourceIndex, 'mode_1', edtMode2.Text);
end;

end.

