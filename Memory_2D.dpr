program Memory_2D;

uses
  Vcl.Forms,
  Main in 'Main.pas' {MainForm},
  MemoryGame in 'MemoryGame.pas';

{$R *.res}

begin
  ReportMemoryLeaksOnShutdown := DebugHook <> 0;

  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TMainForm, MainForm);
  Application.Run;
end.
