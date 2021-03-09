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
                @info stacktrace()
            end
        end
    end
end


make_websocket_client(handler::Function) = begin
    HTTP.WebSockets.open("ws://127.0.0.1:8081") do ws
        handler(ws)
    end
end


authenticate(data::String, ws) = begin
    get_sender = d -> get(d, "sender", nothing)
    sender = try (get_sender ∘ JSON.parse)(data) catch end
    return sender, data
end


socket_handler(sender, data, ws, cws) = begin
    if sender == nothing
        return
    end

    if !haskey(cws, sender) && sender != SERVER
        push!(cws, sender => ws)
        return
    end

    if sender != SERVER
        return
    end

    for (_, sending_ws) in cws
        write(sending_ws, data)
    end
end
