{$A8,B-,C+,D+,E-,F-,G+,H+,I+,J-,K-,L+,M-,N-,O+,P+,Q-,R-,S-,T-,U-,V+,W-,X+,Y+,Z1}
{$MINSTACKSIZE $00004000}
{$MAXSTACKSIZE $00100000}
{$IMAGEBASE $00400000}
{$APPTYPE GUI}
{$WARN SYMBOL_DEPRECATED ON}
{$WARN SYMBOL_LIBRARY ON}
{$WARN SYMBOL_PLATFORM ON}
{$WARN SYMBOL_EXPERIMENTAL ON}
{$WARN UNIT_LIBRARY ON}
{$WARN UNIT_PLATFORM ON}
{$WARN UNIT_DEPRECATED ON}
{$WARN UNIT_EXPERIMENTAL ON}
{$WARN HRESULT_COMPAT ON}
{$WARN HIDING_MEMBER ON}
{$WARN HIDDEN_VIRTUAL ON}
{$WARN GARBAGE ON}
{$WARN BOUNDS_ERROR ON}
{$WARN ZERO_NIL_COMPAT ON}
{$WARN STRING_CONST_TRUNCED ON}
{$WARN FOR_LOOP_VAR_VARPAR ON}
{$WARN TYPED_CONST_VARPAR ON}
{$WARN ASG_TO_TYPED_CONST ON}
{$WARN CASE_LABEL_RANGE ON}
{$WARN FOR_VARIABLE ON}
{$WARN CONSTRUCTING_ABSTRACT ON}
{$WARN COMPARISON_FALSE ON}
{$WARN COMPARISON_TRUE ON}
{$WARN COMPARING_SIGNED_UNSIGNED ON}
{$WARN COMBINING_SIGNED_UNSIGNED ON}
{$WARN UNSUPPORTED_CONSTRUCT ON}
{$WARN FILE_OPEN ON}
{$WARN FILE_OPEN_UNITSRC ON}
{$WARN BAD_GLOBAL_SYMBOL ON}
{$WARN DUPLICATE_CTOR_DTOR ON}
{$WARN INVALID_DIRECTIVE ON}
{$WARN PACKAGE_NO_LINK ON}
{$WARN PACKAGED_THREADVAR ON}
{$WARN IMPLICIT_IMPORT ON}
{$WARN HPPEMIT_IGNORED ON}
{$WARN NO_RETVAL ON}
{$WARN USE_BEFORE_DEF ON}
{$WARN FOR_LOOP_VAR_UNDEF ON}
{$WARN UNIT_NAME_MISMATCH ON}
{$WARN NO_CFG_FILE_FOUND ON}
{$WARN IMPLICIT_VARIANTS ON}
{$WARN UNICODE_TO_LOCALE ON}
{$WARN LOCALE_TO_UNICODE ON}
{$WARN IMAGEBASE_MULTIPLE ON}
{$WARN SUSPICIOUS_TYPECAST ON}
{$WARN PRIVATE_PROPACCESSOR ON}
{$WARN UNSAFE_TYPE OFF}
{$WARN UNSAFE_CODE OFF}
{$WARN UNSAFE_CAST OFF}
{$WARN OPTION_TRUNCATED ON}
{$WARN WIDECHAR_REDUCED ON}
{$WARN DUPLICATES_IGNORED ON}
{$WARN UNIT_INIT_SEQ ON}
{$WARN LOCAL_PINVOKE ON}
{$WARN MESSAGE_DIRECTIVE ON}
{$WARN TYPEINFO_IMPLICITLY_ADDED ON}
{$WARN RLINK_WARNING ON}
{$WARN IMPLICIT_STRING_CAST ON}
{$WARN IMPLICIT_STRING_CAST_LOSS ON}
{$WARN EXPLICIT_STRING_CAST OFF}
{$WARN EXPLICIT_STRING_CAST_LOSS OFF}
{$WARN CVT_WCHAR_TO_ACHAR ON}
{$WARN CVT_NARROWING_STRING_LOST ON}
{$WARN CVT_ACHAR_TO_WCHAR ON}
{$WARN CVT_WIDENING_STRING_LOST ON}
{$WARN NON_PORTABLE_TYPECAST ON}
{$WARN XML_WHITESPACE_NOT_ALLOWED ON}
{$WARN XML_UNKNOWN_ENTITY ON}
{$WARN XML_INVALID_NAME_START ON}
{$WARN XML_INVALID_NAME ON}
{$WARN XML_EXPECTED_CHARACTER ON}
{$WARN XML_CREF_NO_RESOLVE ON}
{$WARN XML_NO_PARM ON}
{$WARN XML_NO_MATCHING_PARM ON}
{$WARN IMMUTABLE_STRINGS OFF}
unit uChat;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, ZeroMQ, ZeroMQ.API, Vcl.ExtCtrls,
  Vcl.StdCtrls, Vcl.ComCtrls, SyncObjs, Vcl.ToolWin, BaseUtil, Vcl.ExtDlgs, JPEG;

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
    MemoMessages: TListBox;
    edNickname: TEdit;
    Label1: TLabel;
    openDialog: TOpenPictureDialog;
    BtnImagem: TButton;
    PnImage: TPanel;
    Image1: TImage;
    Splitter1: TSplitter;
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
    FConnected: Boolean;
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
    procedure EnableTopPanel;
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
  StreamData.Stream.Write(Buffer, Len);
  StreamData.Stream.Seek(0, 0);
  S := Format('%s: enviou imagem.', [aReceivedData.Nickname]);
  FChat.MemoMessages.ItemIndex := FChat.MemoMessages.Items.AddObject(S, StreamData);
end;

procedure AddStringMessage(aReceivedData: TReceivedData);
var
  Value: string;
begin
  if aReceivedData.MessageType = mtJoin then
    Value := aReceivedData.StringMessage
  else
    Value := Format('%s: %s', [aReceivedData.Nickname, aReceivedData.StringMessage]);

  FChat.MemoMessages.ItemIndex := FChat.MemoMessages.Items.Add(Value);
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
  edNickname.SetFocus;
  EnableMessagePanel;
  UpdateStatusBar;
end;

procedure TFChat.MemoMessagesClick(Sender: TObject);
var
  StreamData: TStreamData;
  Index: Integer;
  JPEGImage: TJPEGImage;
begin
  Splitter1.Visible := False;
  PnImage.Visible := False;
  Index := MemoMessages.ItemIndex;
  if Index > -1 then
  begin
    StreamData := TStreamData(MemoMessages.Items.Objects[Index]);
    if Assigned(StreamData) then
    begin

      PnImage.Visible := True;
      Splitter1.Visible := True;

      StreamData.Stream.Position := 0;
      JPEGImage := TJPEGImage.Create;
      try
        JPEGImage.LoadFromStream(StreamData.Stream);
        Image1.Picture.Assign(JPEGImage);
      finally
        JPEGImage.Free;
      end;
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
