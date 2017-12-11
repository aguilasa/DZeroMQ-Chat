program ChatClient;

uses
  Vcl.Forms,
  uPrincipal in 'uPrincipal.pas' {FPrincipal},
  uChat in 'uChat.pas' {FChat};

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TFChat, FChat);
  //  IsMultiThread := True;
  Application.Run;
end.
