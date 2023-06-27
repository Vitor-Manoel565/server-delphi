{$mode objfpc}{$H+}

uses
  SysUtils, Classes, fphttpserver, fpjson, jsonparser;

type
  TMyHTTPServer = class(TFPHTTPServer)
    procedure RequestHandler(Sender: TObject; var ARequest: TFPHTTPConnectionRequest; var AResponse: TFPHTTPConnectionResponse);
    procedure HandleTesteRequest(AResponse: TFPHTTPConnectionResponse);
    procedure HandleFileRequest(ARequest: TFPHTTPConnectionRequest; AResponse: TFPHTTPConnectionResponse);
    procedure HandleWriteRequest(ARequest: TFPHTTPConnectionRequest; AResponse: TFPHTTPConnectionResponse);
    procedure SetCORSHeaders(AResponse: TFPHTTPConnectionResponse);
  end;

var
  MyHTTPServer: TMyHTTPServer;
  Data: TJSONData;

procedure TMyHTTPServer.RequestHandler(Sender: TObject; var ARequest: TFPHTTPConnectionRequest; var AResponse: TFPHTTPConnectionResponse);
begin
  writeln('Recebendo requisição: ' + ARequest.URI);

  // Adiciona os cabeçalhos CORS a todos os endpoints
  SetCORSHeaders(AResponse);

  // Se a requisição for do tipo OPTIONS, responda apenas com os cabeçalhos CORS
  if ARequest.Method = 'OPTIONS' then
  begin
    AResponse.Code := 204;
    AResponse.SendContent;
    Exit;
  end;

  if ARequest.URI = '/file' then
  begin
    HandleFileRequest(ARequest, AResponse);
    Exit;
  end;

  if ARequest.URI = '/teste' then
  begin
    HandleTesteRequest(AResponse);
    Exit;
  end;

  if ARequest.URI = '/write' then
  begin
    HandleWriteRequest(ARequest, AResponse);
    Exit;
  end;

  AResponse.Content := 'Hello, world!';
  AResponse.Code := 200;
  AResponse.SendContent;
end;

procedure TMyHTTPServer.SetCORSHeaders(AResponse: TFPHTTPConnectionResponse);
begin
  AResponse.SetCustomHeader('Access-Control-Allow-Origin', '*');
  AResponse.SetCustomHeader('Access-Control-Allow-Methods', 'GET, POST, PUT, DELETE, OPTIONS');
  AResponse.SetCustomHeader('Access-Control-Allow-Headers', 'Content-Type');
end;

procedure TMyHTTPServer.HandleTesteRequest(AResponse: TFPHTTPConnectionResponse);
begin
  AResponse.ContentType := 'text/plain; charset=utf-8';
  AResponse.Content := 'Rota "teste" acessada com sucesso!';
  AResponse.Code := 200;
  AResponse.SendContent;
end;

procedure TMyHTTPServer.HandleFileRequest(ARequest: TFPHTTPConnectionRequest; AResponse: TFPHTTPConnectionResponse);
var
  FileName: String;
  FileStream: TFileStream;
  JSONData: TJSONData;
begin
  FileName := ARequest.QueryFields.Values['filename'];
  if FileName = '' then
    FileName := 'data.json';

  FileStream := TFileStream.Create('DB/' + FileName, fmOpenRead);
  try
    JSONData := GetJSON(FileStream);
    AResponse.ContentType := 'application/json; charset=utf-8';
    AResponse.Content := JSONData.FormatJSON;
    AResponse.Code := 200;
    AResponse.SendContent;
  finally
    FileStream.Free;
  end;
end;

procedure TMyHTTPServer.HandleWriteRequest(ARequest: TFPHTTPConnectionRequest; AResponse: TFPHTTPConnectionResponse);
var
  ReceivedData: String;
  FileStream: TFileStream;
begin
  if (ARequest.Method = 'POST') or (ARequest.Method = 'PUT') then
  begin
    ReceivedData := ARequest.Content;

    Data := GetJSON(ReceivedData);
    FileStream := TFileStream.Create('DB/data.json', fmCreate);
    try
      FileStream.Write(Data.AsJSON[1], Length(Data.AsJSON));
    finally
      FileStream.Free;
    end;

    AResponse.ContentType := 'text/plain; charset=utf-8';
    AResponse.Content := 'Dados JSON escritos com sucesso!';
    AResponse.Code := 200;
    AResponse.SendContent;
  end
  else
  begin
    AResponse.ContentType := 'text/plain; charset=utf-8';
    AResponse.Content := 'Método inválido!';
    AResponse.Code := 405;
    AResponse.SendContent;
  end;
end;

begin
  MyHTTPServer := TMyHTTPServer.Create(nil);
  try
    MyHTTPServer.Address := '0.0.0.0';
    MyHTTPServer.Port := 8080;
    MyHTTPServer.OnRequest := @MyHTTPServer.RequestHandler;
    MyHTTPServer.Active := True;
    writeln('Servidor web iniciado na porta ' + IntToStr(MyHTTPServer.Port) + '.');
    writeln('Pressione [Enter] para encerrar o servidor.');
    readln;
  finally

  end;
end.
