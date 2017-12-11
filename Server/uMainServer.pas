unit uMainServer;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics,   Vcl.Controls, Vcl.Forms, Vcl.Dialogs,
  ZeroMQ, ZeroMQ.API, Vcl.StdCtrls, Vcl.ExtCtrls;

type

  TThreadInfo = record
    ThreadHandle : Integer;
    ThreadId : Cardinal;
  end;

  TFMainServer = class(TForm)
    Panel1: TPanel;
    BtnIniciar: TButton;
    BtnPausar: TButton;
    Panel2: TPanel;
    MemoMessages: TMemo;
    procedure BtnIniciarClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
  private
    { Private declarations }
    FContext: TZeroMQ;
    ServerInfo: TThreadInfo;
  public
    { Public declarations }

  end;

  procedure AddMessage(const aMessage: string);
  function ServerThread(PContext: Pointer): Integer;
  procedure CloseThread(ThreadHandle : Integer);

var
  FMainServer: TFMainServer;

implementation

{$R *.dfm}

procedure AddMessage(const aMessage: string);
begin
  FMainServer.MemoMessages.Lines.Add(aMessage);
end;

function ServerThread(PContext: Pointer): Integer;
var
  Rec: IZMQPair;
  Pub: IZMQPair;
  Context: IZeroMQ;
  Received: String;
begin
  Context := PZeroMQ(PContext)^;

  Pub := Context.Start(ZMQSocket.Publisher);
  Pub.Bind('tcp://*:5000');
  Rec := Context.Start(ZMQSocket.Pull);
  Rec.Bind('tcp://*:5001');

  while true do
  begin
    Received := Rec.ReceiveString;
    AddMessage('Received: ' + Received);
    Pub.SendString(Received);
  end;
  Result := 0;
end;

procedure CloseThread(ThreadHandle : Integer);
begin
  if ThreadHandle <> 0 then
    CloseHandle(ThreadHandle);
end;

{ TFMainServer }

procedure TFMainServer.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  CloseThread(ServerInfo.ThreadHandle);
end;

procedure TFMainServer.BtnIniciarClick(Sender: TObject);
begin
  FContext := TZeroMQ.Create;
  ServerInfo.ThreadHandle := BeginThread(nil, 0, @ServerThread, @FContext, 0, ServerInfo.ThreadId);
  BtnIniciar.Enabled := False;
end;

end.