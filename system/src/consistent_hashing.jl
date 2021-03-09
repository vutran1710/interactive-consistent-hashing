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
    'args:
        - record_number::Integer
        - cache_number::Integer
        - virtual_node_each_cache_number::Integer
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

    __new(args...) = begin
        BACKEND = backend_init(args...)
        Dict(:action => "new", :data => args)
    end

    __get(record_id) = begin
        if BACKEND != nothing
            result = BACKEND.get_record(record_id)
            return Dict(:action => "get", :data => result)
        end
        @info "Backend must be initialized first, using \"new\" command"
    end

    __help() = println(instruction)

    commands = [
        CLICommand("new", __new, [Integer, Integer, Integer]),
        CLICommand("get", __get, [Integer]),
        CLICommand("help", __help, []),
    ]

    cmd_map = Dict((c.name => c) for c=commands)

    cmd_handler = cli_handler(cmd_map)

    handler = input -> begin
        result = cmd_handler(input)

        if result == nothing
            println("\n")
            return nothing
        end

        push!(result, :sender => SERVER)
        @show result
        write(ws, JSON.json(result))
        println("\n")
    end

    return cli_loop(instruction, handler)
end


make_websocket_server(authenticate, socket_handler)
make_websocket_client(run_cli)

end
