unit settings;

{$mode objfpc}{$H+}

interface

uses
    Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ExtCtrls, Buttons,
    StdCtrls, base, SettingsBase, GeneralSettings, GPSSettings, GatewaySettings,
    UDPSettings, HabitatSettings;

type

    { TfrmSettings }

    TfrmSettings = class(TfrmBase)
      btnGeneral: TButton;
      btnGPS: TButton;
      btnGateway: TButton;
      btnUDP: TButton;
      btnHabitat: TButton;
        Panel3: TPanel;
        procedure btnGatewayClick(Sender: TObject);
        procedure btnGeneralClick(Sender: TObject);
        procedure btnGPSClick(Sender: TObject);
        procedure btnHabitatClick(Sender: TObject);
        procedure btnUDPClick(Sender: TObject);
        procedure FormCreate(Sender: TObject);
    private
        CurrentForm: TfrmSettingsBase;
        procedure ShowSelectedButton(Button: TButton);
        procedure LoadSettingsForm(Button: TButton; NewForm: TfrmSettingsBase);
    public
        procedure LoadForm; override;
    public

    end;

var
    frmSettings: TfrmSettings;

implementation

{$R *.lfm}

{ TfrmSettings }

procedure TfrmSettings.btnGeneralClick(Sender: TObject);
begin
    LoadSettingsForm(TButton(Sender), frmGeneralSettings);
end;

procedure TfrmSettings.btnGatewayClick(Sender: TObject);
begin
    LoadSettingsForm(TButton(Sender), frmLoRaGatewaySettings);
end;

procedure TfrmSettings.btnGPSClick(Sender: TObject);
begin
    LoadSettingsForm(TButton(Sender), frmGPSSettings);
end;

procedure TfrmSettings.btnHabitatClick(Sender: TObject);
begin
    LoadSettingsForm(TButton(Sender), frmHabitatSettings);
end;

procedure TfrmSettings.btnUDPClick(Sender: TObject);
begin
    LoadSettingsForm(TButton(Sender), frmUDPSettings);
end;

procedure TfrmSettings.FormCreate(Sender: TObject);
begin
    inherited;

    frmGPSSettings := TfrmGPSSettings.Create(nil);
    frmLoRaGatewaySettings := TfrmLoRaGatewaySettings.Create(nil);
    //frmLoRaGatewaySettings2 := TfrmLoRaGatewaySettings2.Create(nil);
    frmHabitatSettings := TfrmHabitatSettings.Create(nil);
    //frmBluetoothSettings := TfrmBluetoothSettings.Create(nil);
    frmUDPSettings := TfrmUDPSettings.Create(nil);

    frmGeneralSettings := TfrmGeneralSettings.Create(nil);
end;

procedure TfrmSettings.LoadSettingsForm(Button: TButton; NewForm: TfrmSettingsBase);
begin
    ShowSelectedButton(Button);

    if CurrentForm <> nil then begin
        CurrentForm.pnlMain.Parent := CurrentForm;
        CurrentForm.HideForm;
    end;

    NewForm.pnlMain.Parent := pnlMain;
    CurrentForm := NewForm;
    NewForm.LoadForm;
end;

procedure TfrmSettings.ShowSelectedButton(Button: TButton);
begin
    btnGeneral.Font.Style := btnGeneral.Font.Style - [TFontStyle.fsItalic];
    btnGPS.Font.Style := btnGPS.Font.Style - [TFontStyle.fsItalic];
    btnGateway.Font.Style := btnGateway.Font.Style - [TFontStyle.fsItalic];
    btnUDP.Font.Style := btnUDP.Font.Style - [TFontStyle.fsItalic];
    btnHabitat.Font.Style := btnHabitat.Font.Style - [TFontStyle.fsItalic];

    Button.Font.Style := Button.Font.Style + [TFontStyle.fsItalic];
end;

procedure TfrmSettings.LoadForm;
begin
    inherited;

    LoadSettingsForm(btnGeneral, frmGeneralSettings);
end;

end.

