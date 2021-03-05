function ClientWS(f)
    @async HTTP.WebSockets.listen("127.0.0.1", UInt16(8081)) do ws
        while !eof(ws)
            data = readavailable(ws)
            write(ws, data)
        end
    end

    HTTP.WebSockets.open("ws://127.0.0.1:8081") do ws
        f(ws)
    end
end
