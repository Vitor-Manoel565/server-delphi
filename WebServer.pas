{$mode objfpc}{$H+}

uses
  SysUtils, Classes, fphttpserver, fpjson, jsonparser;

type
  TMyHTTPServer = class(TFPHTTPServer)
    procedure RequestHandler(Sender: TObject; var ARequest: TFPHTTPConnectionRequest; var AResponse: TFPHTTPConnectionResponse);
    procedure HandleTesteRequest(AResponse: TFPHTTPConnectionResponse);
    procedure HandleFileRequest(AResponse: TFPHTTPConnectionResponse);
    procedure HandleWriteRequest(ARequest: TFPHTTPConnectionRequest; AResponse: TFPHTTPConnectionResponse);
  end;

var
  MyHTTPServer: TMyHTTPServer;
  Data: TJSONData;

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

  if ARequest.URI = '/write' then
  begin
    HandleWriteRequest(ARequest, AResponse);
    Exit;
  end;

  AResponse.Content := 'Hello, world!';
  AResponse.Code := 200;
  AResponse.SendContent;
end;

procedure TMyHTTPServer.HandleTesteRequest(AResponse: TFPHTTPConnectionResponse);
begin
  AResponse.Content := 'Rota "teste" acessada com sucesso!';
  AResponse.Code := 200;
  AResponse.SendContent;
end;

procedure TMyHTTPServer.HandleFileRequest(AResponse: TFPHTTPConnectionResponse);
var
  FileStream: TFileStream;
  JSONData: TJSONData;
begin
  FileStream := TFileStream.Create('DB/data.json', fmOpenRead);
  try
    JSONData := GetJSON(FileStream);
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
  if ARequest.Method = 'POST' then
  begin
    ReceivedData := ARequest.Content;

    Data := GetJSON(ReceivedData);
    FileStream := TFileStream.Create('DB/data.json', fmCreate);
    try
      FileStream.Write(Data.AsJSON[1], Length(Data.AsJSON));
    finally
      FileStream.Free;
    end;

    AResponse.Content := 'Dados JSON escritos com sucesso!';
    AResponse.Code := 200;
    AResponse.SendContent;
  end
  else
  begin
    AResponse.Content := 'Método inválido!';
    AResponse.Code := 405;
    AResponse.SendContent;
  end;
end;

begin
  MyHTTPServer := TMyHTTPServer.Create(nil);
  try
    MyHTTPServer.Port := 8080;
    MyHTTPServer.OnRequest := @MyHTTPServer.RequestHandler;
    MyHTTPServer.Active := True;

    writeln('Servidor web iniciado em http://localhost:8080');
    writeln('Pressione [Enter] para sair.');
    readln;
  finally
    MyHTTPServer.Free;
    Data.Free;
  end;
end.
