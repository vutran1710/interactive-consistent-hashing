using HTTP


make_websocket_server(authenticate::Function, handler::Function) = begin
    cws = Dict()

    @async HTTP.WebSockets.listen("127.0.0.1", UInt16(8081)) do ws
        while !eof(ws)
            try
                data = String(readavailable(ws))
                sender, data = authenticate(data, cws)
                handler(sender, data, ws, cws)
            catch e
                @error e
            end
        end
    end
end


make_websocket_client(handler::Function) = begin
    HTTP.WebSockets.open("ws://127.0.0.1:8081") do ws
        tolerate(handler, ws)
    end
end
