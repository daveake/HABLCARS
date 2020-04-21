unit splash;

{$mode objfpc}{$H+}

interface

uses
    Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ExtCtrls, StdCtrls,
    base;

type

    { TfrmSplash }

    TfrmSplash = class(TfrmBase)
        btnPayloads: TLabel;
        btnPayloads1: TLabel;
        Image1: TImage;
    private

    public

    end;

var
    frmSplash: TfrmSplash;

implementation

{$R *.lfm}

end.

