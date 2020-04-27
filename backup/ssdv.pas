unit ssdv;

{$mode objfpc}{$H+}

interface

uses
    Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ExtCtrls,
    LCLTMSFNCWebBrowser, TargetForm;

type

    { TfrmSSDV }

    TfrmSSDV = class(TfrmTarget)
    private
        Browser: TTMSFNCWebBrowser;
    public
      procedure NewSelection(Index: Integer); override;
      procedure LoadForm; override;
      procedure HideForm; override;
    end;

var
    frmSSDV: TfrmSSDV;

implementation

{$R *.lfm}

procedure TfrmSSDV.NewSelection(Index: Integer);
begin
    inherited;

    if Browser <> nil then begin
        Browser.URL := 'https://ssdv.habhub.org/' + Positions[Index].Position.PayloadID;
    end;
end;

procedure TfrmSSDV.LoadForm;
begin
    inherited;

    Browser := TTMSFNCWebBrowser.Create(Self);
    Browser.Parent := pnlMain;
    Browser.Align := alClient;
    // Browser.URL := 'https://ssdv.habhub.org/';
    NewSelection(SelectedIndex);
end;


procedure TfrmSSDV.HideForm;
begin
    Browser.Free;

    inherited;
end;


end.

