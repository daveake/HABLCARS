program HABLCARS;

{$mode objfpc}{$H+}

uses
  {$DEFINE UseCThreads}
  {$IFDEF UNIX}{$IFDEF UseCThreads}
  cthreads,
  {$ENDIF}{$ENDIF}
  Interfaces, // this includes the LCL widgetset
  Forms, main, base, sourcesform, splash, Miscellaneous, payloads, direction,
  navigate, ssdv, log, settings, GPSSource, HabitatSource, SettingsBase,
  GeneralSettings, GPSSettings, GatewaySettings, UDPSettings, HabitatSettings,
  speech;

{$R *.res}

begin
  RequireDerivedFormResource:=True;
  Application.Scaled:=True;
  Application.Initialize;
  Application.CreateForm(TfrmMain, frmMain);
  Application.Run;
end.

