module main
using Logging
using JSON
using TypedTables
using PrettyPrinting
using UUIDs: uuid1
using Faker: first_name, last_name
using SplitApplyCombine: group
using Colors
using HTTP

include("structs.jl")
include("consistent_hashing.jl")
include("cli.jl")
include("ws.jl")
include("utils.jl")

logger = SimpleLogger()
global_logger(logger)
system = construct(10, 4, 20)

new_system(record_count::Integer, server_count::Integer, label_count::Integer) = begin
    system = construct(record_count, server_count, label_count)
end


cli_handle = ClientCLI(
    "Construct/re-construct a new System",
    "new" => (new_system, [Integer, Integer, Integer]),
    "Get a single record by its ID",
    "get" => (system.api__get_record, Integer),
    "Add a number of records to Store",
    "add" => (system.api__add_records, Integer),
)

write_socket = ws::HTTP.WebSockets.WebSocket ->
    msg::ResponseMessage ->
    println(
        write(ws, serialize(msg)),
        ">> Sent to WS >>",
        String(readavailable(ws)),
    )


ClientWS(ws -> run_forever(cli_handle, after_cb=write_socket(ws)))

end
