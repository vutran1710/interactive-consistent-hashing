module main
using Test
using Logging

include("structs.jl")
include("database.jl")
include("caches.jl")
include("app.jl")
include("websocket.jl")

logger = SimpleLogger()
global_logger(logger)


authenticate(data::String, ws) = begin
    parsed = JSON.parse(data)
    @test getproperty(parsed, "sender") != nothing
    return parsed["sender"], data
end

socket_handler(sender, data, ws, cws) = begin
    if !haskey(cws, sender) && sender != "server"
        return push!(cws, sender => ws)
    end

    if sender != "server"
        return nothing
    end

    for (_, ws) in cws
        sending_ws = cws[sender]
        write(sending_ws, data)
    end
end


make_websocket_server(authenticate, socket_handler)
make_websocket_client((serialize ∘ app_init))
end
