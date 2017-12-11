unit uMainServer;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics,   Vcl.Controls, Vcl.Forms, Vcl.Dialogs,
  ZeroMQ, ZeroMQ.API, Vcl.StdCtrls, Vcl.ExtCtrls;

type

  TSThread = class(TThread)
  private
    FReceiver: IZMQPair;
    FPublisher: IZMQPair;
  public
    constructor Create(aReceiver, aPublisher: IZMQPair);
    procedure Execute; override;
  end;

  TFMainServer = class(TForm)
    Panel1: TPanel;
    BtnIniciar: TButton;
    BtnPausar: TButton;
    Panel2: TPanel;
    MemoMessages: TMemo;
    procedure BtnIniciarClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure BtnPausarClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
    FContext: TZeroMQ;
    Receiver: IZMQPair;
    Publisher: IZMQPair;
    Server: TSThread;
    procedure CloseServer;
  public
    { Public declarations }

  end;

  procedure AddMessage(const aMessage: string);

var
  FMainServer: TFMainServer;

implementation

{$R *.dfm}

procedure AddMessage(const aMessage: string);
begin
  FMainServer.MemoMessages.Lines.Add(aMessage);
end;

{ TFMainServer }

procedure TFMainServer.BtnPausarClick(Sender: TObject);
begin
  if Assigned(Server) then
  begin
    Server.Terminate;
  end;

  BtnIniciar.Enabled := True;
  BtnPausar.Enabled := False;
end;

procedure TFMainServer.CloseServer;
begin
  if Assigned(Server) then
  begin
    Server.Terminate;
  end;
end;

procedure TFMainServer.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  CloseServer;
end;

procedure TFMainServer.FormCreate(Sender: TObject);
begin
  FContext := TZeroMQ.Create;
  Publisher := FContext.Start(ZMQSocket.Publisher);
  Receiver := FContext.Start(ZMQSocket.Pull);
end;

procedure TFMainServer.BtnIniciarClick(Sender: TObject);
begin
//  ServerInfo.ThreadHandle := BeginThread(nil, 0, @ServerThread, @FContext, 0, ServerInfo.ThreadId);

  Publisher.Bind('tcp://*:5000');
  Receiver.Bind('tcp://*:5001');

  Server := TSThread.Create(Receiver, Publisher);
  Server.Start;

  BtnIniciar.Enabled := False;
  BtnPausar.Enabled := True;
end;

{ TSThread }

constructor TSThread.Create(aReceiver, aPublisher: IZMQPair);
begin
  inherited Create(True);
  FReceiver := aReceiver;
  FPublisher := aPublisher;
end;

procedure TSThread.Execute;
var
  Received: String;
begin
  while True do
  begin
    Received := FReceiver.ReceiveString;
    if not Terminated then
    begin
      AddMessage('Received: ' + Received);
      FPublisher.SendString(Received);
    end
    else
      Break;
  end;
end;

end.
