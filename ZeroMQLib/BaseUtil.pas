unit BaseUtil;

interface

uses
  System.Classes, System.SysUtils, System.Generics.Collections;

type

  TMessageType = (mtJoin, mtString, mtStream);

  TReceivedData = record
    MessageType: TMessageType;
    Nickname: string;
    StringMessage: string;
    StreamName: string;
    StreamData: TBytes;
  end;

  TStreamData = class
  private
    FStream: TMemoryStream;
    FName: string;
  public
    constructor Create;
    destructor Destroy; override;
    property Stream: TMemoryStream read FStream write FStream;
    property Name: string read FName write FName;
  end;

  TBytesWriter = class
  private
    FBytes: TList<TBytes>;
    function GetBytes: TArray<TBytes>;
  public
    constructor Create;
    destructor Destroy; override;
    procedure WriteByte(aValue: Byte);
    procedure WriteInteger(aValue: Integer);
    procedure WriteString(aValue: string);
    procedure WriteStream(aValue: TMemoryStream);
    property Bytes: TArray<TBytes> read GetBytes;
  end;

  TReaderData = class
  private
    FBytes: TArray<TBytes>;
  public
    constructor Create(aBytes: TArray<TBytes>);
    function GetReceivedData: TReceivedData;
  end;

implementation

const
  SizeOfByte = SizeOf(Byte);
  SizeOfInteger = SizeOf(Integer);

{ TBytesWriter }

constructor TBytesWriter.Create;
begin
  FBytes := TList<TBytes>.Create;
end;

destructor TBytesWriter.Destroy;
begin
  FBytes.Free;
  inherited;
end;

function TBytesWriter.GetBytes: TArray<TBytes>;
begin
  Result := FBytes.ToArray;
end;

procedure TBytesWriter.WriteByte(aValue: Byte);
var
  Bytes: TBytes;
  Stream: TMemoryStream;
begin
  Stream := TMemoryStream.Create;
  try
    SetLength(Bytes, SizeOfByte);
    Stream.Write(aValue, SizeOfByte);
    Stream.Seek(0,0);
    Stream.Read(Bytes, SizeOfByte);
    FBytes.Add(Bytes);
  finally
    Stream.Free;
  end;
end;

procedure TBytesWriter.WriteInteger(aValue: Integer);
var
  Stream: TMemoryStream;
  Bytes: TBytes;
begin
  SetLength(Bytes, SizeOfInteger);
  Stream := TMemoryStream.Create;
  try
    Stream.Write(aValue, SizeOfInteger);
    Stream.Seek(0,0);
    Stream.Read(Bytes, SizeOfInteger);
    FBytes.Add(Bytes);
  finally
    Stream.Free;
  end;
end;

procedure TBytesWriter.WriteStream(aValue: TMemoryStream);
var
  Bytes: TBytes;
begin
  aValue.Seek(0, 0);
  SetLength(Bytes, aValue.Size);
  aValue.Read(Bytes, aValue.Size);
  FBytes.Add(Bytes)
end;

procedure TBytesWriter.WriteString(aValue: string);
var
  Bytes: TBytes;
begin
  Bytes := BytesOf(aValue);
  FBytes.Add(Bytes);
end;


{ TReaderData }

constructor TReaderData.Create(aBytes: TArray<TBytes>);
begin
  FBytes := aBytes;
end;

function TReaderData.GetReceivedData: TReceivedData;
begin
  Result.MessageType := TMessageType(FBytes[0][0]);
  Result.Nickname := StringOf(FBytes[1]);
  if Result.MessageType in [mtJoin, mtString] then
  begin
    Result.StringMessage := StringOf(FBytes[2]);
  end
  else if Result.MessageType = mtStream then
  begin
    Result.StreamName := StringOf(FBytes[2]);
    Result.StreamData := FBytes[3];
  end;
end;

{ TStreamData }

constructor TStreamData.Create;
begin
  FStream := TMemoryStream.Create;
end;

destructor TStreamData.Destroy;
begin
  if Assigned(FStream) then
    FStream.Free;

  inherited;
end;

end.

