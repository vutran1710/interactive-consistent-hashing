function create_records(; start::Integer=1, stop::Integer=1000)::Array{Record}
    data = [(i, "$(first_name()) $(last_name())") for i=start:stop]
    (t -> Record(t...)).(data)
end


function init_db(r::Array{Record})::Database
    ids = getproperty(:id).(r)
    names = getproperty(:name).(r)
    Database(Table(id=ids, name=names))
end


function add_records(records::Array{Record}, db::Database)
    for r in records
        push!(db.table.id, r.id)
        push!(db.table.name, r.name)
    end
end


function create_cache_servers(num::Integer)::Array{CacheServer}
    id() = string(uuid1())[end-5:end]
    create_server(_) = CacheServer(id(), Dict())
    create_server.(1:num)
end


function hashing(number::Integer)::Angle
    mod(number, 360)
end


function pin_servers(servers::Array{CacheServer})::Table
    """ Pin servers' points over the hashing-ring randomly
    """
    ids = getproperty(:id).(servers)
    angles = rand(0:360, length(servers))
    Table(server=ids, angle=angles)
end


function locate_cache(hashed::Angle, server_table::Table)::ServerID
    """ We find the nearest cache-id in the counter-clockwise direction
    whose angle is greater than the hashed
    """
    online_servers = server_table[server_table.online .== true]
    servers = map(r -> (r.angle, r.server), online_servers)
    sort!(servers, by=first)
    idx = findfirst(g -> g[1] >= hashed, servers)
    idx != nothing ? servers[idx][2] : servers[1][2]
end


function derive_server_labels(server_table::Table, label_count::Integer)::Table
    server_count = length(server_table)
    chars = Iterators.Stateful(('A':'Z')[begin:server_count])
    flatmap(fmap, iter) = collect(Iterators.flatten(map(fmap, iter)))

    derive_labels(row) = begin
        char = popfirst!(chars)
        map(i -> char * repr(i), 1:label_count)
    end

    derive_angles(row) = rand(0:360, label_count)
    repeat_server_id(row) = repeat([row.server], label_count)

    labels = flatmap(derive_labels, server_table)
    angles = flatmap(derive_angles, server_table)
    ids = flatmap(repeat_server_id, server_table)
    online = repeat([true], server_count * label_count)

    Table(label=labels, angle=angles, server=ids, online=online)
end


function construct(
    number_of_records::Integer,
    number_of_caches::Integer,
    number_of_labels::Integer,
)
    records = create_records(stop=number_of_records)
    caches = create_cache_servers(number_of_caches)
    cache_map = reduce((r, s) -> push!(r, s.id => s), caches, init=Dict())
    db = init_db(records)
    cache_table = pin_servers(caches)
    cache_hash_table = derive_server_labels(cache_table, number_of_labels)

    println("============== System Components ==============")
    println("> Cache IDs -----------------------------------")
    print(cache_table.server)
    print("\n\n")
    println("> Cache Hash Table with derived Labels --------")
    print(cache_hash_table)
    print("\n\n")
    println("> Cache Map -----------------------------------")
    pprint(cache_map)
    print("\n\n")
    println("> Database ------------------------------------")
    pprint(db.table)
    print("\n\n")
    println("===============================================")

    api__get_record(id::RecordID) = begin
        hashed = hashing(id)
        cache_id = locate_cache(hashed, cache_hash_table)
        cache_server = cache_map[cache_id]
        bucket = cache_server.bucket
        find = get(bucket, id, db.table[db.table.id .== id])

        if find isa Record
            @info "Cache-hit"
            return ResponseMessage(find, SUCCESS)
        end

        if length(find) > 0
            @info "Cache-miss"
            record = Record(id, find[1].name)
            push!(bucket, id => record)
            return ResponseMessage(record, SUCCESS)
        end

        return ResponseMessage(nothing, NOT_FOUND)
    end

    api__add_records(number::Integer) = begin
        start = length(db.table) + 1
        stop = start + number - 1
        new_records = create_records(start=start, stop=stop)
        add_records(new_records, db)
        println("Updated Table: $(length(db.table)) rows")
    end

    inspect__cache_data(cache_id::ServerID) = get(cache_map, cache_id, nothing)

    TheSystem(
        api__get_record,
        api__add_records,
        inspect__cache_data,
        db,
        cache_hash_table,
    )
end
