{$mode objfpc}{$H+}

uses
  SysUtils, Classes, fphttpserver;

type
  TMyHTTPServer = class(TFPHTTPServer)
    procedure RequestHandler(Sender: TObject; var ARequest: TFPHTTPConnectionRequest; var AResponse: TFPHTTPConnectionResponse);
    procedure HandleTesteRequest(AResponse: TFPHTTPConnectionResponse);
    procedure HandleFileRequest(AResponse: TFPHTTPConnectionResponse);
  end;

var
  MyHTTPServer: TMyHTTPServer;
  arquivo: TextFile;
  texto: string;

procedure TMyHTTPServer.RequestHandler(Sender: TObject; var ARequest: TFPHTTPConnectionRequest; var AResponse: TFPHTTPConnectionResponse);
begin
  if ARequest.URI = '/file' then
  begin
    HandleFileRequest(AResponse);
    Exit;
  end;

  if ARequest.URI = '/teste' then
  begin
    HandleTesteRequest(AResponse);
    Exit;
  end;

  AResponse.Content := 'Hello, world!';
  AResponse.Code := 200; // HTTP_OK substituído pelo valor inteiro 200
  AResponse.SendContent;
end;

procedure TMyHTTPServer.HandleTesteRequest(AResponse: TFPHTTPConnectionResponse);
begin
  AResponse.Content := 'Rota "teste" acessada com sucesso!';
  AResponse.Code := 200; // HTTP_OK substituído pelo valor inteiro 200
  AResponse.SendContent;
end;

procedure TMyHTTPServer.HandleFileRequest(AResponse: TFPHTTPConnectionResponse);
var
  FileStream: TFileStream;
  Data: AnsiString;
begin
  // Use TFileStream para ler o arquivo data.txt
  FileStream := TFileStream.Create('DB/data.txt', fmOpenRead);
  try
    SetLength(Data, FileStream.Size);
    FileStream.Read(Data[1], FileStream.Size);
  finally
    FileStream.Free;
  end;

  AResponse.Content := Data;
  AResponse.Code := 200; // HTTP_OK substituído pelo valor inteiro 200
  AResponse.SendContent;
end;

begin
  MyHTTPServer := TMyHTTPServer.Create(nil);
  try
    MyHTTPServer.Port := 8080;
    MyHTTPServer.OnRequest := @MyHTTPServer.RequestHandler;
    MyHTTPServer.Active := True;

    writeln('Web server started on http://localhost:8080');
    writeln('Press [Enter] to quit.');
    readln;
  finally
    MyHTTPServer.Free;
  end;
end.
