unit uMainServer;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics,   Vcl.Controls, Vcl.Forms, Vcl.Dialogs,
  ZeroMQ, ZeroMQ.API, Vcl.StdCtrls, Vcl.ExtCtrls, BaseUtil;

type

  TStreamData = record
    MessageType: TMessageType;
    Nickname: string;
    StringMessage: string;
    StreamSize: Integer;
    StreamData: TMemoryStream;
  end;

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

function ProcessStreamData(aStream: TMemoryStream): TStreamData;
var
  Reader: TReader;
  Buffer: PChar;
  Size: Integer;
begin
  aStream.Seek(0, soFromBeginning);
  Reader := TReader.Create(aStream);
  try
     Size := Reader.ReadByte;
     Result.MessageType := TMessageType(Size);
     Result.Nickname := Reader.ReadString;

     if Result.MessageType in [mtJoin, mtString] then
     begin
       Result.StringMessage := Reader.ReadString;
     end
     else if Result.MessageType = mtStream then
     begin

     end;
  finally
     FreeAndNil(Reader);
  end;
end;

procedure AddMessage(const aMessage: string);
begin
  FMainServer.MemoMessages.Lines.Add(aMessage);
end;

procedure AddStreamMessage(aMessage: TMemoryStream);
const
  CSEND = '%s: %s';
var
  StreamData: TStreamData;
begin
  StreamData := ProcessStreamData(aMessage);
  if StreamData.MessageType in [mtJoin, mtString] then
  begin
    AddMessage(Format(CSEND, [StreamData.Nickname, StreamData.StringMessage]));
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

{
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
}

procedure TSThread.Execute;
var
  Received: TMemoryStream;
begin
  while True do
  begin
    Received := FReceiver.ReceiveStream;
    if not Terminated then
    begin
      try
        AddStreamMessage(Received);
        FPublisher.SendStream(Received);
      finally
        Received.Free;
      end;
    end
    else
      Break;
  end;
end;



end.
