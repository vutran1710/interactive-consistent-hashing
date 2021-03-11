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



INSTRUCTION = """
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
/new
    # create/recreate backend-app, with a database and a cache-cluster
    'args:
        - record_number::Integer
        - cache_number::Integer
        - virtual_node_for_each_cache_number::Integer
    'returns:
        # List of node-info, including node-label, angle,
        # server-id and online-status
        - Array{Tuple{String, Float, ServerID, Boolean}}

/get
    # get a single record by record-id
    'args:
        - record_id::Integer
    'returns:
        # Record data if found, and server-id of the cache
        # that is mapped to the hashed record_id
        - Tuple{Union{Record, Nothing}, ServerID}

/add
    # add more records
    'args:
        - record_number::Integer
    'returns:
        # New length of the updated table
        - Integer

/hash
    # find hashing and the mapped server to a given record-id
    'args:
        - id::Integer
    'returns:
        # Return a list of the given-input, the hashed value,
        # and the correspondent server-id
        - Array{id::Integer, hashed::Angle, nearest::Angle, ServerID}

/fail
    # failing a random cache-server from cluster
    # if there is already a failing server, it will be turned on again
    'args: none
    'returns:
        # The updated cache cluster info
        - Array{Tuple{String, Float, ServerID, Boolean}}

/help
    # show this diaglog again
============================== !SHOWTIME! ================================
"""


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
