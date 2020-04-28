unit settings;

{$mode objfpc}{$H+}

interface

uses
    Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ExtCtrls, Buttons,
    base, SettingsBase, GeneralSettings;

type

    { TfrmSettings }

    TfrmSettings = class(TfrmBase)
        btnGeneral: TSpeedButton;
        btnGateway: TSpeedButton;
        btnGPS: TSpeedButton;
        btnUDP: TSpeedButton;
        btnHabitat: TSpeedButton;
        Panel3: TPanel;
        procedure btnGatewayClick(Sender: TObject);
        procedure btnGeneralClick(Sender: TObject);
        procedure btnGPSClick(Sender: TObject);
        procedure btnHabitatClick(Sender: TObject);
        procedure btnUDPClick(Sender: TObject);
        procedure FormCreate(Sender: TObject);
    private
        CurrentForm: TfrmSettingsBase;
        procedure ShowSelectedButton(Button: TSpeedButton);
        procedure LoadSettingsForm(Button: TSpeedButton; NewForm: TfrmSettingsBase);
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
    LoadSettingsForm(TSpeedButton(Sender), frmGeneralSettings);
end;

procedure TfrmSettings.btnGatewayClick(Sender: TObject);
begin
    LoadSettingsForm(TSpeedButton(Sender), frmLoRaGatewaySettings);
end;

procedure TfrmSettings.btnGPSClick(Sender: TObject);
begin
    LoadSettingsForm(TSpeedButton(Sender), frmGPSSettings);
end;

procedure TfrmSettings.btnHabitatClick(Sender: TObject);
begin
    LoadSettingsForm(TSpeedButton(Sender), frmHabitatSettings);
end;

procedure TfrmSettings.btnUDPClick(Sender: TObject);
begin
    LoadSettingsForm(TSpeedButton(Sender), frmUDPSettings);
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

procedure TfrmSettings.LoadSettingsForm(Button: TSpeedButton; NewForm: TfrmSettingsBase);
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

procedure TfrmSettings.ShowSelectedButton(Button: TSpeedButton);
begin
    btnGeneral.Font.Style := btnGeneral.Font.Style - [TFontStyle.fsUnderline];
    btnGPS.Font.Style := btnGPS.Font.Style - [TFontStyle.fsUnderline];
    btnGateway.Font.Style := btnGateway.Font.Style - [TFontStyle.fsUnderline];
    btnUDP.Font.Style := btnUDP.Font.Style - [TFontStyle.fsUnderline];
    btnHabitat.Font.Style := btnHabitat.Font.Style - [TFontStyle.fsUnderline];

    Button.Font.Style := Button.Font.Style + [TFontStyle.fsUnderline];
end;

procedure TfrmSettings.LoadForm;
begin
    inherited;

    LoadSettingsForm(btnGeneral, frmGeneralSettings);
end;

end.

