""" Putting everything together
"""
module main
using Test
using Logging
using JSON

include("structs.jl")
include("database.jl")
include("cache.jl")
include("backend.jl")
include("cli.jl")
include("websocket.jl")
include("texts.jl")

logger = SimpleLogger()
global_logger(logger)


println(WELCOME)

BackendApp = nothing


run_cli(ws) = begin
    global BackendApp

    # DEFINE CLI COMMANDS
    __new(x::Integer, y::Integer, z::Integer)::Dict = begin
        BackendApp = backend_init(x, y, z)
        BackendApp.get_database_info(serialize=false)
        cluster = BackendApp.get_cluster_info()
        Dict(:action => "new", :data => cluster)
    end

    __get(id::RecordID)::Dict = begin
        record, _ = BackendApp.get_record(id)
        hash = BackendApp.hashing(id)
        result = Dict(:record => record, :hash => hash)
        Dict(:action => "get", :data => result)
    end

    __add(number::Integer)::Dict = begin
        result = BackendApp.add_records(number)
        BackendApp.get_database_info(serialize=false)
        Dict(:action => "add", :data => result)
    end

    __info()::Nothing = begin
        BackendApp.get_database_info(serialize=false)
        BackendApp.get_cluster_info(serialize=false)
        nothing
    end

    __hash(id::RecordID)::Dict = begin
        result = BackendApp.hashing(id)
        Dict(:action => "hash", :data => result)
    end

    __fail()::Dict = begin
        BackendApp.fail_server()
        cluster = BackendApp.get_cluster_info()
        Dict(:action => "new", :data => cluster)
    end

    __help()::Nothing = println(INSTRUCTION)

    commands = [
        cli_command("new", __new),
        cli_command("get", __get),
        cli_command("add", __add),
        cli_command("info", __info),
        cli_command("hash", __hash),
        cli_command("fail", __fail),
        cli_command("help", __help),
    ]

    # COMPOSING FUNCTION PIPELINE, JUST LIKE APIS & MIDDLEWARES
    command_map = Dict((c.name => c) for c=commands)
    api = cli_handler(command_map)

    guard(input::String) = begin
        if BackendApp == nothing
            valid = startswith(input, "new") || startswith(input, "help")
            input = valid ? input : ""
            if !valid
                @warn "BackendApp must be initialized first"
            end
        end

        return input
    end

    broadcast(result::Union{Dict, Nothing}) = begin
        if result isa Dict
            push!(result, :sender => SERVER)
            write(ws, JSON.json(result))
        end
        return result
    end

    log(result) = begin
        @show result
        println("~~~~~~~~~~~~~~~~~~~~~~~~~~~~> Finished")
    end

    cli_loop(INSTRUCTION, log ∘ broadcast ∘ api ∘ guard)
end


ws_callback = (handler::Function) -> (sender, data, ws, cws) -> begin
    client_count_before = length(values(cws))
    handler(sender, data, ws, cws)
    client_count_after = length(values(cws))

    if client_count_after > client_count_before && BackendApp != nothing
        println("New client attached, Foward system info!")
        print("command /")
        data = Dict(
            :data => BackendApp.get_cluster_info(),
            :sender => string(SERVER),
            :action => "new",
        )
        serialized = JSON.json(data)
        write(ws, serialized)
    end

end

make_websocket_server(authenticate, ws_callback(socket_handler))
make_websocket_client(run_cli)

end
