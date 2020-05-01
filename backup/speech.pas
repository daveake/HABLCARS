unit speech;

interface

uses Classes, SysUtils, Variants,
{$IFDEF MSWINDOWS}
  ComObj,
{$ELSE}

{$ENDIF}
Strings;


type
  TSpeech = class(TThread)
  private
    { Private declarations }
    Messages: TStringList;
  public
    procedure Execute; override;
    procedure AddMessage(Message: String);
    constructor Create;
  end;

implementation

uses Miscellaneous;


constructor TSpeech.Create;
begin
    Messages := TStringList.Create;

    inherited Create(False);
end;

procedure TSpeech.AddMessage(Message: String);
begin
    Messages.Add(Message);
end;

{$IFDEF MSWINDOWS}
procedure TSpeech.Execute;
var
    SpVoice: OleVariant;
    SavedCW: Word;
    Message: WideString;
begin
    Messages := TStringList.Create;

    SpVoice := CreateOleObject('SAPI.SpVoice');

    while not Terminated do begin
        while Messages.Count > 0 do begin
            Message := Messages[0];
            begin
                // Change FPU interrupt mask to avoid SIGFPE exceptions
                SavedCW := Get8087CW;
                try
                    Set8087CW(SavedCW or $4);
                    SpVoice.Speak(Message, 0);
                finally
                  // Restore FPU mask
                  Set8087CW(SavedCW);
                end;
            end;
            Messages.Delete(0);
        end;

        Sleep(1000);
    end;
end;
{$ELSE}
procedure TSpeech.Execute;
var
   FileName: AnsiString;
   f: TextFile;
begin
    Messages := TStringList.Create;
    FileName := GetTempDir + '/say.sh';

    while not Terminated do begin
        while Messages.Count > 0 do begin
            // Create shell script
            AssignFile(f, FileName);
            ReWrite(f);
            WriteLn(f, '#!/bin/sh');
            WriteLn(f, '/usr/bin/espeak -g 5 "' + Messages[0] + '" --stdout | /usr/bin/aplay');
            CloseFile(f);

            fpChmod (FileName,&777);

            // fpexecl ('./' + FileName,[]);
            SysUtils.ExecuteProcess('/bin/bash', '-c ' + FileName, []);

            // Bye Bye
            Messages.Delete(0);
        end;

        Sleep(1000);
    end;
end;
{$ENDIF}

end.
