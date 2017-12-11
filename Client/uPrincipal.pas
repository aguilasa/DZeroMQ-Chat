unit uPrincipal;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, ZeroMQ, ZeroMQ.API, Vcl.ExtCtrls,
  Vcl.StdCtrls, Vcl.ComCtrls, SyncObjs;

type

  TFPrincipal = class(TForm)
    Label1: TLabel;
    edNickname: TEdit;
    Button1: TButton;
    Button2: TButton;
    procedure edNicknameKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
  private
    { Private declarations }
    procedure ValidateNickname;
    procedure ShowChatForm;
  public
    { Public declarations }
  end;

var
  FPrincipal: TFPrincipal;

implementation

{$R *.dfm}

uses uChat;

{ TFPrincipal }

procedure TFPrincipal.Button1Click(Sender: TObject);
begin
  ValidateNickname;
end;

procedure TFPrincipal.Button2Click(Sender: TObject);
begin
  Close;
end;

procedure TFPrincipal.edNicknameKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Chr(Key) = #13 Then
  begin
    ValidateNickname;
  end;
end;

procedure TFPrincipal.ShowChatForm;
begin
  FChat := TFChat.Create(Application);
  try
    Hide;
    FChat.Nickname := edNickname.Text;
    FChat.ShowModal;
  finally
    Application.Terminate;
  end;
end;

procedure TFPrincipal.ValidateNickname;
begin
  if Length(Trim(edNickname.Text)) > 0 then
  begin
    ShowChatForm;
  end
  else
    raise Exception.Create('Nickname não informado.');
end;

end.
