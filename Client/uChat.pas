unit uChat;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, ZeroMQ, ZeroMQ.API, Vcl.ExtCtrls,
  Vcl.StdCtrls, Vcl.ComCtrls, SyncObjs, Vcl.ToolWin, BaseUtil, Vcl.ExtDlgs;

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
    MemoMessages: TListBox;
    edNickname: TEdit;
    Label1: TLabel;
    openDialog: TOpenPictureDialog;
    BtnImagem: TButton;
    PnImage: TPanel;
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormShow(Sender: TObject);
    procedure EdMessageKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure FormCreate(Sender: TObject);
    procedure btnConnectClick(Sender: TObject);
    procedure edNicknameKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure BtnImagemClick(Sender: TObject);
    procedure MemoMessagesClick(Sender: TObject);
  private
    { Private declarations }
    FConected: Boolean;
    FNickName: string;
    FContext: TZeroMQ;
    FSender: IZMQPair;
    ReceiverInfo: TThreadInfo;
    procedure CreateSockets;
    procedure UpdateStatusBar;
    procedure SendMessage;
    procedure CreateReceiverThread;
    procedure Connect;
    procedure EnableMessagePanel;
    procedure EnableConnectButton;
    procedure ValidateNickname;
    procedure SendJoinMessage;
    procedure SendStringMessage(const aMessage: string; aType: TMessageType = mtString);
    procedure SendStreamMessage(aStream: TMemoryStream; const aName: string);
  public
    { Public declarations }

    property Nickname: string read FNickname write FNickname;
  end;

  procedure AddMessage(aMessage: TArray<TBytes>);
  procedure AddStringMessage(aReceivedData: TReceivedData);
  procedure AddStreamMessage(aReceivedData: TReceivedData);

var
  FChat: TFChat;

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
  FChat.MemoMessages.Items.AddObject(S, StreamData);
end;

procedure AddStringMessage(aReceivedData: TReceivedData);
var
  Value: string;
begin
  if aReceivedData.MessageType = mtJoin then
    Value := aReceivedData.StringMessage
  else
    Value := Format('%s: %s', [aReceivedData.Nickname, aReceivedData.StringMessage]);
  FChat.MemoMessages.Items.Add(Value);
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

function ReceiverThread(PContext: Pointer): Integer;
var
  Receiver: IZMQPair;
  Poller: IZMQPoll;
  Context: IZeroMQ;
  Received: TArray<TBytes>;
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
      Received := Receiver.ReceiveListBytes;
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

procedure TFChat.BtnImagemClick(Sender: TObject);
var
  Stream: TMemoryStream;
  FileName, FilePath: String;
begin
  if openDialog.Execute then
  begin
    FilePath := openDialog.FileName;
    FileName := ExtractFileName(FilePath);
    Stream := TMemoryStream.Create;
    try
      Stream.LoadFromFile(FilePath);
      SendStreamMessage(Stream, FileName);
    finally
      Stream.Free;
    end;
  end;
end;

procedure TFChat.Connect;
begin
  ValidateNickname;
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
  SendJoinMessage;
end;

procedure TFChat.EdMessageKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if (Chr(Key) = #13) and (Length(Trim(EdMessage.Text)) > 0) then
  begin
    SendMessage;
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

procedure TFChat.MemoMessagesClick(Sender: TObject);
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

procedure TFChat.SendJoinMessage;
const
  CENTER = '%s acaba de entrar.';
begin
  SendStringMessage(Format(CENTER, [Nickname]), mtJoin);
end;

procedure TFChat.SendMessage;
begin
  SendStringMessage(EdMessage.Text);
  EdMessage.Text := '';
end;

procedure TFChat.SendStreamMessage(aStream: TMemoryStream; const aName: string);
var
  Writer: TBytesWriter;
begin
  Writer := TBytesWriter.Create;
  try
    Writer.WriteByte(Ord(mtStream));
    Writer.WriteString(Nickname);
    Writer.WriteString(aName);
    Writer.WriteStream(aStream);
    FSender.SendListBytes(Writer.Bytes);
  finally
    Writer.Free;
  end;
end;

procedure TFChat.SendStringMessage(const aMessage: string; aType: TMessageType = mtString);
var
  Writer: TBytesWriter;
begin
  Writer := TBytesWriter.Create;
  try
    Writer.WriteByte(Ord(aType));
    Writer.WriteString(Nickname);
    Writer.WriteString(aMessage);
    FSender.SendListBytes(Writer.Bytes);
  finally
    Writer.Free;
  end;
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
