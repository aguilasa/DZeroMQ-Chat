program ServerChat;

uses
  Vcl.Forms,
  uMainServer in 'uMainServer.pas' {FMainServer};

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TFMainServer, FMainServer);
  Application.Run;
end.
