module main
using Logging

include("structs.jl")
include("database.jl")
include("caches.jl")
include("app.jl")
include("websocket.jl")

logger = SimpleLogger()
global_logger(logger)

end
