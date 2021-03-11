using Test
using JSON
using Logging
include("../src/structs.jl")
include("../src/database.jl")
include("../src/cache.jl")
include("../src/cli.jl")
include("../src/backend.jl")
include("../src/websocket.jl")

logger = SimpleLogger()
global_logger(logger)


@testset "database" begin
    count = 10
    db = db_init(count)
    @test db.count() == 10

    record = db.select_single(1)
    @test record isa Record
    @test record.id == 1
    @info record.name

    record = db.select_single(100)
    @test record == nothing

    records = db.select_many(r -> r.id > 2)
    @test length(records) == 8
    @test records isa Array{Record}

    records = db.select_many(r -> r.id > 200)
    @test records isa Array{Record}
    @test length(records) == 0

    records = db.insert_records(4)
    @test db.count() == 14
end


@testset "caches" begin
    caches = create_cache_servers(3)
    @test length(caches) == 3
    # NOTE: evenly distributed
    node_tbl = create_virtual_nodes(caches, 4)
    @test node_tbl isa Table
    @test length(node_tbl[node_tbl.online .== true]) == 12
    @test length(node_tbl) == 12
    @info node_tbl

    # NOTE:table row sorted by angles, ascendingly
    for (idx, row) in enumerate(node_tbl)
        if idx == 1
            continue
        end
        prev = node_tbl[idx-1]
        @test row.angle > prev.angle
    end

    # =====================================================

    caches = create_cache_servers(7)
    @test length(caches) == 7
    # NOTE: randomly distributed
    node_tbl = create_virtual_nodes(caches, 10; even=false)
    @test node_tbl isa Table
    @test length(node_tbl) == 70
    @info node_tbl

    # NOTE:table row sorted by angles, ascendingly
    for (idx, row) in enumerate(node_tbl)
        if idx == 1
            continue
        end
        prev = node_tbl[idx-1]
        @test row.angle > prev.angle
    end

    # ===================================================
    # Testing CacheCluster
    db = db_init(20)
    rec = db.select_single(2)
    ctbl = cache_init(4, 5; on_cache_miss=db.select_single)
    r, cache_id = ctbl.get(2)
    @test r.id == rec.id
    @test r.name == rec.name
    @test cache_id isa String
    @info cache_id

    r, _= ctbl.get(200)
    @test r == nothing

    ctbl.get(2)

    # ==================================================
    # Testing Hashing
    id, hashed, angle, cache_id = ctbl.find(234)
    @test id == 234
    @test angle > 0
    @test cache_id isa ServerID
    @info id, hashed, angle, cache_id

    id, hashed, angle, cache_id = ctbl.find(382349)
    @test id == 382349
    @test angle > 0
    @test cache_id isa ServerID
    @info id, hashed, angle, cache_id

    id, hashed, angle, cache_id = ctbl.find(3)
    @test id == 3
    @test angle > 0
    @test cache_id isa ServerID
    @info id, hashed, angle, cache_id
end


@testset "cli" begin
    test_cmd(x::Integer) = x + 1
    clicmd = cli_command("test", test_cmd)
    @info clicmd isa CLICommand
    @info clicmd.argument_types == [Integer]

    test_cmd(x::Integer, y::Integer) = x + y
    clicmd = cli_command("test", test_cmd)
    @info clicmd isa CLICommand
    @info clicmd.argument_types == [Integer, Integer]

    test_cmd() = "Hello"
    clicmd = cli_command("test", test_cmd)
    @info clicmd isa CLICommand
    @info clicmd.argument_types == []

    cmd0 = CLICommand("test0", () -> nothing, [])
    cmd1 = CLICommand("test1", x -> x ^ 2, [Integer])
    cmd2 = CLICommand("test2", (x, y) -> x + y, [Integer, Integer])
    cmd3 = CLICommand("test3", (x, y) -> x * " " * y, [String, String])

    cmd_map = Dict(
        cmd0.name => cmd0,
        cmd1.name => cmd1,
        cmd2.name => cmd2,
        cmd3.name => cmd3,
    )

    handler = cli_handler(cmd_map)

    @test handler("test0") == nothing
    @test handler("test1") == nothing
    @test handler("test1 2") == 4
    @test handler("test2 2 3") == 5
    @test handler("test2 2 3 4") == 5
    @test handler("test3 hello world") == "hello world"
end


@testset "backend" begin
    be = backend_init(10, 2, 3)
    @test be isa Backend

    cluster = be.get_cluster_info()
    @test cluster isa Array
    @test cluster[1] isa Tuple

    serialized = JSON.json(cluster)
    @show serialized

    fail_server = be.fail_server()
    @test fail_server isa String
    @info "Failing=$(fail_server)"

    updated_cluster = be.get_cluster_info(serialized=false)
    @info updated_cluster

    fail_server = be.fail_server()
    @test fail_server isa String
    @info "Failing=$(fail_server)"

    updated_cluster = be.get_cluster_info(serialized=false)
    @info updated_cluster

    id, angle, cache_id = be.hashing(123456)
    @test id == 123456
    @info angle, cache_id
end


@testset "websocket" begin
    data = ""
    @test authenticate(data, 1) == (nothing, data)
    data = "{\"sender\":\"vutran\"}"
    @test authenticate(data, 1) == ("vutran", data)

    mock = []
    cws = Dict()

    Base.write(x::Integer, y::String) = begin
        # Overwrite for testing only
        mock = [mock..., x, y]
    end

    r = socket_handler("abc", data, 1, cws)
    @test r == nothing
    @test isempty(mock)
    @test length(keys(cws)) == 1

    r = socket_handler("asdf", data, 1, cws)
    @test r == nothing
    @test isempty(mock)
    @test length(keys(cws)) == 2

    r = socket_handler(string(SERVER), data, 2, cws)
    @test r == nothing
    @test length(mock) == 4
    @test length(keys(cws)) == 2
end
