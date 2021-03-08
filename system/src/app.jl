app_init(record_count::Integer, cache_count::Integer, node_per_server_count::Integer)::App = begin
    db = db_init(record_count)
    ch = cache_init(cache_count, node_per_server_count, db.select_single)
    __fail_server = () -> nothing
    App(ch.get, db.insert_records, __fail_server)
end
