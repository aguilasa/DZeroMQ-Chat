unit uChat;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, ZeroMQ, ZeroMQ.API, Vcl.ExtCtrls,
  Vcl.StdCtrls, Vcl.ComCtrls, SyncObjs, Vcl.ToolWin;

type
  PMessageRecord = ^TMessageRecord;
  TMessageRecord = record
    Context: IZeroMQ;
    Message: string;
  end;


  TThreadInfo = record
    ThreadHandle : Integer;
    ThreadId : Cardinal;
  end;

  TFChat = class(TForm)
    StatusB: TStatusBar;
    PnMessages: TPanel;
    Panel2: TPanel;
    EdMessage: TEdit;
    Panel1: TPanel;
    btnConnect: TButton;
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormShow(Sender: TObject);
    procedure EdMessageKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
    FConected: Boolean;
    FNickName: string;
    FContext: IZeroMQ;
    FSender: IZMQPair;
    FReceiver: IZMQPair;
    FPoller: IZMQPoll;
    SenderInfo: TThreadInfo;
    MessageRec: TMessageRecord;
    procedure Initialize;
    procedure ShowMessagePanel;
    procedure CreateSockets;
    procedure UpdateStatusBar;
    procedure SendMessage;
  public
    { Public declarations }

    property Nickname: string read FNickname write FNickname;
  end;

var
  FChat: TFChat;

implementation

{$R *.dfm}

function SenderThread(MsgRec: Pointer): Integer;
var
  MessageRec: TMessageRecord;
  Sender: IZMQPair;
  Context: IZeroMQ;
begin
  MessageRec := PMessageRecord(MsgRec)^;
  Context := MessageRec.Context;
  Sender := Context.Start(ZMQSocket.Push);
  Sender.Connect('tcp://localhost:5001');
  Sender.SendString(MessageRec.Message);
  Result := 0;
end;

{ TFChat }

procedure TFChat.CreateSockets;
begin
  FContext := TZeroMQ.Create;
  FSender := FContext.Start(ZMQSocket.Push);
  FSender.Connect('tcp://localhost:5001');
{
  FReceiver := FContext.Start(ZMQSocket.Subscriber);
  FReceiver.Bind('tcp://*:5000');
  FReceiver.Subscribe('');

  FPoller := FContext.Poller;
  FPoller.RegisterPair(FReceiver, [PollIn]);   }

//  FClientThread := TClientThread.Create(FPoller, FReceiver, ListBox1);
end;

procedure TFChat.EdMessageKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if (Chr(Key) = #13) and (Length(Trim(EdMessage.Text)) > 0) then
  begin
    SendMessage;
  end;
end;

procedure TFChat.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Action := caFree;
end;

procedure TFChat.FormCreate(Sender: TObject);
begin
  CreateSockets;
end;

procedure TFChat.FormShow(Sender: TObject);
begin
  UpdateStatusBar;
end;

procedure TFChat.Initialize;
begin
end;

procedure TFChat.SendMessage;
begin
  FSender.SendString(EdMessage.Text);
  EdMessage.Text := '';
{
  MessageRec.Context := FContext;
  MessageRec.Message := EdMessage.Text;
  EdMessage.Text := '';
  SenderInfo.ThreadHandle := BeginThread(nil, 0, @SenderThread, @MessageRec, 0, SenderInfo.ThreadId);
}
end;

procedure TFChat.ShowMessagePanel;
begin
end;


procedure TFChat.UpdateStatusBar;
const
  CONAS = 'Conectado como: %s';
  UNCON = 'Desconectado';
begin
  if FConected then
    StatusB.Panels[0].Text := Format(CONAS, [Nickname])
  else
    StatusB.Panels[0].Text := UNCON;
end;

end.
