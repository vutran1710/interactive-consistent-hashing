using Test
using JSON
using Logging
include("../src/structs.jl")
include("../src/database.jl")
include("../src/caches.jl")

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
    # Testing CacheTable
    db = db_init(20)
    rec = db.select_single(2)
    on_cache_miss = key -> db.select_single(key)
    ctbl = cache_init(4, 5, on_cache_miss)
    r = ctbl.get(2)
    @test r.id == rec.id
    @test r.name == rec.name

    r = ctbl.get(200)
    @test r == nothing

    ctbl.get(2)
end
