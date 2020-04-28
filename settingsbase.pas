unit SettingsBase;

{$mode objfpc}{$H+}

interface

uses
    Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ExtCtrls, Buttons,
    StdCtrls, base, miscellaneous;

type

    { TfrmSettingsBase }

    TfrmSettingsBase = class(TfrmBase)
        Panel1: TPanel;
        Panel3: TPanel;
        Shape1: TShape;
        Shape2: TShape;
        btnApply: TSpeedButton;
        btnCancel: TSpeedButton;
        StaticText1: TStaticText;
        procedure btnApplyClick(Sender: TObject);
        procedure btnCancelClick(Sender: TObject);
    private
    protected
      FormIsLoading: Boolean;
      Group: String;
      procedure ApplyChanges; virtual;
      procedure CancelChanges; virtual;
      procedure SettingsHaveChanged;
    public
      { Public declarations }
      procedure LoadForm; override;
    end;


implementation

{$R *.lfm}


{ TfrmSettingsBase }

procedure TfrmSettingsBase.btnApplyClick(Sender: TObject);
begin
    ApplyChanges;
end;

procedure TfrmSettingsBase.btnCancelClick(Sender: TObject);
begin
    CancelChanges;
end;

procedure TfrmSettingsBase.ApplyChanges;
begin
    SetGroupChangedFlag(Group, True);
    btnApply.Enabled := False;
    btnCancel.Enabled := False;
    btnApply.Color := $00108CA3;
    btnCancel.Color := $00108CA3;
end;

procedure TfrmSettingsBase.CancelChanges;
begin
    btnApply.Enabled := False;
    btnCancel.Enabled := False;
end;

procedure TfrmSettingsBase.LoadForm;
begin
    FormIsLoading := True;

    inherited;

    //tmrLoadSettings.Enabled := True;
    CancelChanges;

    FormIsLoading := False;
end;

procedure TfrmSettingsBase.SettingsHaveChanged;
begin
    if not FormIsLoading then begin
        btnApply.Enabled := True;
        btnCancel.Enabled := True;
        btnApply.Color := $006FDFF1;
        btnCancel.Color := $006FDFF1;
    end;
end;

end.

