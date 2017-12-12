unit WorkerThread;

interface

uses Windows, Classes, SyncObjs;

type
  TWorkFunction = function: boolean of object;

  TWorkerThread = Class(TThread)
  private
    FCancelFlag: TSimpleEvent;
    FDoWorkFlag: TSimpleEvent;
    FOwnerFormHandle: HWND;
    FWorkFunc: TWorkFunction; // Function method to call
    FCallbackMsg: integer; // PostMessage id
    FProgress: integer;
    procedure SetPaused(doPause: boolean);
    function GetPaused: boolean;
  public
    procedure Execute; override;
    Constructor Create(WindowHandle: HWND; callbackMsg: integer; myWorkFunc: TWorkFunction);
    Destructor Destroy; override;
    function StartNewWork(newWorkFunc: TWorkFunction): boolean;
    property Paused: boolean read GetPaused write SetPaused;
  end;

implementation

constructor TWorkerThread.Create(WindowHandle: HWND; callbackMsg: integer;
  myWorkFunc: TWorkFunction);
begin
  inherited Create(false);
  FOwnerFormHandle := WindowHandle;
  FDoWorkFlag := TSimpleEvent.Create;
  FCancelFlag := TSimpleEvent.Create;
  FWorkFunc := myWorkFunc;
  FCallbackMsg := callbackMsg;
  Self.FreeOnTerminate := false; // Main thread controls for thread destruction
  if Assigned(FWorkFunc) then
    FDoWorkFlag.SetEvent; // Activate work at start
end;

destructor TWorkerThread.Destroy; // Call MyWorkerThread.Free to cancel the thread
begin
  FDoWorkFlag.ResetEvent; // Stop ongoing work
  FCancelFlag.SetEvent; // Set cancel flag
  Waitfor; // Synchronize
  FCancelFlag.Free;
  FDoWorkFlag.Free;
  inherited;
end;

procedure TWorkerThread.SetPaused(doPause: boolean);
begin
  if doPause then
    FDoWorkFlag.ResetEvent
  else
    FDoWorkFlag.SetEvent;
end;

function TWorkerThread.StartNewWork(newWorkFunc: TWorkFunction): boolean;
begin
  Result := Self.Paused; // Must be paused !
  if Result then
  begin
    FWorkFunc := newWorkFunc;
    FProgress := 0; // Reset progress counter
    if Assigned(FWorkFunc) then
      FDoWorkFlag.SetEvent; // Start work
  end;
end;

procedure TWorkerThread.Execute;
{- PostMessage LParam:
  0 : Work in progress, progress counter in WParam
  1 : Work is ready
  2 : Thread is closing
}
var
  readyFlag: boolean;
  waitList: array [0 .. 1] of THandle;
begin
  FProgress := 0;
  waitList[0] := FDoWorkFlag.Handle;
  waitList[1] := FCancelFlag.Handle;
  while not Terminated do
  begin
    if (WaitForMultipleObjects(2, @waitList[0], false, INFINITE) <>
      WAIT_OBJECT_0) then
      break; // Terminate thread when FCancelFlag is signaled
    // Do some work
    readyFlag := FWorkFunc;
    if readyFlag then // work is done, pause thread
      Self.Paused := true;
    Inc(FProgress);
    // Inform main thread about progress
    PostMessage(FOwnerFormHandle, FCallbackMsg, WPARAM(FProgress),
      LPARAM(readyFlag));
  end;
  PostMessage(FOwnerFormHandle, FCallbackMsg, 0, LPARAM(2)); // Closing thread
end;

function TWorkerThread.GetPaused: boolean;
begin
  Result := (FDoWorkFlag.Waitfor(0) <> wrSignaled);
end;

end.
