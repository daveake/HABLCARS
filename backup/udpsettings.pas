unit UDPSettings;

{$mode objfpc}{$H+}

interface

uses
    Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ExtCtrls, Buttons,
    StdCtrls, SettingsBase, Miscellaneous;

type

    { TfrmUDPSettings }

    TfrmUDPSettings = class(TfrmSettingsBase)
        edtPort: TEdit;
        Label1: TLabel;
        procedure edtPortKeyPress(Sender: TObject; var Key: char);
        procedure FormCreate(Sender: TObject);
    private
    protected
      procedure ApplyChanges; override;
      procedure CancelChanges; override;
    public
    end;

var
    frmUDPSettings: TfrmUDPSettings;

implementation

{$R *.lfm}

{ TfrmUDPSettings }

procedure TfrmUDPSettings.FormCreate(Sender: TObject);
begin
    inherited;
    Group := 'UDP';
end;

procedure TfrmUDPSettings.edtPortKeyPress(Sender: TObject; var Key: char);
begin
    SettingsHaveChanged
end;

procedure TfrmUDPSettings.ApplyChanges;
begin
    SetSettingString(Group, 'Port', edtPort.Text);

    inherited;
end;

procedure TfrmUDPSettings.CancelChanges;
begin
    inherited;

    edtPort.Text := GetSettingString(Group, 'Port', '');
end;


end.

