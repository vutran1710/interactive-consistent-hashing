create_cache_servers(number_of_servers::Integer)::Array{CacheServer} = begin
    id() = string(uuid1())[end-5:end]
    create(_) = CacheServer(id(), Dict())
    create.(1:number_of_servers)
end


create_virtual_nodes(
    caches::Array{CacheServer},
    number_of_labels_each_node::Integer;
    even=true,
)::Table = begin
    server_count = length(caches)
    cache_ids = (c -> c.id).(caches)
    total_node_count = number_of_labels_each_node * server_count

    chars = ('A':'Z')[begin:server_count]
    labels = [char * string(i) for char=chars, i=1:number_of_labels_each_node][:]
    angles = nothing

    if even
        # NOTE: nodes are distributed evenly over the Ring
        angles = (0:(360/total_node_count):360)[begin:total_node_count]
    else
        # NOTE: nodes are distributed randomly over the Ring
        angles = sample(0:360, total_node_count, ordered=true, replace=false)
    end

    ids = repeat(cache_ids, number_of_labels_each_node)
    online = collect(trues(total_node_count))
    @test length(angles) == length(ids) == length(online) == total_node_count
    Table(label=labels, angle=angles, server=ids, online=online)
end


""" We find the nearest cache-id in the counter-clockwise direction
    whose angle is greater than the hashed.
    For the sake of simplicty, we carry a simple O(n) linear search
"""
find_cache_by_hash(hash::Angle, tbl::Table)::Union{Row, Nothing} = begin
    onlines = tbl[tbl.online .== true]

    if isempty(onlines)
        return nothing
    end

    servers = onlines[onlines.angle .>= hash]
    row = !isempty(servers) ? servers[1] : onlines[1]
    return row
end


hashing(value::Integer)::Angle = begin
    mod(value, 360)
end


random_failing(tbl::Table)::Union{ServerID, Nothing} = begin
    onlines = tbl[tbl.online .== true]

    if isempty(onlines)
        return nothing
    end

    index = rand(1:length(onlines))
    server_id = tbl[index].server
    tbl.online .= [r.server == server_id ? false : r.online for r=tbl]
    server_id
end




""" Create a cache cluster
"""
cache_init(
    number_of_caches::Integer,
    number_of_labels_each_node::Integer;
    on_cache_miss::Any=nothing,
    on_cache_hit::Any=nothing,
)::CacheCluster = begin
    caches = create_cache_servers(number_of_caches)
    cache_map = Dict((s.id => s) for s=caches)
    tbl = create_virtual_nodes(caches, number_of_labels_each_node)

    """ Return data along with cache-id
    """
    __get(key::Integer)::Tuple{Any, Union{String, Nothing}} = begin
        hash = hashing(key)
        row = find_cache_by_hash(hash, tbl)

        if row == nothing
            @warn "CacheCluster has been down completely"
            return nothing, nothing
        end

        cache_id = row.server
        bucket = cache_map[cache_id].bucket
        data = get(bucket, key, nothing)

        if data != nothing
            result = on_cache_hit != nothing ? on_cache_hit(data) : data
            return result, cache_id
        end

        if on_cache_miss == nothing
            return nothing, cache_id
        end

        data = on_cache_miss(key)

        if data != nothing
            @info "cache-miss: caching $(data) in $(cache_id)"
            push!(bucket, key => data)
        end

        return data, cache_id
    end

    __find(id::RecordID)::Union{Nothing, Tuple{RecordID, Angle, Angle, ServerID}} = begin
        hash = hashing(id)
        row = find_cache_by_hash(hash, tbl)

        if row != nothing
            @info "Val=$(id) -> Hashed=$(hash) -> Nearest-Angle=$(row.angle) -> Server=$(row.server)"
            return id, hash, row.angle, row.server
        end

        return nothing
    end

    __fail() = random_failing(tbl)

    CacheCluster(tbl, __get, __find, __fail)
end
