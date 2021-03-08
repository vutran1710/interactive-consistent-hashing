using StatsBase: sample
using UUIDs: uuid1


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
        angles = 0:(360/(total_node_count-1)):360
    else
        angles = sample(0:360, total_node_count, ordered=true, replace=false)
    end

    ids = repeat(cache_ids, number_of_labels_each_node)
    online = collect(trues(total_node_count))
    Table(label=labels, angle=angles, server=ids, online=online)
end

find_cache_by_hash(hash::Angle, tbl::Table)::ServerID = begin
    """ We find the nearest cache-id in the counter-clockwise direction
    whose angle is greater than the hashed.
    For the sake of simplicty, we carry a simple O(n) linear search
    """
    online_only = tbl[tbl.online .== true]
    servers = online_only[online_only.angle .>= hash]
    (!isempty(servers) ? servers[1] : tbl[1]).server
end

hashing(value::Integer)::Angle = begin
    mod(value, 360)
end


""" Create a cache table
"""
cache_init(
    number_of_caches::Integer,
    number_of_labels_each_node::Integer,
    on_cache_miss::Any;
    on_cache_hit=nothing,
)::CacheTable = begin
    caches = create_cache_servers(number_of_caches)
    cache_map = Dict((s.id => s) for s=caches)
    tbl = create_virtual_nodes(caches, number_of_labels_each_node)

    __get(;key=nothing) = begin
        if key == nothing
            return nothing
        end

        hash = hashing(key)
        cache_id = find_cache_by_hash(hash, tbl)
        bucket = cache_map[cache_id].bucket
        data = get(bucket, key, nothing)

        if data == nothing
            data = on_cache_miss(key)
            if data != nothing
                @info "cache-miss: caching $(data) in $(cache_id)"
                push!(bucket, key => data)
            end
            return data
        end

        @info "cache-hit: cached $(data) in $(cache_id)"
        return on_cache_hit != nothing ? on_cache_hit(data) : data
    end

    CacheTable(tbl, __get)
end
