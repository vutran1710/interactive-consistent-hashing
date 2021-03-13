backend_init(
    record_count::Integer,
    cache_count::Integer,
    node_per_server_count::Integer,
)::Backend = begin
    db = db_init(record_count)
    ch = cache_init(cache_count, node_per_server_count; on_cache_miss=db.select_single)

    __get_cluster_info(;serialize=true)::Dict = begin
        server_ids = Set(ch.table.server)
        @show server_ids
        @show ch.table
        table = serialize ? values.(ch.table) : ch.table
        Dict(:id => server_ids, :table => table)
    end

    __get_database_info(;serialize=true)::Dict = begin
        @show db.table
        table = serialize ? values.(db.table) : db.table
        Dict(:table => table)
    end

    Backend(
        ch.get,
        db.insert_records,
        ch.find,
        ch.fail,
        __get_cluster_info,
        __get_database_info,
    )
end
