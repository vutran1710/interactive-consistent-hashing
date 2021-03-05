using HTTP


struct SocketMessage
    sender::String
    payload::String
    SocketMessage(data) = begin
        try
            parsed = JSON.parse(data)
            sender, payload = map(k -> get(parsed, k, nothing), ["sender", "payload"])
            new(sender, payload)
        catch e
            @error e
            new("", "")
        end
    end
end




function ClientWS(f)
    @async HTTP.WebSockets.listen("127.0.0.1", UInt16(8081)) do ws
        while !eof(ws)
            data = readavailable(ws)
            write(ws, data)
        end
    end

    receive_handler(msg::SocketMessage) = begin
        if msg.sender ∈ ["server", ""]
            return println("Ignore")
        end

        return println("__|> received: " * msg.sender * " $(msg.payload)")
    end

    HTTP.WebSockets.open("ws://127.0.0.1:8081") do ws
        f(ws)
    end
end
