backend_init(
    record_count::Integer,
    cache_count::Integer,
    node_per_server_count::Integer,
)::Backend = begin
    db = db_init(record_count)
    ch = cache_init(cache_count, node_per_server_count; on_cache_miss=db.select_single)
    __fail_server = () -> nothing
    Backend(ch.get, db.insert_records, __fail_server)
end
