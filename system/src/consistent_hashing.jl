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
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
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

/add
    'add more records
    'args: number::Integer
    'return: nothing

/help
    'show this diaglog again
============================== !SHOWTIME! ================================
"""
    BackendApp = nothing

    # DEFINE CLI COMMANDS
    __new(args...) = begin
        BackendApp = backend_init(args...)
        Dict(:action => "new", :data => args)
    end

    __get(record_id) = begin
        result = BackendApp.get_record(record_id)
        Dict(:action => "get", :data => result)
    end

    __add(number) = begin
        result = BackendApp.add_record(number)
        Dict(:action => "add", :data => result)
    end

    __help() = println(instruction)

    commands = [
        CLICommand("new", __new, [Integer, Integer, Integer]),
        CLICommand("get", __get, [Integer]),
        CLICommand("add", __add, [Integer]),
        CLICommand("help", __help, []),
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

    write_to_socket(result::Union{Dict, Nothing}) = begin
        if result isa Dict
            push!(result, :sender => SERVER)
            write(ws, JSON.json(result))
        end
        return result
    end

    log(result) = @show result; println("\n\n")

    cli_loop(instruction, log ∘ write_to_socket ∘ api ∘ guard)
end

make_websocket_server(authenticate, socket_handler)
make_websocket_client(run_cli)

end
