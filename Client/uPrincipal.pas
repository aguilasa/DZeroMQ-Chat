unit uPrincipal;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, ZeroMQ, ZeroMQ.API, Vcl.ExtCtrls,
  Vcl.StdCtrls, Vcl.ComCtrls, SyncObjs;

type
  TClientThread = class(TThread)
  private
    FMessage: string;
    FCReceiver: IZMQPair;
    FCPoller: IZMQPoll;
    FListMessage: TListBox;
   // FTerminateEvent: TEvent;
    procedure WriteMessage;
  protected
    procedure Execute; override;
  public
    constructor Create(Poller: IZMQPoll; Receiver: IZMQPair; ListMessage: TListBox);
    destructor Destroy; override;
    procedure Stop;
  end;

  TFPrincipal = class(TForm)
    StatusB: TStatusBar;
    PnMessages: TPanel;
    Panel2: TPanel;
    EdMessage: TEdit;
    ListBox1: TListBox;
    PnNick: TPanel;
    Label1: TLabel;
    EdNick: TEdit;
    procedure FormShow(Sender: TObject);
    procedure EdNickKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure EdMessageKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
  private
    { Private declarations }
    FNickName: string;
    FContext: IZeroMQ;
    FSender: IZMQPair;
    FReceiver: IZMQPair;
    FPoller: IZMQPoll;
    FClientThread: TClientThread;
    procedure Initialize;
    procedure ShowMessagePanel;
    procedure CreateSockets;
  public
    { Public declarations }
  end;

var
  FPrincipal: TFPrincipal;

implementation

{$R *.dfm}

{ TFPrincipal }

procedure TFPrincipal.CreateSockets;
begin
  FContext := TZeroMQ.Create;

  FSender := FContext.Start(ZMQSocket.Push);
  FSender.Bind('tcp://*:5001');

  FReceiver := FContext.Start(ZMQSocket.Subscriber);
  FReceiver.Bind('tcp://*:5000');
  FReceiver.Subscribe('');

  FPoller := FContext.Poller;
  FPoller.RegisterPair(FReceiver, [PollIn]);

  FClientThread := TClientThread.Create(FPoller, FReceiver, ListBox1);
end;

procedure TFPrincipal.EdMessageKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Chr(Key) = #13 Then
  begin
    if Length(Trim(EdNick.Text)) > 0 then
    begin
      FSender.SendString(EdMessage.Text);
      EdMessage.Text := '';
    end;
  end;
end;

procedure TFPrincipal.EdNickKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Chr(Key) = #13 Then
  begin
    if Length(Trim(EdNick.Text)) > 0 then
    begin
      CreateSockets;
      FNickName := EdNick.Text;
      StatusB.Panels[1].Text := FNickName;
      ShowMessagePanel;
    end;
  end;
end;

procedure TFPrincipal.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  if Assigned(FClientThread) then
  begin
    FClientThread.Stop;
    FreeAndNil(FClientThread);
  end;
  Action := caFree;
  Application.Terminate;
end;

procedure TFPrincipal.FormShow(Sender: TObject);
begin
  Initialize;
end;

procedure TFPrincipal.Initialize;
begin
  PnNick.Visible := True;
  StatusB.Visible := False;
  PnMessages.Visible := False;
end;

procedure TFPrincipal.ShowMessagePanel;
begin
  PnNick.Visible := False;
  StatusB.Visible := True;
  PnMessages.Visible := True;
end;

{ TClientThread }

constructor TClientThread.Create(Poller: IZMQPoll; Receiver: IZMQPair;
  ListMessage: TListBox);
begin
//  FTerminateEvent := TEvent.Create(nil, True, False, 'FTerminateEvent');
  inherited Create(False);
  FCPoller := Poller;
  FCReceiver := Receiver;
  FListMessage := ListMessage;
end;

destructor TClientThread.Destroy;
begin
//  FTerminateEvent.Free;
  inherited;
end;

procedure TClientThread.Execute;
var
  events: Integer;
begin
  while not Terminated do
  begin
    events := FCPoller.PollOnce();
    if events > 0 then
    begin
      FMessage := FCReceiver.ReceiveString;
      Synchronize(WriteMessage);
    end;
//    FTerminateEvent.WaitFor(5000);
  end;
end;

procedure TClientThread.Stop;
begin
  Terminate;
//  FTerminateEvent.SetEvent;
end;

procedure TClientThread.WriteMessage;
begin
  if Assigned(FListMessage) then
  begin
    FListMessage.Items.Add(FMessage);
   end;
end;

end.
