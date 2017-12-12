unit uChat;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ExtCtrls, Vcl.StdCtrls,
  Vcl.ComCtrls, SyncObjs, Vcl.ToolWin, ZeroMQ, ZeroMQ.API, BaseUtil;

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
    PnTop: TPanel;
    btnConnect: TButton;
    LbMessages: TListBox;
    edNickname: TEdit;
    Label1: TLabel;
    BtnImage: TButton;
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormShow(Sender: TObject);
    procedure EdMessageKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure FormCreate(Sender: TObject);
    procedure btnConnectClick(Sender: TObject);
    procedure edNicknameKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure BtnImageClick(Sender: TObject);
  private
    { Private declarations }
    FConnected: Boolean;
    FNickName: string;
    FContext: TZeroMQ;
    FSender: IZMQPair;
    ReceiverInfo: TThreadInfo;
    procedure CreateSockets;
    procedure UpdateStatusBar;
    procedure CreateReceiverThread;
    procedure Connect;
    procedure EnableMessagePanel;
    procedure EnableConnectButton;
    procedure EnableTopPanel;
    procedure ValidateNickname;
    procedure SendStringMessage(const aMessage: string; aMessageType: TMessageType = mtString);
    procedure SendJoinMessage;
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

procedure TFChat.BtnImageClick(Sender: TObject);
//var
//  Writer: TWriterManager;
begin
//  Writer := TWriterManager.Create;
//  try
//    Writer.Writer.Write(1);
//    Writer.Writer.Write(Nickname);
//    Writer.Writer.Write(EdMessage.Text);
//    FSender.SendStream(Writer.Stream);
//  finally
//    FreeAndNil(Writer);
//  end;
end;

procedure TFChat.Connect;
begin
  ValidateNickname;
  CreateSockets;
  CreateReceiverThread;
  FConnected := True;
  EnableMessagePanel;
  EnableConnectButton;
  EnableTopPanel;
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
  SendJoinMessage;
end;

procedure TFChat.EdMessageKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if (Chr(Key) = #13) and (Length(Trim(EdMessage.Text)) > 0) then
  begin
    SendStringMessage(Trim(EdMessage.Text));
    EdMessage.Text := '';
  end;
end;

procedure TFChat.edNicknameKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Chr(Key) = #13 Then
  begin
    Connect;
  end;
end;

procedure TFChat.EnableConnectButton;
begin
  btnConnect.Enabled := not FConnected;
end;

procedure TFChat.EnableMessagePanel;
begin
  PnMessages.Enabled := FConnected;
end;

procedure TFChat.EnableTopPanel;
begin
  PnTop.Enabled := not FConnected;
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

procedure TFChat.SendJoinMessage;
const
  CENTER = '%s acaba de entrar.';
begin
  SendStringMessage(Format(CENTER, [Nickname]), mtJoin);
end;

//procedure TFChat.SendStringMessage(const aMessage: string; aMessageType: TMessageType);
//var
//  Writer: TWriterManager;
//  MTByte: Byte;
//begin
//  Writer := TWriterManager.Create;
//  try
//    MTByte := Byte(aMessageType);
//    Writer.Writer.Write(MTByte);
//    Writer.Writer.Write(Nickname);
//    Writer.Writer.Write(aMessage);
//    Writer.Writer.Close;
//    FSender.SendStream(Writer.Stream);
//  finally
//    FreeAndNil(Writer);
//  end;
//end;

procedure TFChat.SendStringMessage(const aMessage: string; aMessageType: TMessageType);
var
  Writer: TWriter;
begin
  Writer := TWriter.Create;
  try
    Writer.WriteByte(Byte(aMessageType));
    Writer.WriteString(Nickname);
    Writer.WriteString(aMessage);
    FSender.SendStream(Writer.Stream);
  finally
    FreeAndNil(Writer);
  end;
end;

procedure TFChat.UpdateStatusBar;
const
  CONAS = 'Conectado como: %s';
  UNCON = 'Desconectado';
begin
  if FConnected then
    StatusB.Panels[0].Text := Format(CONAS, [Nickname])
  else
    StatusB.Panels[0].Text := UNCON;
end;

procedure TFChat.ValidateNickname;
begin
  Nickname := Trim(edNickname.Text);
  if Length(Nickname) = 0 then
  begin
    edNickname.SetFocus;
    raise Exception.Create('Nickname não informado.');
  end;
end;

end.
