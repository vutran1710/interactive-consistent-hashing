make_websocket_server(authenticate::Function, handler::Function) = begin
    cws = Dict()
    println("Initializing WS server, binding 0.0.0.0:8081")
    @async HTTP.WebSockets.listen("0.0.0.0", UInt16(8081)) do ws
        while !eof(ws)
            try
                data = String(readavailable(ws))
                sender, data = authenticate(data, cws)
                handler(sender, data, ws, cws)
            catch
                cws = Dict()
            end
        end
    end
end


make_websocket_client(handler::Function) = begin
    HTTP.WebSockets.open("ws://0.0.0.0:8081") do ws
        handler(ws)
    end
end


authenticate(data::String, _::Any) = begin
    get_sender = d -> get(d, "sender", nothing)
    sender = try (get_sender ∘ JSON.parse)(data) catch end
    return sender, data
end


socket_handler(sender, data, ws, cws) = begin
    if sender == nothing
        return
    end

    is_server_sending = sender == string(SERVER)

    if !haskey(cws, sender) && !is_server_sending
        push!(cws, sender => ws)
        return
    end

    if is_server_sending
        client_wss = values(cws)
        foreach(w -> write(w, data), client_wss)
    end
end
