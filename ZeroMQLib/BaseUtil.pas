unit BaseUtil;

interface

uses
  System.Classes, System.SysUtils;

type
  TFastWriterSection = class
  private
    FStream: TMemoryStream;
    FPosition: Integer;
    FParent: TFastWriterSection;
    constructor Create(aStream: TMemoryStream; aParent: TFastWriterSection);
    procedure Write( const aBuffer; aSize: Integer );
    procedure Close;
    property Parent: TFastWriterSection read FParent;
  end;

  TFastWriter = class
  private
    FStream: TStream;
    FCache, FCachePos, FCacheMaxPos: PChar;
    FSection: TFastWriterSection;
    FSectionStream: TMemoryStream;
    procedure iWrite( const aValue; aSize: Integer );
  public
    constructor Create( aStream: TStream; aCacheSize: Integer );
    destructor Destroy; override;
    procedure WriteBoolean( aValue: Boolean );
    procedure WriteByte( aValue: Byte );
    procedure WriteWord( aValue: Word );
    procedure WriteLongint( aValue: Longint );
    procedure WriteDateTime( aValue: TDateTime );
    procedure WriteString( aValue: String ); // 1 Byte
    procedure WriteMediumString( aValue: String); // 2 Bytes
    procedure WriteLongString( aValue: String); // 4 Bytes
    procedure WriteText( aValue: String );
    procedure WriteBinary( aValue: PChar; aSize: Longint );
    procedure WriteFloat(_Value: Extended);
    procedure WriteChar(_Value: Char);
    procedure BeginSection;
    procedure EndSection;
  end;

  PFastReaderSection = ^TFastReaderSection;
  TFastReaderSection = record
    Next: PFastReaderSection;
    NextLimit: Word;
  end;

  TFastReader = class
  private
    FStream: TStream;
    FOwner: Boolean;
    FCache, FCachePos, FCacheMaxPos: PChar;
    FCacheSize: Integer;
    FSection: PFastReaderSection;
    FLimit: Word;
    procedure iRead( var aValue; aSize: Integer );
  public
    constructor Create( aStream: TStream; aCacheSize: Integer; aOwner: Boolean = false);
    destructor Destroy; override;
    function ReadBoolean: Boolean;
    function ReadByte: Byte;
    function ReadWord: Word;
    function ReadLongint: Longint;
    function ReadDateTime: TDateTime;
    function ReadString: String;
    procedure SkipString;
    function ReadMediumString: String; // 2 Bytes
    function ReadLongString: String; // 4 Bytes
    function ReadText: String;
    procedure ReadBinary( aValue: PChar; aSize: Longint );
    function ReadFloat: Extended;
    function ReadChar: Char;
    procedure Skip( aSize: Longint );
    procedure SkipSection;
    procedure BeginSection;
    procedure EndSection;
  end;

  TWriterManager = class
  private
    FStream: TMemoryStream;
    FWriter: TFastWriter;
  public
    constructor Create;
    destructor Destroy; override;
    property Stream: TMemoryStream read FStream;
    property Writer: TFastWriter read FWriter;
  end;

  TReaderManager = class
  private
    FStream: TMemoryStream;
    FReader: TFastReader;
  public
    constructor Create(const aBuffer; aCount: Integer);
    destructor Destroy; override;
    property Stream: TMemoryStream read FStream;
    property Reader: TFastReader read FReader;
  end;

implementation

{ TFastWriterSection }

constructor TFastWriterSection.Create(aStream: TMemoryStream; aParent: TFastWriterSection);
var
  xSize: Word;
begin
  inherited Create;
  FStream := aStream;
  FPosition := aStream.Position;
  FParent := aParent;
  xSize := 0;
  aStream.Write(xSize, 2);
end;

procedure TFastWriterSection.Write( const aBuffer; aSize: Integer );
begin
  FStream.Write(aBuffer, aSize);
end;

procedure TFastWriterSection.Close;
var
  xPos: Integer;
  xSize: Integer;
  xWordSize: Word;
begin
  xPos := FStream.Position; // Pega a posição atual.
  xSize := xPos - (FPosition + 2); // Tamanho do início até a posição atual.
  if (xSize > High(Word)) then
    raise Exception.CreateFmt('Section is too big (%d bytes). Maximum session size is %d bytes.', [xSize, High(Word)]);
  FStream.Position := FPosition; // Vai até a posição do tamanho.
  xWordSize := xSize;
  FStream.Write(xWordSize, 2); // Grava o tamanho.
  FStream.Position := xPos; // Vai até a posição atual.
