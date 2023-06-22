uses
  SysUtils, Classes, IdHTTPServer, IdContext, IdCustomHTTPServer, IdStack, IdGlobal;

type
  TMyRequestHandler = class
  private
    class var BingoNumbers: TStringList;
    class var BingoBoard: TStringList;
    class procedure InitializeBingoNumbers;
    class procedure InitializeBingoBoard;
  public
    class procedure HandleStartRequest(AContext: TIdContext; ARequestInfo: TIdHTTPRequestInfo; AResponseInfo: TIdHTTPResponseInfo);
    class procedure HandleNumberRequest(AContext: TIdContext; ARequestInfo: TIdHTTPRequestInfo; AResponseInfo: TIdHTTPResponseInfo);
    class procedure HandleBoardRequest(AContext: TIdContext; ARequestInfo: TIdHTTPRequestInfo; AResponseInfo: TIdHTTPResponseInfo);
  end;

var
  MyHTTPServer: TIdHTTPServer;

class procedure TMyRequestHandler.InitializeBingoNumbers;
var
  i: Integer;
begin
  BingoNumbers := TStringList.Create;
  for i := 1 to 75 do
    BingoNumbers.Add(IntToStr(i));
  BingoNumbers.Sort;
end;

class procedure TMyRequestHandler.InitializeBingoBoard;
var
  i: Integer;
begin
  BingoBoard := TStringList.Create;
  for i := 1 to 75 do
    BingoBoard.Add(IntToStr(i));
end;

class procedure TMyRequestHandler.HandleStartRequest(AContext: TIdContext; ARequestInfo: TIdHTTPRequestInfo; AResponseInfo: TIdHTTPResponseInfo);
begin
  InitializeBingoBoard;

  AResponseInfo.ContentText := 'O jogo de Bingo começou!';
  AResponseInfo.ResponseNo := 200;
end;

class procedure TMyRequestHandler.HandleNumberRequest(AContext: TIdContext; ARequestInfo: TIdHTTPRequestInfo; AResponseInfo: TIdHTTPResponseInfo);
var
  RandomIndex: Integer;
  SelectedNumber: string;
begin
  if BingoNumbers.Count = 0 then
  begin
    AResponseInfo.ContentText := 'O jogo de Bingo já terminou!';
    AResponseInfo.ResponseNo := 200;
    Exit;
  end;

  RandomIndex := Random(BingoNumbers.Count);
  SelectedNumber := BingoNumbers[RandomIndex];
  BingoNumbers.Delete(RandomIndex);

  AResponseInfo.ContentText := 'Número selecionado: ' + SelectedNumber;
  AResponseInfo.ResponseNo := 200;
end;

class procedure TMyRequestHandler.HandleBoardRequest(AContext: TIdContext; ARequestInfo: TIdHTTPRequestInfo; AResponseInfo: TIdHTTPResponseInfo);
begin
  AResponseInfo.ContentText := BingoBoard.Text;
  AResponseInfo.ResponseNo := 200;
end;

begin
  Randomize;
  TMyRequestHandler.InitializeBingoNumbers;
  TMyRequestHandler.InitializeBingoBoard;

  MyHTTPServer := TIdHTTPServer.Create(nil);
  try
    MyHTTPServer.DefaultPort := 8080;
    MyHTTPServer.OnCommandGet := TMyRequestHandler.HandleStartRequest;
    MyHTTPServer.OnCommandOther := TMyRequestHandler.HandleNumberRequest;

    MyHTTPServer.Active := True;

    writeln('Servidor web iniciado em http://localhost:8080');
    writeln('Pressione [Enter] para encerrar.');
    readln;
  finally
    MyHTTPServer.Free;
    TMyRequestHandler.BingoNumbers.Free;
    TMyRequestHandler.BingoBoard.Free;
  end;
end.

