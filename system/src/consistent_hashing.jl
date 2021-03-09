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

logger = SimpleLogger()
global_logger(logger)


run_cli(ws) = begin
    instruction = """
/new
    'creating backend-app
    'args: record_number::Integer cache_number::Integer virtual_node_each_cache::Integer
    'return: nothing

/get
    'get a single record by record-id
    'args: record_id::Integer
    'return: Union{Record, Nothing}, CacheID

/help
    'show this diaglog again
==================================== !SHOWTIME! =======================================
"""
    BACKEND = nothing

    new_backend = (args...) -> begin
        BACKEND = backend_init(args...)
        Dict(:action => "new", :data => args)
    end

    get_record = record_id -> begin
        @show BACKEND, record_id
        if BACKEND != nothing
            result = BACKEND.get_record(record_id)
            Dict(:action => "get", :data => result)
        end
        return nothing
    end

    help = () -> println(instruction)

    commands = [
        CLICommand("new", new_backend, [Integer, Integer, Integer]),
        CLICommand("get", get_record, [Integer]),
        CLICommand("help", help, []),
    ]

    cmd_map = Dict((c.name => c) for c=commands)
    commander = cli_handler(cmd_map)
    handler = input -> begin
        result = commander(input)

        if result == nothing
            return nothing
        end

        push!(result, :sender => SERVER)
        write(ws, json(result))
        println("\n")
    end

    return cli_loop(instruction, handler)
end

make_websocket_server(authenticate, socket_handler)
make_websocket_client(run_cli)
end
