module main
using Faker: first_name, last_name
using HTTP
using JSON
using Logging
using PrettyPrinting
using SplitApplyCombine: group
using StatsBase: sample
using TypedTables
using UUIDs: uuid1

include("structs.jl")
include("construct.jl")
include("cli.jl")
include("ws.jl")
include("utils.jl")

logger = SimpleLogger()
global_logger(logger)
system = construct(5, 2, 3)

new_system(record_count, server_count, label_count) = begin
    if label_count * server_count > 360
        @error "Number of server-labels cannot be larger than 360"
        return
    end
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
    "new_client" => id -> "\n\n 🍑 New client attached: $(id)\n\n" * "command /",
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