end;

{ TFastWriter }

procedure TFastWriter.iWrite( const aValue; aSize: Integer );
var
  p: PChar;
  xSpaceLeft, xCacheSize, xWriteSize: Integer;
begin
  if (FSection <> nil) then
  begin
    FSection.Write(aValue, aSize);
    Exit;
  end;
  if (FCache = nil) then
  begin
    FStream.WriteBuffer(aValue, aSize);
    Exit;
  end;
  p := @aValue;
  xSpaceLeft := FCacheMaxPos - FCachePos;
  if (xSpaceLeft < aSize) then
  begin
    // Precisamos gravar mais do que cabe no cache.

    // Para minimizar gravações, vamos primeiro preencher o cache e
    // gravar ele inteiro.
    Move(p^, FCachePos^, xSpaceLeft);
    Inc(p, xSpaceLeft);
    Dec(aSize, xSpaceLeft);
    xCacheSize := FCacheMaxPos - FCache;
    FStream.WriteBuffer(FCache^, xCacheSize);
    // Agora o cache está vazio.
    FCachePos := FCache;

    // Para minimizar gravações, vamos gravar N blocos de xCacheSize bytes.
    xWriteSize := (aSize div xCacheSize) * xCacheSize;
    if (xWriteSize > 0) then
    begin
      FStream.WriteBuffer(p^, xWriteSize);
      Inc(p, xWriteSize);
      Dec(aSize, xWriteSize);
    end;

    // Se sobrou alguma coisa, vai para o cache.
  end;
  Move(p^, FCachePos^, aSize);
  Inc(FCachePos, aSize);
end;

constructor TFastWriter.Create( aStream: TStream; aCacheSize: Integer );
begin
  inherited Create;
  FStream := aStream;
  if (aCacheSize > 0) then
  begin
    FCache := AllocMem(aCacheSize);
    FCachePos := FCache;
    FCacheMaxPos := FCache + aCacheSize;
  end;
end;

destructor TFastWriter.Destroy;
var
  xSection: TFastWriterSection;
begin
  while (FSection <> nil) do
  begin
    xSection := FSection;
    FSection := FSection.Parent;
    xSection.Destroy;
  end;
  FreeAndNil(FSectionStream);
  if (FCache <> nil) and (FStream <> nil) and (FCachePos <> FCache) then
    FStream.WriteBuffer(FCache^, FCachePos - FCache);
  ReallocMem(FCache, 0);
  inherited Destroy;
end;

procedure TFastWriter.WriteBoolean( aValue: Boolean );
begin
  iWrite(aValue, 1);
end;

procedure TFastWriter.WriteByte( aValue: Byte );
begin
  iWrite(aValue, 1);
end;

procedure TFastWriter.WriteWord( aValue: Word );
begin
  iWrite(aValue, 2);
end;

procedure TFastWriter.WriteLongint( aValue: Longint );
begin
  iWrite(aValue, 4);
end;

procedure TFastWriter.WriteDateTime( aValue: TDateTime );
begin
  iWrite(aValue, SizeOf(TDateTime));
end;

procedure TFastWriter.WriteString( aValue: String );
var
  xLen: Integer;
begin
  xLen := Length(aValue);
  if (Length(aValue) > 255) then
    raise Exception.Create('Must use WriteLongString for strings greater than 255 chars.');
  WriteByte(xLen);
  WriteBinary(PChar(aValue), xLen);
end;

procedure TFastWriter.WriteMediumString( aValue: String); // 2 Bytes
var
  xLen: Integer;
begin
  xLen := Length(aValue);
  if (Length(aValue) > High(Word)) then
    raise Exception.Create('Must use WriteLongString for strings greater than 64K chars.');
  WriteWord(xLen);
  WriteBinary(PChar(aValue), xLen);
end;

procedure TFastWriter.WriteLongString( aValue: String); // 4 Bytes
var
  xLen: Integer;
begin
  xLen := Length(aValue);
  WriteLongint(xLen);
  WriteBinary(PChar(aValue), xLen);
end;

procedure TFastWriter.WriteText( aValue: String );
var
  xLen: Integer;
begin
  xLen := Length(aValue);
  iWrite(xLen, 1);
  iWrite(PChar(aValue)^, xLen);
