program SimpleServer;

{$mode objfpc}

uses
  SysUtils,
  Sockets;

const
  DEFAULT_PORT = 1234;
  INVALID_SOCKET = TSocket(-1);

var
  ServerSocket, ClientSocket: TSocket;
  ServerAddr, ClientAddr: TInetSockAddr;
  BytesReceived: Integer;
  Buffer: array[0..1023] of Byte;
  BufferStr: AnsiString;

begin
  try
    // Create server socket
    ServerSocket := fpSocket(AF_INET, SOCK_STREAM, 0);

    // Bind server socket to a port
    ServerAddr.sin_family := AF_INET;
    ServerAddr.sin_port := htons(DEFAULT_PORT);
    ServerAddr.sin_addr.s_addr := INADDR_ANY;
    fpBind(ServerSocket, @ServerAddr, SizeOf(ServerAddr));

    // Listen for incoming connections
    fpListen(ServerSocket, 1);
    Writeln('Server started. Listening on port ', DEFAULT_PORT);

    while True do
    begin
      // Accept incoming connections
      ClientSocket := fpAccept(ServerSocket, @ClientAddr, @BytesReceived);

      if ClientSocket <> INVALID_SOCKET then
      begin
        // Handle client requests
        repeat
          // Receive data from client
          BytesReceived := fpRecv(ClientSocket, @Buffer[0], SizeOf(Buffer), 0);

          // Process received data
          if BytesReceived > 0 then
          begin
            // Convert received bytes to a string
            SetString(BufferStr, PAnsiChar(@Buffer[0]), BytesReceived);

            // Display received message
            Writeln('Received: ', BufferStr);
          end;
        until BytesReceived <= 0;

        // Close client socket
        CloseSocket(ClientSocket);
      end;
    end;
  finally
    // Close server socket
    CloseSocket(ServerSocket);
  end;
end.
