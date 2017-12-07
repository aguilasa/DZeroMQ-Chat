unit uPrincipal;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, ZeroMQ, ZeroMQ.API, Vcl.StdCtrls, Vcl.ExtCtrls;

type
  TServerThread = class(TThread)
  private
    FMessage: string;
    FPublisher: IZMQPair;
    FReceiver: IZMQPair;
    FMemoMessage: TMemo;
    procedure WriteMessage;
  protected
    procedure Execute; override;
  public
    constructor Create(Publisher, Receiver: IZMQPair; MemoMessage: TMemo);
    destructor Destroy; override;
  end;

  TFPrincipal = class(TForm)
    Panel1: TPanel;
    BtnIniciar: TButton;
    BtnPausar: TButton;
    Panel2: TPanel;
    MemoMessages: TMemo;
    Timer1: TTimer;
    procedure BtnIniciarClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
  private
    { Private declarations }
    FContext: IZeroMQ;
    FPub: IZMQPair;
    FRec: IZMQPair;
    ServerThread: TServerThread;
  public
    { Public declarations }
  end;

var
  FPrincipal: TFPrincipal;

implementation

{$R *.dfm}

{ TWorkerThread }

constructor TServerThread.Create(Publisher, Receiver: IZMQPair; MemoMessage: TMemo);
begin
  inherited Create(False);
  FMessage := '';
  FPublisher := Publisher;
  FReceiver := Receiver;
  FMemoMessage := MemoMessage;
end;

destructor TServerThread.Destroy;
begin
  inherited;
end;

procedure TServerThread.Execute;
begin
  FMessage := FReceiver.ReceiveString;
  Synchronize(WriteMessage);
  FPublisher.SendString(FMessage);
end;

procedure TServerThread.WriteMessage;
begin
  if Assigned(FMemoMessage) then
  begin
    FMemoMessage.Lines.Add('Received: ' + FMessage);
  end;
end;

{ TFPrincipal }

procedure TFPrincipal.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  if Assigned(ServerThread) then
  begin
    FreeAndNil(ServerThread);
  end;

end;

procedure TFPrincipal.BtnIniciarClick(Sender: TObject);
begin
  FContext := TZeroMQ.Create;

  FPub := FContext.Start(ZMQSocket.Publisher);
  FPub.Bind('tcp://*:5000');

  FRec := FContext.Start(ZMQSocket.Pull);
  FRec.Bind('tcp://*:5001');

  ServerThread := TServerThread.Create(FPub, FRec, MemoMessages);
  BtnIniciar.Enabled := False;
end;

end.
