unit Unit1;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, WorkerThread;

const
  WM_MyProgress = WM_USER + 0; // The unique message id

type
  TForm1 = class(TForm)
    Label1: TLabel;
    Label2: TLabel;
    btnStartTask: TButton;
    btnPauseResume: TButton;
    btnCancelTask: TButton;procedure btnStartTaskClick(Sender: TObject);
    procedure btnPauseResumeClick(Sender: TObject);
    procedure btnCancelTaskClick(Sender: TObject);
  private
    { Private declarations }
    MyThread: TWorkerThread;
    workLoopIx: integer;

    function HeavyWork: boolean;
    procedure OnMyProgressMsg(var Msg: TMessage); message WM_MyProgress;
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

{$R *.dfm}

{ TForm1 }
const
  cWorkLoopMax = 500;

function TForm1.HeavyWork: boolean; // True when ready
var
  i, j: integer;
begin
  j := 0;
  for i := 0 to 10000000 do
    Inc(j);
  Inc(workLoopIx);
  Result := (workLoopIx >= cWorkLoopMax);
end;

procedure TForm1.btnStartTaskClick(Sender: TObject);
begin
  if not Assigned(MyThread) then
  begin
    workLoopIx := 0;
    btnStartTask.Enabled := false;
    btnPauseResume.Enabled := true;
    btnCancelTask.Enabled := true;
    MyThread := TWorkerThread.Create(Self.Handle, WM_MyProgress, HeavyWork);
  end;
end;

procedure TForm1.btnPauseResumeClick(Sender: TObject);
begin
  if Assigned(MyThread) then
    MyThread.Paused := not MyThread.Paused;
end;

procedure TForm1.btnCancelTaskClick(Sender: TObject);
begin
  if Assigned(MyThread) then
  begin
    FreeAndNil(MyThread);
    btnStartTask.Enabled := true;
    btnPauseResume.Enabled := false;
    btnCancelTask.Enabled := false;
  end;
end;

procedure TForm1.OnMyProgressMsg(var Msg: TMessage);
begin
  Msg.Msg := 1;
  case Msg.LParam of
    0:
      Label1.Caption := Format('%5.1f %%', [100.0 * Msg.WParam / cWorkLoopMax]);
    1:
      begin
        Label1.Caption := 'Task done';
        btnCancelTaskClick(Self);
      end;
    2:
      Label1.Caption := 'Task terminated';
  end;
end;

end.
