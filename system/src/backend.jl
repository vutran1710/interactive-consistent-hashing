backend_init(
    record_count::Integer,
    cache_count::Integer,
    node_per_server_count::Integer,
)::Backend = begin
    db = db_init(record_count)
    ch = cache_init(cache_count, node_per_server_count; on_cache_miss=db.select_single)

    __hashing(id::RecordID) = ch.find(id)
    __fail_server() = ch.fail()
    __cache_cluster_info(;serialize=true) = begin
        ids = Set(ch.table.server)
        table = serialize ? values.(ch.table) : ch.table
        Dict(:id => ids, :table => table)
    end

    Backend(
        ch.get,
        db.insert_records,
        __hashing,
        __fail_server,
        __cache_cluster_info,
    )
end
