program ServerChat;

uses
  Vcl.Forms,
  uPrincipal in 'uPrincipal.pas' {FPrincipal};

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TFPrincipal, FPrincipal);
  Application.Run;
end.
