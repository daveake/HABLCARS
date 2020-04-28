unit base;

{$mode objfpc}{$H+}

interface

uses
    Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ExtCtrls;

type

    { TfrmBase }

    TfrmBase = class(TForm)
        pnlMain: TPanel;
    private

    public
      procedure LoadForm(SelectedPayload: Integer); virtual;
      procedure HideForm; virtual;
    end;

var
    frmBase: TfrmBase;

implementation

{$R *.lfm}

procedure TfrmBase.LoadForm(SelectedPayload: Integer);
begin
    // virtual
end;


procedure TfrmBase.HideForm;
begin
    pnlMain.Parent := Self;
end;


end.
