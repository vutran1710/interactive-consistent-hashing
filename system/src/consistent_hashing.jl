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


run_cli(ws) = begin
    BackendApp = nothing

    # DEFINE CLI COMMANDS
    __new(x::Integer, y::Integer, z::Integer) = begin
        BackendApp = backend_init(x, y, z)
        cluster = BackendApp.get_cluster_info()
        Dict(:action => "new", :data => cluster)
    end

    __get(id::RecordID) = begin
        result = BackendApp.get_record(record_id)
        Dict(:action => "get", :data => result)
    end

    __add(number::Integer) = begin
        result = BackendApp.add_record(number)
        Dict(:action => "add", :data => result)
    end

    __hash(id::RecordID) = begin
        result = BackendApp.hashing(id)
        Dict(:action => "hash", :data => result)
    end

    __fail() = begin
        BackendApp.fail_server()
        cluster = BackendApp.get_cluster_info()
        Dict(:action => "new", :data => cluster)
    end

    __help() = println(INSTRUCTION)

    commands = [
        cli_command("new", __new),
        cli_command("get", __get),
        cli_command("add", __add),
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

    log(result) = @show result; println("\n\n")

    cli_loop(INSTRUCTION, log ∘ broadcast ∘ api ∘ guard)
end

make_websocket_server(authenticate, socket_handler)
make_websocket_client(run_cli)

end
