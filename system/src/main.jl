module main
using Logging
using JSON
using TypedTables
using PrettyPrinting
using UUIDs: uuid1
using Faker: first_name, last_name
using SplitApplyCombine: group
using HTTP

include("structs.jl")
include("consistent_hashing.jl")
include("cli.jl")
include("ws.jl")
include("utils.jl")

logger = SimpleLogger()
global_logger(logger)
system = construct(10, 4, 3)

new_system(record_count, server_count, label_count) = begin
    system = construct(record_count, server_count, label_count)
end

cli_handle = ClientCLI(
    "Construct/re-construct a new System",
    "new" => (new_system, Integer, Integer, Integer),
    "Get a single record by its ID",
    "get" => (system.api__get_record, Integer),
    "Add a number of records to Store",
    "add" => (system.api__add_records, Integer),
)

Alerts = Dict(
    "new_client" => id -> "\n 🍑 New client attached: $(id)\n\n" * "command /",
    "no_client" => _ -> "\n\n 💀 No web-socket clients\n\n",
    "sent" => msg -> "\n 👌 Sent: $(msg)\n\n",
)

notify = (key, args...) -> print(Alerts[key](args...))

write_socket = ws -> msg -> begin
    if !(msg isa ResponseMessage)
        # NOTE: cli-command return nothing due to special command input
        return
    end

    if msg.message ∈ (USER_ERROR, SYSTEM_ERROR)
        return
    end

    write(ws, serialize(msg))
end


ClientWS(ws -> run_forever(cli_handle, after_cb=write_socket(ws)), notify)

end
