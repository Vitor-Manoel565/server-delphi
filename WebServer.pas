program WebServer;

{$mode objfpc}{$H+}

uses
  SysUtils, Classes, fphttpserver, sqldb, pqconnection;

type
  TMyHTTPServer = class(TFPHTTPServer)
    procedure RequestHandler(Sender: TObject; var ARequest: TFPHTTPConnectionRequest; var AResponse: TFPHTTPConnectionResponse);
    procedure HandleTesteRequest(AResponse: TFPHTTPConnectionResponse);
    procedure HandleTableRequest(AResponse: TFPHTTPConnectionResponse);
  end;

var
  MyHTTPServer: TMyHTTPServer;
  DBConnection: TPQConnection;
  SQLTransaction: TSQLTransaction;

procedure TMyHTTPServer.RequestHandler(Sender: TObject; var ARequest: TFPHTTPConnectionRequest; var AResponse: TFPHTTPConnectionResponse);
begin
  if ARequest.URI = '/usertable' then
  begin 
  HandleTableRequest(AResponse);
  Exit;
  end;

  if ARequest.URI = '/usertable' then
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

procedure TMyHTTPServer.HandleTableRequest(AResponse: TFPHTTPConnectionResponse);
begin
  AResponse.Content := 'id={1516hd6fh156}';
  AResponse.Code := 200; // HTTP_OK substituído pelo valor inteiro 200
  AResponse.SendContent;
end;
begin
  DBConnection := TPQConnection.Create(nil);
  try
    // DBConnection.HostName := 'localhost';
    // DBConnection.DatabaseName := 'your_database_name';
    // DBConnection.UserName := 'your_username';
    // DBConnection.Password := 'your_password';
    // DBConnection.Params.Add('port=8081');

    // SQLTransaction := TSQLTransaction.Create(DBConnection);
    // DBConnection.Transaction := SQLTransaction;

    // DBConnection.Open;

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

  finally
    DBConnection.Free;
  end;
end.
