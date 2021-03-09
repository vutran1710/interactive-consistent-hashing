using HTTP


make_websocket_server(authenticate, handler) = begin
    cws = Dict()

    @async HTTP.WebSockets.listen("127.0.0.1", UInt16(8081)) do ws
        while !eof(ws)
            data = String(readavailable(ws))
            parsed, sender = nothing, nothing

            try
                parsed = JSON.parse(data)
                sender = authenticate(JSON.parse(data))
            catch
                continue
            end

            if sender == nothing
                continue
            end

            handler(sender, ws, cws, parsed, data)
        end
    end
end


make_websocket_client(handler) = begin
    HTTP.WebSockets.open("ws://127.0.0.1:8081") do ws
        handler(ws)
    end
end
