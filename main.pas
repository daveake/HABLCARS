unit main;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ExtCtrls, StdCtrls;

type

  { TfrmMain }

  TfrmMain = class(TForm)
    btnPayloads: TLabel;
    btnPayloads1: TLabel;
    btnPayloads10: TLabel;
    btnPayloads11: TLabel;
    btnPayloads12: TLabel;
    btnPayloads13: TLabel;
    btnPayloads14: TLabel;
    btnPayloads2: TLabel;
    btnPayloads3: TLabel;
    btnPayloads4: TLabel;
    btnPayloads5: TLabel;
    btnPayloads6: TLabel;
    btnPayloads7: TLabel;
    btnPayloads8: TLabel;
    btnPayloads9: TLabel;
    btnPayloadsSpace1: TLabel;
    btnPayloadsSpace2: TLabel;
    btnPayloadsSpace3: TLabel;
    btnPayloadsSpace4: TLabel;
    btnPayloadsSpace5: TLabel;
    btnPayloadsSpace6: TLabel;
    btnPayloadsSpace7: TLabel;
    btnPayloadsSpace8: TLabel;
    btnClose: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    lblPayload: TLabel;
    lblPayload1: TLabel;
    pnlBottomBar: TPanel;
    pnlMain: TPanel;
    pnlTopBar1: TPanel;
    pnlTopBar2: TPanel;
    pnlTopLeft: TPanel;
    Panel6: TPanel;
    pnlCentre: TPanel;
    pnlTop: TPanel;
    pnlTopBar: TPanel;
    pnlBottom: TPanel;
    pnlButtons: TPanel;
    Shape2: TShape;
    shpTopLeft: TShape;
    Shape3: TShape;
    Shape4: TShape;
    procedure btnCloseClick(Sender: TObject);
    procedure pnlBottomResize(Sender: TObject);
    procedure pnlTopResize(Sender: TObject);
    procedure Shape2MouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
  private

  public

  end;

var
  frmMain: TfrmMain;

implementation

{$R *.lfm}

{ TfrmMain }

procedure TfrmMain.pnlTopResize(Sender: TObject);
begin
    pnlTopBar.Width := pnlTop.Width - pnlTop.Height;
end;

procedure TfrmMain.Shape2MouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
end;

procedure TfrmMain.pnlBottomResize(Sender: TObject);
begin
    pnlBottomBar.Width := pnlBottom.Width - pnlBottom.Height;
end;

procedure TfrmMain.btnCloseClick(Sender: TObject);
begin
    Close;
end;

end.

