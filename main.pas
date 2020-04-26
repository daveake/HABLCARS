unit main;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ExtCtrls, StdCtrls,
  LCLTMSFNCMaps, Base, SourcesForm, Splash, Source, Map;

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
    btnMap: TLabel;
    btnPayloads4: TLabel;
    btnSources: TLabel;
    btnPayloads6: TLabel;
    btnPayloads7: TLabel;
    btnPayloads8: TLabel;
    btnPayloads9: TLabel;
    btnPayloadsSpace1: TLabel;
    pnlMapHeader: TButton;
    lblMap: TLabel;
    btnPayloadsSpace3: TLabel;
    btnPayloadsSpace4: TLabel;
    btnPayloadsSpace5: TLabel;
    lblSources: TLabel;
    btnPayloadsSpace7: TLabel;
    btnPayloadsSpace8: TLabel;
    Label3: TLabel;
    lblPayload: TLabel;
    lblGPS: TLabel;
    pnlBottomBar: TPanel;
    pnlCentre: TPanel;
    pnlMap: TPanel;
    pnlTopBar1: TPanel;
    pnlTopBar2: TPanel;
    pnlTopLeft: TPanel;
    Panel6: TPanel;
    pnlMain: TPanel;
    pnlTop: TPanel;
    pnlTopBar: TPanel;
    pnlBottom: TPanel;
    pnlButtons: TPanel;
    Shape2: TShape;
    shpTopLeft: TShape;
    Shape3: TShape;
    Shape4: TShape;
    tmrLoad: TTimer;
    GMap: TTMSFNCMaps;
    procedure btnCloseClick(Sender: TObject);
    procedure btnlSourcesClick(Sender: TObject);
    procedure btnMapClick(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure pnlBottomResize(Sender: TObject);
    procedure pnlTopBarClick(Sender: TObject);
    procedure pnlTopResize(Sender: TObject);
    procedure Shape2MouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure tmrLoadTimer(Sender: TObject);
  private
    CurrentForm: TfrmBase;
    procedure ShowSelectedButton(Button: TLabel);
  public
    procedure NewPosition(SourceID: Integer; HABPosition: THABPosition);
    function LoadForm(Button: TLabel; NewForm: TfrmBase): Boolean;
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

procedure TfrmMain.tmrLoadTimer(Sender: TObject);
begin
    tmrLoad.Enabled := False;

    // Main forms
    //frmPayloads := TfrmPayloads.Create(nil);
    //frmSSDV := TfrmSSDV.Create(nil);
    //frmDirection := TfrmDirection.Create(nil);
    //frmNavigate := TfrmNavigate.Create(nil);
    //frmLog := TfrmLog.Create(nil);

    // Sources Form
    frmSources := TfrmSources.Create(nil);

    // Target Forms
    frmMap := TfrmMap.Create(nil);

    // frmSources.EnableCompass;

    //LoadMapIfNotLoaded;

    frmSplash.lblLoading.Caption := 'ACCESS GRANTED';

    //lblGPS.Text := '';
end;

procedure TfrmMain.pnlBottomResize(Sender: TObject);
begin
    pnlBottomBar.Width := pnlBottom.Width - pnlBottom.Height;
end;

procedure TfrmMain.pnlTopBarClick(Sender: TObject);
begin
    LoadForm(nil, frmSplash);
end;

procedure TfrmMain.btnCloseClick(Sender: TObject);
begin
    Close;
end;

procedure TfrmMain.btnlSourcesClick(Sender: TObject);
begin
    LoadForm(btnSources, frmSources);
end;

procedure TfrmMain.btnMapClick(Sender: TObject);
begin
     LoadForm(btnMap, frmMap);
end;

procedure TfrmMain.FormActivate(Sender: TObject);
const
    FirstTime: Boolean = True;
begin
    if FirstTime then begin
        FirstTime := False;

        // Splash form
        frmSplash := TfrmSplash.Create(nil);
        LoadForm(nil, frmSplash);

        // Source Form

        tmrLoad.Enabled := True;
    end;
end;

function TfrmMain.LoadForm(Button: TLabel; NewForm: TfrmBase): Boolean;
begin
    if NewForm <> nil then begin
        ShowSelectedButton(Button);

        if CurrentForm <> nil then begin
            CurrentForm.HideForm;
        end;

        CurrentForm := NewForm;

        if NewForm = frmMap then begin
            pnlMap.Visible := True;
        end else begin
            pnlMap.Visible := False;

            NewForm.pnlMain.Parent := pnlCentre;
        end;

        NewForm.LoadForm;

        Result := True;
    end else begin
        Result := False;
    end;
end;

procedure TfrmMain.ShowSelectedButton(Button: TLabel);
begin
    //btnPayloads.TextSettings.Font.Style := btnPayloads.TextSettings.Font.Style - [TFontStyle.fsUnderline];
    //btnMap.TextSettings.Font.Style := btnMap.TextSettings.Font.Style - [TFontStyle.fsUnderline];
    //btnSSDV.TextSettings.Font.Style := btnSSDV.TextSettings.Font.Style - [TFontStyle.fsUnderline];
    //btnDirection.TextSettings.Font.Style := btnDirection.TextSettings.Font.Style - [TFontStyle.fsUnderline];
    //btnNavigate.TextSettings.Font.Style := btnNavigate.TextSettings.Font.Style - [TFontStyle.fsUnderline];
    //btnLog.TextSettings.Font.Style := btnLog.TextSettings.Font.Style - [TFontStyle.fsUnderline];
    //btnSettings.TextSettings.Font.Style := btnSettings.TextSettings.Font.Style - [TFontStyle.fsUnderline];

    btnMap.Font.Style := btnMap.Font.Style - [TFontStyle.fsUnderline];
    btnSources.Font.Style := btnSources.Font.Style - [TFontStyle.fsUnderline];

    if Button <> nil then begin
        Button.Font.Style := Button.Font.Style + [TFontStyle.fsUnderline];
    end;
end;

procedure TfrmMain.NewPosition(SourceID: Integer; HABPosition: THABPosition);
var
    Index: Integer;
    PositionOK: Boolean;
begin
    //ShowSourceStatus(SourceID, True, True);
    //
    //Index := PlacePayloadInList(Position);
    //
    //if Position.IsChase or (Index > 0) then begin
    //    if Position.IsChase then begin
    //        // Chase car only
    //        ChasePosition := Position;
    //        if frmDirection <> nil then frmDirection.NewPosition(0, Position);
    //    end else begin
    //        // Payloads only
    //        if Payloads[Index].LoggedLoss then begin
    //            Payloads[Index].LoggedLoss := False;
    //            frmLog.AddMessage(Payloads[Index].Position.PayloadID, 'Signal Regained', True, False);
    //        end;
    //
    //        PositionOK := (Position.Latitude <> 0.0) or (Position.Longitude <> 0.0);
    //
    //        if PositionOK <> Payloads[Index].GoodPosition then begin
    //            Payloads[Index].GoodPosition := PositionOK;
    //
    //            if PositionOK then begin
    //                frmLog.AddMessage(Payloads[Index].Position.PayloadID, 'GPS Position Valid', True, False);
    //            end else begin
    //                frmLog.AddMessage(Payloads[Index].Position.PayloadID, 'GPS Position Lost', True, False);
    //            end;
    //        end;
    //
    //        if frmPayloads <> nil then frmPayloads.NewPosition(Index, Position);
    //        if frmSSDV <> nil then frmSSDV.NewPosition(Index, Position);
    //
    //        // Selected payload only
    //        if Index = SelectedPayload then begin
    //            if frmDirection <> nil then frmDirection.NewPosition(Index, Position);
    //            ShowSelectedPayloadPosition;
    //        end;
    //
    //        // Select payload if it's the only one
    //        if SelectedPayload < 1 then begin
    //            SelectPayload(btnPayload1);
    //        end;
    //
    //        if GetSettingBoolean('General', 'PositionBeeps', False) then begin
    //            tmrBleep.Tag := 1;
    //        end;
    //    end;
    //
    //    // Payloads and Chase Car
    //    if frmMap <> nil then begin
    //        if (Position.Latitude <> 0) or (Position.Longitude <> 0) then begin
    //            frmMap.NewPosition(Index, Position);
    //        end;
    //    end;
    //end;

    // Show active on status bar
//    if SourceID = 1 then lblGateway.FontColor := TAlphaColorRec.Black;
//    if SourceID = 2 then Label2.FontColor := TAlphaColorRec.Black;
//    if SourceID = 3 then Label3.FontColor := TAlphaColorRec.Black;
//    if SourceID = 4 then Label4.FontColor := TAlphaColorRec.Black;
//    if SourceID = 5 then Label5.FontColor := TAlphaColorRec.Black;
end;

end.