end;

procedure TFastWriter.WriteBinary( aValue: PChar; aSize: Longint );
begin
  iWrite(aValue^, aSize);
end;

procedure TFastWriter.WriteFloat(_Value: Extended);
begin
  iWrite(_Value, SizeOf(Extended));
end;

procedure TFastWriter.WriteChar(_Value: Char);
begin
  iWrite(_Value, 1);
end;

procedure TFastWriter.BeginSection;
begin
  if (FSectionStream = nil) then
    FSectionStream := TMemoryStream.Create;
  FSection := TFastWriterSection.Create(FSectionStream, FSection);
end;

procedure TFastWriter.EndSection;
var
  xParent: TFastWriterSection;
begin
  if (FSection = nil) then
    raise Exception.Create('There is no active section. To avoid this, use try-finally with BeginSection-EndSection.');
  xParent := FSection.Parent;
  FSection.Close;
  FSection.Destroy;
  FSection := xParent;
  if (xParent = nil) then
  begin
    iWrite(FSectionStream.Memory^, FSectionStream.Position);
    FSectionStream.Position := 0;
  end;
end;

{ TFastReader }

procedure TFastReader.iRead( var aValue; aSize: Integer );
var
  p: PChar;
  xOnCache, xRead: Integer;
begin

  if (FSection <> nil) then
    if (aSize > FLimit) then
      raise Exception.Create('Attempt to read after end of current section.')
    else
      Dec(FLimit, aSize);

  if (FCache = nil) then
  begin
    FStream.ReadBuffer(aValue, aSize);
    Exit;
  end;

  p := @aValue;

  xOnCache := FCacheMaxPos - FCachePos;
  while (xOnCache < aSize) do
  begin
    // Precisamos ler mais do que há no cache.

    // Primeiro lemos o que está no cache.
    Move(FCachePos^, p^, xOnCache);
    Inc(p, xOnCache);
    Dec(aSize, xOnCache);
    // Agora o cache está vazio.

    // Para minimizar leituras e movimentações na memória, enquanto
    // o que falta ler for maior ou igual ao FCacheSize, vamos ler
    // diretamente para o buffer.
    while (aSize >= FCacheSize) do
    begin
      xRead := FStream.Read(p^, aSize);
      if (xRead = 0) then
        raise EReadError.Create('Attempt to read after end of stream.');
      if (xRead < 0) then
        raise EReadError.Create('Read error.');
      Inc(p, xRead);
      Dec(aSize, xRead);
    end;

    // Agora vamos preencher o cache, para futuras leituras.
    xOnCache := FStream.Read(FCache^, FCacheSize);
    if (xOnCache < 0) then
      raise EReadError.Create('Read error.');
    FCachePos := FCache;
    FCacheMaxPos := FCache + xOnCache;
    // Pode ser que leitura seja menor do que FCacheSize.
    // Isto permite xOnCache < aSize. Mas este while resolve isto.
  end;

  Move(FCachePos^, p^, aSize);
  Inc(FCachePos, aSize);
end;

constructor TFastReader.Create( aStream: TStream; aCacheSize: Integer; aOwner: Boolean);
begin
  inherited Create;
  FStream := aStream;
  if (aCacheSize > 0) then
  begin
    FCache := AllocMem(aCacheSize);
    FCacheSize := aCacheSize;
    FCachePos := FCache;
    FCacheMaxPos := FCache;
  end;
  FOwner := aOwner;
end;

destructor TFastReader.Destroy;
var
  xSection: PFastReaderSection;
begin
  while (FSection <> nil) do
  begin
    xSection := FSection;
    FSection := FSection.Next;
    FreeMem(xSection);
  end;
  FStream.Seek(Integer(FCachePos) - Integer(FCacheMaxPos), soFromCurrent);
  ReallocMem(FCache, 0);
  if FOwner then
    FStream.Destroy;
  inherited Destroy;
end;

function TFastReader.ReadBoolean: Boolean;
begin
  iRead(Result, 1);
end;

function TFastReader.ReadByte: Byte;
begin
  iRead(Result, 1);
end;

function TFastReader.ReadWord: Word;
begin
  iRead(Result, 2);
end;

function TFastReader.ReadLongint: Longint;
begin
  iRead(Result, 4);
end;

function TFastReader.ReadDateTime: TDateTime;
begin
  iRead(Result, SizeOf(TDateTime));
