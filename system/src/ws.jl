function ClientWS(f, noti)
    cws = Dict()

    @async HTTP.WebSockets.listen("127.0.0.1", UInt16(8081)) do ws
        while !eof(ws)
            data = String(readavailable(ws))
            msg = JSON.parse(data)
            sender = get(msg, "sender", nothing)

            if sender ∉ ["SERVER", nothing] && !haskey(cws, sender)
                push!(cws, sender => ws)
                noti("new_client", sender)
            end

            if isempty(cws)
                noti("no_client", nothing)
            end

            if sender == "SERVER" && !isempty(cws)
                clients = collect(values(cws))
                data = JSON.json(msg["data"])
                foreach(w -> write(w, data), clients)
                noti("sent", data)
            end
        end
    end

    HTTP.WebSockets.open("ws://127.0.0.1:8081") do ws
        f(ws)
    end
end
