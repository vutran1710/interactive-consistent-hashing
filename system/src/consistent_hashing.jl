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


const run_cli = (app::Backend) -> (ws::HTTP.WebSockets.WebSocket) -> begin

    ref_app = app

    __new(x::Integer, y::Integer, z::Integer)::Dict = begin
        ref_app = backend_init(x, y, z)
        ref_app.get_database_info(serialize=false)
        cluster = ref_app.get_cluster_info()
        Dict(:action => "new", :data => cluster)
    end

    __get(id::RecordID)::Dict = begin
        record, _ = ref_app.get_record(id)
        hash = ref_app.hashing(id)
        result = Dict(:record => record, :hash => hash)
        Dict(:action => "get", :data => result)
    end

    __add(number::Integer)::Dict = begin
        result = ref_app.add_records(number)
        ref_app.get_database_info(serialize=false)
        Dict(:action => "add", :data => result)
    end

    __info()::Nothing = begin
        ref_app.get_database_info(serialize=false)
        ref_app.get_cluster_info(serialize=false)
        nothing
    end

    __hash(id::RecordID)::Dict = begin
        result = ref_app.hashing(id)
        Dict(:action => "hash", :data => result)
    end

    __fail()::Dict = begin
        ref_app.fail_server()
        cluster = ref_app.get_cluster_info()
        Dict(:action => "new", :data => cluster)
    end

    __help()::Nothing = println(INSTRUCTION)

    handlers = cli_handler([
        cli_command("new", __new),
        cli_command("get", __get),
        cli_command("add", __add),
        cli_command("info", __info),
        cli_command("hash", __hash),
        cli_command("fail", __fail),
        cli_command("help", __help),
    ])

    broadcast(result::Union{Dict, Nothing})::Nothing = begin
        if result isa Dict
            push!(result, :sender => SERVER)
            write(ws, JSON.json(result))
            @show result
        end
        println("~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ FINISHED")
    end

    cli_loop(INSTRUCTION, broadcast ∘ handlers)
end


const wscallback = (
    app::Backend,
    handler::Function,
) -> (
    sender::String,
    data::Any,
    ws::HTTP.WebSockets.WebSocket,
    cws::Dict,
) -> begin
    client_count_before = length(values(cws))
    handler(sender, data, ws, cws)
    client_count_after = length(values(cws))

    if client_count_after > client_count_before
        println("New client attached, Foward system info!")
        print("command /")
        data = Dict(
            :data => app.get_cluster_info(),
            :sender => string(SERVER),
            :action => "new",
        )
        serialized = JSON.json(data)
        write(ws, serialized)
    end
end


function ich_exec()::Nothing
    sample_app = backend_init(10, 3, 3)
    println("Initializing a sample app")
    println("- 10 records, 3 cache-servers & 3 virtual node each servers")

    if !haskey(ENV, "COMPILE")
        make_websocket_server(authenticate, wscallback(sample_app, socket_handler))
        make_websocket_client(run_cli(sample_app))
    end
end


ich_exec()


end