end;

function TFastReader.ReadString: String;
var
  xLen: Byte;
begin
  iRead(xLen, 1);
  SetLength(Result, xLen);
  iRead(PChar(Result)^, xLen);
end;

procedure TFastReader.SkipString;
var
  xLen: Byte;
begin
  iRead(xLen, 1);
  Skip(xLen);
end;

function TFastReader.ReadMediumString: String; // 2 Bytes
var
  xLen: Integer;
begin
  xLen := ReadWord;
  SetString(Result, PChar(nil), xLen);
  iRead(PChar(Result)^, xLen);
end;

function TFastReader.ReadLongString: String; // 4 Bytes
var
  xLen: Integer;
begin
  xLen := ReadLongint;
  SetString(Result, PChar(nil), xLen);
  iRead(PChar(Result)^, xLen);
end;

function TFastReader.ReadText: String;
var
  xLen: Longint;
begin
  iRead(xLen, 4);
  SetLength(Result, xLen);
  iRead(PChar(Result)^, xLen);
end;

procedure TFastReader.ReadBinary( aValue: PChar; aSize: Longint );
begin
  iRead(aValue^, aSize);
end;

function TFastReader.ReadFloat: Extended;
begin
  iRead(Result, SizeOf(Extended));
end;

function TFastReader.ReadChar: Char;
begin
  iRead(Result, 1);
end;

procedure TFastReader.Skip( aSize: Longint );
var
  xPosition, xSize: Longint;
begin

  if (aSize < 0) then
    raise Exception.CreateFmt('Size must be non-negative, not %d.', [aSize]);
  if (aSize = 0) then
    Exit;

  if (FSection <> nil) then
    if (aSize > FLimit) then
      raise Exception.Create('Attempt to read after end of current section.')
    else
      Dec(FLimit, aSize);

  if (FCache <> nil) then
  begin
    xSize := FCacheMaxPos - FCachePos;
    if (xSize > aSize) then
      xSize := aSize;
    Dec(aSize, xSize);
    Inc(FCachePos, xSize);
  end;

  if (aSize = 0) then
    Exit;

  xPosition := FStream.Position;
  xSize := FStream.Seek(aSize, soFromCurrent) - xPosition;
  if (xSize < aSize) then
    raise EReadError.Create('Attempt to read after end of stream.')
  else
  if (xSize > aSize) then
    raise EReadError.Create('Seek error.');

end;

procedure TFastReader.SkipSection;
var
  xSize: Word;
begin
  iRead(xSize, 2);
  Skip(xSize);
end;

procedure TFastReader.BeginSection;
var
  xSize: Word;
  xSection: PFastReaderSection;
begin
  iRead(xSize, 2);
  if (FSection <> nil) and (xSize > FLimit) then
    raise Exception.Create('TFastReader position is corrupt. Some BeginSection was issued at wrong position.');
  xSection := AllocMem(SizeOf(TFastReaderSection));
  xSection.Next := FSection;
  xSection.NextLimit := FLimit - xSize;
  FSection := xSection;
  FLimit := xSize;
end;

procedure TFastReader.EndSection;
var
  xSection: PFastReaderSection;
begin
  if (FSection = nil) then
    raise Exception.Create('There is no active section. To avoid this, use try-finally with BeginSection-EndSection.');
  if (FLimit <> 0) then
    raise Exception.CreateFmt('EndSection issued before actual end (%d byte were not read). There are missing reads or BeginSection issued at wrong position.', [FLimit]);
  xSection := FSection;
  FSection := xSection.Next;
  FLimit := xSection.NextLimit;
  FreeMem(xSection);
end;

{ TWriterManager }

constructor TWriterManager.Create;
begin
  FStream := TMemoryStream.Create;
  FWriter := TFastWriter.Create(FStream, 0);
end;

destructor TWriterManager.Destroy;
begin
  FreeAndNil(FWriter);
  FreeAndNil(FStream);
  inherited;
end;

{ TReaderManager }

constructor TReaderManager.Create(const aBuffer; aCount: Integer);
begin
  FStream := TMemoryStream.Create;
  FStream.WriteBuffer(aBuffer, aCount);
  FStream.Position := 0;
  FReader := TFastReader.Create(FStream, 0);
end;

destructor TReaderManager.Destroy;
begin
  FreeAndNil(FReader);
  FreeAndNil(FStream);
  inherited;
end;

end.
