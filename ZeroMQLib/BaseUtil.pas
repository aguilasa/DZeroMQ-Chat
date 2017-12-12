unit BaseUtil;

interface

uses
  System.Classes, System.SysUtils;

type

  TMessageType = (mtJoin, mtString, mtStream);

  TWriter = class
  private
    FStream: TMemoryStream;
  public
    constructor Create;
    destructor Destroy; override;
    procedure WriteByte(aValue: Byte);
    procedure WriteInteger(aValue: Integer);
    procedure WriteString(aValue: string);
    procedure WriteStream(aValue: TMemoryStream);
    property Stream: TMemoryStream read FStream;
  end;

  TReader = class
  private
    FStream: TMemoryStream;
  public
    constructor Create(aStream: TMemoryStream);
    function ReadByte: Byte;
    function ReadInteger: Integer;
    function ReadString: string;
    function ReadStream: TMemoryStream;
  end;

implementation

const
  SizeOfByte = SizeOf(Byte);
  SizeOfInteger = SizeOf(Integer);

{ TWriter }

constructor TWriter.Create;
begin
  FStream := TMemoryStream.Create;
end;

destructor TWriter.Destroy;
begin
  FStream.Free;
  inherited;
end;

procedure TWriter.WriteByte(aValue: Byte);
begin
  FStream.Write(aValue, SizeOfByte);
end;

procedure TWriter.WriteInteger(aValue: Integer);
begin
  FStream.Write(aValue, SizeOfInteger);
end;

procedure TWriter.WriteStream(aValue: TMemoryStream);
begin

end;

procedure TWriter.WriteString(aValue: string);
var
  Bytes: TBytes;
  Len: Integer;
begin
  Bytes := BytesOf(aValue);
  Len := Length(Bytes);
  WriteInteger(Len);
  FStream.Write(Bytes, Len);
end;

{ TReader }

constructor TReader.Create(aStream: TMemoryStream);
begin
  FStream := aStream;
end;

function TReader.ReadByte: Byte;
begin
  FStream.Read(Result, SizeOfByte);
end;

function TReader.ReadInteger: Integer;
begin
  FStream.Read(Result, SizeOfInteger);
end;

function TReader.ReadStream: TMemoryStream;
begin

end;

function TReader.ReadString: string;
var
  Len: Integer;
  Bytes: TBytes;
begin
  Len := ReadInteger;
  SetLength(Bytes, Len);
  FStream.ReadBuffer(Bytes, Len);
  Result := StringOf(Bytes);
end;

end.
