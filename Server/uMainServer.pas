unit uMainServer;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics,   Vcl.Controls, Vcl.Forms, Vcl.Dialogs,
  ZeroMQ, ZeroMQ.API, Vcl.StdCtrls, Vcl.ExtCtrls, BaseUtil;

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
    MemoMessages: TListBox;
    procedure BtnIniciarClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure BtnPausarClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure MemoMessagesDblClick(Sender: TObject);
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

  procedure AddMessage(aMessage: TArray<TBytes>);
  procedure AddStringMessage(aReceivedData: TReceivedData);
  procedure AddStreamMessage(aReceivedData: TReceivedData);

var
  FMainServer: TFMainServer;

implementation

{$R *.dfm}

procedure AddStreamMessage(aReceivedData: TReceivedData);
var
  StreamData: TStreamData;
  Buffer: TBytes;
  Len: Integer;
  S: string;
begin
  StreamData := TStreamData.Create;
  StreamData.Name := aReceivedData.StreamName;
  Buffer := aReceivedData.StreamData;
  Len := Length(Buffer);
  StreamData.Stream.Read(Buffer, Len);
  S := Format('%s: enviou imagem.', [aReceivedData.Nickname]);
  FMainServer.MemoMessages.Items.AddObject(S, StreamData);
end;

procedure AddStringMessage(aReceivedData: TReceivedData);
var
  Value: string;
begin
  if aReceivedData.MessageType = mtJoin then
    Value := aReceivedData.StringMessage
  else
    Value := Format('%s: %s', [aReceivedData.Nickname, aReceivedData.StringMessage]);

  FMainServer.MemoMessages.ItemIndex := FMainServer.MemoMessages.Items.Add(Value);
end;

procedure AddMessage(aMessage: TArray<TBytes>);
var
  Reader: TReaderData;
  Received: TReceivedData;
begin
  Reader := TReaderData.Create(aMessage);;
  try
    Received := Reader.GetReceivedData;
    if Received.MessageType in [mtJoin, mtString] then
    begin
      AddStringMessage(Received);
    end
    else
    begin
      AddStreamMessage(Received);
    end;
  finally
    Reader.Free;
  end;
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

procedure TFMainServer.MemoMessagesDblClick(Sender: TObject);
var
  StreamData: TStreamData;
  Index: Integer;
begin
  Index := MemoMessages.ItemIndex;
  if Index > -1 then
  begin
    StreamData := TStreamData(MemoMessages.Items.Objects[Index]);
    if Assigned(StreamData) then
    begin

    end;
  end;

end;

procedure TFMainServer.BtnIniciarClick(Sender: TObject);
begin
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
  Received: TArray<TBytes>;
begin
  while True do
  begin
    Received := FReceiver.ReceiveListBytes;
    if not Terminated then
    begin
      AddMessage(Received);
      FPublisher.SendListBytes(Received);
    end
    else
      Break;
  end;
end;

end.
