unit uChat;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, ZeroMQ, ZeroMQ.API, Vcl.ExtCtrls,
  Vcl.StdCtrls, Vcl.ComCtrls, SyncObjs, Vcl.ToolWin;

type

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
    LbMessages: TListBox;
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormShow(Sender: TObject);
    procedure EdMessageKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure FormCreate(Sender: TObject);
    procedure btnConnectClick(Sender: TObject);
  private
    { Private declarations }
    FConected: Boolean;
    FNickName: string;
    FContext: TZeroMQ;
    FSender: IZMQPair;
    ReceiverInfo: TThreadInfo;
    procedure Initialize;
    procedure ShowMessagePanel;
    procedure CreateSockets;
    procedure UpdateStatusBar;
    procedure SendMessage;
    procedure CreateReceiverThread;
    procedure Connect;
    procedure EnableMessagePanel;
    procedure EnableConnectButton;
  public
    { Public declarations }

    property Nickname: string read FNickname write FNickname;
  end;

var
  FChat: TFChat;

implementation

{$R *.dfm}

procedure AddMessage(const aMessage: string);
begin
  FChat.LbMessages.Items.Add(aMessage);
end;

function ReceiverThread(PContext: Pointer): Integer;
var
  Receiver: IZMQPair;
  Poller: IZMQPoll;
  Context: IZeroMQ;
  Received: String;
  Events: Integer;
begin
  Context := PZeroMQ(PContext)^;

  Receiver := Context.Start(ZMQSocket.Subscriber);
  Receiver.Connect('tcp://localhost:5000');
  Receiver.Subscribe('');

  Poller := Context.Poller;
  Poller.RegisterPair(Receiver, [PollIn]);

  while true do
  begin
    Events := Poller.PollOnce;
    if Events > 0 then
    begin
      Received := Receiver.ReceiveString;
      AddMessage(Received);
    end;
  end;
  Result := 0;
end;

procedure CloseThread(ThreadHandle : Integer);
begin
  if ThreadHandle <> 0 then
    CloseHandle(ThreadHandle);
end;

{ TFChat }

procedure TFChat.btnConnectClick(Sender: TObject);
begin
  Connect;
end;

procedure TFChat.Connect;
begin
  CreateSockets;
  CreateReceiverThread;
  FConected := True;
  EnableMessagePanel;
  EnableConnectButton;
  UpdateStatusBar;
end;

procedure TFChat.CreateReceiverThread;
begin
  ReceiverInfo.ThreadHandle := BeginThread(nil, 0, @ReceiverThread, @FContext, 0, ReceiverInfo.ThreadId);
end;

procedure TFChat.CreateSockets;
begin
  FContext := TZeroMQ.Create;
  FSender := FContext.Start(ZMQSocket.Push);
  FSender.Connect('tcp://localhost:5001');
end;

procedure TFChat.EdMessageKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if (Chr(Key) = #13) and (Length(Trim(EdMessage.Text)) > 0) then
  begin
    SendMessage;
  end;
end;

procedure TFChat.EnableConnectButton;
begin
  btnConnect.Enabled := not FConected;
end;

procedure TFChat.EnableMessagePanel;
begin
  PnMessages.Enabled := FConected;
end;

procedure TFChat.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  CloseThread(ReceiverInfo.ThreadHandle);
  Action := caFree;
end;

procedure TFChat.FormCreate(Sender: TObject);
begin
//  CreateSockets;
end;

procedure TFChat.FormShow(Sender: TObject);
begin
  EnableMessagePanel;
  UpdateStatusBar;
end;

procedure TFChat.Initialize;
begin
end;

procedure TFChat.SendMessage;
begin
  FSender.SendString(EdMessage.Text);
  EdMessage.Text := '';
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
